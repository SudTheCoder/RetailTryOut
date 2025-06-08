/******************************************************************************
Name: ASDAC_CloseBulkCasesController_Test
===============================================================================
Req: 
ASDAC-1360 Bulk Close Cases.
===============================================================================
Purpose:Test Class to test the functionality for -  
		ASDAC_CloseBulkCasesController controller class.
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		03 June 2022    Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_CloseBulkCasesController_Test {
    public FINAL STATIC String TL_BULK_MSG = 'OCS Team Leader UK has Bulk Case Close Permission.';
	/**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup static void setup() {
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + '.teamLeaderUK';
        ocsTeamLdrTstUsr.FederationIdentifier = ocsTeamLdrTstUsr.FederationIdentifier + '.teamLeaderUK';
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEADUK_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsTeamLdrTstUsr) {
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            ASDAC_TestDataUtility.createCases(200, true, 'GeneralEnquiry', personAccount.Id);
        }
    }
    /**************************************************************************
     Purpose    : test method to test the bulk close case functionality
				  from Permitted Profile.                                          
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
    @isTest
    public static void testWithPermittedProfiles() {
        User ocsTeamLdrTstUsr = getuserRecord('testUser_0@testing_0.com.teamLeaderUK');
        System.runAs(ocsTeamLdrTstUsr) {
			PageReference pageRef = Page.ASDAC_CloseBulkCases;
            Test.setCurrentPage(pageRef);
            List<Case> listOfCases = getListOfCases();
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listOfCases);
            stdSetController.setSelected(listOfCases); 
            
            ASDAC_CloseBulkCasesController controller = new ASDAC_CloseBulkCasesController(stdSetController); 
            ASDAC_CloseBulkCasesController.ResponseWrapper resWrap = controller.resWrap;
            System.assertEquals(true, resWrap.isSuccess, TL_BULK_MSG);
            List<String> listOfClosedCaseNumbers = new List<String>();
            List<Case> listOfCasesToClosed = new List<Case>();
            for(Case cse : listOfCases) {
                Case clonedCase = new Case();
                clonedCase.Id = cse.Id;
				clonedCase.Status = 'Closed';
				clonedCase.Comments = 'Closing cases';
				clonedCase.CaseClosedReason__c = 'Resolved';
                listOfClosedCaseNumbers.add(cse.CaseNumber);
                listOfCasesToClosed.add(clonedCase);
            }            
            update listOfCasesToClosed;

			new ASDAC_CloseBulkCasesController(stdSetController);
            string casenumbers ='00010251';
            System.assertEquals(true, ASDAC_CloseBulkCasesController.closeCases(listOfCasesToClosed, listOfClosedCaseNumbers, casenumbers).isSuccess, TL_BULK_MSG);
        }
    }

    /**************************************************************************
     Purpose    : test method to test Log__c record creation when any 
				  exception occurs.                                          
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
    @isTest
    public static void testExceptionLogCreation() {
        User ocsTeamLdrTstUsr = getuserRecord('testUser_0@testing_0.com.teamLeaderUK');
        System.runAs(ocsTeamLdrTstUsr) {
			PageReference pageRef = Page.ASDAC_CloseBulkCases;
            Test.setCurrentPage(pageRef);
            List<Case> listOfCases = getListOfCases();
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listOfCases);
            stdSetController.setSelected(listOfCases); 
            ASDAC_CloseBulkCasesController controller1 = new ASDAC_CloseBulkCasesController(stdSetController); 
            ASDAC_CloseBulkCasesController.ResponseWrapper resWrap1 = controller1.resWrap;
            System.assertEquals(true, resWrap1.isSuccess, TL_BULK_MSG);
            List<String> listOfClosedCaseNumbers = new List<String>();
            List<Case> listOfCasesToClosed = new List<Case>();
            for(Case cse : listOfCases) {
                Case clonedCase = new Case();
                clonedCase.Id = cse.Id;
				clonedCase.Status = 'Closed';
				clonedCase.Comments = 'Closing cases';
				clonedCase.CaseClosedReason__c = '';//throw exception reason is required for closing the case
                listOfClosedCaseNumbers.add(cse.CaseNumber);
                listOfCasesToClosed.add(clonedCase);
            }
        	insert new LogManagement__c(SetupOwnerId = UserInfo.getProfileId(), EnableLogging__c = true);
            string casenumbers ='00010251';
            System.assertEquals(false, ASDAC_CloseBulkCasesController.closeCases(listOfCasesToClosed, listOfClosedCaseNumbers, casenumbers).isSuccess, 'is Success False because Exception occurs');
            //System.assertEquals(false, [SELECT Id FROM Log__c].isEmpty(), 'Log Record Inserted.');
        }
    }    
	@isTest
    public static void testExceptionLogCreation1() {
        User ocsTeamLdrTstUsr = getuserRecord('testUser_0@testing_0.com.teamLeaderUK');
        System.runAs(ocsTeamLdrTstUsr) {
			PageReference pageRef = Page.ASDAC_CloseBulkCases;
            Test.setCurrentPage(pageRef);
            List<Case> listOfCases = getListOfCases();
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listOfCases);
            stdSetController.setSelected(listOfCases); 
            ASDAC_CloseBulkCasesController controller1 = new ASDAC_CloseBulkCasesController(stdSetController); 
            ASDAC_CloseBulkCasesController.ResponseWrapper resWrap1 = controller1.resWrap;
            System.assertEquals(true, resWrap1.isSuccess, TL_BULK_MSG);
            List<String> listOfClosedCaseNumbers = new List<String>();
            List<Case> listOfCasesToClosed = new List<Case>();
            for(Case cse : listOfCases) {
                Case clonedCase = new Case();
                clonedCase.Id = cse.Id;
				clonedCase.Status = 'Closed';
				clonedCase.Comments = 'Closing cases';
				clonedCase.CaseClosedReason__c = '';//throw exception reason is required for closing the case
                clonedCase.AsdaRewardId__c = '';
                listOfClosedCaseNumbers.add(cse.CaseNumber);
                listOfCasesToClosed.add(clonedCase);
            }
        	insert new LogManagement__c(SetupOwnerId = UserInfo.getProfileId(), EnableLogging__c = true);
            string casenumbers ='00010251';
            System.assertEquals(false, ASDAC_CloseBulkCasesController.closeCases(listOfCasesToClosed, listOfClosedCaseNumbers, casenumbers).isSuccess, 'is Success False because Exception occurs');
        }
    }    

	/**************************************************************************
     Purpose    : test method to test the bulk close case functionality 
				  from Non Permitted Profile                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/   
    @isTest
    public static void testWithNonPermittedProfiles() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPO) {
			PageReference pageRef = Page.ASDAC_CloseBulkCases;
            Test.setCurrentPage(pageRef);
            List<Case> listOfCases = getListOfCases();
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listOfCases);
            stdSetController.setSelected(listOfCases); 
            ASDAC_CloseBulkCasesController controller2 = new ASDAC_CloseBulkCasesController(stdSetController); 
            ASDAC_CloseBulkCasesController.ResponseWrapper resWrap2 = controller2.resWrap;
            System.assertEquals(false, resWrap2.isSuccess, 'OCS Colleague BPO will not have Bulk Case Close Permission.');
        }
    }    

	/**************************************************************************
     Purpose    : method to retrieve the List of Cases                                      
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    private static List<Case> getListOfCases() {
        return [SELECT Id, CaseNumber, Status FROM Case LIMIT 10];
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