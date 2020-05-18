/**
* Author Name : Sandeep
* Last modified date : 11 Mar, 2019
* Ticket/Story# : 
* Description : Test class for GroupAssignment functionality which will be Triggered from User trigger
*/
@isTest
public class UserTriggerHandlerTest {
  	
    /**
    * Author Name : Sandeep
    * Last modified date : 11 Mar, 2019
    * Ticket/Story# : 
    * Description : Test Mehtod of user insert
    */
    public static testMethod void testFIBIUser() { 
    
        final Group dashboardGroup = [select id from Group where Name = 'Recruiter And Recruiter Admin Users'];
        final Profile communityProfile = [Select Id from profile where name = 'Recruiter'];
        final Profile adminProfile = [Select Id from profile where name = 'System Administrator'];
        final Id roleId = [Select Id from UserRole where name = 'Admin'].Id;
        
        // Building User Sobject
        final User adminU = new User(
                                Username = 'AdminUser@improvinginterviews.com',
                                LastName = 'user',
                                FirstName = 'Admin',
                                Email = 'AdminUser@improvinginterviews.com',
                                alias = 'testA12',
                                TimeZoneSidKey = 'America/New_York',
                                LocaleSidKey = 'en_US',
                                EmailEncodingKey = 'ISO-8859-1',
                                EmployeeNumber = '3456',    
                                LanguageLocaleKey = 'en_US',
                                CompanyName = 'improvinginterviews',
                                ProfileId = adminProfile.Id,
                                userroleId = roleId
                            ); 
        
        insert adminU;
        
        Test.startTest();        
        
        system.runAs(adminU) { 
        
            final Account acc =  new Account(Name = 'Test Account 11321233');
            insert acc;
            
            final Contact con = new Contact(
                                        AccountId = acc.Id,
                                        FirstName = 'Community',
                                        LastName = 'user132',
                                        Email = 'CommunityUser@improvinginterviews.com'
                                    );
            insert con;
            
            final User customerU = new User(
                                    Username = 'CommunityUser@improvinginterviews.com',
                                    LastName = 'user132',
                                    FirstName = 'Community',
                                    Email = 'CommunityUser132@improvinginterviews.com',
                                    alias = 'testCS90',
                                    TimeZoneSidKey = 'America/New_York',
                                    LocaleSidKey = 'en_US',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    EmployeeNumber = '3456',    
                                    LanguageLocaleKey = 'en_US',
                                    CompanyName = 'improvinginterviews',
                                    ProfileId = communityProfile.Id,
                                    contactId = con.Id 
                                );
                            
            insert customerU;
        
            final List<GroupMember> grpMem = new List<GroupMember>([select GroupId, UserOrGroupId 
                                                                From GroupMember 
                                                                Where GroupId = :dashboardGroup.id AND 
                                                                UserOrGroupId = :customerU.id]);
		
            system.assert(!grpMem.isEmpty(), 'User is not being added ');
            
        }    
        
        Test.stopTest();
    }
    
}