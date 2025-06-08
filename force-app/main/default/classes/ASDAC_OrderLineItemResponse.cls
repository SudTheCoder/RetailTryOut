public with sharing virtual class ASDAC_OrderLineItemResponse {
    private static Schema.SObjectField cancelField = ASDAC_OrderDetailsButtonsVisibility__mdt.Cancel__c;
    private static Schema.SobjectField discountField = ASDAC_OrderDetailsButtonsVisibility__mdt.Discount__c;
    private static Schema.SobjectField exchangeField = ASDAC_OrderDetailsButtonsVisibility__mdt.Exchange__c;
    private static Schema.SobjectField refundField = ASDAC_OrderDetailsButtonsVisibility__mdt.Refund__c;
    private static Schema.SobjectField recieveField = ASDAC_OrderDetailsButtonsVisibility__mdt.Recieve__c;
    private static Schema.SobjectField ghsRefundField = ASDAC_OrderDetailsButtonsVisibility__mdt.GhsRefund__c;
    private static Schema.SobjectField overrideField = ASDAC_OrderDetailsButtonsVisibility__mdt.Override__c;
    private static Schema.SobjectField georgeTrackingField = ASDAC_OrderDetailsButtonsVisibility__mdt.GeorgeTracking__c;
    private static Set<Schema.SObjectField> mdtActionFields = new Set<Schema.SObjectField>{ cancelField, discountField, exchangeField, refundField, recieveField, ghsRefundField,overrideField,georgeTrackingField};
    private static Map<Schema.SObjectField, Set<String>> lineItemStatusMap = new Map<Schema.SObjectField, Set<String>>();
    private static Map<String,String> fcDsvMdtMap = new Map<String,String>();

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
    
    private static Map<String, Map<String, Map<String, List<ASDAC_OMSToSFSCStatusMapping__mdt>>>> mdtStatusMap = new Map<String, Map<String, Map<String, List<ASDAC_OMSToSFSCStatusMapping__mdt>>>>();
    static {
        List<ASDAC_OMSToSFSCStatusMapping__mdt> statusMappingMdt = ASDAC_OMSToSFSCStatusMapping__mdt.getAll().values();
        for(ASDAC_OMSToSFSCStatusMapping__mdt rec: statusMappingMdt){
            String orderType = rec.ASDAC_OrderType__c;
            String businessArea = rec.ASDAC_BusinessArea__c;
            String omsStatus = rec.ASDAC_OMSStatus__c;
            if(!mdtStatusMap.containsKey(businessArea)){
                mdtStatusMap.put(businessArea, new Map<String, Map<String, List<ASDAC_OMSToSFSCStatusMapping__mdt>>>());
            }
            if(!mdtStatusMap.get(businessArea).containsKey(orderType)){
                mdtStatusMap.get(businessArea).put(orderType, new Map<String, List<ASDAC_OMSToSFSCStatusMapping__mdt>>());
            }
            if (!mdtStatusMap.get(businessArea).get(orderType).containsKey(omsStatus)) {
                mdtStatusMap.get(businessArea).get(orderType).put(omsStatus, new List<ASDAC_OMSToSFSCStatusMapping__mdt>());
            }
            mdtStatusMap.get(businessArea).get(orderType).get(omsStatus).add(rec);
        }
    }
    
    private String updateStatusString(String orderType, String omsStatus){
        Map<String, Map<String, List<ASDAC_OMSToSFSCStatusMapping__mdt>>> mdtStatusMapByBussiness = new Map<String, Map<String, List<ASDAC_OMSToSFSCStatusMapping__mdt>>>();
        String statusString = omsStatus;
        if (isGeorge == false) {
            mdtStatusMapByBussiness = mdtStatusMap.get('Grocery');
        } else {
            mdtStatusMapByBussiness = mdtStatusMap.get('George');
        }
        if(mdtStatusMapByBussiness != null && mdtStatusMapByBussiness.containsKey(orderType)){
            Map<String, List<ASDAC_OMSToSFSCStatusMapping__mdt>> mdtRecords = mdtStatusMapByBussiness.get(orderType);
            if(mdtRecords.containsKey(omsStatus)){                
                for (ASDAC_OMSToSFSCStatusMapping__mdt mdtRecord: mdtRecords.get(omsStatus)) {
                    if(String.isNotBlank(mdtRecord.ASDAC_OMSREASONCODE__c) && mdtRecord.ASDAC_OMSREASONCODE__c == reasonCode){
                        statusString =  mdtRecord.ASDAC_SFSCStatus__c;
                        break;
                    } else if(String.isBlank(mdtRecord.ASDAC_OMSREASONCODE__c)) {
                        statusString =  mdtRecord.ASDAC_SFSCStatus__c;
                    }
                }
            }
        }
        return statusString;
    }
    
    public Boolean isActionPossible(Schema.SObjectField actionField) {
        return lineItemStatusMap.get(actionField).contains(status.toUpperCase());
    }
    
    @AuraEnabled
    public Integer orderLineId;
    public String source;
    public Boolean isGeorge;
    public String reasonCode;
    public String orderType; // To be removed after Return order line response is created
    @AuraEnabled
    public String lineStatus {
        get {
            return updateStatusString(orderType, status);
        }
    }
    public Boolean isAccountSuspended {
        get {
            return isAccountSuspended != null && isAccountSuspended;
        }
        set;
    }
    public Boolean isGhsRefundPossible {
        get {
            return isGhsRefundPossible != null && isGhsRefundPossible;
        }
        set;
    }
    @AuraEnabled
    public Boolean isGhsRefundDisabled {
        get {
            return !(hasOrderActionsPermission && isGhsRefundPossible && refundableQuantity > 0.0 && discountedPrice > 0);
        }
    }
    @AuraEnabled
    public Boolean isGhsRefundVisible {
        get {
            if(hasSubstitute!=null && refundableQuantity!=null ){
                return !hasSubstitute || (hasSubstitute && refundableQuantity>0.0);
            }
            return false;
        }
        set;
    }
    
    @AuraEnabled
    public Boolean isCancelDisabled {
        get {
            return !(hasOrderActionsPermission && isActionPossible(cancelField));
        }
    }

    @AuraEnabled
    public Boolean canOverride;

    @AuraEnabled
    public Boolean isOverridePossible {
        get {
            return isOverridePossible != null && isOverridePossible;
        }
        set;
    }

    @AuraEnabled
    public Boolean isOverrideDisabled {
        get {
            return !(hasOrderActionsPermission && isActionPossible(overrideField) && isOverridePossible && canOverride);
        }
    }
	
    public Boolean isGeorgeActionDisabled(){
       
        if(ASDAC_OMSConstants.CLICKNCOLLECT.equalsIgnoreCase(orderLineType) && 
            (ASDAC_OMSConstants.SHIPPED_STRING.equalsIgnoreCase(status) || 
             ASDAC_OMSConstants.TERMINAL_SHIPPED_STRING.equalsIgnoreCase(status) || 
             ASDAC_OMSConstants.OUT_FOR_DELIVERY_STRING.equalsIgnoreCase(status))
        ){
            return true;
        }
        return false;
    }
    
    public Boolean canRefund() {
        if (isBundle) {
            return bundleItems.size() > 0 && bundleItems[0].canRefund();
        }
        if(isGeorgeActionDisabled()){
            return false;
        }
        return isActionPossible(refundField);
    }

    @AuraEnabled
    public Boolean isRefundDisabled {
        get {
            return !(hasOrderActionsPermission && canRefund());
        }
    }

    public Boolean canExchange() {
        if (orderLineType == ASDAC_OMSConstants.CLICKNCOLLECT) {
            return false;
        }
        if (isBundle) {
            for (ASDAC_OrderLineItemResponse bundleItem : bundleItems) {
                if (!bundleItem.canExchange()) {
                    return false;
                }
            }
            return true;
        }
        if(isGeorgeActionDisabled()){
            return false;
        }
        return isActionPossible(exchangeField);
    }

    @AuraEnabled
    public Boolean isExchangeDisabled {
        get {
            return !(hasOrderActionsPermission && canExchange());
        }
    }
    @AuraEnabled
    public Boolean isPartiallyRefunded = false;
    
    @AuraEnabled
    public Boolean isDiscountDisabled {
        get {
            if(isPartiallyRefunded!=null){
               return (!isPartiallyRefunded ) ? !(hasOrderActionsPermission && (!isGeorgeActionDisabled() && isActionPossible(discountField))) : isPartiallyRefunded;
            }else{
               return !(hasOrderActionsPermission && (!isGeorgeActionDisabled() && isActionPossible(discountField)));
            }
        }
    }
    
    @AuraEnabled
    public Boolean isRecieveDisabled {
        get {
            if(isReceivable!=null){
                return !isReceivable || isBundle || !hasOrderActionsPermission || !isActionPossible(recieveField) || isAccountSuspended;
            }
            return false;    
        }
    }
    
    @AuraEnabled
    public Boolean hasOrderActionsPermission {
        get {
            return !isAccountSuspended && ASDAC_OrderUtility.hasOrderActionsPermission();
        }
    }

    @AuraEnabled public Boolean isCreatedFromExchange; // will be coming from AIS directly, true is a return order is created from Exchange order
    @AuraEnabled
    public Boolean isBundle {
        get {
            return isBundle != null && isBundle;
        }
        set;
    }
    @AuraEnabled
    public Integer parentId;
    @AuraEnabled
    public String substitutedId;
    @AuraEnabled
    public Boolean hasSubstitute = false;
    @AuraEnabled
    public boolean isSubstitutedLine;
    @AuraEnabled
    public boolean isPersonalisedPromotion;
    @AuraEnabled public Boolean isCharitableProduct;
    @AuraEnabled public String lineId {
        get {
            return String.valueOf(orderLineId);
        }
    }
    @AuraEnabled public String orderLineType;
    @AuraEnabled public String fulfillmentService;
    @AuraEnabled public String fulfillmentType;
    @AuraEnabled public String fulfillmentCentre;     //// Not present in mapping sheet
    @AuraEnabled public String orderLifecycleStatus; // not is use
    @AuraEnabled public String lastUpdatedTime;
    @AuraEnabled public String formattedLastUpdatedTime {
        get {
            return ASDAC_OrderUtility.convertStringToDateTimeString(lastUpdatedTime);
        }
    }
    @AuraEnabled public Datetime dateTimeReceived;
    @AuraEnabled public String formattedDateTimeReceived{
        get{
            return ASDAC_OrderUtility.convertDateTimeString(dateTimeReceived);
        }
    }
    @AuraEnabled public String receiptedUserName;
    @AuraEnabled public String formattedstateUpdatedTime{
        get{
            if(stateToQty != null){
                return ASDAC_OrderUtility.convertDateTimeString(stateToQty[0].stateUpdatedTime);
            }else{
                return '';
            }            
        }
    }
    @AuraEnabled public ASDAC_OrderContact shipToContact;
    @AuraEnabled public ASDAC_OrderAddress shipToAddress;
    @AuraEnabled
    public String orderFulfilmentType;
    @AuraEnabled
    public String storeNumber;

    @AuraEnabled public String shippingAddress {
        get {
            if(ASDAC_OMSConstants.CLICKNCOLLECT.equals(orderFulfilmentType)){
                return getStoreNameNumber(storeNumber);
            }      
            return ASDAC_OrderUtility.getAddressString(shipToAddress);         
        }
    }

    @AuraEnabled public String currentEstimateDeliveryDate;   // Pending mapping in sheet
    @AuraEnabled public Datetime promisedDeliveryDate;
    @AuraEnabled public String promiseDeliveryDate{
        get{
            return shipments.isEmpty() ? '' :ASDAC_OrderUtility.convertStringToDateTimeString(shipments[0]?.promisedDeliveryDate);
        }
    }
    @AuraEnabled public String carrierName;
    @AuraEnabled public String distributor;
    @AuraEnabled public String productId;
    @AuraEnabled public String productLink;       // Not present in mapping sheet
    @AuraEnabled public String productDescription;
    @AuraEnabled public Decimal quantity;
    @AuraEnabled public Decimal nilPickQty;
    @AuraEnabled public Decimal rejectedQty;
    @AuraEnabled
    public String productType;
    @AuraEnabled
    public String uom;
    @AuraEnabled
    public Boolean isUomEach{
        get{
            return ASDAC_OMSConstants.EACH_STRING.equalsIgnoreCase(uom);
        }
    }
    @AuraEnabled
    public Boolean isOutofStock;
    @AuraEnabled
    public Boolean showStockWaring;
    public Boolean isReceivable{
        get{
            return !ASDAC_OMSConstants.BLIND_RETRUN_STRING.equalsIgnoreCase(returnType);
        }
    }
    @AuraEnabled
    public Decimal refundedAmountSoFar;
    @AuraEnabled
    public Decimal unitPrice = 0.0;
    public Decimal unitDiscount = 0.0;
    public Decimal unitTax = 0.0;
    public Decimal partialRefundAmount = 0.0;
    @AuraEnabled
    public Decimal unitTotal {
        get {
            if(unitTax!=null && unitDiscount!=null&&unitDiscount!=null){
                Decimal unitTotalAmount = unitPrice + unitTax - unitDiscount;
                return unitTotalAmount > 0 ? unitTotalAmount : 0.0;
            }
            return 0.0;
        }
    }
    @AuraEnabled public Decimal discount {
        get {
            if(unitDiscount!=null && quantity!=null){
               return ((Decimal)(unitDiscount * quantity))?.setScale(2);
           }
           return 0.0;
        }
    }
    public Decimal unitPartialRefund {
        get {
            return (quantity > 0 && refundedAmountSoFar > 0) ? (refundedAmountSoFar/quantity).setScale(2) : 0.0;
        }
    }
    @AuraEnabled public Decimal tax {
        get {
            if(unitTax!=null && quantity!=null){
               return ((Decimal)(unitTax * quantity))?.setScale(2);
            }
            return 0.0;
        }
    }
    @AuraEnabled public Decimal lineTotal {
        get {
            if(unitTotal!=null && quantity!=null){
                return ((decimal)(unitTotal * quantity)).setScale(2);
            }
            return 0.0;
        }
        set;
    }
    @AuraEnabled public Decimal nilPickTotal {
        get {
            return ASDAC_OMSConstants.NIL_PICK_TOTAL;
        }
        set;
    }
    @AuraEnabled public Decimal rejectedTotal {
        get {
            return ASDAC_OMSConstants.REJECTED_TOTAL;
        }
        set;
    }
    @AuraEnabled
    public Decimal refundedAmount;
    @AuraEnabled public Decimal deliveryCharge;   // line item delivery charge not present in mapping sheet
    @AuraEnabled public String warrantyInfo;    // will come from custom field, Not present in mapping sheet
    @AuraEnabled public String colour;    //will come from custom field, Not present in mapping sheet
    @AuraEnabled public String upc;     //will come from custom field, Not present in mapping sheet
    @AuraEnabled public String size;    //will come from custom field, Not present in mapping sheet
    @AuraEnabled public String typicalLife;
    @AuraEnabled public Integer parentOrderLineId;
    
    @AuraEnabled
    public String partialRefundHelpText;
    @AuraEnabled
    public String returnReasonCode;
    @AuraEnabled
    public String returnReason;
    @AuraEnabled
    public String returnType {
        get {
            return source !=ASDAC_GlobalConstants.STRING_SOURCE_SFSC?ASDAC_GlobalConstants.STRING_RETURNTYPE_STANDARD:returnType;
        }
    }
    @AuraEnabled
    public String returnNotes;
    @AuraEnabled
    public String exchangeReason;
    // GHS Refunds
    @AuraEnabled
    public String refundMode;
    @AuraEnabled
    public String refundSource;

    @AuraEnabled public Decimal discountedPrice;
    @AuraEnabled public Decimal discountAmount;
    @AuraEnabled public Decimal totalPrice;
    @AuraEnabled public Decimal vatRate;	
    @AuraEnabled public Decimal exVat;	
    @AuraEnabled public Decimal vatAmount;
    @AuraEnabled public Decimal vatExTotalPrice;
    @AuraEnabled public Decimal refundAmount;
    @AuraEnabled public Decimal vatExRefundAmount;
    @AuraEnabled public Decimal refundableQuantity;
    @AuraEnabled public Boolean isNilPick = false;
    @AuraEnabled public Boolean isRejected = false;
    @AuraEnabled public String rejectionReason;
    @AuraEnabled public Datetime rejectionDate;
    @AuraEnabled public String formattedRejectionDate {
        get {
            return ASDAC_OrderUtility.convertDateTimeString(rejectionDate);
        }
    }
    
    public List<ShipmentWrapper> shipments {
        get {
            if (shipments == null) {
                return new List<ShipmentWrapper>();
            }
            getFcDsvMdtMap();
            return shipments;
        }
        set;
    }
    @AuraEnabled
    public List<ShipmentWrapper> shipmentDetails {
        get {
            if (isNotTrackable) {
                return new List<ShipmentWrapper>(); // To minimize response payload after splitting order lines by state
            }
            return shipments;
        }
    }
    @AuraEnabled public String itemNameHelpText {
        get {
            List<String> itemNameHelpTextList = new List<String>();
            itemNameHelpTextList.add(ASDAC_OMSConstants.UPC_STRING + upc);
            itemNameHelpTextList.add(ASDAC_OMSConstants.SIZE_STRING + size);
            itemNameHelpTextList.add(ASDAC_OMSConstants.COLOUR_STRING + colour);

            return getItemHelpText(itemNameHelpTextList);
        }
    }

    @AuraEnabled public String promotionAmountType {
        get {
            return String.isNotBlank(stateToQty[0].discountText) ? (ASDAC_OMSConstants.INCLUDES_STRING + stateToQty[0].discountText) : null;
        }
    }
    @AuraEnabled
    public Boolean isNotTrackable {
        get {
            return !((!shipments.isEmpty()) && hasOrderActionsPermission && isActionPossible(georgeTrackingField));
        }
    }
    @AuraEnabled public Boolean isReturnRecived = false;

    public List<ASDAC_OrderLineStateResponse> stateToQty;
    @AuraEnabled
    public String status{
        get{
            return (isGeorge == false)?status:stateToQty[0].state;
        }
    }
    
    public Integer refundQuantity{
        get{
            return getRefundQuantity();
        }
    }

    private Integer getRefundQuantity(){
        Integer tempQty = 0;
        for(ASDAC_OrderLineStateResponse stq: stateToQty){
            if(stq.state == 'REFUNDED'){
                tempQty = Math.abs(Integer.valueof(stq.quantity));
            }
        }
        return tempQty;
    }

    // added as part of ghs refund override
    @AuraEnabled
    public List<ASDAC_OrderLineAssociationRequest> associationDetails;
    
    public List<ASDAC_OrderLineItemResponse> bundleItems = new List<ASDAC_OrderLineItemResponse>();
    


    public static String getItemHelpText(List<String> itemNameHelpTextList){
        String helpTextStr='';
        for(String val: itemNameHelpTextList){
            helpTextStr = helpTextStr + val ;
        }
        return helpTextStr;
    }

    public class ShipmentWrapper{
        public String promisedDeliveryDate;
        @AuraEnabled 
        public String promiseDeliveryDate{
            get{
                return ASDAC_OrderUtility.convertStringToDateTimeString(promisedDeliveryDate);
            }
        }
        public String currentEstimatedDeliveryDate;
        @AuraEnabled 
        public String estimateDeliveryDate{
            get{
                return ASDAC_OrderUtility.convertStringToDateTimeString(currentEstimatedDeliveryDate);
            }
        }

        @AuraEnabled public Integer shipmentQuantity;
       
        public String actualShipDate;
        @AuraEnabled public String shipDate{
            get{
                return ASDAC_OrderUtility.convertStringToDateTimeString(actualShipDate);
            }
        }
        @AuraEnabled public String carrierService;
        @AuraEnabled public String carrierName;
        @AuraEnabled public String trackingId;
        @AuraEnabled public String trackingUrl;
        @AuraEnabled public String poNumber;
        public String fulfillmentCentre;
        @AuraEnabled public String fulfillmentCentreName{
            get{
                return fcDsvMdtMap.containsKey(fulfillmentCentre) ? fcDsvMdtMap.get(fulfillmentCentre) : '';
            }
        }
        @AuraEnabled public String fulfillmentService;
        @AuraEnabled public String fulfilledBy;
    }

    private static void getFcDsvMdtMap() {
        List<ASDAC_FcDsvMappingWithLocationID__mdt> mdtRecords = [Select Id,LocationId__c,FcDsvName__c from ASDAC_FcDsvMappingWithLocationID__mdt];        
        for(ASDAC_FcDsvMappingWithLocationID__mdt rec: mdtRecords){
            if(!fcDsvMdtMap.containsKey(rec.LocationId__c) && !String.isBlank(rec.LocationId__c)){
                fcDsvMdtMap.put(rec.LocationId__c, rec.FcDsvName__c);
            }
        }
    }

    private static String getStoreNameNumber(String storeNumber) {
        if (Store__c.SObjectType.getDescribe().isAccessible() && storeNumber!=null) {
            List<Store__c> storeList = [SELECT Id, StoreNumberName__c, StoreNumber__c FROM Store__c WHERE StoreNumber__c = :storeNumber LIMIT 1];
            if (!storeList.isEmpty()) {
                return storeList[0].StoreNumberName__c;
            }
            else {
                return storeNumber;
            }
        }
        return '';
    }
}