/**
* Author Name : Sandeep
* Last modified date : 11 Mar, 2019
* Ticket/Story# : 
* Description : Trigger Handler for UserTrigger
*/
public with sharing class UserTriggerHandler { 
    
    /**
    * Author Name : Sandeep
    * Last modified date : 11 Mar, 2019
    * Ticket/Story# : 
    * Description : Method on After Insert
    */
    public static void onAfterInsert(List<User> newUserList) {
        
        //Process group Assignment for community users
        final String errorMsg = GroupAssignment.processNewUsers(newUserList);
        
    }
}