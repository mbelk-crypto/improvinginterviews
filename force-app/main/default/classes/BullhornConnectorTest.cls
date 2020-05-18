@isTest
public class BullhornConnectorTest {
    static testMethod void callTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        BullhornEntity candidEntity= new CandidateEntity();
        BullhornEntity jobEntity = new JobOrderEntity();
        BullhornConnector.getAuthorizationCode(' ', ' ', ' ', ' ');
        BullhornConnector.getAccessTokenRefreshToken(' ', ' ', ' ');
        List<Object> objList = BullhornConnector.getChangesFromBullHorn('https://rest91.bullhornstaffing.com/rest-services/5514nd/', candidEntity,
                '2c5e5d9a-1a9f-49de-a391-f4491dae87f0', '0', '{ "where" : "dateLastModified > 1554393310000 AND dateLastModified < 1554444669760"}');

        List<Object> candidateList = BullhornConnector.getCandidateChangesFromBullHorn('https://rest91.bullhornstaffing.com/rest-services/5514nd/', jobEntity,
                '2c5e5d9a-1a9f-49de-a391-f4491dae87f0', '0', '{ "query" : "dateLastModified: 1554393310000 "}');


        Test.stopTest();
        System.assertEquals(objList.size(), 1);
        System.assertEquals(candidateList.size(), 1);

    }
}