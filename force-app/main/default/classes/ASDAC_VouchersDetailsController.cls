public with sharing class ASDAC_VouchersDetailsController {
    @AuraEnabled
    public static Id createContentNote(String title, String content, Id recordId) {
        ContentNote contentNote = new ContentNote();
        contentNote.Title = title;
        contentNote.Content = Blob.valueOf(content);
        insert contentNote;
        
        ContentDocumentLink contentDoclnk = new ContentDocumentLink();
        contentDoclnk.LinkedEntityId = recordId;
        contentDoclnk.ContentDocumentId = contentNote.Id;
        contentDoclnk.ShareType = 'I';
        insert contentDoclnk;
        return contentDoclnk.Id;
    }
}