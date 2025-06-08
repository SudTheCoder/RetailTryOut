/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-02-06
 * @description                  : OMS - Order Header Response
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
 ***************************************************************************************************/
public with sharing virtual class ASDAC_OrderHeaderResponse {
  @AuraEnabled
  public String orderId;
  public Datetime orderDate;
  public Datetime updateTime;
  @AuraEnabled
  public String sellingChannel;
  @AuraEnabled
  public Integer numberOfItems;
  @AuraEnabled
  public String orderType;
  @AuraEnabled
    public String orderStatus
    {
        get{
          if (sellingChannel == 'GEORGE.COM'){
            return orderStatus;
          } else{
            return updateStatusString(ASDAC_OMSConstants.GROCERY_STRING, orderStatus);
          }
        }
    }
  @AuraEnabled
  public String orderFulfilmentType;
  @AuraEnabled
  public String fulfillmentType{
    get{
      Boolean isGrocery = (sellingChannel == ASDAC_OMSConstants.ASDA_GROCERIES_STRING);
      if(isGrocery){
        return getFulfillmentType(orderFulfilmentType, fulfillmentService);
      }
      else{
        return orderFulfilmentType;
      }
    }
  }
  @AuraEnabled
  public String fulfillmentService;
  @AuraEnabled
  public String storeAddress
      {
        get{
            return updateStoreIdToStoreName(storeAddress);
        }
    }
  @AuraEnabled
  public Decimal totalAmount;  
  public Datetime deliveryDate;
  @AuraEnabled
  public String formattedOrderDate {
    get {
      if (orderDate != null) {
        return ASDAC_OrderUtility.convertDateTimeString(orderDate);
      }
      return '';
    }
  }
  @AuraEnabled
  public String formattedDeliveryDate {
    get {
      if (deliveryDate != null) {
          return ASDAC_OrderUtility.convertDateTimeString(deliveryDate);
      }
      return '';
    }
  }
  @AuraEnabled
  public String formattedActionDate {
    get {
      if (updateTime != null) {
        return ASDAC_OrderUtility.convertDateTimeString(updateTime);
      }
      return '';
    }
  }
  @AuraEnabled
  public String formattedTotalAmount {
    get {
      if (totalAmount != null) {
        return String.valueOf(totalAmount.setScale(2));
      }
      return '';
    }
  }
    
  @AuraEnabled
  public String deliveryPassId; // Added as part of ASDAC-10618

  private static Map<String, String> fulfillmentMap = new Map<String, String>();
    static{
        List<ASDAC_FulfillmentTypeToService__mdt> fulfillmentList =  ASDAC_FulfillmentTypeToService__mdt.getAll().values();
        for(ASDAC_FulfillmentTypeToService__mdt rec: fulfillmentList){
            FulfillmentMap.put(rec.fulfillmentType__c.toUpperCase()+rec.FulfillmentService__c.toUpperCase(), rec.MasterLabel);
        }
    }

    private String getFulfillmentType(String fulfillmentType, String fulfillmentService){
        if(String.isBlank(fulfillmentType) || String.isBlank(fulfillmentService) || !fulfillmentMap.containsKey(fulfillmentType.toUpperCase()+fulfillmentService.toUpperCase())){
            return  fulfillmentType;
        }else{
            return fulfillmentMap.get(fulfillmentType.toUpperCase()+fulfillmentService.toUpperCase());
        }
    }
    
    private static Map<String, Map<String, Map<String,String>>> mdtStatusMap = new Map<String, Map<String, Map<String,String>>>();
    static {
        List<ASDAC_OMSToSFSCStatusMapping__mdt> statusMappingMdt = ASDAC_OMSToSFSCStatusMapping__mdt.getAll().values();
        for(ASDAC_OMSToSFSCStatusMapping__mdt rec: statusMappingMdt){
            String businessArea = rec.ASDAC_BusinessArea__c.toUpperCase();
            String omsStatus = rec.ASDAC_OMSStatus__c;
            String sfscStatus = rec.ASDAC_SFSCStatus__c;
            String orderType = rec.ASDAC_OrderType__c;
            if(!mdtStatusMap.containsKey(businessArea)){
                mdtStatusMap.put(businessArea, new Map<String, Map<String,String>>());
            }
            if(!mdtStatusMap.get(businessArea).containsKey(orderType)){
                mdtStatusMap.get(businessArea).put(orderType, new Map<String, String>());
            }
            mdtStatusMap.get(businessArea).get(orderType).put(omsStatus, sfscStatus);
        }
    }
    
     private String updateStatusString(String businessArea, String omsStatus){
        if(!mdtStatusMap.containsKey(businessArea)){
            return omsStatus;
        }
        else{
            Map<String, Map<String,String>> fieldMap = mdtStatusMap.get(businessArea);
            if (orderType == null) {
                orderType = ASDAC_OMSConstants.SALES_ORDER;
            }
            if(!fieldMap.containsKey(orderType) || !fieldMap.get(orderType).containsKey(omsStatus) ){
                return omsStatus;
            }
            else{
                return fieldMap.get(orderType).get(omsStatus);
            }
        }
    }
    
    private static Map<String, String> storeNumberToNameMap = new Map<String, String>();
    static {
        if(
            Store__c.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Store__c.fields.StoreNumber__c.isAccessible() &&
            Schema.SObjectType.Store__c.fields.StoreNumberName__c.isAccessible()
        ) {
            for(Store__c rec: [Select id, StoreNumberName__c,StoreNumber__c, Name from Store__c]){
            storeNumberToNameMap.put(rec.StoreNumber__c, rec.StoreNumberName__c);
            }
        }
    }
    
    private String updateStoreIdToStoreName(String storeAddress){
        if(String.isBlank(storeAddress)  || !storeNumberToNameMap.containsKey(storeAddress)){
            return  storeAddress;
        }else{
            return storeNumberToNameMap.get(storeAddress);
        }
    }
}