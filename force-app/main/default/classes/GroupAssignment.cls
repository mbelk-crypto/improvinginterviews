/**
* Author Name : Sandeep
* Last modified date : 11 Mar, 2019
* Ticket/Story# : 
* Description : Class to enable sharing for FIBI and CPS
*/
public with sharing class GroupAssignment {
    
    private static final String GRP_NAME = 'Recruiter And Recruiter Admin Users';
    private static final Set<String> COMMUNITY_PROFILES = new Set<String>{'Recruiter', 'Recruiter Admin'};
    private static final Set<Id> communityProfileIds = new Set<Id>();
    
    //To get the Ids of necessary profile Ids
    static {
        
        for(Profile pr : [Select Id from Profile where name in : COMMUNITY_PROFILES]) {
            communityProfileIds.add(pr.Id);
        }
    }
    
    /**
    * Author Name : Sandeep
    * Last modified date : 11 Mar, 2019
    * Ticket/Story# : 
    * Description : Method to processNewUsers
    */
    public static String processNewUsers(List<User> newUserList) {
    
        system.debug('==============communityProfileIds:' + communityProfileIds);
        
        //List of users who need to be processed
        final List<User> usersToBeProcessed = new List<User>();
        
        //filter user list
        for(User u : newUserList){
            if(u.isActive && communityProfileIds.contains(u.profileId)){
                usersToBeProcessed.add(u);
            }
        }
        
        system.debug('==============usersToBeProcessed:' + usersToBeProcessed);
        
        //List to add new group assignments
        List<GroupMember> groupMembers = new List<GroupMember>();
        
        //process each users
        for(User usr: usersToBeProcessed) {
            
            final GroupMember grpMember = new GroupMember(Group = new Group(Name = GRP_NAME), UserOrGroupId = usr.Id);
            //adding in list
            groupMembers.add(grpMember);
        }
        
        INSERT groupMembers;       
        
        string error;
        return error;
    }
}