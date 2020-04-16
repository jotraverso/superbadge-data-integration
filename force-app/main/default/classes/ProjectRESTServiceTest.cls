@isTest
private class ProjectRESTServiceTest {
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
	static void testRestServiceOK() {
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Test.startTest();
		ProjectRESTService.postProjectData('ProjectRef', 'ProjectName', opp.Id, Date.today(), Date.today().addMonths(2), 100000, 'Running');
		Opportunity updatedOpp = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity WHERE Id = :opp.Id];
		Project__c newProject = [SELECT Id FROM Project__c WHERE Opportunity__c = :opp.Id LIMIT 1];
		System.assert(newProject.Id != null, 'The new project was not created');
		System.assertEquals('In progress', updatedOpp.DeliveryInstallationStatus__c, 'Opportunity DeliveryInstallationStatus__c was not updated');
		Test.stopTest();
	}

	@IsTest
	static void testRestServiceFail() {
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Test.startTest();
		String result = ProjectRESTService.postProjectData(
			'ProjectRef',
			'ProjectName',
			opp.Id,
			Date.today(),
			Date.today().addMonths(2),
			100000,
			'INVALID VALUE'
		);
		List<Project__c> newProjectList = [SELECT Id FROM Project__c WHERE Opportunity__c = :opp.Id];
		System.assertEquals(0, newProjectList.size(), 'A Project was created');
		System.assertNotEquals('OK', result);
		Test.stopTest();
	}
}
