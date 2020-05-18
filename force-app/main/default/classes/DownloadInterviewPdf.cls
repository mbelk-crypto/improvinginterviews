public class DownloadInterviewPdf {
    
    @AuraEnabled
    public static string downloadData(String strRecordId){
        system.debug('strRecordId :::> '+strRecordId);
        
        PageReference vfPage = Page.InterviewPacketPdf;
        vfPage.getParameters().put('id',strRecordId);
        system.debug('vfPage :::> '+vfPage);
        string response;
        blob AttachementData;
        try{
            if(!Test.isRunningTest()) AttachementData = vfPage.getContentAsPDF();
            else AttachementData = Blob.valueOf('Test');
            system.debug('AttachementData :::> '+AttachementData);
            response = EncodingUtil.base64Encode(AttachementData);
        }catch(exception e){
            system.debug('Exception :::> '+e.getMessage());     
        }
        return response;
        
    }
}