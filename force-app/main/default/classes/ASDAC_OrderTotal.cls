public with sharing class ASDAC_OrderTotal {
	@AuraEnabled public Decimal subtotal { get; set; }
    @AuraEnabled public Decimal tax  { get; set; }	 
    @AuraEnabled public Decimal charges { get; set; }
    @AuraEnabled public Decimal discounts { get; set; }
    @AuraEnabled public Decimal totalAmount { get; set; }
}