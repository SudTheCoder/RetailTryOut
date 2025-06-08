/******************************************************************************
Name: ASDAC_DownloadRestrictControllerTest
===============================================================================
Req: ASDAC-22008 Disable download of files submitted through webforms
===============================================================================
Purpose:Test class to test functionality for ASDAC_DownloadRestrictController
===============================================================================
******************************************************************************/

@IsTest
public with sharing class ASDAC_DownloadRestrictControllerTest {
    
    public static final String TEST_USERNAME = 'testUser_0@testing_0.com'+ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
    
    /**************************************************************************
    Method to insert records for testing.       
    **************************************************************************/
    @testSetup
     public static void createData() {
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
        insert ocsASDABaseUser;  
    }
    
    /**************************************************************************
     Purpose    : Restriction on download files attached from webform                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/  
    @IsTest
    static void testRestrictDownload() {   
       User asdaBaseUsr = getUserRecord(TEST_USERNAME);
        System.runAs(asdaBaseUsr) {
            ContentVersion file = new ContentVersion(
            Title = 'Test Document',
            Description = 'Attached From Webform',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content')
            );
            insert file;
            
            ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Id = :file.Id LIMIT 1];
            ASDAC_DownloadRestrictController factory = new ASDAC_DownloadRestrictController();
            List<Id> testIds = new List<Id>();
            testIds.add(cv.Id);
           
            Sfc.ContentDownloadHandler handler = factory.getContentDownloadHandler(testIds,null);

            System.assertEquals(false,handler.isDownloadAllowed, 'Download should be restricted for non-System Administrator.');
            System.assertNotEquals(null, handler.redirectUrl, 'Redirect URL should be set.');
            
        }
    }
        
    /**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }   
}