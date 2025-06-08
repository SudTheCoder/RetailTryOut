/**********************************************************************************
* @author                       : Akshay Singh Shekhawat
* @date                         : 2022-02-07
* @description                  : OMS Case Selector
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Akshay Singh Shekhawat           07-Feb-2022        OMS Integration re-design
***************************************************************************************************/
public with sharing class ASDAC_CaseSelector {

    @AuraEnabled(Cacheable = true)
    public static List<CaseWrapper> getCase(string orderid) {
        List<CaseWrapper> caseWrapperList = new List<CaseWrapper>();

        List<Case> caseList = [SELECT Id,Status,RecordType.Name,WorkQueue__c,CaseNumber,ContactReasonLevel2__c,
                               ContactReasonLevel1__c,CreatedDate 
                               FROM Case 
                               WHERE OrderId__c =: orderid 
                               ORDER BY CreatedDate DESC];
        for(Case caseRecord: caseList){
            CaseWrapper caseWrap = new CaseWrapper();
            caseWrap.id = caseRecord.Id;
            caseWrap.status = caseRecord.Status;
            caseWrap.recordTypeName = caseRecord.RecordType.Name;
            caseWrap.workQueue = caseRecord.WorkQueue__c;
            caseWrap.caseNumber = caseRecord.CaseNumber;
            caseWrap.contactReasonLevel1 = caseRecord.ContactReasonLevel1__c;
            caseWrap.contactReasonLevel2 = caseRecord.ContactReasonLevel2__c;
            caseWrap.createdDate = caseRecord.CreatedDate;
            caseWrapperList.add(caseWrap);
        }
        return caseWrapperList;
    }

    public class CaseWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String status;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public String workQueue;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String contactReasonLevel2;
        @AuraEnabled public String contactReasonLevel1;
        public DateTime createdDate;
        @AuraEnabled public String formattedCreatedDate {
            get {
                return ASDAC_OrderUtility.convertDateTimeString(createdDate);
            }
        }
    }
    
    /**
    * ****************************************************************************************************
    * @param caseList list of case w.r.t orderId
    * @param pOrder linked order/searched order
    * @description Send out linked/searched orderId
    * @return String Order Id
    * ****************************************************************************************************
    */
    public static String getOrderIdForCase(list<Case> caseList, String pOrder){
        String strOrderId = '';
        strOrderId = caseList[0]?.OrderId__c;
        return String.isNotBlank(strOrderId) ? strOrderId : pOrder;
    }
    
    public static List<Case> getCaseList(Id pCaseId){
        return [SELECT Id, OrderId__c, Account.ExternalId__c, Account.PersonContactId 
                FROM Case 
                WHERE Id =: pCaseId WITH SECURITY_ENFORCED LIMIT 1];
    }

     /**
* ****************************************************************************************************
* Author: Swapnil
* @param orderId 
* @param ContactreasonLevel2 
* @description //getting case that has not genereated vat and first case on order which is VatRequet
* @return String Case VAT Id
* ****************************************************************************************************
*/

    @AuraEnabled
    public static String getVATParentCase(string orderid, String contactReasonVatReceipt) {
        Case caseID;
        String caseVatId= '';
        try { 
            
            caseID = [SELECT Id,IsVatReceiptGenerated__c FROM Case WHERE OrderId__c =:orderid AND ContactReasonLevel2__c=:contactReasonVatReceipt 
            ORDER BY CreatedDate ASC limit 1];
            if(caseID.IsVatReceiptGenerated__c == false)
            {
                caseVatId = caseID.Id;
            }
            else {
                caseVatId = '';
            }
        
        } catch (Exception ex) {
            caseVatId = System.Label.ASDAC_VAtCaseNotFound;
        }
        
        return caseVatId;
    }

    /**
     * ****************************************************************************************************
     * @param caseIdsList list of case Ids
     * @description method to get cases from Flow for Webforms
     * ****************************************************************************************************
     */
    @InvocableMethod(label='Get Webform Cases' description='Get Case records from Flow')
    public static List<List<Case>> getWebformCases(List<List<Id>> caseIdsList) {
        List<List<Case>> caseList = new List<List<Case>>{ASDAC_WithoutSharingUtility.getCases(caseIdsList[0],'CaseNumber')};
        return caseList;
    }
}