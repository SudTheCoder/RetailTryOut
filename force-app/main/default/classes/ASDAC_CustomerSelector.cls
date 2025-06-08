/**********************************************************************************
* @author                       : Vineeth Rangamgari
* @date                         : 2022-02-06
* @description                  : OMS Customer Selector
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
***************************************************************************************************/
public with sharing class ASDAC_CustomerSelector {
    /**
    * ****************************************************************************************************
    * @param personAccountId Id of Person account
    * @description method to get Customer Id from Person acccount
    * @return String
    * ****************************************************************************************************
    */
    public static String getCustomerId(Id personAccountId) {
        return [SELECT PersonContactId 
                FROM Account 
                WHERE Id = :personAccountId WITH SECURITY_ENFORCED]?.PersonContactId;
    }
    
    /**
    * ****************************************************************************************************
    * @param customerId Customer Id
    * @param isPersonContactIdUsed check if person Contcat Id need to be used
    * @description get Account based on Customer Id (new CRM Id)
    * @return list<Account> list of person accounts
    * ****************************************************************************************************
    */
    @TestVisible
    public static Account getCustomer(String customerId) {
        List<Account> acctList = new List<Account>();
        Map<String, Schema.SObjectField> accountFieldsMap = Schema.sObjectType.Account.fields.getMap();
        Boolean hasAccessToFields = accountFieldsMap.get('Phone').getDescribe().isAccessible() && accountFieldsMap.get('AccountRegistrationStatus__c').getDescribe().isAccessible() && accountFieldsMap.get('Status__c').getDescribe().isAccessible() && accountFieldsMap.get('SuspensionReason__c').getDescribe().isAccessible() && accountFieldsMap.get('SuspendedDate__c').getDescribe().isAccessible() && accountFieldsMap.get('Under_Audit_Info__c').getDescribe().isAccessible() && accountFieldsMap.get('UnderAuditDatetime__c').getDescribe().isAccessible() && accountFieldsMap.get('IsUnderAudit__c').getDescribe().isAccessible();
        if(Schema.sObjectType.Account.isAccessible() && hasAccessToFields){
        acctList = [SELECT Id, PersonContactId, AccountRegistrationStatus__c, Status__c, toLabel(SuspensionReason__c), SuspendedDate__c, Under_Audit_Info__c, UnderAuditDatetime__c,IsUnderAudit__c
                    FROM Account 
                    WHERE PersonContactId = :customerId WITH SECURITY_ENFORCED LIMIT 1];
        }
        if (acctList.size() == 0) {
          return null;
        }
        return acctList[0];
    }
}