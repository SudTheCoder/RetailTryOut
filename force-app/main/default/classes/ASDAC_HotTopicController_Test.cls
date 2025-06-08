/**********************************************************************************
 * @author                       : Amey Priolkar
 * @date                         : 2022-09-19
 * @description                  : ASDAC-3485  Hot Topics
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Amey Priolkar                 19-Sep-2022     Created the Test class
 ***************************************************************************************************/
@isTest
public with sharing class ASDAC_HotTopicController_Test {
    /**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup static void createData() {
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + '.teamLeaderUK';
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEAD_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsTeamLdrTstUsr) {
            HotTopic__c hTopic = new HotTopic__c(Name='Test Hot Topic', StartDate__c = Date.Today().addDays(-2), ExpiryDate__c = Date.Today().addDays(2));
            insert hTopic;
			HotTopic__c hTopic2 = new HotTopic__c(Name='Test Hot Topic2', StartDate__c = Date.Today().addDays(-2), ExpiryDate__c = Date.Today().addDays(2));
            insert hTopic2;
            
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true; // Adding Case Assignment Rules
            List<Case> listOfCases = ASDAC_TestDataUtility.createCases(200, false, 'GeneralEnquiry', personAccount.Id);
            for(Case cse : listOfCases) {
                cse.HotTopic__c = hTopic.Id;
            }
            listOfCases[0].HotTopic__c = hTopic2.Id;
            insert listOfCases;
        }
    }

    /**************************************************************************
     Purpose    : fetching Hot topics
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void fetchHotTopicsTest() {
        User ocsTeamLdrTstUsr = getuserRecord('testUser_0@testing_0.com.teamLeaderUK');
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                ASDAC_HotTopicController.ResponseWrapper respWrap = ASDAC_HotTopicController.getActiveHotTopics();
                System.assertEquals(respWrap.isSuccess, TRUE, 'Hot Topics Found.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : No Hot topics test
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void noHotTopicsTest() {
        User ocsTeamLdrTstUsr = getuserRecord('testUser_0@testing_0.com.teamLeaderUK');
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                Delete [SELECT Id FROM HotTopic__c];
                ASDAC_HotTopicController.ResponseWrapper respWrap = ASDAC_HotTopicController.getActiveHotTopics();
                System.assertEquals(respWrap.isSuccess, FALSE, 'No Hot Topics Found.');
            Test.StopTest();
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