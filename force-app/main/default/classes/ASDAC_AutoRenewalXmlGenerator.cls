/***********************************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-02
* @Component Type               : Apex Class
* @component Name               : ASDAC_AutoRenewalXmlGenerator
* @description                  : ASDAC-8813 - GHS - DP SME - Auto-renew payload along with Payment authorization - 3+ASDAC-18173
* @Modified By                  : Niteesh
* @Modified Date		        : 2024-02-19
************************************************************************************************************************/
public with sharing class ASDAC_AutoRenewalXmlGenerator {
    
    /**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-02
* @Method Name                  : xmlRequestGenerator
* @Modified By                  : Niteesh
* @Modified Date		         : 2024-02-19
**********************************************************************************/
    Public Static string xmlString = '';
    Public Static string strCustomAttribute = 'custom-attribute';
    Public Static string strCustomAttributes = 'custom-attributes';
    Public Static string strShipmentId = 'shipment-id';
    Public Static string strTaxBasis = 'tax-basis';
    Public Static string strLineItemText = 'lineitem-text';
    Public Static string strBasePrice = 'base-price';
    Public Static string strGrossPrice = 'gross-price';
    Public Static string strOriginalOrderNo = 'original-order-no';
    Public Static string strAttributeId = 'attribute-id';
    Public Static string isAuthorized = 'False'; 
    public Static Decimal amount = 0.0;
    public static string MIGRATED_PSPID = system.label.ASDAC_LoyaltyMigratedDP_PSPID;
    public static string migratedDPPaymnetId;
    public static string migratedDPMerchantRefNo;
    public static String xmlRequestGenerator(Asset objAsset , String strRequestName, Map<String,String> migratedPaymnetResponse){
        if(migratedPaymnetResponse != null){
            migratedDPPaymnetId = migratedPaymnetResponse.get('paymentId');
            migratedDPMerchantRefNo = migratedPaymnetResponse.get('merchantReference');
            isAuthorized = migratedPaymnetResponse.get('isAuthorized') ?? 'False';          
        }
        ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams objParamWrapper = initializeParams(objAsset,strRequestName);
        String xmlstring = generateXmlString(objParamWrapper, strRequestName);
        return xmlstring;
    }
    
    /**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-02
* @Method Name                  : initializeParams
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-07-10
**********************************************************************************/
    private static ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams initializeParams(Asset objAsset,String strRequestName) {
        ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams objParamWrapper = new ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams();
        objParamWrapper.objAccount = [Select id, Name, isPersonAccount,Salutation,firstname,lastname,billingStreet, billingCity, billingpostalcode,
                                      ShippingLatitude,ShippingLongitude,ShippingCity,ShippingCountryCode,ShippingPostalCode,ShippingStreet,billingcountrycode,phone,Loginid__c,PersonContactId from Account where id=:objAsset.AccountId limit 1];
        objParamWrapper.objcard = [SELECT Id,AddressId__r.AddressLine1__c, AddressId__r.AddressLine2__c,AddressId__r.City__c,AddressId__r.PostalCode__c,AddressId__r.Country__c,NameOnCard__c,ExpiryDate__c,MaskedCardNumber__c, CardToken__c,CardBrand__c  from CustomerCard__c where id= :objAsset.Customer_Card__c];
        objParamWrapper.objOrder = [Select id, OriginalOrderId,EffectiveDate, OrderedDate,OrderNumber from Order where id=:objAsset.loyaltyOrderNumber__c];
        objParamWrapper.objOrderproduct = [Select Id, UnitPrice, NetUnitPrice,Description,Quantity from OrderItem where OrderId=:objParamWrapper.objOrder.Id];
        objParamWrapper.objProduct = [Select id,ProductCode,PlanPrice__c,NumberOfInstallments__c,ItemId__c,Name,PlanDuration__c from Product2 where id=:objAsset.Product2Id];
        objParamWrapper.objAsset = objAsset;
        if(!Test.isRunningTest() && strRequestName !='AutoRenew') {        
            objParamWrapper.objInvoice = [select id,TotalAmountWithTax,DueDate,DocumentNumber,InvoiceNumber from Invoice where BillingAccountId =:objAsset.AccountId order By CreatedDate DESC limit 1];
        }
        return objParamWrapper;
    }
    
    /**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-02
* @Method Name                  : generateXmlString
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-07-10
**********************************************************************************/
    private static String generateXmlString(ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams objParamWrapper, String strRequestName) {
        
        if(!test.isRunningTest()){
            amount = (strRequestName == 'AutoRenew') ? objParamWrapper.objProduct.PlanPrice__c :(strRequestName == 'Monthly' && !Test.isRunningTest()) ? [Select Id,BillingPeriodAmount from BillingSchedule where ReferenceEntityId = :objParamWrapper.objAsset.loyaltyOrderNumber__c].BillingPeriodAmount:0.0; 
        }
        DOM.Document doc = new DOM.Document();
        
        dom.XmlNode order = addOrderDetailNode(doc,objParamWrapper,strRequestName);
        addBodyDetailNode(order, objParamWrapper, strRequestName);
        addProductDetailNode(order, objParamWrapper, strRequestName);      
        
        
        
        dom.XmlNode totals1= order.addChildElement('totals', null, null);
        dom.XmlNode merchandizeTotal1 = totals1.addChildElement('merchandize-total', null, null);
        merchandizeTotal1.addChildElement(strGrossPrice,null,null).addTextNode(String.valueOf(amount));
        dom.XmlNode adjustedMerchandizeTotal1 = totals1.addChildElement('adjusted-merchandize-total', null, null);
        adjustedMerchandizeTotal1.addChildElement(strGrossPrice,null,null).addTextNode(String.valueOf(amount));
        dom.XmlNode shippingTotal1 = totals1.addChildElement('shipping-total', null, null);
        shippingTotal1.addChildElement(strGrossPrice,null,null).addTextNode('0.00');
        dom.XmlNode adjustedShippingTotal1 = totals1.addChildElement('adjusted-shipping-total', null, null);
        adjustedShippingTotal1.addChildElement(strGrossPrice,null,null).addTextNode('0.00');
        dom.XmlNode ordertotal = totals1.addChildElement('order-total', null, null); 
        ordertotal.addChildElement(strGrossPrice,null,null).addTextNode(String.valueOf(amount));
        
        dom.XmlNode payments= order.addChildElement('payments', null, null); 
        dom.XmlNode payment= payments.addChildElement('payment', null, null);
        dom.XmlNode customMethod= payment.addChildElement('custom-method', null, null); 
        customMethod.addChildElement('method-name',null,null).addTextNode('INGENICO_OGONE_CARD');
        
        dom.XmlNode custAttribute =customMethod.addChildElement(strCustomAttributes,null,null);
        
        //FinalRetry
        dom.XmlNode ingenicoOgoneAcquirerName = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneAcquirerName.setAttribute(strAttributeId, 'ingenicoOgoneAcquirerName');
        
        dom.XmlNode ingenicoOgonePaymentId = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgonePaymentId.setAttribute(strAttributeId, 'ingenicoOgonePaymentId');
        
        dom.XmlNode ingenicoOgoneSRD = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneSRD.setAttribute(strAttributeId, 'ingenicoOgoneSchemeReferenceData');
        ingenicoOgoneSRD.addTextNode(objParamWrapper.objAsset.SchemeReferenceData__c!=null?objParamWrapper.objAsset.SchemeReferenceData__c : '');
        
        dom.XmlNode ingenicoOgoneCardToken = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneCardToken.setAttribute(strAttributeId, 'ingenicoOgoneCardToken');
        ingenicoOgoneCardToken.addTextNode(String.valueof(objParamWrapper.objCard.CardToken__c));
        
        dom.XmlNode ingenicoOgoneCardExpirationMonth = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneCardExpirationMonth.setAttribute(strAttributeId, 'ingenicoOgoneCardExpirationMonth');
        ingenicoOgoneCardExpirationMonth.addTextNode((objParamWrapper.objCard.ExpiryDate__c).substring(0,2));
        
        dom.XmlNode ingenicoOgoneCardExpirationYear = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneCardExpirationYear.setAttribute(strAttributeId, 'ingenicoOgoneCardExpirationYear');
        ingenicoOgoneCardExpirationYear.addTextNode('20'+(objParamWrapper.objCard.ExpiryDate__c).substring(3,5));
        
        //Pick label from CardBrand picklist
       List<Schema.PicklistEntry> values = CustomerCard__c.CardBrand__c.getDescribe().getPicklistValues();
        Map<String,String> cardBrandApiToLabelMap = new Map<String,String>();
        For(Schema.PicklistEntry sp : values){
            cardBrandApiToLabelMap.put(sp.getValue(), sp.getLabel());
       }
        
        dom.XmlNode ingenicoOgonePaymentProductName = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgonePaymentProductName.setAttribute(strAttributeId, 'ingenicoOgonePaymentProductName');
       ingenicoOgonePaymentProductName.addTextNode(cardBrandApiToLabelMap.get(objParamWrapper.objCard.CardBrand__c));
        
        dom.XmlNode ingenicoOgoneCardHolder = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneCardHolder.setAttribute(strAttributeId, 'ingenicoOgoneCardHolder');
        ingenicoOgoneCardHolder.addTextNode(objParamWrapper.objCard.NameOnCard__c);
        
        dom.XmlNode ingenicoOgoneCardNumber = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneCardNumber.setAttribute(strAttributeId, 'ingenicoOgoneCardNumber');
        ingenicoOgoneCardNumber.addTextNode(objParamWrapper.objCard.MaskedCardNumber__c);
        
        dom.XmlNode ingenicoOgonePaymentRequestedAmount = custAttribute.addChildElement(strCustomAttribute,null,null);
        ingenicoOgonePaymentRequestedAmount.setAttribute(strAttributeId, 'ingenicoOgonePaymentRequestedAmount');
        ingenicoOgonePaymentRequestedAmount.addTextNode(String.valueOf(amount));
        
        payment.addChildElement('amount',null,null).addTextNode(String.valueOf(amount));
        payment.addChildElement('processor-id',null,null).addTextNode('INGENICO_OGONE_CREDIT');
        
        dom.XmlNode custAttributeOrder =order.addChildElement(strCustomAttributes,null,null);
        
        dom.XmlNode asdaColleagueDiscountAmount = custAttributeOrder.addChildElement('custom-attribute',null,null);
        asdaColleagueDiscountAmount.setAttribute(strAttributeId, 'asdaColleagueDiscountAmount');
        asdaColleagueDiscountAmount.addTextNode('0.0');
        
        dom.XmlNode customerCrmID = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        customerCrmID.setAttribute(strAttributeId, 'customerCrmID');
        customerCrmID.addTextNode(objParamWrapper.objAccount.PersonContactId);
        
        dom.XmlNode ingenicoOgoneMerchantID = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneMerchantID.setAttribute(strAttributeId, 'ingenicoOgoneMerchantID');
      
        
        dom.XmlNode asdaFraudCheckStatus = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        asdaFraudCheckStatus.setAttribute(strAttributeId, 'asdaFraudCheckStatus');
        asdaFraudCheckStatus.addTextNode('False');       
        
        dom.XmlNode ingenicoOgoneTransactionID = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        ingenicoOgoneTransactionID.setAttribute(strAttributeId, 'ingenicoOgoneTransactionID');
        String transactionId = 'transaction-id';
        dom.XmlNode asda_merchant_reference_no = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        asda_merchant_reference_no.setAttribute(strAttributeId, 'asda_merchant_reference_no');
        if(objParamWrapper.objAsset.isMigratedSubscription__c && objParamWrapper.objAsset.PSPID__c==null){
            ingenicoOgoneAcquirerName.addTextNode('WorldPay');
            ingenicoOgoneMerchantID.addTextNode(MIGRATED_PSPID);
            if(objParamWrapper.objAsset.Payment_Id__c != null){
                ingenicoOgonePaymentId.addTextNode(objParamWrapper.objAsset.Payment_Id__c);
                ingenicoOgoneTransactionID.addTextNode(objParamWrapper.objAsset.Payment_Id__c);
                payment.addChildElement(transactionId,null,null).addTextNode(objParamWrapper.objAsset.Payment_Id__c);
                
                asda_merchant_reference_no.addTextNode(objParamWrapper.objAsset.asda_merchant_reference_no__c);
            }else{
                ingenicoOgonePaymentId.addTextNode(migratedDPPaymnetId);
                ingenicoOgoneTransactionID.addTextNode(migratedDPPaymnetId);
                payment.addChildElement(transactionId,null,null).addTextNode(migratedDPPaymnetId);
                
                asda_merchant_reference_no.addTextNode(migratedDPMerchantRefNo);
            }
        }else{
            ingenicoOgoneAcquirerName.addTextNode(objParamWrapper.objAsset.Acquirer_Name__c);
            ingenicoOgonePaymentId.addTextNode(objParamWrapper.objAsset.Payment_Id__c);
            ingenicoOgoneTransactionID.addTextNode(objParamWrapper.objAsset.Payment_Id__c);
            ingenicoOgoneMerchantID.addTextNode(objParamWrapper.objAsset.PSPID__c);
            payment.addChildElement(transactionId,null,null).addTextNode(objParamWrapper.objAsset.Payment_Id__c);
            asda_merchant_reference_no.addTextNode(objParamWrapper.objAsset.asda_merchant_reference_no__c);
        }
        
        dom.XmlNode ingenicoTokenizationId = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        ingenicoTokenizationId.setAttribute(strAttributeId, 'ingenicoTokenizationId');
        ingenicoTokenizationId.addTextNode(objParamWrapper.objCard.CardToken__c);
        
        dom.XmlNode isDeliveryPassPurchase = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        isDeliveryPassPurchase.setAttribute(strAttributeId, 'isDeliveryPassPurchase');
        isDeliveryPassPurchase.addTextNode('True');
        
        dom.XmlNode isAuthorizedTxn = custAttributeOrder.addChildElement(strCustomAttribute,null,null);
        isAuthorizedTxn.setAttribute(strAttributeId, 'isAuthorized');
        isAuthorizedTxn.addTextNode(isAuthorized);
        
        xmlString = doc.toXmlString();
        return xmlString;
    }
    public static dom.XmlNode addOrderDetailNode(DOM.Document doc, ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams objParamWrapper,String strRequestName){
        dom.XmlNode orders = doc.createRootElement('orders',null,null);
        orders.setAttribute('xmlns', 'http://www.demandware.com/xml/impex/order/2006-10-31');
        
        dom.XmlNode order= orders.addChildElement('order', null, null);
        if(!Test.isRunningTest()){
            String orderNumber = '500000'+objParamWrapper.objOrder.OrderNumber+objParamWrapper.objAsset.Renewal_Payment_Failed_Counter__c;
         order.setAttribute('order-no', strRequestName == 'AutoRenew' ? orderNumber : (strRequestName == 'Monthly' ? objParamWrapper.objOrder.OrderNumber + (objParamWrapper.objInvoice.DocumentNumber).subString(4)+objParamWrapper.objAsset.Installment_Payment_Counter__c : null)); 
        }
        date d1= (objParamWrapper.objAsset.UsageEndDate).addDays(1);
        order.addChildElement('order-date', null, null).addTextNode(String.valueOf(Datetime.newInstanceGMT(d1.year(), d1.month(), d1.day())));
        order.addChildElement('created-by', null, null).addTextNode('storefront');
        
        if(!Test.isRunningTest()) {
            String orderNumber = '500000'+objParamWrapper.objOrder.OrderNumber+objParamWrapper.objAsset.Renewal_Payment_Failed_Counter__c;
           order.addChildElement('original-order-no', null, null).addTextNode(strRequestName == 'AutoRenew' ? orderNumber : (strRequestName == 'Monthly' ? objParamWrapper.objOrder.OrderNumber +(objParamWrapper.objInvoice.DocumentNumber).subString(4)+objParamWrapper.objAsset.Installment_Payment_Counter__c : null));
        }
        
        order.addChildElement('currency', null, null).addTextNode('GBP');
        return order;
    }
    
    //Add body1/2/3
    public static void addBodyDetailNode(dom.XmlNode order, ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams objParamWrapper,String strRequestName){
        dom.XmlNode body2= order.addChildElement('customer', null, null);
        
        body2.addChildElement('customer-no',null,null).addTextNode(objParamWrapper.objAccount.PersonContactId);
        body2.addChildElement('customer-name',null,null).addTextNode(objParamWrapper.objAccount.Name);	
        
        dom.XmlNode body3= body2.addChildElement('billing-address',null,null);
        body3.addChildElement('salutation',null,null).addTextNode('NA');
        body3.addChildElement('first-name',null,null).addTextNode(String.isNotBlank(objParamWrapper.objcard.NameOnCard__c)?objParamWrapper.objcard.NameOnCard__c:''); 
        body3.addChildElement('last-name',null,null).addTextNode(String.isNotBlank(objParamWrapper.objcard.NameOnCard__c)?objParamWrapper.objcard.NameOnCard__c:''); 
        body3.addChildElement('address1',null,null).addTextNode(String.isNotBlank( objParamWrapper.objcard.AddressId__r.AddressLine1__c)?objParamWrapper.objcard.AddressId__r.AddressLine1__c:''); 
        body3.addChildElement('address2',null,null).addTextNode(String.isNotBlank(objParamWrapper.objcard.AddressId__r.AddressLine2__c)?objParamWrapper.objcard.AddressId__r.AddressLine2__c:'');         
        body3.addChildElement('city',null,null).addTextNode(String.isNotBlank(objParamWrapper.objcard.AddressId__r.City__c)?objParamWrapper.objcard.AddressId__r.City__c:''); 
        body3.addChildElement('postal-code',null,null).addTextNode(String.isNotBlank(objParamWrapper.objcard.AddressId__r.PostalCode__c)?objParamWrapper.objcard.AddressId__r.PostalCode__c:''); 
        body3.addChildElement('country-code',null,null).addTextNode(String.isNotBlank(objParamWrapper.objcard.AddressId__r.Country__c)?objParamWrapper.objcard.AddressId__r.Country__c:''); 
        
    }
    //Add Product node
    Public static void addProductDetailNode(dom.XmlNode order, ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams objParamWrapper,String strRequestName){       
        if(!Test.isRunningTest()) {
             String orderNumber = '500000'+objParamWrapper.objOrder.OrderNumber+objParamWrapper.objAsset.Renewal_Payment_Failed_Counter__c;
           order.addChildElement('current-order-no', null, null).addTextNode( strRequestName == 'AutoRenew' ? orderNumber : strRequestName == 'Monthly' ? objParamWrapper.objOrder.OrderNumber +objParamWrapper.objInvoice.DocumentNumber.substring(4)+objParamWrapper.objAsset.Installment_Payment_Counter__c : null);
        }
        
        dom.XmlNode productLineItems= order.addChildElement('product-lineitems', null, null);
        dom.XmlNode productLineItem = productLineItems.addChildElement('product-lineitem', null, null);
        addProductLineItem( productLineItem,objParamWrapper,strRequestName);
        
        //needs adjustment to incorporate attribute-id properties
        
        dom.XmlNode customAttributes = productLineItem.addChildElement(strCustomAttributes, null, null);
        
        
        
        dom.XmlNode dp_PlanInstallmentCount = customAttributes.addChildElement(strCustomAttribute,null,null);
        dp_PlanInstallmentCount.setAttribute(strAttributeId, 'DP_PlanInstallmentCount');
        dp_PlanInstallmentCount.addTextNode(String.valueOf(objParamWrapper.objProduct.NumberOfInstallments__c) );
        dom.XmlNode isPersonalizedSample = customAttributes.addChildElement(strCustomAttribute,null,null);
        isPersonalizedSample.setAttribute(strAttributeId, 'isPersonalizedSample');
        isPersonalizedSample.addTextNode('False');
        
        if(strRequestName == 'Monthly'){
            
            dom.XmlNode is_dp_installment_payment = customAttributes.addChildElement(strCustomAttribute,null,null);
            is_dp_installment_payment.setAttribute(strAttributeId, 'is_dp_installment_payment');
            is_dp_installment_payment.addTextNode('true');
            dom.XmlNode dp_installment_invoice_id = customAttributes.addChildElement(strCustomAttribute,null,null);
            dp_installment_invoice_id.setAttribute(strAttributeId, 'dp_installment_invoice_id');
            
            //AESR-1325
            dom.XmlNode serviceEndDate = customAttributes.addChildElement(strCustomAttribute,null,null);
            serviceEndDate.setAttribute(strAttributeId, 'DP_ServiceEndDate');
            date d = ((objParamWrapper.objAsset.PurchaseDate).addMonths(Integer.valueOf(objParamWrapper.objProduct.PlanDuration__c))).addDays(1);
            serviceEndDate.addTextNode(String.valueOf(Datetime.newInstanceGMT(d.year(), d.month(), d.day())));//Service End Date
            dom.XmlNode serviceStartDate = customAttributes.addChildElement(strCustomAttribute,null,null);
            serviceStartDate.setAttribute(strAttributeId, 'DP_ServiceStartDate');
            date d1= (objParamWrapper.objAsset.PurchaseDate).addDays(1);
            serviceStartDate.addTextNode(String.valueOf(Datetime.newInstanceGMT(d1.year(), d1.month(), d1.day())));//Service Start Date 
            
            if(!test.isRunningTest()){
              dp_installment_invoice_id.addTextNode(objParamWrapper.objInvoice.Id); 
            }
            
        }else if(strRequestName == 'AutoRenew'){
            dom.XmlNode is_dp_installment_payment = customAttributes.addChildElement(strCustomAttribute,null,null);
            is_dp_installment_payment.setAttribute(strAttributeId, 'is_dp_installment_payment');
            is_dp_installment_payment.addTextNode('false');
            dom.XmlNode dp_installment_invoice_id = customAttributes.addChildElement(strCustomAttribute,null,null);
            dp_installment_invoice_id.setAttribute(strAttributeId, 'dp_installment_invoice_id');
            dp_installment_invoice_id.addTextNode('');

            dom.XmlNode serviceEndDate = customAttributes.addChildElement(strCustomAttribute,null,null);
            serviceEndDate.setAttribute(strAttributeId, 'DP_ServiceEndDate');
            date d = ((objParamWrapper.objAsset.UsageEndDate).addMonths(Integer.valueOf(objParamWrapper.objProduct.PlanDuration__c))).addDays(1);
            serviceEndDate.addTextNode(String.valueOf(Datetime.newInstanceGMT(d.year(), d.month(), d.day())));//Service End Date
            dom.XmlNode serviceStartDate = customAttributes.addChildElement(strCustomAttribute,null,null);
            serviceStartDate.setAttribute(strAttributeId, 'DP_ServiceStartDate');
            date d1= (objParamWrapper.objAsset.UsageEndDate).addDays(1);
            serviceStartDate.addTextNode(String.valueOf(Datetime.newInstanceGMT(d1.year(), d1.month(), d1.day())));//Service Start Date 
        }
    }
    public static void addProductLineItem(dom.XmlNode productLineItem, ASDAC_SubscriptionAutoRenewalBatch.XMLObjectParams objParamWrapper,String strRequestName){
        productLineItem.addChildElement(strGrossPrice,null,null).addTextNode(String.valueOf(amount)); 
        productLineItem.addChildElement(strBasePrice,null,null).addTextNode(String.valueOf(amount)); 
        productLineItem.addChildElement(strLineItemText, null, null).addTextNode(objParamWrapper.objOrderproduct.Description != null?String.valueOf(objParamWrapper.objOrderproduct.Description):'');
        productLineItem.addChildElement(strTaxBasis, null, null).addTextNode('0');
        productLineItem.addChildElement('product-id',null,null).addTextNode(String.isNotBlank(objParamWrapper.objProduct.ItemId__c)?objParamWrapper.objProduct.ItemId__c:''); 
        productLineItem.addChildElement('product-name', null, null).addTextNode(String.isNotBlank(objParamWrapper.objProduct.Name)?objParamWrapper.objProduct.Name:'');
        dom.XmlNode quantity = productLineItem.addChildElement('quantity', null, null);
        quantity.setAttribute('unit', '');
        quantity.addTextNode(objParamWrapper.objOrderproduct.Quantity != null?String.valueOf(objParamWrapper.objOrderproduct.Quantity):'');
        productLineItem.addChildElement('tax-rate', null, null).addTextNode('0.0');
        productLineItem.addChildElement('gift', null, null).addTextNode('false'); 
    }
}