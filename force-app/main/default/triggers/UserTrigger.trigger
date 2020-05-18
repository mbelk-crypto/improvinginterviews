/**
* Author Name : Sandeep
* Last modified date : 11 Mar, 2019
* Ticket/Story# : 
* Description : Trigger on User
*/
trigger UserTrigger on User (after insert) { 
    
    if(trigger.isAfter) {
        
        if(trigger.isInsert) {
            UserTriggerHandler.onAfterInsert(trigger.new);
        }
    } 
}