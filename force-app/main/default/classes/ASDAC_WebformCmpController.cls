/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-06-21
 * @description                  : ASDAC-949 Enable GEORGE Webform to Case
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            21-June-2022       Created the class
 * Vineeth Rangamgari            24-June-2022       Updated the class for ASDAC-1644
 * Vineeth Rangamgari            23-August-2022     Updated the class for ASDAC-2220
 * Disharee Ray                  08-September-2022  Updated the class for ASDAC-3434
 * Vineeth Rangamgari            08-September-2022  Removed ASDAC_Query references
 * Vineeth Rangamgari            19-Dec-2022     ASDAC-6781 George Refund Webform
 ***************************************************************************************************/
public with sharing class ASDAC_WebformCmpController {
  public STATIC FINAL String GEORGE_INT_ORDER = 'George - International Orders'; 
  public STATIC FINAL String BLANK_LINE_CONST = '<br><br>';
  /**
   * ****************************************************************************************************
   * @param caseObject object of Case
   * @param files list of files to be attached to the Case
   * @description method to create Case with attachments
   * @return String
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=false)
  public static String createCase(Case caseObject, List<FileWrapper> files) {
    try {
      String webformName = caseObject.Webform__c;
	  String GENERAL_ENQUIRY ='General_Enquiry_George_Com';
      Group ownerIDGeroge =[SELECT ID FROM Group WHERE Type ='Queue' AND Name ='George - Written'];
        ID ownerIdGeorgeWritten=ownerIDGeroge.Id;
      Webform__mdt webformMetadata = getWebformMetadata(webformName);
        
	 
	  ASDAC_CaseContactReason__mdt	queueNameMdt =ASDAC_CaseContactReason__mdt.getInstance(GENERAL_ENQUIRY);
	  String queueName =queueNameMdt.QueueName__c;
      Id recordTypeId = getCaseRecordTypeId(webformMetadata.CaseRecordType__c);

      if (!UserInfo.getUserType().equalsIgnoreCase('Guest')) {
        caseObject.ContactId = null;
        caseObject.AccountId = null;
        User currentUser = [SELECT Contact.Id, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
        caseObject.ContactId = currentUser.Contact.Id;
        caseObject.AccountId = currentUser.Contact.AccountId;
      }
      if (String.isNotEmpty(caseObject.ContactId)) {
        caseObject.SuppliedEmail = null;
      } else if (String.isEmpty(caseObject.SuppliedEmail)) {
        throw new WebformException('Invalid Email');
      } else {
          matchCustomer(new List<Case>{caseObject});
      }

      caseObject.RecordTypeId = recordTypeId;
      caseObject.Origin = 'Webform';
      caseObject.BusinessArea__c = webformMetadata.BusinessArea__c;
      if (caseObject.Webform__c == GEORGE_INT_ORDER) {
        caseObject.Status = 'Closed';
        caseObject.CaseClosedReason__c = 'No Response Required';
      }
      if (caseObject.Webform__c != 'George - General Enquiry' && caseObject.Webform__c != GEORGE_INT_ORDER && caseObject.Webform__c != '') {
        caseObject.ContactReasonLevel1__c = webformMetadata.ContactReasonLevel1__c;
      }
	   if (caseObject.Webform__c == 'George - General Enquiry' || caseObject.Webform__c == 'George - Refund' && caseObject.Webform__c != '' ) {
        caseObject.WorkQueue__c = queueName;
        caseObject.OwnerId = ownerIdGeorgeWritten;
      }
	  ASDAC_WithoutSharingUtility.upsertCase(new List<Case>{caseObject});
      String caseId = caseObject.Id;

      insertFiles(files, caseId);

      if (caseObject.Webform__c == GEORGE_INT_ORDER) {
        sendEmailToGlobalETeam(caseObject);
      }

      return caseId;
    } catch (Exception e) {
      writeLogsToDatabase(e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * ****************************************************************************************************
   * @param webformName name of the webform
   * @description method to get Case record type Id based on webform name
   * @return String
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static Id getCaseRecordType(String webformName) {
    try {
      Webform__mdt webformMetadata = getWebformMetadata(webformName);
      Id recordTypeId = getCaseRecordTypeId(webformMetadata.CaseRecordType__c);
      return recordTypeId;
    } catch (Exception e) {
      writeLogsToDatabase(e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * ****************************************************************************************************
   * @param webformName name of the webform
   * @description method to get Webform Metadata
   * @return Webform__mdt
   * ****************************************************************************************************
   */
  private static Webform__mdt getWebformMetadata(String webformName) {
    Webform__mdt webformMetadata = Webform__mdt.getInstance(webformName.replaceAll('[^a-zA-Z0-9]+', '_'));

    if (webformMetadata == null) {
      throw new WebformException('Invalid Webform');
    }
    return webformMetadata;
  }

  /**
   * ****************************************************************************************************
   * @param caseRecordTypeName name of the Case record type
   * @description method to get Case record type Id
   * @return Webform__mdt
   * ****************************************************************************************************
   */
  private static Id getCaseRecordTypeId(String caseRecordTypeName) {
    //SonarQube suggestion : Use getRecordTypeInfosByDeveloperName instead of getRecordTypeInfosByName : Amey -- STARTS
    Map<String,Schema.RecordTypeInfo> rtMapByStdDevName = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
    Map<String,Schema.RecordTypeInfo> rtByDevNameMap = new map<String,Schema.RecordTypeInfo>();
    for(Schema.RecordTypeInfo rcInf : rtMapByStdDevName.values()){
        rtByDevNameMap.put(rcInf.getName(), rcInf);
    }

    if (!rtByDevNameMap.containsKey(caseRecordTypeName)) {
      throw new WebformException('Invalid Case record type');
    }
    Id recordTypeId = rtByDevNameMap.get(caseRecordTypeName).getRecordTypeId();
    //SonarQube suggestion : Use getRecordTypeInfosByDeveloperName instead of getRecordTypeInfosByName : Amey -- ENDS
    return recordTypeId;
  }

  /**
   * ****************************************************************************************************
   * @param files list of files to be attached to the Case
   * @param caseId parent case for the file
   * @description method to create instance of ContentVersion
   * ****************************************************************************************************
   */
  private static void insertFiles(List<FileWrapper> files, String caseId) {
    if (files.size() == 0) {
      return;
    }
    Id networkId = null;
    if (Test.isRunningTest()) {
      // Network Id needs to be manually populated in test
      Network helpNetwork = [SELECT Id FROM Network WHERE Name = 'Help' WITH SECURITY_ENFORCED];
      networkId = helpNetwork.Id;
    }
    List<ContentVersion> contentVersionList = new List<ContentVersion>();
    for (FileWrapper file : files) {
      contentVersionList.add(createContentVersion(file, caseId, networkId));
    }
    ASDAC_WithoutSharingUtility.insertContentVersions(contentVersionList);
  }

  /**
   * ****************************************************************************************************
   * @param file instance of FileWrapper
   * @param caseId parent case for the file
   * @param networkId networkId to be manually added while testing
   * @description method to create instance of ContentVersion
   * @return String
   * ****************************************************************************************************
   */
  private static ContentVersion createContentVersion(FileWrapper file, String caseId, Id networkId) {
    ContentVersion contentVersionObject = new ContentVersion();
    contentVersionObject.ContentLocation = 'S';
    contentVersionObject.PathOnClient = file.name;
    contentVersionObject.Title = file.name;
    contentVersionObject.VersionData = EncodingUtil.base64Decode(file.body);
    contentVersionObject.FirstPublishLocationId = caseId;
    if (networkId != null) {
      contentVersionObject.NetworkId = networkId;
    }
    return contentVersionObject;
  }

  /**
   * ****************************************************************************************************
   * @param files list of files to be attached to the Case
   * @description method to send email to the Global-E
   * ****************************************************************************************************
   */
  private static void sendEmailToGlobalETeam(Case caseObject) {
    try {
      messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
      String[] toAddresses = new List<String>{ System.Label.Global_E_Email };
      mail.setToAddresses(toAddresses);
      mail.setReplyTo(caseObject.SuppliedEmail);
      mail.setSenderDisplayName(caseObject.SuppliedName);
      mail.setSubject('Issue with customer\'s order : ' + caseObject.OrderId__c);
      mail.setBccSender(false);
      mail.setUseSignature(false);

      mail.setPlainTextBody('Brief description of the issue with customer\'s order :' + caseObject.Description);
      String body = 'Dear Team,<br> ';
      body += '<br>';
      body += 'This case has come to Asda George.com and needs to be picked up by Global-e team.<br>';
      body += 'Here is the brief description of the issue with customer\'s order : <br><br>';
      body += 'Customer\'s Name : ' + caseObject.SuppliedName + BLANK_LINE_CONST;
      body += 'Customer\'s Email Address : ' + caseObject.SuppliedEmail + BLANK_LINE_CONST;
      body += 'Customer\'s Order Number : ' + caseObject.OrderId__c + BLANK_LINE_CONST;
      body +=
        'Brief description of the issue with customer\'s order : ' +
        caseObject.Description.substringAfter('Brief description of the issue with customer\'s order:') +
        '<br>';
      mail.setHtmlBody(body);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    } catch (exception e) {
      writeLogsToDatabase(e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * ****************************************************************************************************
   * @param caseObject case object
   * @description method to match customer using email
   * ****************************************************************************************************
   */
  private static void matchCustomer(List<Case> caseObjectList) {
    List<String> caseEmailList= new List<String>();
    for(Case cs:caseObjectList){
      if(cs.SuppliedEmail!=null){
        caseEmailList.add(cs.SuppliedEmail);    
      }
    }
    Map<String,Account> emailToCustomerMap = ASDAC_WithoutSharingUtility.getCustomerAccount(caseEmailList);
    for(Case caseObject:caseObjectList){
     if(emailToCustomerMap.containsKey(caseObject.SuppliedEmail)){
       caseObject.ContactId = emailToCustomerMap.get(caseObject.SuppliedEmail).PersonContactId;  
       caseObject.AccountId = emailToCustomerMap.get(caseObject.SuppliedEmail).Id;
       caseObject.SuppliedEmail = null;
     }
    }
  }

  /**
   * ****************************************************************************************************
   * @param exceptionMessage exception message
   * @description future method to write logs to database
   * ****************************************************************************************************
   */
  @Future
  private static void writeLogsToDatabase(String exceptionMessage) {
    ASDAC_Logger.logException(exceptionMessage, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, 'ASDAC_WebformCmpController');
    ASDAC_Logger.writeLogsToDatabase();
  }

  /**********************************************************************************
   * @author                       : Vineeth Rangamgari
   * @date                         : 2022-06-21
   * @description                  : exception class for Webform
   **********************************************************************************/
  public class WebformException extends Exception {
  }

  /**********************************************************************************
   * @author                       : Vineeth Rangamgari
   * @date                         : 2022-06-21
   * @description                  : wrapper class for File
   **********************************************************************************/
  public class FileWrapper {
    /**
     * @description name of the file
     */
    @AuraEnabled
    public String name { get; set; }
    /**
     * @description type of the file
     */
    @AuraEnabled
    public String type { get; set; }
    /**
     * @description body of the file base64 encoded
     */
    @AuraEnabled
    public String body { get; set; }
  }

  /**
   * ****************************************************************************************************
   * @param caseObject case object
   * @description method to create/update case from Flow for Webforms
   * ****************************************************************************************************
   */
  @InvocableMethod(label='Upsert Webform Case' description='Upsert Webform Case from Flow')
  public static List<Case> upsertWebformCase(List<Case> caseObjectList) {
    List<Case>caseList=caseObjectList;
    matchCustomer(caseList);
    Database.DMLOptions dmlOptions = new Database.DMLOptions();
    dmlOptions.EmailHeader.triggerAutoResponseEmail = true;
    dmlOptions.AssignmentRuleHeader.useDefaultRule = true;
    for(Case cs:caseList){
     cs.setOptions(dmlOptions); 
    }
    ASDAC_WithoutSharingUtility.upsertCase(caseList);
    return caseList;
  }
}