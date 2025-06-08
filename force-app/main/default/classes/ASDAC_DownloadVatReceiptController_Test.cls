/**********************************************************************************
 * @author                       : Sanskriti Vijay
 * @date                         : 19-06-2023
 * @description                  : Test Class for ASDAC_DownloadVatReceiptController.
 **********************************************************************************/

@IsTest
public with sharing class ASDAC_DownloadVatReceiptController_Test {

    private final static String ORDER_MOCK_RESOURCE_NAME = 'AP_202205160031';
    private final static String ORDER_NUMBER = 'GHS-2605-003';
    private final static String SELLING_CHANNEL = 'ASDA_GROCERIES';
    
    /**************************************************************************
	 Purpose    : Test Setup data                                           
	 Parameters : NA
	 Returns    : NA                                        
	**************************************************************************/ 
    @TestSetup
	static void createData(){
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        
	}
    
    /**************************************************************************
	 Purpose    : Get User Record                                           
	 Parameters : username
	 Returns    : User record                                        
	**************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
    
    
  @IsTest
  static void generatePdfTest() {
      User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
      System.runAs(ocsCollBPO) {	
          Case cse = ASDAC_TestDataUtility.createCases(1, false, 'CustomerSupport', null)[0];
          insert cse;
          Test.startTest();
          ASDAC_DownloadVatReceiptController.generatePdf(ORDER_NUMBER,SELLING_CHANNEL,cse.Id);
          Test.stopTest();
          List<ContentDocumentLink> docLink = [Select Id,ContentDocumentId From ContentDocumentLink where LinkedEntityId=:cse.Id];
          system.assertEquals(1, docLink.size(), 'One ContentDocumentLink record should have been inserted.');
      }
  }
    
    @IsTest
    static void testConstructor() {
        Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_MOCK_RESOURCE_NAME));
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        System.runAs(ocsCollBPO) {
            Test.startTest();
            Test.setCurrentPage(Page.VatReceiptPdf); 
            ApexPages.currentPage().getParameters().put('orderId',ORDER_NUMBER);
            ApexPages.currentPage().getParameters().put('sellingChannel', SELLING_CHANNEL);
            ASDAC_DownloadVatReceiptController controller = new ASDAC_DownloadVatReceiptController(); 
            Test.stopTest();
            system.assertEquals(controller.orderId, ORDER_NUMBER, 'assert successfull');
        }
    }
}