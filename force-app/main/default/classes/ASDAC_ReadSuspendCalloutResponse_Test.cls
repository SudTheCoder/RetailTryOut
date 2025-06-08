@IsTest
public with sharing class ASDAC_ReadSuspendCalloutResponse_Test { 
    @IsTest
    static void testReadSuspendCalloutErrorResponse() {
        String status = 'Failed';
        String errorCode = '123';
        String errorDescription = 'Invalid request';
        String mockJsonResponse = '{"status":"' + status + '","errorCode":"' + errorCode + '","errorDescription":"' + errorDescription + '"}';
        List<String> errorResponse = new List<String>{mockJsonResponse};
        List<ASDAC_SuspendAccountCalloutResponse> result = ASDAC_ReadSuspendCalloutResponse.readSuspendCalloutErrorResponse(errorResponse);

        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(1, result.size(), 'The result size should be 1');
        System.assertEquals(status, result[0].status, 'The status should be ' + status);
        System.assertEquals(errorCode, result[0].errorCode, 'The errorCode should be ' + errorCode);
        System.assertEquals(errorDescription, result[0].errorDescription, 'The errorDescription should be ' + errorDescription);
    }
}