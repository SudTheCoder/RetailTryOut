/******************************************************************************
@author:      Sapient: Dependra Singh
@date:        04 April 2022
@description: Logger class for logging Custom Log records
*******************************************************************************/
public with sharing class ASDAC_Logger {
    public class CustomException extends Exception{}
    private static final string DEBUGTYPE = 'Debug';
    private static final string EXCEPTIONTYPE = 'Exception';
    // Static Logs list populated during an execution,
    // then inserted at end of execution.
    private static List<Log__c> logs = new List<Log__c>();
    // Custom Setting that contains:
    // - whether Logging is enabled for current profile
    // - the Crypto Key used for encrypting Messages and Stacktrace
    private static LogManagement__c logManage = LogManagement__c.getInstance(UserInfo.getProfileId());
    private static integer sequence = 0;
    private static boolean loggingEnabled = isLoggingEnabled();
    private static string executionId;
    private static string correlationId;
    /******************************************************************************
    @author    		Sapient: Dependra Singh
    @date      		04 April 2022
    @param			String - a debug log message
    @return			null
    @description 	Saves a given message as a Debug Log record if Logging
    is enabled.
    Version : 
    *******************************************************************************/
    public static void logDebug(String message) {
        createLog(DEBUGTYPE, message, '', null, null,null);
    }
    /******************************************************************************
    @author    		Sapient: Dependra Singh
    @date      		04 April 2022
    @param			Exception - an Exception object
    @return			null
    @description 	Converts the given Exception into an Exception Log record if
    Logging is enabled.
    *******************************************************************************/
    public static void logException(Exception ex){
        createLog(EXCEPTIONTYPE, ex.getMessage(), ex.getTypeName(),ex, null,null);
    }
    /******************************************************************************
    @author:        Sapient: Dependra Singh
    @date:          04 April 2022
    @param			String - an error log message
    @return			null
    @description 	Saves a given message as an Error Log record if
    Logging is enabled.
    *******************************************************************************/
    public static void logException(String exceptionMessage){
        CustomException ex = new CustomException(exceptionMessage);
        logException(ex);
    }
    /******************************************************************************
    @author:        Sapient: Dependra Singh
    @date:          04 April 2022
    @param			List<Log__c> - a list of Log records
    @return			null
    @description 	Writes all the given Log records to the database if
    Logging is enabled.
    *******************************************************************************/
    public static void writeLogsToDatabase(List<Log__c> logs){
        //if debug custom setting is on
        if(loggingEnabled  && !logs.isEmpty()){
            insert logs;
            System.debug('logid::: '+logs);
        }
    }
    /******************************************************************************
    @author:        Sapient: Dependra Singh
    @date:          04 April 2022
    @param			List<Log__c> - a list of Log records
    @return			null
    @description 	Writes all the given Log records to the database if
    Logging is enabled.
    *******************************************************************************/
    public static void writeLogsToDatabase(){
        System.debug('logs::: '+logs);
        if(!logs.isEmpty())
        writeLogsToDatabase(logs);
        logs.clear();
    }
    /******************************************************************************
    @author:        Sapient: Dependra Singh
    @date:          04 April 2022
    @param			String logType, String message,String exceptionType, Exception ex
    @return			String
    @description 	Writes all the given Log records to the database if
    Logging is enabled.
    *******************************************************************************/
    private static void createLog(String logType, String message,String exceptionType, Exception ex, String exceptionSource,String apexClassName) {
        if(!loggingEnabled){
           	return;
        }
        string strSecureStackTrace =  '';
        if(ex != null){
             strSecureStackTrace = getStackTrace(ex);
        }
        Log__c log = new Log__c(
            ExecutionId__c = getExecutionId(),
            StackTrace__c = strSecureStackTrace,
            Limits__c = getLimits(),
            Message__c = message,
            //Message__c = secureMessage(message),// Currently, we are not encrypting message.
            LogType__c = logType,
            User__c = Userinfo.getUserId(),
            ExceptionType__c = exceptionType,
            Sequence__c = sequence + '_' + executionId,
            Source__c = exceptionSource,
            ApexClass__c = apexClassName,
            Correlation_Id__c=correlationId
        );
        System.debug('ex::: '+ex);
        if(ex != null){
           logs.add(log);
        } 
        sequence++;
    }
    /******************************************************************************
    @author    		Sapient: Dependra 
    @date			04 April 2022
    @param
    @return			String
    @description 	Method is used to get the execution Id as string
    *******************************************************************************/
    private static String getExecutionId(){
        if(executionId != null && executionId != ''){
            return executionId;
        }
        else {
            executionId = 'ExId_' + String.ValueOf(System.currentTimeMillis());
            return executionId;
        }
    }
    /******************************************************************************
    @author    		Sapient: Dependra 
    @date			04 April 2022
    @param			String message
    @return			Boolean
    @description 	Method is used to encrypt the string(debug or error)
    *******************************************************************************/
    @testVisible
    private static String secureMessage(String message){
    	// Get AES Key
        Blob cryptoKey;
        if (logManage != null) {
            cryptoKey =  Blob.valueOf(logManage.CryptoKey__c);
        }
        else {
            throw new CustomException('No Log Management Custom Setting found');
        }
        // Generate the data to be encrypted.
        Blob data = Blob.valueOf(message);
        // Encrypt the data and have Salesforce.com generate the initialization vector
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
        // Return encrypted data as String
        return EncodingUtil.base64Encode(encryptedData);
    }
    /******************************************************************************
    @author    		Sapient: Dependra 
    @date			04 April 2022
    @param
    @return			Boolean
    @description 	Method is used to get the status of logging from custom setting.
    *******************************************************************************/
    // Assume Logging is false by default
    private static Boolean isLoggingEnabled() {
        if (logManage != null) {
            return logManage.EnableLogging__c;
        }
        else {
            throw new CustomException('No Log Management Custom Setting found');
        }
    }
    /******************************************************************************
    @author    		Dependra
    @date			04 April 2022
    @param			Exception ex
    @return			null
    @description 	Method id used to get stack trace string.
    *******************************************************************************/
    private static String getStackTrace(Exception ex ) {
        String stackTrace = ex.getStackTraceString();
        //Commented by Dependra
        /*
        List<String> stackLines = stackTrace.split('\n');
        stacklines.remove(0);
        stacklines.remove(stackLines.size()-1);
        stackTrace  = string.join(stackLines ,' -> ');
        */
        return stackTrace;
    }
    /******************************************************************************
    @author    		Sapient: Dependra 
    @date			04 April 2022
    @param
    @return			String
    @description 	Method is used toget the limit of apex in one instance.
    *******************************************************************************/
    private static string getLimits(){
        string limitstring = '';
        limitstring += 'Query Limits: '+ Limits.getQueries() + '/' + Limits.getLimitQueries() +'\n';
        limitstring += 'DML Rows Limits: '+Limits.getDMLRows()+'/' + Limits.getLimitDMLRows()+'\n';
        limitstring += 'Heap Size Limits: '+Limits.getHeapSize()+'/' +Limits.getLimitHeapSize()+'\n';
        limitstring += 'Query Return Limits: '+Limits.getQueryRows()+'/' + Limits.getLimitQueryRows()+'\n';
        limitstring += 'Aggregate Queries: '+Limits.getAggregateQueries()+'/' + Limits.getLimitAggregateQueries()+ '\n';
        limitstring += 'Callouts: '+Limits.getCallouts()+'/' +Limits.getLimitCallouts()+ '\n';
        limitstring += 'CPU Time: '+Limits.getCpuTime()+'/' +Limits.getLimitCpuTime()+ '\n';
        limitstring += 'DML Statements: '+Limits.getDMLStatements()+'/' +Limits.getLimitDMLStatements()+ '\n';
        limitstring += 'Email Invocations: '+Limits.getEmailInvocations()+'/' +Limits.getLimitEmailInvocations()+ '\n';
        limitstring += 'Future Calls: '+Limits.getFutureCalls()+'/' +Limits.getLimitFutureCalls()+ '\n';
        limitstring += 'Query Locator Rows: '+Limits.getQueryLocatorRows() +'/'+Limits.getLimitQueryLocatorRows()+ '\n';
        return limitstring;
    }
     /******************************************************************************
    @author    		Sapient: Dependra 
    @date			04 April 2022
    @param
    @return			String
    @description 	Method is used to get the limit of apex in one instance.
    *******************************************************************************/
    public static string getActualErrorMessage(string strErrorMessage){
        //Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error.//
        String errorMsg = strErrorMessage;
        if(errorMsg.contains(ASDAC_GlobalConstants.FIELDCUSTOMVALIDATIONEXCEPTION)){
            errorMsg = errorMsg.substringBetween(ASDAC_GlobalConstants.FIELDCUSTOMVALIDATIONEXCEPTION + ', ', ': ');
        }
        else if(errorMsg.contains(ASDAC_GlobalConstants.REQUIREDFIELDMISSING)){
            errorMsg = errorMsg.substringBetween(ASDAC_GlobalConstants.REQUIREDFIELDMISSING + ', ', ': ');
        }
        return errorMsg;
    }
    /******************************************************************************
    @author    		Sapient: Dependra 
    @date      		04 April 2022
    @param			string strErrorMessage
    @return			void
    @description 	Method is used to show valid error message instead of Script throw exception.
    *******************************************************************************/
    public static void getAuraHandledException(string strErrorMessage){
        AuraHandledException e = new AuraHandledException(strErrorMessage);
        e.setMessage(strErrorMessage);
        throw e;
    }
    
    /******************************************************************************
    @author    		Sapient: Dependra 
    @date      		04 April 2022
    @param			String - an error log message
					String - source of exception
    @return			null
    @description 	Saves a given message as an Error Log record if
    				Logging is enabled.
    *******************************************************************************/
    public static void logException(String exceptionMessage, String exceptionSource){
        CustomException ex = new CustomException(exceptionMessage);
        logException(ex, exceptionSource,null, null);
    }
    
   /******************************************************************************
    @author    		Sapient: Dependra 
    @date      		04 April 2022
    @param			String - an error log message
					String - source of exception
    @return			null
    @description 	Saves a given message as an Error Log record if
    				Logging is enabled.
    *******************************************************************************/
    public static void logException(String exceptionMessage, String exceptionSource,String apexClassName){
        CustomException ex = new CustomException(exceptionMessage);
        logException(ex, exceptionSource,null, apexClassName);
    }
    /******************************************************************************
    @author    		Sapient: Dependra 
    @date      		04 April 2022
    @param			Exception - an Exception object
					String - source of exception
    @return			null
    @description 	Converts the given Exception into an Exception Log record if
    				Logging is enabled.
    *******************************************************************************/
    public static void logException(Exception ex, String exceptionSource, String message, String apexClassName){
        String exceptionMsg;
        if(String.isNotBlank(message)) 
            exceptionMsg = message;
        else
            exceptionMsg = ex.getMessage();
        createLog(EXCEPTIONTYPE, exceptionMsg, ex.getTypeName(),ex, exceptionSource,apexClassName);
    }
     /******************************************************************************
    @author    		Sapient: Dependra 
    @date      		04 April 2022
    @param			String - a debug log message
					String - source of error
    @return			null
    @description 	Saves a given message as a Debug Log record if Logging
    				is enabled.
    *******************************************************************************/
    public static void logDebug(String message, String errorSource) {
        createLog(DEBUGTYPE, message,  errorSource);
    }
    /******************************************************************************
    @author:      Sapient: Dependra Singh
    @date:        04 April 2022
    @param			String logType, String message,String exceptionType, String exceptionLine , Exception ex
    @return			String
    @description 	Writes all the given Log records to the database if
    Logging is enabled.
    *******************************************************************************/
    private static void createLog(String logType, String message, String exceptionSource) {
        if(!loggingEnabled){
           	return;
        }
        string strSecureStackTrace =  '';
        Log__c log = new Log__c(
            ExecutionId__c = getExecutionId(),
            StackTrace__c = strSecureStackTrace,
            Limits__c = getLimits(),
            Message__c = message,
            //Message__c = secureMessage(message),// Currently, we are not encrypting message.
            LogType__c = logType,
            User__c = Userinfo.getUserId(),
            ExceptionType__c = exceptionType,
            Sequence__c = sequence + '_' + executionId,
            Source__c = exceptionSource,
            Correlation_Id__c=correlationId
            
        );
           logs.add(log);
        sequence++;
    }
 
}