/*************************************************************************
Name: ASDAC_AssignToMeController_Test
==========================================================================
Req: 
ASDAC-1696 Adding notes to a case not owned by the agent.
==========================================================================
Purpose: This Class will test the functionality of 
		 ASDAC_AssignToMeController.     
==========================================================================
History                                                                                                                       
VERSION   AUTHOR                		DATE         	DETAIL
1.0       Shivakoti SaiAbhiteja    		17 June 2022    Initial Development
**************************************************************************/
@isTest
public with sharing class ASDAC_AssignToMeController_Test {
    public FINAL STATIC String BPO_SUFFIX = '.ocsColleagueBPO';
    /**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + BPO_SUFFIX;
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + BPO_SUFFIX;
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + '.teamLeaderUK';
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEAD_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsTeamLdrTstUsr) {
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            ASDAC_TestDataUtility.createCases(200, true, 'GeneralEnquiry', personAccount.Id);
        }
    }
    
    /**************************************************************************
     Purpose    : Positive test method when case assigned successfully.                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void assignmentTestSuccess() {
        User ocsTeamLdrTstUsr = getuserRecord('testUser_0@testing_0.com.teamLeaderUK');
        Case caseRecBefore = getCaseRecord();
        System.assertEquals(ocsTeamLdrTstUsr.Id, caseRecBefore.ownerId, 'Owner Will be Team Leader before clicking Assign To Me button by Colleague Profile.');
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        System.runAs(ocsCollBPO) {
            List<Case> lstCaseRec = new List<Case>();
            lstCaseRec.add(caseRecBefore);
            
			List<List<Case>> lstCaseRecList = new List<List<Case>>();
            lstCaseRecList.add(lstCaseRec);
            ASDAC_AssignToMeController.caseAssignToMe(lstCaseRecList);
            Case caseRecAfter = [SELECT Id, OwnerId FROM Case WHERE Id = :caseRecBefore.Id];
            System.assertEquals(ocsCollBPO.Id, caseRecAfter.ownerId, 'Owner is changed after Assign To Me button is clicked by Colleague Profile.');
        }
    }
    
    /**************************************************************************
     Purpose    : negative test method when there is any exception in
				  re-assignment.
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void assignmentTestFailure() {
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
         System.runAs(ocsCollBPO) {
			insert new LogManagement__c(SetupOwnerId = UserInfo.getProfileId(), EnableLogging__c = true);
            ASDAC_AssignToMeController.ResponseWrapper resWrap = ASDAC_AssignToMeController.assignToMe(null);
            System.assertEquals(false, resWrap.isSuccess, 'Exception occurs.');
            System.assertEquals(false, getLogRecord().isEmpty(), 'Log Record Inserted');
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
     Purpose    : method to retrieve the Case Record                                    
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    private static Case getCaseRecord() {
        return [SELECT Id, OwnerId FROM Case LIMIT 1];
    }
    
    /**************************************************************************
     Purpose    : method to get Exception Record                                   
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    private static List<Log__c> getLogRecord() {
        return [SELECT Id FROM Log__c LIMIT 1];
    } 
}