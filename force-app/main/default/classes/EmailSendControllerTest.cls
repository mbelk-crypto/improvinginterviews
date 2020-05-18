@isTest
public class EmailSendControllerTest {
    @TestSetup
    public static void testSetup(){
Candidate__c cand = new Candidate__c(
            Name = 'Test Candidate Name',
            First_Name__c = 'test first Name ',
            Last_Name__c = 'test last Name',
            Email__c = 'test@email.com',
            Phone__c = '7894561230'
        );
        insert cand;
        
        Id devAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Account acc = new Account(
            Name = 'test Account',
            RecordTypeId = devAccountRecordTypeId,
            Special_Logistics__c  = 'Test Special Logistics',
            Company_Logo__c = ' test src="testlogoLink"   '
        );
        insert acc;
        System.debug(acc.Company_Logo__c);
        
        Contact cnt = new Contact(
            LastName = 'test cnt LastName',
            AccountId = acc.Id
        );
        insert cnt;
        
        Job__c job = new Job__c(
            Name = 'Engineer',
            Company__c = acc.id,
            Industry__c = 'Engineering',
            Level__c = 'VP'
        );
        insert job;
        
        Interview__c interview  = new Interview__c(
            Candidate_Name__c =cand.Id,
            Location__c = 'Test Location',
            Company__c = acc.Id,
            Job_Record__c = job.Id,
            Interview_Date__c = System.today(),
            Interview_Start_Time__c = System.now().time() + 10,
            Interview_End_Time__c = System.now().time() + 11, 
            Interview_Format__c  = 'Single',
            Notes_to_Candidate__c = 'Test Notes'
        );
        insert interview;
        
     
        Interviewer__c interviewer = new Interviewer__c(
            Interview__c = interview.Id,
            Interviewer_Name__c = cnt.Id,
            Company__c = acc.id,
            Interviewer_Role__c = 'HR',
            Job__c = job.Id
        );
        insert interviewer;
        
    }
    
    
    public static testMethod void sendEmailData(){
        Interview__c interview = [SELECT Id FROM Interview__c LIMIT 1];
        String email = EmailSendController.getMailData(interview.id);
        System.assertEquals(email, 'test@email.com');
        EmailSendController.sendMailMethod(interview.Id, email, 'test subject', 'test Body');
        
    }
}