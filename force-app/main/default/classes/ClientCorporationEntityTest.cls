@isTest
public class ClientCorporationEntityTest {

    @isTest
    public static void otherMethods() {
        BullhornEntity entity = new ClientCorporationEntity();

        entity.getEntityName();
        entity.getQuery();
        entity.buildJSONBody(new Account(), '');

    }


    @isTest
    public static void clientCorpUpsertTest() {
        BullhornEntity entity = new ClientCorporationEntity();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped('{ "start": 0, "count": 2, "data": [ { "id": 2, "address": { "address1": "1234, Park Avenue", "address2": "Pali Area", "city": "Mumbai", "state": "Washington", "zip": "777777", "countryID": 1, "countryName": "United States", "countryCode": "US" }, "annualRevenue": 0, "billingAddress": null, "billingContact": null, "billingFrequency": null, "billingPhone": null, "branch": null, "businessSectorList": null, "certificationGroups": { "total": 0, "data": [] }, "certifications": { "total": 0, "data": [] }, "childClientCorporations": { "total": 0, "data": [] }, "clientContactNotes": { "total": 0, "data": [] }, "clientContacts": { "total": 1, "data": [] }, "companyDescription": null, "companyURL": "www.google.com", "competitors": null, "culture": null, "customDate1": null, ' +
                '"customDate2": null, "customDate3": null, "customFloat1": null, "customFloat2": null, "customFloat3": null, "customInt1": null, "customInt2": null, "customInt3": null, "customText1": null, "customText10": null, "customText11": null, "customText12": null, "customText13": null, "customText14": null, "customText15": null, "customText16": null, "customText17": null, "customText18": null, "customText19": null, "customText2": null, "customText20": null, "customText3": null, "customText4": null, "customText5": null, "customText6": null, "customText7": null, "customText8": null, "customText9": null, "customTextBlock1": null, "customTextBlock2": null, "customTextBlock3": null, "customTextBlock4": null, "customTextBlock5": null, "dateAdded": 1554120037887, "dateFounded": null, "dateLastModified": 1554197073653, "department": { "id": 1000000, "name": "Sandbox - Improving Interviews" }, "externalID": null, "facebookProfileName": null, "fax": null, "feeArrangement": 0, "fileAttachments": { "total": 0, "data": [] }, "funding": null, "industryList": null, "invoiceFormat": null, "leads": { "total": 0, "data": [] }, "linkedinProfileName": null, "locations": { "total": 0, "data": [] }, "name": "Cloud Happy Test Company 1", "notes": null, "numEmployees": 0, "numOffices": 1, "owners": { "total": 1, "data": [] },' +
                ' "ownership": "Private", "parentClientCorporation": null, "phone": "9696969696", "requirements": { "total": 0, "data": [] }, "revenue": null, "status": "Active Account", "taxRate": 0, "tickerSymbol": null, "trackTitle": null, "twitterHandle": null, "workWeekStart": null }, { "id": 1, "address": { "address1": null, "address2": null, "city": null, "state": null, "zip": null, "countryID": 1, "countryName": "United States", "countryCode": "US" }, "annualRevenue": 0, "billingAddress": null, "billingContact": null, "billingFrequency": null, "billingPhone": null, "branch": null, "businessSectorList": null, "certificationGroups": { "total": 0, "data": [] }, "certifications": { "total": 0, "data": [] }, "childClientCorporations": { "total": 0, "data": [] }, "clientContactNotes": { "total": 0, "data": [] }, "clientContacts": { "total": 1, "data": [] }, "companyDescription": null, "companyURL": null, "competitors": null, "culture": null, "customDate1": null, "customDate2": null, "customDate3": null, "customFloat1": null, "customFloat2": null, "customFloat3": null, "customInt1": null, "customInt2": null, "customInt3": null, "customText1": null, "customText10": null, "customText11": null, "customText12": null, "customText13": null, "customText14": null, "customText15": null, "customText16": null, "customText17": null, ' +
                '"customText18": null, "customText19": null, "customText2": null, "customText20": null, "customText3": null, "customText4": null, "customText5": null, "customText6": null, "customText7": null, "customText8": null, "customText9": null, "customTextBlock1": null, "customTextBlock2": null, "customTextBlock3": null, "customTextBlock4": null, "customTextBlock5": null, "dateAdded": 1548869327487, "dateFounded": null, "dateLastModified": 1548869327487, "department": { "id": 1000000, "name": "Sandbox - Improving Interviews" }, "externalID": null, "facebookProfileName": null, "fax": null, "feeArrangement": 0, "fileAttachments": { "total": 0, "data": [] }, "funding": null, "industryList": null, "invoiceFormat": null, "leads": { "total": 0, "data": [] }, "linkedinProfileName": null, "locations": { "total": 0, "data": [] }, "name": "Improving Interviews", "notes": null, "numEmployees": 0, "numOffices": 1, "owners": { "total": 1, "data": [] }, "ownership": null, "parentClientCorporation": null, "phone": null, "requirements": { "total": 0, "data": [] }, "revenue": null, "status": "Active Account", "taxRate": 0, "tickerSymbol": null, "trackTitle": null, "twitterHandle": null, "workWeekStart": null } ] }');
        List<Object> entityList = entity.deserialiseToWrapper(responseMap);
        UpsertWrapper success = entity.upsertData(entityList, null);
        //System.assertEquals(success, true);
        List<Account> newData = [SELECT Id FROM Account];
        System.assertEquals(newData.size(), 2);
    }

}