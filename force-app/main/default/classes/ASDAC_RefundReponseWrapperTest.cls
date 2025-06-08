@IsTest
public class ASDAC_RefundReponseWrapperTest {
    
    @IsTest
    static void testASDAC_RefundReponseWrapper() {
        String strDateTime = '2023-05-22T11:29:16.919Z';

        // Create test data
        ASDAC_RefundReponseWrapper.Detail detail = new ASDAC_RefundReponseWrapper.Detail();
        detail.state = 'CREATED';
        detail.stateId = '1000';
        detail.quantity = 1;
        
        ASDAC_RefundReponseWrapper.AggregatedState aggregatedState = new ASDAC_RefundReponseWrapper.AggregatedState();
        aggregatedState.details = new List<ASDAC_RefundReponseWrapper.Detail>{ detail };
        
        ASDAC_RefundReponseWrapper.OrderTotals orderTotals = new ASDAC_RefundReponseWrapper.OrderTotals();
        orderTotals.subtotal = 30;
        orderTotals.tax = 0;
        orderTotals.charges = 0;
        orderTotals.discounts = 0;
        orderTotals.totalAmount = 30;
        
        ASDAC_RefundReponseWrapper.AssociationDetail associationDetail = new ASDAC_RefundReponseWrapper.AssociationDetail();
        associationDetail.orgId = 'ASDA';
        associationDetail.sellingChannel = 'ASDA_GROCERIES';
        associationDetail.associationType = 'SalesOrder';
        associationDetail.orderId = 'ASDA-GHS-202305160741641';
        
        ASDAC_RefundReponseWrapper.StateTransitions stateTransitions = new ASDAC_RefundReponseWrapper.StateTransitions();
        ASDAC_RefundReponseWrapper.Transition transition = new ASDAC_RefundReponseWrapper.Transition();
        transition.id = '1';
        transition.event = 'Event';
        transition.previousQuantity = 0;
        transition.newQuantity = 1;
        transition.nextPossibleEvents = new List<String>{ 'NextEvent' };
        transition.stateUpdatedTime = strDateTime;
        transition.correlationId = 'CorrelationID';
        transition.stateId = 'StateID';
        stateTransitions.CREATED = new List<ASDAC_RefundReponseWrapper.Transition>{ transition };
        
        ASDAC_RefundReponseWrapper.Price price = new ASDAC_RefundReponseWrapper.Price();
        price.value = 10;
        price.name = 'Price';
        price.useForTotals = true;
        
        ASDAC_RefundReponseWrapper.OrderLine orderLine = new ASDAC_RefundReponseWrapper.OrderLine();
        orderLine.updateTime = strDateTime;
        orderLine.orderLineId = 1;
        orderLine.orderLineType = 'DELIVERY';
        orderLine.fulfillmentType = 'DELIVERY';
        orderLine.fulfillmentService = 'STANDARD';
        orderLine.quantity = 1;
        orderLine.productId = 'PROD_2389_1';
        orderLine.productDescription = 'ASDA Grower\'s selection strawberries 400g';
        orderLine.uom = 'EACH';
        orderLine.stateTransitions = stateTransitions;
        
        ASDAC_RefundReponseWrapper.CustomFields customFields = new ASDAC_RefundReponseWrapper.CustomFields();
        customFields.refundType = 'Original';
        customFields.refundReason = 'Customer Changed Mind GR';
        customFields.refundNotes = 'Customer did not like item';
        orderLine.customFields = customFields;
        
        ASDAC_RefundReponseWrapper.LineTotals lineTotals = new ASDAC_RefundReponseWrapper.LineTotals();
        lineTotals.subtotal = 30;
        lineTotals.tax = 0;
        lineTotals.charges = 0;
        lineTotals.discounts = 0;
        lineTotals.totalAmount = 30;
        orderLine.lineTotals = lineTotals;
        
        orderLine.isRefundable = true;
        orderLine.associationDetails = new List<ASDAC_RefundReponseWrapper.AssociationDetail>{ associationDetail };
        orderLine.addressInfo = new List<Object>();
        
        ASDAC_RefundReponseWrapper refundResponse = new ASDAC_RefundReponseWrapper();
        refundResponse.updateTime = strDateTime;
        refundResponse.orgId = 'ASDA';
        refundResponse.sellingChannel = 'ASDA_GROCERIES';
        refundResponse.orderId = 'ASDA-GHS-20230518111014131';
        refundResponse.orderType = 'ReturnOrder';
        refundResponse.orderCategory = 'ReturnOrder';
        refundResponse.customerId = '8860077585';
        refundResponse.orderDate = '2023-05-16T05:34:44Z';
        refundResponse.aggregatedState = aggregatedState;
        refundResponse.createTime = null;
        refundResponse.billingCurrency = 'GBP';
        refundResponse.charges = new List<Object>();
        refundResponse.discounts = new List<Object>();
        refundResponse.taxes = new List<Object>();
        refundResponse.orderTotals = orderTotals;
        refundResponse.associationDetails = new List<ASDAC_RefundReponseWrapper.AssociationDetail>{ associationDetail };
        refundResponse.addressInfo = new List<Object>();
        refundResponse.refundPaymentMethod = null;
        refundResponse.refundStatus = null;
        refundResponse.orderLines = new List<ASDAC_RefundReponseWrapper.OrderLine>{ orderLine };
        
    }
}