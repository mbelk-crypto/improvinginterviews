@isTest
public class BullhornSyncControllerTest {
    @isTest
    static void queueJobTest() {
        Id p = [select id from profile where name = 'Recruiter'].id;
        
        Id devAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recruiter').getRecordTypeId();
        
        Account acc = new Account(
            Name = 'test Recuiter',
            RecordTypeId = devAccountRecordTypeId,
            Special_Logistics__c  = 'Test Special Logistics',
            Company_Logo__c = ' test src="testlogoLink"   '
        );
        
        insert acc;

        Contact cnt = new Contact(
            LastName = 'test cnt LastName',
            AccountId = acc.Id
        );
        insert cnt;
        
        System.debug(devAccountRecordTypeId);


        User u = new User(alias = 'test123', email = 'test123@noemail.com',
                emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                localesidkey = 'en_US', profileid = p, country = 'United States', IsActive = true,
                ContactId = cnt.Id,
                timezonesidkey = 'America/Los_Angeles', username = 'tester@noemail.com');

        insert u;
        
        System.runAs(u) {

            System.debug(u + '  ===> u');
            Test.startTest();
            BullhornSyncController.queueJob();
            System.debug([SELECT Id, Current_Job__c, Client_Refresh_Token__c FROM Account] + '  ===> [SEL]');
            Test.stopTest();
            List<AsyncApexJob> batchJob = [SELECT Id, Status, ExtendedStatus  FROM AsyncApexJob LIMIT 1];
            System.debug(batchJob + '  ===> batchJob');

            if(batchJob.size() > 0){
                update new Account(id =acc.Id , Current_Job__c = batchJob[0].Id);
                BullhornSyncController.checkJobStatus();
            }
        }
    }
}