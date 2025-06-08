/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-02-06
 * @description                  : OMS Service layer for heavy lifting of code
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
 ***************************************************************************************************/
public with sharing class ASDAC_OrderService {

    public static Object getResponse(String integrationMetadata, String jsonString, Type typeObj) {
        ASDAC_IntegrationUtility.ResultWrapper result = ASDAC_CalloutService.getResponseMethod(integrationMetadata, jsonString);
        if (ASDAC_ErrorHandler.checkForException(integrationMetadata,result.statusCode)) {
            throw new ASDAC_ErrorHandler.CustomCalloutException(result);
        }
        else if (ASDAC_ErrorHandler.checkForEmptyResponse(result.statusCode)) {
            return null;
        }
        return JSON.deserialize(result.strData, typeObj);
    }
    
    /**
   * ****************************************************************************************************
   * @param option Order History option (filters, sort, pagination)
   * @description method to get Orders
   * @return ASDAC_OrderHistoryResponse
   * ****************************************************************************************************
   */
  public static ASDAC_OrderHistoryResponse getOrders(ASDAC_OrderHistoryOption option, String integrationMetadata) {
    ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
    requestWrap.params= new List<String> {option.toQueryString()}; 
    requestWrap.isGrocery= option.filters != null && option.filters.contains(ASDAC_OMSConstants.ASDA_GROCERIES_STRING);
    String requestJson = JSON.serialize(requestWrap);
    ASDAC_OrderHistoryResponse response = (ASDAC_OrderHistoryResponse) getResponse(integrationMetadata, requestJson, ASDAC_OrderHistoryResponse.class);
    return response;
  }

  /**
   * ****************************************************************************************************
   * @param orderId Order Id
   * @description method to get a single Order
   * @return ASDAC_OrderResponse
   * ****************************************************************************************************
   */
  public static ASDAC_OrderResponse getOrder(String businessArea, String orderId, List<String> variables, String integrationMetadata) { 
    if(String.isBlank(businessArea)) {
      businessArea = ASDAC_OMSConstants.SELLING_CHANNEL_MAP.keySet().iterator().next();
    }
    String sellingChannel = ASDAC_OMSConstants.SELLING_CHANNEL_MAP.get(businessArea.toUpperCase());
    ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
    requestWrap.isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING || businessArea == ASDAC_OMSConstants.GROCERY_STRING);
    requestWrap.params = new List<String> {sellingChannel, orderId};   
    if (variables == null || variables.size() == 0) {variables = new List<String> {'paymentDetails', 'exchangeOrders', 'returnOrders'};}
    requestWrap.body = JSON.serialize(new Map<String, Object> { 'variables' => variables });
    String requestJson = JSON.serialize(requestWrap);
    ASDAC_OrderResponse order;
        order = (ASDAC_OrderResponse) getResponse(integrationMetadata, requestJson, ASDAC_OrderResponse.class);
        order.setCustomerDetails(ASDAC_CustomerSelector.getCustomer(order.customerId));
        order.transformOrderLines();
    return order;
    }

    /**
* ****************************************************************************************************
* @param order order wrapper instance
* @description method to exchange an Order
* @return String
* ****************************************************************************************************
  */
    public static String exchangeOrder(ASDAC_OrderWrapper order, String integrationMetadata) {
        ASDAC_OrderRequest exchangeOrder = order.toExchangeOrderRequest();
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.params = new List<String> {order.sellingChannel, order.orderId};
        requestWrap.body = JSON.serialize(exchangeOrder, true).replaceAll(ASDAC_OMSConstants.REGEX_EXP_STRING, 'Z');
        String requestJson = JSON.serialize(requestWrap);
        
        String response = (String) getResponse(integrationMetadata, requestJson, String.class);
        return response;
        
    }
    
    /**
* ****************************************************************************************************
* @param orderId Order Id
* @description method to get a single Order
* @return ASDAC_OrderResponse
* ****************************************************************************************************
*/
    public static String partialRefundOrder(ASDAC_OrderWrapper order, String integrationMetadata) {
        ASDAC_OrderRequest partialOrder = order.toPartialOrderRequest();
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.body = JSON.serialize(partialOrder, true).replaceAll('.\\d{3}Z', 'Z');
        requestWrap.params = new List<String>{ASDAC_OMSConstants.STRING_TRUE};
        String requestJson = JSON.serialize(requestWrap);

        String response = (String) getResponse(integrationMetadata, requestJson, String.class);
        return response;
        
    }
    /**
* ****************************************************************************************************
* @param orderId Order Id
* @description method to delivery charge refund
* @return ASDAC_OrderResponse
* ****************************************************************************************************
*/
    public static String deliveryChargeRefundOrder(ASDAC_OrderWrapper order, String integrationMetadata) {
        ASDAC_OrderRequest deliveryChargeRefund = order.toDeliveryChargeRequest();
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.body = JSON.serialize(deliveryChargeRefund, true).replaceAll(ASDAC_OMSConstants.REGEX_EXP_STRING, 'Z');
        requestWrap.params = new List<String>{ASDAC_OMSConstants.STRING_FALSE};
        String requestJson = JSON.serialize(requestWrap);
        
        String response = (String) getResponse(integrationMetadata, requestJson, String.class);
        return response;
    }
    
    
    
    public class PreviewParams{
        public Boolean preview;
        public Boolean proratedRefundCalculation;
    }
    /**
* ****************************************************************************************************
* @param order
* @description method to create a return preview request
* @return response String from Preview Request callout
* ****************************************************************************************************
*/
    public static ASDAC_ReturnPreviewResponse createReturnPreviewRequest(ASDAC_OrderWrapper order, String integrationMetadata) {
        String businessArea = order.sellingChannel;
        Boolean isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING);

        Map<String, Boolean> params = new Map<String, Boolean>();
        params.put('preview', true);
        if(!isGrocery){
            params.put('proratedRefundCalculation', true);
        }
        List<String> paramList = new List<String>();
        for (String param : params.keySet()) {
            Boolean value = params.get(param);
            paramList.add(param + '=' + value);
        }
        String query = String.join(paramList, '&');
        
        ASDAC_OrderRequest previewOrder = order.toReturnPreviewRequest();
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.isGrocery = isGrocery;
        requestWrap.params= new List<String> {query}; 
        requestWrap.body = JSON.serialize(previewOrder, true).replaceAll(ASDAC_OMSConstants.REGEX_EXP_STRING, 'Z');
        String requestJson = JSON.serialize(requestWrap);
        
        ASDAC_ReturnPreviewResponse response = (ASDAC_ReturnPreviewResponse) getResponse(integrationMetadata, requestJson, ASDAC_ReturnPreviewResponse.class);
        return response;
    }

    /**
* ****************************************************************************************************
* @param order
* @description method to create a return preview request
* @return response String from Preview Request callout
* ****************************************************************************************************
*/
    public static String createReturnRequest(ASDAC_OrderWrapper order, String integrationMetadata) {
        String businessArea = order.sellingChannel;
        ASDAC_OrderRequest returnOrder = order.toReturnOrderRequest();
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING);
        requestWrap.body = JSON.serialize(returnOrder, true).replaceAll(ASDAC_OMSConstants.REGEX_EXP_STRING, 'Z');
        String requestJson = JSON.serialize(requestWrap);
        String response = (String) getResponse(integrationMetadata, requestJson, String.class);
        return response;
    }
    
    /**
* ****************************************************************************************************
* @param order
* @description method to create a Whole order Refund request
* @return response String from Whole order Refund Request callout
* ****************************************************************************************************
*/
public static String createWholeOrderRefundRequest(ASDAC_OrderWrapper order, String integrationMetadata) {
    String businessArea = order.sellingChannel;
    ASDAC_OrderRequest returnOrder = order.toWholeOrderRefundRequest();
    ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
    requestWrap.isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING);
    requestWrap.body = JSON.serialize(returnOrder, true).replaceAll(ASDAC_OMSConstants.REGEX_EXP_STRING, 'Z');
    String requestJson = JSON.serialize(requestWrap);
    String response = (String) getResponse(integrationMetadata, requestJson, String.class);
    return response;
}


    /**
* ****************************************************************************************************
* @param order
* @description method to create a receive request
* @return response String from Receive Request callout
* ****************************************************************************************************
*/
public static String createReceiveRequest(ASDAC_OrderWrapper order, String integrationMetadata) {

  ASDAC_ReceiveRequest returnOrder = order.toReceiveRequest();
  ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
  requestWrap.body = JSON.serialize(returnOrder, true).replaceAll(ASDAC_OMSConstants.REGEX_EXP_STRING, 'Z');

  String requestJson = JSON.serialize(requestWrap);

  String response = (String) getResponse(integrationMetadata, requestJson, String.class);
  return response;
}

    /**
* ****************************************************************************************************
* @param order
* @description method to create a ATP request
* @return response String from ATP Request callout
* ****************************************************************************************************
*/
    public static ASDAC_GetOrderATPWrapper createOrderItemAvailabilityRequest(ASDAC_OrderWrapper order, String integrationMetadata) {
        ASDAC_ATPInventoryCheckRequest inventoryRequest = order.toATPInventoryCheckRequest();
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.body = JSON.serialize(inventoryRequest, true);
        String requestJson = JSON.serialize(requestWrap);
        ASDAC_GetOrderATPWrapper response = (ASDAC_GetOrderATPWrapper) getResponse(integrationMetadata, requestJson, ASDAC_GetOrderATPWrapper.class);
        return response;
    }
    
  /**
   * ****************************************************************************************************
   * @param personAccountId Id of Person account
   * @description method to get Customer Id from Person account
   * @return String
   * ****************************************************************************************************
*/
  public static String getCustomerId(Id personAccountId) {
    return ASDAC_CustomerSelector.getCustomerId(personAccountId);
  }

  /**
* ****************************************************************************************************
* @description method to get Order History Fields metadata
* @return List\<ASDAC_OrderHistoryField__mdt\>
* ****************************************************************************************************
*/
  public static List<ASDAC_OrderHistoryField__mdt> getOrderHistoryFields() {
    return ASDAC_OrderHistoryField__mdt.getAll().values(); // ASDAC_MetadataSelector / ASDAC_OrderHistoryFieldMetadataSelector
  }

  /**
* ****************************************************************************************************
* @param orderId Order Id
* @description method to get a single Order
* @return ASDAC_OrderResponse
* ****************************************************************************************************
*/
    public static String cancelOrder(ASDAC_OrderWrapper order, String integrationMetadata) {
        ASDAC_OrderRequest cancelOrderReq = order.toCancelOrderRequest();     
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.body = JSON.serialize(cancelOrderReq, true);
        requestWrap.isGrocery= order.sellingChannel.contains(ASDAC_OMSConstants.ASDA_GROCERIES_STRING);
        String requestJson = JSON.serialize(requestWrap);
        String response = (String) getResponse(integrationMetadata, requestJson, String.class);
        return response;
    }
      
    /**
* ****************************************************************************************************
* @param order
* @description method to create a ghs refund override request
* @return response String from refund override callout
* ****************************************************************************************************
*/
    public static String createRefundOverrideRequest(ASDAC_OrderWrapper order, String integrationMetadata) {
        String businessArea = order.sellingChannel;
        String query = '';
        
        ASDAC_OrderRequest returnOrder = order.toRefundOverrideRequest();
        ASDAC_OrderIntegrationService.RequestWrapper requestWrap = new ASDAC_OrderIntegrationService.RequestWrapper();
        requestWrap.isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING);
        requestWrap.params= new List<String> {query}; 
        requestWrap.body = JSON.serialize(returnOrder, true).replaceAll(ASDAC_OMSConstants.REGEX_EXP_STRING, 'Z');
        
        String requestJson = JSON.serialize(requestWrap);
       
        String response = (String) getResponse(integrationMetadata, requestJson, String.class);
        return response;
    }
    
}