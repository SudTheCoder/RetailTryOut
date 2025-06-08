/******************************************************************************
Name: ASDAC_EmailMessageHandler
===============================================================================
Req: 
ASDAC-1485 Bulk Close Cases
ASDAC-1695 Case Reopened Status
===============================================================================
Purpose:Handler class for Email Message Trigger
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE            DETAIL
1.0       Nitish Yadav          16 June 2022    Initial Development
2.0       Disharee Ray          27 June 2023    ASDAC-13132 Changed Trigger Framework 
******************************************************************************/
public with sharing class ASDAC_EmailMessageHandler extends ASDAC_TriggerFramworkService {
    
    @TestVisible private static Date testClassDate;
    private List<EmailMessage> lstNewEmailMessage;
    private Boolean contactCenterEnable = false;
  
/**********************************************************************************************
@author        Sapient: Disharee Ray
@date          27 June 2023
@description   This is constructor of the class.
**********************************************************************************************/    
    public ASDAC_EmailMessageHandler() {
        this.lstNewEmailMessage = (List<EmailMessage>) Trigger.new;
        if (!ASDAC_ContactCentreSetting__c.getInstance().DisableContactCentre__c) {
            this.contactCenterEnable = true;
        }
    }
    
    /**********************************************************************************************
@author        Sapient: Disharee Ray
@date          27 June 2023
@return        void
@description   This method overrides beforeInsert Trigger
**********************************************************************************************/    
    public override void beforeInsert() {
        if(!this.contactCenterEnable) {
            return;
        }
        try {    
           caseReopeningAndReassignment(lstNewEmailMessage);
        }catch(Exception ex) {
            ASDAC_Logger.logException(ex);
        }
    }
    /***************************************************************************
    @author        Sapient: Nitish Yadav
    @date          16 June 2022
    @param         List<EmailMessage> listOfNewEmailMessages
    @return        void
    @description   This method will create a new case if any email comes after 
                    7 days of case closure and in case of email comes before 7
                    days then it will reopen existing case.
    ****************************************************************************/
    private static void caseReopeningAndReassignment(List<EmailMessage> listOfNewEmailMessages) {
        Map<Id, EmailMessage> mapOfCaseIdsToEmailMessage = new Map<Id, EmailMessage>();
        Map<Id, Case> mapOfCaseIdToCase = new Map<Id, Case>();
        List<Case> listOfCasesToUpdate = new List<Case>();
        getMapOfCaseIdToEmailMessage(listOfNewEmailMessages, mapOfCaseIdsToEmailMessage);
        Date dateToConsider = Test.isRunningTest() ? testClassDate : System.now().date();

        Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address LIKE 'no-reply%' LIMIT 1].id;
        Id actionRequiredAutoResponseEmailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Action_Required_Auto_Response' LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> emailList =   new List<Messaging.SingleEmailMessage>();

        for(Case cse : [SELECT ClosedDate, ContactId, RecordTypeId, BusinessArea__c, ContactReasonLevel1__c, ContactReasonLevel2__c, ParentId, Status FROM Case WHERE Id IN : mapOfCaseIdsToEmailMessage.keyset()]) {
            if(cse.Status.equalsIgnoreCase(ASDAC_GlobalConstants.STRING_STATUS_CLOSED)) {
                ASDAC_ContactCentreSetting__c ccSetting = ASDAC_ContactCentreSetting__c.getInstance();
                Integer caseClosedThreshold = (ccSetting == null || ccSetting.CaseClosedThreshold__c == null) ? 7 : Integer.valueOf(ccSetting.CaseClosedThreshold__c);
                Boolean isCaseClosedMoreThn7DaysAgo = cse.ClosedDate.date().daysBetween(dateToConsider) > caseClosedThreshold;  
                //If email is received on Case which is closed within 7 days
                if(!isCaseClosedMoreThn7DaysAgo) {
                    //change the status of the Case back to Assigned
                    listOfCasesToUpdate.add(new Case(Id = cse.Id, Status = ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, CaseClosedReason__c = null));
                }  
                //If email is received on Case which is closed more than 7 days ago
                else { 
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { mapOfCaseIdsToEmailMessage.get(cse.Id).FromAddress });
                    email.setTemplateId(actionRequiredAutoResponseEmailTemplateId);
                    email.setTargetObjectId(cse.ContactId);
                    email.setWhatId(cse.Id);

                    // Set the Org-Wide Email Address ID
                    email.setOrgWideEmailAddressId(orgWideEmailAddressId);
                    emailList.add(email);
                }
            }
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
        linkNewCaseWithEmailMessage(mapOfCaseIdToCase, mapOfCaseIdsToEmailMessage);
        // updating the case with Status 'Assigned'
        if(!listOfCasesToUpdate.isEmpty() && Case.SobjectType.getDescribe().isUpdateable()) {
            update listOfCasesToUpdate;            
        }
    }

    /***************************************************************************
    @author        Sapient: Nitish Yadav
    @date          16 June 2022
    @param         List<EmailMessage> listOfNewEmailMessages, 
                   Map<Id, EmailMessage> mapOfCaseIdsToEmailMessage
    @return        void
    @description   This method will populate the mapOfCaseIdsToEmailMessage
                   with caseId as key and EmailMessage record as the value
    ****************************************************************************/
    private static void getMapOfCaseIdToEmailMessage(List<EmailMessage> listOfNewEmailMessages, Map<Id, EmailMessage> mapOfCaseIdsToEmailMessage) {
        for(EmailMessage emailMsg : listOfNewEmailMessages) {
            if(emailMsg.ParentId != null && emailMsg.Incoming) {
                mapOfCaseIdsToEmailMessage.put(emailMsg.ParentId, emailMsg);
            }                                               
        }
    }

    /***************************************************************************
    @author        Sapient: Nitish Yadav
    @date          16 June 2022
    @param         Map<Id, Case> mapOfCaseIdToCase, 
                   Map<Id, EmailMessage> mapOfCaseIdsToEmailMessage
    @return        void
    @description   This method will insert the new case and link it with the
                    email message record.
    ****************************************************************************/
    private static void linkNewCaseWithEmailMessage(Map<Id, Case> mapOfCaseIdToCase, Map<Id, EmailMessage> mapOfCaseIdsToEmailMessage) {
        if(!mapOfCaseIdToCase.isEmpty()) {
            // inserting a new case
            insert mapOfCaseIdToCase.values();
            //and link the email message to the newly created case.
            for(Id caseId : mapOfCaseIdToCase.keyset()) {
                mapOfCaseIdsToEmailMessage.get(caseId).ParentId = mapOfCaseIdToCase.get(caseId).Id;                                             
            }
        }
    }
}