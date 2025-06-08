public with sharing class ASDAC_OrderResponse {
    
    private static Schema.SObjectField cancelField = ASDAC_OrderDetailsButtonsVisibility__mdt.Cancel__c;
    private static Schema.SobjectField discountField = ASDAC_OrderDetailsButtonsVisibility__mdt.Discount__c;
    private static Schema.SobjectField exchangeField = ASDAC_OrderDetailsButtonsVisibility__mdt.Exchange__c;
    private static Schema.SobjectField refundField = ASDAC_OrderDetailsButtonsVisibility__mdt.Refund__c;
    private static Schema.SobjectField recieveField = ASDAC_OrderDetailsButtonsVisibility__mdt.Recieve__c;
    private static Schema.SobjectField ghsRefundField = ASDAC_OrderDetailsButtonsVisibility__mdt.GhsRefund__c;
    private static Set<Schema.SObjectField> mdtActionFields = new Set<Schema.SObjectField>{ cancelField, discountField, exchangeField, refundField, recieveField, ghsRefundField};
        private static Map<Schema.SObjectField, Set<String>> lineItemStatusMap = new Map<Schema.SObjectField, Set<String>>();
    
    static {
        for (Schema.SObjectField action : mdtActionFields) {
            lineItemStatusMap.put(action, new Set<String>());
        }
        for (ASDAC_OrderDetailsButtonsVisibility__mdt rec : ASDAC_OrderDetailsButtonsVisibility__mdt.getAll().values()) {
            for (Schema.SObjectField action : mdtActionFields) {
                if (rec.get(action) != null && (Boolean) rec.get(action)) {
                    lineItemStatusMap.get(action).add(rec.OrderItemStatus__c.toUpperCase());
                }
            }
        }
    }
    
    public Boolean isActionPossible(Schema.SObjectField actionField) {
        return lineItemStatusMap.get(actionField).contains(orderStatus?.toUpperCase());
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
    
    private static Map<String, Map<String,String>> mdtCancelledByMap = new Map<String, Map<String,String>>();
    static {
        List<ASDAC_OMSToSFSCCancelledByMapping__mdt> cancelledByMappingMdt = ASDAC_OMSToSFSCCancelledByMapping__mdt.getAll().values();
        for(ASDAC_OMSToSFSCCancelledByMapping__mdt rec: cancelledByMappingMdt){
            String businessArea = rec.Business_Area__c.toUpperCase();
            String omsValue = rec.OMS_value__c;
            String sfscValue = rec.SFSC_value__c;
            
            if(!mdtCancelledByMap.containsKey(businessArea)){
                mdtCancelledByMap.put(businessArea, new Map<String, String>());
            }
            mdtCancelledByMap.get(businessArea).put(omsValue, sfscValue);
        }
    }
    
    private String updatecancelledByString(String businessArea, String omsValue){
        if(!mdtCancelledByMap.containsKey(businessArea)){
            return omsValue;
        }
        else{
            Map<String, String> fieldMap = mdtCancelledByMap.get(businessArea);
            if(!fieldMap.containsKey(omsValue)){
                return omsValue;
            }
            else{
                return fieldMap.get(omsValue);
            }
        }
    }    

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
    
    @AuraEnabled
    public String orderId;
    @AuraEnabled
    public String salesOrderId;
    @AuraEnabled
    public String sellingChannel;
    @AuraEnabled
    public String customerId;
    @AuraEnabled
    public String orderCategory;
    @AuraEnabled
    public List<String> yNumbers; 
    @AuraEnabled
    public String orderType;
    @AuraEnabled
    public Datetime plannedArrivalTime;
    @AuraEnabled
    public Boolean eVouchersAsDiscount;
    @AuraEnabled
    public  string formattedPlannedArrivalTime {
        get {
            return ASDAC_OrderUtility.convertStringToDateString(plannedArrivalTime);
        }
    }
    @AuraEnabled
    public  string formattedPlannedArrivalTimeInTrack {
        get {
            return ASDAC_OrderUtility.dateTimeFormat(plannedArrivalTime);
        }
    }
    @AuraEnabled
    public String orderFulfilmentTypeGrocery{
        get{
            return getFulfillmentType(fulfillmentType, fulfillmentService);
        }
        set;   
    }
    @AuraEnabled
    public String orderFulfilmentType;
    @AuraEnabled
    public String fulfillmentType;
    @AuraEnabled
    public String fulfillmentService;
    @AuraEnabled
    public Decimal originalOrderTotal; 
    @AuraEnabled
    public Decimal totalAmount; 
    @AuraEnabled
    public Datetime orderDate;
    @AuraEnabled
    public Datetime orderPlacedDate;
    @AuraEnabled
    public String formattedOrderDate {
        get {
            return ASDAC_OrderUtility.convertDateTimeString(orderDate);
        }
    }
    @AuraEnabled
    public String source;
    @AuraEnabled
    public String createUser;
    @AuraEnabled
    public Boolean hasColleagueDiscount;
    @AuraEnabled
    public String colleagueDiscountAmount;
    @AuraEnabled
    public Decimal colleagueDiscount;
    @AuraEnabled
    public String fraudStatus;
    @AuraEnabled
    public Decimal originalShippingCharge;
    @AuraEnabled
    public Decimal deliveryPassDiscount;
    @AuraEnabled
    public Decimal marketingShippingDiscount;
    @AuraEnabled
    public Decimal originalDeliveryCharge{
        get{
            Boolean isGeorge = sellingChannel == ASDAC_OMSConstants.GEORGECOM_STRING;
            if(isGeorge){
                return originalDeliveryCharge;
            }
            else {
               return originalDeliveryCharge - ((deliveryPassDiscount != null) ? deliveryPassDiscount : 0)- ((marketingShippingDiscount != null) ? marketingShippingDiscount : 0);
            }
        }
    }
    @AuraEnabled
    public Decimal deliveryChargeRefund;
    @AuraEnabled
    public Decimal currentDeliveryCharge {
        get {
            return (originalDeliveryCharge > 0 ? originalDeliveryCharge : 0) - (deliveryChargeRefund > 0 ? deliveryChargeRefund : 0);
        }
        set;
    }
    
    public boolean isDeliveryChargeRefunded{
        get{
            if(isDeliveryChargeRefunded != null){
                return isDeliveryChargeRefunded;
            }
            else{
                return true;
            }
        }
    }

       
    @AuraEnabled
    public boolean isDeliveryChargeRefundDisabled{
        get {
            if(!isAccountSuspended && ASDAC_OrderUtility.hasOrderActionsPermission() && !isDeliveryChargeRefunded){
                return false;
            }
            return true;
        }
    }
    
    @AuraEnabled
    public Datetime orderFulfilledDate; 

    @AuraEnabled
    public Boolean isCancelled {
        get {
            return orderStatus == ASDAC_OMSConstants.CANCELLED_STRING;
        }
    }
    @AuraEnabled
    public String orderCancelledBy{
        get{
            return updatecancelledByString(ASDAC_OMSConstants.GROCERY_STRING, orderCancelledBy);
        }
        set;
    }
    @AuraEnabled
    public Datetime orderCancelledOn; 
    @AuraEnabled
    public String formattedOrderCancelledOn{
        get{
            return  ASDAC_OrderUtility.convertDateTimeString(orderCancelledOn);
        }
    }
    @AuraEnabled
    public Datetime orderCancelledByStore;
    @AuraEnabled
    public String storeNumber;    // GHS store number	
    @AuraEnabled
    public Datetime actualArrivalTime;
    @AuraEnabled
    public String formattedActualArrivalTime{
        get{
            return ASDAC_OrderUtility.dateTimeFormat(actualArrivalTime);
        }
    }
    // GHS Progress bar
    @AuraEnabled
    public String orderStatus;
    @AuraEnabled
    public String orderLevelStatus
    {
        get{
            return updateStatusString(ASDAC_OMSConstants.GROCERY_STRING, orderStatus);
        }
    }
    @AuraEnabled
    public String status {
        get {
            return ASDAC_OmsProgressMappingSelector.findBy(fulfillmentType, orderStatus)?.StatusLabel__c;
        }
    }
    @AuraEnabled
    public Integer progressDot {
        get {
            return ASDAC_OmsProgressMappingSelector.findBy(fulfillmentType, orderStatus)?.ProgressDot__c?.intValue();
        }
    }
    
    //Payment Summary
    @AuraEnabled
    public Decimal orderTotal;
    @AuraEnabled
    public Decimal productRefund;
    @AuraEnabled
    public Decimal shippingRefund;
    @AuraEnabled
    public Decimal partialRefund;
    @AuraEnabled
    public Decimal goodwillRefund;
    @AuraEnabled
    public Decimal orderSubTotal;
    @AuraEnabled
    public Decimal refundTotal;
    @AuraEnabled
    public Decimal originalOrderDiscount;
    @AuraEnabled
    public Decimal promotionalDiscount;
    @AuraEnabled
    public Decimal originalVAT;
    @AuraEnabled
    public List<ASDAC_OrderPaymentMethodResponse> paymentDetails;     
    @AuraEnabled
    public List<ASDAC_OrderPaymentMethodResponse> paymentMethods;
    @AuraEnabled
    public List<ASDAC_OrderPaymentMethodResponse> paymentMethodList = new List<ASDAC_OrderPaymentMethodResponse>();
   
    public List<ASDAC_OrderLineItemResponse> orderLines;
    
    @AuraEnabled
    public Map<String, list<ASDAC_OrderLineItemResponse>> fulfillmentCenters;
    
    @AuraEnabled
    public List<ASDAC_OrderLineItemResponse> orderItems {
        get {
            return orderLines;
        }
    }
    
    @AuraEnabled
    public List<ASDAC_OrderCharges> charges;
    
    @AuraEnabled
    public List<ASDAC_OrderDiscountRequest> discounts;

    @AuraEnabled
    public List<ASDAC_ReturnOrderResponse> returnOrders {
        get {
            if (returnOrders == null) {
                return new List<ASDAC_ReturnOrderResponse>();
            }
            return returnOrders;
        }
        set;
    }

    @AuraEnabled
    public Map<String, list<ASDAC_OrderLineItemResponse>> refundedItemsMap;
    
    @AuraEnabled
    public List<ASDAC_OrderResponse> exchangeOrders {
        get {
            if (exchangeOrders == null) {
                return new List<ASDAC_OrderResponse>();
            }
            return exchangeOrders;
        }
        set;
    }
    
    @AuraEnabled
    public Integer exchangedItemsCount {
        get {
            Integer count = 0;
            for (ASDAC_OrderResponse exchangedOrder : exchangeOrders) {
                count += exchangedOrder.orderLines.size();
            }
            return count;
        }
    }
    
    // Customer details
    @AuraEnabled
    public String customerType;
    @AuraEnabled
    public String customerRiskStatus = ASDAC_OMSConstants.CUSTOMERISKSTATUS;
    @AuraEnabled
    public String customerSalesforceAccId;
    @AuraEnabled
    public String customerSalesforceConId;
    @AuraEnabled
    public Boolean isUnderAudit;
    @AuraEnabled
    public Boolean isAccountSuspended {
        get{
            return isAccountSuspended != null && isAccountSuspended;
        }
        set {
            isAccountSuspended = value;
            for(ASDAC_ReturnOrderResponse rtnordr: returnOrders){
                rtnordr.isAccountSuspended = isAccountSuspended;
            }
            for (ASDAC_OrderLineItemResponse orderLine : orderLines) {
                orderLine.isAccountSuspended = isAccountSuspended;
            }
        } 
    }
    @AuraEnabled
    public String suspensionReason;
    @AuraEnabled
    public String suspensionDate;
    
    
    @AuraEnabled
    public String underAuditInformation;
     @AuraEnabled
    public String underAuditDate;
    
    // TBC
    @AuraEnabled
    public String state;
    public String billingCurrency;
    @AuraEnabled
    public String currencyISOCode {
        get {
            return ASDAC_OMSConstants.CURRENCYISOCODE;
        }
    }
    @AuraEnabled
    public String billToContactName;
    @AuraEnabled
    public String billToContactEmail;
    @AuraEnabled
    public String billToContactPhone;
    @AuraEnabled
    public Date estimatedOrderDeliveryDate;
    @AuraEnabled
    public Date orderCutOffDate;
    @AuraEnabled
    public Integer percOrderComplete;
    @AuraEnabled
    public Boolean isOrderDelivered;
    @AuraEnabled
    public Integer refundedItemsCount = ASDAC_OMSConstants.INTEGER_ZERO; 
    
    @AuraEnabled
    public Integer partialRefundItemsCount = ASDAC_OMSConstants.INTEGER_ZERO; 
    @AuraEnabled
    public Integer unavailableItemsCount = ASDAC_OMSConstants.INTEGER_ZERO; 
    @AuraEnabled
    public List<ASDAC_OrderAddressInfo> addressInfo;
    @AuraEnabled 
    public ASDAC_OrderContact billToContact;
    @AuraEnabled 
    public String customerPhone;
    @AuraEnabled
    public ASDAC_OrderAddress billToAddress = new ASDAC_OrderAddress();
    public ASDAC_OrderAddress shipToAddress = new ASDAC_OrderAddress();
    @AuraEnabled
    public String shippingAddress {
        get {
            Boolean isGeorge = sellingChannel == ASDAC_OMSConstants.GEORGECOM_STRING;
            if(isGeorge){
            return ASDAC_OrderUtility.getAddressString(orderLines[0].shipToAddress);
            }
            return ASDAC_OrderUtility.getAddressString(shipToAddress);
        }
    }
    @AuraEnabled
    public String fulfilmentStore='ASDA FC - Lymdale';
    @AuraEnabled
    public String deliveryNote;
    
    @AuraEnabled
    public String shippingFee;
    
    // GHS Order Level Refund Attributes
    @AuraEnabled
    public Decimal subTotal;
    @AuraEnabled
    public Decimal currentSubtotal{
        get{
            return (currentSubtotal!=null) ? currentSubtotal - currentCharitableDonation : 0.00;
        }
    }
    @AuraEnabled
    public Decimal deliveryfee;
    @AuraEnabled
    public Decimal minimumBasketCharge;
    @AuraEnabled
    public Decimal charitableDiscount;
    @AuraEnabled
    public Decimal eVoucherAmount;
    @AuraEnabled
    public Decimal multisaveDiscount;
    @AuraEnabled
    public Decimal refundAmount;
    @AuraEnabled
    public Decimal giftcardAmount;
    @AuraEnabled
    public Decimal marketingCouponAmount;
    
    // Rewards Discount Modal
    @AuraEnabled
    public Decimal asdaRewardDiscount;
    @AuraEnabled
    public List<ASDAC_RewardVoucher> rewardVouchers;
    
    // For GHS tracking Modal bringg Url
    @AuraEnabled public String wismoURL;

    @AuraEnabled
    public Decimal charitableDonation;
    @AuraEnabled
    public Decimal currentCharitableDonation;
    @AuraEnabled
    public Datetime cutOffDate;
    @AuraEnabled
    public String formattedcutOffDate{
        get{
            return ASDAC_OrderUtility.cutoffdateTimeFormat(cutOffDate);
        }
    }
    @AuraEnabled
    public String deliveryWindow;
    @AuraEnabled
    public Datetime departureTime;
    @AuraEnabled
    public String formattedDepartureTime{
        get{
            return ASDAC_OrderUtility.timeFormat(departureTime);
        }
    }
    @AuraEnabled
    public Boolean hasRefundedItem;
    @AuraEnabled
    public Boolean isDeliveryPassUsed;
    @AuraEnabled
    public Boolean isPersonalisedPromotion;

    // For exchange orders
    @AuraEnabled
    public Boolean isExchangeOrder {
        get {
            return 'ExchangeOrder'.equalsIgnoreCase(orderType);
        }
    }
    
    @AuraEnabled
    public String fulfillmentCentre {
        get {
            if (!orderLines.isEmpty() && orderLines[0].shipmentDetails != null && !orderLines[0].shipmentDetails.isEmpty()) {
                return orderLines[0].shipmentDetails[0].fulfillmentCentre;
            }
            return null;
        }
    }
    
    @AuraEnabled
    public String vatRegistrationNumber;
    @AuraEnabled
    public Datetime vatDate = Datetime.now();
    @AuraEnabled
    public List<ASDAC_TotalVatDetailsWrapper> totalVatDetails = new List<ASDAC_TotalVatDetailsWrapper>();
    @AuraEnabled
    public Decimal vatRateDeliveryCharge;
    @AuraEnabled
    public Decimal vatAmountDeliveryCharge;
    @AuraEnabled
    public Decimal vatExDeliveryCharge;
    @AuraEnabled
    public Decimal vatAmount;
    @AuraEnabled
    public Decimal vatTotalPrice;
    
    @AuraEnabled
    public String deliveryChargeReferenceId;
    @AuraEnabled
    public String deliveryChargeReferenceType;
    @AuraEnabled
    public String minimumBasketChargeReferenceId;
    @AuraEnabled
    public String minimumBasketChargeReferenceType;
    @AuraEnabled
    public Decimal currentMinimumBasketCharge;
    @AuraEnabled
    public String cancellationReasonCode;
    @AuraEnabled
    public String cancellationReason;
    @AuraEnabled
    public Decimal refundableAmount;
    
    public class TotalWrapper {
        @AuraEnabled public String subtotal;
        @AuraEnabled public String tax;
        @AuraEnabled public String totalAmount;
        @AuraEnabled public String charges;
        @AuraEnabled public String discounts;
    }
    
    public void setCustomerDetails(Account accObj) {
        customerSalesforceAccId = accObj?.Id;
        customerSalesforceConId = accObj?.PersonContactId;
        customerType = accObj?.AccountRegistrationStatus__c;
        isUnderAudit=accObj?.IsUnderAudit__c;
        isAccountSuspended = accObj?.Status__c=='Suspended';
        suspensionReason = accObj?.SuspensionReason__c;
        if(accObj?.SuspendedDate__c != null){
        	suspensionDate= ASDAC_OrderUtility.convertStringToDateTimeString(String.ValueOf(accObj?.SuspendedDate__c));
        }
        underAuditInformation =accObj?.Under_Audit_Info__c; 
        if(accObj?.UnderAuditDatetime__c != null){
        underAuditDate = ASDAC_OrderUtility.convertStringToDateTimeString(String.ValueOf(accObj?.UnderAuditDatetime__c));
        }
        
    }

    public void transformOrderLines() {
        Boolean isGeorge = sellingChannel == ASDAC_OMSConstants.GEORGECOM_STRING;
        if (isGeorge) {
            transformGeorgeOrderLines();
        } else {
             groceryOrderLines();
        }
    }

    private void transformGeorgeOrderLines() {
        for (ASDAC_OrderLineItemResponse orderLine : orderLines) {
            orderLine.orderType = ASDAC_OMSConstants.SALES_ORDER;
            orderLine.orderFulfilmentType = orderFulfilmentType;
            orderLine.storeNumber = storeNumber;
            orderLine.isGeorge = true;
        }
        orderLines = ASDAC_OrderUtility.transformOrderLines(orderLines);
        for (ASDAC_ReturnOrderResponse returnOrder : returnOrders) {
            returnOrder.sellingChannel = sellingChannel;
            returnOrder.transformOrderLines();
        }
        for (ASDAC_OrderResponse exchangeOrder : exchangeOrders) {
            exchangeOrder.sellingChannel = sellingChannel;
            exchangeOrder.transformOrderLines();
        }
    }
    
    private void groceryOrderLines() {
        transformGroceryOrderLines();
        if (returnOrders != null && returnOrders.size() > 0) {
            ASDAC_OrderUtility.transformGroceryReturnOrderLines(returnOrders);
        } 
    }

    private void transformGroceryOrderLines() {
        Boolean isGhsRefundPossible;
        Map<String, ASDAC_ExtendedWarrentyProductType__mdt> extendedProductTypesMap = new Map<String, ASDAC_ExtendedWarrentyProductType__mdt> ();
        for (ASDAC_ExtendedWarrentyProductType__mdt extProductType : [SELECT ProductType__c, MaxWarrentyPeriod__c FROM ASDAC_ExtendedWarrentyProductType__mdt]) {
            extendedProductTypesMap.put(extProductType.ProductType__c, extProductType);
        }

        for (ASDAC_OrderLineItemResponse orderLine : orderLines) {
            if (extendedProductTypesMap.containsKey(orderLine.productType)) {
                ASDAC_ExtendedWarrentyProductType__mdt extProductType = extendedProductTypesMap.get(orderLine.productType);
                Integer warrantyPeriodInMonths = Integer.valueOf(extProductType.MaxWarrentyPeriod__c);
                isGhsRefundPossible = isActionPossible(ghsRefundField) && actualArrivalTime != null && actualArrivalTime.date().addMonths(warrantyPeriodInMonths).daysBetween(Date.today()) <= 0;
            } else {
                isGhsRefundPossible = isActionPossible(ghsRefundField) && actualArrivalTime != null && actualArrivalTime.date().addDays(30).daysBetween(Date.today()) <= 0;
            }
            orderLine.isGhsRefundPossible = isGhsRefundPossible;
            orderLine.isGeorge = false;
        }
        orderLines = ASDAC_OrderUtility.transformGrocerySubstituteItems(orderLines);
    }
    
    @AuraEnabled
    public Boolean isStoreCancelDisabled {
        get {
            if(!isAccountSuspended && ASDAC_OrderUtility.hasOrderActionsPermission() && isActionPossible(cancelField))
            {
                    return false;
                }
            return true;
            
        }
    }
    
    @AuraEnabled
    public Boolean isCancelDisabled {
        get {
            if(!isAccountSuspended && ASDAC_OrderUtility.hasOrderActionsPermission() && orderStatus== 'CREATED')
            {
                return false;
            }
            return true;            
        }
    }
    
    @AuraEnabled
    public Boolean isRefundDisabled {
        get {
            for (ASDAC_OrderLineItemResponse lineItem : orderLines) {
                if (!lineItem.isRefundDisabled) {
                    return false;
                }
            }
            return true;
        }
    }
    
    @AuraEnabled
    public Boolean isExchangeDisabled {
        get {
            for (ASDAC_OrderLineItemResponse lineItem : orderLines) {
                if (!lineItem.isExchangeDisabled) {
                    return false;
                }
            }
            return true;
        }
    }
    
    @AuraEnabled
    public Boolean isDiscountDisabled {
        get {
            for (ASDAC_OrderLineItemResponse lineItem : orderLines) {
                if (!lineItem.isDiscountDisabled) {
                    return false;
                }
            }
            return true;
        }
    }

    @AuraEnabled
    public Boolean isOverrideAllDisabled{
        get {
            for (ASDAC_ReturnOrderResponse order : returnOrders) {
                for (ASDAC_OrderLineItemResponse lineItem : order.orderItems) {
                    if (!lineItem.isOverrideDisabled) {
                        return false;
                    }
                }
            }
            return true;
        }
    }
    
    @AuraEnabled
    public Boolean isGhsRefundDisabled {
        get {
           return !(ASDAC_OrderUtility.hasOrderActionsPermission() && isActionPossible(ghsRefundField) && (totalAmount > 0));
        }
    }

    @AuraEnabled
    public Boolean ghsOrderLevelRefundDisabled{
        get{
            Boolean ghsLineLevelRefundDisabled = true;
            for (ASDAC_OrderLineItemResponse item : orderItems) {
                if (!item.isGhsRefundDisabled) {
                    ghsLineLevelRefundDisabled = false;
                    break;
                }
            }
            return isGhsRefundDisabled || ghsLineLevelRefundDisabled;
        }
    }
    
    @AuraEnabled
    public Boolean hasExchangeOrder{
        get {
            if(exchangeOrders?.size() <= 0){
                return false;
            }
            return true;
        }
    }
    
    @AuraEnabled
    public Boolean isVATEnabled {
        get {
            if (orderFulfilledDate== null) {
                return true;
            }
            DateTime currentDateTime = DateTime.now();
            if(ASDAC_OrderUtility.hasOrderActionsPermission() && orderStatus == ASDAC_OMSConstants.FULFILLED_STATUS && currentDateTime >= orderFulfilledDate.AddDays(7) && currentDateTime <= orderFulfilledDate.AddDays(372)){
                return false;
            }
            return true;
        }
    }
}