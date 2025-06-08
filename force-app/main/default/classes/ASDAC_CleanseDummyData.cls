/************************************************************************************
 * Class Name	: ASDAC_CleanseDummyData
 * Developer	:  Sai
 * Created Date	: 04/26/2022
 * Purpose		: To delete dummy records from the org
 * Reference	: ASDAC-642
 * **********************************************************************************/
//SonarQube suggestion : Added with Sharing : Amey -- STARTS
public with sharing class ASDAC_CleanseDummyData {
//SonarQube suggestion : Added with Sharing : Amey -- ENDS
	public static void cleanseData() {
        
    	//fetch date from custom setting
        ASDAC_ContactCentreSetting__c cstg = ASDAC_ContactCentreSetting__c.getInstance();
        Date creationDate = cstg.CreationDate__c;
        if(creationDate == null) {
        	System.debug('Creation Date is not set in the custom setting');
        }
        try {
            List<Case> caseList = [SELECT Id FROM Case WHERE CreatedDate <= :creationDate];
            if(!caseList.isEmpty()) {
            	delete caseList;
            }
            List<contact> conList = [SELECT Id, Name FROM contact WHERE CreatedDate < =:creationDate];
            if(!conList.isEmpty()) {
            	delete conList ;
            }
            List<Entitlement> entitlementList = [SELECT Id FROM Entitlement WHERE CreatedDate < =:creationDate]; 
            if(!entitlementList.isEmpty()) {
            	delete entitlementList;
            }
            List<Account> accountList = [SELECT Id FROM Account WHERE CreatedDate < =:creationDate];
            if(!accountList.isEmpty()){
                delete accountList;
            }
            List<QuickText> qtList = [SELECT Id FROM QuickText WHERE CreatedDate < =:creationDate];
            if(!qtList.isEmpty()){
                delete qtList;
            }
            List<EmailMessage> emList = [SELECT Id FROM EmailMessage WHERE CreatedDate < =:creationDate];
            if(!emList.isEmpty()){
                delete emList;
            }
            List<Macro> macroList = [SELECT Id FROM Macro WHERE CreatedDate < =:creationDate];
            if(!macroList.isEmpty()){
                delete macroList;
            }
        }
		catch( exception e){
			System.debug('Exception deleting the dummy data: ' + e.getMessage());
		}
    }
}