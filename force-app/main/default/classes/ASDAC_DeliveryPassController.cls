/**********************************************************************************
 * @author                       : Sanskriti Vijay
 * @date                         : 20-04-2023
 * @description                  : Controller class for asdacDeliveryPassCalloutCmp LWC
 **********************************************************************************/

public with sharing class ASDAC_DeliveryPassController {

    /**************************************************************************
	 Purpose    : This method calls the ASDAC_OrderController class and gets the orderHistoryList.
				  It then updated the related asset records for a personAccount on basis of matching deliveryPassID.
	 Parameters : ASDAC_OrderHistoryOption option, Id personAccountId
	 Returns    : List of updated Asset Ids.                                     
	**************************************************************************/ 
    @AuraEnabled
    public static List<String> getOrderList(ASDAC_OrderHistoryOption option, Id personAccountId) {
        // get the orderList for a customerId
       
        ASDAC_OrderHistoryResponse response = ASDAC_OrderController.getOrders(option);
        
        // create a map of deliveryPassId and No. of orders placed for that DP.
        List<String> updatedAssetIds = new List<String>();
        if(!response.data.isEmpty()){
            Map<String, Integer> dpToOrderCountMap = new Map<String, Integer>();
            for(ASDAC_OrderHeaderResponse order: response.data){
                String key = order.deliveryPassId;
                if(key != null && dpToOrderCountMap.containsKey(key)){
                    Integer count = dpToOrderCountMap.get(key);
                    count++;
                    dpToOrderCountMap.put(key, count);
                }
                else if(key != null){
                    dpToOrderCountMap.put(key, 1);
                }
            }
           
            updatedAssetIds = updateAssetRecords(personAccountId, dpToOrderCountMap);
        }
        return updatedAssetIds;
    }
    
	/**************************************************************************
	 Purpose    : This method updated the related asset records for a personAccount on basis of matching deliveryPassID.
	 Parameters : Id personAccountId, Map<String, Integer> dpToOrderCountMap
	 Returns    : List of updated Asset Ids.                                     
	**************************************************************************/ 
    @AuraEnabled
    public static List<String> updateAssetRecords(Id personAccountId, Map<String, Integer> dpToOrderCountMap) {
        try{
            List<Asset> relatedAssets = [SELECT Id,AccountId,ASDAC_OrdersPlaced__c,shopOrderNumber__c FROM Asset WHERE AccountId=:personAccountId];
    
            List<Asset> assetToUpdate = new List<Asset>();
            List<String> idList = new List<String>();
            for(Asset obj: relatedAssets){
                if(dpToOrderCountMap.containsKey(obj.Id)){
                    obj.ASDAC_OrdersPlaced__c = dpToOrderCountMap.get(obj.Id);
                    assetToUpdate.add(obj);
                    idList.add(obj.Id);
                }
            }
            if(!assetToUpdate.isEmpty()){
                Database.update(assetToUpdate);
            }
            return idList;
        }catch(Exception e) {
            writeLogsToDatabase(e.getMessage());
            return new List<String>();
        }
    }
    @Future
    private static void writeLogsToDatabase(String exceptionMessage) {
        ASDAC_Logger.logException(exceptionMessage, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, 'ASDAC_DeliveryPassController');
        ASDAC_Logger.writeLogsToDatabase();
    }
}