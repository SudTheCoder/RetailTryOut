public with sharing class ASDAC_StandardLetterCmp {
    public CaseComment latestComment { get; set; }
    private ApexPages.StandardController controller;
    
    public ASDAC_StandardLetterCmp(ApexPages.StandardController controller){
        this.controller = controller;
        latestComment = retrieveLatestComment();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> generatePdf(String recordId,String type){ 
        List<String> pageStrings=new List<String>();        
        PageReference pdfPage = new pagereference('/apex/'+type+'?id='+recordId);
        pdfPage.getParameters().put('id', recordId);
        Blob pdfBlob= (Test.isRunningTest()) ? Blob.valueOf('test') : pdfPage.getContent();
        String downloadURL=EncodingUtil.base64Encode(pdfBlob);
        pageStrings.add(downloadURL);
        pageStrings.add(pdfPage.getUrl());
        return pageStrings;
    }    

    public CaseComment retrieveLatestComment() {
        List<CaseComment> comments = [SELECT Id, CommentBody, CreatedBy.Name, CreatedDate 
                                      FROM CaseComment 
                                      WHERE ParentId = :controller.getId() 
                                      ORDER BY CreatedDate DESC 
                                      LIMIT 1];
        if (comments != null && !comments.isEmpty()) {
            return comments[0];
        }
        return null;
    }
    
}