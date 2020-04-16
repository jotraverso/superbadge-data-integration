@isTest
private class ProjectCalloutServiceTest {
	@TestSetup
	static void setupData() {
		ServiceTokens__c cSetting = new ServiceTokens__c(Name = 'ProjectServiceToken', Token__c = 'token');
		insert cSetting;

		Account testAcct = new Account();
		testAcct.name = 'Test Account';
		testAcct.type = 'Customer - Direct';
		insert testAcct;

		Opportunity testOpp = new Opportunity();
		testOpp.name = 'Test Opportunity';
		testOpp.AccountId = testAcct.id;
		testOpp.type = 'New Project';
		testOpp.CloseDate = system.today();
		testOpp.StageName = 'Negotiation/Review';
		testOpp.Amount = 500000;
		insert testOpp;
	}

	@IsTest
	static void testCalloutOk() {
		Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
		Test.startTest();
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		ProjectCalloutService.PostOpportunityToPMS(new List<Id>{ opp.Id });
		Test.stopTest();
	}

	@IsTest
	static void testCalloutFailure() {
		Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
		Test.startTest();
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		ProjectCalloutService.PostOpportunityToPMS(new List<Id>{ opp.Id });
		Test.stopTest();
	}
}
