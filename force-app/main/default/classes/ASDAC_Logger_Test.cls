@isTest
public with sharing class ASDAC_Logger_Test {
    public static final String APEX_CLASS_ID_MISSING =  'Apex class is missing';
    public static final String SOURCE_OF_EXCEPTION =  'Source of Exception';
    @isTest
    static void testLogandDebugExceptionScenarios() {
        try {
           LogManagement__c objCs= new LogManagement__c();
           objCs.EnableLogging__c=true;
           insert objCs; 
        } catch (Exception e) {
            ASDAC_Logger.logException(e);
        } 
        finally{
            if(LogManagement__c.getInstance(UserInfo.getProfileId()).EnableLogging__c){
                Log__c objLog = new Log__c();
                objLog.ApexClass__c='ASDAC_ContactPointAddress';
                insert objLog;
                ASDAC_Logger.writeLogsToDatabase();    
                ASDAC_Logger.logDebug(APEX_CLASS_ID_MISSING);
                ASDAC_Logger.logDebug(APEX_CLASS_ID_MISSING, SOURCE_OF_EXCEPTION);
                ASDAC_Logger.logException(APEX_CLASS_ID_MISSING);
                ASDAC_Logger.logException(APEX_CLASS_ID_MISSING, SOURCE_OF_EXCEPTION);
                ASDAC_Logger.logException(APEX_CLASS_ID_MISSING, SOURCE_OF_EXCEPTION, objLog.ApexClass__c);
            }
        }  

        test.startTest();

        List<Log__c> logList = [SELECT Message__c FROM Log__c];
        test.stopTest();

        System.assertEquals(1,logList.size(),'Log list size must be 1');
    } 
    
    @isTest
    static void testGetAuraHandledException() {       
        try {
            ASDAC_Logger.getAuraHandledException('to show valid error message instead of script throw exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('to show valid error message instead of script throw exception'));
            
        }
    } 
    
    @isTest
    static void testGetActualErrorMessageWhenFieldCustomValidation() { 
         String errorMsg ='Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error';
         if(errorMsg.contains(ASDAC_GlobalConstants.FIELDCUSTOMVALIDATIONEXCEPTION)){
            ASDAC_Logger.getActualErrorMessage(errorMsg);
         }
    }  
    
    @isTest
    static void testGetActualErrorMessageWhenRequiredFieldMissing() {   
         String errorMsg1 ='Added check for REQUIRED_FIELD_MISSING to return user friendly error';
         if(errorMsg1.contains(ASDAC_GlobalConstants.REQUIREDFIELDMISSING)){
            ASDAC_Logger.getActualErrorMessage(errorMsg1);
        }
    } 
    @isTest
    static void testSecureMessage(){
        String msgtoSecure ='Message to Secure';
        LogManagement__c lgm = new LogManagement__c();
        lgm.CryptoKey__c =  '00000000000000000000000000000000';
        insert lgm;
        test.startTest();
        ASDAC_Logger.secureMessage(msgtoSecure);
        test.stopTest();
    }
}