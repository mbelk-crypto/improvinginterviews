public class JobOrderEntity implements BullhornEntity {
    public String getEntityName() {
        return 'JobOrder';
    }

    public String getQuery() {
        return null;
    }

    public String buildJSONBody(sObject sobj, String defaultBullhornOwner) {
        return null;
    }

    public List<Object> deserialiseToWrapper(Map<String, Object> responseMap) {
        System.debug('getUpdatedData');

        List<Object> dataList = (List<Object>) responseMap.get('data');
        System.debug(dataList + '  ===> dataList');

        List<JobOrderWrapper> wrapperList = new List<JobOrderWrapper>();
        for (Object obj : dataList) {
            String jsonString = JSON.serialize(obj);
            System.debug('obj Job Order STR==========' + jsonString);
            System.debug('obj Job Order owner==========' + obj);
            JobOrderWrapper wrapper = (JobOrderWrapper) JSON.deserialize(jsonString, JobOrderWrapper.class);
            wrapperList.add(wrapper);
        }
        System.debug(wrapperList + '  ===> wrapperList');

        return (List<Object>) wrapperList;
    }

    public UpsertWrapper upsertData(List<Object> dataToUpsertList, Map<String, List<Decimal>> idsListMap) {
        System.debug('upsertData');
        UpsertWrapper upsertWrapper = new UpsertWrapper();
        upsertWrapper.success = true;
        upsertWrapper.idsListMap = idsListMap;
        List<JobOrderWrapper> dataToUpsert = (List<JobOrderWrapper>) dataToUpsertList;

        User loggedInUser = [Select Id, Name, contactId, AccountId from user where Id = : UserInfo.getUserId()];

        //All the Account Ids That needs to be updated
        Set<Decimal> accountIdSet = new Set<Decimal>();
        Set<Decimal> contactIdSet = new Set<Decimal>();
        Set<Decimal> jobOrderIdSet = new Set<Decimal>();
        Set<Integer> OwnerBHId = new Set<Integer>();
        for (JobOrderWrapper obj : dataToUpsert) {
            if (obj.clientContact != null && obj.clientContact.id != null)
                contactIdSet.add(obj.clientContact.Id);
            if (obj.clientCorporation != null && obj.clientCorporation.id != null)
                accountIdSet.add(obj.clientCorporation.Id);
            if (obj.owner != null && obj.owner.id != null)
                OwnerBHId.add(obj.owner.id);
            if (obj.Id != null) {
                jobOrderIdSet.add(obj.id);
            }
        }
        //Map to get All the owners in Salesforce
        Map<Integer, Contact> bullhornVSContactMap = new Map<Integer, Contact>();

        for (Contact c : [
                SELECT Id, Name, AccountId
                FROM Contact
                WHERE ATS_ID__c IN :OwnerBHId And Account.RecordType.Name = 'Recruiter'
        ]) {
            bullhornVSContactMap.put(Integer.valueOf(c.ATS_ID__c), c);
        }

        //Map to get All the Job Orders Already in Salesforce For Update
        Map<Decimal, Id> bullhornVSJobIdMap = new Map<Decimal, Id>();

        for (Job__c job : [
                SELECT Id, ATS_ID__c
                FROM Job__c
                WHERE ATS_ID__c IN :jobOrderIdSet AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSJobIdMap.put(job.ATS_ID__c, job.Id);
        }

        //Map to get all the accounts Related to Job
        Map<Decimal, Account> bullhornVSAccountIdMap = new Map<Decimal, Account>();

        for (Account acc : [
                SELECT Id, ATS_ID__c, RecordType.DeveloperName
                FROM Account
                WHERE ATS_ID__c IN :accountIdSet AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSAccountIdMap.put(acc.ATS_ID__c, acc);
        }

        //Map to get all the accounts Related to Job
        Map<Decimal, Id> bullhornVSContactIdMap = new Map<Decimal, Id>();

        for (Contact cnt : [
                SELECT Id, ATS_ID__c
                FROM Contact
                WHERE ATS_ID__c IN :contactIdSet AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSContactIdMap.put(cnt.ATS_ID__c, cnt.Id);
        }


        //TODO get all the data that is not present in salesforce
        for (Decimal accId : accountIdSet) {
            if (!bullhornVSAccountIdMap.containsKey(accId)) {
                upsertWrapper.idsListMap.get('Account').add(accId);
            }
        }
        for (Decimal cntId : contactIdSet) {
            if (!bullhornVSContactIdMap.containsKey(cntId)) {
                upsertWrapper.idsListMap.get('Contact').add(cntId);
            }
        }


        System.debug(bullhornVSContactIdMap + '  ===> bullhornVSContactIdMap');
        System.debug(bullhornVSContactMap+ '  ===> bullhornVSContactMap');
        List<Job__c> upsertList = new List<Job__c>();
        for (JobOrderWrapper obj : dataToUpsert) {
            Job__c job = new Job__c(
                    Name = obj.title == '' ? null : obj.title,
                    ATS_System__c = 'Bullhorn',
                    Status__c = obj.status == '' ? null : obj.status,
                    Description__c = obj.description,
                    OwnerId = UserInfo.getUserId(),
                    ATS_ID__c = obj.Id
            );

            //Populate Company and recruiter from the owner and only if its new Job
            if (obj.owner != null && !bullhornVSJobIdMap.containsKey(obj.id)) {

                if (bullhornVSContactMap.containsKey(obj.owner.id) && bullhornVSContactMap.get(obj.owner.id) != null) {

                    Contact c = bullhornVSContactMap.get(obj.owner.id);
                    job.Recruiter__c = c.Id;
                    job.Staffing_Company__c = c.AccountId;
                } else {
                    //if no match is found in SF, set the recruiter and staffing company based on logged in user
                    job.Recruiter__c = loggedInUser.contactId;
                    job.Staffing_Company__c = loggedInUser.AccountId;    
                }
            }

            //Populate Company field by the Company from BH
            if (obj.clientCorporation == null ?
                    false :
                    (bullhornVSAccountIdMap.containsKey(obj.clientCorporation.Id) ?
                            bullhornVSAccountIdMap.get(obj.clientCorporation.Id).RecordType.DeveloperName == 'Company' :
                            false)) {
                job.Company__c = bullhornVSAccountIdMap.get(obj.clientCorporation.Id).Id;

            }


            System.debug(job + '  ===> job');
            //if Job is already Created then Assign Id for Update
            if (bullhornVSJobIdMap.containsKey(obj.id)) {
                job.Id = bullhornVSJobIdMap.get(obj.id);
            }
            upsertList.add(job);
        }
        List<Error_Log__c> errorList = new List<Error_Log__c>();
        if (upsertList.size() > 0) {
            List<Database.UpsertResult> result = Database.upsert(upsertList, false);
            integer i = 0;
            for (Database.UpsertResult r : result) {
                System.debug(r + '  ===> r');
                if (!r.isSuccess()) {
                    upsertWrapper.success = false;
                    Error_Log__c error_log = new Error_Log__c(
                            Error_Code__c = r.isCreated() ? 'Insert Error' : 'Update Error',
                            Description__c = (r.getErrors() != null) ? String.valueOf(r.getErrors()) : '',
                            Integration_Flow__c = 'Bullhorn to Salesforce',
                            Record_ID__c = r.getID(),
                            Record_BH_ID__c = upsertList[i].ATS_ID__c + '',
                            Object_Name__c = 'Job'
                    );
                    errorList.add(error_log);
                }
                i++;
            }
        }
        if (errorList.size() > 0) insert errorList;
        System.debug(upsertList + '  ===> upsertList');

        return upsertWrapper;
    }
}