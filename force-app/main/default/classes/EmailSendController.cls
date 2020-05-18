public class EmailSendController {
  
    @AuraEnabled
    public static String getMailData(String strRecordId){
        system.debug('strRecordId :::> '+strRecordId);
        
        Interview__c objInterview = [SELECt Id, Candidate_Name__c, Candidate_Name__r.Email__c FROM Interview__c WHERE Id = :strRecordId LIMIT 1];
        
        return objInterview.Candidate_Name__r.Email__c;
    }
    
    @AuraEnabled 
    public static void sendMailMethod(String strRecordId, String mMail ,String mSubject ,String mbody){        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();    
        system.debug('mMail :::> '+mMail);
        system.debug('mSubject :::> '+mSubject);
        system.debug('mbody :::> '+mbody);
        system.debug('strRecordId :::> '+strRecordId);
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(mMail);
        mail.setToAddresses(sendTo);        
        // Step 4. Set email contents - you can use variables!
        mail.setSubject(mSubject);
        
        PageReference vfPage = Page.InterviewPacketPdf;
        vfPage.getParameters().put('id',strRecordId);
		system.debug('vfPage :::> '+vfPage);
        
        blob AttachementData;
        try{
            if(!Test.isRunningTest()) AttachementData = vfPage.getContentAsPDF();
            else AttachementData = Blob.valueOf('Test');
            system.debug('AttachementData :::> '+AttachementData);
        }catch(exception e){
            system.debug('Exception :::> '+e.getMessage());     
        }
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('InterviewPacket.Pdf');
        efa.setBody(AttachementData);
        
        mail.setHtmlBody(mbody);
        
        // Step 5. Add your email to the master list
        mails.add(mail);
        
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
    }
    
}