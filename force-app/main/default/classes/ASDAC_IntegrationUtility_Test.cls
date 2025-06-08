@isTest
public class ASDAC_IntegrationUtility_Test {
    /***************************************************************
    * @author       : Akshay Singh Shekhawat
    * @date         : 2022-11-11
    * @description  : Testing with predefined custom metadata record
    ****************************************************************/
    public FINAL STATIC String  USER_RECORD = 'testUser_0@testing_0.com';
    
    @testSetup static void setup() {
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
        insert ocsASDABaseUser;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsASDABaseUser},ASDAC_GlobalConstants.STRING_TEAMLEAD_UK_PSG_NAME);
        System.runAs(ocsASDABaseUser) {
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
        User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Test.startTest();
            ASDAC_IntegrationUtility.IntegrationWrapper intWrap = new ASDAC_IntegrationUtility.IntegrationWrapper(); 
            intWrap.metadataRecord = ASDAC_IntegrationMetadata__mdt.getInstance('Stub_Callout_Demops'); 
            intWrap.requestBody = '{"type":"OrderId","src":"","key":"AP-202205160031","disabled":false}';
            Test.setMock(HttpCalloutMock.class, new ASDAC_OrderDetailsServiceMock_Test());
            HttpResponse httpResp = ASDAC_IntegrationUtility.sendRequest(intWrap);
            Test.stopTest();
            System.assertEquals(true, String.isNotBlank(httpResp.getBody()), 'response not be null');
        }
    }

    @isTest
    public static void logTest() {
        User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Test.startTest();          
            new ASDAC_IntegrationUtility.ResultWrapper(true, 'test','test');
              
            ASDAC_IntegrationUtility.IntegrationWrapper intWrap = new ASDAC_IntegrationUtility.IntegrationWrapper();
            ASDAC_IntegrationMetadata__mdt medalliaMeta = [Select id,ExternalSystem__c,Source__c,EndPointURL__c,MethodType__c
                                                           from ASDAC_IntegrationMetadata__mdt where DeveloperName = 'SendCSATSurvey'];
            intWrap.metadataRecord = medalliaMeta; 
            intWrap.requestBody = '{"type":"","src":"","key":"","disabled":false}';
            
            HttpResponse res = new HttpResponse();
            res.setBody('<?xml version="1.0" encoding="utf-8"?><root U_Id="12345"></root>');
            res.setStatusCode(400);
            
            new ASDAC_IntegrationUtility.ResultWrapper(res);
            
            ASDAC_IntegrationUtility.createLog(intWrap,res);
            Test.stopTest();
        }
        
    }
    
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }       
}