/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-05-27
 * @description                  : ASDAC-940 Help Centre Alerts - informative
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            27-May-2022     Created the class
 * Vineeth Rangamgari            27-May-2022     Updated the class for ASDAC-965
 * Vineeth Rangamgari            27-May-2022     Updated the class for ASDAC-966
 ***************************************************************************************************/
public with sharing class ASDAC_GeneralAlertController {
  private static final String COMMUNITY_NAME = 'Help';
  private static final Integer CONTENT_PAGE_NUMBER = 0;
  private static final Integer CONTENT_PAGE_SIZE = 25;
  private static final String CONTENT_LANGUAGE = 'en_US';
  private static final String CONTENT_TYPE = 'general_alert';
  @testVisible
  private static ConnectApi.ManagedContentVersionCollection mockedContentCollection;

  /**
   * ****************************************************************************************************
   * @description method to get currently published Alerts
   * @return List\<GeneralAlertWrapper\>
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static List<GeneralAlertWrapper> getAlerts() {
    try {
      String communityId = Network.getNetworkId();
      ConnectApi.ManagedContentVersionCollection contentCollection;
      if (Test.isRunningTest()) {
        contentCollection = mockedContentCollection;
      } else {
        // ConnectApi to fetch CMS content
        contentCollection = ConnectApi.ManagedContent.getAllManagedContent(communityId, CONTENT_PAGE_NUMBER, CONTENT_PAGE_SIZE, CONTENT_LANGUAGE, CONTENT_TYPE);
      }
      List<GeneralAlertWrapper> alerts = new List<GeneralAlertWrapper>();
      for (ConnectApi.ManagedContentVersion content : contentCollection.items) {
        alerts.add(new GeneralAlertWrapper(content)); // Response Wrapper for Alert
      }
      return alerts;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**********************************************************************************
   * @author                       : Vineeth Rangamgari
   * @date                         : 2022-05-27
   * @description                  : wrapper class for General Alert
   **********************************************************************************/
  public class GeneralAlertWrapper {
    /**
     * @description id of the general alert
     */
    @AuraEnabled
    public String id { get; set; }
    /**
     * @description message (rich text) to be displayed
     */
    @AuraEnabled
    public String message { get; set; }
    /**
     * @description variant of the alert: Informative, Warning or Crisis
     */
    @AuraEnabled
    public String variant { get; set; }
    /**
     * @description placement of the alert: Navigation, or Bottom
     */
    @AuraEnabled
    public String placement { get; set; }
    /**
     * @description indicates if the alert is dismissable
     */
    @AuraEnabled
    public Boolean dismissable { get; set; }

    /**
     * ****************************************************************************************************
     * @param content general alert content of type ConnectApi.ManagedContentVersion
     * @description constructor to create General Alert
     * ****************************************************************************************************
     */
    public GeneralAlertWrapper(ConnectApi.ManagedContentVersion content) {
      this.id = content.managedContentId;
      this.variant = ((ConnectApi.ManagedContentTextNodeValue) content.contentNodes.get('type')).value;

      this.message = getValue(content.contentNodes.get('body'));

      this.placement = getValue(content.contentNodes.get('placement'));
      if (!'bottom'.equalsIgnoreCase(this.placement)) {
        this.placement = 'navigation';
      }

      String dismissable;
      dismissable = getValue(content.contentNodes.get('dismissable'));
      this.dismissable = !('false'.equalsIgnoreCase(dismissable));
    }

    private String getValue(ConnectApi.ManagedContentNodeValue node) {
      ConnectApi.ManagedContentTextNodeValue textNode = (ConnectApi.ManagedContentTextNodeValue) node;
      if (textNode != null) {
        return textNode.value;
      }
      return null;
    }
  }
}