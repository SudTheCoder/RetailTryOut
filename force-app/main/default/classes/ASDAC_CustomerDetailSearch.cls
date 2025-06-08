/******************************************************************************
Name: ASDAC_CustomerDetailSearch
===============================================================================
Req: 
ASDAC-623 Carryover Customer Account Search
===============================================================================
Purpose:Controller Class for Customer Details search functionality
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		21 October 2022    Initial Development
******************************************************************************/
public with sharing class ASDAC_CustomerDetailSearch { 
    
	/**************************************************************************
    Purpose    : Method to find customers based upon search inputs
    Parameters : String stringifiedSearchWrapper
    Returns    : ResponseWrapper                                               
    **************************************************************************/
    @AuraEnabled
    public static ResponseWrapper getCustomersList(String stringifiedSearchWrapper) {
        ResponseWrapper respWrap;
        try {
            respWrap = new ResponseWrapper(true, '');
            SearchWrapper searchWrap = (SearchWrapper)JSON.deserialize(stringiFiedSearchWrapper, SearchWrapper.Class);
            List<Account> listOfAccounts = new List<Account>();
            
            if(String.isNotBlank(searchWrap.phone)) {
				//If phone is provided, search the customer records with the phone as primary/secondary phone. If results are found, add in the list to show on UI.
				getCustomersFromPhone(searchWrap, listOfAccounts);
            }
            
            // If email is provided, search the customer records with the email as primaryEmail. If results are found, add in the list to show on UI.
            if(String.isNotBlank(searchWrap.email)) {
                getCustomersFromEmail(searchWrap, listOfAccounts);
            }
            
            //If no results found from Phone/Email, and either FirstName, LastName or address is filled and Postal Code is empty. Show this error.
            if(listOfAccounts.isEmpty() && (String.isNotBlank(searchWrap.lastName) || String.isNotBlank(searchWrap.firstName) || String.isNotBlank(searchWrap.address)) && String.isBlank(searchWrap.postalCode)) {
				respWrap = new ResponseWrapper(true, Label.ASDAC_PostalCodeErrorCustomerSearch); 
                respWrap.hasPostalCodeError = true;
                return respWrap;
            }
            //if postal code is provided, Search on combination of postcode, lastname, firstname, HouseName
            if(listOfAccounts.isEmpty()) {
                getCustomersFromNameAndPostalCode(searchWrap, listOfAccounts);
            }
            respWrap.listOfAccounts = listOfAccounts;
            if(respWrap.listOfAccounts.size() > 2000) {
                respWrap = new ResponseWrapper(false, Label.ASDAC_TooManyResultsCustomerSearch); 
                return respWrap;             
            }
        }
        catch(Exception ex) {
			respWrap = new ResponseWrapper(false, ex.getMessage());            
        }
        return respWrap;
    }
    
	/**************************************************************************
    Purpose    : Method to find customers based upon Phone. If phone is provided, 
				 search the customer records with the phone as primary/secondary 
				 phone. If results are found, add in the list to show on UI.
    Parameters : SearchWrapper searchWrap, List<Account> listOfAccounts
    Returns    : void                                               
    **************************************************************************/
    private static void getCustomersFromPhone(SearchWrapper searchWrap, List<Account> listOfAccounts) {
		Set<Id> setOfCPPhonePrntIds = new Set<Id>();
        List<List<sObject>> listOfCustomers = [FIND :searchWrap.phone IN PHONE FIELDS
                                               RETURNING Account (Id, Name, PersonEmail, CountryCode__c, Phone, AddressLine1__pc, PostalCode__pc WHERE IsDeleted = false ORDER BY Name),
                                               ContactPointPhone (ParentId WHERE IsDeleted = false)
                                               LIMIT 2000];
        if(!listOfCustomers[0].isEmpty()) {
            listOfAccounts.addAll(((List<Account>)listOfCustomers[0]));
        }
        for(sObject sObj : listOfCustomers[1]) {
            ContactPointPhone contactPtPhone = (ContactPointPhone) sObj;
            if(contactPtPhone.ParentId != null) {
                setOfCPPhonePrntIds.add(contactPtPhone.ParentId);
            }
        }
        List<Account> listOfAccountsFromCPP = [SELECT Id, Name, PersonEmail, CountryCode__c, Phone, AddressLine1__pc, PostalCode__pc FROM Account WHERE Id IN : setOfCPPhonePrntIds AND IsDeleted = false AND Id NOT IN : listOfAccounts WITH SECURITY_ENFORCED ORDER BY Name];
        if(!listOfAccountsFromCPP.isEmpty()) {
            listOfAccounts.addAll(listOfAccountsFromCPP);
        }
    }
    
	/**************************************************************************
    Purpose    : Method to find customers based upon Email. If email is provided,
				 search the customer records with the email as primaryEmail. 
				 If results are found, add in the list to show on UI.
    Parameters : SearchWrapper searchWrap, List<Account> listOfAccounts
    Returns    : void                                               
    **************************************************************************/
	private static void getCustomersFromEmail(SearchWrapper searchWrap, List<Account> listOfAccounts) {
        List<Account> listOfAccountFromEmail = [SELECT Id, Name, PersonEmail, CountryCode__c, Phone, AddressLine1__pc, PostalCode__pc
                                                FROM Account
                                                WHERE (Loginid__c=:searchWrap.email.tolowerCase() OR PersonEmail=:searchWrap.email.tolowerCase())
                                                AND Id NOT IN : listOfAccounts
                                                AND IsDeleted = false
                                                WITH SECURITY_ENFORCED
                                                LIMIT 2000];
        if(!listOfAccountFromEmail.isEmpty()) {
            listOfAccounts.addAll(listOfAccountFromEmail);                
        }
    }
    
	/**************************************************************************
    Purpose    : Method to find customers based upon First Name/Last Name,
				 or Postal Code. 
    Parameters : SearchWrapper searchWrap, List<Account> listOfAccounts
    Returns    : void                                               
    **************************************************************************/
	private static void getCustomersFromNameAndPostalCode(SearchWrapper searchWrap, List<Account> listOfAccounts) {
        String soqlQuery = 'SELECT Id, Name, PersonEmail, CountryCode__c, Phone, AddressLine1__pc, PostalCode__pc FROM Account WHERE Id NOT IN : listOfAccounts';
        Boolean isWhereClause = false;
        if(String.isNotBlank(searchWrap.postalCode)) {
            String postalCode = searchWrap.postalCode;
            String postalCodeWithoutSpaces = postalCode.replaceAll(' ', '');
            String formattedPostcode = postalCode;
            if(postalCodeWithoutSpaces.length()>4){
                formattedPostcode = postalCodeWithoutSpaces.substring(0, postalCodeWithoutSpaces.length() - 3) + ' ' + postalCodeWithoutSpaces.substring(postalCodeWithoutSpaces.length() - 3);
            }
            isWhereClause = true;
            soqlQuery = soqlQuery + ' AND (PostalCode__pc = :formattedPostcode OR PostalCode__pc = :postalCodeWithoutSpaces)';
        }
        if(String.isNotBlank(searchWrap.lastName)) {
            isWhereClause = true;
            String lastName = searchWrap.lastName + '%';
            soqlQuery = soqlQuery + ' AND (LastName LIKE : lastName)';
        }
        if(String.isNotBlank(searchWrap.firstName)) {
            isWhereClause = true;
            String firstName = searchWrap.firstName + '%';
            soqlQuery = soqlQuery + ' AND (FirstName LIKE : firstName)';
        }
        if(String.isNotBlank(searchWrap.address)) {
            isWhereClause = true;
            String address = '%' + searchWrap.address + '%';
            soqlQuery = soqlQuery + ' AND (AddressLine1__pc LIKE : address OR AddressLine2__pc LIKE : address OR AddressLine3__pc LIKE : address OR City__pc LIKE : address OR State__pc LIKE : address OR Country__pc LIKE : address)';
        }
        soqlQuery = soqlQuery + ' AND IsDeleted = false LIMIT 2000';
        if(isWhereClause) {
            List<Account> listOfAccFrmFNLN = Database.query(soqlQuery);
            if(!listOfAccFrmFNLN.isEmpty()) {
                listOfAccounts.addAll(listOfAccFrmFNLN);               
            }
        }
    }
    public Class SearchWrapper {
        public String postalCode;
        public String lastName;
        public String address;
        public String phone;
        public String firstName;
        public String email;
        public String caseId;
        public String countryCode;
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public Boolean isSuccess;
        
        @AuraEnabled
        public String message;
        
        @AuraEnabled
        public List<Account> listOfAccounts;
        
        @AuraEnabled
        public Boolean hasPostalCodeError;
        
        public ResponseWrapper(Boolean isSuccess, String message) {
			this.isSuccess = isSuccess;
            this.message = message;
        }
    }
}