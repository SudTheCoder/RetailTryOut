/******************************************************************************
Name: ASDAC_CreateNewCustomerController
===============================================================================
Req: 
ASDAC-895 No Results Returned from Search / Create New Customer Account
ASDAC-892 Customer Account Creation Duplication Checks
===============================================================================
Purpose:Controller Class for New Customer Functionality
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		06 July 2022    Initial Development
2.0       Disharee Ray          14-April-2023   ASDAC-9056 Customer Account Creation Manually
******************************************************************************/
public with sharing class ASDAC_CreateNewCustomerController {  
	/**************************************************************************
    Purpose    : find Duplicates and create new customer if no duplicates  
    Parameters : Account newCustomer - Customer Account Instance
    Returns    : ResponseWrapper                                               
    **************************************************************************/ 
    @AuraEnabled
    public static ResponseWrapper checkDuplicatesAndCreate(Account newCustomer) {
        String postcodeWithoutSpaces=newCustomer.PostalCode__pc.replaceAll(' ','');
        String formattedPostcode = newCustomer.PostalCode__pc;
        if(postcodeWithoutSpaces.length()>4){
            formattedPostcode = postcodeWithoutSpaces.substring(0, postcodeWithoutSpaces.length() - 3) + ' ' + postcodeWithoutSpaces.substring(postcodeWithoutSpaces.length() - 3);
        }
        ResponseWrapper resWrap;
        try {
            List<Account> listOfAccounts = new List<Account>();            
            listOfAccounts = [
                SELECT Id, Name, Salutation, PersonEmail, Phone, AddressLine1__pc, PostalCode__pc, Status__c, CountryCode__c, Postcode__c 
                FROM Account 
                WHERE IsPersonAccount = true 
                AND (
                    PersonEmail = :newCustomer.PersonEmail 
                    OR Phone = :newCustomer.Phone 
                    OR (
                        (PostalCode__pc = :formattedPostcode OR PostalCode__pc = :postcodeWithoutSpaces)
                        AND (
                            FirstName = :newCustomer.FirstName__pc 
                            OR LastName = :newCustomer.LastName__pc
                        )
                    )
                ) 
                WITH SECURITY_ENFORCED LIMIT 50
            ];
            if(!listOfAccounts.isEmpty()) {
                // if duplicates found then do not create new customer and return duplicates from here.
				resWrap = new ResponseWrapper(true, '');
                resWrap.isDuplicateExists = true;
                resWrap.listOfAccounts = listOfAccounts;
                return resWrap;
            }
            return createNewCustomer(newCustomer); // if no duplicates found create a new Customer record and Contact point phone and emails as well
        }
        catch(Exception ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_CreateNewCustomerController');
            ASDAC_Logger.writeLogsToDatabase();
			resWrap = new ResponseWrapper(false, ex.getMessage());
        }
        return resWrap;
    }
    
	/**************************************************************************
    Purpose    : Create Customer Account and related ContactPointPhone,
				 ContactPointAddress.
    Parameters : Account newCustomer - Customer Account Instance
    Returns    : ResponseWrapper                                               
    **************************************************************************/ 
    @AuraEnabled
    public static ResponseWrapper createNewCustomer(Account newCustomer) {
        ResponseWrapper resWrap;
        try {
            newCustomer.PostalCode__pc=newCustomer.PostalCode__pc.replaceAll(' ','');
            newCustomer.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId('Account', 'PersonAccount');
            newCustomer.AccountRegistrationStatus__c = 'Manual';
            if(Account.SobjectType.getDescribe().isCreateable()) {
				insert newCustomer;
                resWrap = new ResponseWrapper(true, '');
                resWrap.isDuplicateExists = false;
                resWrap.listOfAccounts = new List<Account>{newCustomer};                
            }
            else {
                resWrap = new ResponseWrapper(false, String.format(Label.ASDAC_CreateRecordError, new List<Object>{'Account'}));    
            }
        }
        catch(Exception ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_CreateNewCustomerController');
            ASDAC_Logger.writeLogsToDatabase();
            resWrap = new ResponseWrapper(false, ex.getMessage());
        }
        return resWrap;
    }
    
     /**
   * ****************************************************************************************************
   * @param case record ID and the account detail which needs to be used to create Customer Account
   * @description method to create a customer account & attach the specific case with the Account
   * Returns: ResponseWrapper  
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=false)
  public static ResponseWrapper createCustomerAccount(Account accountDetail) {
    ResponseWrapper acrwrapper;
    List<Case> caseListToBeUpdated= new List<Case>();
    try {
     if(accountDetail!=null){
      List<Account> existingAccountDetail=[SELECT Id,Name FROM Account WHERE RecordType.IsPersonType=true AND Loginid__c=:accountDetail.PersonEmail];
      if(existingAccountDetail.size()>0){
       accountDetail.Id= existingAccountDetail[0].Id;   
      }else{
       accountDetail.Loginid__c=accountDetail.PersonEmail;
       accountDetail.Source__c=ASDAC_GlobalConstants.STRING_CONTACT_CENTRE;
       accountDetail.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ASDAC_GlobalConstants.STRING_PERSON_ACCOUNT).getRecordTypeId();
       accountDetail.AccountRegistrationStatus__c=ASDAC_GlobalConstants.STRING_MANUAL;
       insert accountDetail;  
      }           
     Contact con=[Select Id, Name FROM Contact WHERE AccountId=:accountDetail.Id];
     for(Case cs: [SELECT Id, ContactId, AccountId, SuppliedEmail FROM Case WHERE SuppliedEmail =:accountDetail.PersonEmail AND ContactId=NULL]){
       cs.ContactId=con.Id;
       cs.AccountId=accountDetail.Id;
       cs.SuppliedEmail=null;
       caseListToBeUpdated.add(cs);
     }
     if(!caseListToBeUpdated.isEmpty()){
       update caseListToBeUpdated;      
     }
     acrwrapper = new ResponseWrapper(true, System.Label.ASDAC_AccountCaseLinkingSuccessMessage);
    }
   }catch (exception e) {
    ASDAC_Logger.writeLogsToDatabase();
    acrwrapper = new ResponseWrapper(false,e.getMessage());
   }
   return acrwrapper;
  }
    
	/**********************************************************************************
   	* @author                       : Nitish Yadav
   	* @date                         : 06 July 2022
   	* @description                  : wrapper class for response
   	**********************************************************************************/
	public class ResponseWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public Boolean isDuplicateExists;
        @AuraEnabled public List<Account> listOfAccounts;
        @AuraEnabled public String message;
		ResponseWrapper(Boolean isSuccess, String message) {
			this.isSuccess = isSuccess;
          	this.message = message;
        }
	}
}