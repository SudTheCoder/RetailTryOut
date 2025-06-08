/******************************************************************************
Name: ASDAC_CaseHandler
===============================================================================
Req: 
ASDAC-946 Case Escalation
ASDAC-1861 Retention rules for CPQC
===============================================================================
Purpose:Handler class for Case Trigger
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE              	DETAIL
1.0       Nitish Yadav    		25 July 2022          Initial Development
1.1       Sai Shivakoti   		1 August 2022         Initial Development
1.2       Vineeth Rangamgari  4 August 2022         Resolved Defect on SLA
1.3       Vineeth Rangamgari  24 August 2022        Resolved Auto-response issue
1.4       Disharee Ray        9th September 2024    Refactored preventDeletion method as per ASDAC-21493
******************************************************************************/
public with sharing class ASDAC_CaseHandler extends ASDAC_TriggerFramworkService {
	private Map<Id, Case> oldCaseMap;
  	private List<Case> lstNewCase;
	private List<Case> lstOldCase;
	private Boolean contactCenterEnable = false;
	/**
	* @description constructor to assign trigger map 
	* @date 26-06-2023
	* @author Arjun Singh  
	**/
	public ASDAC_CaseHandler() {
        this.oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
        this.lstNewCase = (List<Case>) Trigger.new;
		this.lstOldCase = (List<Case>) Trigger.old;
		if (!ASDAC_ContactCentreSetting__c.getInstance().DisableContactCentre__c) {
			this.contactCenterEnable = true;
		}
    }
	/**
	* @description override method for before insert 
	* @date 26-06-2023
	* @author Arjun Singh  
	**/
	public override void beforeInsert() {
		this.execute('beforeInsert');		
	}
	/**
	* @description override method for before update 
	* @date 26-06-2023
	* @author Arjun Singh  
	**/
	public override void beforeUpdate() {
		this.execute('beforeUpdate');		
	}
	/**
	* @description override method for before delete 
	* @date 26-06-2023
	* @author Arjun Singh  
	**/
	public override void beforeDelete() {
		this.execute('beforeDelete');			
	}
	/**
	* @description override method for after insert 
	* @date 26-06-2023
	* @author Arjun Singh  
	**/
	public override void afterInsert() {
		this.execute('afterInsert');
	}
    
    public override void afterUpdate() {
	 	this.execute('afterUpdate');
	}
	
	/**
	* @description execute actual trigger context
	* @date 26-06-2023
	* @author Arjun Singh  
	**/
	private void execute(String type) {
		if(!this.contactCenterEnable) {
			return;
		}
		try {
			switch on type {
				when 'beforeInsert' {
					populateEntitlementOnCase(this.lstNewCase, null);
					populateWorkQueueAndStatus(this.lstNewCase, null);
					populateOrderDetails(this.lstNewCase);
					validateComments(this.lstNewCase, null);
				}
				when 'beforeUpdate' {
					populateEntitlementOnCase(this.lstNewCase,  this.oldCaseMap);
					populateWorkQueueAndStatus(this.lstNewCase, this.oldCaseMap);
					validateComments(this.lstNewCase, this.oldCaseMap);
				}
				when 'beforeDelete' {
					preventDeletion(this.lstOldCase);
				}
        when 'afterUpdate' {
					caseOwnerInactive(this.lstNewCase);
				}
				when else {
					//default case 
					System.debug('no event initiated the trigger');
				}
			}
		} catch (Exception ex) {
			ASDAC_Logger.logException(ex);
			ASDAC_Logger.writeLogsToDatabase();
		}
	}

  
  /***************************************************************************
	@author        Sapient: Disharee Ray
	@date          9th September 2024
	@param         List<Case> listOfOldCases
	@return        void
	@description   This method will prevent the case record deletion if the case lies within its retention period
	****************************************************************************/
  private static void preventDeletion(List<Case> listOfOldCases) {
      Map<String, ASDAC_CaseRetentionPeriodMapping__mdt> caseRetentionMetadataMap = new Map<String, ASDAC_CaseRetentionPeriodMapping__mdt>();
      for(ASDAC_CaseRetentionPeriodMapping__mdt rec:ASDAC_CaseRetentionPeriodMapping__mdt.getAll().values()){
        List<String> metadataDetails = new List<String>();
        metadataDetails.add(rec.RecordType__c.toUpperCase());
        metadataDetails.add(rec.ContactReason1__c.toUpperCase());
        if (String.isNotBlank(rec.ASDAC_CaseUnderAge__c)) {
            metadataDetails.add(rec.ASDAC_CaseUnderAge__c.toUpperCase());
        }
        String metadataKey= String.join(metadataDetails,'-');
        caseRetentionMetadataMap.put(metadataKey, rec);   
      }
    for (Case cse : listOfOldCases) {
      String recordTypeDevName = Schema.SObjectType.Case.getRecordTypeInfosById().get(cse.RecordTypeId).getName();
      List<String> caseDetailsKey = new List<String>();
        caseDetailsKey.add(recordTypeDevName.toUpperCase());
        caseDetailsKey.add(cse.ContactReasonLevel1__c.toUpperCase());
        if(String.isNotBlank(cse.Case_under_age__c)) {
            caseDetailsKey.add(cse.Case_under_age__c.toUpperCase());
        }
      String csFieldsKey= String.join(caseDetailsKey,'-');
        if(caseRetentionMetadataMap.containsKey(csFieldsKey) && caseRetentionMetadataMap.get(csFieldsKey).ASDAC_RetentionPeriod__c!=null &&
           cse.ASDAC_CaseAgeInYears__c<caseRetentionMetadataMap.get(csFieldsKey).ASDAC_RetentionPeriod__c){
             cse.addError(Label.ASDAC_CaseDeletionError);
        }   
    }
  }

    public static void populateOrderDetails(List<Case> listOfNewCases) {
        try{
    for (Case newCase : listOfNewCases) {
      if (String.isNotEmpty(newCase.WebToCase__c)) {
        WebToCaseWrapper wrapper = (WebToCaseWrapper) JSON.deserialize(newCase.WebToCase__c, WebToCaseWrapper.class);
                    if (wrapper.isVatRequest == true) {
                        newCase.OrderId__c = wrapper.orders[0].orderId;
                        newCase.Description = 'Order Date: '+ wrapper.orders[0].orderDate.format() + '\n' + 'Order Value: ' + wrapper.orders[0].orderTotal + '\n' + 'Is this a delivery pass order: ' + wrapper.orders[0].deliveryPassOrder;
        }
      }
    }
        } catch(Exception ex){
            ASDAC_Logger.logException(ex);
            ASDAC_Logger.writeLogsToDatabase();
        }

  }

  /***************************************************************************
	@author        Sapient: Nitish Yadav
	@date          25 July 2022
	@param         List<Case> listOfNewCases, 
				   Map<Id, Case> mapOfNewCases, 
				   Map<Id, Case> mapOfOlaCases
	@return        void
	@description   This method will populate the Entitlements on the case
	****************************************************************************/
  private static void populateEntitlementOnCase(
    List<Case> listOfNewCases,
    Map<Id, Case> mapOfOldCases
  ) {
    Map<Id, List<Case>> mapOfOwnerIdToCases = new Map<Id, List<Case>>();
    Map<String, List<Case>> mapOfQueueNameToCases = new Map<String, List<Case>>();
    for (Case newCase : listOfNewCases) {
      if (shouldProcessCase(newCase, mapOfOldCases)) {
        processCase(mapOfOwnerIdToCases, mapOfQueueNameToCases, newCase);
      }
    }

    if (!mapOfOwnerIdToCases.isEmpty() || !mapOfQueueNameToCases.isEmpty()) {
      findEntitlementsAndMapToCases(mapOfOwnerIdToCases, mapOfQueueNameToCases);
    }
  }

  private static Boolean shouldProcessCase(Case newCase, Map<Id, Case> mapOfOldCases) {
    if ((Trigger.isInsert ||
      (Trigger.isUpdate &&
      ((newCase.OwnerId != mapOfOldCases.get(newCase.Id).OwnerId) ||
      (newCase.WorkQueue__c !=
      mapOfOldCases.get(newCase.Id).WorkQueue__c))) &&
      (String.valueOf(newCase.OwnerId).startsWith('00G') ||
      String.isNotBlank(newCase.WorkQueue__c)))) {
      return true;
    }
    return false;
  }

  private static void processCase(Map<Id, List<Case>> mapOfOwnerIdToCases, Map<String, List<Case>> mapOfQueueNameToCases, Case newCase) {
    if (String.valueOf(newCase.OwnerId).startsWith('00G')) {
      if (!mapOfOwnerIdToCases.containsKey(newCase.OwnerId)) {
        mapOfOwnerIdToCases.put(newCase.OwnerId, new List<Case>());
      }
      // creating map of queueId as key and list of related cases
      mapOfOwnerIdToCases.get(newCase.OwnerId).add(newCase);
    } else if (
      String.isNotBlank(newCase.WorkQueue__c) &&
      String.valueOf(newCase.OwnerId).startsWith('005')
    ) {
      if (!mapOfOwnerIdToCases.containsKey(newCase.OwnerId)) {
        mapOfQueueNameToCases.put(newCase.WorkQueue__c, new List<Case>());
      }
      mapOfQueueNameToCases.get(newCase.WorkQueue__c).add(newCase);
    }
  }

  /***************************************************************************
	@author        Sapient: Nitish Yadav
	@date          25 July 2022
	@param         Map<Id, List<Case>> mapOfOwnerIdToCases
	@return        void
	@description   This method will query on Entitlement object with filter
				   as Case.Owner(Queue).DeveloperName and map on case.
	****************************************************************************/
  private static void findEntitlementsAndMapToCases(
    Map<Id, List<Case>> mapOfOwnerIdToCases, Map<String, List<Case>> mapOfQueueNameToCases
  ) {
    Map<String, List<Case>> mapOfQueueDevNameToCases = new Map<String, List<Case>>();
    for (Group queue : [
      SELECT Id, DeveloperName, Name
      FROM Group
      WHERE Id IN :mapOfOwnerIdToCases.keyset() OR Name IN :mapOfQueueNameToCases.keySet()
    ]) {
      List<Case> cases = new List<Case>();
      if(mapOfOwnerIdToCases.containsKey(queue.Id)){
        cases.addAll(mapOfOwnerIdToCases.get(queue.Id));
      }
      if(mapOfQueueNameToCases.containsKey(queue.Name)){
        cases.addAll(mapOfQueueNameToCases.get(queue.Name));
      }
      if (!mapOfQueueDevNameToCases.containsKey(queue.DeveloperName)) {
        mapOfQueueDevNameToCases.put(queue.DeveloperName, new List<Case>());
      }
      //Creating map of Queue Developer Name as key since and list of related cases -
      //Since the metadata record Developer name is same as Queue Developer name.
      mapOfQueueDevNameToCases.get(queue.DeveloperName).addAll(cases);
    }
    getMetadataMappings(mapOfQueueDevNameToCases);
  }

  /***************************************************************************
	@author        Sapient: Nitish
	@date          25 July 2022
	@param         Map<String, List<Case>> mapOfQueueDevNameToCases
	@return        void
	@description   This method will query the related Mdt record to get the
				   entitlement and Business Hours name that needs to be mapped
	****************************************************************************/
  private static void getMetadataMappings(
    Map<String, List<Case>> mapOfQueueDevNameToCases
  ) {
    Map<String, ASDAC_QueueSLAMapping__mdt> mapOfQueueDevNameToMdtMapping = new Map<String, ASDAC_QueueSLAMapping__mdt>();
    Map<String, Set<String>> mapOfSetNamesToSetOfENAndBHN = new Map<String, Set<String>>(); //map of Set Names to Sets Of -
    // Entitlement Names and
    // Business Hours Names
    Set<String> setOfBusinessHoursName = new Set<String>();
    Set<String> setOfEntitlementName = new Set<String>();

    /* querying on metadata records*/
    for (ASDAC_QueueSLAMapping__mdt queueSLAmapping : [
      SELECT Id, EntitlementName__c, BusinessHourName__c, DeveloperName
      FROM ASDAC_QueueSLAMapping__mdt
      WHERE DeveloperName IN :mapOfQueueDevNameToCases.keyset()
    ]) {
      //populating Entitlement record name
      if (String.isNotBlank(queueSLAmapping.EntitlementName__c)) {
        setOfEntitlementName.add(queueSLAmapping.EntitlementName__c);
      }

      //populating Business hour name
      if (String.isNotBlank(queueSLAmapping.BusinessHourName__c)) {
        setOfBusinessHoursName.add(queueSLAmapping.BusinessHourName__c);
      }
      // creating map with key as Queue/Mdt developer name and related Mdt record
      mapOfQueueDevNameToMdtMapping.put(
        queueSLAmapping.DeveloperName,
        queueSLAmapping
      );
    }
    mapOfSetNamesToSetOfENAndBHN.put(
      'setOfEntitlementName',
      setOfEntitlementName
    );
    mapOfSetNamesToSetOfENAndBHN.put(
      'setOfBusinessHoursName',
      setOfBusinessHoursName
    );
    mapEntitlementsAndBusinessHours(
      mapOfQueueDevNameToCases,
      mapOfQueueDevNameToMdtMapping,
      mapOfSetNamesToSetOfENAndBHN
    );
  }

  /***************************************************************************
	@author        Sapient: Nitish
	@date          25 July 2022
	@param         Map<String, List<Case>> mapOfQueueDevNameToCases, 
				   Map<String, ASDAC_QueueSLAMapping__mdt> mapOfQueueDevNameToMdtMapping, 
				   Set<String> setOfBusinessHoursName, 
				   Set<String> setOfEntitlementName
	@return        void
	@description   This method will map the related Entitlement and Business-
				   hours record to the case.
	****************************************************************************/
  private static void mapEntitlementsAndBusinessHours(
    Map<String, List<Case>> mapOfQueueDevNameToCases,
    Map<String, ASDAC_QueueSLAMapping__mdt> mapOfQueueDevNameToMdtMapping,
    Map<String, Set<String>> mapOfSetNamesToSetOfENAndBHN
  ) {
    Map<String, String> mapOfEntToEntId = new Map<String, String>();
    Map<String, String> mapOfBHNameToBHId = new Map<String, String>();
    Set<String> setOfBusinessHoursName = mapOfSetNamesToSetOfENAndBHN.get(
      'setOfBusinessHoursName'
    );
    Set<String> setOfEntitlementName = mapOfSetNamesToSetOfENAndBHN.get(
      'setOfEntitlementName'
    );
    List<Entitlement> listOfEntitlement = ASDAC_WithoutSharingUtility.getEntitlements(
      setOfEntitlementName
    );
    // querying on Entitlement record
    for (SObject sObj : listOfEntitlement) {
      Entitlement entitlemnt = (Entitlement) sObj;
      mapOfEntToEntId.put(entitlemnt.Name, entitlemnt.Id);
    }

    /* querying on Business hour record*/

    for (BusinessHours bsnsHrs : [
      SELECT Id, Name
      FROM BusinessHours
      WHERE Name IN :setOfBusinessHoursName
    ]) {
      mapOfBHNameToBHId.put(bsnsHrs.Name, bsnsHrs.Id);
    }

    //mapping Business Hour and Entitlement on Case
    for (String queueDevName : mapOfQueueDevNameToMdtMapping.keyset()) {
      for (Case cse : mapOfQueueDevNameToCases.get(queueDevName)) {
        cse.EntitlementId = mapOfEntToEntId.containsKey(
            mapOfQueueDevNameToMdtMapping.get(queueDevName).EntitlementName__c
          )
          ? mapOfEntToEntId.get(
              mapOfQueueDevNameToMdtMapping.get(queueDevName).EntitlementName__c
            )
          : null;
        cse.BusinessHoursId = mapOfBHNameToBHId.containsKey(
            mapOfQueueDevNameToMdtMapping.get(queueDevName).BusinessHourName__c
          )
          ? mapOfBHNameToBHId.get(
              mapOfQueueDevNameToMdtMapping.get(queueDevName)
                .BusinessHourName__c
            )
          : null;
      }
    }
  }

  /***************************************************************************
	@author        Sapient: Vineeth
	@date          24 August 2022
	@param listOfNewCases list of new Cases 
	@param mapOfOldCases map of old Cases
	@description   This method will populate the WorkQueue and Status on the case
	****************************************************************************/
  private static void populateWorkQueueAndStatus(List<Case> listOfNewCases, Map<Id, Case> mapOfOldCases) {
    	Boolean isNew = (mapOfOldCases == null);
    	Map<Id, List<Case>> mapOfQueueToCase = new Map<Id, List<Case>>();
		  populateWorkQueueAndStatusForManualRefundCases(listOfNewCases, mapOfOldCases);
    	for(Case caseObject : listOfNewCases) {
        if(ASDAC_GlobalConstants.STRING_STATUS_CLOSED.equalsIgnoreCase(caseObject.Status) || 
            (!isNew && (mapOfOldCases.get(caseObject.Id).OwnerId == caseObject.OwnerId))) {
            continue;
        }
        //When a new case is being inserted with Internal Comments, -
        //Due to Status change in before insert, the Case Comment was not getting inserted
        if(!isNew) {
          caseObject.Status = String.valueOf(caseObject.OwnerId).startsWith('00G') ? ASDAC_GlobalConstants.STRING_STATUS_AVAILABLE
                                                                                   : ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED; 
        }
        if (String.valueOf(caseObject.OwnerId).startsWith('00G')) {
          addCaseToMap(mapOfQueueToCase, caseObject.OwnerId, caseObject);
        }
    	}
      if (mapOfQueueToCase.keySet().size() == 0) {
        return;
      }
      populateWorkQueue(mapOfQueueToCase);
  }

  /***************************************************************************
	@author        TCS: Fayyas T
	@date          16 Jan 2025
	@param listOfNewCases list of new Cases 
	@description   This method will populate the workqueue and status on Manual Refund Case record.
	****************************************************************************/
  private static void populateWorkQueueAndStatusForManualRefundCases(List<Case> listOfNewCases, Map<Id, Case> mapOfOldCases) {
    if (listOfNewCases != null && !listOfNewCases.isEmpty()) {
      Map<String, Id> queueIdMap = fetchQueueIdMap();
      if (!queueIdMap.isEmpty()){
        Boolean isNew = (mapOfOldCases == null);
        for (Case caseObject : listOfNewCases) {
          if (isManualRefundProcessed(caseObject, mapOfOldCases, isNew)) {
            updateCaseStatusAndQueue(caseObject, queueIdMap);
          }
        }
      } else {
        System.debug(LoggingLevel.ERROR, 'Unexpected refund queues: ' + JSON.serialize(queueIdMap));
      }     
    }
  }

  private static Map<String, Id> fetchQueueIdMap() {
    List<String> queueNameList = new List<String>{
      System.Label.ASDAC_APIManualRefundQueue,
      System.Label.ASDAC_APIManualRefundPendingQueue,
      System.Label.ASDAC_APIManualRefundFailureQueue
    };
    List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :queueNameList];
    Map<String, Id> queueIdMap = new Map<String, Id>();
    if (queueList != null && !queueList.isEmpty()) {
      for (Group queueObject : queueList) {
        queueIdMap.put(queueObject.Name, queueObject.Id);
      }
    } else {
      System.debug(LoggingLevel.ERROR, 'Unexpected refund queues: ' + JSON.serialize(queueList));
    }
    return queueIdMap;
  }
  
  private static Boolean isManualRefundProcessed(Case caseObject, Map<Id, Case> mapOfOldCases, Boolean isNew) {
    return (caseObject.ContactReasonLevel2__c == 'Manual Refund Processed' && caseObject.Subject == 'Manual Payout') &&
            ((!isNew && mapOfOldCases.get(caseObject.Id)?.PayoutStatus__c != caseObject.PayoutStatus__c) || isNew);
  }
  
  private static void updateCaseStatusAndQueue(Case caseObject, Map<String, Id> queueIdMap) {
    String payoutStatus = caseObject.PayoutStatus__c;
    if (System.Label.ASDAC_PayoutStatusSuccess.contains(payoutStatus)) {
      updateCaseFields(caseObject, System.Label.ASDAC_APIManualRefundQueue, ASDAC_GlobalConstants.STRING_STATUS_CLOSED, 'Resolved', queueIdMap.get(System.Label.ASDAC_APIManualRefundQueue));
    } else if (System.Label.ASDAC_PayoutStatusPending.contains(payoutStatus)) {
      updateCaseFields(caseObject, System.Label.ASDAC_APIManualRefundPendingQueue, ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, null, queueIdMap.get(System.Label.ASDAC_APIManualRefundPendingQueue));
    } else if (System.Label.ASDAC_PayoutStatusFailure.contains(payoutStatus)) {
      updateCaseFields(caseObject, System.Label.ASDAC_APIManualRefundFailureQueue, ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, null, queueIdMap.get(System.Label.ASDAC_APIManualRefundFailureQueue));
    }
  }
  
  private static void updateCaseFields(Case caseObject, String workQueue, String status, String caseClosedReason, Id ownerId) {
    caseObject.WorkQueue__c = workQueue;
    caseObject.Status = status;
    caseObject.CaseClosedReason__c = caseClosedReason;
    caseObject.OwnerId = ownerId;
  }

  /***************************************************************************
	@author        Sapient: Nitish
	@date          12 Jan 2023
	@param listOfNewCases list of new Cases 
	@description   This method will populate the worqueue on Case record .
	****************************************************************************/
  private static void populateWorkQueue(Map<Id, List<Case>> mapOfQueueToCase) {
    List<Group> listOfQueues = [SELECT Name FROM Group WHERE Id IN :mapOfQueueToCase.keySet() WITH SECURITY_ENFORCED];
    for (Group queue : listOfQueues) {
      for (Case caseObject : mapOfQueueToCase.get(queue.Id)) {
        caseObject.WorkQueue__c = queue.Name;
      }
    }
  }
	
  
  /***************************************************************************
	@author        Sapient: Vineeth
	@date          25 August 2022
	@param mapOfIdToCaseList map of Id to list of Cases
	@param key key for the map
	@param caseObject case object
	@description   This method will add the case to list of at the specified key
	****************************************************************************/
  private static void addCaseToMap(
    Map<Id, List<Case>> mapOfIdToCaseList,
    Id key,
    Case caseObject
  ) {
    if (!mapOfIdToCaseList.containsKey(key)) {
      mapOfIdToCaseList.put(key, new List<Case>());
    }
    mapOfIdToCaseList.get(key).add(caseObject);
  }

 /***************************************************************************
	@author        Sapient: Sri Abhinaya
	@date          31 March 2023
	@param         List<Case> listOfNewCases, 
				         Map<Id, Case> mapOfOldCases
	@return        void
	@description   This method is to validate that comments are added when valie is greater than 5 euro or 1500 pence
	****************************************************************************/
  private static void validateComments(List<Case> listOfNewCases, Map<Id, Case> mapOfOldCases){
    Boolean isNew = (mapOfOldCases == null);
    for (Case newCase : listOfNewCases){
      if((isNew || (mapOfOldCases.get(newCase.Id).Value__c != newCase.Value__c))&&(newCase.Value__c > 1500 && String.isBlank(newCase.Comments))&& (newCase.GoodwillType__c != 'Evoucher')){ 
          newCase.Comments.addError(System.Label.ASDAC_CommentsValidation); 
      }
    }
  }

  /**********************************************************************************
   * @author                       : Vineeth Rangamgari
   * @date                         : 2022-12-15
   * @description                  : wrapper class for Web to Case data
   **********************************************************************************/
  public class WebToCaseWrapper {
    @AuraEnabled
    public Boolean isVatRequest { get; set; }
    @AuraEnabled
    public List<WebToCaseOrderWrapper> orders { get; set; }
  }
  public class WebToCaseOrderWrapper {
    @AuraEnabled
    public String orderId { get; set; }
    @AuraEnabled
    public Date orderDate { get; set; }
    @AuraEnabled
    public Decimal orderTotal { get; set; }
    @AuraEnabled
    public String deliveryPassOrder { get; set; }

  }
 
/****************
CaseOwnerInactive

*********************/
public static void caseOwnerInactive ( List<Case> listOfNewCases) {
  //List<Case> listOfCasesToUpdate = new List<Case>();
  //List<Case> caseRecord = new List<Case>();
//trigger CaseOwnerInactiveCheck on Case (before update) {
 
  Set<Id> ownerIds = new Set<Id>();
  
  // Collect the OwnerIds from the cases being updated
  for (Case caseRecord : listOfNewCases) {
      ownerIds.add(caseRecord.OwnerId);
  }
  
  // Query for the User records to check their active status
  Map<Id, User> userMap = new Map<Id, User>([SELECT Id, IsActive FROM User WHERE Id IN :ownerIds]);
  
  for (Case caseRecord : listOfNewCases) {
      User userRecord = userMap.get(caseRecord.OwnerId);
      if (userRecord!= null && !userRecord.IsActive)
          caseRecord.addError(System.Label.ASDAC_CaseOwnerIsInactive);
      }
  }
}