public with sharing class ASDAC_ATPInventoryCheckRequest {
    public String orgId = ASDAC_OMSConstants.ASDA_STRING;
    public String sellingChannel = ASDAC_OMSConstants.GEORGECOM_STRING;
    public String transactionType = ASDAC_OMSConstants.eComm_STRING;
    public String segment = ASDAC_OMSConstants.DEFAULT_STRING;
    public List<ASDAC_OrderLineRequest> products { get; set; }
}