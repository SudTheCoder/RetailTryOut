/**********************************************************************************************************************
* @author        : Sapient: Sathish Thallapelly
* @date          : 2022-05-20
* @description   : ASDAC_HTTPCalloutFrameworkException is thecustom exception class with error messages
**********************************************************************************8************************************/
public class ASDAC_HTTPCalloutFrameworkException extends Exception {
    public static final String CUSTOM_METADATA_NOT_FOUND = 'Unable to query custom metadata. Make sure you\'ve passed the correct developer name.';
    public static final String MOCK_NOT_FOUND = 'Response Mock not found for the current request URL';
    public static final String CONTINUATION_LIMIT_EXCEEDED = 'You can add upto ' + ASDAC_HTTPCalloutAsyncService.CONTINUATION_LIMIT + ' callouts in a single continuation request.';
}