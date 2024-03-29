public class JobAppWizardTest {
	
	
	public static testMethod void testMyController() {
		// Testing the Job Application Wizard
		PageReference pageRef = new PageReference('Page.jobAppStep1');
		Test.setCurrentPage(pageRef);
		ApexPages.standardController controller = new ApexPages.standardController(new Job_Application__c());
		JobAppWizard extension = new JobAppWizard(controller);
		Job_Application__c jobApp = extension.jobApplication;
			
		// Verify that page fails without specifying a Position
		System.assertNotEquals(extension.step2(),null);
		
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('posId',[select id from Position__c limit 1].id);
		
		// Instantiate a new controller with all parameters in the page
		extension = new JobAppWizard(controller);
		// re-instantiate the jobApp to pick up the posId now
		jobApp = extension.jobApplication;
		String pageTwo = extension.step2().getUrl();
		System.assertEquals('/apex/jobappstep2',pageTwo);
		
		// verify getter/setter works for SearchText
		extension.searchText='Paul*';
		System.assertEquals(extension.searchText,'Paul*');
		
		// the following 3 lines are special; for testing SOSL in testMethods
		//	see the Apex PDF for more info on SOSL in testMethods
		Id [] fixedSearchResults= new Id[1];
		fixedSearchResults[0] = [select id from Candidate__c where first_name__c='Paul' and last_name__c='Revere'].id;
		Test.setFixedSearchResults(fixedSearchResults);
		// now we do the controller's sosl search
		PageReference dummy = extension.doSearch();
		// verify the results of the search		
		List<Candidate__c> results = extension.results;
		System.debug('results=' + results);
		System.assert(results.size() > 0);
		System.assertNotEquals(results[0].email__c,null);
		
		// now let's simulate the user selecting one of the candidates from the search results
		extension.candidateId = results[0].id;
		String pageThree = extension.selectCandidate().getUrl();
		// make sure the page transferred to step 3 upon selecting the candidate
		System.assertEquals('/apex/jobappstep3', pageThree);
		// make sure the candidate was set by the selectCandidate() method
		Candidate__c cand = extension.candidate;
		System.assertNotEquals(cand.last_name__c,null);
		
		// move back to page 2 and validate the toggle to creating a brand new candidate
		pageTwo = extension.step2().getUrl();
		System.assertEquals('/apex/jobappstep2', pageTwo);
		extension.showSearch = false;
		extension.NewCandidate();
		// candidateId should be null now
		System.assertEquals(extension.candidateId,null);
		cand = extension.candidate;
		// candidate should be empty now
		System.assertEquals(cand.last_name__c,null);
		 
		// now let's simulate the user filling out the new candidate form and move to page 3
		cand = new Candidate__c(first_name__c = 'Mike',
							 	last_name__c = 'Reuben',
							 	email__c = 'mike@reuben.com');
		extension.candidate = cand;
		pageThree = extension.step3().getUrl();
		System.assertEquals('/apex/jobappstep3', pageThree);
		
		// now let's run the save() and verify the new candidate and job_application creation
		System.debug('candidate=' + extension.candidate);
		jobApp = extension.jobApplication;
		// run the save()
		String saveUrl = extension.save().getUrl();
		// get the latest candidate and verify it
		cand = extension.candidate;
		System.assertNotEquals(cand.id,null);
		// get the latest jobApp and verify it
		jobApp = extension.jobApplication;
		System.assertEquals(jobApp.Candidate__c,cand.id);
		System.assertNotEquals(jobApp.id,null);
		// verify the Url after the save() method occurred
		String jobAppUrl = '/' + jobApp.id;
		System.assertEquals(saveUrl,jobAppUrl);
	}
}