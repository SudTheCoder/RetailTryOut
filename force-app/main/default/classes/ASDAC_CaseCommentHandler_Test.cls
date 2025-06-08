/******************************************************************************
Name: ASDAC_CaseCommentHandler_Test
===============================================================================
Req: 
ASDAC-19380 Throw an error when Agents are trying to delete Case Comments 
===============================================================================
Purpose:Test class to test functionality for ASDAC_CaseCommentHandler_Test
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Sri Abhinaya    		27 March 2024     Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_CaseCommentHandler_Test {
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
            Case cse = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', personAccount.Id)[0];
            cse.Status = 'Assigned';
            insert cse;
            Case caseRecord = [SELECT Id FROM Case LIMIT 1];
            CaseComment newComment = new CaseComment();
            newComment.ParentId = caseRecord.Id;
            newComment.CommentBody = 'SampleTest';
            insert newComment;
        }
    }
    
    /**************************************************************************
     Purpose    : When Non Sys Admins are trying to delete CaseComment throw an error                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/  
    @isTest
    public static void preventDeletionOnCaseCommentPositive() {
        User asdaBaseUsr = getUserRecord(Test_USERNAME);
        System.runAs(asdaBaseUsr) {
            CaseComment newComment = [Select id from CaseComment Limit 1];
            try {
                delete newComment;
            }
            catch(Exception ex) {
                System.assertEquals(true, ex.getTypeName() == 'System.DmlException', 'You do not have permission to delete Case Comments.');          
            }
        }
    }
    
    /**************************************************************************
     Purpose    : When Non Sys Admins are trying to edit CaseComment throw an error                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/  
    @isTest
    public static void preventEditOnCaseCommentPositive() {
        User asdaBaseUsr = getUserRecord(Test_USERNAME);
        System.runAs(asdaBaseUsr) {
            CaseComment newComment = [Select id from CaseComment Limit 1];
            try {
                newComment.CommentBody = 'Update SampleTest';
                update newComment;
            }
            catch(Exception ex) {
                System.assertEquals(true, ex.getTypeName() == 'System.DmlException', 'You do not have permission to edit Case Comments.');          
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

}