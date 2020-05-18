// BullhornToSFQueueable

public with sharing class BullhornToSFQueueable implements Queueable, Database.AllowsCallouts {
    private string entityType;
    private String BhRestToken;
    private String restUrl;
    private String newRefreshToken;
    private Integer start;
    private DateTime contactLastSyncedDateTime;
    private Integer orderInteger;
    private Id contactId;
    private Contact contactSyncSetting;
    private BullhornEntity bullhornEntityType;
    private Map<String, List<Decimal>> idsListMap;
    public BullhornToSFQueueable(Integer orderInteger, Integer start, Id contactId, Map<String, List<Decimal>> idsListMap) {
        this.contactId = contactId;
        List<Bullhorn_Sync_Order__mdt> bullhorn_sync_order_List = [SELECT Id, MasterLabel, DeveloperName FROM Bullhorn_Sync_Order__mdt WHERE Order__c = :orderInteger];
        System.debug(' This Job is Running for ===> ' + bullhorn_sync_order_List);

        if (idsListMap != null) {
            this.idsListMap = idsListMap;
        } else {
            this.idsListMap = new Map<String, List<Decimal>>{
                    'Account' => new List<Decimal>(),
                    'Contact' => new List<Decimal>()
            };
        }
        if (bullhorn_sync_order_List.size() > 0)
            this.entityType = bullhorn_sync_order_List[0].MasterLabel;
        this.start = start;
        this.orderInteger = orderInteger;
    }

    public void execute(QueueableContext context) {
        contactSyncSetting = [
                SELECT Id, Last_Synced_Date__c,Client_Id__c, Client_Secret__c, Current_Job__c,
                        Client_Refresh_Token__c, Client_Password__c, Client_Username__c
                FROM Contact
                WHERE Id = :contactId
        ];
        this.contactLastSyncedDateTime = contactSyncSetting.Last_Synced_Date__c;

        System.debug(contactSyncSetting + '  ===> contactSyncSetting');
        //get authorization code
        String refreshToken = contactSyncSetting.Client_Refresh_Token__c;
        String clientId = contactSyncSetting.Client_Id__c;
        String clientSecret = contactSyncSetting.Client_Secret__c;
        String username = contactSyncSetting.Client_Username__c;
        String password = contactSyncSetting.Client_Password__c;
        System.debug(entityType + '  ===> entityType');
        system.debug('#--refreshToken-#' + refreshToken);
        if (entityType != null && clientSecret != null && clientId != null) {
            Map<String, object> responseMap;
            if (refreshToken != null) {
                responseMap = BullhornConnector.getAccessTokenRefreshToken(refreshToken, clientId, clientSecret);
            } else if (username != null && password != null) {
                responseMap = BullhornConnector.getAuthorizationCode(clientId, clientSecret, username, password);
            }

            //If Refresh Token on Contact is Expired Or Invalid
            if ((responseMap == null || !responseMap.containsKey('BhRestToken')) && username != null && password != null) {
                responseMap = BullhornConnector.getAuthorizationCode(clientId, clientSecret, username, password);
            }

            

            if (responseMap != null && !responseMap.isEmpty()) {
                BhRestToken = String.valueOf(responseMap.get('BhRestToken'));
                restUrl = String.valueOf(responseMap.get('restUrl'));
                newRefreshToken = String.valueOf(responseMap.get('refresh_token'));
            }

            try {
                if (responseMap != null && responseMap.containsKey('BhRestToken')) bullhornIntegration();
            } catch (Exception e) {
                System.debug('Error In INtegration  ===> ');
                String errorMsg = 'Message: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber() + '\n' + e.getStackTraceString();
                Error_Log__c error_log = new Error_Log__c(
                        Error_Code__c = e.getTypeName(),
                        Description__c = errorMsg,
                        Integration_Flow__c = 'Bullhorn to Salesforce',
                        Record_ID__c = '',
                        Record_BH_ID__c = '',
                        Object_Name__c = entityType
                );
                insert error_log;
                contactSyncSetting.Last_Synced_Date__c = contactLastSyncedDateTime;
            }


            if (responseMap != null && responseMap.containsKey('refresh_token')) {
                contactSyncSetting.Client_Refresh_Token__c = newRefreshToken;
                System.debug(contactSyncSetting.Current_Job__c + '  ===> contactSyncSetting.Current_Job__c');
                System.debug('  ===> Updating Contact Refreshtoken ' + contactSyncSetting);
                update contactSyncSetting;
            }
        }
    }


    private void bullhornIntegration() {



        this.bullhornEntityType = Util.getInstance(entityType);
        
        ID jobID;

//check if any new data is inserted or updated
        List<object> changes = getChanges();


        //update/insert data
        UpsertWrapper upsertWrapper = new UpsertWrapper();
        if (changes.size() > 0) {
            upsertWrapper = bullhornEntityType.upsertData(changes, idsListMap);
        } else if (changes.size() == 0) {
            upsertWrapper.success = true;
        }
        idsListMap = upsertWrapper.idsListMap;
        System.debug(upsertWrapper + '  ===> upsertWrapper');


        //flag to check if there are more records
        if (changes.size() == Integer.valueOf(Label.QueryCount)) {
            start += Integer.valueOf(Label.QueryCount);
            System.debug('  ===> There Might Be more Records .... ');

            System.debug('  ===> Queueing the Job for ' + bullhornEntityType.getEntityName() + ' with Start ' + start);
            contactSyncSetting.Client_Refresh_Token__c = newRefreshToken;

            //The Same Job is Queued for the new Data
            if (!Test.isRunningTest()) {
                if (upsertWrapper.success) {
                    jobId = System.enqueueJob(new BullhornToSFQueueable(orderInteger, start, contactSyncSetting.Id, idsListMap));
                    System.debug(jobID + '  ===> jobID');
                    contactSyncSetting.Current_Job__c = jobID;
                    update new Contact(Id = contactSyncSetting.id, Client_Refresh_Token__c = newRefreshToken, Current_Job__c = jobID);
                } else {
                    update new Contact(Id = contactSyncSetting.id, Client_Refresh_Token__c = newRefreshToken);
                }

            }

        } else {
            orderInteger += 1;
            System.debug(orderInteger + '  ===> orderInteger');
            if (![SELECT Id FROM Bullhorn_Sync_Order__mdt WHERE Order__c = :orderInteger].isEmpty()) {
                System.debug('  ===> Queuing Next Entity Job');
                contactSyncSetting.Client_Refresh_Token__c = newRefreshToken;
                //New job is Queued For next Entity
                if (!Test.isRunningTest()) {
                    if (upsertWrapper.success) {
                        jobID = System.enqueueJob(new BullhornToSFQueueable(orderInteger, 0, contactSyncSetting.Id, idsListMap)); // Queue The Next Job in order
                        System.debug(jobID + '  ===> jobID');
                        contactSyncSetting.Current_Job__c = jobID;
                        update new Contact(Id = contactSyncSetting.id, Client_Refresh_Token__c = newRefreshToken, Current_Job__c = jobID);
                    } else {
                        update new Contact(Id = contactSyncSetting.id, Client_Refresh_Token__c = newRefreshToken);
                    }

                }

            } else if (upsertWrapper.success) {//if no more Entities are left in order
                System.debug('  ===> Contact Last Synced Change');

                contactSyncSetting.Last_Synced_Date__c = DateTime.now(); // set the new Last Synced Time For next Sync
            }
        }
    }


    
    
    //Return Changes according to the Entity
    private List<Object> getChanges() {

        if (entityType == 'Candidate') {
            return BullhornConnector.getCandidateChangesFromBullHorn(restUrl, bullhornEntityType, BhRestToken, String.valueOf(start), getCandidateWhereJSON());
        } else if (entityType == 'Job' || entityType == 'Job__c' || entityType == 'JobOrder') {
            return BullhornConnector.getChangesFromBullHorn(restUrl, new JobOrderEntity(), BhRestToken, String.valueOf(start), getWhereJobJSON(null));
        }
        else if (entityType == 'Appointment') {
            //return BullhornConnector.getChangesFromBullHorn(restUrl, new AppointmentEntity(), BhRestToken, String.valueOf(start), getWhereAppointmentJSON());
        } else if (entityType == 'Account' || entityType == 'ClientCorporation') {
            List<Object> accountList = BullhornConnector.getChangesFromBullHorn(restUrl, bullhornEntityType, BhRestToken, String.valueOf(start), getWhereJSON());
            List<Object> newAccountList = new List<Object>();
            //get All the jobs of recieved contact and process only the accounts with the active jobs
            if (accountList.size() > 0) {
                List<ClientCorporationWrapper> clientCorporationList = (List<ClientCorporationWrapper>) accountList;
                List<Decimal> idList = new List<Decimal>();
                for (clientCorporationWrapper acc : clientCorporationList) {
                    idList.add(acc.Id);
                }
                List<Object> jobsList = BullhornConnector.getJobsFromBullHorn(restUrl, new JobOrderEntity(), BhRestToken, String.valueOf(start), getWhereJobJSON(idList));
                if (jobsList.size() > 0) {
                    List<JobOrderWrapper> jobOrderList = (List<JobOrderWrapper>) jobsList;
                    List<Decimal> newidList = new List<Decimal>();
                    for (JobOrderWrapper job : jobOrderList) {
                        if (job.clientCorporation != null)
                            newidList.add(job.clientCorporation.Id);
                    }
                    for (ClientCorporationWrapper corp : clientCorporationList) {
                        if (newidList.contains(corp.Id)) {
                            newAccountList.add((Object) corp);
                        }
                    }
                }
            }
            //deserialise the new list to wrapper
            return bullhornEntityType.deserialiseToWrapper(new Map<String, Object>{
                    'data' => newAccountList
            });
        } else if (entityType == 'Contact' || entityType == 'ClientContact') {
            List<Object> contactList = BullhornConnector.getChangesFromBullHorn(restUrl, bullhornEntityType, BhRestToken, String.valueOf(start), getWhereJSON());
            List<Object> newContactList = new List<Object>();
//get All the jobs of recieved contact and process only the contacts of accounts with the active jobs
            if (contactList.size() > 0) {
                List<ClientContactWrapper> clientContactList = (List<ClientContactWrapper>) contactList;
                List<Decimal> idList = new List<Decimal>();
                for (ClientContactWrapper cnt : clientContactList) {
                    idList.add(cnt.clientCorporation.Id);
                }
                List<Object> jobsList = BullhornConnector.getJobsFromBullHorn(restUrl, new JobOrderEntity(), BhRestToken, String.valueOf(start), getWhereJobJSON(idList));
                if (jobsList.size() > 0) {
                    List<JobOrderWrapper> jobOrderList = (List<JobOrderWrapper>) jobsList;
                    List<Integer> newidList = new List<Integer>();
                    for (JobOrderWrapper job : jobOrderList) {
                        if (job.clientCorporation != null)
                            newidList.add(job.clientCorporation.Id);
                    }
                    for (ClientContactWrapper contactWrapper : clientContactList) {
                        if (newidList.contains(contactWrapper.clientCorporation.Id)) {
                            newContactList.add((Object) contactWrapper);
                        }
                    }
                }
            }
            //deserialise the new list to wrapper
            return bullhornEntityType.deserialiseToWrapper(new Map<String, Object>{
                    'data' => newContactList
            });
        }
        return null;
    }

    //get Where clause for the Bullhorn Query as Json
    private String getWhereJSON() {
        String whereJson = '';
        String whereClause = ' ( dateLastModified > ' +
                contactSyncSetting.Last_Synced_Date__c.getTime() + ' AND dateLastModified < ' +
                DateTime.now().getTime() + ') ';
        String statusClause = '';
        //if Account or Contact then get Active only
        switch on entityType {
            when 'Account', 'ClientCorporation' {
                if (idsListMap.containsKey('Account') && idsListMap.get('Account').size() > 0)
                    whereClause += ' OR id IN ' + idsListMap.get('Account') + '';
            } when 'Contact', 'ClientContact' {

                whereClause = ' ( status = \'Active\'  AND  ( ' + whereClause + (idsListMap.containsKey('Contact') && idsListMap.get('Contact').size() > 0 ? ' OR id IN ' + idsListMap.get('Contact') : '') + ' ) ) ';
            } when else {

            }
        }
        whereJson = '{ "where" : "' + whereClause + '"} ';

        System.debug(whereJson + '  ===> whereJson');
        return whereJson;
    }

//get Where clause for the JOB Bullhorn Query as Json
    private String getWhereJobJSON(List<Decimal> idsList) {
        String whereJson = '';
        String whereClause = '"dateLastModified > ' +
                contactSyncSetting.Last_Synced_Date__c.getTime() + ' AND dateLastModified < ' +
                DateTime.now().getTime();
        if (idsList != null) {
            whereJson = '{ "where" : "' + ' isOpen = true AND clientCorporation.id IN ' + idsList + '"} ' ;
        } else {
            whereJson = '{ "where" : ' + whereClause + ' AND isOpen = true  "} ';
        }
        System.debug(whereJson + '  ===> whereJson');
        return whereJson;
    }

    
    private String getWhereAppointmentJSON() {
       String whereJson = '';
       String whereClause = '"dateLastModified > ' +
                contactSyncSetting.Last_Synced_Date__c.getTime() + ' AND dateLastModified < ' +
                DateTime.now().getTime();
        /*String whereClause = '"dateLastModified < ' +
                DateTime.now().getTime();
        */
        whereJson = '{ "where" : ' + whereClause + ' AND type = \'Interview\' AND isDeleted = false  "} ';
        System.debug(whereJson + '  ===> whereJson');
        return whereJson;
    }


//get Where clause for the Candidate Bullhorn Query as Json
    private String getCandidateWhereJSON() {
        String whereJson = '';

        Datetime nowDatetime = System.now();
        String whereClause = '"dateLastModified: [ ' +
                contactSyncSetting.Last_Synced_Date__c.formatGMT('YYYYMMddHHmmss') + ' TO ' +
                nowDatetime.formatGMT('YYYYMMddHHmmss') + ' ]  AND status: Active "';

        whereJson = '{ "query" : ' + whereClause + ' }' ;

        System.debug(whereJson + '  ===> whereJson');
        return whereJson;
    }
}