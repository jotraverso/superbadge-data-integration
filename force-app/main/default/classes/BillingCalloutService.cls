public class BillingCalloutService {
	public static void callBillingService(Map<Id, Project__c> oldProjects, Map<Id, Project__c> newProjects) {
		for (Project__c prj : newProjects.values()) {
			Project__c oldPrj = oldProjects.get(prj.Id);
			if (prj.Status__c != oldPrj.Status__c && prj.Status__c == 'Billable') {
				futureCallBillingService(prj.Id, prj.ProjectRef__c, prj.Billable_Amount__c);
			}
		}
	}

	@future(callout=true)
	public static void futureCallBillingService(Id projectId, String projectRef, Decimal billingAmount) {
		ServiceCredentials__c sc = [SELECT Id, Username__c, Password__c FROM ServiceCredentials__c WHERE Name = 'BillingServiceCredential' LIMIT 1];
		BillingServiceProxy.InvoicesPortSoap11 proxy = new BillingServiceProxy.InvoicesPortSoap11();
		BillingServiceProxy.project project = new BillingServiceProxy.project();
		project.projectid = projectRef;
		project.billAmount = billingAmount;
		project.username = sc.Username__c;
		project.password = sc.Password__c;
		String result = proxy.billProject(project);
		if ('OK' == result) {
			update new Project__c(Id = projectId, Status__c = 'Billed');
		}
	}
}
