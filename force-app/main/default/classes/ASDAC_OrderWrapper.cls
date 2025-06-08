public with sharing class ASDAC_OrderWrapper {

    private final static String NEW_ORDER_ID_FORMAT = '{0}_{1}_{2}';
    private final static String PREVIEW_ORDER_ID_FORMAT = 'ASDA-DUMMY-{0}';
    @AuraEnabled
    public String orgId { get; set; }
    @AuraEnabled
    public String sellingChannel { get; set; }
    @AuraEnabled
    public String orderId { get; set; }
    @AuraEnabled
    public String customerId { get; set; }
    @AuraEnabled
    public Boolean eVouchersAsDiscount { get; set; }
    @AuraEnabled
    public List<ASDAC_OrderLineWrapper> orderLines { get; set; }
    @AuraEnabled
    public List<ASDAC_OrderAssociationRequest> associationDetails { get; set; }
    @AuraEnabled
    public String reason { get; set; }
    @AuraEnabled
    public Decimal discount { get; set; }
    @AuraEnabled
    public String notes { get; set; }
    @AuraEnabled
    public String deliveryChargeReferenceId { get; set; }
    @AuraEnabled
    public String deliveryChargeReferenceType { get; set; }
    @AuraEnabled
    public String minimumBasketChargeReferenceId { get; set; }
    @AuraEnabled
    public String minimumBasketChargeReferenceType { get; set; }
    @AuraEnabled
    public Decimal currentMinimumBasketCharge { get; set; }
    @AuraEnabled
    public Decimal currentDeliveryCharge { get; set; }
    @AuraEnabled
    public List<ASDAC_OrderAddressInfo> addressInfo { get; set; }
    @AuraEnabled
    public List<ASDAC_OrderCharges> charges { get; set; }
    @AuraEnabled
    public List<ASDAC_OrderDiscountRequest> discounts { get; set; }


    public ASDAC_OrderRequest toPartialOrderRequest(){
        ASDAC_OrderRequest partialOrderRequest = new ASDAC_OrderRequest();
        partialOrderRequest.orgId = ASDAC_OMSConstants.ORG_ID;
        partialOrderRequest.sellingChannel = sellingChannel;
        partialOrderRequest.orderId = orderId;
        partialOrderRequest.orderType = ASDAC_OMSConstants.SALES_ORDER;
        partialOrderRequest.partialFillAllowed=null;
        partialOrderRequest.orderDate = null;
        
        for(ASDAC_OrderLineWrapper orderLine : orderLines) {
            ASDAC_OrderDiscountRequest deliveryDiscount = new ASDAC_OrderDiscountRequest();
            deliveryDiscount.name = ASDAC_OMSConstants.PARTIAL_REFUND_NAME;
            deliveryDiscount.accountingType = ASDAC_OMSConstants.ACCOUNTING_TYPE;
            deliveryDiscount.category = ASDAC_OMSConstants.CATEGORY;
            deliveryDiscount.amount = orderLine.discount;
            deliveryDiscount.reasonCode = orderLine.reason;
            deliveryDiscount.useForTotals = true;
            deliveryDiscount.isRefundable = true;
            
            ASDAC_OrderCommentRequest deliveryNotes = new ASDAC_OrderCommentRequest();
            deliveryNotes.comment = orderLine.notes;
            deliveryNotes.commentedBy = ASDAC_OMSConstants.COMMENTED_BY;
            deliveryNotes.commentType = ASDAC_OMSConstants.COMMENTED_TYPE;
            
            ASDAC_OrderLineRequest partialOrderLine = new ASDAC_OrderLineRequest();
            partialOrderLine.orderLineId = orderLine.orderLineId;
            partialOrderLine.discounts = new List<ASDAC_OrderDiscountRequest>{deliveryDiscount};
            partialOrderLine.comments = new List<ASDAC_OrderCommentRequest>{deliveryNotes};
                    partialOrderLine.partialFillAllowed=null;
            partialOrderRequest.orderLines.add(partialOrderLine);
        }
        return partialOrderRequest;
    }
  
  public ASDAC_OrderRequest toExchangeOrderRequest() {
    ASDAC_OrderRequest exchangeOrderRequest = new ASDAC_OrderRequest();
    orgId = ASDAC_OMSConstants.ORG_ID;
    exchangeOrderRequest.orgId = orgId;
    exchangeOrderRequest.sellingChannel = sellingChannel;
    exchangeOrderRequest.customerId = customerId;
    exchangeOrderRequest.createUser = ASDAC_OMSConstants.SFSC_USER;
    exchangeOrderRequest.updateUser = ASDAC_OMSConstants.SFSC_USER;
    exchangeOrderRequest.orderType = ASDAC_OMSConstants.RETURN_ORDER;
    exchangeOrderRequest.orderCategory = ASDAC_OMSConstants.SALES_ORDER;
    exchangeOrderRequest.billingCurrency = ASDAC_OMSConstants.BILLING_CURRENCY;
    exchangeOrderRequest.addressInfo = addressInfo;
    if (eVouchersAsDiscount != null && eVouchersAsDiscount) {
        exchangeOrderRequest.customFields = new ASDAC_OrderRequest.CustomFields();
        exchangeOrderRequest.customFields.eVouchersAsDiscount = 'true';
    }
    ASDAC_OrderAssociationRequest salesOrderAssociation = new ASDAC_OrderAssociationRequest();
    salesOrderAssociation.orgId = orgId;
    salesOrderAssociation.sellingChannel = sellingChannel;
    salesOrderAssociation.orderId = orderId;
    salesOrderAssociation.associationType = ASDAC_OMSConstants.SALES_ORDER;

    ASDAC_OrderAssociationRequest exchangeOrderAssociation = new ASDAC_OrderAssociationRequest();
    exchangeOrderAssociation.orgId = orgId;
    exchangeOrderAssociation.sellingChannel = sellingChannel;
    exchangeOrderAssociation.associationType = ASDAC_OMSConstants.AWAITING_EXCHANGE;
    exchangeOrderAssociation.copyPayment = true;

    exchangeOrderRequest.associationDetails = new List<ASDAC_OrderAssociationRequest>{
      salesOrderAssociation,
      exchangeOrderAssociation
    };

    ASDAC_OrderLineRequest.OrderAssociation salesOrderLineAssociation = new ASDAC_OrderLineRequest.OrderAssociation();
    salesOrderLineAssociation.associationType = ASDAC_OMSConstants.SALES_ORDER;
    salesOrderLineAssociation.associatedLineId = 0;

    ASDAC_OrderLineRequest.OrderAssociation exchangeOrderLineAssociation = new ASDAC_OrderLineRequest.OrderAssociation();
    exchangeOrderLineAssociation.associationType = ASDAC_OMSConstants.AWAITING_EXCHANGE;
    exchangeOrderLineAssociation.associatedLineId = 0;

    List<ASDAC_OrderLineRequest.OrderAssociation> orderLineAssociations = new List<ASDAC_OrderLineRequest.OrderAssociation> {
      salesOrderLineAssociation,
      exchangeOrderLineAssociation
    };

    if (orderLines != null) {
      Integer orderLineId = 0;
      for (ASDAC_OrderLineWrapper orderLine : orderLines) {
        ASDAC_OrderLineRequest exchangeOrderLine = new ASDAC_OrderLineRequest();
        exchangeOrderLine.orderLineId = ++orderLineId;
        exchangeOrderLine.orderLineType = orderLine.orderLineType;
        exchangeOrderLine.fulfillmentType = orderLine.fulfillmentType;
        exchangeOrderLine.fulfillmentService = orderLine.fulfillmentService;

        exchangeOrderLine.productId = orderLine.productId;
        exchangeOrderLine.productDescription = orderLine.productDescription;
        exchangeOrderLine.productType = orderLine.productType;
        exchangeOrderLine.uom = orderLine.uom;
        exchangeOrderLine.quantity = orderLine.quantity;
        exchangeOrderLine.lineTotals = null;

        exchangeOrderLine.customFields = new ASDAC_OrderLineRequest.CustomFields();
        exchangeOrderLine.customFields.returnType = orderLine.actionType;
        exchangeOrderLine.customFields.returnReason = orderLine.reason;
        exchangeOrderLine.customFields.exchangeReason = orderLine.reason;
        exchangeOrderLine.customFields.returnNotes = orderLine.notes;
        exchangeOrderLine.customFields.exchangeNotes = orderLine.notes;
        exchangeOrderLine.reasonCode = orderLine.reason;

        exchangeOrderLine.dates = new ASDAC_OrderLineRequest.OrderDateRanges();
        exchangeOrderLine.dates.requestedDeliveryDate = new ASDAC_OrderLineRequest.OrderDateRange();
        exchangeOrderLine.dates.requestedDeliveryDate.min = orderLine.promisedDeliveryDate;
        exchangeOrderLine.dates.requestedDeliveryDate.max = orderLine.promisedDeliveryDateMax;

        exchangeOrderLine.associationDetails = new List<ASDAC_OrderLineRequest.OrderAssociation> {
          orderLineAssociations[0].clone(),
          orderLineAssociations[1].clone()
        };
        exchangeOrderLine.associationDetails[0].associatedLineId = orderLine.orderLineId;
        exchangeOrderLine.associationDetails[1].associatedLineId = orderLineId;
        exchangeOrderLine.associationDetails[1].productId = orderLine.productId;
        exchangeOrderLine.associationDetails[1].quantity = orderLine.quantity;

        ASDAC_OrderAddressInfo addressInfo = new ASDAC_OrderAddressInfo();
        addressInfo.type = ASDAC_OMSConstants.SHIPPING_ADDRESS_TYPE;
        addressInfo.contact = orderLine.shipToContact;
        addressInfo.address = orderLine.shipToAddress;
        exchangeOrderLine.addressInfo = new List<ASDAC_OrderAddressInfo> { addressInfo };

        exchangeOrderRequest.orderLines.add(exchangeOrderLine);
      }
    }

    return exchangeOrderRequest;
  }

  public ASDAC_OrderRequest toReturnPreviewRequest() {
    ASDAC_OrderRequest returnPreviewRequest = new ASDAC_OrderRequest();
    Boolean isGrocery = isGroceryCheck();
    String orderIdSuffix = EncodingUtil.base64Encode(Crypto.generateAesKey(128)).replaceAll('[+/]', '').substring(0, 8);
    String returnOrderId = String.format(PREVIEW_ORDER_ID_FORMAT, new List<Object> {orderIdSuffix});
    returnPreviewRequest.orgId = ASDAC_OMSConstants.ORG_ID;
    returnPreviewRequest.sellingChannel = sellingChannel;
    returnPreviewRequest.createUser = ASDAC_OMSConstants.SFSC_USER;
    returnPreviewRequest.orderId = returnOrderId;
    returnPreviewRequest.customerId = customerId;
    returnPreviewRequest.orderType = ASDAC_OMSConstants.RETURN_ORDER;
    returnPreviewRequest.orderCategory = ASDAC_OMSConstants.RETURN_ORDER;
    returnPreviewRequest.billingCurrency = ASDAC_OMSConstants.BILLING_CURRENCY;
    returnPreviewRequest.updateUser = ASDAC_OMSConstants.SFSC_USER;
    
    ASDAC_OrderAssociationRequest salesOrderAssociation = new ASDAC_OrderAssociationRequest();
    salesOrderAssociation.orgId = ASDAC_OMSConstants.ORG_ID;
    salesOrderAssociation.sellingChannel = sellingChannel;
    salesOrderAssociation.orderId = orderId;
    salesOrderAssociation.associationType = ASDAC_OMSConstants.SALES_ORDER;
    
    returnPreviewRequest.associationDetails = new List<ASDAC_OrderAssociationRequest> {salesOrderAssociation};
    if(orderLines != null) {
        Integer orderLineId = 0;
        Map<Integer, Integer> orderLineIdMap = new Map<Integer, Integer>();
        for(ASDAC_OrderLineWrapper orderLine : orderLines) {
            ++orderLineId;
            orderLineIdMap.put(orderLine.orderLineId, orderLineId);
            //ignone bundle patrent product
            if(orderLine.isBundle != null && orderLine.isBundle && !isGrocery){
              continue;
            }
            ASDAC_OrderLineRequest returnPreviewLine = new ASDAC_OrderLineRequest();
            returnPreviewLine.orderLineId = orderLineId;                
            returnPreviewLine.productId = orderLine.productId;
            returnPreviewLine.productDescription = orderLine.productDescription;
            returnPreviewLine.uom = orderLine.uom;
            returnPreviewLine.quantity = orderLine.quantity;
            returnPreviewLine.reasonCode = orderLine.reason; 
            returnPreviewLine.updateUser = ASDAC_OMSConstants.SFSC_USER;
            returnPreviewLine.productType = orderLine.productType;
            returnPreviewLine.fulfillmentType = orderLine.fulfillmentType;
            returnPreviewLine.fulfillmentService = orderLine.fulfillmentService;
            returnPreviewLine.orderLineType = orderLine.orderLineType;

            List<ASDAC_OrderLineRequest.OrderAssociation> orderLineAssociations = new List<ASDAC_OrderLineRequest.OrderAssociation>();
            ASDAC_OrderLineRequest.OrderAssociation association = new ASDAC_OrderLineRequest.OrderAssociation();
            association.associationType = ASDAC_OMSConstants.SALES_ORDER;
            association.associatedLineId = orderLine.orderLineId;
            orderLineAssociations.add(association);
            returnPreviewLine.associationDetails = orderLineAssociations;

            if(returnPreviewLine != null){
                returnPreviewRequest.orderLines.add(returnPreviewLine);
            }
        }
    }
      return returnPreviewRequest;
  }
    
    public ASDAC_OrderRequest toReturnOrderRequest() {
      	Boolean isGrocery = isGroceryCheck();
        List<String> fraudBypassReasonCodes = System.Label.ASDAC_GhsFraudBypassLineLevelRefundReasons.split(',');
     	
        ASDAC_OrderRequest returnOrderRequest = new ASDAC_OrderRequest();
        orgId = ASDAC_OMSConstants.ORG_ID;
        returnOrderRequest.orgId = orgId;
        returnOrderRequest.sellingChannel = sellingChannel;
        returnOrderRequest.customerId = customerId;
        returnOrderRequest.createUser = ASDAC_OMSConstants.SFSC_USER;
        returnOrderRequest.updateUser = ASDAC_OMSConstants.SFSC_USER;
        returnOrderRequest.billingCurrency = ASDAC_OMSConstants.BILLING_CURRENCY;
        returnOrderRequest.orderType = ASDAC_OMSConstants.RETURN_ORDER;
        returnOrderRequest.orderCategory = ASDAC_OMSConstants.RETURN_ORDER;
        returnOrderRequest.associationDetails = associationDetails;
        returnOrderRequest.addressInfo = addressInfo;
        
        if (orderLines != null) {
            Integer orderLineId = 0;
            Map<Integer, Integer> orderLineIdMap = new Map<Integer, Integer>();
            for (ASDAC_OrderLineWrapper orderLine : orderLines) {
                ++orderLineId;
                orderLineIdMap.put(orderLine.orderLineId, orderLineId);
                //ignone bundle patrent product
                if(orderLine.isBundle != null && orderLine.isBundle && !isGrocery){
                  continue;
                }
                ASDAC_OrderLineRequest returnOrderLine = new ASDAC_OrderLineRequest();
                returnOrderLine.orderLineId = orderLineId;
                returnOrderLine.orderLineType = orderLine.orderLineType;
                returnOrderLine.updateUser = ASDAC_OMSConstants.SFSC_USER;
                returnOrderLine.fulfillmentType = orderLine.fulfillmentType;
                returnOrderLine.omsStatus = orderLine.omsStatus;
                returnOrderLine.fulfillmentService = orderLine.fulfillmentService;
                
                returnOrderLine.customFields = new ASDAC_OrderLineRequest.CustomFields();

                if(isGrocery){
                    returnOrderLine.customFields.fraud = getFraudDetails(fraudBypassReasonCodes,orderLine.reason);
                }
                if (orderLine.isBundle == null || !orderLine.isBundle) {
                    returnOrderLine.customFields.returnType = orderLine.actionType;
                    returnOrderLine.customFields.returnReason = orderLine.reason;
                    returnOrderLine.customFields.returnNotes = orderLine.notes;
                }
                
                returnOrderLine.productId = orderLine.productId;
                returnOrderLine.productDescription = orderLine.productDescription;
                returnOrderLine.productType = orderLine.productType;
                returnOrderLine.uom = orderLine.uom;
                returnOrderLine.quantity = orderLine.quantity;
                returnOrderLine.associationDetails = getReturnOrderLineAssociation(orderLine.associationDetails);
                
                returnOrderLine.reasonCode = orderLine.reason;
                returnOrderRequest.orderLines.add(returnOrderLine);
            }
        }
        return returnOrderRequest;
    }

    public Boolean isGroceryCheck(){
        return (sellingChannel == ASDAC_OMSConstants.ASDA_GROCERIES_STRING || sellingChannel == ASDAC_OMSConstants.GHS_STRING);
    }
    
    public static ASDAC_OrderRefundFraudWrapper getFraudDetails(List<String> fraudBypassReasonCodes, String selectedReason){
        ASDAC_OrderRefundFraudWrapper fraud = new ASDAC_OrderRefundFraudWrapper();
        if(fraudBypassReasonCodes.contains(selectedReason)){
            fraud.fraudBypass = true;
        }
        else{
            fraud.fraudBypass = false;
        }
        return fraud;
    }

  public List<ASDAC_OrderLineRequest.OrderAssociation> getReturnOrderLineAssociation(List<ASDAC_OrderLineWrapper.OrderLineAssociation> lineAssociationList){
    List<ASDAC_OrderLineRequest.OrderAssociation> associationDetails = new List<ASDAC_OrderLineRequest.OrderAssociation>();
    for(ASDAC_OrderLineWrapper.OrderLineAssociation lineAssociations: lineAssociationList){
        ASDAC_OrderLineRequest.OrderAssociation association = new ASDAC_OrderLineRequest.OrderAssociation();
        association.associationType = lineAssociations.associationType;
        association.associatedLineId = lineAssociations.associatedLineId;
        associationDetails.add(association);
    }
    return associationDetails;
}
  
  public ASDAC_ATPInventoryCheckRequest toATPInventoryCheckRequest(){
    ASDAC_ATPInventoryCheckRequest inventoryCheckRequest = new ASDAC_ATPInventoryCheckRequest();
    List<ASDAC_OrderLineRequest> lstProducts = new List<ASDAC_OrderLineRequest>();
    if (orderLines != null) {
        for (ASDAC_OrderLineWrapper orderLine : orderLines) {
            ASDAC_OrderLineRequest orderLineInventory = new ASDAC_OrderLineRequest();
            orderLineInventory.productId = orderLine.productId;
            orderLineInventory.uom = ASDAC_OMSConstants.EACH_STRING;
            orderLineInventory.quantity = ASDAC_OMSConstants.INTEGER_ONE;
            lstProducts.add(orderLineInventory);
        }
    }
    inventoryCheckRequest.products = lstProducts;
    return inventoryCheckRequest;
  }
  
  public ASDAC_ReceiveRequest toReceiveRequest() {
        ASDAC_ReceiveRequest receiveOrderRequest = new ASDAC_ReceiveRequest();
        receiveOrderRequest.updateUser = ASDAC_OMSConstants.SFSC_USER;
        receiveOrderRequest.orgId = ASDAC_OMSConstants.ORG_ID;
        receiveOrderRequest.sellingChannel = ASDAC_OMSConstants.SELLING_CHANNEL_GEORGE;
        receiveOrderRequest.orderId = orderId;
        receiveOrderRequest.orderType = ASDAC_OMSConstants.RETURN_ORDER;
        receiveOrderRequest.orderLines = new List<ASDAC_ReceiveRequest.Cls_orderLines>();
        
        if (orderLines != null) {
          for (ASDAC_OrderLineWrapper orderLine : orderLines) {     
            ASDAC_ReceiveRequest.Cls_orderLines receivedorderLine = new ASDAC_ReceiveRequest.Cls_orderLines();
            receivedorderLine.updateUser = UserInfo.getUserId();
            receivedorderLine.orderLineId = orderLine.orderLineId;
            receivedorderLine.quantity = orderLine.quantity;
            receivedorderLine.receivedInSFSC = true;            
            receiveOrderRequest.orderLines.add(receivedorderLine);          
        }
        }  
    return receiveOrderRequest;
  }
    
  public ASDAC_OrderRequest toDeliveryChargeRequest(){
    ASDAC_OrderRequest deliveryChargeRefundRequest = new ASDAC_OrderRequest();
    deliveryChargeRefundRequest.orgId = ASDAC_OMSConstants.ORG_ID;
    deliveryChargeRefundRequest.sellingChannel = sellingChannel;
    deliveryChargeRefundRequest.orderId = orderId;
    deliveryChargeRefundRequest.orderType = ASDAC_OMSConstants.SALES_ORDER;
    deliveryChargeRefundRequest.partialFillAllowed=null;
    deliveryChargeRefundRequest.orderDate = null;
    deliveryChargeRefundRequest.orderLines = null;
  
    List<Integer> appliesToLines = new List<Integer>();
    for (ASDAC_OrderLineWrapper orderLine : this.orderLines) {
        if (!appliesToLines.contains(orderLine.orderLineId)) {
            appliesToLines.add(orderLine.orderLineId);
        }
    }
    ASDAC_OrderDiscountRequest deliveryDiscount = new ASDAC_OrderDiscountRequest();
    deliveryDiscount.appliesToLines = appliesToLines;
    deliveryDiscount.name = ASDAC_OMSConstants.DELIVERY_CHARGE_NAME;
    deliveryDiscount.accountingType = ASDAC_OMSConstants.ACCOUNTING_TYPE;
    deliveryDiscount.category = ASDAC_OMSConstants.CATEGORY;
    deliveryDiscount.reasonCode = reason;
    deliveryDiscount.amount = discount;
    deliveryDiscount.isRefundable = false;

    List<ASDAC_OrderDiscountRequest> discounts = new List<ASDAC_OrderDiscountRequest>{deliveryDiscount};
    deliveryChargeRefundRequest.discounts = discounts;
  
    ASDAC_OrderCommentRequest deliveryNotes = new ASDAC_OrderCommentRequest();
    deliveryNotes.comment = notes;
    deliveryNotes.commentedBy = ASDAC_OMSConstants.COMMENTED_BY;
    deliveryNotes.commentType = ASDAC_OMSConstants.COMMENTED_TYPE;
    List<ASDAC_OrderCommentRequest> deliveryChargeComments = new List<ASDAC_OrderCommentRequest>{deliveryNotes};
    deliveryChargeRefundRequest.comments = deliveryChargeComments;

    return deliveryChargeRefundRequest;
  }

  public ASDAC_OrderRequest toCancelOrderRequest(){

    ASDAC_OrderRequest cancelOrderRequest = new ASDAC_OrderRequest();
    cancelOrderRequest.updateUser = ASDAC_OMSConstants.SFSC_USER;
    cancelOrderRequest.orgId = ASDAC_OMSConstants.ORG_ID;
    cancelOrderRequest.sellingChannel = sellingChannel;
    cancelOrderRequest.orderId = orderId;
    cancelOrderRequest.orderType = ASDAC_OMSConstants.SALES_ORDER;
    cancelOrderRequest.reasonCode = reason;
    cancelOrderRequest.customerId = customerId;
    cancelOrderRequest.partialFillAllowed=null;
    cancelOrderRequest.orderDate = null;
  
    for (ASDAC_OrderLineWrapper orderLine : orderLines){
      ASDAC_OrderLineRequest cancelOrderLine = new ASDAC_OrderLineRequest();
      cancelOrderLine.orderLineId = orderLine.orderLineId;
      cancelOrderLine.updateUser = ASDAC_OMSConstants.SFSC_USER;
      cancelOrderLine.quantity = orderLine.quantity;
      cancelOrderLine.partialFillAllowed=null;
      cancelOrderRequest.orderLines.add(cancelOrderLine);
    }
    return cancelOrderRequest;
  }

  public ASDAC_OrderRequest toWholeOrderRefundRequest() {
        List<String> fraudBypassReasonCodes = System.Label.ASDAC_GhsFraudBypassOrderLevelRefundReasons.split(',');
        
        ASDAC_OrderRequest wholeRefundRequest = new ASDAC_OrderRequest();
        orgId = ASDAC_OMSConstants.ORG_ID;
        wholeRefundRequest.orgId = orgId;
        wholeRefundRequest.sellingChannel = sellingChannel;
        wholeRefundRequest.customerId = customerId;
        wholeRefundRequest.createUser = ASDAC_OMSConstants.SFSC_USER;
        wholeRefundRequest.updateUser = ASDAC_OMSConstants.SFSC_USER;
        wholeRefundRequest.billingCurrency = ASDAC_OMSConstants.BILLING_CURRENCY;
        wholeRefundRequest.orderType = ASDAC_OMSConstants.RETURN_ORDER;
        wholeRefundRequest.orderCategory = ASDAC_OMSConstants.RETURN_ORDER;
        ASDAC_OrderAssociationRequest salesOrderAssociation = new ASDAC_OrderAssociationRequest();
        salesOrderAssociation.orgId = ASDAC_OMSConstants.ORG_ID;
        salesOrderAssociation.sellingChannel = sellingChannel;
        salesOrderAssociation.orderId = orderId;
        salesOrderAssociation.associationType = ASDAC_OMSConstants.SALES_ORDER;
        wholeRefundRequest.associationDetails = new List<ASDAC_OrderAssociationRequest> {salesOrderAssociation};
            
        wholeRefundRequest.customFields = new ASDAC_OrderRequest.CustomFields();
        wholeRefundRequest.customFields.returnReason = reason;
        wholeRefundRequest.customFields.returnNotes = notes; 
        wholeRefundRequest.customFields.fraud = getFraudDetails(fraudBypassReasonCodes,reason);  
        
        wholeRefundRequest.addressInfo = addressInfo;
        wholeRefundRequest.charges = charges;
        wholeRefundRequest.discounts = discounts;
		
        List<Integer> appliesToLines = new  List<Integer>();
        
        if (orderLines != null) {
            Integer orderLineId = 0;
            for (ASDAC_OrderLineWrapper orderLine : orderLines) {
                if(orderLine.refundableQuantity > 0.0 || orderLine.isCharitableProduct){
                    ASDAC_OrderLineRequest wholeRefundLine = new ASDAC_OrderLineRequest();
                    wholeRefundLine.orderLineId = ++orderLineId;
                    wholeRefundLine.orderLineType = orderLine.orderLineType;
                    wholeRefundLine.fulfillmentType = orderLine.fulfillmentType;
                    wholeRefundLine.fulfillmentService = orderLine.fulfillmentService;
                    wholeRefundLine.updateUser = ASDAC_OMSConstants.SFSC_USER;
                    
                    wholeRefundLine.productId = orderLine.productId;
                    wholeRefundLine.productDescription = orderLine.productDescription;
                    wholeRefundLine.productType = orderLine.productType;
                    wholeRefundLine.uom = orderLine.uom;
                    wholeRefundLine.quantity = orderLine.refundableQuantity;
                    List<ASDAC_OrderLineRequest.OrderAssociation> lineAssociationDetails = new List<ASDAC_OrderLineRequest.OrderAssociation>(); 
                    ASDAC_OrderLineRequest.OrderAssociation association = new ASDAC_OrderLineRequest.OrderAssociation();
                    association.associationType = ASDAC_OMSConstants.SALES_ORDER;
                    association.associatedLineId = orderLine.orderLineId;
                    lineAssociationDetails.add(association);
                    wholeRefundLine.associationDetails = lineAssociationDetails;

                    appliesToLines.add(orderLine.orderLineId);
                    
                    if (orderLine.isBundle == null || !orderLine.isBundle) {
                        wholeRefundLine.customFields = new ASDAC_OrderLineRequest.CustomFields();
                        wholeRefundLine.customFields.returnType = ASDAC_OMSConstants.ORIGINAL_STRING;
                        wholeRefundLine.customFields.returnReason = orderLine.reason;
                        wholeRefundLine.customFields.returnNotes = orderLine.notes;
                        wholeRefundLine.customFields.fraud = getFraudDetails(fraudBypassReasonCodes,orderLine.reason);
                    }
                    
                    wholeRefundLine.reasonCode = orderLine.reason;
                    wholeRefundRequest.orderLines.add(wholeRefundLine);
                }
            }
        }

        setAppliesToLine(wholeRefundRequest, appliesToLines);
        return wholeRefundRequest;
    }
    
    public void setAppliesToLine(ASDAC_OrderRequest orderRequest, List<Integer> appliesToLines){
        
            if(orderRequest.charges != null){
                for(ASDAC_OrderCharges charge: orderRequest.charges){
                    charge.appliesToLines = appliesToLines;
                }
            }
            if ( orderRequest.discounts != null){
                for(ASDAC_OrderDiscountRequest discount: orderRequest.discounts){
                    discount.appliesToLines = appliesToLines;
                }
            }
       
    }

    public ASDAC_OrderRequest toRefundOverrideRequest() {
      	
        ASDAC_OrderRequest returnOrderRequest = new ASDAC_OrderRequest();
        orgId = ASDAC_OMSConstants.ORG_ID;
        returnOrderRequest.orgId = orgId;
        returnOrderRequest.sellingChannel = sellingChannel;
        returnOrderRequest.customerId = customerId;
        returnOrderRequest.createUser = ASDAC_OMSConstants.SFSC_USER;
        returnOrderRequest.updateUser = ASDAC_OMSConstants.SFSC_USER;
        returnOrderRequest.billingCurrency = ASDAC_OMSConstants.BILLING_CURRENCY;
        returnOrderRequest.orderType = ASDAC_OMSConstants.RETURN_ORDER;
        returnOrderRequest.orderCategory = ASDAC_OMSConstants.RETURN_ORDER;
        returnOrderRequest.addressInfo = addressInfo;
        
        ASDAC_OrderAssociationRequest salesOrderAssociation = new ASDAC_OrderAssociationRequest();
        salesOrderAssociation.orgId = ASDAC_OMSConstants.ORG_ID;
        salesOrderAssociation.sellingChannel = sellingChannel;
        salesOrderAssociation.orderId = orderId;
        salesOrderAssociation.associationType = ASDAC_OMSConstants.SALES_ORDER;
        returnOrderRequest.associationDetails = new List<ASDAC_OrderAssociationRequest> {salesOrderAssociation};
        
        if (orderLines != null) {
            Integer orderLineId = 0;
            Map<Integer, Integer> orderLineIdMap = new Map<Integer, Integer>();
            for (ASDAC_OrderLineWrapper orderLine : orderLines) {
                ASDAC_OrderLineRequest returnOrderLine = new ASDAC_OrderLineRequest();
                returnOrderLine.orderLineId = ++orderLineId;
                orderLineIdMap.put(orderLine.orderLineId, returnOrderLine.orderLineId);
                returnOrderLine.orderLineType = orderLine.orderLineType;
                returnOrderLine.updateUser = ASDAC_OMSConstants.SFSC_USER;
                returnOrderLine.fulfillmentType = orderLine.fulfillmentType;
                returnOrderLine.omsStatus = orderLine.omsStatus;
                returnOrderLine.fulfillmentService = orderLine.fulfillmentService;
                
                if (orderLine.isBundle == null || !orderLine.isBundle) {
                    returnOrderLine.customFields = new ASDAC_OrderLineRequest.CustomFields();
                    returnOrderLine.customFields.returnType = orderLine.actionType;
                    returnOrderLine.customFields.returnReason = orderLine.reason;
                    returnOrderLine.customFields.returnNotes = orderLine.notes;
                    ASDAC_OrderRefundFraudWrapper fraudObj = new ASDAC_OrderRefundFraudWrapper();
                    fraudObj.fraudOverride = true;
                    fraudObj.previousROId = orderLine.returnOrderId;
                    fraudObj.previousROLineId = orderLine.orderLineId;
                    returnOrderLine.customFields.fraud = fraudObj;
                }
                
                returnOrderLine.productId = orderLine.productId;
                returnOrderLine.productDescription = orderLine.productDescription;
                returnOrderLine.productType = orderLine.productType;
                returnOrderLine.uom = orderLine.uom;
                returnOrderLine.quantity = orderLine.quantity;
                returnOrderLine.associationDetails = getReturnOrderLineAssociation(orderLine.associationDetails);
                
                returnOrderLine.reasonCode = orderLine.reason;
                returnOrderRequest.orderLines.add(returnOrderLine);
            }
        }
        return returnOrderRequest;
    }
    

}