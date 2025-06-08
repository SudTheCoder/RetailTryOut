public with sharing class ASDAC_OrderLineStateResponse {
  @AuraEnabled
  public String state;
  @AuraEnabled
  public Decimal quantity;
  @AuraEnabled
  public Datetime stateUpdatedTime; 
  @AuraEnabled
  public string discountText;
    public ASDAC_OrderLineStateResponse(){
        if(Test.isRunningTest()){
            state = 'Test';
        }
    }
}