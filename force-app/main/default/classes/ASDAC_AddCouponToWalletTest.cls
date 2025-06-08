/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-05-17
* @Component Type               : Apex Class
* @component Name               : ASDAC_AddCouponToWalletTest
* @description                  : 
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-05-23
***************************************************************************************************/
@IsTest
public with sharing class ASDAC_AddCouponToWalletTest {
    public FINAL STATIC String BPO_SUFFIX = '.ocsColleagueBPO';
    Public Static FINAL String REASON_CODE = 'Cancelled Order';  
    @testsetup
    static void testsetup() {
        
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + BPO_SUFFIX;
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + BPO_SUFFIX;
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + '.teamLeaderUK';
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEAD_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsTeamLdrTstUsr) {
          ASDAC_TestDataUtility.createPersonAccount(true);
        }
        
    }
    /**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
    
    @IsTest
    static void testAddCoupon() {
        
        Integer decDiscountAmount = 10;
        String strWalletId = '123456789';
        String strVoucherType = 'Savings_Guarantee';
        String strReason = REASON_CODE;
        
        ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '100109453';
        mockMapping.Name = strVoucherType;
        insert mockMapping;
        
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = 'Loyalty & Rewards';
            cs.ContactReasonLevel2__c = 'Vouchers';
            cs.Status = 'Assigned';
            cs.Subject = 'Goodwill Voucher';
            cs.BusinessArea__c ='George';
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c='GHS';
        	goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;
            
            Test.startTest();	
            Test.setMock(HttpCalloutMock.class, new ASDAC_AddCouponToWalletMockTest());
            ASDAC_AddCouponToWallet.addCoupon(decDiscountAmount, strWalletId, strVoucherType,objAccount.id,strReason);
            Test.stopTest();
            
        }  
    }
    
    @IsTest
    static void testAddCouponNeg() {
        
        Integer decDiscountAmount = 10;
        String strWalletId = '123456789';
        String strVoucherType = 'Savings_Guarantee';
        String strReason = REASON_CODE;
        ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '100109453';
        mockMapping.Name = strVoucherType;
        insert mockMapping;
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = 'Loyalty & Rewards';
            cs.ContactReasonLevel2__c = 'Vouchers';
            cs.Status = 'Assigned';
            cs.Subject = 'Goodwill Voucher';
            cs.BusinessArea__c ='George';
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c='GHS';
        	goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            Test.startTest();	
            
            Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());
            try{
                ASDAC_AddCouponToWallet.addCoupon(decDiscountAmount, strWalletId, strVoucherType,objAccount.id,strReason); 
            }catch(exception e){
                system.debug('Error : '+e.getmessage());
            }
            Test.stopTest();
            
        }  
    }
    
    // Mock response - Error
    public class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404);
            response.setBody('{"statusCode":404,"message":"Resource not found"}');
            return response;
        }
    }
}