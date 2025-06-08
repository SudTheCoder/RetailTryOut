/******************************************************************************
Name: ASDAC_CaseCustomerSearch
===============================================================================
Req: 
ASDAC-4949 Search cases tab
===============================================================================
Search Customer From Case Number
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		21 Oct 2022     Initial Development
******************************************************************************/
public with sharing class ASDAC_CaseCustomerSearch {
    
	/**************************************************************************
    Purpose    : find Customer and case details by Case Number
    Parameters : String caseNumber - Case Number linked with Customer
    Returns    : ResponseWrapper                                               
    **************************************************************************/ 
    @AuraEnabled
    public static ResponseWrapper getCaseWithCustomerDetails(String caseNumber) {
        ResponseWrapper resp;
        try {
            resp = new ResponseWrapper(true, '');
			resp.listOfCases = new List<Case>();
            for(Case cse : [SELECT CaseNumber,AccountId, Account.Name, Account.PersonEmail, 
                            Account.CountryCode__c, Account.Phone, Account.AddressLine1__pc, 
                            Account.PostalCode__pc
                            FROM Case WHERE CaseNumber = :caseNumber WITH SECURITY_ENFORCED LIMIT 1]) {
				resp.listOfCases.add(cse);
			}
        }
        catch(Exception ex) {            
            resp = new ResponseWrapper(false, ex.getMessage());
        }
        return resp;                    
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public List<Case> listOfCases;
        
        public ResponseWrapper(Boolean isSuccess, String message) {
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }
}