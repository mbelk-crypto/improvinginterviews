/**
 * Created by Iron Man, CloudRoute on 3/28/2019.
 */

public interface BullhornEntity {

    String buildJSONBody(sObject sObj, String defaultBullhornOwner);     // B-S Build JSON body to upload the Data to BH
    String getQuery();   //B-S get query for the batch scope
    String getEntityName(); //The name of the entity as on Bullhorn
    UpsertWrapper upsertData(List<Object> dataToUpsert, Map<String, List<Decimal>> idsListMap); // Insert or update the data on BF as per condition
    List<Object> deserialiseToWrapper(Map<String, Object> responseMap);   //Create list of wrapper to be Upserted
    

}