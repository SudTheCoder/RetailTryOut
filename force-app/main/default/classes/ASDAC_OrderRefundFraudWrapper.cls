public with sharing class ASDAC_OrderRefundFraudWrapper {
	public Boolean fraudOverride;
    public Boolean fraudBypass;
    public String previousROId;
    public Integer previousROLineId;
    public ASDAC_OrderRefundFraudWrapper(){
        if(Test.isRunningTest()){
            previousROId = 'Test';
        }
    }
}