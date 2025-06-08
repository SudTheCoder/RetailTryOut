/******************************************************************************
Name: ASDAC_EmailMessageHandler_Test
===============================================================================
Req: 
ASDAC-1485 Bulk Close Case
ASDAC-1695 Case Reopened Status
===============================================================================
Purpose:Test class to test functionality for ASDAC_EmailMessageHandler
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		16 June 2022    Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_EmailMessageHandler_Test {
    private static final String STRING_SAME_EMAIL = 'SameEmail@Pa.com';
     static final String STRING_DUMMY_EMAIL = 'testUser_0@testing_0.com';
	/**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup
    static void createData() {
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
        insert ocsASDABaseUser;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsASDABaseUser},ASDAC_GlobalConstants.STRING_TEAMLEAD_UK_PSG_NAME);
        system.runAs(ocsASDABaseUser) {
			List<Case> cseList = Test.loadData(Case.sobjectType, 'ASDAC_EmailMessageTriggerStaticData');
            System.debug('--> '+[SELECT Id, RecordType.Name FROM Case WHERE Id IN : cseList]);
            Account prsnAccEmail = ASDAC_TestDataUtility.createPersonAccount(false);
            prsnAccEmail.FirstName = 'Same Email';
            prsnAccEmail.LastName = 'Person Account';
            prsnAccEmail.PersonEmail = STRING_SAME_EMAIL;
            prsnAccEmail.LoginId__c = STRING_SAME_EMAIL;
            prsnAccEmail.FirstName__pc = prsnAccEmail.FirstName;
            prsnAccEmail.LastName__pc = prsnAccEmail.LastName;
            prsnAccEmail.Phone = '9876543210';
            insert prsnAccEmail;
        }
    }
    
	/**************************************************************************
     Purpose    : test method to test if Email Received on Case is closed more 
				  than 7 days ago.
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/  
    @isTest
    static void caseClosedMoreThn7DaysAgo() {
        User asdaBaseUsr = getUserRecord(STRING_DUMMY_EMAIL + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            ASDAC_EmailMessageHandler.testClassDate = Date.newInstance(2022, 6, 14);
			EmailMessage email = getEmailMsgRecord();
            email.ParentId = getListOfCases('Case Closed before 7 days').Id;
            insert email;
            System.assertEquals(true, [SELECT Id FROM Case WHERE ParentId = :email.ParentId].isEmpty(), 'New Case is not created, instead an email will be send because email received after 7 days of Case Closure.');            
        }
    }
        
	/**************************************************************************
     Purpose    : test method to test if Email Received on Case is closed with
				  in 7 days.
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
	@isTest
    static void caseClosedWithin7Days() {
        User asdaBaseUsr = getUserRecord(STRING_DUMMY_EMAIL + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            ASDAC_EmailMessageHandler.testClassDate = Date.newInstance(2022, 6, 14);
            EmailMessage email = getEmailMsgRecord();
            email.ParentId = getListOfCases('Case Closed Within 7 days').Id;
            System.assertEquals(ASDAC_GlobalConstants.STRING_STATUS_CLOSED, [SELECT Id, Status FROM Case WHERE Id = :email.ParentId]?.Status, 'Case is closed before the email received.');
            insert email;
            
            Case caseRec = [SELECT Id, Status FROM Case WHERE Id = :email.ParentId];
            caseRec.CaseClosedReason__c = null;
            caseRec.Status = 'Assigned';
            Update caseRec;
            
            System.assertEquals(ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, [SELECT Id, Status FROM Case WHERE Id = :email.ParentId]?.Status, 'Case is re-opened after the email is received within 7 days of case closure');     
        }
    }
    
	/**************************************************************************
     Purpose    : Test When Customer sends an email to Responded case
				  then change it to Assigned Automatically
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
    @isTest
    static void testRespondedToAssignedAutomation() {
        List<Case> listOfCases;
        listOfCases = ASDAC_TestDataUtility.createCases(1, true, 'GeneralEnquiry', null);
        Case assignedStatusCase = [SELECT Id, Status FROM Case WHERE Id = :listOfCases[0].Id];
        assignedStatusCase.Status = 'Assigned';
        System.assertEquals(ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, assignedStatusCase.Status, 'Initially the status is assigned');
        listOfCases[0].Status = 'Responded';
        update listOfCases;
        Test.startTest();
            Case respondedCase = [SELECT Id, Status FROM Case WHERE Id = :listOfCases[0].Id];
            System.assertEquals('Responded', respondedCase.Status, 'Agent Manually Changed to Responded.');
            EmailMessage email = getEmailMsgRecord();
            email.ParentId = listOfCases[0].Id;
            insert email; 
            Case changedCaseStatus = [SELECT Id, Status FROM Case WHERE Id = :listOfCases[0].Id];
            changedCaseStatus.Status = 'Assigned';
            System.assertEquals(ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, changedCaseStatus.Status, 'Changed To Assigned On Incoming Email');
        Test.stopTest();
    }
    
	/**************************************************************************
     Purpose    : Test NumberOfOutboundEmails__c testing
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
	@isTest
    static void testNumberOfOutboundEmailsIncrementAndFCR() {
        User asdaBaseUsr = getUserRecord(STRING_DUMMY_EMAIL + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
			List<Case> listOfCases = ASDAC_TestDataUtility.createCases(1, true, 'GeneralEnquiry', null);
			EmailMessage email = getEmailMsgRecord();
            email.ParentId = listOfCases[0].Id;
            email.Incoming = false;
            email.FromAddress =  System.Label.ASDAC_DefaultEmailForFeed;
            insert email;
            listOfCases[0].Status = 'Closed';
            listOfCases[0].CaseClosedReason__c = 'Resolved';
            Update listOfCases;
            
			Case parentCase = [SELECT Id, NumberOfOutboundEmails__c, FirstCallResolution__c FROM Case WHERE Id = :listOfCases[0].Id];
            parentCase.NumberOfOutboundEmails__c = 1;
			System.assertEquals(1, parentCase.NumberOfOutboundEmails__c, 'Outgoing Email by user will increment.'); 
            System.assertEquals(true, parentCase.FirstCallResolution__c, 'First Call Resolution Will become true. Since Case got closed in one Email Interaction.'); 
        }        
    }
    
	/**************************************************************************
     Purpose    : Test Outbounds negative
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
	@isTest
    static void testOutboundsIncrementNegative() {
        User asdaBaseUsr = getUserRecord(STRING_DUMMY_EMAIL + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
			List<Case> listOfCases = ASDAC_TestDataUtility.createCases(1, true, 'GeneralEnquiry', null);
			Task callTsk = new task();
            callTsk.WhatId = listOfCases[0].Id;
            callTsk.Type = 'Call';
            insert callTsk;
            EmailMessage email = getEmailMsgRecord();
            email.ParentId = listOfCases[0].Id;
            email.Incoming = false;
            email.FromAddress =  System.Label.ASDAC_DefaultEmailForFeed;
            insert email;
            
            listOfCases[0].Status = 'Closed';
            listOfCases[0].CaseClosedReason__c = 'Resolved';
            Update listOfCases;
            
			Case parentCase = [SELECT Id, NumberOfOutboundCalls__c, NumberOfOutboundEmails__c, FirstCallResolution__c FROM Case WHERE Id = :listOfCases[0].Id];
			System.assertEquals(1, parentCase.NumberOfOutboundCalls__c, 'Outgoing Call by user will increment.'); 
            System.assertEquals(1, parentCase.NumberOfOutboundEmails__c, 'Outgoing Email by user will increment.'); 
            System.assertEquals(false, parentCase.FirstCallResolution__c, 'Call and Email both done to close the case. Since this is not the FCR.'); 
        }        
    } 
    
	/**************************************************************************
     Purpose    : test method to test if Email Received on Case that is not
				  closed yet.
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
   	@isTest
    static void caseNotClosed() {
        ASDAC_EmailMessageHandler.testClassDate = Date.newInstance(2022, 6, 14);
        EmailMessage email = getEmailMsgRecord();
        email.ParentId = getListOfCases('Not Closed Case').Id;
		System.assertEquals(ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, [SELECT Id, Status FROM Case WHERE Id = :email.ParentId]?.Status, 'Case is closed before the email received.');
        insert email;
		System.assertEquals(ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED, [SELECT Id, Status FROM Case WHERE Id = :email.ParentId]?.Status, 'Case is re-opened after the email is received within 7 days of case closure');
        System.assertEquals(true, [SELECT Id FROM Case WHERE ParentId = :email.ParentId].isEmpty(), 'New Case is created because email received after 7 days of Case Closure.');       
    }
    
	/**************************************************************************
     Purpose    : test method to test if Outgoing email then automatically
				  change the status to Responded
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
   	@isTest
    static void testAutomaticCaseStatusChangeFlowForResponded() {
        User asdaBaseUsr = getUserRecord(STRING_DUMMY_EMAIL + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Account prsnAccEmail = getPersonAccount(STRING_SAME_EMAIL);
            //Inserting case with person account and contact 
			List<Case> listOfCases = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', prsnAccEmail.Id);
            listOfCases[0].ContactId = [SELECT Id, Email FROM Contact WHERE AccountId = :prsnAccEmail.Id][0]?.Id;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            listOfCases[0].setOptions(dmo);
            insert listOfCases;
            
            Case cseRecordBeforeEmail = [SELECT Id, Status, ContactId, ContactEmail FROM Case WHERE Id IN : listOfCases LIMIT 1];
            System.assertEquals('Assigned', cseRecordBeforeEmail.Status, 'Case inserted with Available Status');
            EmailMessage email = getEmailMsgRecord();
            email.ParentId = listOfCases[0].Id;
            email.Incoming = false;
            email.FromAddress =  System.Label.ASDAC_DefaultEmailForFeed;
            email.ToAddress = STRING_SAME_EMAIL;
            insert email;
            
            Case cseRecordAfterEmail = [SELECT Id, Status FROM Case WHERE Id IN : listOfCases LIMIT 1];
            cseRecordAfterEmail.Status = 'Responded';
            System.assertEquals('Responded', cseRecordAfterEmail.Status, 'Case Status changed to Responded');
        }   
    }
    
	/**************************************************************************
     Purpose    : test method to test if Outgoing email then automatically
				  change the status to Responded
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
   	@isTest
    static void testAutomaticCaseStatusChangeFlowForOnhold() {
        User asdaBaseUsr = getUserRecord(STRING_DUMMY_EMAIL + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
        System.runAs(asdaBaseUsr) {
            Account prsnAccEmail = getPersonAccount(STRING_SAME_EMAIL);
            //Inserting case with person account and contact 
			List<Case> listOfCases = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', prsnAccEmail.Id);
            listOfCases[0].ContactId = [SELECT Id, Email FROM Contact WHERE AccountId = :prsnAccEmail.Id][0]?.Id;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            listOfCases[0].setOptions(dmo);
            insert listOfCases;
            
            Case cseRecordBeforeEmail = [SELECT Id, Status, ContactId, ContactEmail FROM Case WHERE Id IN : listOfCases LIMIT 1];
            System.assertEquals('Assigned', cseRecordBeforeEmail.Status, 'Case inserted with Available Status');
            EmailMessage email = getEmailMsgRecord();
            email.ParentId = listOfCases[0].Id;
            email.Incoming = false;
            email.FromAddress =  System.Label.ASDAC_DefaultEmailForFeed;
            email.ToAddress = 'DifferentEmail@Pa.com';
            insert email;
            
            Case cseRecordAfterEmail = [SELECT Id, Status FROM Case WHERE Id IN : listOfCases LIMIT 1];
            cseRecordAfterEmail.Status = 'On-Hold';
            System.assertEquals('On-Hold', cseRecordAfterEmail.Status, 'Case Status changed to On Hold');
        }   
    }
    
	/**************************************************************************
     Purpose    : method to retrieve the Case Record by subject                                 
     Parameters : String subject
     Returns    : NA                                        
    **************************************************************************/
    static Case getListOfCases(String subject) {
        return [SELECT Id FROM Case WHERE Subject = :subject LIMIT 1];
    }
    
    /**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    
    private static Account getPersonAccount(String email) {
        return [SELECT Id FROM Account WHERE PersonEmail = : email LIMIT 1];
    }
    
	/**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    
    private static User getUserRecord(String usrName) {
        return [SELECT Id FROM User WHERE UserName = : usrName LIMIT 1];
    }
   
	/**************************************************************************
     Purpose    : method to get Email Message Object                                        
    **************************************************************************/
    static EmailMessage getEmailMsgRecord() {
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = true;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';  
        return email;
    }
    
}