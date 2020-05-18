public with sharing class ClientCorporationEntity implements BullhornEntity {

    public String getEntityName() {
        return 'ClientCorporation';
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

        List<ClientCorporationWrapper> wrapperList = new List<ClientCorporationWrapper>();
        for (Object obj : dataList) {
            String jsonString = JSON.serialize(obj);
            System.debug(obj + '  ===> obj');
            ClientCorporationWrapper wrapper = (ClientCorporationWrapper) JSON.deserialize(jsonString, ClientCorporationWrapper.class);
            wrapperList.add(wrapper);
        }

        return (List<Object>) wrapperList;
    }


    public UpsertWrapper upsertData(List<Object> dataToUpsertList, Map<String, List<Decimal>> idsListMap) {
        System.debug('upsertData');
        UpsertWrapper upsertWrapper = new UpsertWrapper();
        upsertWrapper.success = true;
        upsertWrapper.idsListMap = idsListMap;
        List<ClientCorporationWrapper> dataToUpsert = (List<ClientCorporationWrapper>) dataToUpsertList;

        //All the Account Ids That needs to be updated
        Set<Decimal> accountIds = new Set<Decimal>();
        Set<Decimal> parentAccountIds = new Set<Decimal>();
        for (ClientCorporationWrapper obj : dataToUpsert) {
            if (obj.Id != null) {
                accountIds.add(obj.Id);
            }
            if (obj.clientCorporation != null && obj.clientCorporation.id != null) {
                parentAccountIds.add(obj.clientCorporation.id);
            }
        }

        Map<Decimal, Id> bullhornVSAccountIdMap = new Map<Decimal, Id>();

        for (Account acc : [
                SELECT Id, ATS_ID__c
                FROM Account
                WHERE ATS_ID__c IN :accountIds AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSAccountIdMap.put(acc.ATS_ID__c, acc.Id);
        }


        Map<Decimal, Id> bullhornVSParentAccountIdMap = new Map<Decimal, Id>();

        for (Account acc : [
                SELECT Id, ATS_ID__c
                FROM Account
                WHERE ATS_ID__c IN :parentAccountIds AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSParentAccountIdMap.put(acc.ATS_ID__c, acc.Id);
        }


        List<Account> upsertList = new List<Account>();
        for (ClientCorporationWrapper obj : dataToUpsert) {
            Account acc = new Account(
                    Name = obj.Name == '' ? null : obj.Name,
                    ATS_ID__c = obj.Id,
                    ATS_System__c = 'Bullhorn',
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId(),
                    ParentId = obj.clientCorporation == null ? null : bullhornVSAccountIdMap.get(obj.clientCorporation.Id),
                    BillingStreet = obj.address.address1 == '' ? null : obj.address.address1,
                    BillingCity = obj.address.city == '' ? null : obj.address.city,
                    BillingCountry = 'United States',
                    BillingState = obj.address.state == '' ? null : obj.address.state,
                    BillingPostalCode = obj.address.zip == '' ? null : obj.address.zip,
                    Website = obj.companyURL == '' ? null : obj.companyURL,
                    Description = obj.companyDescription == '' ? null : obj.companyDescription,
                    Phone = obj.phone == '' ? null : obj.phone,
                    Last_Synced_Date__c = System.now(),
                    OwnerId = UserInfo.getUserId()

            );

            if (bullhornVSAccountIdMap.containsKey(obj.id)) {
                acc.Id = bullhornVSAccountIdMap.get(obj.Id);
            }
            upsertList.add(acc);
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
                            Object_Name__c = 'Account'
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