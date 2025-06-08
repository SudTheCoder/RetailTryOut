public with sharing class ASDAC_OrderUtility {
    
    public Static Set<String> fulfilmentTypeSet = new Set<String>();
    public static Schema.SObjectField cancelField =  ASDAC_OrderDetailsButtonsVisibility__mdt.Cancel__c;
    public static Schema.SobjectField discountField = ASDAC_OrderDetailsButtonsVisibility__mdt.Discount__c;
    public static Schema.SobjectField exchangeField = ASDAC_OrderDetailsButtonsVisibility__mdt.Exchange__c;
    public static Schema.SobjectField refundField =  ASDAC_OrderDetailsButtonsVisibility__mdt.Refund__c;
    public static Set<Schema.SObjectField> mdtActionFields = new Set<Schema.SObjectField> {cancelField,discountField,exchangeField,refundField};
    
    /**
* ****************************************************************************************************
* @param shipAddressMap Shipping Address details from payload
* @description get the shipping address for order item from the payload
* @return String concatenated address
* ****************************************************************************************************
*/
    public static String getAddressString(ASDAC_OrderAddress shipAddressMap){
        String shipAddress = '';
        if(shipAddressMap!=null){
            shipAddress += String.isNotBlank(shipAddressMap.addressLine1) ? (shipAddressMap.addressLine1 + ', ') : '';
            shipAddress += String.isNotBlank(shipAddressMap.addressLine2) ? (shipAddressMap.addressLine2 + ', ') : '';
            shipAddress += String.isNotBlank(shipAddressMap.city) ? (shipAddressMap.city + ', ') : '';
            shipAddress += String.isNotBlank(shipAddressMap.state) ? (shipAddressMap.state + ', ') : '';
            shipAddress += String.isNotBlank(shipAddressMap.country) ? (shipAddressMap.country + ', ') : '';
            shipAddress += String.isNotBlank(shipAddressMap.zipCode) ? (shipAddressMap.zipCode) : '';
        }
        return shipAddress;    
    }
    
       /**
* ****************************************************************************************************
* @param strDate String form of Date: '2012-02-21T11:27:54.14Z'
* @description Set format for date
* @return String set formatted date :21 Feb 2012, Tue 11:27 AM
* ****************************************************************************************************
*/
    public static String convertStringToDateTimeString(String strDate){
        if (String.isBlank(strDate)) {
            return '';
        }
        DateTime d = Datetime.valueOfGmt(strDate.replace('T',' '));     
        return convertDateTimeString(d);
    }
    
    public static String convertDateTimeString(Datetime dt){
        if (dt == null) {
            return '';
        }
        String timeStr = dt.format(System.Label.ASDAC_OmsDateTimeFormat, 'Europe/London');
        return timeStr;
    }

/**
* ****************************************************************************************************
* @param strDate String form of Date: '2022-09-29T11:49:00.432'
* @description Set format for date
* @return String set formatted date :Thursday 29 September 2022
* ****************************************************************************************************
*/
    public static String convertStringToDateString(Datetime dt){
        if (dt == null) {
            return '';
        }
        return dt.format('EEEE dd MMMM yyyy', System.Label.ASDAC_DateTimeZone);
    }

 /**
 * ****************************************************************************************************
 * @param strDate String form of Date: '2023-11-15T04:39:22Z'
 * @description Set format for date
 * @return String set formatted date :15 Nov 2023 Wednesday 04:39 AM
 * ****************************************************************************************************
 */
    public static String dateTimeFormat(Datetime dt){
        if (dt == null) {
            return '';
        }
        return dt.format('dd MMM yyyy EEEE hh:mm a', System.Label.ASDAC_DateTimeZone);
    }

/**
 * ****************************************************************************************************
 * @param strDate String form of Date: '2023-11-15T04:39:22Z'
 * @description Set format for date
 * @return String set formatted date :28-Sep-2022 12:00pm
 * ****************************************************************************************************
 */
public static String cutoffdateTimeFormat(Datetime dt){
    if (dt == null) {
        return '';
    }
    return dt.format('dd-MMM-yyyy h:mm a', System.Label.ASDAC_DateTimeZone);
}
    
 /**
 * ****************************************************************************************************
 * @param strDate String form of Date: '2023-11-15T04:39:22Z'
 * @description Set format for date
 * @return String set formatted time : 04:39
 * ****************************************************************************************************
 */
    public static String timeFormat(Datetime dt){
        if (dt == null) {
            return '';
        }
        return dt.format('hh:mm', System.Label.ASDAC_DateTimeZone);
    }

/**
* ****************************************************************************************************
* @param dt DateTime form of Date: '2022-09-29T11:49:00.432'
* @description Set format for date
* @return String set formatted date :29 September 2022
* ****************************************************************************************************
*/
    public static String convertToVatDateFormat(Datetime dt){
        if (dt == null) {
            return '';
        }
        return dt.format('dd MMMM yyyy', System.Label.ASDAC_DateTimeZone);
    }    

/**
* ****************************************************************************************************
* @description fetch currency and symbol mapping
* @return map<String, String> : currncy against symbol
* ****************************************************************************************************
*/
    
    public static map<String, String> fetchCurrencyWithSymbol(){
        map<String, String> currencyToSymbMap = new map<String, String>();
        map<String, ASDAC_CurrencyMappingWithSymbols__mdt> mdtMap = ASDAC_CurrencyMappingWithSymbols__mdt.getAll();
        for(String curr : mdtMap.keyset()){
            currencyToSymbMap.put(curr, mdtMap.get(curr).ASDAC_CurrencySymbol__c);
        }
        return currencyToSymbMap;
    }


    public static List<ASDAC_OrderLineItemResponse> transformOrderLines(List<ASDAC_OrderLineItemResponse> products) {
        List<ASDAC_OrderLineItemResponse> orderLines = new List<ASDAC_OrderLineItemResponse>();
        // Arrange bundle items under the parent
        Map<Integer, ASDAC_OrderLineItemResponse> mapOfBundle = new Map<Integer, ASDAC_OrderLineItemResponse>();
        // Split Original Order Lines based on its state
        List<ASDAC_OrderLineItemResponse> productsSplitByState = new List<ASDAC_OrderLineItemResponse>();
        for (ASDAC_OrderLineItemResponse orderLine : products) {
            if (orderLine.isBundle) { // Do not split bundle parent
                orderLine.quantity = orderLine.stateToQty[0].quantity;
                productsSplitByState.add(orderLine);
                continue;
            }
            for (ASDAC_OrderLineStateResponse state : orderLine.stateToQty) {
                ASDAC_OrderLineItemResponse product = orderLine.clone();
                product.stateToQty = new List<ASDAC_OrderLineStateResponse> {state};
                product.quantity = state.quantity;
                product.receiptedUserName= (product.receiptedUserName!=null)? product.receiptedUserName.substring(0,product.receiptedUserName.length()-3):'';
                if(state.state == ASDAC_OMSConstants.RETURN_CREATED_STR || state.state == ASDAC_OMSConstants.RETURN_DROP_OFF_STR){
                    product.receiptedUserName = '';
                    product.dateTimeReceived = null;
                }
                productsSplitByState.add(product);
            }
        }
        mapOfBundle = getBundleMap(productsSplitByState);
        if(mapOfBundle.isEmpty()){
            return productsSplitByState;
        }else{
            return mapBundleProducts(orderLines, mapOfBundle, productsSplitByState);
        }
    }

    private static Map<Integer, ASDAC_OrderLineItemResponse> getBundleMap(List<ASDAC_OrderLineItemResponse> productsSplitByState) {
        Map<Integer, ASDAC_OrderLineItemResponse> mapOfBundle = new Map<Integer, ASDAC_OrderLineItemResponse>();
    
        for (ASDAC_OrderLineItemResponse orderLine : productsSplitByState) {
            if (orderLine.isBundle) {
                mapOfBundle.put(orderLine.orderLineId, orderLine);
            }
        }
    
        return mapOfBundle;
    }

        public static List<ASDAC_OrderLineItemResponse> mapBundleProducts(List<ASDAC_OrderLineItemResponse> orderLines, Map<Integer, ASDAC_OrderLineItemResponse> mapOfBundle, List<ASDAC_OrderLineItemResponse> productsSplitByState) {
        for (ASDAC_OrderLineItemResponse orderLine : productsSplitByState) {
            if (orderLine.parentId != 0 && orderLine.parentId != null) {                
                if (mapOfBundle.get(orderLine.parentId).bundleItems == null) {
                    mapOfBundle.get(orderLine.parentId).bundleItems = new List<ASDAC_OrderLineItemResponse>();
                }
                mapOfBundle.get(orderLine.parentId).bundleItems.add(orderLine);
            } else if (!orderLine.isBundle) {
                orderLines.add(orderLine);
            }
        }
        for (ASDAC_OrderLineItemResponse bundle : mapOfBundle.values()) {
            orderLines.add(bundle);
            orderLines.addAll(bundle.bundleItems);
        }
        return orderLines;
    }

    public static Boolean hasOrderActionsPermission() {
        return FeatureManagement.checkPermission('ASDAC_OrderActions');
    }
    
    public static void transformGroceryReturnOrderLines(List<ASDAC_ReturnOrderResponse> returnOrders) {
        Boolean isOverridePossible;
        Map<String, ASDAC_ExtendedWarrentyProductType__mdt> extendedProductTypesMap = new Map<String, ASDAC_ExtendedWarrentyProductType__mdt> ();
        for (ASDAC_ExtendedWarrentyProductType__mdt extProductType : [SELECT ProductType__c, MaxWarrentyPeriod__c FROM ASDAC_ExtendedWarrentyProductType__mdt]) {
            extendedProductTypesMap.put(extProductType.ProductType__c, extProductType);
        }
        for (ASDAC_ReturnOrderResponse order : returnOrders) {
            for (ASDAC_OrderLineItemResponse orderLine : order.orderLines) {
                orderLine.orderType = ASDAC_OMSConstants.RETURN_ORDER;
                orderLine.isGeorge = false;
                orderLine.source = order.source;
                if (extendedProductTypesMap.containsKey(orderLine.productType)) {
                    ASDAC_ExtendedWarrentyProductType__mdt extProductType = extendedProductTypesMap.get(orderLine.productType);
                    Integer warrantyPeriodInMonths = Integer.valueOf(extProductType.MaxWarrentyPeriod__c);
                    isOverridePossible = order.actualArrivalTime != null && order.actualArrivalTime.date().addMonths(warrantyPeriodInMonths).daysBetween(Date.today()) <= 0;
            
                } else {
                    isOverridePossible = order.actualArrivalTime != null && order.actualArrivalTime.date().addDays(30).daysBetween(Date.today()) <= 0;
                    
                }
                orderLine.isOverridePossible = isOverridePossible;
            }
            
        }
    
    }
    public static List<ASDAC_OrderLineItemResponse> transformGrocerySubstituteItems(List<ASDAC_OrderLineItemResponse> orderLines){
        Map<Integer, List<ASDAC_OrderLineItemResponse>> subMap = new Map<Integer, List<ASDAC_OrderLineItemResponse>>();
        List<ASDAC_OrderLineItemResponse> itemList = new List<ASDAC_OrderLineItemResponse>();        
        for (ASDAC_OrderLineItemResponse orderLine : orderLines) {
            if(orderLine.hasSubstitute){
                subMap.put(orderLine.orderLineId, new List<ASDAC_OrderLineItemResponse>{orderLine});                
            }
        }

        for(ASDAC_OrderLineItemResponse orderLine : orderLines){
            if(orderLine.isSubstitutedLine && orderLine.parentOrderLineId!=null && subMap.containsKey(orderLine.parentOrderLineId)){
                    subMap.get(orderLine.parentOrderLineId).add(orderLine);                               
            }else if(!orderLine.hasSubstitute){
                subMap.put(orderLine.orderLineId, new List<ASDAC_OrderLineItemResponse>{orderLine});
            }
        }
        List<Integer> orderLineList = new List<Integer>(subMap.keySet());
        orderLineList.sort();
        for(Integer orderLine : orderLineList){
            itemList.addAll(subMap.get(orderLine));
        }

        return itemList;
    }
}