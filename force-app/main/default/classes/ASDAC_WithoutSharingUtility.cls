/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-08-03
 * @description                  : Utility class to get data without sharing rules
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            03-August-2022  ASDAC-2217 Set up George case SLAs
 * Vineeth Rangamgari            23-August-2022  Updated the class for ASDAC-2220
 * Vineeth Rangamgari            08-Sep-2022     Removed ASDAC_Query references
 * Vineeth Rangamgari            12-October-2022 ASDAC-3542 Search Results
 * Vineeth Rangamgari            19-Dec-2022     ASDAC-6781 George Refund Webform
 * Disharee Ray                  21-March-2023   ASDAC-8796 Refund request / Chasing refund request webform - (Merge & Clone current webform)
 * Disharee Ray                  06-June-2023    ASDAC-12362 Create reusable common LWC component for injecting events in Adobe Analytics 
 * Disharee Ray                  22-Nov-2023     Refactored reOpenCase method
 * Disharee Ray                  16-April-2024   added removeDataCategoryAssignments method to overcome Delete access restrictions on Knowledge__DataCategorySelection
 ***************************************************************************************************/
public without sharing class ASDAC_WithoutSharingUtility {
  @TestVisible private static Boolean throwCustomException = false;
  
  /**
   * ****************************************************************************************************
   * @param setOfEntitlementName set of entitlement names
   * @description method to get list of entitlements
   * @return List\<Entitlement\>
   * ****************************************************************************************************
   */
  public static List<Entitlement> getEntitlements(Set<String> setOfEntitlementName) {
    List<Entitlement> entitlements = [SELECT Name FROM Entitlement WHERE Name IN :setOfEntitlementName];
    return entitlements;
  }

  /**
   * ****************************************************************************************************
   * @param listOfObjects List of objects
   * @description method to insert list of objects
   * ****************************************************************************************************
   */
  public static void insertObjects(List<SObject> listOfObjects) {
    insert listOfObjects;
  }
 
  /**
   * ****************************************************************************************************
   * @param listOfObjects List of objects
   * @description method to upsert list of objects
   * ****************************************************************************************************
   */
  public static void upsertObjects(List<SObject> listOfObjects) {
    upsert listOfObjects;
  }

  /**
   * ****************************************************************************************************
   * @param contentVersionList List of ContentVersion objects
   * @description method to insert List of ContentVersion
   * ****************************************************************************************************
   */
  public static void insertContentVersions(List<ContentVersion> contentVersionList) {
    insert contentVersionList;
  }

  /**
   * ****************************************************************************************************
   * @param emails List of email addresses of customers
   * @description method to get Customer accounts based on emails
   * @return Map of email to Account
   * ****************************************************************************************************
   */
  public static Map<String, Account> getCustomerAccount(List<String> emails) {
    Map<String, Account> emailToAccountMap = new Map<String, Account>();
    for(Account acc : [SELECT PersonContactId, PersonEmail FROM Account WHERE IsPersonAccount = TRUE AND Loginid__c IN :emails]) {
      if(!emailToAccountMap.containsKey(acc.PersonEmail)) {
        emailToAccountMap.put(acc.PersonEmail, acc);
      }
    }
    return emailToAccountMap;
  }

  /**
   * ****************************************************************************************************
   * @param topicName topic name to find attached articles
   * @param articleIdSet article Id set for filtering
   * @description method to get Topic assignments
   * @return List\<TopicAssignment\>
   * ****************************************************************************************************
   */
  public static List<TopicAssignment> getTopicAssignmentsByTopic(String topicName, Set<Id> articleIdSet) {
    List<TopicAssignment> topicAssignments = [SELECT EntityId FROM TopicAssignment WHERE Topic.Name = :topicName AND EntityId IN :articleIdSet LIMIT 5];
    return topicAssignments;
  }

  /**
   * ****************************************************************************************************
   * @param articleIdSet article Id set
   * @description method to get Topic assignments
   * @return List\<TopicAssignment\>
   * ****************************************************************************************************
   */
  public static List<TopicAssignment> getTopicAssignmentsByArticles(Set<Id> articleIdSet) {
    return [SELECT Topic.Name, EntityId FROM TopicAssignment WHERE EntityId IN :articleIdSet AND Topic.Name NOT IN ('Pinned', 'Personalized')];
  }

  /**
   * ****************************************************************************************************
   * @param recordId of case record
   * @description method to update the case record fields
   * ****************************************************************************************************
   */
  public static void reOpenCase(Id recordId) {
    try {     
      List<CaseMilestone> caseMileStonesListToBeUpdated = new List<CaseMilestone>();
      Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, Status FROM Case WHERE Id = :recordId]);
      
      if(!caseMap.isEmpty()) {
        for(Case cs : caseMap.values()) {
          cs.Status = 'Assigned';
          cs.ownerId = UserInfo.getUserId();
          cs.CaseClosedReason__c = null;
          cs.IsStopped = false;
        }
        update caseMap.values();
      }

      for(CaseMilestone cmsToUpdate : [SELECT Id, completionDate FROM CaseMilestone WHERE caseId IN :caseMap.keySet()
                                        ORDER BY LastModifiedDate]) {
        cmsToUpdate.completionDate = null;
        caseMileStonesListToBeUpdated.add(cmsToUpdate);
      }
      
      if(!caseMileStonesListToBeUpdated.isEmpty()) {
        update caseMileStonesListToBeUpdated;
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * ****************************************************************************************************
   * @param listOfContentVersions list of Content Version objects
   * @description method to create files from Flow
   * ****************************************************************************************************
   */
  @InvocableMethod(label='Create Files' description='Create Files from Flow')
  public static void insertFiles(List<List<ContentVersion>> listOfContentVersions) {
    try {
      List<ContentVersion> files = listOfContentVersions[0];
      if (files != null) {
        for (ContentVersion cv : files) {
          cv.VersionData = EncodingUtil.base64Decode(JSON.serialize(cv.VersionData).replace('"', ''));
          cv.Description = System.Label.ASDAC_AttachedFromWebformText;
        }
        insert files;
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * ****************************************************************************************************
   * @param caseObjectList List of Case objects to be updated or inserted
   * @description method to insert/update Case
   * ****************************************************************************************************
   */
  public static void upsertCase(List<Case> caseObjectList) {
    if(!caseObjectList.isEmpty()) {
      upsert caseObjectList;
    }
  }
    
  /**
   * ****************************************************************************************************
   * @description method to get ASDAC_DataLayerEventMetadata__mdt Custom Metadata records
   * @return List<ASDAC_DataLayerEventMetadata__mdt>
   * ****************************************************************************************************
   */
  @AuraEnabled
  public static List<ASDAC_DataLayerEventMetadata__mdt> getDataLayerEventMetadata() {
    try {
      if(Test.isRunningTest() && throwCustomException) {
        throw new ASDAC_ErrorHandler.CustomCalloutException();
      }
      return ASDAC_DataLayerEventMetadata__mdt.getAll().values();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * ****************************************************************************************************
   * @param idsList List of Case Ids
   * @param fields String of fields to query
   * @description method to get Cases
   * @return List<Case>
   * ****************************************************************************************************
   */
  public static List<Case> getCases(List<Id> idsList, String fields) {
    String soqlQuery = 'SELECT Id,' + fields + ' FROM Case WHERE Id IN :idsList';
    return Database.query(String.escapeSingleQuotes(soqlQuery));
  }
    
  /**
   * ****************************************************************************************************
   * @param userId Id of the User
   * @description method to get User record
   * @return List<User>
   * ****************************************************************************************************
   */
  @AuraEnabled
  public static List<User> getUser(String userId) {
    return [SELECT Id, Username, ContactId, LastName, FirstName, Email, Country, LocaleSidKey, IsActive 
            FROM User WHERE Id = :userId AND IsActive = true LIMIT 1];
  }
    
  /**
   * ****************************************************************************************************
   * @param existingDataCategoryAssignments List of Knowledge__DataCategorySelection objects to be deleted
   * @description method to delete Knowledge__DataCategorySelection since it is not accessible to any profile/permission other than System Administrator
   * ****************************************************************************************************
   */
  public static void removeDataCategoryAssignments(List<Knowledge__DataCategorySelection> existingDataCategoryAssignments) {
    if(!existingDataCategoryAssignments.isEmpty()) {
      delete existingDataCategoryAssignments;
    }
  }
}