/***************************************************************************************************************************
* Author:       Ramdev Chahar
* Date:         01 Nov 2022
* Description:  Controller class for Limit Monitor
**************************************************************************************************************************/
public with sharing class ASDAC_DailyBulkApiLimit_Controller {
    /********************************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          01 Nov 2022
    @param         none
    @return        Map of String and String
    @description   This method is used to get DailyBulkAPILimit
    *********************************************************************************************************/
    public static final String DAILYBULKAPI_NAME = 'DailyBulkApiBatches';
    @AuraEnabled(cacheable = true)
    public static Map<string,string> getDailyBulkAPILimit(){
        Map<String, OrgLimit> mapOrgLimit = new Map<String, OrgLimit>();
        mapOrgLimit =  OrgLimits.getMap();
        OrgLimit objOrgLimit = mapOrgLimit.get(DAILYBULKAPI_NAME);
        Map<String, String> maptoReturn = new Map<String, String>();
        maptoReturn.put('max', ''+objOrgLimit.getLimit());
        maptoReturn.put('consumed',''+objOrgLimit.getValue());
        return maptoReturn;
        
    }
}