@isTest
public class BullhornToSFQueueableTest {
    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'test name ', Client_Refresh_Token__c = 'asb', Client_Id__c = 'asd', Client_Secret__c = 'asd', Last_Synced_Date__c = System.now());

        insert acc;

        Contact cnt = new Contact(LastName = 'test Name ',
                Account = acc,
                Client_Secret__c = 'asd',
                Client_Id__c = '23123',
                Client_Username__c = ' test ',
                Client_Password__c = ' test ',
                Last_Synced_Date__c = System.now()
        );
        insert cnt;
    }


    static testMethod void accountQueuableTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Contact cnt = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        System.enqueueJob(new BullhornToSFQueueable(1, 0, cnt.Id, null));
        Test.stopTest();
    }
    static testMethod void contactQueuableTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Contact cnt = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        System.enqueueJob(new BullhornToSFQueueable(2, 0, cnt.Id, null));
        Test.stopTest();
    }
    static testMethod void jobQueuableTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Contact cnt = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        System.enqueueJob(new BullhornToSFQueueable(3, 0, cnt.Id, null));
        Test.stopTest();
    }
    static testMethod void candidateQueuableTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Contact cnt = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        System.enqueueJob(new BullhornToSFQueueable(4, 0, cnt.Id, null));
        Test.stopTest();
    }
}