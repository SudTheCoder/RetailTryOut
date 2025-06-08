/**********************************************************************************
 * @author                       : Sanskriti Vijay
 * @date                         : 16-Aug-2023
 * @description                  : Error Handler for Integration Callouts
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Sanskriti Vijay              16-Aug-2023      	Error Handler framework re-design
 ***************************************************************************************************/
public with sharing  class ASDAC_ErrorHandler {
    
    /**
  * ****************************************************************************************************
  * @param mdtName : integration metadata record
  * @param statusCode : HTTP response status code
  * @description method to return a boolean if an exception is needed to be thrown
  * ****************************************************************************************************
  */
   public static Boolean checkForException(String mdtName, Integer statusCode){
       if(statusCode >= 400){
           return true;
       }
       else{
           List<ASDAC_CalloutExceptionMessage__mdt> exceptionMsgMdt = [Select id From ASDAC_CalloutExceptionMessage__mdt 
                                                                       where IntegrationMetadata__r.DeveloperName =: mdtName 
                                                                       and StatusCode__c =:statusCode Limit 1];
           if(!exceptionMsgMdt.isEmpty()){
               return true;
           } else{
               return false;
           }
       }
   }
    /**
  * ****************************************************************************************************
  * @param statusCode : HTTP response status code
  * @description method to return a boolean if an empty response is received
  * ****************************************************************************************************
  */
   public static Boolean checkForEmptyResponse( Integer statusCode){
       if(statusCode == 204){
           return true;
       }
       return false;
   }
   
  /**
  * ****************************************************************************************************
  * @param mdtName : integration metadata record
  * @param statusCode : HTTP response status code
  * @description : method to return the custom exception msg queried from metadata records
  * ****************************************************************************************************
  */
   public static String getErrorMessage(String mdtName, Integer statusCode){
       String exMessage='';
       List<ASDAC_CalloutExceptionMessage__mdt> exceptionMsgMdt = [Select id,CustomErrorMessage__c From ASDAC_CalloutExceptionMessage__mdt 
                                                                   where IntegrationMetadata__r.DeveloperName =: mdtName 
                                                                   and StatusCode__c =:statusCode Limit 1];
       if(!exceptionMsgMdt.isEmpty()){
           exMessage = exceptionMsgMdt[0].CustomErrorMessage__c;
       } else{
           exMessage = ASDAC_CalloutExceptionMessage__mdt.getInstance('ASDAC_GenericExceptionMessage').CustomErrorMessage__c;   
       }
       
       Map<String, Object> messageBody = new Map<String, Object> {
           'statusCode' => statusCode,
           'message' => exMessage
       };
       return JSON.serialize(messageBody); 
   }
 
   public class CustomCalloutException extends Exception {
       @AuraEnabled
       public Integer statusCode;
       
       public CustomCalloutException(ASDAC_IntegrationUtility.ResultWrapper result) {
           this(result.strData);
           statusCode = result.statusCode;
       }
   }
   
   public class CustomPaymentException extends Exception {   
   }
   
}