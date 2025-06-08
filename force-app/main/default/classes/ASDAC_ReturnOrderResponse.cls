public with sharing class ASDAC_ReturnOrderResponse {
    @AuraEnabled
    public String orderId;
    @AuraEnabled
    public String sellingChannel;
    @AuraEnabled
    public String customerId;
    @AuraEnabled
    public String orderType;
    @AuraEnabled
    public Datetime orderDate;
    @AuraEnabled
    public String formattedOrderDate {
        get {
            return ASDAC_OrderUtility.convertDateTimeString(orderDate);
        }
    }
    @AuraEnabled
    public String createUser;
    @AuraEnabled
    public String source;
    @AuraEnabled
    public String orderCategory;
    @AuraEnabled
    public Datetime actualArrivalTime;
    @AuraEnabled
    public Boolean isAccountSuspended {
        get{
            return isAccountSuspended != null && isAccountSuspended;
        }
        set {
            isAccountSuspended = value;
            for (ASDAC_OrderLineItemResponse orderLine : orderItems) {
                orderLine.isAccountSuspended = isAccountSuspended;
            }
        } 
    }
   
    public List<ASDAC_OrderLineItemResponse> orderLines;
    @AuraEnabled
    public List<ASDAC_OrderLineItemResponse> orderItems {
        get {
            return orderLines;
        }
    }

    @AuraEnabled
    public Boolean disableReceiveButton {
        get {
            for (ASDAC_OrderLineItemResponse orderItem : orderItems) {
                if (orderItem.isRecieveDisabled == true) {
                    continue;
                } else {
                    return false;
                }
            }
            return true;
        }
    }

    public void transformOrderLines() {
        Boolean isGeorge = sellingChannel == ASDAC_OMSConstants.GEORGECOM_STRING;
        if (isGeorge) {
            transformGeorgeOrderLines();
        }
    }

    private void transformGeorgeOrderLines() {
        for (ASDAC_OrderLineItemResponse orderLine : orderLines) {
            orderLine.orderType = ASDAC_OMSConstants.RETURN_ORDER;
            orderLine.isGeorge = true;
            orderLine.source  = source;
        }
        orderLines = ASDAC_OrderUtility.transformOrderLines(orderLines);
    }

}