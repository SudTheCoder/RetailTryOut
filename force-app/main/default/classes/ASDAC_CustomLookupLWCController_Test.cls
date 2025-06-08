@isTest
public with sharing class ASDAC_CustomLookupLWCController_Test {
    private FINAL STATIC String BPO_SUFFIX = '.ocsColleagueBPO';
    @testSetup
    static void createData() {
        User ocsCollBPOUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPOUser.userName = ocsCollBPOUser.userName + BPO_SUFFIX;
        ocsCollBPOUser.FederationIdentifier = ocsCollBPOUser.FederationIdentifier + BPO_SUFFIX;
        insert ocsCollBPOUser;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPOUser},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPOUser) {
            List<Account> accList = ASDAC_TestDataUtility.createPersonAccounts(1,true);
            List<Case> listOfCases = ASDAC_TestDataUtility.createCases(1,false,'CustomerSupport',accList[0].Id);
        	for (Case cs : listOfCases) {
            	cs.OrderId__c = 'AP-202205160031';
            	cs.BusinessArea__c = 'George';
            	cs.ContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
        	}
        	Database.Insert(listOfCases);
        }

    }
    
    @IsTest
    static void testGetCaseForEvoucherFunctionality() {
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
         System.runAs(ocsCollBPO) {
        	Test.startTest();
        	Id conId  = [SELECT Id,PersonContactId FROM Account LIMIT 1].PersonContactId;
			Case cs = [SELECT Id,BusinessArea__c,ContactId, VoucherCode__C, CaseNumber FROM Case LIMIT 1];
            String caseRecordsFoundMsg = 'Expected Case Records in List';
            String caseRecordsNotFoundMsg = 'Not Expecting Case Records in List';
            String stringifiedJSON = '","businessArea":"Grocery","isIssueEvoucher":false}';
            String stringifiedJSONG = '","businessArea":"George","isIssueEvoucher":true}';
        	String stringifiedJSON1 = '{"searchTerm":"'+cs.CaseNumber+'","recordId":"'+conId+stringifiedJSONG;
            String sObjectName = 'Case';
            List<SObject> lstLookupWrapper1 = ASDAC_CustomLookupLWCController.getsearchedRecords(sObjectName, stringifiedJSON1);
        	System.assertEquals(true, lstLookupWrapper1.size()>0, caseRecordsFoundMsg);
            String stringifiedJSON2 = '{"searchTerm":"test","recordId":"'+conId+stringifiedJSONG;
       	 	List<Case> lstLookupWrapper2 = ASDAC_CustomLookupLWCController.getsearchedRecords(sObjectName, stringifiedJSON2);
        	System.assertEquals(false, lstLookupWrapper2.size()>0, caseRecordsFoundMsg);
            String stringifiedJSON3 = '{"searchTerm":"","recordId":"'+conId+stringifiedJSONG;
            List<Case> lstLookupWrapper3 = ASDAC_CustomLookupLWCController.getsearchedRecords(sObjectName, stringifiedJSON3);
        	System.assertEquals(true, lstLookupWrapper3.size()>0, caseRecordsNotFoundMsg);
            String stringifiedJSON4 = '{"searchTerm":"'+cs.CaseNumber+'","recordId":"'+conId+stringifiedJSONG;
            List<Case> lstLookupWrapper4 = ASDAC_CustomLookupLWCController.getsearchedRecords(sObjectName, stringifiedJSON4);
        	System.assertEquals(true, lstLookupWrapper4.size()>0, caseRecordsFoundMsg);
            String stringifiedJSON5 = '{"searchTerm":"000134","recordId":"'+conId+stringifiedJSON;
        	List<Case> lstLookupWrapper5 = ASDAC_CustomLookupLWCController.getsearchedRecords(sObjectName, stringifiedJSON5);
        	System.assertEquals(false, lstLookupWrapper5.size()>0, caseRecordsNotFoundMsg);
        
        	Test.stopTest();
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
}