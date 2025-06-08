/**********************************************************************************
 * @author                       : Amey Priolkar
 * @date                         : 2022-09-26
 * @description                  : SonarQube Test class ASDAC_CommonUtility
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Amey Priolkar                 26-Sep-2022     Created the Test class
 ***************************************************************************************************/
@isTest
public with sharing class ASDAC_CommonUtility_Test {
    public FINAL STATIC String UK_TL_USER = 'testUser_0@testing_0.com.teamLeaderUK';
    /**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup static void createData() {
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + '.teamLeaderUK';
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEAD_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsTeamLdrTstUsr) {
            ASDAC_TestDataUtility.createPersonAccount(true);
        }
    }

    /**************************************************************************
     Purpose    : fetching All sObjects
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getAllSObjectsTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                ASDAC_CommonUtility.getAllSObjects();
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : get API Name of specified Object
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getSObjectAPINameTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                String objectAPIName = ASDAC_CommonUtility.getSObjectAPIName('Account');
                system.debug('== objectAPIName =='+objectAPIName);
                System.assertEquals(objectAPIName, 'Account', 'Object API Matches.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get all fields of object
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getSObjectAllFieldsTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                ASDAC_CommonUtility.getSObjectAllFields(Schema.getGlobalDescribe().get('Account'));
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get field API Name
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getFieldAPINameTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                String nameStr = ASDAC_CommonUtility.getFieldAPIName(Schema.getGlobalDescribe().get('Account'), 'Industry');
                System.assertEquals(nameStr, 'Industry', 'Field API Matches.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get field Label
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getFieldLabelTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                String nameStr = ASDAC_CommonUtility.getFieldLabel(Schema.getGlobalDescribe().get('Account'), 'Name');
                System.assertEquals(nameStr, 'Account Name', 'Field Label Matches.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get fieldset
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getFieldSetMemebersTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                List<Schema.FieldSetMember> fieldList = ASDAC_CommonUtility.getFieldSetMemebers(Schema.getGlobalDescribe().get('Account'), 'CustomerSearch');
                System.assertEquals(fieldList.isEmpty(), false, 'FieldSet found.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get Picklist values of a specific Field of an Object
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getFieldPicklistValuesTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                Map<String, String> pickListMap = ASDAC_CommonUtility.getFieldPicklistValues(Schema.getGlobalDescribe().get('Account'), 'Industry');
                System.assertEquals(pickListMap.isEmpty(), false, 'Picklist values found.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get Picklist values of a specific Field of an Object
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getPicklistEntriesTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                List<Schema.PicklistEntry> pickListSchemaList = ASDAC_CommonUtility.getPicklistEntries('Account', 'Industry');
                System.assertEquals(pickListSchemaList.isEmpty(), false, 'Picklist values found.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get Record Type Id
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getRecordTypeIdTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                list<RecordType> rtList = [select id, name from RecordType where SobjectType = 'Case' LIMIT 1];
                Id rtId = ASDAC_CommonUtility.getRecordTypeId(Schema.getGlobalDescribe().get('Case'), rtList[0].Name, 'Case');
                System.assertEquals(rtId, rtList[0].Id, 'Record Type Id found.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Get Record Type Id
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getRecordTypeNameTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                list<RecordType> rtList = [select id, name from RecordType where SobjectType = 'Case' LIMIT 1];
                String rtName = ASDAC_CommonUtility.getRecordTypeName(Schema.getGlobalDescribe().get('Case'), rtList[0].Id, 'Case');
                System.assertEquals(rtName, rtList[0].Name, 'Record Type Name found.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Generate GUID
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getSObjectTypeTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                Schema.SObjectType accSobjTyp = ASDAC_CommonUtility.getSObjectType([SELECT ID FROM ACCOUNT LIMIT 1].Id);
                System.assertEquals(Schema.getGlobalDescribe().get('Account'), accSobjTyp, 'Object mapped with record.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Generate GUID
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void getRecordTypeIdOverloadTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                list<RecordType> rtList = [SELECT id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' LIMIT 1];
                Id rtId = ASDAC_CommonUtility.getRecordTypeId('Case', rtList[0].DeveloperName);
                System.assertEquals(rtId, rtList[0].Id, 'Record Type Id found with Overload method.');
            Test.StopTest();
        }
    }

    @isTest
    public static void getRecordTypeIdsByObjectTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                Map<String, Id> strToIdMap = ASDAC_CommonUtility.getRecordTypeIdsByObject('Case');
                System.assertEquals(strToIdMap.isEmpty(), false, 'Record Type found.');
            Test.StopTest();
        }
    }

    /**************************************************************************
     Purpose    : Generate GUID
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    @isTest
    public static void generateGUIDTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USER);
        System.runAs(ocsTeamLdrTstUsr) {
            Test.StartTest();
                String guidStr = ASDAC_CommonUtility.generateGUID();
                System.assertEquals(String.isBlank(guidStr), false, 'GUID generated.');
            Test.StopTest();
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
}