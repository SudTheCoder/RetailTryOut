/******************************************************************************
Name: ASDAC_DownloadRestrictController
===============================================================================
Req: ASDAC-22008 Disable download of files submitted through webforms
===============================================================================
Purpose:class to restrict download of webform attached files
===============================================================================
******************************************************************************/

public with sharing class ASDAC_DownloadRestrictController implements Sfc.ContentDownloadHandlerFactory {
    
    /**************************************************************************
    Purpose    : This method determines whether the current user is allowed to download file.
    Parameters : ids (List<Id>): A list of content document or version IDs
    Returns    : Returns an Sfc.ContentDownloadHandler object                                               
    **************************************************************************/
    public Sfc.ContentDownloadHandler getContentDownloadHandler(List<ID> ids, Sfc.ContentDownloadContext context) {
        Sfc.ContentDownloadHandler contentDownloadHandler = new Sfc.ContentDownloadHandler();
        contentDownloadHandler.isDownloadAllowed = true;
        
        if (!User.SObjectType.getDescribe().isAccessible()) {
            throw new AuraException(System.Label.ASDAC_InsufficientPermissionError);
        }
        User currentUser= [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
           
        if(currentUser.Profile.Name != 'System Administrator'){
            ContentVersion contentDoc = [Select Id, Description from ContentVersion WHERE Id IN :ids LIMIT 1];
            if (contentDoc != null && contentDoc.Description == System.Label.ASDAC_AttachedFromWebformText) {
                contentDownloadHandler.isDownloadAllowed = false;
                PageReference downloadRestrictPage = Page.DownloadRestrictPage;
                contentDownloadHandler.redirectUrl = downloadRestrictPage.getUrl();
            } 
        }
        return contentDownloadHandler;
   }

}