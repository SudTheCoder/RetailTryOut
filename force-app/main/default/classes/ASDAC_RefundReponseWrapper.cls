public class ASDAC_RefundReponseWrapper {

    public String updateTime { get; set; }
    public String orgId { get; set; }
    public String sellingChannel { get; set; }
    public String orderId { get; set; }
    public String orderType { get; set; }
    public String orderCategory { get; set; }
    public String customerId { get; set; }
    public String orderDate { get; set; }
    public AggregatedState aggregatedState { get; set; }
    public String createTime { get; set; }
    public String billingCurrency { get; set; }
    public List<Object> charges { get; set; }
    public List<Object> discounts { get; set; }
    public List<Object> taxes { get; set; }
    public OrderTotals orderTotals { get; set; }
    public List<AssociationDetail> associationDetails { get; set; }
    public List<Object> addressInfo { get; set; }
    public String refundPaymentMethod { get; set; }
    public String refundStatus { get; set; }
    public List<OrderLine> orderLines { get; set; }
    
    public class AggregatedState {
        public List<Detail> details { get; set; }
    }
    
    public class Detail {
        public String state { get; set; }
        public String stateId { get; set; }
        public Integer quantity { get; set; }
    }
    
    public class OrderTotals {
        public Double subtotal { get; set; }
        public Double tax { get; set; }
        public Double charges { get; set; }
        public Double discounts { get; set; }
        public Double totalAmount { get; set; }
    }
    
    public class AssociationDetail {
        public String orgId { get; set; }
        public String sellingChannel { get; set; }
        public String associationType { get; set; }
        public String orderId { get; set; }
    }
    
    public class OrderLine {
        public String updateTime { get; set; }
        public Integer orderLineId { get; set; }
        public String orderLineType { get; set; }
        public String fulfillmentType { get; set; }
        public String fulfillmentService { get; set; }
        public Double quantity { get; set; }
        public String productId { get; set; }
        public String productDescription { get; set; }
        public String uom { get; set; }
        public String stateTransitionFlowId { get; set; }
        public CustomFields customFields { get; set; }
        public AggregatedState aggregatedState { get; set; }
        public StateTransitions stateTransitions { get; set; }
        public String reasonCode { get; set; }
        public List<Price> prices { get; set; }
        public List<Object> charges { get; set; }
        public List<Object> discounts { get; set; }
        public List<Object> taxes { get; set; }
        public LineTotals lineTotals { get; set; }
        public Boolean isRefundable { get; set; }
        public List<AssociationDetail> associationDetails { get; set; }
        public List<Object> addressInfo { get; set; }
    }
    
    public class CustomFields {
        public String refundType { get; set; }
        public String refundNotes { get; set; }
        public String refundReason { get; set; }
    }
    
    public class StateTransitions {
        public List<Transition> CREATED { get; set; }
    }
    
    public class Transition {
        public String id { get; set; }
        public String event { get; set; }
        public Integer previousQuantity { get; set; }
        public Integer newQuantity { get; set; }
        public List<String> nextPossibleEvents { get; set; }
        public String stateUpdatedTime { get; set; }
        public String correlationId { get; set; }
        public String stateId { get; set; }
    }
    
    public class Price {
        public Double value { get; set; }
        public String name { get; set; }
        public Boolean useForTotals { get; set; }
    }
    
    public class LineTotals {
        public Double subtotal { get; set; }
        public Integer tax { get; set; }
        public Integer charges { get; set; }
        public Integer discounts { get; set; }
        public Double totalAmount { get; set; }
    }

}