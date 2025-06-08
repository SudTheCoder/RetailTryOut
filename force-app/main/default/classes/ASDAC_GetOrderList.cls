/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-12-22
* @description                  : ASDAC-15573 - GetOrderList PS AIS Endpoint (Savings Guarantee)
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                22-Dec-2023      Created the class
***************************************************************************************************/
public with sharing class ASDAC_GetOrderList Implements Queueable, Database.AllowsCallouts{
    public Asset asst;
    /******************************************************************************************************
    * @param : Customer CRMID(ContactId)
    * @description : get request to AIS for OrderList Detail
    * @return OrderList 
    * ****************************************************************************************************/
   List<Id> assetIds = new List<Id>();
    public ASDAC_GetOrderList(Asset asst){
        this.asst = asst;
    }

    //Queueable call
    public void execute(QueueableContext context) {
        ASDAC_LoyaltyGetOrderListWrapper responseBody = ASDAC_GetOrderList.getOrderList(asst.ContactId);
        if(!Test.isRunningTest()){
            System.enqueueJob(new ASDAC_SavingGurantee(responseBody,asst));
        }
    }
    

    public static ASDAC_LoyaltyGetOrderListWrapper getOrderList(Id contactId){
        String getOrderlistUrl = ASDAC_Loyalty_base_urls__mdt.getInstance('LoyaltyGetOrderList').Traget_endpoint__c;
        Http http = new Http();
        String url =getOrderlistUrl+contactId;
        HttpRequest getOrderListRequest = new HttpRequest();
        getOrderListRequest.setMethod('GET');
        getOrderListRequest.setEndpoint(url);
        HttpResponse orderList = http.send(getOrderListRequest);
        if(orderList.getStatusCode() ==200){
            ASDAC_LoyaltyGetOrderListWrapper responseBody = (ASDAC_LoyaltyGetOrderListWrapper)System.JSON.deserialize(orderList.getBody(), ASDAC_LoyaltyGetOrderListWrapper.class);
       	    return responseBody;  
        }else{
            return null;
        }
    }
}