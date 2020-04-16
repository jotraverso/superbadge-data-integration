public with sharing class ProjectCalloutService {
	private static String calloutTemplate = '"opportunityId": "{0}", "opportunityName": "{1}", "accountName": "{2}", "closeDate": "{3}", "amount": {4}';

	@InvocableMethod
	public static void PostOpportunityToPMS(List<Id> opportunityIds) {
		QueueablePMSCall qOperation = new QueueablePMSCall(opportunityIds);
		qOperation.execute(null);
	}

	public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
		public List<Id> myOppIds;

		public QueueablePMSCall(List<Id> oppIds) {
			myOppIds = oppIds;
		}

		public void execute(QueueableContext ctxt) {
			ServiceTokens__c tokenSetting = [SELECT Id, Name, Token__c FROM ServiceTokens__c WHERE Name = 'ProjectServiceToken' LIMIT 1];
			List<Opportunity> myOpps = [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity WHERE Id IN :myOppIds];
			for (Opportunity opp : myOpps) {
				Http con = new Http();
				HttpRequest myRequest = new HttpRequest();
				myRequest.setEndpoint('callout:ProjectService');
				myRequest.setMethod('POST');
				myRequest.setHeader('Content-Type', 'application/json');
				myRequest.setHeader('Authorization', 'Bearer ' + tokenSetting.Token__c);
				List<Object> calloutParams = new List<Object>{ opp.Id, opp.Name, opp.Account.Name, opp.CloseDate, opp.Amount };
				myRequest.setBody('{' + String.format(calloutTemplate, calloutParams) + '}');
				HttpResponse myResp = con.send(myRequest);
				Integer code = myResp.getStatusCode();
				Boolean isFailure = code / 100 != 2;
				if (isFailure) {
					opp.StageName = 'Resubmit Project';
				} else {
					opp.StageName = 'Submitted Project';
				}
			}
			update myOpps;
		}
	}
}
