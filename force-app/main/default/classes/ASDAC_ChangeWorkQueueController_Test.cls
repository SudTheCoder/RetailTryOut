/******************************************************************************
Name: ASDAC_ChangeWorkQueueController_Test
===============================================================================
Req: 
ASDAC-1435 test Class for ASDAC_ChangeWorkQueueControllers
===============================================================================
Purpose:test Class for ASDAC_ChangeWorkQueueControllers 
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Amey Priolkar   		08/05/2022    Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_ChangeWorkQueueController_Test {
    public FINAL STATIC String BPO_USERNAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
    public FINAL STATIC String  USER_RECORD = 'testUser_0@testing_0.com';
    public FINAL STATIC String CASE_COMMENT = 'Sample Case Comment';
	@TestSetup
	static void createData(){
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
        insert ocsASDABaseUser;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsASDABaseUser},ASDAC_GlobalConstants.STRING_TEAMLEAD_UK_PSG_NAME);
        system.runAs(ocsASDABaseUser) {
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            Case cse = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', personAccount.Id)[0];
            cse.Status = 'Assigned';
            insert cse;
        }
	}

	@isTest
	static void getListOfQueuesTest() {
        User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Test.startTest();
                ASDAC_ChangeWorkQueueController.ResponseWrapper resWrap = ASDAC_ChangeWorkQueueController.getListOfQueues();
                System.assert(resWrap.listOfQueues.size() > 0, true);
            Test.stopTest();
        }
	}

	@isTest
	static void updateCaseDiffOwnerTest() {
        User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Case cse = [SELECT Id, ownerId, owner.Name FROM Case LIMIT 1];
            cse.OwnerId = asdaBaseUsr.Id;
            update cse;
            Test.startTest();
                Case caseRecordBefore = [SELECT Id, ownerId, owner.Name FROM Case LIMIT 1];
                QueueSobject otherQueue = [SELECT QueueId, Queue.Name, SobjectType FROM QueueSobject WHERE SobjectType = 'Case' AND QueueId != :caseRecordBefore.ownerId LIMIT 1];
                ASDAC_ChangeWorkQueueController.updateCaseOwner(caseRecordBefore.Id, CASE_COMMENT, otherQueue.QueueId);
                Case caseRecordAfter = [SELECT Id, ownerId FROM Case WHERE Id = : caseRecordBefore.Id LIMIT 1];
                System.assertEquals(otherQueue.QueueId, caseRecordAfter.OwnerId, 'Case is assigned to Selected queue.');
            Test.stopTest();
        }
	}
   
	@isTest
	static void updateCaseSameOwnerTest() {
        User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Test.startTest();
                Case caseRecordBefore = [SELECT Id, ownerId FROM Case LIMIT 1];
                ASDAC_ChangeWorkQueueController.ResponseWrapper resWrap = ASDAC_ChangeWorkQueueController.updateCaseOwner(caseRecordBefore.Id, CASE_COMMENT, caseRecordBefore.OwnerId);
                System.assertEquals(false, resWrap.isSuccess, 'isSuccess As Case is assgined to same owner.');
            Test.stopTest();
        }
	}
    
	@isTest
	static void exceptionCatchTest() {
        User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Test.startTest();
                Case caseRecord = [SELECT Id FROM Case LIMIT 1];
                ASDAC_ChangeWorkQueueController.ResponseWrapper resWrap = ASDAC_ChangeWorkQueueController.updateCaseOwner(caseRecord.Id, CASE_COMMENT, null);
                System.assertEquals(false, resWrap.isSuccess, 'Exception occured');
            Test.stopTest();
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