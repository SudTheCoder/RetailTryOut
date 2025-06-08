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
@IsTest
public class ASDAC_GeneralAlertController_Test {
  @IsTest
  static void testGetAlerts() {
    ConnectApi.ManagedContentVersionCollection managedContentVerColl = new ConnectApi.ManagedContentVersionCollection();
    managedContentVerColl.items = new List<ConnectApi.ManagedContentVersion>();
    ConnectApi.ManagedContentVersion managedContentVersion = new ConnectApi.ManagedContentVersion();

    ConnectApi.ManagedContentTextNodeValue placementTxtNodeVal = new ConnectApi.ManagedContentTextNodeValue();
    placementTxtNodeVal.value = 'Navigation';

    ConnectApi.ManagedContentTextNodeValue typeTxtNodeVal = new ConnectApi.ManagedContentTextNodeValue();
    placementTxtNodeVal.value = 'Warning';

    ConnectApi.ManagedContentTextNodeValue bodyTxtNodeVal = new ConnectApi.ManagedContentTextNodeValue();
    bodyTxtNodeVal.value = '&lt;p&gt;Have funds in your account the day before your order so we can set up your payment with your bank. We’ll only charge you on the day.&lt;/p&gt;';

    ConnectApi.ManagedContentTextNodeValue dismissableTxtNodeVal = new ConnectApi.ManagedContentTextNodeValue();
    dismissableTxtNodeVal.value = 'false';

    managedContentVersion.contentNodes = new Map<String, ConnectApi.ManagedContentTextNodeValue>{
      'placement' => placementTxtNodeVal,
      'type' => typeTxtNodeVal,
      'body' => bodyTxtNodeVal,
      'dismissable' => dismissableTxtNodeVal
    };
    managedContentVerColl.items.add(managedContentVersion);
    ASDAC_GeneralAlertController.mockedContentCollection = managedContentVerColl;
    List<ASDAC_GeneralAlertController.GeneralAlertWrapper> alerts = ASDAC_GeneralAlertController.getAlerts(); // Checking for correct execution of the method
    System.assertEquals(1, alerts.size(), 'Expected 1 alert'); // Returned data is Org data (Alerts currently published will be returned, can be 0)
  }

  @isTest
  static void testGetAlertsException() {
    Boolean isExceptionOccured = false;
    try {
      ASDAC_GeneralAlertController.getAlerts();
    } catch (Exception ex) {
      isExceptionOccured = true;
    }
    System.assertEquals(true, isExceptionOccured, 'Exception occured');
  }
}