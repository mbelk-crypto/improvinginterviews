@isTest
public class CandidateEntityTest {

    @isTest
    public static void otherMethods(){
        BullhornEntity candidateEntity = new CandidateEntity();

        candidateEntity.getEntityName();
        candidateEntity.getQuery();
        candidateEntity.buildJSONBody(new Candidate__c(), '');

    }


    @isTest
    public static void candidateUpsertTest(){
        BullhornEntity candidateEntity = new CandidateEntity();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped('{ "total": 2, "start": 0, "count": 2, "data": [ { "id": 11, "firstName": "Cloud Happy Test", "lastName": "Candidate", "phone": "9595959595", "email": "cloudhappytest@cloud.com", "dateLastModified": 1554201210450, "_score": 1 }, { "id": 12, "firstName": "Cloud happy test 1", "lastName": "Candidate 1 ", "phone": null, "email": "cloudhappytest1@cloud.com", "dateLastModified": 1554202234910, "_score": 1 } ] }');
        List<Object> candList = candidateEntity.deserialiseToWrapper(responseMap);
        UpsertWrapper success = candidateEntity.upsertData(candList, null);
        
        //System.assertEquals(success, true);
        List<Candidate__c> newCandidates = [SELECT Id FROM Candidate__c];
        System.assertEquals(newCandidates.size(), 2);
        
    }

}