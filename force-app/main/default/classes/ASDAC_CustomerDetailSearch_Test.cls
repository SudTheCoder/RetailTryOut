/******************************************************************************
Name: ASDAC_CustomerDetailSearch_Test
===============================================================================
Req: 
ASDAC-4949 Search cases tab
===============================================================================
Search Customer From Customer Details
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		21 Oct 2022     Initial Development
******************************************************************************/
@isTest
public class ASDAC_CustomerDetailSearch_Test {
    static final String STRING_FNAME = 'Test FName';
    static final String STRING_LNAME = 'Test LName';
    static final String STRING_USER_EMAIL = 'testUser_0@testing_0.com.ocsColleagueBPO';
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
            List<Account> listOfAccounts = new List<Account>();
            for(Integer i = 0; i < 200; i++) {
 				Account prsnAcc = ASDAC_TestDataUtility.createPersonAccount(false);
                prsnAcc.FirstName__pc = prsnAcc.FirstName + i;
                prsnAcc.LastName__pc = prsnAcc.LastName + i;
                prsnAcc.PostalCode__pc = 'N10' + i;
                prsnAcc.FirstName = STRING_FNAME + i;
                prsnAcc.LastName  = STRING_LNAME + i;
                prsnAcc.Phone = '12345678' + i ;
                prsnAcc.Loginid__c = 'test' + Integer.valueof((Math.random() * 100)) + '@asdatest.co.uk' + Integer.valueof((Math.random() * 100)) + i;
                prsnAcc.PersonEmail = prsnAcc.Loginid__c;
                listOfAccounts.add(prsnAcc);               
            }
            insert listOfAccounts;
        }
    }
    
	/**************************************************************************
	 Purpose    : test Customer List From Phone
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/
    @isTest
    static void testCustomersListFrmPhone() {
		User ocsCollBPO = getUserRecord(STRING_USER_EMAIL);
        System.runAs(ocsCollBPO) {
            Account acc = [SELECT Id FROM Account WHERE Phone = '123456780'];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = acc.Id;
            Test.setFixedSearchResults(fixedSearchResults);
			ASDAC_CustomerDetailSearch.SearchWrapper searchWrap = new ASDAC_CustomerDetailSearch.SearchWrapper();
            searchWrap.phone = '123456780';
            ASDAC_CustomerDetailSearch.ResponseWrapper respWrap = ASDAC_CustomerDetailSearch.getCustomersList(JSON.serialize(searchWrap));
            System.assertEquals(true, respWrap.isSuccess, 'Customer Found from Phone.');
        }
    }

    @isTest
    static void testCustomersListFrmPhoneException() {
		User ocsCollBPO = getUserRecord(STRING_USER_EMAIL);
        System.runAs(ocsCollBPO) {
            ASDAC_CustomerDetailSearch.ResponseWrapper respWrap = ASDAC_CustomerDetailSearch.getCustomersList('Invalid Input');
            System.assertEquals(false, respWrap.isSuccess, 'Exception occur.');
        }
    }
    
	/**************************************************************************
	 Purpose    : test Customer List From Email
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/
	@isTest
    static void testCustomersListFrmEmail() {
		User ocsCollBPO = getUserRecord(STRING_USER_EMAIL);
        System.runAs(ocsCollBPO) {
            Account acc = [SELECT Id, PersonEmail FROM Account WHERE Phone != '123456780' LIMIT 1];
			ASDAC_CustomerDetailSearch.SearchWrapper searchWrap = new ASDAC_CustomerDetailSearch.SearchWrapper();
            searchWrap.email = acc.PersonEmail;
            ASDAC_CustomerDetailSearch.ResponseWrapper respWrap = ASDAC_CustomerDetailSearch.getCustomersList(JSON.serialize(searchWrap));
            System.assertEquals(true, respWrap.isSuccess, 'Customer Found from Email.');
        }
    }
    
	/**************************************************************************
	 Purpose    : test Postal Code Search
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/
    @isTest
    static void testCustomersListPostalCodeSearch() {
		User ocsCollBPO = getUserRecord(STRING_USER_EMAIL);
        System.runAs(ocsCollBPO) {
			ASDAC_CustomerDetailSearch.SearchWrapper searchWrap = new ASDAC_CustomerDetailSearch.SearchWrapper();
            searchWrap.firstName = STRING_FNAME;
            searchWrap.lastName = STRING_LNAME;
            searchWrap.postalCode = 'N100';
            searchWrap.address='Test Shipping street';
            ASDAC_CustomerDetailSearch.ResponseWrapper respWrap = ASDAC_CustomerDetailSearch.getCustomersList(JSON.serialize(searchWrap));
            System.assertEquals(true, respWrap.isSuccess, 'Customer Found from First Name/Last Name and Postal Code.');
        }
    }
    
	/**************************************************************************
	 Purpose    : Postal Code Error if firstName/lastName or address is filled
				  and postal code is blank
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/    
	@isTest
    static void testCustomersListPostalCodeError() {
		User ocsCollBPO = getUserRecord(STRING_USER_EMAIL);
        System.runAs(ocsCollBPO) {
			ASDAC_CustomerDetailSearch.SearchWrapper searchWrap = new ASDAC_CustomerDetailSearch.SearchWrapper();
            searchWrap.firstName = STRING_FNAME;
            searchWrap.lastName = STRING_LNAME;
            ASDAC_CustomerDetailSearch.ResponseWrapper respWrap = ASDAC_CustomerDetailSearch.getCustomersList(JSON.serialize(searchWrap));
            System.assertEquals(true, respWrap.hasPostalCodeError, 'Postal Code error.');
        }
    }
    
	/**************************************************************************
	 Purpose    : Get User Record                                           
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/
	private static User getUserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
}