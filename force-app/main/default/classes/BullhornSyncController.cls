public class BullhornSyncController {
    @AuraEnabled
    public static void queueJob() {
        User u = [SELECT Id, ContactId FROM User WHERE id = :UserInfo.getUserId()];
        Contact cnt;
        if (u.ContactId != null) {
            cnt = [
                    SELECT Id, Last_Synced_Date__c,Client_Id__c, Client_Secret__c, Current_Job__c,
                            Client_Refresh_Token__c, Client_Password__c, Client_Username__c
                    FROM Contact
                    WHERE Id = :u.ContactId
            ];
        }
        System.debug(cnt + '  ===> cnt');
        if (cnt != null) {
            ID jobID = System.enqueueJob(new BullhornToSFQueueable(1, 0, cnt.Id, null));
            System.debug(jobID + '  ===> jobID');
            update new Contact(Id = cnt.id, Client_Refresh_Token__c = cnt.Client_Refresh_Token__c, Current_Job__c = jobID);

        }
    }// Enqueue the Job , get the account of the current user and queue the job


    @AuraEnabled
    public static Boolean checkJobStatus() {

        User u = [
                SELECT Id, ContactId
                FROM User
                WHERE id = :UserInfo.getUserId()
        ];
        Contact cnt;
        if (u.ContactId != null  ) {
            cnt = [
                    SELECT Id, Last_Synced_Date__c, Current_Job__c, Client_Refresh_Token__c
                    FROM Contact
                    WHERE Id = :u.ContactId
            ];
        }

        List<AsyncApexJob> jobObjectList = [
                SELECT ApexClassId, CompletedDate, CreatedDate, ExtendedStatus, Id, JobType, ParentJobId, Status
                FROM AsyncApexJob
                WHERE id = :cnt.Current_Job__c
        ];
        System.debug(jobObjectList + '  ===> jobObject');
        if(jobObjectList.size() > 0){
            AsyncApexJob jobObject = jobObjectList[0];
            if (jobObject.Status == 'Completed' || jobObject.Status == 'Aborted') {
                System.debug('  ===> TRUE');
                return true;
            } else {
                System.debug('  ===> FALSE');
                return false;
            }
        }
        return null;

    }//query the job from custom setting and return boolean if the Job is Completed

}