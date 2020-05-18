public class ClientContactEntity implements BullhornEntity {

    public String getEntityName() {
        return 'ClientContact';
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

        List<ClientContactWrapper> wrapperList = new List<ClientContactWrapper>();
        for (Object obj : dataList) {
            String jsonString = JSON.serialize(obj);
            System.debug(obj + '  ===> obj');
            ClientContactWrapper wrapper = (ClientContactWrapper) JSON.deserialize(jsonString, ClientContactWrapper.class);
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
        List<ClientContactWrapper> dataToUpsert = (List<ClientContactWrapper>) dataToUpsertList;

//        Set<Decimal> interviewerIds = new Set<Decimal>();

        Set<Decimal> accountIds = new Set<Decimal>();
        Set<Decimal> contactIds = new Set<Decimal>();//for upsert and Reports to
        for (ClientContactWrapper obj : dataToUpsert) {
            if (obj.Id != null) {
                contactIds.add(obj.Id);
            }
            if (obj.reportToPerson != null) {
                contactIds.add(obj.reportToPerson.Id);
            }
            if (obj.clientCorporation != null && obj.clientCorporation.id != null) {
                accountIds.add(obj.clientCorporation.id);
            }

        }

        //Map to get All the Job Orders Already in Salesforce For Update
        /* Map<Decimal, Id> bullhornVSJobIdMap = new Map<Decimal, Id>();
         for(Job__c job: [
                 SELECT Id, ATS_ID__c
                 FROM Job__c
        WHERE ATS_ID__c IN :jobIds
        ]){
        bullhornVSJobIdMap.put(job.ATS_ID__c, job.Id);
         }*/

        Map<Decimal, Id> bullhornVSContactIdMap = new Map<Decimal, Id>();

        for (Contact cont : [
                SELECT Id, ATS_ID__c
                FROM Contact
                WHERE ATS_ID__c IN :contactIds AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSContactIdMap.put(cont.ATS_ID__c, cont.Id);
        }


        Map<Decimal, Id> bullhornVSAccountIdMap = new Map<Decimal, Id>();

        for (Account acc : [
                SELECT Id, ATS_ID__c
                FROM Account
                WHERE ATS_ID__c IN :accountIds AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSAccountIdMap.put(acc.ATS_ID__c, acc.Id);
        }


        List<Contact> upsertList = new List<Contact>();
        for (ClientContactWrapper obj : dataToUpsert) {
 
            Contact cnt = new Contact(
                    FirstName = obj.firstName,
                    LastName = obj.lastName,
                    ATS_ID__c = obj.id,
                    ATS_System__c = 'Bullhorn',
                    Email = obj.email,
                    ReportsToId = obj.reportToPerson == null ? null : bullhornVSContactIdMap.get(obj.reportToPerson.Id),
                    Phone = obj.phone,
                    AccountId = obj.clientCorporation == null ? null : bullhornVSAccountIdMap.get(obj.clientCorporation.Id)
            );


            if (bullhornVSContactIdMap.containsKey(obj.id)) {
                cnt.Id = bullhornVSContactIdMap.get(obj.Id);
            }
            upsertList.add(cnt);
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
                            Object_Name__c = 'Contact'
                    );
                    errorList.add(error_log);
                }
                i++;
            }
        }
        if(errorList.size() > 0) insert errorList;

        System.debug(upsertList + '  ===> upsertList');

        return upsertWrapper;
    }
}