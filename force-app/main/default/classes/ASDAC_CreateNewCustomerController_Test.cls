/******************************************************************************
Name: ASDAC_CreateNewCustomerController_Test
===============================================================================
Req: 
ASDAC-895 No Results Returned from Search / Create New Customer Account
ASDAC-892 Customer Account Creation Duplication Checks
===============================================================================
Purpose: Test Class for ASDAC_CreateNewCustomerController functionality
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		06 July 2022    Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_CreateNewCustomerController_Test {
    public FINAL STATIC String PERSON_ACCOUNT_SAME_EMAIL = 'SameEmail@Pa.com';
    public FINAL STATIC String PERSON_ACCOUNT_EMAIL = 'newGmail@asdatest.co.uk';
    public FINAL STATIC String PERSON_ACCOUNT_POSTCODE = 'GU15 4PJ';
    public FINAL STATIC String BPO_USERNAME = 'testUser_0@testing_0.com.colleagueBPO';
    public FINAL STATIC String TESTING_FIRST_NAME = 'Testing First';
    public FINAL STATIC String TESTING_LAST_NAME = 'Testing Last';
    public FINAL STATIC String TESTING_CASE_SUBJECT = 'Testing Case Subject';
    public FINAL STATIC String CASE_SUPPLIED_EMAIL = 'guest.user@asdatest.co.uk';
    public FINAL STATIC String PERSON_ACCOUNT_PHONE = '0856564545';
	/**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testsetup
    static void setup() {
        User ocsColleagueTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsColleagueTstUsr.userName = ocsColleagueTstUsr.userName + '.colleagueBPO';
        ocsColleagueTstUsr.FederationIdentifier = ocsColleagueTstUsr.FederationIdentifier + '.colleagueBPO';
        insert ocsColleagueTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsColleagueTstUsr},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsColleagueTstUsr) {
            Account prsnAcc = ASDAC_TestDataUtility.createPersonAccount(false);
            prsnAcc.FirstName__pc = prsnAcc.FirstName;
            prsnAcc.LastName__pc = prsnAcc.LastName;
            insert prsnAcc;
            
            Account prsnAccEmail = ASDAC_TestDataUtility.createPersonAccount(false);
            prsnAccEmail.FirstName = 'Same Email';
            prsnAccEmail.LastName = 'Person Account';
            prsnAccEmail.PersonEmail = PERSON_ACCOUNT_SAME_EMAIL;
            prsnAccEmail.LoginId__c = PERSON_ACCOUNT_SAME_EMAIL;
            prsnAccEmail.FirstName__pc = prsnAccEmail.FirstName;
            prsnAccEmail.LastName__pc = prsnAccEmail.LastName;
            prsnAccEmail.Phone = '9876543210';
            insert prsnAccEmail;
            
			Account prsnAccPhone = ASDAC_TestDataUtility.createPersonAccount(false);
            prsnAccPhone.FirstName = 'Same Phone';
            prsnAccPhone.LastName = 'Person Account';
            prsnAccPhone.PersonEmail = 'SamePhone@Pa.com';
            prsnAccPhone.LoginId__c = 'SamePhone@Pa.com';
            prsnAccPhone.FirstName__pc = prsnAccPhone.FirstName;
            prsnAccPhone.LastName__pc = prsnAccPhone.LastName;
            prsnAccPhone.Phone = '9876543234';
            insert prsnAccPhone;
        }
        createCaseObject();
    }
    
    @future
    static void createCaseObject(){
      Case cs = ASDAC_TestDataUtility.createCases(1, false, ASDAC_GlobalConstants.STRING_CUSTOMER_SUPPORT, null)[0];
        cs.SuppliedEmail = CASE_SUPPLIED_EMAIL;
        cs.SuppliedName =TESTING_FIRST_NAME+' '+TESTING_LAST_NAME;
        cs.Supplied_Lastname__c=TESTING_LAST_NAME;
        cs.SuppliedFirstname__c=TESTING_FIRST_NAME;
		cs.Subject = TESTING_CASE_SUBJECT;
        cs.Origin=ASDAC_GlobalConstants.STRING_WEBFORM_CASE_ORIGIN;
        insert cs;   
    }
    
    /**************************************************************************
     Purpose    : test method to test when no duplicates found then insert 
				  Customer record
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
    @isTest
    public static void testSuccessFullCustomerCreation() {
        User ocsColleagueTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsColleagueTstUsr) {
            Account newCustomer = new Account(FirstName__pc = TESTING_FIRST_NAME,
                                    LastName__pc = TESTING_LAST_NAME,
                                    LastName = TESTING_LAST_NAME,
                                    LoginId__c = PERSON_ACCOUNT_EMAIL,
                                    PersonEmail = PERSON_ACCOUNT_EMAIL,
                                    Phone = '5643210987',
                                    PostalCode__pc = PERSON_ACCOUNT_POSTCODE);
            ASDAC_CreateNewCustomerController.ResponseWrapper resWrap = ASDAC_CreateNewCustomerController.checkDuplicatesAndCreate(newCustomer);
            System.assertEquals(true, resWrap.isSuccess, 'No Exception');
            System.assertEquals(false, resWrap.isDuplicateExists, 'No duplicates found.');
        }
    }
    

    
	/**************************************************************************
     Purpose    : test method to test when duplicates found then 
				  return duplicates          
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
	@isTest
    public static void testDuplicatesWithEmail() {
        User ocsColleagueTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsColleagueTstUsr) {
            Account newCustomer = new Account(FirstName__pc = TESTING_FIRST_NAME,
                                    LastName__pc = TESTING_LAST_NAME,
                                    LastName = TESTING_LAST_NAME,
                                    LoginId__c = PERSON_ACCOUNT_SAME_EMAIL, //Duplicate Email
                                    PersonEmail = PERSON_ACCOUNT_SAME_EMAIL, //Duplicate Email
                                    Phone = '5643210987',
                                    PostalCode__pc = PERSON_ACCOUNT_POSTCODE);
            ASDAC_CreateNewCustomerController.ResponseWrapper resWrap = ASDAC_CreateNewCustomerController.checkDuplicatesAndCreate(newCustomer);
            System.assertEquals(true, resWrap.isDuplicateExists, 'duplicates found.');
        }
    }
    
	/**************************************************************************
     Purpose    : test method to test to log Exception record when exceptions
				  occurs
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
	@isTest
    public static void testExceptionLogCreation() {
        User ocsColleagueTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsColleagueTstUsr) {
            Account newCustomer = new Account(FirstName__pc = TESTING_FIRST_NAME,
                                    LastName__pc = TESTING_LAST_NAME,
                                    //LastName = TESTING_LAST_NAME,// this will create Exception since lastName is required
                                    LoginId__c = PERSON_ACCOUNT_EMAIL, 
                                    PersonEmail = PERSON_ACCOUNT_EMAIL, 
                                    Phone = '5643210987',
                                    PostalCode__pc = PERSON_ACCOUNT_POSTCODE);
        	insert new LogManagement__c(SetupOwnerId = UserInfo.getProfileId(), EnableLogging__c = true);
            ASDAC_CreateNewCustomerController.ResponseWrapper resWrap = ASDAC_CreateNewCustomerController.checkDuplicatesAndCreate(newCustomer);
            System.assertEquals(false, [SELECT Id FROM Log__c].isEmpty(), 'Log Record Inserted.');
            System.assertEquals(false, resWrap.isSuccess, 'Exception occured');
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
     Purpose    : test method to test when customer account gets created          
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
	@isTest
    public static void testcreateCustomerAccount() {
        User ocsColleagueTstUsr = getuserRecord(BPO_USERNAME);
        Case cs=[SELECT Id FROM Case WHERE SuppliedEmail =:CASE_SUPPLIED_EMAIL LIMIT 1];
        SObject[] userShares = new List<SObject> {new CaseShare(CaseAccessLevel = 'Edit',
                                                                CaseId = cs.Id,
                                                                RowCause = 'Manual',
                                                                UserOrGroupId = ocsColleagueTstUsr.Id)};
        insert userShares;
        System.runAs(ocsColleagueTstUsr) {
        Account newCustomer = new Account(FirstName = TESTING_FIRST_NAME,
                                          LastName = TESTING_LAST_NAME,
                                          PersonEmail = CASE_SUPPLIED_EMAIL, 
                                          Phone = PERSON_ACCOUNT_PHONE);
        ASDAC_CreateNewCustomerController.ResponseWrapper resWrap = ASDAC_CreateNewCustomerController.createCustomerAccount(newCustomer);
        System.assertEquals(true, resWrap.isSuccess);
        }
    } 
      
    @isTest
    public static void testcreateCustomerAccountException() {
        User ocsColleagueTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsColleagueTstUsr) {
        Account newCustomer = new Account(FirstName = TESTING_FIRST_NAME,
                                          LastName = TESTING_LAST_NAME,
                                          Phone = PERSON_ACCOUNT_PHONE);
        ASDAC_CreateNewCustomerController.ResponseWrapper resWrap = ASDAC_CreateNewCustomerController.createCustomerAccount(newCustomer);
        System.assertEquals(false, resWrap.isSuccess, 'Exception occured');
        }        
    }   
}