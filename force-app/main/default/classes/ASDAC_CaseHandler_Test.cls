/*************************************************************************
Name: ASDAC_CaseHandler_Test
==========================================================================
Req: 
ASDAC-1438 Case assignment alerts
==========================================================================
Purpose: This Class will test the functionality of flows 
         ASDAC_CaseAssignmentNotification,
         ASDAC_CaseBeforeTriggerWorkQueueUpdate.     
==========================================================================
History                                                                                                                       
VERSION   AUTHOR                        DATE            DETAIL
1.0       Shivakoti SaiAbhiteja         21 June 2022    Initial Development
**************************************************************************/
@isTest
public with sharing class ASDAC_CaseHandler_Test {
    public static final String Test_USERNAME = 'testUser_0@testing_0.com'+ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
    /**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup
    public static void createData() {
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
        insert ocsASDABaseUser;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsASDABaseUser},ASDAC_GlobalConstants.STRING_TEAMLEAD_UK_PSG_NAME);
        createEntitlementData();
        system.runAs(ocsASDABaseUser) {
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true; // Adding Case Assignment Rules
            List<Case> listOfCases = ASDAC_TestDataUtility.createCases(200, false, 'GeneralEnquiry', personAccount.Id);
            for(Case cse : listOfCases) {
                cse.setOptions(dmo);                                
            }
            insert listOfCases;
        }
    }
    
    /**************************************************************************
     Purpose    : Positive test method when case assigned successfully.                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void assignmentTestAndWorkQueueSuccess() {
        User asdaBaseUsr = getUserRecord(Test_USERNAME);
        Group generalInfoQueue = getGeneralInformationRecord();
        System.runAs(asdaBaseUsr) {
            Account personAccount = getPersonAccount();
            Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('GeneralEnquiry').getRecordTypeId();
            Case newcaseObj = new Case(Origin = 'Email',
                                    RecordTypeId = recTypeId,
                                    AccountId = personAccount.Id,
                                    Subject = 'Test Case' ,
                                    Status = Label.ASDAC_DefaultCaseStatus,
                                    WorkQueue__c ='George - Written',
                                    OwnerId = generalInfoQueue.Id
                                    );
                insert newcaseObj;
            System.assertEquals(generalInfoQueue.Id, newcaseObj.OwnerId, 'Owner Will be General Enquiry before clicking Assign To Me button by Colleague Profile.');
            System.assertEquals(generalInfoQueue.Name, newcaseObj.WorkQueue__c, 'Work Queue will be the Queue Name to whome case is assigned when case is created.');
            ASDAC_AssignToMeController.assignToMe(newcaseObj.id);
            Case caseRecAfter = [SELECT Id, OwnerId, WorkQueue__c FROM Case WHERE Id = :newcaseObj.Id];
            System.assertEquals(asdaBaseUsr.Id, caseRecAfter.ownerId, 'Owner is changed after Assign To Me button is clicked by Colleague Profile.');
            System.assertEquals(generalInfoQueue.Name, caseRecAfter.WorkQueue__c, 'Work queue is also populated when owner is changed from Queue to User');
        }
    }
        
    /**************************************************************************
     Purpose    : When New Case is created with owner as Group.                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void newCaseWithOwnerAsGrp() {
        User asdaBaseUsr = getUserRecord(Test_USERNAME);
        System.runAs(asdaBaseUsr) {
            Account personAccount = getPersonAccount();
            Group generalInfoQueue = getGeneralInformationRecord();
            Case cse = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', personAccount.Id)[0];
            cse.OwnerId = generalInfoQueue.Id;
            insert cse;
            Case insertedRec = [SELECT Id, OwnerId, WorkQueue__c FROM Case WHERE Id = :cse.Id];
            System.assertEquals(generalInfoQueue.Name, insertedRec.WorkQueue__c, 'Work queue is also populated when owner is changed from Queue to User');                    
        }
    }
    
    /**************************************************************************
     Purpose    : When New CPQC Case is deleted in less thn 10 years.                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void preventDeletionOnCasePositive() {
        User asdaBaseUsr = getUserRecord(Test_USERNAME);
        System.runAs(asdaBaseUsr) {
            Account personAccount = getPersonAccount();
            Case cse = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', personAccount.Id)[0];
            cse.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId(ASDAC_GlobalConstants.OBJCASE, ASDAC_GlobalConstants.STRING_COMPLAINT);
            cse.ContactReasonLevel1__c = ASDAC_GlobalConstants.STRING_PRODUCT_QUALITY;
            cse.ContactReasonLevel2__c = 'Foreign Body';
            cse.Case_under_age__c='No';
            insert cse;
            try {
                delete cse;
            }
            catch(Exception ex) {
                System.assertEquals(true, ex.getTypeName() == 'System.DmlException', 'Cannot delete cases created within retention period.');
                System.assertEquals(true, ex.getMessage().startsWith('Delete failed.'), 'Cannot delete cases created within retention period.');                
            }
        }
    }
    
    /**************************************************************************
     Purpose    : When New Case is created with owner as Group.                                           
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void testEntitlementPositive() {
        User asdaBaseUsr = getUserRecord(Test_USERNAME);
        System.runAs(asdaBaseUsr) {
            Account personAccount = getPersonAccount();
            Group vatQueue = getVATQueueRecord();
            ASDAC_QueueSLAMapping__mdt vatRqstMdt = ASDAC_QueueSLAMapping__mdt.getInstance(vatQueue.DeveloperName);
            Case cse = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', personAccount.Id)[0];
            cse.OwnerId = vatQueue.Id;
            insert cse;
            Case insertedRec = [SELECT Id, OwnerId, Entitlement.Name, BusinessHours.Name, OrderId__c FROM Case WHERE Id = :cse.Id];
            System.assertEquals(vatRqstMdt.EntitlementName__c, insertedRec.Entitlement.Name, 'Entitlement Name is populated as per the Custom Metadata mapping record');
            System.assertEquals(vatRqstMdt.BusinessHourName__c, insertedRec.BusinessHours.Name, 'Business Hour populated as per the Custom Metadata mapping record');
        }
    }

    /**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
    
    /**************************************************************************
     Purpose    : method to retrieve the Case Record                                    
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    private static Case getCaseRecord() {
        return [SELECT Id, OwnerId, WorkQueue__c FROM Case LIMIT 1];
    }
    
    /**************************************************************************
     Purpose    : method to get GeneralInformation Queue                                   
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    private static Group getGeneralInformationRecord() {
        return [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = 'GeorgeWritten' LIMIT 1];
    }
    
    /**************************************************************************
     Purpose    : method to get VAT Requests Queue                                   
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    private static Group getVATQueueRecord() {
        return [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'VATRequests' LIMIT 1];
    }
    
    /**************************************************************************
     Purpose    : method to get Person Account                                
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
    private static Account getPersonAccount() {
        return [SELECT Id FROM Account WHERE RecordType.Name = 'Person Account' LIMIT 1];
    }
    
    /**************************************************************************
     Purpose    : method to create Entitement data
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
    private static void createEntitlementData() {
        User adminUser = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        adminUser.userName = adminUser.userName + '.systemAdmin';
        adminUser.FederationIdentifier = adminUser.FederationIdentifier + String.valueOf(Math.random()).substring(0,2);
        insert adminUser;
        System.runAs(adminUser) {
            Account entAcc = ASDAC_TestDataUtility.createAccount(false);
            entAcc.RecordTypeId = ASDAC_CommonUtility.getRecordTypeId('Account', 'BusinessAccount');
            entAcc.Name = 'Entitlement Account';
            insert entAcc;
            List<Entitlement> listOfEntitlments = new List<Entitlement>();
            List<String> listOfEntitlementNames = new List<String>{
                '30 Days SLA',
                '24 Hours SLA',
                '48 Hours SLA',
                '2 Hours SLA'
            };
            for(String entitlementName : listOfEntitlementNames) {
                listOfEntitlments.add(ASDAC_TestDataUtility.createEntitlements(false, entitlementName, entAcc.Id, null));                
            }
            insert listOfEntitlments;
        }
    }
    
     @IsTest
    static void testPopulateOrderDetails() {
        // Create test data
        Case testCase = new Case(
            Subject = 'Test Case',
            WebToCase__c = '{"isVatRequest": true, "orders": [{"orderId": "123", "orderDate": "2023-07-06", "orderTotal": 100.00}]}'
        );
        List<Case> testCases = new List<Case>{ testCase };

        // Call the method
        ASDAC_CaseHandler.populateOrderDetails(testCases);

        // Assert the changes made by the method
        System.assertEquals('123', testCase.OrderId__c,'Order Id');
    }
    @isTest
    static void testCaseOwnerInactiveWarning() {
        // Create an inactive user
        User inactiveUser = new User(
            Alias = 'inausr',
            Email = 'inactiveuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Inactive',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'inactiveuser_' + String.valueOf(System.currentTimeMillis()) + '@example.com', // Unique username
            IsActive = false,
            ProfileId  = UserInfo.getProfileId() 
             
        );
        insert inactiveUser;
        
        // Create a case with an inactive owner
        Case caseWithInactiveOwner = new Case(
            OwnerId = inactiveUser.Id,
            Status = 'New',
            Subject = 'Case with Inactive Owner'
        );
        
        Test.startTest();
        
        // Call the method with the list of cases
        List<Case> newCases = new List<Case>{ caseWithInactiveOwner };
        ASDAC_CaseHandler.caseOwnerInactive(newCases);
        
        Test.stopTest();
        
        // Verify results
        System.debug('updatedCases.size -----------------> ' + newCases.size());
        System.assertEquals(1, caseWithInactiveOwner.getErrors().size(), 'Error expected for case with inactive owner');
        System.assertEquals('The owner of this case is inactive. Please assign the case to an active user.', 
                            caseWithInactiveOwner.getErrors()[0].getMessage(), 
                            'Correct error message expected for case with inactive owner');
    }

    @isTest
    static void populateWorkQueueAndStatusForManualRefundCases_withInsertAndUpdateCasePayoutStatus_updateWorkQueueAndStatus() {
        Case caseObject = new Case();
        caseObject.ContactReasonLevel1__c = 'Payment & Refunds';
        caseObject.ContactReasonLevel2__c = 'Manual Refund Processed';
        caseObject.Origin = 'Phone';
        caseObject.BusinessArea__c = 'George';
        caseObject.Subject = 'Manual Payout';
        caseObject.Description = 'Manual Payout Test';
        caseObject.PayoutStatus__c = System.Label.ASDAC_PayoutStatusPending.split(', ')[0];
        insert caseObject;

        Test.startTest();
        Case updatedCase = [SELECT WorkQueue__c, Status FROM Case WHERE Id = :caseObject.Id];
        Assert.areEqual(System.Label.ASDAC_APIManualRefundPendingQueue, updatedCase.WorkQueue__c, 'Expected WorkQueue to be ' + System.Label.ASDAC_APIManualRefundPendingQueue);
        Assert.areNotEqual(ASDAC_GlobalConstants.STRING_STATUS_CLOSED, updatedCase.Status, 'Expected Status not to be ' + ASDAC_GlobalConstants.STRING_STATUS_CLOSED);

        caseObject.PayoutStatus__c = System.Label.ASDAC_PayoutStatusSuccess.split(', ')[0];
        update caseObject;
        updatedCase = [SELECT WorkQueue__c, Status FROM Case WHERE Id = :caseObject.Id];
        Assert.areEqual(System.Label.ASDAC_APIManualRefundQueue, updatedCase.WorkQueue__c, 'Expected WorkQueue to be ' + System.Label.ASDAC_APIManualRefundQueue);
        Assert.areEqual(ASDAC_GlobalConstants.STRING_STATUS_CLOSED, updatedCase.Status, 'Expected Status to be ' + ASDAC_GlobalConstants.STRING_STATUS_CLOSED);

        caseObject.PayoutStatus__c = System.Label.ASDAC_PayoutStatusFailure.split(', ')[0];
        update caseObject;
        updatedCase = [SELECT WorkQueue__c, Status FROM Case WHERE Id = :caseObject.Id];
        Assert.areEqual(System.Label.ASDAC_APIManualRefundFailureQueue, updatedCase.WorkQueue__c, 'Expected WorkQueue to be ' + System.Label.ASDAC_APIManualRefundFailureQueue);
        Assert.areNotEqual(ASDAC_GlobalConstants.STRING_STATUS_CLOSED, updatedCase.Status, 'Expected Status not to be ' + ASDAC_GlobalConstants.STRING_STATUS_CLOSED);
        Test.stopTest();
    }
}