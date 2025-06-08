/**********************************************************************************
* @author                       : Sanskriti Vijay
* @date                         : 20-04-2023
* @description                  : Test Class for ASDAC_DeliveryPassController.
**********************************************************************************/

@isTest
public  with sharing class ASDAC_DeliveryPassController_Test {
    private final static String ORDER_LIST_GHS_MOCK_RESOURCE_NAME = 'SampleHistoryJsonResponseGrocery';
    private final static String USER_NAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
    
    /**************************************************************************
    Purpose    : Test Setup data                                           
    Parameters : NA
    Returns    : NA                                        
    **************************************************************************/ 
    @TestSetup
    static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        
    }
    
    @isTest
    static void updateAssetRecordsTest(){
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO) {			
            Account acc = ASDAC_TestDataUtility.createPersonAccount(true);
            
            Asset obj = new Asset();
            obj.AccountId = acc.Id;
            obj.Name = 'Test Delivery Pass';
            obj.ASDAC_OrdersPlaced__c = 10;
            obj.shopOrderNumber__c = 'OMS0001234';
            obj.Status = 'Active';
            
            Database.insert(obj);
            Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_LIST_GHS_MOCK_RESOURCE_NAME));
            
            Test.startTest();
            List<String> result = ASDAC_DeliveryPassController.getOrderList(new ASDAC_OrderHistoryOption(), acc.Id);
            if(!result.isEmpty()){
                Asset updatedRecord = [Select id, Name, ASDAC_OrdersPlaced__c, AccountId From Asset where id=: result[0] Limit 1];
                System.assertEquals(updatedRecord.Name, obj.Name, 'Check for same asset record');
                System.assertEquals(updatedRecord.ASDAC_OrdersPlaced__c, 6, 'Record updated Successfully!');        
            }
            
            
            Test.stopTest();   
        }
    }
    
    @isTest
    static void updateAssetRecordsMethodTest(){
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
              
            Account acc = ASDAC_TestDataUtility.createPersonAccount(true);
            
            Asset obj = new Asset();
            obj.AccountId = acc.Id;
            obj.Name = 'Test Delivery Pass';
            obj.ASDAC_OrdersPlaced__c = 10;
            obj.shopOrderNumber__c = 'OMS0001234';
            obj.Status = 'Active';
            
            Database.insert(obj);
            Map<String, Integer> dpToOrderCountMap = new Map<String, Integer>();
            dpToOrderCountMap.put(obj.Id, 11);
            Test.startTest();
            List<String> tempList = new List<String>();
            try{
                tempList = ASDAC_DeliveryPassController.updateAssetRecords(acc.Id, dpToOrderCountMap);
            }catch(exception e){
                System.assert(String.isNotBlank(e.getMessage()), 'Exception caught and handled correctly');
            } 
            system.assertequals(tempList.isEmpty(),false);
            Test.stopTest();
        }  
    }
    
    @isTest
    static void updateAssetRecordsMethodNegativeTest(){
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            Account acc = ASDAC_TestDataUtility.createPersonAccount(true);
            
            Asset obj = new Asset();
            obj.AccountId = acc.Id;
            obj.Name = 'Test Delivery Pass';
            obj.ASDAC_OrdersPlaced__c = 10;
            obj.shopOrderNumber__c = 'OMS0001234';
            obj.Status = 'Active';
            
            Database.insert(obj);
            Map<String, Integer> dpToOrderCountMap = new Map<String, Integer>();
            dpToOrderCountMap.put(obj.Id, null);
            Test.startTest();
            List<String> tempList = new List<String>();
            try{
                tempList = ASDAC_DeliveryPassController.updateAssetRecords(acc.Id, null);
            }catch(exception e){
                System.assert(String.isNotBlank(e.getMessage()), 'Exception caught and handled correctly');
            }
            Test.stopTest();
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