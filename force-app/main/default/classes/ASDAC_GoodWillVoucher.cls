/**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 25/05/2023
* @description                  : ASDAC_7904 Rel C - GHS - GV - CCA UI API integration - View Customer's Voucher History
* @Modified By                  : Niteesh Kumar
**********************************************************************************/

public with sharing class ASDAC_GoodWillVoucher {
    
    @AuraEnabled(cacheable=true)
    public static List<Object> getGoodwillVoucher(String walletId) {
        try{
            List<ASDAC_GoodWillVoucher.VoucherResponse> voucherResponseList = new List<ASDAC_GoodWillVoucher.VoucherResponse>();
            
            String strURL = '/wallet/'+walletId+'/vouchers?clientType[]=GOODWILL_VOUCHER&status[]=ACTIVE&status[]=LOCKED&orderBy=dateCreated,DESC';
            
            Http http = new Http();
            HttpRequest getVoucherListRequest = ASDAC_HashTokenGenerator.sendAISRequest('','GET', strURL);
            
            HttpResponse response = http.send(getVoucherListRequest);
            Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> voucherList = (List<Object>) jsonResponseMap.get('results');
            for (Object obj : voucherList) {
                Map<String, Object> voucherResultMap = (Map<String, Object>) obj;
                Object metaObj = voucherResultMap.get('meta');
                
                //declaring overrideList as it can be an array or a Object
                //if its a array than it will be in LIST and if its object then it will be in MAP
                
                String reasonCode = metaObj!=null? getReasonCode(metaObj):'';
                List<Object> overridesList = new List<Object>();
                
                Object overridesObj = voucherResultMap.get('overrides');
                
                overridesList = getOverrides(overridesObj);
                for (Object overrides : overridesList) {
                    Map<String, Object> rewardMap = new Map<String, Object>();
                        Map<String, Object> overridesMap = (Map<String, Object>) overrides;
                        Map<String, Object> offerMap = (Map<String, Object>) overridesMap.get('offer');
                        rewardMap = (Map<String, Object>) offerMap.get('reward');
                   		Map<String, Object> dateMap = (Map<String, Object>) voucherResultMap.get('dates');
                    
                    Map<String, Object> dataConstruct = new Map<String, Object>();
                    
                    
                    if ( voucherResultMap.get('status')=='ACTIVE' || voucherResultMap.get('status')=='LOCKED') {
                        String voucherType = getVoucherType(voucherResultMap);
                        dataConstruct.put('clientType', voucherType);
                        dataConstruct.put('status', voucherResultMap.get('status'));
                        dataConstruct.put('discountAmount',getAmount(rewardMap));
                        dataConstruct.put('locked',getStatus(voucherResultMap.get('status')));
                        dataConstruct.put('voucherId',voucherResultMap.get('accountId'));
                        dataConstruct.put('reasonCode',reasonCode);
                        
                        //Formatting issueDate into proper date Time
                        // String issueDate = (String) dateMap.get('start');
                        String issueDate = (String) voucherResultMap.get('dateCreated');
                        DateTime issueDateInstant = DateTime.valueOfGmt(issueDate.replace('T', ' ').substringBefore('.'));
                        String formattedIssueDate = issueDateInstant.format('dd MMMM yyyy, EE hh:mm a', 'Europe/London');
                        dataConstruct.put('issueDate',formattedIssueDate);
                       
                        //Formatting Expiry date into proper date Time
                        String expiryDate = (String)dateMap.get('end');
                        DateTime expiryDateInstant = DateTime.valueOfGmt(expiryDate.replace('T', ' ').substringBefore('.'));
                        String formattedExpiryDate = expiryDateInstant.format('dd MMMM yyyy, EE hh:mm a', 'Europe/London');
                        dataConstruct.put('expiryDate',formattedExpiryDate);
                        
                        voucherResponseList.add(new VoucherResponse(dataConstruct));
                    }
                }
            }
            return voucherResponseList;
        }catch(Exception e){
            writeLogsToDatabase(e.getMessage());
            System.debug('Exception : '+e.getMessage());
            return null;
        }
        
    }
    /**
* ****************************************************************************************************
* @param exceptionMessage exception message
* @description future method to write logs to database
* ****************************************************************************************************
*/
    
    @Future
    private static void writeLogsToDatabase(String exceptionMessage) {
        ASDAC_Logger.logException(exceptionMessage, ASDAC_GlobalConstants.STRING_LOYALTY, 'ASDAC_GoodWillVoucher');
        ASDAC_Logger.writeLogsToDatabase();
    }
    
    Public static String getVoucherType(Map<String, Object> voucherResultMap){
        Map<String,ASDAC_Loyalty_Campaign_Mapping__c> campaignIdMap = ASDAC_Loyalty_Campaign_Mapping__c.getAll();
        Map<String,String> campaignIdVoucherMap = new Map<String,String>();
        for(ASDAC_Loyalty_Campaign_Mapping__c campaignvalue :campaignIdMap.values()){
            campaignIdVoucherMap.put(campaignvalue.Campaign_Id__c , campaignvalue.MasterLabel__c);
        }
        String campaignId = String.valueOf(voucherResultMap.get('campaignId')) ;
        String voucherType = campaignIdVoucherMap.get(campaignId); 
        return voucherType;
    }
    
    public static String getReasonCode( Object metaObj){
        String reasonCode;
        List<Object> metaObjList = new List<Object>();
        if (metaObj instanceof List<Object>) {
            metaObjList = (List<Object>) metaObj;
        } else if (metaObj instanceof Map<String, Object>) {
            metaObjList.add(metaObj);
        }
        
        for(Object meta: metaObjList){
            Map<String, Object> metaMap = (Map<String, Object>)meta; 
            Map<String, Object> metakeymap = (Map<String, Object>)metaMap;
            
            reasonCode = metakeyMap.get('key1') != null?(String.ValueOf(metakeyMap.get('key1'))).countMatches(':')==2?String.valueOf(metakeyMap.get('key1')).substringAfterLast(':'):metaReasonCode(String.ValueOf(metakeyMap.get('key1'))) : metakeyMap.get('reasoncode')!=null ?String.valueOf(metakeyMap.get('reasoncode')):'';
            
        }
        return reasonCode;
    }
    
        //Break the meta key1 to extract Reason Code
        public static String metaReasonCode(String meta){
            List<String> str = meta.split(',');
            Map<String,String> keymap = new Map<String,String>();
            for(String st:str){
                keymap.put(st.substringBefore(':').trim(),st.substringAfterLast(':'));
            }
            return keymap.get('ReasonCode');
        }
    public static string getstatus(Object status){
        return String.valueOf(status)=='LOCKED'?'Yes':'No';
    }
    public static Decimal getAmount(Map<String,Object> rewardMap){ 
        Decimal amount = rewardMap.containsKey('discountAmount') ?Decimal.valueOf(String.valueOf(rewardMap.get('discountAmount'))):0;  
        return amount/100;
    }
    public static List<Object> getOverrides(Object overridesObj){  
        List<Object> overridesList = new List<Object>();
        if (overridesObj instanceof List<Object>) {
            overridesList = (List<Object>) overridesObj;
        } else if (overridesObj instanceof Map<String, Object>) {
            overridesList.add(overridesObj);
        }
        return overridesList;
    }
    
    public class VoucherResponse {
        @AuraEnabled public String clientType { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String issueDate { get; set; }
        @AuraEnabled public String expiryDate { get; set; }
        @AuraEnabled public Decimal discountAmount { get; set; }
        @AuraEnabled public String voucherId {get; set;} 
        @AuraEnabled public String reasonCode {get; set;}
        @AuraEnabled public String locked;
        @AuraEnabled public Boolean isRewardsVoucher;
        
        public VoucherResponse(Map<String, Object> dataConstruct) {
            this.clientType = String.valueOf(dataConstruct.get('clientType'));
            this.status = String.valueOf(dataConstruct.get('status'));
            this.issueDate = String.valueOf(dataConstruct.get('issueDate'));
            this.expiryDate = String.valueOf(dataConstruct.get('expiryDate'));
            this.discountAmount = Decimal.valueOf(String.valueOf(dataConstruct.get('discountAmount')));
            this.voucherId = string.valueOf(dataConstruct.get('voucherId'));
            this.locked = string.valueOf(dataConstruct.get('locked'));
            this.reasonCode = string.valueOf(dataConstruct.get('reasonCode'));
            this.isRewardsVoucher = String.valueOf(dataConstruct.get('clientType')) == System.Label.ASDAC_RewardsVoucherLabel;
        }
    }
}