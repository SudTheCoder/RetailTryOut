/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-06-23
 * @description                  : ASDAC-949 Enable GEORGE Webform to Case
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            23-June-2022       Created the class
 * Vineeth Rangamgari            23-August-2022     Updated the class for ASDAC-2220
 * Disharee Ray                  08-September-2022  Updated the class for ASDAC-3434
 ***************************************************************************************************/
@IsTest
public with sharing class ASDAC_WebformCmpController_Test {
  private static final String WEBFORM_NAME = 'George - Refund';
  private static final String ADMIN_PROFILE = 'System Administrator';
  private static final String CUSTOMER_PROFILE = 'Help Centre Customer';
  private static final String GUEST_PROFILE = 'Help Profile';
  private static final String CASE_RECORD_TYPE = 'Complaint';
  private static final String ENTITLEMENT_NAME = '48 Hours SLA';
  private static final String CUSTOMER_EMAIL = 'guest.customer@asdatest.co.uk';
  private static final String WEB_CASE_ORIGIN = 'Expected Case origin as Web';
  private static final String EXPECTED_CONSTANT = 'Expected ';
  private static final String ENT_ATTACHED = ' Entitlement to be attached'; 
  private static final String ATTACH_CONSTANT = ' attachment(s)';
  private static final String EMAIL_SENT = 'Email is sent';

  @TestSetup
  static void setup() {
    createEntitlementData();
    createCustomerAccount();
  }

  static void createEntitlementData() {
    Account entAcc = ASDAC_TestDataUtility.createAccount(false);
    entAcc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId('Account', 'BusinessAccount');
    entAcc.Name = 'Entitlement Account';
    insert entAcc;
    ASDAC_TestDataUtility.createEntitlements(true, ENTITLEMENT_NAME, entAcc.Id, null);
  }

  static void createCustomerAccount() {
    Account customer = new Account(FirstName = 'Guest', LastName = 'Customer', LoginId__c = CUSTOMER_EMAIL, PersonEmail = CUSTOMER_EMAIL, RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT));
    insert customer;
    customer = [SELECT PersonContactId FROM Account WHERE Id = :customer.Id];
  }

  /**
   * ****************************************************************************************************
   * @param webformName name of the webform
   * @description method to create Case object
   * @return Case
   * ****************************************************************************************************
   */
  static Case createCaseObject(String webformName) {
        Case cs = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', null)[0];
      	cs.Webform__c = webformName;
        cs.SuppliedEmail = 'guest.user@asdatest.co.uk';
        cs.SuppliedName ='Test123';
        cs.ContactReasonLevel2__c = (webformName!='George - International Orders') ? 'General Issue':'';
		cs.OrderId__c='TEST123';
		cs.Subject = webformName;
		cs.Description = 'Returned To: Courier\nReturn Code: ASD12345\nBrief description of the issue with customer\'s order:Testing';
      	return cs;
  }

  /**
   * ****************************************************************************************************
   * @param fileNumber number of the file
   * @description method to create File object
   * @return ASDAC_WebformCmpController.FileWrapper
   * ****************************************************************************************************
   */
  static ASDAC_WebformCmpController.FileWrapper createFile(Integer fileNumber) {
    ASDAC_WebformCmpController.FileWrapper file = new ASDAC_WebformCmpController.FileWrapper();
    file.name = 'file' + fileNumber + '.txt';
    file.type = 'txt';
    file.body = 'dGV4dCBib2R5'; // 'text body' in base64 encoding
    return file;
  }

  /**
   * ****************************************************************************************************
   * @description method for testing case creation for a Customer
   * ****************************************************************************************************
   */
    @IsTest
    static void testCaseCreationForCustomer() {
        UserRole adminRole = new UserRole(Name = 'Admin');
        insert adminRole;
        Profile adminProfile = ASDAC_TestDataUtility.getProfile(ADMIN_PROFILE);
        User adminUser = ASDAC_TestDataUtility.getUser('admin.customer@asdatest.co.uk', adminProfile.Id);
        adminUser.UserRoleId = adminRole.Id;
        insert adminUser;
        
        String customerEmail = 'sample.customer@asdatest.co.uk';
        System.runAs(adminUser) {
            Account customer = new Account(FirstName = 'Sample', LastName = 'Customer', LoginId__c = customerEmail, PersonEmail = customerEmail, RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT));
            insert customer;
            customer = [SELECT PersonContactId, RecordTypeId, RecordType.Name FROM Account WHERE Id = :customer.Id];
            Profile customerProfile = ASDAC_TestDataUtility.getProfile(CUSTOMER_PROFILE);
            User customerUser = ASDAC_TestDataUtility.getUser(customerEmail, customerProfile.Id);
            customerUser.ContactId = customer.PersonContactId;
            customerUser.FederationIdentifier = 'FID-customer-user';
            insert customerUser;
        }
        
        Account customer = [SELECT PersonContactId FROM Account WHERE LoginId__c = :customerEmail];
        User customerUser = [SELECT Id FROM User WHERE Username = :customerEmail];
        
        Case caseObject = createCaseObject(WEBFORM_NAME);
        List<ASDAC_WebformCmpController.FileWrapper> files = new List<ASDAC_WebformCmpController.FileWrapper>{ createFile(1) };
            
            String caseId = '';
        Test.startTest();
        System.runAs(customerUser) {
            caseId = ASDAC_WebformCmpController.createCase(caseObject, files);
        }
        Test.stopTest();
        
        Case caseRecord = [SELECT Origin, SuppliedEmail, ContactId, AccountId, Entitlement.Name, Status FROM Case WHERE Id = :caseId];
        System.assertEquals('Webform', caseRecord.Origin, WEB_CASE_ORIGIN);
        System.assertEquals(null, caseRecord.SuppliedEmail, 'Expected Suplied Email to be removed');
        System.assertEquals(customer.PersonContactId, caseRecord.ContactId, 'Expected Case contact as Customer');
        System.assertEquals(customer.Id, caseRecord.AccountId, 'Expected Case account as Customer');
        
        List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caseRecord.Id];
        System.assertEquals(files.size(), contentDocumentLinkList.size(), EXPECTED_CONSTANT + files.size() + ATTACH_CONSTANT);
    }

  /**
   * ****************************************************************************************************
   * @description method for testing case creation for a Guest user with matching customer account
   * ****************************************************************************************************
   */
  @IsTest
  static void testCaseCreationForGuestUserWithMatchingCustomerAccount() {
    User guestUser = [SELECT Id, Name FROM User WHERE Profile.Name = :GUEST_PROFILE];

    Case caseObject = createCaseObject(WEBFORM_NAME);
    caseObject.SuppliedEmail = CUSTOMER_EMAIL;
    List<ASDAC_WebformCmpController.FileWrapper> files = new List<ASDAC_WebformCmpController.FileWrapper>{ createFile(1) };

    String caseId = '';
    Test.startTest();
    System.runAs(guestUser) {
      caseId = ASDAC_WebformCmpController.createCase(caseObject, files);
    }
    Test.stopTest();

    Account customer = [SELECT PersonContactId FROM Account WHERE LoginId__c = :CUSTOMER_EMAIL];
    Case caseRecord = [SELECT Origin, SuppliedEmail, ContactId, AccountId, Entitlement.Name FROM Case WHERE Id = :caseId];
    System.assertEquals('Webform', caseRecord.Origin, WEB_CASE_ORIGIN);
    System.assertEquals(null, caseRecord.SuppliedEmail, 'Expected Suplied Email to be removed');
    System.assertEquals(customer.PersonContactId, caseRecord.ContactId, 'Expected Case contact as matching Customer');
    System.assertEquals(customer.Id, caseRecord.AccountId, 'Expected Case account as matching Customer');

    List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caseRecord.Id];
    System.assertEquals(files.size(), contentDocumentLinkList.size(), EXPECTED_CONSTANT + files.size() + ATTACH_CONSTANT);
  }

  /**
   * ****************************************************************************************************
   * @description method for testing case creation for a Guest user without matching customer account
   * ****************************************************************************************************
   */
  @IsTest
  static void testCaseCreationForGuestUserWithoutMatchingCustomerAccount() {
    User guestUser = [SELECT Id, Name FROM User WHERE Profile.Name = :GUEST_PROFILE];

    Case caseObject = createCaseObject(WEBFORM_NAME);
    List<ASDAC_WebformCmpController.FileWrapper> files = new List<ASDAC_WebformCmpController.FileWrapper>{ createFile(1) };

    String caseId = '';
    Test.startTest();
    System.runAs(guestUser) {
      caseId = ASDAC_WebformCmpController.createCase(caseObject, files);
    }
    Test.stopTest();

    Case caseRecord = [SELECT Origin, SuppliedEmail, ContactId, AccountId, Entitlement.Name FROM Case WHERE Id = :caseId];
    System.assertEquals('Webform', caseRecord.Origin, WEB_CASE_ORIGIN);
    System.assertEquals(caseObject.SuppliedEmail, caseRecord.SuppliedEmail, 'Expected Suplied Email to be retained');
    System.assertEquals(null, caseRecord.ContactId, 'Expected Case contact as empty for Guest user');
    System.assertEquals(null, caseRecord.AccountId, 'Expected Case account as empty for Guest user');

    List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caseRecord.Id];
    System.assertEquals(files.size(), contentDocumentLinkList.size(), EXPECTED_CONSTANT + files.size() + ATTACH_CONSTANT);
  }

  /**
   * ****************************************************************************************************
   * @description method for testing case record type based on webform name
   * ****************************************************************************************************
   */
  @IsTest
  static void testCaseRecordType() {
    Id recordTypeId = ASDAC_WebformCmpController.getCaseRecordType(WEBFORM_NAME);

    RecordType caseRecordType = [SELECT Id FROM RecordType WHERE Name = :CASE_RECORD_TYPE];
    System.assertEquals(caseRecordType.Id, recordTypeId, 'Expected Case record type: ' + CASE_RECORD_TYPE);
  }

  /**
   * ****************************************************************************************************
   * @description method for testing Invalid Email
   * ****************************************************************************************************
   */
 @IsTest
  static void testInvalidEmailException() {
    Case caseObject = createCaseObject(WEBFORM_NAME);
    caseObject.SuppliedEmail = '';
    List<ASDAC_WebformCmpController.FileWrapper> files = new List<ASDAC_WebformCmpController.FileWrapper>();

    Boolean exceptionRaised = false;
    try {
      ASDAC_WebformCmpController.createCase(caseObject, files);
    } catch (AuraHandledException e) {
      exceptionRaised = true;
    }
    System.assertEquals(true, exceptionRaised, 'Expected Invalid Email Exception');
  }

  /**
   * ****************************************************************************************************
   * @description method for testing Invalid Webform
   * ****************************************************************************************************
   */
  @IsTest
  static void testInvalidWebformException() {
    Case caseObject = createCaseObject('Invalid Webform Name');
    List<ASDAC_WebformCmpController.FileWrapper> files = new List<ASDAC_WebformCmpController.FileWrapper>();

    Boolean exceptionRaised = false;
    try {
      ASDAC_WebformCmpController.createCase(caseObject, files);
    } catch (AuraHandledException e) {
      exceptionRaised = true;
    }
    System.assertEquals(true, exceptionRaised, 'Expected Invalid Webform Exception');
  }
    
     /**
   * ****************************************************************************************************
   * @description method for testing sendEmailToGlobalETeam method
   * ****************************************************************************************************
   */
  @IsTest
  static void testSendEmailToGlobalETeam() {
    Case caseObject = createCaseObject('George - International Orders');
    caseObject.SuppliedEmail = CUSTOMER_EMAIL;
    List<ASDAC_WebformCmpController.FileWrapper> files = new List<ASDAC_WebformCmpController.FileWrapper>();
    Test.startTest();
    System.assertEquals(0, Limits.getEmailInvocations(), 'No emails were sent');
    ASDAC_WebformCmpController.createCase(caseObject,files);
    System.assertEquals(1, Limits.getEmailInvocations(), EMAIL_SENT);
    Test.stopTest();
  }

  /**
   * ****************************************************************************************************
   * @description method for testing Webform Case creation
   * ****************************************************************************************************
   */
  @IsTest
  static void testWebformCaseCreation() {
    Case caseObject = createCaseObject(WEBFORM_NAME);
    caseObject.Origin = 'Webform';
    caseObject.ContactReasonLevel2__c = '';

    List<Case> result = ASDAC_WebformCmpController.upsertWebformCase(new List<Case> { caseObject });
    Id caseId = result[0].Id;

    Case caseRecord = [SELECT Origin, SuppliedEmail, ContactId, AccountId, Entitlement.Name FROM Case WHERE Id = :caseId];
    System.assertEquals(caseObject.SuppliedEmail, caseRecord.SuppliedEmail, 'Expected Suplied Email to be retained');
    System.assertEquals(null, caseRecord.ContactId, 'Expected Case contact as empty for Guest user');
    System.assertEquals(null, caseRecord.AccountId, 'Expected Case account as empty for Guest user');
    System.assertEquals(ENTITLEMENT_NAME, caseRecord.Entitlement.Name, EXPECTED_CONSTANT + ENTITLEMENT_NAME + ENT_ATTACHED);
  }

  /**
   * ****************************************************************************************************
   * @description method for testing Files creation
   * ****************************************************************************************************
   */
  @IsTest
  static void testFileCreation() {
    String fileName = 'file.txt';
    ContentVersion file = new ContentVersion(
      ContentLocation = 'S',
      PathOnClient = fileName,
      Title = fileName,
      VersionData = Blob.valueOf('file body')
    );
    List<List<ContentVersion>> files = new List<List<ContentVersion>> { new List<ContentVersion> { file } };

    ASDAC_WithoutSharingUtility.insertFiles(files);
    System.assertNotEquals(null, file.Id, 'Expected file to be created');
  }
}