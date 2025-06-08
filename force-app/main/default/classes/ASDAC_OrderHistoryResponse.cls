/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-02-06
 * @description                  : OMS - Order History Response
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
 ***************************************************************************************************/
public with sharing class ASDAC_OrderHistoryResponse {
  @AuraEnabled
    public Integer totalCount;
  @AuraEnabled
    public Integer count;
  @AuraEnabled
    public Integer startIndex;
  @AuraEnabled
    public List<ASDAC_OrderHeaderResponse> data;
    public ASDAC_OrderHistoryResponse(){
        if(Test.isRunningTest()){
            totalCount = 200;
        }
    }
}