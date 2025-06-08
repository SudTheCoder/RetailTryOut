/************************************************************************************************************
    @author         Dependra Singh
    @description:   This is the constants class for all static strings used in classes, but use comments so that it's clear how the constants are being used
    **************************************************************************************************************/
    public with sharing class ASDAC_GlobalConstants {
        
        // The prefix for this namespace
        public static final String PREFIX = 'ASDAC_';
        
        // Appended to the end of all trigger handler classes
        public static final String HANDLERSUFFIX = 'Handler';
        public static final string contactleave1 ='Product Quality';
        public static final string adderrors ='you cannot delete this record';
        
        public static final string damage ='Damaged / Faulty';
        public static final string foreign ='Foreign Body';
        
        public static final string wegith = 'Missing Part / Weight';
        
        public static final string general='General Issue';
                
        // Suffix for trigger automation custom setting fields
        public static final String CUSTSETFIELDSUFFIX = 'Triggers__c';   
        
        // Trigger object names and the prefix for trigger class and field names
        public static final String OBJACCOUNT             = 'Account';
        public static final String OBJCASE                = 'Case';
        public static final String OBJCONTACTPOINTADDRESS = 'ContactPointAddress';
        public static final String OBJCONTACTPOINTEMAIL   = 'ContactPointEmail';
        public static final String OBJCONTACTPOINTPHONE   = 'ContactPointPhone';
        public static final String OBJEMAILMESSAGE        = 'EmailMessage';
        public static final String OBJGOODWILL	          = 'Goodwill';
        public static final String OBJCONTACTPOINTCONSENT = 'ContactPointConsent';
        public static final String OBJTERMSCONDITION      = 'TermsCondition';
        public static final String OBJCONTENTDOCUMENT     = 'ContentDocument';
        public static final String OBJCASECOMMENT         = 'CaseComment';
        
        public static final String DUPLICATE_EMAIL        = 'Duplicate Email Address For this Account'; 
        public static final String INVALID_CONTACTPOINT   = 'Invalid Contact Point for the Account';
        public static final String PRIMARY_EMAIL_DELETE_ERROR = 'Primary Email Cannot be Deleted';
        public static final String DELETE_EXCEPTION = 'Delete Exception in deleting';
        public static final String PRIVACY_CONSENT_STATUS_OPTOUT = 'OptOut'; 
        
        
        public static final String OBJCONTENTDOCUMENTLINK           = 'ContentDocumentLink';  
        public static final String ALLUSERS                         = 'AllUsers';
        public static final String SHARETYPE                        = 'I';
        public static final String BATCHPROCESSOPERATION            = 'Import';
        public static final String BATCHPROCESSOPERATIONEXPORT      = 'Export';
        public static final String FILEEXTENSIONCSV                 = 'csv';
        public static final String FILEEXTENSIONXML                 = 'xml';
        public static final String NOTIMPLEMENTEDERROR              = 'Error Not Implemented';
        public static final String ERRORS                           = 'Errors';
        public static final String INITIALISED                      = 'Initialised'; 
        public static final String PROCESSED                        = 'Processed';
        public static final String COMPLETED                        = 'Completed'; 
        public static final String COMPLETE                         = 'Complete';  
        public static final String AFTERINSERT                      = ' Exception After Insert';
        public static final String BEFOREINSERT                     = ' Exception Before Insert';
        public static final String AFTERUPDATE                      = ' Exception After Update';
        public static final String BEFOREUPDATE                     = ' Exception Before Update';
        public static final String AFTERDELETE                      = ' Exception After Delete';
        public static final String BEFOREDELETE                     = ' Exception Before Delete';
        public static final String EXECUTINGBATCH                   = ' Executing Batch ';
        public static final String EXECUTINGLGTHNGCMPCTRL           = ' Executing Lighting Component Controller ';
        public static final String EXECUTING                        = ' Executing ';
        public static final String FIELDCUSTOMVALIDATIONEXCEPTION   = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
        public static final String REQUIREDFIELDMISSING             = 'REQUIRED_FIELD_MISSING';
        public static final String STRINGUPDATE                     = 'Update';
        
                
        public static final String JOBTYPEAPINAME       = 'JOB_TYPE';
        public static final String JOBTYPELABEL         = 'Job Type';
        public static final String JOBIDAPINAME       = 'JOB_ID'; 
        public static final String JOBIDLABEL         = 'Job Id'; 
        public static final String BATCHJOBSAPINAME     = 'BatchJobs';
        public static final String NEXTSCHEDULEDAPINAME = 'Next_Scheduled';
        public static final String NEXTSCHEDULEDLABEL   = 'Next Scheduled';
        public static final String CRONEXPRESSIONAPINAME= 'cronExpression';
        public static final String STATUSAPINAME        = 'STATUS';
        public static final String FREQUENCYAPINAME     = 'FREQUENCY';
        public static final String SUBMITTEDBYAPINAME   = 'SUBMITTED_BY';
        public static final String SUBMITTEDBYLABEL     = 'SUBMITTED BY';
        public static final String TOTALRECORDSAPINAME  = 'TOTAL_RECORDS';
        public static final String TOTALRECORDSLABEL    = 'TOTAL RECORDS';    
        public static final String SUCCESSAPINAME       = 'SUCCESS';
        public static final String FAILUREAPINAME       = 'FAILURE';
        public static final String JOBENDTIMEAPINAME    = 'Job_End_Time';
        public static final String JOBENDTIMELABEL      = 'Job End Time';
        public static final String ERRORDEFAULTADDRESSDELETION     = 'Default Address Can not be deleted';
        public static final String ERRORRESTRICTEDPICKLIST     = 'bad value for restricted picklist field';
        public static final String FIELDADDRESSTYPE    = 'AddressType';
        public static final String FIELDUSAGETYPE     = 'UsageType';
        public static final String STRING_CONTACT_CENTRE = 'Contact Centre';
        public static final String STRING_LOYALTY = 'Loyalty';
        public static final String STRING_OMS = 'OMS';
        public static final String STRING_ASDA_REWARDS = 'ASDA Rewards';
        public static final String STRING_MANUAL = 'Manual'; 
        public static final String STRING_STATUS_CLOSED = 'Closed';
        public static final String STRING_STATUS_ASSIGNED = 'Assigned';
        public static final String STRING_STATUS_AVAILABLE = 'Available';
        public static final Set<String> SET_PREVENT_DEL_CONTACT_REASON_LVL_2 = new Set<String> {'Damaged / Faulty',
                                                                                                'Foreign Body',
                                                                                                'General Issue',
                                                                                                'Missing Part / Weight',
                                                                                                'Out of Date',
                                                                                                'Serious Product Issue'};
                                                                                                    
        public static final String STRING_PRODUCT_QUALITY = 'Product Quality';
        public static final String STRING_COMPLAINT = 'Complaint';
        public static final String TASK_PRIORITY = 'Normal';
        public static final String TASK_STATUS = 'Open';
        public static final String PERSON_ACCOUNT_SAME_EMAIL = 'SameEmail@Pa.com';
        public static final String PERSON_ACCOUNT_EMAIL = 'newGmail@gmail.com';
        public static final String BPO_USERNAME = 'testUser_0@testing_0.com.colleagueBPO';
        public static final String STRING_PERSON_ACCOUNT = 'PersonAccount';
        public static final String STRING_ASDA_BASE_PROFILE = 'ASDA Base';
        public static final String STRING_ASDABASE_SUFFIX = '.asdaBase';
        public static final String STRING_CUSTOMER_SUPPORT = 'CustomerSupport';
        public static final String STRING_OCS_TEAMLEAD_PERMISSION_SET_GROUP_NAME = 'ASDAC_TeamLeadOffshoreGroupPermissions';
        public static final String STRING_OCS_TEAMLEADUK_PERMISSION_SET_GROUP_NAME = 'ASDAC_TeamLeadUKGroupPermissions';
        public static final String STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME = 'ASDAC_ColleagueOffshoreGroupPermissions';
        public static final String STRING_EVOUCHER_TITLE    = 'EVouchers Removed.';
        public static final String STRING_ACCOUNT_NOTE      = 'These Vouchers {0} removed successfully at {1} by {2}.';
        public static final String STRING_SUCCESS_MESSAGE   = 'Vouchers Removed Successfully.';
        public static final String STRING_BULKCASEACTIONS_PERMISSION_SET_NAME = 'ASDA_Bulk_Case_Actions_Permissions';
        public static final String STRING_TEAMLEAD_UK_PSG_NAME = 'ASDAC_TeamLeadUKGroupPermissions';
        public static final String STRING_WEBFORM_CASE_ORIGIN = 'Webform';
        public static final String STRING_GROCERY_CASE_BUSINESSAREA = 'Grocery';
        public static final String STRING_STORES_CASE_BUSINESSAREA = 'Stores';
        public static final String STRING_MEDALLIA_GHS_STOREID = 'asda_grocery';
        public static final String STRING_MEDALLIA_STR_STOREID = 'asda_stores';
        public static final String STRING_MEDALLIA_GRG_STOREID = 'asda';
        Public Static final String VOUCHERE_MAIL_ERROR = 'Errow while sending Evoucher Issue Email to Customer: ';
        Public Static final Integer VOUCHERE_SUCCESS_CODE = 202;
        Public Static final String RECURRINGSLOT_SUCCESS_RESPONSE = 'Success';
        Public Static final String RECURRINGSLOT_SUCCESS_MESSAGE = 'Processed Successfully';
        Public Static final String RECURRINGSLOT_ERROR_RESPONSE ='ERROR';
        Public Static final String CURRENCYCODE = 'GBP';
        public static final String STRING_VAT_RECEIPT = 'VAT Receipt';
        public static final String STRING_EXCEPTION_LOGTYPE = 'Exception';
        public static final String STRING_RETURNTYPE_STANDARD = 'Standard';
        public static final String STRING_SOURCE_SFSC = 'SFSC';
    }