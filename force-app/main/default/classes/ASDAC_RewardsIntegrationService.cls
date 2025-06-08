public class ASDAC_RewardsIntegrationService implements ASDAC_IntegrationServices {
 
    /**
   * ****************************************************************************************************
   * @param stringifiedJSON stringified json
   * @description method to create request
   * @return String
   * ****************************************************************************************************
   */
  public String createRequest(String stringifiedJSON) {
    return null;
  }
  /**
   * ****************************************************************************************************
   * @param metadataRecord integration metadata record
   * @param stringifiedJSON stringified json
   * @description method to do callout
   * @return ASDAC_IntegrationUtility.ResultWrapper
   * ****************************************************************************************************
   */
  public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt metadataRecord, String stringifiedJSON) {
    Rewardswrapper req = (Rewardswrapper) JSON.deserialize(stringifiedJSON, Rewardswrapper.class);
    ASDAC_IntegrationUtility.IntegrationWrapper intWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
    String crmId =req.crmId;
    intWrapper.metadataRecord = metadataRecord;
    intWrapper.requestBody = stringifiedJSON;
    intWrapper.listOfQueryParameters = new List<String>{crmId};
    system.debug('check intWrapper '+ intWrapper);
    HttpResponse res = ASDAC_IntegrationUtility.sendRequest(intWrapper, false).response;
    return new ASDAC_IntegrationUtility.ResultWrapper(res);
  }
 
    
    public class Rewardswrapper {
        public List<String> params;
    	public String body;
        public String crmId;
      public ASDAC_IntegrationUtility.IntegrationWrapper toIntegrationWrapper() {
      ASDAC_IntegrationUtility.IntegrationWrapper intWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
      //intWrapper.requestBody = crmId;
     // intWrapper.listOfQueryParameters = new List<String>{crmId};
      system.debug('check intWrapper '+ intWrapper);
      return intWrapper;
    }
   }
}