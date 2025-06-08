/***************************************************************************************************************************
* Author:       Dependra Singh
* Date:         23/05/2022
* Description:  Test Utility
**************************************************************************************************************************/
public with sharing class ASDAC_TestDataUtility {
    public FINAL STATIC String EMAIL_SUFFIX = '@asdatest.co.uk'; 
    
/***************************************************************************************************************************
* Author:       Dependra Singh
* Date:         23/05/2022
* Description:  Populate Account with Contacts
**************************************************************************************************************************/   
    public static void createAccountWithContacts(Integer numAccts, Integer numContactsPerAcct) {
        List<Account> lstAccount = new List<Account>();
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BusinessAccount').getRecordTypeId();

        for (Integer i = 0; i < numAccts; i++) {
            Account a = new Account(
                Name = 'TestAccount' + i,
                Loginid__c = 'testdatautilaccount@asdatest.co.uk' + i,
                RecordTypeId=RecordTypeIdaccount
            );
            lstAccount.add(a);
        }
        if(Account.SObjectType.getDescribe().isCreateable()){
        insert lstAccount;
        }

        List<Contact> lstcontact = new List<Contact>();
        for (Integer j = 0; j < numAccts; j++) {
            Account objAccount = lstAccount[j];
            // For each account just inserted, add contacts
            for (Integer k = numContactsPerAcct * j; k < numContactsPerAcct * (j + 1); k++) {
                lstcontact.add( new Contact(firstname = 'Test' + k,lastname = 'Test' + k, AccountId = objAccount.Id));
            }
        }
        // Insert all contacts for all accounts
        if(Contact.SObjectType.getDescribe().isCreateable()){
        insert lstcontact;
        }
    }
    
/***********************************************************
* Author:       Dependra Singh
* Date:         23/05/2022
* Description:   This method is test data for create Account
* ***********************************************************/  
    public static Account createAccount(Boolean doInsert) {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.Loginid__c = 'testdatautilaccount@asdatest.co.uk';
        if (doInsert) {
            insert objAccount;
        }
        return objAccount;
    }

/*********************************************************************
    * Author:       Ramdev Chahar
    * Date:         28/10/2022
    * Description:  This method is to get personAccount recordtype Id
**********************************************************************/
    public static String getPersonAccountRecordTypeId() {
        return Schema.getGlobalDescribe()
          .get('Account')
          .getDescribe()
          .getRecordTypeInfosByDeveloperName()
          .get('PersonAccount')
          .getRecordTypeId();
    }
    
    /******************************************************************
    * Author:       Ramdev Chahar
    * Date:         28/10/2022
    * Description:  This method is to create particular Perso nAccount
    * *****************************************************************/
    public static Account getNthPersonAccount(Integer n) {
        String personAccountRecordTypeId = getPersonAccountRecordTypeId();
        String apendString = '';
        if(n != 0 || n != null){
            apendString += n;
        }
        Account objAccount = new Account();
        objAccount.RecordTypeID = personAccountRecordTypeId;
        objAccount.FirstName = 'Test FName'+apendString;
        objAccount.LastName = 'Test LName'+apendString;
        objAccount.AddressLine1__pc = 'testAddressLine1'+apendString;
        objAccount.AddressLine2__pc = 'testAddressLine2'+apendString;
        objAccount.AddressLine3__pc = 'testAddressLine3'+apendString;
        objAccount.City__pc = 'SFO';
        objAccount.PostalCode__pc = '12345';
        objAccount.State__pc = 'testState'+apendString;
        objAccount.Loginid__c ='test' +Integer.valueof((Math.random() * 100)) + EMAIL_SUFFIX + String.valueOf(Math.abs(Crypto.getRandomLong()));
        objAccount.PersonEmail = objAccount.Loginid__c;
        return objAccount;
    }

    /*********************************************************
    * Author:       Dependra Singh
    * Date:         23/05/2022
    * Description:  This method is test data for create Person Account
    *********************************************************/
    public static Account createPersonAccount(Boolean doInsert) {
        Account objAccount = getNthPersonAccount(0);
        if (doInsert) {
            insert objAccount;
        }
        return objAccount;
    }
    
    /*******************************************************************
    * Author:       Ramdev Chahar
    * Date:         28/10/2022
    * Description:  This method is test data for create Person Accounts
    ********************************************************************/
    public static List<Account> createPersonAccounts(Integer numAccts, Boolean doInsert) {
        List<Account> lstAccount = new List<Account>();
        for(Integer i = 0; i < numAccts; i++){
            lstAccount.add(getNthPersonAccount(i));
        }
        if (doInsert) {
            insert lstAccount;
        }
        return lstAccount;
    }
/***********************************************************
* Author:       Dependra Singh
* Date:         23/05/2022
* Description:  This method is test data for create Contact
************************************************************/      
    public static Contact createContact(Boolean doInsert, Id accId) {
        Contact objContact = new Contact();
        objContact.AccountId = accId;
        objContact.FirstName = 'FirstName';
        objContact.LastName = 'LastName';
        objContact.Email = 'FirstName@asdatest.co.uk' + Math.floor(Math.random() * 1000);
        if (doInsert) {
            insert objContact;
        }
        return objContact;
    }
/***************************************************************************************************************************
* Author:       Dependra Singh
* Date:         23/05/2022
* Description:  Populate Profile object
**************************************************************************************************************************/
    public static Profile getProfile(String profileName){
        Profile userProfile = [SELECT Id FROM Profile  WHERE Name = :profileName WITH SECURITY_ENFORCED LIMIT 1];
        return userProfile;
    }
    
/***************************************************************************************************************************
* Author:       Dependra Singh
* Date:         23/05/2022
* Description:  Populate User object
**************************************************************************************************************************/
    public static User getUser(String userName, Id userProfileId) {
        User userRecord = new User();
        userRecord.Alias = 'TESTU';
        userRecord.Email = 'testuser.salesforce@asdatest.co.uk';
        userRecord.EmailEncodingKey = 'UTF-8';
        userRecord.LastName = 'Test User';
        userRecord.LanguageLocaleKey = 'en_US';
        userRecord.LocaleSidKey = 'en_US';
        userRecord.TimeZoneSidKey = 'America/Los_Angeles';
        userRecord.UserName = userName;
        userRecord.ProfileId = userProfileId;
        userRecord.FederationIdentifier = 'FID-abcde12345';
        //... Other fields
        return userRecord;
    }
      
/***************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         28/10/2022
    * Description:  This method is test data for create List of Contact Point Address 
****************************************************************************************/
    public static List<ContactPointAddress> createContactPointAddress(Boolean doInsert, Id accId, Integer noOfRecords) {
        List<ContactPointAddress> lstContactPointAddress = new List<ContactPointAddress>();
        for (integer i = 0; i < noOfRecords; i++) {
            ContactPointAddress objCPA = new ContactPointAddress();
            objCPA.ParentId = accId;
            objCPA.Name = 'TestName'+i;
            objCPA.City__c = 'TestCity';
            objCPA.AddressLine1__c = 'TestLine1'+i;
            objCPA.AddressLine2__c = 'TestLine2'+i;
            objCPA.AddressLine3__c = 'TestLine3'+i;
            lstContactPointAddress.add(objCPA);
        }
        if(doInsert && ContactPointAddress.SObjectType.getDescribe().isCreateable()){
            insert lstContactPointAddress;
        }
        return lstContactPointAddress;
    }
 /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         25 August 2025
    * Description:  Populate Contact Point Consent object data
*****************************************************************************************************************************/
    public static List<ContactPointConsent> createContactPointConsents(Boolean doInsert,String accountId,String contactId,Integer noOfRecords) {
    List<ContactPointConsent> lstContactPointConsent = new List<ContactPointConsent>();
    for (Integer i = 0; i < noOfRecords; i++) {
      ContactPointConsent objConsent = new ContactPointConsent();
      objConsent.ExternalId__c = i + 'test' + Integer.valueof((Math.random() * 100)) + EMAIL_SUFFIX + String.valueOf(Math.abs(Crypto.getRandomLong()));
      objConsent.Account__c = accountId;
      objConsent.ContactPointId = contactId;
      objConsent.Name = 'TestName';
      lstContactPointConsent.add(objConsent);
    }
    if(doInsert && ContactPointConsent.SObjectType.getDescribe().isCreateable()){
      insert lstContactPointConsent;
    }
    return lstContactPointConsent;
  }
    /***************************************************************************************************************************
	* Author:       Sathish Thallapelly
	* Date:         09/06/2022
	* Description:  Populate Contact Point Phone Object Data
	**************************************************************************************************************************/
    public static List<ContactPointPhone> createContactPointPhone(Boolean doInsert,String accountId,Integer noOfRecords) {
        List<ContactPointPhone> lstContactPointPhone = new List<ContactPointPhone>();
        for (integer i = 0; i < noOfRecords; i++) {
            ContactPointPhone objCPP = new ContactPointPhone();
            objCPP.TelephoneNumber = '1234567890' + i;
            objCPP.ContactPhoneType__c = 'Mobile';
            objCPP.ContactType__c = 'Phone';
            objCPP.CountryCode__c = '1';
            objCPP.IsPrimary = true;
            objCPP.ExternalId__c =i +'test' +Integer.valueof((Math.random() * 100)) + EMAIL_SUFFIX + String.valueOf(Math.abs(Crypto.getRandomLong()));
            objCPP.IsMigrated__c = true;
            objCPP.ParentId = accountId;
            lstContactPointPhone.add(objCPP);
        }
        if(doInsert && ContactPointPhone.SObjectType.getDescribe().isCreateable()){
            insert lstContactPointPhone;
        }
        return lstContactPointPhone;
    }
    /***************************************************************************************************************************
	* Author:       Sathish Thallapelly
	* Date:         09/06/2022
	* Description:  Populate Contact Point Email object data
	**************************************************************************************************************************/
    public static List<ContactPointEmail> createContactPointEmail(Boolean doInsert,String accountId,Integer noOfRecords) {
        List<ContactPointEmail> lstContactPointEmail = new List<ContactPointEmail>();
        
        for (Integer i = 0; i < noOfRecords; i++) {
            ContactPointEmail objCPE = new ContactPointEmail();
            objCPE.EmailAddress = i + 'test12345@asdatest.co.uk';
            objCPE.EmailContentType__c = 'HTML';
            objCPE.ContactType__c = 'EMAIL';
            objCPE.IsPrimary = true;
            objCPE.ExternalId__c =i +'test' +Integer.valueof((Math.random() * 100)) + EMAIL_SUFFIX + String.valueOf(Math.abs(Crypto.getRandomLong()));
            objCPE.IsMigrated__c = true;
            objCPE.ParentId = accountId;
            lstContactPointEmail.add(objCPE);
        }
        if(doInsert && ContactPointEmail.SObjectType.getDescribe().isCreateable()){
            insert lstContactPointEmail;
        }
        return lstContactPointEmail;
    }
    
	/***************************************************************************************************************************
    * Author:       Nitish Yadav
    * Date:         06/06/2022
    * Description:  Create test users
    **************************************************************************************************************************/
	public static List<User> createUsers(Integer userCount, Boolean isInsert, String profileName){ 
        String profileId = getProfile(profileName).Id;
        List<User> userList = new List<User>();
        for(Integer uCount = 0; uCount < userCount; uCount++){
            String str = '_' + uCount;
            User usr = new User(ProfileId = profileId,
                                alias = 'test' + str, 
                                email = 'testUser' + str + '@testing.com',
                                emailencodingkey = 'UTF-8', 
                                firstName = 'Fname' + str,
                                lastname = 'Lname' + str, 
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US', 
                                timezonesidkey = 'America/Los_Angeles', 
                                FederationIdentifier = 'FederationId' + str ,
                                username = 'testUser' + str + '@testing' + str + '.com');
            userList.add(usr);
        }
        if (isInsert && User.SObjectType.getDescribe().isCreateable()){
            insert userList;
        }
        return userList;
    }
    
	/**************************************************************************
    * Author:       Nitish Yadav
    * Date:         06/06/2022
    * Description:  Create test Cases                                                
    **************************************************************************/
    public static List<Case> createCases(Integer noOfCases, Boolean isInsert, String recordTypeDevName, Id accountId) {
        List<Case> listOfcases = new List<Case>();                
        Id recTypeId = getRecordTypeInfoMapFrmDevName('Case').get(recordTypeDevName).getRecordTypeId();        
        for(Integer caseCount = 0; caseCount < noOfCases; caseCount++) {
            Case caseObj = new Case(Origin = 'Email',
                                    RecordTypeId = recTypeId,
                                    AccountId = accountId,
                                    Subject = 'Testing ' + caseCount ,
                                    Status = Label.ASDAC_DefaultCaseStatus
                                    );
            listOfcases.add(caseObj);
        }
        if(isInsert && Case.SObjectType.getDescribe().isCreateable()) {
            insert listOfcases;
        }
        return listOfcases;
    }
    
	/**************************************************************************
    * Author:       Nitish Yadav
    * Date:         06/06/2022
    * Description:  Method to find if correct recordtype has been used                                                
    **************************************************************************/
	public static Map<String, Schema.RecordTypeInfo> getRecordTypeInfoMap(String objectApiName) {
        if(!String.isBlank(objectApiName)) {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            if(sObjectType != null) {
                //SonarQube suggestion : Use getRecordTypeInfosByDeveloperName instead of getRecordTypeInfosByName : Amey -- STARTS
                Map<String,Schema.RecordTypeInfo> rtMapByStdDevName = sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
                Map<String,Schema.RecordTypeInfo> rtByDevNameMap = new map<String,Schema.RecordTypeInfo>();
                for(Schema.RecordTypeInfo rcInf : rtMapByStdDevName.values()){
                    rtByDevNameMap.put(rcInf.getName(), rcInf);
                }
                return rtByDevNameMap;
                //SonarQube suggestion : Use getRecordTypeInfosByDeveloperName instead of getRecordTypeInfosByName : Amey -- ENDS
            }
        }
        return null;
    }  
    
    /**************************************************************************
    * Author:       Nitish Yadav
    * Date:         06/06/2022
    * Description:  Method to find if correct recordtype has been used                                                
    **************************************************************************/
	public static Map<String, Schema.RecordTypeInfo> getRecordTypeInfoMapFrmDevName(String objectApiName) {
        if(!String.isBlank(objectApiName)) {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            if(sObjectType != null) {
                return sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
            }
        }
        return null;
    }  
    
	/**************************************************************************
    * Author:       Nitish Yadav
    * Date:         06/06/2022
    * Description:  Create test Entitlements                                            
    **************************************************************************/
    public static Entitlement createEntitlements(Boolean isInsert, String entitlementName, Id accId, Id slaProcessId) {
        Entitlement testEntitlement = new Entitlement(AccountId = accId,
                                                      SlaProcessId = slaProcessId,
                                                      Name = entitlementName,
                                                      StartDate = System.today());
        if(isInsert && Entitlement.SObjectType.getDescribe().isCreateable()) {
            insert testEntitlement;
        }
        return testEntitlement;
    }
    /***************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         28/10/2022
    * Description:  This method is test data for create List of Contact Point Address 
    ****************************************************************************************/
    public static List<TermsCondition__c> createTermsConditions(Boolean doInsert, Id accId, Integer noOfRecords) {
        List<TermsCondition__c> lstTermsCondition = new List<TermsCondition__c>();
        for (integer i = 0; i < noOfRecords; i++) {
            TermsCondition__c objTC = new TermsCondition__c();
            objTC.Account__c = accId;
            objTC.ServiceName__c = 'Asda';
            objTC.Acceptance__c = True;
            lstTermsCondition.add(objTC);
        }
        if(doInsert && TermsCondition__c.SObjectType.getDescribe().isCreateable()){
            insert lstTermsCondition;
        }
        return lstTermsCondition;
    }

    /***************************************************************************************
    * Author:       Vineeth Rangamgari
    * Date:         22/11/2022
    * Description:  This method returns sub-categories of a group in Knowledge 
    ****************************************************************************************/
    public static List<String> getKnowledgeCategories(String groupName) {
        DataCategoryGroupSObjectTypePair pair = new DataCategoryGroupSObjectTypePair();
        pair.setSobject('KnowledgeArticleVersion');
        pair.setDataCategoryGroupName(groupName);
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>{ pair };
        List<DescribeDataCategoryGroupStructureResult> results = Schema.describeDataCategoryGroupStructures(pairs, false);
        List<Schema.DataCategory> dataCategories = results[0].getTopCategories();
        List<String> categories = new List<String>();
        while (dataCategories.size() > 0) {
        List<Schema.DataCategory> subCategories = new List<Schema.DataCategory>();
        for (Schema.DataCategory category : dataCategories) {
            if (category.getChildCategories().isEmpty()) {
            categories.add(category.getName());
            } else {
            subCategories.addAll(category.getChildCategories());
            }
        }
        dataCategories = subCategories;
        }
        return categories;
    }
    
	/**************************************************************************
    * Author:       Nitish Yadav
    * Date:         01/16/2023
    * Description:  Create test Permission Set Assignment                                               
    **************************************************************************/
    public static void createPermissionSetAssignment(List<User> userList, String permissionSetName) {
        List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName WITH SECURITY_ENFORCED];
        if(!permissionSet.isEmpty() && PermissionSetAssignment.SObjectType.getDescribe().isCreateable()) {
            List<PermissionSetAssignment> listOfPSAs = new List<PermissionSetAssignment>();
            for(User usr : userList) {
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = usr.Id;
                psa.PermissionSetId = permissionSet[0].Id;
                listOfPSAs.add(psa);
            }
            if(!listOfPSAs.isEmpty()) {
                insert listOfPSAs;            
            }            
        }
    }

    /**************************************************************************
    * Author:       Disharee Ray
    * Date:         17/2/2023
    * Description:  Create test Permission Set Group Assignment                                               
    **************************************************************************/
    public static void assignPermissionSetGroup(List<User> userList, String permissionSetGroupName) {
        if (Schema.sObjectType.PermissionSetGroup.isAccessible()) {
            List<PermissionSetGroup> permissionSetGroups = [SELECT Id, DeveloperName, Status FROM PermissionSetGroup WHERE DeveloperName = :permissionSetGroupName];
            if(!permissionSetGroups.isEmpty() && PermissionSetAssignment.SObjectType.getDescribe().isCreateable()) {
                List<PermissionSetAssignment> listOfPSAs = new List<PermissionSetAssignment>();
                if (permissionSetGroups[0].Status != 'Updated') {
                    Test.calculatePermissionSetGroup(permissionSetGroups[0].Id);
                }
                for(User usr : userList) {
                    PermissionSetAssignment psa = new PermissionSetAssignment();
                    psa.AssigneeId = usr.Id;
                    psa.PermissionSetGroupId  = permissionSetGroups[0].Id;
                    listOfPSAs.add(psa);
                }
                if(!listOfPSAs.isEmpty()) {
                    insert listOfPSAs;            
                }            
            }
        }
    }

    public static List<Goodwill__c> createGoodwillRecords(Integer numOfGoodwills, Id accId, Id caseId, Boolean isInsert) {
        List<Goodwill__c> listOfGoodwils = new List<Goodwill__c>();
        for(Integer i = 0; i < numOfGoodwills; i++) {
			listOfGoodwils.add(new Goodwill__c(AccountId__c = accId, CaseId__c = caseId, Voucher_Code__c = 'TESTVOUCHER' + i + 'CODE', Email__c = 'testGoodwill' + i + '@asdatest.co.uk'));			            
        }
        return listOfGoodwils;
    }
}