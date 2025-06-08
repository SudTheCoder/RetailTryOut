/**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 26/05/2023
* @description                  : ASDAC_8063 Rel C - GHS - GV - CCA UI API integration - Disable Voucher

**********************************************************************************/
public with sharing class ASDAC_DisableGoodWillVoucher {
    
    @auraEnabled(Cacheable=True)
    public static void doDisableVoucher(String walletId, String voucherId){  
        try{           
            Http http = new Http();
            
            String strURL = '/wallet/'+walletId+'/account/'+voucherId+'/cancel';
            
            HttpRequest ghsVoucherDisable = ASDAC_HashTokenGenerator.sendAISRequest('', 'PATCH', strURL);
            HttpResponse response = http.send(ghsVoucherDisable);
            if(response.getStatusCode()!=200){
                throw new AuraException(System.Label.ASDAC_GHSVoucherDisableError);
            }          
        }catch(Exception e){
            System.debug('Errro '+e.getMessage());
            System.debug('Line '+e.getLineNumber());
            throw new AuraException(System.Label.ASDAC_GHSVoucherDisableError);
        }
    }
    
}