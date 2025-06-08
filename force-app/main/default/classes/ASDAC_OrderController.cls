/**********************************************************************************
* @author                       : Vineeth Rangamgari
* @date                         : 2022-02-06
* @description                  : OMS Controller layer
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
***************************************************************************************************/
public with sharing class ASDAC_OrderController {
    
   
    private final static String ORDER_HISTORY_GEORGE_ENDPOINT_MDT = 'OrderHistoryGeorge';
    private final static String ORDER_HISTORY_GHS_ENDPOINT_MDT = 'OrderHistoryGhs';
    private final static String ORDER_DETAILS_GEORGE_ENDPOINT_MDT = 'OrderDetailGeorge';
    private final static String ORDER_DETAILS_GHS_ENDPOINT_MDT = 'OrderDetailGhs';
    private final static String EXCHANGE_ORDER_ENDPOINT_MDT = 'ExchangeOrder';
    private final static String SHIPPING_FEE_REFUND_ENDPOINT_MDT = 'ShippingFeeRefund';
    private final static String PARTIAL_REFUND_ENDPOINT_MDT = 'PartialRefund';
    private final static String RETURN_PREVIEW_GEORGE_ENDPOINT_MDT = 'ReturnPreviewGeorge';
    private final static String RETURN_PREVIEW_GHS_ENDPOINT_MDT = 'RefundPreviewGhs';
    private final static String GEORGE_RETURN_REQUEST_ENDPOINT_MDT = 'CreateReturnGeorge';
    private final static String GHS_REFUND_REQUEST_ENDPOINT_MDT = 'CreateRefundGhs';
    private final static String RETURN_RECEIVE_ENDPOINT_MDT = 'CreateReceiveRequest';
    private final static String ORDERITEM_INVENTORY_ENDPOINT_MDT = 'Order_Item_Inventory';
    private final static String CANCEL_ORDER_ENDPOINT_MDT = 'OrderCancel';
    private final static String WHOLE_ORDER_REFUND_ENDPOINT_MDT = 'WholeOrderRefundGhs';

    
    /**
* ****************************************************************************************************
* @param option Order History option (filters, sort, pagination)
* @description method to get Orders
* @return ASDAC_OrderHistoryResponse
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=true)
    public static ASDAC_OrderHistoryResponse getOrders(ASDAC_OrderHistoryOption option) {
        Boolean isGrocery = option.filters != null && option.filters.contains(ASDAC_OMSConstants.ASDA_GROCERIES_STRING);
        String integrationMetadata = isGrocery ? ORDER_HISTORY_GHS_ENDPOINT_MDT : ORDER_HISTORY_GEORGE_ENDPOINT_MDT;
            
        try {
            return ASDAC_OrderService.getOrders(option, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }
        catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
        }
    }
    
    /**
* ****************************************************************************************************
* @param orderId Order Id
* @description method to get a single Order
* @return ASDAC_OrderResponse
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static ASDAC_OrderResponse getOrder(String businessArea,String orderId,List<String> variables) {
        Boolean isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING || businessArea == ASDAC_OMSConstants.GROCERY_STRING);
        String integrationMetadata = isGrocery ? ORDER_DETAILS_GHS_ENDPOINT_MDT : ORDER_DETAILS_GEORGE_ENDPOINT_MDT;
            
        try {
            return ASDAC_OrderService.getOrder(businessArea, orderId, variables, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }
        catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(null, null));
        } finally {
        }
    }
    
    /**
* ****************************************************************************************************
* @param order order wrapper instance
* @description method to exchange an Order
* @return String
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String exchangeOrder(ASDAC_OrderWrapper order) {
        String integrationMetadata = EXCHANGE_ORDER_ENDPOINT_MDT;
            
        try {
            return ASDAC_OrderService.exchangeOrder(order, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }
        catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase(); // Allowed but gets Rollbacked as it is a DML
        }
    }
    
    /**
* ****************************************************************************************************
* @param order
* @description method to create a return preview request
* @return response String from Preview Request callout
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static ASDAC_ReturnPreviewResponse createReturnPreviewRequest(ASDAC_OrderWrapper order) {
        String businessArea = order.sellingChannel;
        Boolean isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING);
        String integrationMetadata = isGrocery ? RETURN_PREVIEW_GHS_ENDPOINT_MDT : RETURN_PREVIEW_GEORGE_ENDPOINT_MDT;
        
        try {
            return ASDAC_OrderService.createReturnPreviewRequest(order, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }
        catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase(); // Too many DML error
        }
    }
    
    /**
* ****************************************************************************************************
* @param order
* @description method to create a return request
* @return response String from Return Request callout
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String createReturnRequest(ASDAC_OrderWrapper order) {
        String businessArea = order.sellingChannel;
        Boolean isGrocery = (businessArea == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || businessArea == ASDAC_OMSConstants.GHS_STRING);
        String integrationMetadata = isGrocery ? GHS_REFUND_REQUEST_ENDPOINT_MDT : GEORGE_RETURN_REQUEST_ENDPOINT_MDT;
            
        try {
            
            return ASDAC_OrderService.createReturnRequest(order, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }
        catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase(); // Allowed but gets Rollbacked as it is a DML
        }
    }
    
    
    /**
* ****************************************************************************************************
* @param order
* @description method to create a Whole order Refund request
* @return response String from Whole order Refund Request callout
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String createWholeOrderRefundRequest(ASDAC_OrderWrapper order) {
        String integrationMetadata = WHOLE_ORDER_REFUND_ENDPOINT_MDT;
        try {
            return ASDAC_OrderService.createWholeOrderRefundRequest(order,integrationMetadata);
            
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase();
        }
    }
    
    /**
* ****************************************************************************************************
* @param order
* @description method to create a receive request
* @return response String from Receive Request callout
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String receiveRequest(ASDAC_OrderWrapper order) {
        String integrationMetadata = RETURN_RECEIVE_ENDPOINT_MDT;
        try {
            return ASDAC_OrderService.createReceiveRequest(order, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase(); // Allowed but gets Rollbacked as it is a DML
        }
    }
    
    /**
* ****************************************************************************************************
* @param order
* @description method to create a ATP request
* @return response String from Return Request callout
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static string createATPRequest(ASDAC_OrderWrapper order) {
        String integrationMetadata = ORDERITEM_INVENTORY_ENDPOINT_MDT;
        try {
           return JSON.serialize(ASDAC_OrderService.createOrderItemAvailabilityRequest(order, integrationMetadata));
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
        ASDAC_Logger.writeLogsToDatabase(); // Allowed but gets Rollbacked as it is a DML
        } 
    }

    /**
* ****************************************************************************************************
* @param personAccountId Id of Person account
* @description method to get Customer Id from Person account
* @return String
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=true)
    public static String getCustomerId(Id personAccountId) {
        return ASDAC_OrderService.getCustomerId(personAccountId);
    }
    
    /**
* ****************************************************************************************************
* @description method to get Order History Fields metadata
* @return List\<ASDAC_OrderHistoryField__mdt\>
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=true)
    public static List<ASDAC_OrderHistoryField__mdt> getOrderHistoryFields() {
        return ASDAC_OrderService.getOrderHistoryFields();
    }
    
    /**
* ****************************************************************************************************
* @param ex Exception object
* @param source Exception source
* @description method to log Exception
* ****************************************************************************************************
*/
    private static void logException(Exception ex, String source) {
        ASDAC_Logger.logException(ex, source, null, 'ASDAC_OrderController');
    }
    /**
* ****************************************************************************************************
* @param order order wrapper instance
* @description method to exchange an Order
* @return String
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String partialRefundOrder(ASDAC_OrderWrapper order) {
        String integrationMetadata = PARTIAL_REFUND_ENDPOINT_MDT;
        try {
            return ASDAC_OrderService.partialRefundOrder(order, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase(); // Allowed but gets Rollbacked as it is a DML
        }
    }
    
    /**
* ****************************************************************************************************
* @param order order wrapper instance
* @description method to refund delivery charge of an Order
* @return String
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String deliveryChargeRefundOrder(ASDAC_OrderWrapper order) {
        String integrationMetadata = SHIPPING_FEE_REFUND_ENDPOINT_MDT;
        try {
            return ASDAC_OrderService.deliveryChargeRefundOrder(order, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
        ASDAC_Logger.writeLogsToDatabase(); // Allowed but gets Rollbacked as it is a DML
        }
    }

    /**
    * ****************************************************************************************************
    * @description method to getGrocery order that returns orderFulfildate and assign in Case After Trigger Vat Receipt Flow.
    * @return orderFulfildate 
    * ****************************************************************************************************
    */
    @InvocableMethod(label='Get Grocery Order')
    public static List<String> getOrderFulfillDate(List<String> orderIdList) {
        String integrationMetadata =ORDER_DETAILS_GHS_ENDPOINT_MDT;
        List<String> returnResponse = new List<String>();
        if(orderIdList.size() > 0 && !orderIdList.isEmpty())
        {
        for (String orderId : orderIdList)
        {
            String response = '';
            if(String.isNotBlank(orderId)){
                
                try {
                    ASDAC_OrderResponse orderResponse = ASDAC_OrderService.getOrder(ASDAC_OMSConstants.ASDA_GROCERIES_STRING,orderId,new List<String>(),integrationMetadata);
                    response = string.valueOfGmt(orderResponse.orderFulfilledDate);
                  
                } catch (Exception e) {
                    response = '';
                }
            }
            returnResponse.add(response);
         }
          
        }
        return returnResponse;
        
    }
    
    /**
* ****************************************************************************************************
* @param order order wrapper instance
* @description method to Cancel order
* @return String
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String cancelOrder(ASDAC_OrderWrapper order) {
        String integrationMetadata = CANCEL_ORDER_ENDPOINT_MDT;
        try {
            return ASDAC_OrderService.cancelOrder(order, integrationMetadata);
        } catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        } catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase(); // Allowed but gets Rollbacked as it is a DML
        }
    }

        /**
* ****************************************************************************************************
* @param order
* @description method to create a ghs refund override request
* @return response String from refund override callout
* ****************************************************************************************************
*/
    @AuraEnabled(cacheable=false)
    public static String createRefundOverrideRequest(ASDAC_OrderWrapper order) {
        String integrationMetadata = GHS_REFUND_REQUEST_ENDPOINT_MDT;
            
        try {
            return ASDAC_OrderService.createRefundOverrideRequest(order, integrationMetadata);
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_OMS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        }
        catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        } finally {
            ASDAC_Logger.writeLogsToDatabase(); 
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String getStoreId(String storeNumber) {
        String storeId='';
        try {
          List<Store__c> storeList = new List<Store__c>();
          storeList = [SELECT Id,StoreNumber__c
                      FROM Store__c 
                      WHERE StoreNumber__c = :storeNumber WITH SECURITY_ENFORCED LIMIT 1];
        if (!storeList.isEmpty()){
          storeId=storeList[0].Id;
            }
            
     return storeId;
            
        } catch (Exception ex) {
        logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
        throw ex;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getUserGroups(Id userId) {
        List<String> userGroups = new List<String>();
        List<GroupMember> groupMembers = [
            SELECT Group.Name 
            FROM GroupMember 
            WHERE UserOrGroupId = :userId
        ];
        for (GroupMember gm : groupMembers) {
            userGroups.add(gm.Group.Name);
        }
        return userGroups;
    }
    
}