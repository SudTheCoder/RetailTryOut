/**********************************************************************************
* @author        : Sanskriti Vijay
* @date          : 12-06-2023
* @description   : ASDAC_DownloadVatReceiptController is the controller class to initiate and load vfPage VatReceiptPdf.
**********************************************************************************/
public with sharing class ASDAC_DownloadVatReceiptController {

    public static ASDAC_VatReceiptWrapper orderDetails {get; set;}
    public  String orderId;
    public  String sellingChannel;

     /**
   * ****************************************************************************************************
   * @author        : Sanskriti Vijay
   * @description   :  constructor method called form the vfPage initialized in generatePdf() method
   * ****************************************************************************************************
   */

    public ASDAC_DownloadVatReceiptController(){
        orderId = ApexPages.CurrentPage().getParameters().get('orderId').escapeHtml4();
        sellingChannel = ApexPages.CurrentPage().getParameters().get('sellingChannel').escapeHtml4();
        ASDAC_OrderResponse order = ASDAC_OrderController.getOrder(sellingChannel, orderId, new List<String>());
        ASDAC_VatReceiptWrapper orderWrapper = (ASDAC_VatReceiptWrapper)JSON.deserialize(JSON.serialize(order), ASDAC_VatReceiptWrapper.class);
        orderWrapper.categoryMap = (Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>>)JSON.deserialize(getCategoryMap(order), Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>>.class);
        
        orderWrapper.vatDate = Datetime.now().format('dd MMMM yyyy');
        if(!orderWrapper.orderFulfilmentTypeGrocery.contains('Delivery')){
            List<Account> accList = [Select AddressLine1__pc, AddressLine2__pc,AddressLine3__pc,City__pc,State__pc, Country__pc, PostalCode__pc   from Account where PersonContactId =: orderWrapper.customerId Limit 1];
            if(!accList.IsEmpty()){
                orderWrapper.shipToAddress.addressLine1 = accList[0].AddressLine1__pc;
                orderWrapper.shipToAddress.addressLine2 = (String.isBlank(accList[0].AddressLine2__pc) ? '' : accList[0].AddressLine2__pc) + (String.isBlank(accList[0].AddressLine3__pc) ? '' : accList[0].AddressLine3__pc);
                orderWrapper.shipToAddress.city = accList[0].City__pc;
                orderWrapper.shipToAddress.state = accList[0].State__pc;
                orderWrapper.shipToAddress.country = accList[0].Country__pc;
                orderWrapper.shipToAddress.zipCode = accList[0].PostalCode__pc;
            }else{
                orderWrapper.shipToAddress = new ASDAC_OrderAddress();
            }
        }
        orderDetails = orderWrapper;
    }

      /**
   * ****************************************************************************************************
   * @author        : Sanskriti Vijay
   * @description   :  returns a json string of a map created on order line items based on the item category, 
   *                   promotional deductions and refunds present in that order
   * ****************************************************************************************************
   */

    public static String getCategoryMap(ASDAC_OrderResponse order){
        Map<String, List<ASDAC_OrderLineItemResponse>> categoryMap = new Map<String, List<ASDAC_OrderLineItemResponse>>();
        
        for(ASDAC_OrderLineItemResponse ordItm: order.orderItems){
            ordItm.productType = !String.isBlank(ordItm.productType) ? ordItm.productType.substring(0, 1).toUpperCase() + ordItm.productType.substring(1).toLowerCase() : ordItm.productType;
            if(categoryMap.containsKey(ordItm.productType) && (ordItm.totalPrice!=0 && !ordItm.isCharitableProduct && !ordItm.lineStatus.equalsIgnoreCase('Cancelled'))){
                List<ASDAC_OrderLineItemResponse> itemList = categoryMap.get(ordItm.productType);
                itemList.add(ordItm);
                categoryMap.put(ordItm.productType, itemList);
            }
            else if(ordItm.totalPrice!=0 && !ordItm.isCharitableProduct && !ordItm.lineStatus.equalsIgnoreCase('Cancelled')){
                List<ASDAC_OrderLineItemResponse> itemList = new List<ASDAC_OrderLineItemResponse>();
                itemList.add(ordItm);
                categoryMap.put(ordItm.productType, itemList);
            }
        }
        
        if(order.originalDeliveryCharge > 0 && order.originalDeliveryCharge > order.deliveryChargeRefund){
            ASDAC_OrderLineItemResponse deliveryCostItem = order.orderItems[0];
            List<ASDAC_OrderLineItemResponse> deliveryCostList = new List<ASDAC_OrderLineItemResponse>();
            deliveryCostList.add(deliveryCostItem);
            categoryMap.put(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR, deliveryCostList);
        }

        List<ASDAC_OrderLineItemResponse> refundItemList = getRefundItemList(order);
       
        if(!refundItemList.isEmpty()){
            categoryMap.put(ASDAC_OMSConstants.VAT_REFUNDS_STR, refundItemList);
        }

        return JSON.serialize(categoryMap);

    }

     /**
   * ****************************************************************************************************
   * @author        : Sanskriti Vijay
   * @description   :  returns a list of a refund order items where the line status is 'complete'
   * ****************************************************************************************************
   */
    public static List<ASDAC_OrderLineItemResponse> getRefundItemList(ASDAC_OrderResponse order){
        List<ASDAC_OrderLineItemResponse> refundItemList = new List<ASDAC_OrderLineItemResponse>();
        for(ASDAC_ReturnOrderResponse refund: order.returnOrders){
            for(ASDAC_OrderLineItemResponse ordItm: refund.orderItems){
                if((ASDAC_OMSConstants.REFUND_SUCCESSFUL_STATUS_STR).equalsIgnoreCase(ordItm.lineStatus) && !ordItm.isCharitableProduct){ 
                    refundItemList.add(ordItm);
                }
            }
        }
        return refundItemList;
    }

  /**
   * ****************************************************************************************************
   * @author        : Sanskriti Vijay
   * @description   : this method is called form the component 'asdacDownloadVatReceipt' to generate vfpage
   *                  in form of a pdf and return the blob string back to component.
   * //@Author Modified :Swapnil 
   * description : Adding VatRecipt to Vat Parent Case and Download functionlaity is cancelled 
   * ****************************************************************************************************
   */
    @AuraEnabled
    public static void generatePdf(String orderId, String sellingChannel, Id caseId){
        
        PageReference vfpage = Page.VatReceiptPdf;
        vfpage.getParameters().put('orderId',orderId); 
        vfpage.getParameters().put('sellingChannel',sellingChannel); 
        
        Blob body;
        if (!test.isRunningTest()){
            body = vfpage.getContentAsPDF();
        }   
        else {
            body = Blob.valueOf('Test mode.');
        }
         
        ContentVersion conVer = new ContentVersion();
        conVer.PathOnClient =  System.label.ASDAC_VatReceiptFileName.replace('{0}',orderId); 
        conVer.Title = System.label.ASDAC_VatReceiptFileName.replace('{0}',orderId);
        conVer.VersionData = body; 
        insert conVer;    

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id limit 1].ContentDocumentId;

        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = caseId; 
        conDocLink.ContentDocumentId = conDoc; 
        conDocLink.shareType = 'V';
        insert conDocLink;
    }
}