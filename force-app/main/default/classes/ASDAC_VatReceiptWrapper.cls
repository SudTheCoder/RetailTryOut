public with sharing class ASDAC_VatReceiptWrapper {
    @AuraEnabled public String orderId { get; set; }
    @AuraEnabled public String sellingChannel { get; set; }
    @AuraEnabled public Datetime orderDate { get; set; }
    @AuraEnabled public String vatDate { get; set; }
    @AuraEnabled public String vatRegistrationNumber { get; set; }
    @AuraEnabled public Decimal vatRateDeliveryCharge { get; set; }
    @AuraEnabled public Decimal vatAmountDeliveryCharge { get; set; }
    @AuraEnabled public Decimal currentDeliveryCharge { get; set; }
    @AuraEnabled public ASDAC_OrderContact billToContact { get; set; }
    @AuraEnabled public String customerId { get; set; }
    @AuraEnabled public ASDAC_OrderAddress shipToAddress { get; set; }
    @AuraEnabled public String orderFulfilmentTypeGrocery { get; set; }
    @AuraEnabled public Decimal multisaveDiscount { get; set; }
    @AuraEnabled public Decimal asdaRewardDiscount { get; set; }
    @AuraEnabled public Decimal colleagueDiscount { get; set; }
    @AuraEnabled public Decimal marketingCouponAmount { get; set; }
    @AuraEnabled public Decimal eVoucherAmount { get; set; }
    @AuraEnabled public Decimal vatAmount { get; set; }
    @AuraEnabled public Decimal vatTotalPrice { get; set; } 

    @AuraEnabled public Map<String, List<LineItemDetails>> categoryMap{
        get;
        set {
            categoryMap = getFormattedMap(value);
        } 
    }
    @AuraEnabled
    public List<String> categoryList{get; set;}

    @AuraEnabled public String formattedvatRateDeliveryCharge { 
        get{
            return getFormattedValue(vatRateDeliveryCharge);
        } 
    }
    public String formattedVatOrderDate {
        get {
            return ASDAC_OrderUtility.convertToVatDateFormat(orderDate);
        }
    }
    @AuraEnabled public String formattedvatAmountDeliveryCharge { 
        get{
            return getFormattedValue(vatAmountDeliveryCharge);
        } 
    }
    @AuraEnabled public String formattedcurrentDeliveryCharge { 
        get{
            return getFormattedValue(currentDeliveryCharge);
        } 
    }
    @AuraEnabled public String formattedmultisaveDiscount { 
        get{
            return getFormattedValue(multisaveDiscount);
        } 
    }
    @AuraEnabled public String formattedasdaRewardDiscount { 
        get{
            return getFormattedValue(asdaRewardDiscount);
        } 
    }
    @AuraEnabled public String formattedcolleagueDiscount { 
        get{
            return getFormattedValue(colleagueDiscount);
        } 
    }
    @AuraEnabled public String formattedmarketingCouponAmount { 
        get{
            return getFormattedValue(marketingCouponAmount);
        } 
    }
    @AuraEnabled public String formattedeVoucherAmount { 
        get{
            return getFormattedValue(eVoucherAmount);
        } 
    }   
    @AuraEnabled public String formattedvatAmount { 
        get{
            Decimal vatAmountSum = 0;
            Decimal vatAmountTotal =0;
            for (String category : categoryList){
                if(category != 'Delivery cost'){
                    List<LineItemDetails> lineItems = categoryMap.get(category);
                    if (lineItems != null) {
                        for (LineItemDetails item : lineItems) {
                            if(item.isRefundItem){
                                vatAmountTotal -= item.vatAmount != null ? item.vatAmount : 0;   
                            }else{
                            vatAmountTotal += item.vatAmount != null ? item.vatAmount : 0;
                            }
                        } 
                    }
                }
            }
            vatAmountSum = vatAmountTotal + vatAmountDeliveryCharge;
            return getFormattedValue(vatAmountSum);
        } 
    }

    @AuraEnabled public String formattedvatTotalPrice { 
        get{ 
            Decimal sum = 0;
            Decimal discountedPriceTotal = 0;
            Decimal refundAmountTotal = 0;
             for (String category : categoryList){
                if(category != 'Delivery cost'){
                    List<LineItemDetails> lineItems = categoryMap.get(category);
                    if (lineItems != null) {
                        for (LineItemDetails item : lineItems) {
                            discountedPriceTotal += item.discountedPrice != null ? item.discountedPrice : 0;
                            refundAmountTotal += item.refundAmount != null ? item.refundAmount : 0;
                        } 
                    }
                }
            }
                sum = (discountedPriceTotal + currentDeliveryCharge)-refundAmountTotal;
                return getFormattedValue(sum);
        } 
    }

    public string getFormattedValue(Decimal value){
        if(value == null){
            return '£0.00';
        }                
        return value < 0 ? '-£'+String.valueOf(Math.abs(value).setScale(2)) : '£'+String.valueOf(Math.abs(value).setScale(2));
    }
    
    public Map<String, List<LineItemDetails>> getFormattedMap(Map<String, List<LineItemDetails>> value) {
        if (value.isEmpty()) {
            return value;
        } else {
            categoryList = new List<String>();
            for (String key : value.keySet()) {
                system.debug('key value: '+key);
                if (!key.equals(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR) &&
                    !key.equals(ASDAC_OMSConstants.VAT_REFUNDS_STR)) {
                    categoryList.add(key);
                    updateLineItems(value.get(key), false);
                }
            }
            if (value.containsKey(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR)) {
                categoryList.add(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR);
                for(LineItemDetails temp: value.get(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR)){
                    updateLineItems(value.get(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR), false);
                }
            }
            if (value.containsKey(ASDAC_OMSConstants.VAT_REFUNDS_STR)) {
                categoryList.add(ASDAC_OMSConstants.VAT_REFUNDS_STR);
                updateLineItems(value.get(ASDAC_OMSConstants.VAT_REFUNDS_STR), true);
            }    
            system.debug('final list'+categoryList);
            return value;
        }
    } 
    @testVisible
    private void updateLineItems(List<LineItemDetails> lineItems, Boolean isRefund) {
        for (LineItemDetails temp : lineItems) {
            temp.isRefundItem = isRefund;
        }
    }

    public class LineItemDetails{
        @AuraEnabled public String productDescription { get; set; }
        @AuraEnabled public Decimal discountedPrice { get; set; }
        @AuraEnabled public Decimal refundAmount { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        @AuraEnabled public Decimal vatRate { get; set; }
        @AuraEnabled public Decimal exVat { get; set; }
        @AuraEnabled public Decimal vatAmount { get; set; }
        public boolean isRefundItem = false;

        @AuraEnabled public String quantityFormatted{
            get {
                if(isRefundItem){
                  return  '-'+String.valueOf(quantity);
                }else{
                    return String.valueOf(quantity);
                }                
            }
        }
        @AuraEnabled public String unitPriceFormatted {
            get {
                return getFormattedValue(unitPrice, isRefundItem);
            }
        }
        @AuraEnabled public String refundAmountFormatted{
            get {                
                return refundAmount!=null ? getFormattedValue(refundAmount, isRefundItem) : '';
            }        
        }
        @AuraEnabled public String discountedPriceFormatted{
            get {                
                return discountedPrice!=null ? getFormattedValue(discountedPrice, isRefundItem) : '';
            }        
        }
        @AuraEnabled public String vatAmountFormatted{
            get {
                return getFormattedValue(vatAmount, isRefundItem);
            }
        }

        public string getFormattedValue(Decimal value, boolean isRefundItem){
            return isRefundItem ? '-£'+String.valueOf(Math.abs(value).setScale(2)) : '£'+String.valueOf(Math.abs(value).setScale(2));
        }
        
    }

}