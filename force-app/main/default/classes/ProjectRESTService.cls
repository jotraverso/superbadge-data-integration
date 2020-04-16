@RestResource(urlMapping='/project')
global class ProjectRESTService {
	@HttpPost
	global static String postProjectData(
		String ProjectRef,
		String ProjectName,
		String OpportunityId,
		Date StartDate,
		Date EndDate,
		Double Amount,
		String Status
	) {
		Savepoint sp = Database.setSavepoint();
		try {
			Project__c proj = new Project__c();
			proj.ProjectRef__c = ProjectRef;
			proj.Name = ProjectName;
			proj.Opportunity__c = OpportunityId;
			proj.Start_Date__c = StartDate;
			proj.End_Date__c = EndDate;
			proj.Billable_Amount__c = Amount;
			proj.Status__c = Status;
			update new Opportunity(Id = OpportunityId, DeliveryInstallationStatus__c = 'In progress');
			upsert proj ProjectRef__c;
			return 'OK';
		} catch (System.DmlException ex) {
			Database.rollback(sp);
			return ex.getMessage();
		}
	}
}
