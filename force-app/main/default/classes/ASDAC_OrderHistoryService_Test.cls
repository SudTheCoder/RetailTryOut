@isTest
public class ASDAC_OrderHistoryService_Test {
    /**************************************************************************************************************
* @author       : Akshay Singh Shekhawat
* @date         : 2022-11-11
* @description  : Initializing constants
***************************************************************************************************************/ 
    private static final String CUSTOM_METADATA_NAME = 'Order_History_Stub_Callout_Demops';
    private static String RESPONSE_BODY = '';
    
    @isTest
    public static void testWithCustomMetadata() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ASDAC_OrderHistoryServiceMock_Test());
        ASDAC_OrderHistoryService orderHistoryService = new ASDAC_OrderHistoryService();
        ASDAC_IntegrationUtility.ResultWrapper resultWrap = orderHistoryService.doCallout(ASDAC_IntegrationMetadata__mdt.getInstance(CUSTOM_METADATA_NAME), '');
        ASDAC_OrderHistoryService.createRequest('');//Added for coverage
        Test.stopTest();
        System.assertEquals(true, resultWrap.isSuccess, 'Is Success is true');
    }
}