@isTest
public with sharing class ASDAC_VoucherRequestController_Test {
    public static final String MAILID = 'xyz@email.com';
    public static final String TESTUSER = 'testUser_0@testing_0.com.ocsColleagueBPO';
    public static final String AdminUser= 'testUser_0@testing_0.com.ocsAdminUser';
    @TestSetup
    static void createData(){
        
        userRole objRole = [Select id from UserRole where Name ='OCS Colleague Tier 2 UK'];
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsColleagueBPO';
        ocsCollBPO.userroleId = objRole.Id;
        insert ocsCollBPO;
        
        userRole objRole1 = [Select id from UserRole where Name ='OCS CRM Administrator'];
        User ocsAdminUser = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        ocsAdminUser.userName = ocsAdminUser.userName + '.ocsAdminUser';
        ocsAdminUser.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsAdminUser';
        ocsAdminUser.userroleId = objRole1.Id;
        insert ocsAdminUser;
        
    }
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
    @isTest
	static void createVoucherRecordsTest() {
        User ocsCollBPO = getuserRecord(TESTUSER);
        
        System.runAs(ocsCollBPO) {
            Test.startTest();
            
            Case cs = ASDAC_TestDataUtility.createCases(1, false, 'CustomerSupport', null)[0];
            cs.ContactReasonLevel1__c = 'Loyalty & Rewards';
            cs.ContactReasonLevel2__c = 'Vouchers';
            cs.Subject = 'Goodwill Voucher';
            cs.BusinessArea__c ='George';
            insert cs;
        
            
                Goodwill__c res1 = new Goodwill__c();
                res1.Email__c=MAILID;
                res1.VoucherAmount__c = 51;
                res1.CaseId__c =cs.id;
                Boolean exceptionRaised = false;
                try {
                    ASDAC_VoucherRequestController.getGoodWillLimit();
                    ASDAC_VoucherRequestController.getVoucherRecords();
                }
                catch (AuraHandledException e) {
                    exceptionRaised = true;
                  }
            Test.stopTest();

        }
    }
    
    
    @isTest
    static void createVoucherRecordsTestNegative() {
        User adminUser= getuserRecord(adminUser);
        adminUser.userroleId = null;
        update adminUser;
        
        System.runAs(adminUser) {
            Test.startTest();
            
            Case cse = ASDAC_TestDataUtility.createCases(1, false, 'CustomerSupport', null)[0];
            cse.ContactReasonLevel1__c = 'Payment & Refunds';
            cse.ContactReasonLevel2__c = 'Override Rejected Refund';
            cse.Subject = 'Full Order Refund';
            cse.BusinessArea__c ='Grocery';
            insert cse;
        
            
                Goodwill__c res2 = new Goodwill__c();
                res2.Email__c=MAILID;
                res2.VoucherAmount__c = 50;
                res2.CaseId__c =cse.id;
                Boolean excepRaised = false;
                try {
                    ASDAC_VoucherRequestController.getGoodWillLimit();
                    ASDAC_VoucherRequestController.getVoucherRecords();
                }
                catch (AuraHandledException e) {
                    excepRaised = true;
                  }
            Test.stopTest();

        }
    }
    
    
}