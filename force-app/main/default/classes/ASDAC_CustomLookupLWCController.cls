/**************************************************************************************************************
* @author                       : Akshay Singh Shekhawat
* @date                         : 13/12/2022
* @description                  : ASDAC-6447
*************************************************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Akshay Singh Shekhawat       13/12/2022          Initial Class Code
* 
***************************************************************************************************/
public with sharing class ASDAC_CustomLookupLWCController {
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getsearchedRecords(String sObjectName, String searchParametersJsonString) {
        return ASDAC_CustomLookupLWCControllerService.getRecords(sObjectName, searchParametersJsonString);
    }
}