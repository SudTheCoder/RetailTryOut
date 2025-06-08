/******************************************************************************
Name: ASDAC_ContentDocumentHandler_Test
===============================================================================
Req: 
ASDAC-19020 Throw an error when Non Admins are trying to delete ContentNote  
===============================================================================
Purpose:Test class to test functionality for ASDAC_ContentDocumentHandler
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Sri Abhinaya    		26 March 2024     Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_ContentDocumentHandler_Test {
    public static final String Test_USERNAME = 'testUser_0@testing_0.com'+ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
    /**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @TestSetup
	public static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPO) {
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
        }
    }
    
    /**************************************************************************
     Purpose    : When Non Admins are trying to delete ContentNote throw an error                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/  
    @isTest
    public static void preventDeletionOnContentNotePositive() {
        User asdaBaseUsr = getUserRecord(Test_USERNAME);
        System.runAs(asdaBaseUsr) {
            Account personAccount = getPersonAccount();
            ContentNote contentNote = new ContentNote();
        	contentNote.Title = 'test';
        	contentNote.Content = Blob.valueOf('test');
        	insert contentNote;
        
        	ContentDocumentLink contentDoclnk = new ContentDocumentLink();
        	contentDoclnk.LinkedEntityId = personAccount.Id;
        	contentDoclnk.ContentDocumentId = contentNote.Id;
        	contentDoclnk.ShareType = 'I';
        	insert contentDoclnk;
            try {
                delete contentNote;
            }
            catch(Exception ex) {
                system.debug('ex.getTypeName(): '+ex.getTypeName());
                System.assertEquals(true, ex.getTypeName() == 'System.DmlException', 'You do not have permission to delete Notes.');          
            }
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
    
    /**************************************************************************
     Purpose    : method to get Person Account                                
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
    private static Account getPersonAccount() {
        return [SELECT Id FROM Account WHERE RecordType.Name = 'Person Account' LIMIT 1];
    }

}