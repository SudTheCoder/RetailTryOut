@isTest
public class ASDAC_RetrieveOrderDetailsService_Test {
    /**************************************************************************************************************
    * @author       : Akshay Singh Shekhawat
    * @date         : 2022-11-11
    * @description  : Initializing constants
    ***************************************************************************************************************/ 
    private static final String CUSTOM_METADATA_NAME = 'Stub_Callout_Demops';
    private static String RESPONSE_BODY = '';
    
    /**************************************************************************************************************
    * @author       : Akshay Singh Shekhawat
    * @date         : 2022-11-11
    * @description  : Testing with predefined custom metadata record
    ***************************************************************************************************************/ 
    @testSetup static void setup() {
        //Inserting Case records
        List<Case> lstCase = new List<Case>();
        lstCase.add(new Case(Status ='New', Priority = 'Medium', Origin = 'Email', OrderId__c = 'AP-202205160031'));
        Database.insert(lstCase);
    }
    
    @isTest
    public static void testWithCustomMetadata() {
        Test.startTest();
        List<Case> lstCase = [SELECT Id,OrderId__c FROM Case LIMIT 1];
        ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper rqstHelperWrapper = new ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper();
        rqstHelperWrapper.recordId = lstCase[0].Id;
        rqstHelperWrapper.sObjectName = 'Case';
        RESPONSE_BODY = JSON.serialize(rqstHelperWrapper);
        Test.setMock(HttpCalloutMock.class, new ASDAC_OrderDetailsServiceMock_Test());
        ASDAC_RetrieveOrderDetailsService orderDetailServ = new ASDAC_RetrieveOrderDetailsService();
        ASDAC_IntegrationUtility.ResultWrapper resultWrap = orderDetailServ.doCallout(ASDAC_IntegrationMetadata__mdt.getInstance('Stub_Callout_Demops'), RESPONSE_BODY);
        Test.stopTest();
        System.assertEquals(false, resultWrap.isSuccess, 'Is Success is true');
    }
}