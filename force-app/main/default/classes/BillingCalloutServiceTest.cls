@isTest
private class BillingCalloutServiceTest {
	@TestSetup
	static void setupData() {
		ServiceTokens__c cSetting = new ServiceTokens__c(Name = 'ProjectServiceToken', Token__c = 'token');
		insert cSetting;

		ServiceCredentials__c cCredentials = new ServiceCredentials__c(
			Name = 'BillingServiceCredential',
			Username__c = 'username',
			Password__c = 'password'
		);
		insert cCredentials;

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

		Project__c testProject = new Project__c();
		testProject.ProjectRef__c = 'ProjectRef';
		testProject.Opportunity__c = testOpp.Id;
		testProject.Billable_Amount__c = 500000;
		testProject.Start_Date__c = Date.today();
		testProject.Start_Date__c = Date.today().addMonths(2);
		testProject.Status__c = 'Running';
		insert testProject;
	}

	@IsTest
	static void testCalloutOk() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
		Test.startTest();
		Project__c myProject = [SELECT Id FROM Project__c LIMIT 1];
		myProject.Status__c = 'Billable';
		update myProject;
		Test.stopTest();
		Project__c updatedProject = [SELECT Id, Status__c FROM Project__c WHERE Id = :myProject.Id LIMIT 1];
		System.assertEquals('Billed', updatedProject.Status__c, 'The Project status was not updated');
	}

	@IsTest
	static void testCalloutFailure() {
		Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
		Test.startTest();
		Project__c myProject = [SELECT Id FROM Project__c LIMIT 1];
		myProject.Status__c = 'Billable';
		update myProject;
		Test.stopTest();
		Project__c updatedProject = [SELECT Id, Status__c FROM Project__c WHERE Id = :myProject.Id LIMIT 1];
		System.assertEquals('Billable', updatedProject.Status__c, 'The Project status was updated');
	}
}
