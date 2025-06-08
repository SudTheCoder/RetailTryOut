/**********************************************************************************
 * @author                       : Disharee Ray
 * @date                         : 2022-12-12
 * @description                  : ASDAC-3320 Approvals for partial refund and goodwill. Test class for flow ASDAC_PartialRefundApprovalProcessInitiation
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Disharee Ray                12-Dec-2022    Created the class
 ***************************************************************************************************/
@isTest(seealldata=false)
public with sharing class ASDAC_PartialRefundApprovalFlow_Test {
private static final String USERNAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
public FINAL STATIC String BPO_SUFFIX = '.ocsColleagueBPO';
@testSetup
  static void setup() {
   User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
   ocsCollBPO.userName = ocsCollBPO.userName + BPO_SUFFIX;
   ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + BPO_SUFFIX;
   insert ocsCollBPO;
   ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
   System.runAs(ocsCollBPO) {
    Case caseToBeInserted = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', null)[0];
    caseToBeInserted.SuppliedEmail = 'guest.user@asdatest.co.uk';
    caseToBeInserted.SuppliedName = 'Test123';
    caseToBeInserted.ContactReasonLevel1__c = 'Company Info';
    caseToBeInserted.ContactReasonLevel2__c = 'Policies';
    insert caseToBeInserted;
    RefundRequest__c refundrequest= new RefundRequest__c(CaseId__c=caseToBeInserted.Id,
                                                        RefundPercentage__c=12.1,
                                                        ApprovalRequired__c=false);
   insert refundrequest;
   }
  }
    
  @IsTest
  static void updateRefundRequestRecord() {
    User colleagueUser =[SELECT Id, Email FROM User WHERE UserName=:USERNAME];
    RefundRequest__c ref= [ SELECT Id,RefundPercentage__c FROM RefundRequest__c LIMIT 1];
    ref.RefundPercentage__c=16.1;
    Test.startTest();
    System.runAs(colleagueUser) {
    update ref;
    }
    RefundRequest__c refundAfterFlowExecution= [ SELECT Id,ApprovalRequired__c FROM RefundRequest__c LIMIT 1];
    System.assertEquals(true, refundAfterFlowExecution.ApprovalRequired__c, 'Flow executed successfully!');
    try{
       ref.RefundPercentage__c=100000;
       update ref;   
    }catch(Exception exp){
       System.assertEquals('System.DmlException', exp.getTypeName(), 'Number outside the range error!');
    }
    Test.stopTest();
  }
}