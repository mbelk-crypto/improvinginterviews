/*
* This class is used to generate interview packet pdf
*/
public class InterviewPacket {
    public Interview__c interview {get; set;}
    public Map<Id, Interviewer__c> interviewerMap {get; set;}
    public integer count {get; set;}
    public String imageUrl {get; set;}
    // public Map<Id, List<Interview_Questions__c>> interviewerInterviewQuestionsMap = new Map<Id, List<Interview_Questions__c>>() {get; set;}
    /*public InterviewPacket(ApexPages.StandardController sc){       
interview =  (Interview__c) sc.getRecord();
//interview = [SELECT Id, Interview_Date__c, Interview_Start_Time__c, Interview_End_Time__c, (SELECT ID FROM Interviewer__r) FROM Interview__c WHERE Id = :interview.Id];
count = 0;
getRelatedData();
}*/
    public InterviewPacket(){
        string recordId =(string)ApexPages.currentPage().getParameters().get('id');
        interview = [SELECT Id, Candidate_Name__r.First_Name__c, Candidate_Name__r.Last_Name__c,Location__c,Company__r.Name, Company__r.Company_Logo__c,
                     Interview_Date__c, Interview_Start_Time__c, Interview_End_Time__c, Job_Record__r.Name,Logistics__c,Job_Record__r.Description__c,
                     Company__r.Description,Company__r.Industry_Information__c,Notes_to_Candidate__c,Interview_Format__c,Job_Record__r.Recruiter__r.Account.Company_Logo__c,
                     (SELECT ID,Interviewer_Name__r.FirstName,Interviewer_Name__r.LastName,Interviewer_Name__r.Title,Interviewer_Role__c,
                      Interviewer_Name__r.Email,Interviewer_Name__r.Phone,Reports_To__c,About_Description__c, Hobbies_Personal_Interest__c,Interview_Questions__c,
                      Interview_Tips__c
                      FROM Interviewer__r) FROM Interview__c WHERE Id = :recordId];
        
        //need to use this field instead: Job_Record__r.Recruiter__r.Account.Company_Logo__c
       /*
        if(interview.Company__r.Company_Logo__c != null)
            imageUrl = getImageUrl(interview.Company__r.Company_Logo__c);
*/
        if(interview.Job_Record__r.Recruiter__r.Account.Company_Logo__c != null)
            imageUrl = getImageUrl(interview.Job_Record__r.Recruiter__r.Account.Company_Logo__c);
        system.debug('imageUrl: ' + imageUrl);
        count = 0;
        getRelatedData();
    }
    
    
    public String getImageUrl(String richText){
        
        String url = richtext.substringBetween('src="', '"');
        system.debug('logo url:' + url);
        return url;
    }
    
    public String getStartTime() {
        System.debug('interview StartTime : ' + interview.Interview_Start_Time__c  + '  Minute: '+ interview.Interview_Start_Time__c.minute());
        if(interview.Interview_Start_Time__c != null){
            Integer minute = interview.Interview_Start_Time__c.minute();
            Integer hour24 = interview.Interview_Start_Time__c.hour();
            Integer hour12 = (hour24 > 12) ? hour24 - 12 : hour24;
            return ((hour12 == 0 ) ? '00' : String.valueOf(hour12) )  + ':' + ((minute == 0) ? '00': String.valueOf(minute))  + ' ' + ((hour24 >= 12) ? 'PM' : 'AM') ; 
        }
        else 
            return '';
    }
    
    public String getEndTime() {
        if(interview.Interview_End_Time__c != null){
            Integer minute = interview.Interview_End_Time__c.minute();
            Integer hour24 = interview.Interview_End_Time__c.hour();
            Integer hour12 = (hour24 > 12) ? hour24 - 12 : hour24;
            return ((hour12 == 0 ) ? '00' : String.valueOf(hour12) )  + ':' + ((minute == 0) ? '00': String.valueOf(minute))  + ' ' + ((hour24 >= 12) ? 'PM' : 'AM') ;
        }       
        else 
            return '';
    }
    
    private void getRelatedData(){
        Set<Id> interviewerIdSet = new Set<Id>();
        for(Interviewer__c int_e : interview.Interviewer__r){
            interviewerIdSet.add(int_e.id);
        }
        interviewerMap = new Map<Id, Interviewer__c>([SELECT id, (SELECT Id, Question_Description__c, Question_Reason__c,Question_Record__r.Question_Reason__c FROM Interview_Questions__r) FROM Interviewer__c WHERE Id IN :interviewerIdSet]);
        System.debug('interviewer Map' + interviewerMap);
    }
    
}