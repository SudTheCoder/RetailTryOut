/*************************************************************************
Name: ASDAC_ReopenCaseController_Test
==========================================================================
Req: 
ASDAC-4983 Assign a "reopened" case to the colleague who reopened it.
==========================================================================
Purpose: This Class will test the functionality of 
		 ASDAC_ReopenCaseController.     
==========================================================================
History                                                                                                                       
VERSION   AUTHOR                		DATE         	DETAIL
1.0       Shivakoti SaiAbhiteja    		17 June 2022    Initial Development
2.0       disharee Ray                  23 November 2023  Refactored the test method
**************************************************************************/
@isTest
public with sharing class ASDAC_ReopenCaseController_Test {
    private final static String BPO_SUFFIX = '.ocsColleagueBPO';
    private final static String UK_TEAMLEAD_SUFFIX = '.teamLeaderUK';
    
/******Method to insert records for the trigger testing.***********************************************/
    @testSetup
    static void createData() {
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + UK_TEAMLEAD_SUFFIX;
        insert ocsTeamLdrTstUsr;

        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},
            ASDAC_GlobalConstants.STRING_TEAMLEAD_UK_PSG_NAME);

        User ocsCollBPOUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPOUser.userName = ocsCollBPOUser.userName + BPO_SUFFIX;
        ocsCollBPOUser.FederationIdentifier = ocsCollBPOUser.FederationIdentifier + BPO_SUFFIX;
        insert ocsCollBPOUser;

        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPOUser},
            ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);

        System.runAs(ocsCollBPOUser) {
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            ASDAC_TestDataUtility.createCases(200, true, 'GeneralEnquiry', personAccount.Id);
        }
    }
    /**************************************************************************
     Purpose    : success test method when there is any exception in
				  re-assignment.
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
    @isTest
    public static void assignmentTestSuccess() {
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        System.runAs(ocsCollBPO) {
            insert new LogManagement__c(SetupOwnerId = UserInfo.getProfileId(), EnableLogging__c = true);

            Case cs = [SELECT Id FROM Case LIMIT 1];
            cs.Status = 'Closed';
            cs.Comments = 'Closing case';
            cs.CaseClosedReason__c = 'Resolved';
            update cs;

            ASDAC_ReopenCaseController.ResponseWrapper resWrap = ASDAC_ReopenCaseController.reOpenToMe(cs.Id);
			system.debug('resWrap.isSuccess' +resWrap.isSuccess);
            system.debug('getLogRecord' +getLogRecord().isEmpty());
            System.assertEquals(true, resWrap.isSuccess, 'Successfully processed.');
            System.assertEquals(true, getLogRecord().isEmpty(), 'No Log Record Inserted');
            Case csAfterReopenProcess= [Select Id, Status from Case LIMIT 1];
            System.assertEquals('Assigned', csAfterReopenProcess.Status, 'Case opened successfully.');
        }
    }
    /**************************************************************************
     Purpose    : Exception test method when there is any exception in
				  re-assignment.
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
    @isTest
    public static void assignmentTestException() {
        // Create a dummy case with correct Id prefix to trigger exception in test
        Case testCase = new Case(Status = 'Closed', CaseClosedReason__c = 'Resolved',Origin = 'Phone', Subject = 'Test Exception Case');
        insert testCase;

        Test.startTest();
        ASDAC_ReopenCaseController.ResponseWrapper resWrap = ASDAC_ReopenCaseController.reOpenToMe(testCase.Id);
        Test.stopTest();

        System.assertEquals(false, resWrap.isSuccess, 'Expected failure');
        System.assert(resWrap.message.contains('Simulated exception'), 'Expected simulated exception message');
    }
    /**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username LIMIT 1];
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