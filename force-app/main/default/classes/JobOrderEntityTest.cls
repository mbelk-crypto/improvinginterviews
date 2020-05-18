@isTest
public class JobOrderEntityTest {
    @isTest
    public static void otherMethods() {
        BullhornEntity entity = new JobOrderEntity();

        entity.getEntityName();
        entity.getQuery();
        entity.buildJSONBody(new Job__c(), '');

    }


    @isTest
    public static void jobOrderUpsertTest() {
        BullhornEntity entity = new JobOrderEntity();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped('{ "start": 0, "count": 2, "data": [{ "id": 7134, "address": { "address1": null, "city": "Atlanta", "state": "GA", "zip": "", "countryID": 1 }, "appointments": { "total": 0, "data": [] }, "approvedPlacements": { "total": 0, "data": [] }, "assignedUsers": { "total": 0, "data": [] }, "benefits": null, "billRateCategoryID": null, "bonusPackage": null, "branch": null, "branchCode": null, "businessSectors": { "total": 0, "data": [] }, "categories": { "total": 0, "data": [] }, "certificationGroups": { "total": 0, "data": [] }, "certificationList": null, "certifications": { "total": 0, "data": [] }, "clientBillRate": 0, "clientContact": { "id": 271509, "firstName": "VICTORIA J. (Vicky)", "lastName": "BAKER" }, "clientCorporation": { "id": 448, "name": "Southern Company (Atlanta)" }, "correlatedCustomDate1": null, "correlatedCustomDate2": null, "correlatedCustomDate3": null, "correlatedCustomFloat1": null, "correlatedCustomFloat2": null, "correlatedCustomFloat3": null, "correlatedCustomInt1": null, "correlatedCustomInt2": null, "correlatedCustomInt3": null, "correlatedCustomText1": null, "correlatedCustomText10": null, "correlatedCustomText2": null, "correlatedCustomText3": null, "correlatedCustomText4": null, "correlatedCustomText5": null, "correlatedCustomText6": null, "correlatedCustomText7": null, "correlatedCustomText8": null, "correlatedCustomText9": null, "correlatedCustomTextBlock1": null, "correlatedCustomTextBlock2": null, "correlatedCustomTextBlock3": null, "costCenter": null, "customDate1": null, "customDate2": null, "customDate3": null, "customFloat1": null, "customFloat2": null, "customFloat3": null, "customInt1": null, "customInt2": null, "customInt3": null, "customText1": "", "customText10": null, "customText11": null, "customText12": null, "customText13": null, "customText14": null, "customText15": null, "customText16": null, "customText17": null, "customText18": null, "customText19": null, "customText2": "", "customText20": null, "customText3": "3162", "customText4": "", "customText5": null, "customText6": null, "customText7": null, "customText8": null, "customText9": null, "customTextBlock1": null, "customTextBlock2": null, "customTextBlock3": null, "customTextBlock4": null, "customTextBlock5": null, "dateAdded": 954306000000, "dateClosed": null, "dateEnd": -2208973332000, "dateLastExported": null, "dateLastModified": 954306000000, "dateLastPublished": null, "degreeList": null, "description": "Position Responsibilities: Prototype new web sites and applications and support maintenance of existing sites. A strong understantding of client-side, browser-neutral HTML/DHTML/JavaScript is required. Position also requires excellent client skills and ability to convert business information into well-formed web content and provide guidance to graphic designers for web illustrations. An understanding of server-side ASP (VBScript/JavaScript) is a plus. Additional Requirements: 1+years of Internet development experience Ability to hit the ground running.", "durationWeeks": 2, "educationDegree": null, "employmentType": "Direct Hire", "externalCategoryID": null, "externalID": "3713768399113", "feeArrangement": 0, "fileAttachments": { "total": 0, "data": [] }, "hoursOfOperation": null, "hoursPerWeek": 40, "interviews": { "total": 0, "data": [] }, "isClientEditable": false, "isDeleted": false, "isInterviewRequired": true, "isJobcastPublished": null, "isOpen": false, "isPublic": 0, "jobBoardList": null, "markUpPercentage": 0, "notes": { "total": 0, "data": [] }, "numOpenings": 0, "onSite": "On-Site", "opportunity": null, "optionsPackage": null, "owner": { "id": 1, "firstName": "Unassigned", "lastName": "user" }, "payRate": 0, "placements": { "total": 0, "data": [] }, "publicDescription": null, "publishedCategory": null, "publishedZip": null, "reasonClosed": null, "reportTo": null, "reportToClientContact": null, "responseUser": null, "salary": 0, "salaryUnit": "Yearly", "sendouts": { "total": 0, "data": [] }, "shift": null, "shifts": { "total": 0, "data": [] }, "skillList": "", "skills": { "total": 0, "data": [] }, "source": null, "specialties": { "total": 0, "data": [] }, "startDate": -2208973332000, "status": "Placed", "submissions": { "total": 0, "data": [] }, "tasks": { "total": 0, "data": [] }, "taxRate": 0, "taxStatus": "W2", "tearsheets": { "total": 0, "data": [] }, "timeUnits": { "total": 0, "data": [] }, "title": "Web Prototype Specialist", "travelRequirements": null, "type": 0, "usersAssigned": null, "webResponses": { "total": 0, "data": [] }, "willRelocate": false, "willRelocateInt": 0, "willSponsor": false, "workersCompRate": null, "yearsRequired": 0 } ] }');
        List<Object> entityList = entity.deserialiseToWrapper(responseMap);
        Map<String, List<Decimal>> idsListMap = new Map<String, List<Decimal>>{
                                                        'Account' => new List<Decimal>(),
                                                        'Contact' => new List<Decimal>()
                                                };

        UpsertWrapper success= entity.upsertData(entityList, idsListMap);
        //System.assertEquals(success, true);
        List<Job__c> newData = [SELECT Id FROM Job__c];
        System.assertEquals(newData.size(), 1);
    }

}