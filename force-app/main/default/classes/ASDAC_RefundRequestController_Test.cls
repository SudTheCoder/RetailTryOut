/*************************************************************************
Name: ASDAC_RefundRequestController_Test
==========================================================================
Req: 
ASDAC-3361 => Interface for Refunds - view order history and return actions
==========================================================================
Purpose: This Class will test the ASDAC_RefundRequestController Controller class   
==========================================================================
History                                                                                                                       
VERSION   AUTHOR                		DATE         	DETAIL
1.0       Sanskriti Vijay    		    14-Oct-2022    Initial Development
2.0       Disharee Ray                  28-March-2023   ASDAC-9872 Modified escalatePartialRefundTest()
**************************************************************************/
@isTest
public with sharing class ASDAC_RefundRequestController_Test {
    private STATIC FINAL String ORDER_NUMBER = 'AD-20220526003';
   	private static final String REFUND_STRING = '[{"discount":"10.4","isDisableCancel":true,"isDisableDiscount":false,"isDisableExchange":false,"isDisableRefund":false,"lineId":"1","lineStatus":"SHIPPED","lineTotal":"43.4","notes":"","orderId":"AD-20220526003","productId":"1266009","quantity":"1","refundAmount":"","refundAmountSoFar":"","refundReason":"","refundType":"","taxes":"3.4","unitPrice":"40","updatedLineAmount":""}]';
    private STATIC FINAL String USER_NAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
    private FINAL STATIC String BPO_SUFFIX = '.ocsColleagueBPO';
    @TestSetup
	static void createData(){
        UserRole userRole = [SELECT Id, Name FROM UserRole WHERE Name='OCS Colleague Tier 1 BPO' LIMIT 1];
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + BPO_SUFFIX;
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + BPO_SUFFIX;
        ocsCollBPO.UserRoleId=userRole.Id;
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPO) {
        Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
        List<Case> listOfCases = ASDAC_TestDataUtility.createCases(1, false, 'CustomerSupport', personAccount.Id);
            Database.insert(listOfCases);
        }
    }
    
    @isTest
    static void escalatePartialRefundTest(){
        User ocsCollBPO = getuserRecord(USER_NAME);
        
        System.runAs(ocsCollBPO) {
            Test.startTest();
            ASDAC_RefundRequestController.EscalateResponseWrapper resWrap = ASDAC_RefundRequestController.escalatePartialRefund(ocsCollBPO.UserRole.Name, '15');
            system.assertEquals(resWrap.escalate, false, 'List of Refund Received.');
            ASDAC_RefundRequestController.EscalateResponseWrapper resWrapUk = ASDAC_RefundRequestController.escalatePartialRefund(ocsCollBPO.UserRole.Name, '20');
            system.assertEquals(resWrapUk.escalate, true, 'List of Refund successfully Received.');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCreateCaseCommentSuccess() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO) {
            Case testCase = new Case(
                Subject = 'Test Case',    
                Status = 'Assigned'
            );
            insert testCase;
    
            Test.startTest();
            Boolean result = ASDAC_RefundRequestController.createCaseComment(testCase.Id, 'Exchange', '100');
            Test.stopTest();
            System.assertEquals(true, result, 'Expected result to be true for successful scenario');
            List<CaseComment> createdComments = [SELECT Id FROM CaseComment WHERE ParentId = :testCase.Id];
            System.assertNotEquals(0, createdComments.size(), 'Expected at least one CaseComment to be created');
        }
    }
    
     @isTest
    static void testCreateCaseCommentException() {       
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO) {
            Case testCase = new Case(
                Subject = 'Test Case',    
                Status = 'Assigned'
            );
            insert testCase;
    
            Test.startTest();
            Boolean result = ASDAC_RefundRequestController.createCaseComment(testCase.Id, 'SampleAction', '100');
            Test.stopTest();
            System.assertEquals(false, result, 'Expected result to be true for successful scenario');
        }     
    }
    
    @isTest
    static void testGetPersonContactId() {       
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO) {
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact'
            );
            insert testContact;
            
            Test.startTest();
            String personContactName = ASDAC_RefundRequestController.getPersonContactId(testContact.Id);
            Test.stopTest();
            System.assertEquals(null, personContactName, 'Unexpected Person Contact Name');
        }
    }
        
    private static User getuserRecord(String username) {
        return [SELECT Id,UserRoleId,UserRole.Name FROM User WHERE UserName = :username];
    }
}