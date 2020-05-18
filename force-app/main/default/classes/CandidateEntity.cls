public class CandidateEntity implements BullhornEntity {
    public String getEntityName() {
        return 'Candidate';
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

        List<CandidateWrapper> wrapperList = new List<CandidateWrapper>();
        for (Object obj : dataList) {
            String jsonString = JSON.serialize(obj);
            System.debug(obj + '  ===> obj');
            CandidateWrapper wrapper = (CandidateWrapper) JSON.deserialize(jsonString, CandidateWrapper.class);
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

        List<CandidateWrapper> dataToUpsert = (List<CandidateWrapper>) dataToUpsertList;

        //All the candidate Ids That needs to be updated
        Set<Decimal> candidateIds = new Set<Decimal>();
        for (CandidateWrapper obj : dataToUpsert) {
            if (obj.id != null)
                candidateIds.add(obj.id);
        }


        //Map to get All the Candidate Already in Salesforce For Update
        Map<Decimal, Id> bullhornVSCandidateIdMap = new Map<Decimal, Id>();

        for (Candidate__c cand : [
                SELECT Id, ATS_ID__c
                FROM Candidate__c
                WHERE ATS_ID__c IN :candidateIds AND ATS_System__c = 'Bullhorn'
        ]) {
            bullhornVSCandidateIdMap.put(cand.ATS_ID__c, cand.Id);
        }

        List<Candidate__c> upsertList = new List<Candidate__c>();
        for (CandidateWrapper obj : dataToUpsert) {

            Candidate__c cand = new Candidate__c(
                    Name = obj.firstName + ' ' + obj.lastName,
                    First_Name__c = obj.firstName == '' ? null : obj.firstName,
                    Last_Name__c = obj.lastName == '' ? null : obj.lastName,
                    ATS_ID__c = obj.Id,
                    ATS_System__c = 'Bullhorn',
                    Phone__c = obj.phone == '' ? null : obj.phone,
                    Email__c = obj.email == '' ? null : obj.email,
                    OwnerId = UserInfo.getUserId()
            );
            if (bullhornVSCandidateIdMap.containsKey(obj.Id)) {
                cand.id = bullhornVSCandidateIdMap.get(obj.Id);
            }
            upsertList.add(cand);
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
                            Object_Name__c = 'Candidate'
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