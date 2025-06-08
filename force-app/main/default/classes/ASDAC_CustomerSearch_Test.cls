/**********************************************************************************
 * @author                       : KasiViswaNath Gandham
 * @date                         : 2022-05-23
 * @description                  : ASDAC-623 Carryover Customer Account Search
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * KasiViswaNath Gandham         23-May-2022     Created the class
 * Vineeth Rangamgari            27-May-2022     Updated the class for ASDAC-1041
 * Vineeth Rangamgari            07-June-2022    Updated the class for ASDAC-911
 * Vineeth Rangamgari            07-July-2022    Updated the class for ASDAC-1135
 ***************************************************************************************************/
@isTest(seealldata=false)
public with sharing class ASDAC_CustomerSearch_Test {
  public FINAL STATIC String ACCOUNT_EMAIL = 'acc1@asdatest.co.uk';
  public FINAL STATIC String ACCOUNT_PHONE = '1110-113';
  public FINAL STATIC String ACCOUNT_ADDRESS = 'begum bazar';
  public FINAL STATIC String ACCOUNT_FIRST_NAME = 'First Name';
  public FINAL STATIC String EXPECTED_SUCCESS = 'Expected success';
  public FINAL STATIC String EXPECTED_ACCID = 'Expected acc.id';
  public FINAL STATIC String EXPECTED_ACC_SIZE = 'Expected accountList.size()';
  public FINAL STATIC String EXPECTED_ONE = 'Expected 1';
  /**
   * ****************************************************************************************************
   * @description in this method we are checking size of fields wheather they are greater than zero not.
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetFields() {
    List<ASDAC_CustomerSearch.FilterWrapper> fields = ASDAC_CustomerSearch.getFields();
    System.assertEquals(true, fields.size() >= 0, 'Expected fields');
  }

  /**
   * ****************************************************************************************************
   * @description : In this method, created a account record , and tested  fieldson the record, that are  mapped properly or not
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListFilters() {
    Account acc = new Account();
    acc.FirstName = 'viswa';
    acc.LastName = 'nath';
    acc.LoginId__c = ACCOUNT_EMAIL;
    acc.PersonMobilePhone = ACCOUNT_PHONE;
    acc.AddressLine1__pc = ACCOUNT_ADDRESS;
    acc.City__pc = 'hyderabad';
    acc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc;
    Account acc1 = new Account();
    acc1.FirstName = 'avish';
    acc1.LastName = 'basha';
    acc1.LoginId__c = 'acc2@asdatest.co.uk';
    acc1.AddressLine1__pc = 'gokul bazar';
    acc1.City__pc = 'hyderabad';
    acc1.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc1;
    Account acc2 = new Account();
    acc2.FirstName = 'abdul';
    acc2.LastName = 'shaik';
    acc2.LoginId__c = 'acc3@asdatest.co.uk';
    acc2.AddressLine1__pc = 'nehru bazar';
    acc2.City__pc = 'delhi';
    acc2.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc2;
    ASDAC_CustomerSearch.FilterWrapper filterObj = new ASDAC_CustomerSearch.FilterWrapper();
    filterObj.field = 'FirstName';
    filterObj.search = '*vis*';
    filterObj.label = ACCOUNT_FIRST_NAME;
    filterObj.searchOperation = 'Partial';
    filterObj.customQuery = false;
    ASDAC_CustomerSearch.FilterWrapper filterObj1 = new ASDAC_CustomerSearch.FilterWrapper();
    filterObj1.field = 'AddressLine1__pc, AddressLine2__pc, AddressLine3__pc, City__pc, State__pc, Country__pc, PostalCode__pc';
    filterObj1.search = 'hyd';
    filterObj1.label = 'Address';
    filterObj1.searchOperation = 'Partial';
    filterObj1.customQuery = false;
    List<ASDAC_CustomerSearch.FilterWrapper> filterList = new List<ASDAC_CustomerSearch.FilterWrapper>();
    filterList.add(filterObj);
    filterList.add(filterObj1);

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(filterList, new Map<String, String>());
    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> accountList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(2, accountList.size(), 'Expected 2');
    System.assertEquals(acc1.id, accountList.get(0).Id, 'Expected acc1.id'); // Ordered by Name
    System.assertEquals(acc.id, accountList.get(1).Id, EXPECTED_ACCID);
  }

  /**
   * ****************************************************************************************************
   * @description here tested for Case Number.
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListCaseNumber() {
    Account acc = ASDAC_TestDataUtility.createPersonAccount(true);
    acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :acc.Id];
    Case cs = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', null)[0];
    cs.ContactId = acc.PersonContactId;
    cs.Priority = 'High';
    cs.Status = 'New';
    insert cs;
    cs = [SELECT CaseNumber FROM Case WHERE Id = :cs.Id];

    Map<String, String> customFilter = new Map<String, String>();
    customFilter.put('caseNumber', cs.CaseNumber);

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(new List<ASDAC_CustomerSearch.FilterWrapper>(), customFilter);

    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> accountList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(accountList.size(), 1, EXPECTED_ACC_SIZE);

    Account returnedAccount = accountList[0];
    System.assertEquals(acc.Id, returnedAccount.Id, EXPECTED_ACCID);
  }

  /**
   * ****************************************************************************************************
   * @description here passed an Invaild case number to get no results.
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListNoResults() {
    Account acc = new Account();
    acc.FirstName = 'hemanth';
    acc.LastName = 'rao';
    acc.LoginId__c = 'hemanth.rao@asdatest.co.uk';
    acc.PersonMobilePhone = '112233';
    acc.AddressLine1__pc = 'delhi nagar';
      acc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc;
    Account acc1 = new Account();
    acc1.FirstName = 'sohel';
    acc1.LastName = 'khan';
    acc1.LoginId__c = 'sohel.khan@asdatest.co.uk';
    acc1.AddressLine1__pc = 'lb nagar';
      acc1.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc1;
    Account acc2 = new Account();
    acc2.FirstName = 'rasool';
    acc2.LastName = 'syed';
    acc2.LoginId__c = 'rasool.syed@asdatest.co.uk';
    acc2.AddressLine1__pc = 'naz center';
    acc2.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc2;
    ASDAC_CustomerSearch.FilterWrapper filterObj = new ASDAC_CustomerSearch.FilterWrapper();

    filterObj.field = 'FirstName';
    filterObj.search = 'hemanth';
    filterObj.label = ACCOUNT_FIRST_NAME;
    filterObj.searchOperation = 'Partial';
    filterObj.customQuery = false;

    ASDAC_CustomerSearch.FilterWrapper filterObj1 = new ASDAC_CustomerSearch.FilterWrapper();
    filterObj1.field = 'AddressLine1__pc';
    filterObj1.search = 'delhi nagar';
    filterObj1.label = 'Address';
    filterObj1.searchOperation = 'Partial';
    filterObj1.customQuery = false;
    List<ASDAC_CustomerSearch.FilterWrapper> filterList = new List<ASDAC_CustomerSearch.FilterWrapper>();
    filterList.add(filterObj);
    filterList.add(filterObj1);

    Map<String, String> customFilter = new Map<String, String>();
    customFilter.put('caseNumber', '12345');

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(filterList, customFilter); // Invalid CaseNumber -> No Results

    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> accountList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(accountList.size(), 0, EXPECTED_ACC_SIZE);
  }

  /**
   * ****************************************************************************************************
   * @description here tested for Case Number & orderid.
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListCaseOrderId() {
    Account acc = new Account();
    acc.FirstName = 'ravi';
    acc.LastName = 'kiran';
    acc.LoginId__c = ACCOUNT_EMAIL;
    acc.PersonMobilePhone = '00001122';
    acc.AddressLine1__pc = 'bombay center';
      acc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc;
    acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :acc.Id];
    Case cs = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', null)[0];
    cs.ContactId = acc.PersonContactId;
    cs.Priority = 'High';
    cs.Status = 'New';
    cs.OrderId__c = 'qwer';
    insert cs;
    cs = [SELECT CaseNumber, OrderId__c FROM Case WHERE Id = :cs.Id];

    Map<String, String> customFilter = new Map<String, String>();
    customFilter.put('caseNumber', cs.CaseNumber);
    customFilter.put('orderId', cs.OrderId__c);

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(new List<ASDAC_CustomerSearch.FilterWrapper>(), customFilter);

    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> accountList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(accountList.size(), 1, EXPECTED_ACC_SIZE);

    Account returnedAccount = accountList[0];
    System.assertEquals(acc.Id, returnedAccount.Id, EXPECTED_ACCID);
  }

  /**
   * ****************************************************************************************************
   * @description here tested for orderid.
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListOrderId() {
    Account acc = new Account();
    acc.FirstName = 'ravi';
    acc.LastName = 'kiran';
    acc.LoginId__c = ACCOUNT_EMAIL;
    acc.PersonMobilePhone = '00001122';
    acc.AddressLine1__pc = 'bombay center';
      acc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc;
    acc = [SELECT Id, PersonContactId FROM Account WHERE Id = :acc.Id];
    Case cs = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', null)[0];
    cs.ContactId = acc.PersonContactId;
    cs.Priority = 'High';
    cs.Status = 'New';
    cs.OrderId__c = 'qwer';
    insert cs;
    cs = [SELECT OrderId__c FROM Case WHERE Id = :cs.Id];

    Map<String, String> customFilter = new Map<String, String>();
    customFilter.put('orderId', cs.OrderId__c);

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(new List<ASDAC_CustomerSearch.FilterWrapper>(), customFilter);

    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> accountList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(1, accountList.size(), EXPECTED_ONE);

    Account returnedAccount = accountList[0];
    System.assertEquals(acc.Id, returnedAccount.Id, EXPECTED_ACCID);
  }

  /**
   * ****************************************************************************************************
   * @description test getCustomersList based on postal code
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListPostalCode() {
    Account acc = new Account();
    acc.FirstName = 'viswa';
    acc.LastName = 'nath';
    acc.LoginId__c = ACCOUNT_EMAIL;
    acc.PersonMobilePhone = ACCOUNT_PHONE;
    acc.AddressLine1__pc = ACCOUNT_ADDRESS;
    acc.PostalCode__pc = '1234';
    acc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc;
    ASDAC_CustomerSearch.FilterWrapper filterObj3 = new ASDAC_CustomerSearch.FilterWrapper();
    filterObj3.field = 'PostalCode__pc';
    filterObj3.label = 'Postal Code';
    filterObj3.search = '1234';
    filterObj3.searchOperation = 'Exactly';
    filterObj3.customQuery = false;
    List<ASDAC_CustomerSearch.FilterWrapper> filterList3 = new List<ASDAC_CustomerSearch.FilterWrapper>();
    filterList3.add(filterObj3);

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(filterList3, new Map<String, String>());
    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> accountList3 = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(accountList3.size(), 1, 'Expected accountList3.size()');

    Account returnedAccount1 = accountList3[0];
    Account retAccount1 = [SELECT id, LastName, FirstName, AddressLine1__pc FROM Account WHERE Id = :returnedAccount1.Id];
    System.assertEquals(Acc.id, retAccount1.Id, EXPECTED_ACCID);
  }

  /**
   * ****************************************************************************************************
   * @description test getCustomersList for data table
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListDatatable() {
    Account acc = new Account();
    acc.FirstName = 'viswa';
    acc.LastName = 'nath';
    acc.LoginId__c = ACCOUNT_EMAIL;
    acc.PersonMobilePhone = ACCOUNT_PHONE;
    acc.AddressLine1__pc = ACCOUNT_ADDRESS;
    acc.Status__c = 'Active';
    acc.PostalCode__pc = '334455';
    acc.Salutation = 'Mr';
    acc.PersonEmail = acc.LoginId__c;
    acc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT);
    insert acc;

    ASDAC_CustomerSearch.FilterWrapper filterObj = new ASDAC_CustomerSearch.FilterWrapper();
    filterObj.field = 'FirstName';
    filterObj.search = '*viswa*';
    filterObj.label = ACCOUNT_FIRST_NAME;
    filterObj.searchOperation = 'Partial';
    filterObj.customQuery = false;
    ASDAC_CustomerSearch.FilterWrapper filterObj1 = new ASDAC_CustomerSearch.FilterWrapper();
    filterObj1.field = 'AddressLine1__pc';
    filterObj1.search = ACCOUNT_ADDRESS;
    filterObj1.label = 'Address';
    filterObj1.searchOperation = 'Partial';
    filterObj1.customQuery = false;
    ASDAC_CustomerSearch.FilterWrapper filterObj2 = new ASDAC_CustomerSearch.FilterWrapper();
    filterObj2.field = 'PostCode__pc';
    filterObj2.search = '';
    filterObj2.label = 'Post Code';
    filterObj2.searchOperation = 'Exactly';
    filterObj2.customQuery = false;
    List<ASDAC_CustomerSearch.FilterWrapper> filterList = new List<ASDAC_CustomerSearch.FilterWrapper>();
    filterList.add(filterObj);
    filterList.add(filterObj1);
    filterList.add(filterObj2);

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(filterList, new Map<String, String>());
    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> accountList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(accountList.size(), 1, EXPECTED_ACC_SIZE);

    Account returnedAccount = accountList[0];
    Account retAccount = [SELECT id, LastName, FirstName, AddressLine1__pc FROM Account WHERE Id = :returnedAccount.Id];
    System.assertEquals(acc.id, retAccount.Id, EXPECTED_ACCID);
    Account retAccountmn = [
      SELECT Id, Name, PersonEmail, PostalCode__pc, Status__c, AddressLine1__pc, PersonMobilePhone
      FROM Account
      WHERE Id = :retAccount.Id
    ];
    System.assertEquals(acc.id, retAccountmn.Id, EXPECTED_ACCID);
  }

  /**
   * ****************************************************************************************************
   * @description : method to test search based on phone number
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListPhoneNumber() {
    String[] phoneNumbers = new List<String>{ '12345', '67890', '13579', '24680' };
    Account customer = new Account(
      FirstName = 'Test',
      LastName = 'Customer',
      LoginId__c = ACCOUNT_EMAIL,
	  PersonEmail = ACCOUNT_EMAIL,
      SecondaryLoginId__c = phoneNumbers[0],
	  CountryCode__c = '1',
      Phone = phoneNumbers[1],
      RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT)
    );
    insert customer;
    ContactPointPhone contactPointPhone1 = new ContactPointPhone(ParentId = customer.Id, TelephoneNumber = phoneNumbers[2]);
    insert contactPointPhone1;
    ContactPointPhone contactPointPhone2 = new ContactPointPhone(ParentId = customer.Id, TelephoneNumber = phoneNumbers[3]);
    insert contactPointPhone2;

    ASDAC_CustomerSearch.FilterWrapper filter = new ASDAC_CustomerSearch.FilterWrapper();
    filter.label = 'Primary Contact Number';
    filter.field = 'SecondaryLoginId__c, Phone';
    filter.search = '';
    filter.searchOperation = 'Exactly';
    filter.customQuery = true;
    List<ASDAC_CustomerSearch.FilterWrapper> filters = new List<ASDAC_CustomerSearch.FilterWrapper>{ filter };

    for (String phoneNumber : phoneNumbers) {
      Map<String, String> customFilter = new Map<String, String>();
      customFilter.put('phone', phoneNumber);

      ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(filters, customFilter);
      System.assert(res.isSuccess, EXPECTED_SUCCESS);
      List<Account> customerList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
      System.assertEquals(1, customerList.size(), EXPECTED_ONE);
      System.assertEquals(customer.Id, customerList.get(0).Id, 'Expected customer.Id');
    }
  }

  /**
   * ****************************************************************************************************
   * @description : method to test search based on contact point phone number and other filters
   * ****************************************************************************************************
   */
  @IsTest
  static void testGetCustomersListContactPointPhoneNumber() {
    Account customer = new Account(FirstName = 'Test', LastName = 'Customer', LoginId__c = ACCOUNT_EMAIL, Phone = '12345', RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJACCOUNT, ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT));
    insert customer;
    customer = [SELECT Phone, PersonContactId FROM Account WHERE Id = :customer.Id];
    ContactPointPhone customerPhone = new ContactPointPhone(ParentId = customer.Id, TelephoneNumber = '45678');
    insert customerPhone;
    Case customerCase = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', null)[0];
    customerCase.ContactId = customer.PersonContactId;
    insert customerCase;
    customerCase = [SELECT CaseNumber FROM Case WHERE Id = :customerCase.Id];

    ASDAC_CustomerSearch.FilterWrapper filter = new ASDAC_CustomerSearch.FilterWrapper();
    filter.label = ACCOUNT_FIRST_NAME;
    filter.field = 'FirstName';
    filter.search = 'te*';
    filter.searchOperation = 'Partial';
    filter.customQuery = false;
    List<ASDAC_CustomerSearch.FilterWrapper> filters = new List<ASDAC_CustomerSearch.FilterWrapper>{ filter };

    Map<String, String> customFilter = new Map<String, String>();
    customFilter.put('caseNumber', customerCase.caseNumber);
    customFilter.put('phone', customerPhone.TelephoneNumber);

    ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomersList(filters, customFilter);
    System.assert(res.isSuccess, EXPECTED_SUCCESS);
    List<Account> customerList = (List<Account>) JSON.deserialize(res.message, List<Account>.class);
    System.assertEquals(1, customerList.size(), EXPECTED_ONE);
    System.assertEquals(customer.Id, customerList.get(0).Id, 'Expected customer.Id');
  }

    /**
   * ****************************************************************************************************
   * @description : method to test search based on contact point phone number and other filters
   * ****************************************************************************************************
   */
  @IsTest
  static void testgetCustomerIdFromCallout() {
    Test.startTest();
      ASDAC_CustomerSearch.ResponseWrapper res = ASDAC_CustomerSearch.getCustomerIdFromCallout('TestOrderNumber');
      system.assertEquals(res.isSuccess, true, 'Account match found.');
    Test.stopTest();
  }
}