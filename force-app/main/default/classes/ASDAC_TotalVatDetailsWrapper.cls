public with sharing class ASDAC_TotalVatDetailsWrapper {
     @AuraEnabled public String type { get; set; }
     @AuraEnabled public Decimal totalPrice { get; set; }	
     @AuraEnabled public Decimal vatRate { get; set; }	
     @AuraEnabled public Decimal exVat { get; set; }
     @AuraEnabled public Decimal vatAmount { get; set; }

     @AuraEnabled public String totalPriceFormatted {
          get {
              return totalPrice < 0 ? '-£'+String.valueOf(Math.abs(totalPrice).setScale(2)) : '£'+String.valueOf(Math.abs(totalPrice).setScale(2));
          }
      }
      @AuraEnabled public String exVatFormatted{
          get {
              return exVat < 0 ? '-£'+String.valueOf(Math.abs(exVat).setScale(2)) : '£'+String.valueOf(Math.abs(exVat).setScale(2));
          }
      }
      @AuraEnabled public String vatAmountFormatted{
          get {
              return vatAmount < 0 ? '-£'+String.valueOf(Math.abs(vatAmount).setScale(2)) : '£'+String.valueOf(Math.abs(vatAmount).setScale(2));
          }
      }
}