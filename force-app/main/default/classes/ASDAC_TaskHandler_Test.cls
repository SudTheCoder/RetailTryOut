/******************************************************************************
Name: ASDAC_TaskHandler_Test
===============================================================================
Req: 
ASDAC-3611 New contact vs 2nd time contact and First Contact Resolution
		   - Reporting requirement
===============================================================================
Purpose:Test class to test functionality for Task Triggers
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		11 October 2022    Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_TaskHandler_Test {
    
	/**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup
    static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        system.runAs(ocsCollBPO) {
			ASDAC_TestDataUtility.createCases(1, true, 'GeneralEnquiry', null);
        }
    }
	/**************************************************************************
     Purpose    : Test NumberOfOutboundCalls__c testing
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/
	@isTest
    static void testNumberOfOutboundCallsIncrementAndFCR() {
        User ocsCollBPO = getuserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        System.runAs(ocsCollBPO) {
			List<Case> listOfCases = [SELECT Id FROM Case LIMIT 1];
			Task callTsk = new task();
            callTsk.WhatId = listOfCases[0].Id;
            callTsk.Type = 'Call';
            insert callTsk;
            listOfCases[0].Status = 'Closed';
            listOfCases[0].CaseClosedReason__c = 'Resolved';
            Update listOfCases;
			Case parentCase = [SELECT Id, NumberOfOutboundCalls__c, FirstCallResolution__c FROM Case WHERE Id = :listOfCases[0].Id];
			System.assertEquals(1, parentCase.NumberOfOutboundCalls__c, 'Outgoing Call by user will increment.'); 
            System.assertEquals(true, parentCase.FirstCallResolution__c, 'First Call Resolution Will become true. Since Case got closed in one Email Interaction.'); 
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