/******************************************************************************
Name: ASDAC_CaseCustomerSearch_Test
===============================================================================
Req: 
ASDAC-4949 Search cases tab
===============================================================================
Test class to search the functionality for Customer Search based upon Case 
Number
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		21 Oct 2022     Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_CaseCustomerSearch_Test {
    
	/**************************************************************************
	 Purpose    : Test Setup data                                           
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/ 
	@TestSetup
	static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPO) {
            Account prsnAcc = ASDAC_TestDataUtility.createPersonAccount(false);
            prsnAcc.FirstName__pc = prsnAcc.FirstName;
            prsnAcc.LastName__pc = prsnAcc.LastName;
            insert prsnAcc;
			List<Case> listOfCases = ASDAC_TestDataUtility.createCases(200, false, 'GeneralEnquiry', prsnAcc.Id);
			insert listOfCases;
        }
    }
    
	/**************************************************************************
	 Purpose    : Get User Record                                           
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/
	private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
    
    @isTest
    static void testgetCaseWithCustomerDetailsPositive() {
		User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        system.runAs(ocsCollBPO) {
            Test.startTest();
                Case cse = [SELECT Id, CaseNumber FROM Case LIMIT 1];
                ASDAC_CaseCustomerSearch.ResponseWrapper resp = ASDAC_CaseCustomerSearch.getCaseWithCustomerDetails(cse.CaseNumber);
            Test.stopTest();
            System.assertEquals(true, resp.isSuccess, 'No Exception');
            System.assertEquals(false, resp.listOfCases.isEmpty(), 'Customer Found. So list not empty.');
        }
    }
    
	@isTest
    static void testgetCaseWithCustomerDetailsNegative() {
        User ocsBASE = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsBASE.userName = ocsBASE.userName + '.ocsBASE';
        ocsBASE.FederationIdentifier = ocsBASE.FederationIdentifier + '.ocsBASE';
        insert ocsBASE;
		system.runAs(ocsBASE) {
            Test.startTest();
           		//Random Case Number
                ASDAC_CaseCustomerSearch.ResponseWrapper resp = ASDAC_CaseCustomerSearch.getCaseWithCustomerDetails('9876789');
            Test.stopTest();
            System.assertEquals(false, resp.isSuccess, 'Exception Occured');
            System.debug(resp);
            if(resp.listOfCases==null)
            System.assert(true,'Customer Not Found. So list is empty.');
        }
    }
}