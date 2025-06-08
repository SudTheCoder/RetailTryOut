/**********************************************************************************
 * @author                       : Sai
 * @date                         : 2022-10-13
 * @description                  : ASDAC-3395  QuickLinks
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Sai                 13-oct-2022     Created the class
 ***************************************************************************************************/
public with sharing class ASDAC_QuickLinksController {
  public class ResponseWrapper {
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<MetadataWrapper> listOfActiveMdtRecords;

    public ResponseWrapper(
      Boolean isSuccess,
      String message,
      List<MetadataWrapper> listOfActiveMdtRecords
    ) {
      this.isSuccess = isSuccess;
      this.message = message;
      this.listOfActiveMdtRecords = listOfActiveMdtRecords;
    }
  }

  public class MetadataWrapper {
    @AuraEnabled
    public String metadataCategory;
    @AuraEnabled
    public List<ASDAC_QuickLink__mdt> quickLinks;
    public MetadataWrapper(
      String metadataCategory,
      List<ASDAC_QuickLink__mdt> quickLinks
    ) {
      this.metadataCategory = metadataCategory;
      this.quickLinks = quickLinks;
    }
  }

  @AuraEnabled(cacheable=true)
  public static ResponseWrapper asdaQuicklink() {
    ResponseWrapper respWrap;
    try {
      Map<String, List<ASDAC_QuickLink__mdt>> mapOfCtgryNameToQuickLinksList = new Map<String, List<ASDAC_QuickLink__mdt>>();
      List<ASDAC_QuickLink__mdt> mcs = [
        SELECT
          Id,
          MasterLabel,
          TabOrder__c,
          Language,
          NamespacePrefix,
          Label,
          QualifiedApiName,
          URL__c,
          Order__c,
          isActive__c,
          Category__c
        FROM ASDAC_QuickLink__mdt
        WHERE isActive__c = TRUE AND Category__c != NULL
        ORDER BY TabOrder__c, Order__c
      ];
      for (ASDAC_QuickLink__mdt quickLink : mcs) {
        if (
          !mapOfCtgryNameToQuickLinksList.containsKey(quickLink.Category__c)
        ) {
          mapOfCtgryNameToQuickLinksList.put(
            quickLink.Category__c,
            new List<ASDAC_QuickLink__mdt>()
          );
        }
        mapOfCtgryNameToQuickLinksList.get(quickLink.Category__c)
          .add(quickLink);
      }
      List<MetadataWrapper> listOfActiveMdtRecords = new List<MetadataWrapper>();
      for (String ctgryName : mapOfCtgryNameToQuickLinksList.keyset()) {
        listOfActiveMdtRecords.add(
          new MetadataWrapper(
            ctgryName,
            mapOfCtgryNameToQuickLinksList.get(ctgryName)
          )
        );
      }
      respWrap = new ResponseWrapper(true, '', listOfActiveMdtRecords);
    } catch (Exception ex) {
      respWrap = new ResponseWrapper(
        false,
        ex.getMessage(),
        new List<MetadataWrapper>()
      );
    }
    return respWrap;
  }
}