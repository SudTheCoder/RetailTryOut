public class ASDAC_LoyaltyGetOrderListWrapper {
    Public Integer totalCount;
    Public Integer count;
    Public Integer startIndex;
    public List<Datalist> data {get;set;}
    public class Datalist{
        Public String customerId;
        Public String orderId ;
        Public String  orderDate;
        Public String  updateTime ;
        Public String  sellingChannel;
        Public Integer  numberOfItems;
        Public String  orderStatus;
        Public String  orderFulfilmentType;
        Public String  storeAddress;
        Public Decimal  totalAmount ;
        Public String deliveryDate ;
        Public String deliveryPassId ;
        Public Boolean deliveryPassUsed;
        Public Decimal actualPrice;
        Public Decimal discountedPrice;
    }
}