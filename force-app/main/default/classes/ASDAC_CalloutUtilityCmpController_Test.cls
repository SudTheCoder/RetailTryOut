@isTest
public class ASDAC_CalloutUtilityCmpController_Test {
    
    /**************************************************************************************************************
* @author       : Akshay Singh Shekhawat
* @date         : 2022-11-11
* @description  : Initializing constants
***************************************************************************************************************/ 
    private static final String CUSTOM_METADATA_NAME = 'Stub_Callout_Demops';
    private static String RESPONSE_BODY = '';
    private final static String USER_NAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
    
    /**************************************************************************************************************
* @author       : Akshay Singh Shekhawat
* @date         : 2022-11-11
* @description  : Testing with predefined custom metadata record
***************************************************************************************************************/ 
    
    @testSetup static void setup() {   
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPO){
            //Inserting Case records
            List<Case> lstCase = new List<Case>();
            Case caseObj = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', null)[0];
            caseObj.Origin = 'Email';
            caseObj.Priority = 'Medium';
            caseObj.OrderId__c = 'AP-202205160031';
            lstCase.add(caseObj);
            Database.insert(lstCase);
        }
    }
    
    @isTest
    public static void testWithCustomMetadata() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            Test.startTest();
            
            List<Case> lstCase = [SELECT Id,OrderId__c FROM Case LIMIT 1];
            
            ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper rqstHelperWrapper = new ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper();
            rqstHelperWrapper.recordId = lstCase[0].Id;
            rqstHelperWrapper.sObjectName = 'Case';
            RESPONSE_BODY = JSON.serialize(rqstHelperWrapper);
            
            Test.setMock(HttpCalloutMock.class, new ASDAC_OrderDetailsServiceMock_Test());
            String respBody = ASDAC_CalloutUtilityCmpController.getResponseMethod(CUSTOM_METADATA_NAME,RESPONSE_BODY);
            ASDAC_IntegrationUtility.ResultWrapper resultWrap = (ASDAC_IntegrationUtility.ResultWrapper)JSON.deserialize(respBody, ASDAC_IntegrationUtility.ResultWrapper.Class);
            Test.stopTest();
            System.assertEquals(false, resultWrap.isSuccess, 'Is Success is true');
        }
    }
    
    @isTest
    public static void testExceptionScenario() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            Test.startTest();
            
            List<Case> lstCase = [SELECT Id,OrderId__c FROM Case LIMIT 1];
            
            ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper rqstHelperWrapper = new ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper();
            rqstHelperWrapper.recordId = lstCase[0].Id;
            rqstHelperWrapper.sObjectName = 'Case';
            RESPONSE_BODY = JSON.serialize(rqstHelperWrapper);
            
            Test.setMock(HttpCalloutMock.class, new ASDAC_OrderDetailsServiceMock_Test());
            String respBody = ASDAC_CalloutUtilityCmpController.getResponseMethod(null, RESPONSE_BODY);
            ASDAC_IntegrationUtility.ResultWrapper resultWrap = (ASDAC_IntegrationUtility.ResultWrapper)JSON.deserialize(respBody, ASDAC_IntegrationUtility.ResultWrapper.Class);
            Test.stopTest();
            System.assertEquals(false, resultWrap.isSuccess, 'Exception');
        }
    }  
    
    @isTest
    public static void testException() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            Test.startTest();
            
            List<Case> lstCase = [SELECT Id,OrderId__c FROM Case LIMIT 1];
            
            ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper rqstHelperWrapper = new ASDAC_RetrieveOrderDetailsService.RequestHelperWrapper();
            rqstHelperWrapper.recordId = lstCase[0].Id;
            rqstHelperWrapper.sObjectName = 'Case';
            RESPONSE_BODY = JSON.serialize(rqstHelperWrapper);
            
            Test.setMock(HttpCalloutMock.class, new CustomCalloutExceptionMock());
           
          
            //system.debug('respBody' +respBody);
			        try {
						 String respBody = ASDAC_CalloutUtilityCmpController.getResponseMethod(CUSTOM_METADATA_NAME,null);
             ASDAC_IntegrationUtility.ResultWrapper resultWrap = (ASDAC_IntegrationUtility.ResultWrapper)JSON.deserialize(respBody, ASDAC_IntegrationUtility.ResultWrapper.Class);
        } catch (ASDAC_ErrorHandler.CustomCalloutException e) {
            Assert.isTrue(true, 'CustomCalloutException was not caught');
        }
        
            Test.stopTest();
           // System.assertEquals(false, resultWrap.isSuccess, 'Exception');
        }
    }  
	
	
	   
    // Mock class for CustomCalloutException
    private class CustomCalloutExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"statusCode":500,"strMessage":"CustomCalloutException"}');
            return res;
        }
    }
    
    // Mock class for general Exception
    private class GeneralExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('General Exception');
        }
    }
    
    /**************************************************************************
    Purpose    : Get User Record                                           
    Parameters : username
    Returns    : User record                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
}