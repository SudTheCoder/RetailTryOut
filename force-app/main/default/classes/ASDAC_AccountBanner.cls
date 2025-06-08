public with sharing class ASDAC_AccountBanner {
    public Account accObj { get; set; }
    public String SuspendedDateFormatted { get; set; }
    public String UnderAuditDateFormatted { get; set; }
    
    public ASDAC_AccountBanner(ApexPages.StandardController controller) {
         accObj = [SELECT Id, Name, toLabel(SuspensionReason__c), SuspendedDate__c, UnderAuditDatetime__c FROM Account 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
        if(accObj.SuspendedDate__c != null){
        SuspendedDateFormatted = convertDateFormat(String.ValueOf(accObj.SuspendedDate__c));
        } 
        if(accObj.UnderAuditDatetime__c != null){
        UnderAuditDateFormatted = convertDateFormat(String.ValueOf(accObj.UnderAuditDatetime__c));
        } 
    }
    public static String convertDateFormat(String strDate){
    string d = Datetime.valueOf(strDate.replace('T',' ')).format(System.Label.ASDAC_OmsDateTimeFormat, 'Europe/London');
    return d;
    }
}