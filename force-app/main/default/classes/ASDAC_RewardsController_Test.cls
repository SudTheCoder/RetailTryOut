/**********************************************************************************
 * @author                       : Sanskriti Vijay
 * @date                         : 07-Aug-2023
 * @description                  : Test Class for ASDAC_RewardsController class.
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Sanskriti Vijay            07-Aug-2023          
 ***************************************************************************************************/
@IsTest
public class ASDAC_RewardsController_Test {
    private final static String VALIDATION_EXCEPTION_MESSAGE = 'Not Found';
    private final static String EXPECTED_VALIDATION_EXCEPTION_MESSAGE = 'The crm id is incorrect. Please check and try again.';
    private final static String TECHNICAL_EXCEPTION_MESSAGE = 'Internal Server Error';
    private final static String EXPECTED_TECHNICAL_EXCEPTION_MESSAGE = 'We are currently facing a technical issue. Please try later.';
	  private final static String TIMEOUT_EXCEPTION_MESSAGE = 'System Timeout';
    //private final static String PROFILE_ID = '3d811892-2c48-436b-9682-ec6e5b8493f1';
    private final static String CRM_ID = '003KI0000057O3TYAU';
    private final static String APEX_EXCEPTION_MESSAGE = 'Invalid JSON';
    private final static String EXPECTED_APEX_EXCEPTION_MESSAGE = 'Expected handled Apex error message';
    private final static String USER_NAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
    
    /**************************************************************************
    Purpose    : Test Setup data                                           
    Parameters : NA
    Returns    : NA                                        
    **************************************************************************/ 
    @TestSetup
    static void createData() {
      User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
      ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
      insert ocsCollBPO;
      ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);  
    }
    
    @IsTest
    static void unlinkProfileTest() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
          Test.startTest();
          Test.setMock(HttpCalloutMock.class, new ASDAC_GenericIntegrationServiceMock_Test(200, '"Success"'));
          Integer response = ASDAC_RewardsController.unlinkProfile(CRM_ID);
          System.assert(response == 200, 'Profile successfully unlinked');
          Test.stopTest();
        }
    }
  
    @IsTest
  static void unlinkProfileValidationExceptionTest() {
    User ocsCollBPO = getuserRecord(USER_NAME);
    System.runAs(ocsCollBPO){
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_GenericIntegrationServiceMock_Test(404, VALIDATION_EXCEPTION_MESSAGE));
      ASDAC_GenericIntegrationService instance = new ASDAC_GenericIntegrationService();
      instance.createRequest('{}');
      String exceptionMsg;
      try {
        ASDAC_RewardsController.unlinkProfile(CRM_ID);
      } catch (Exception ex) {
          String exceptionMsgMap = (ex.getMessage());
        Map<String, Object> deserializedMsg = (Map<String, Object>) JSON.deserializeUntyped(exceptionMsgMap);
        exceptionMsg = (String) deserializedMsg.get('message');
      }
      System.assertEquals(EXPECTED_VALIDATION_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_VALIDATION_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
      @IsTest
  static void unlinkProfileApexExceptionTest() {
    User ocsCollBPO = getuserRecord(USER_NAME);
    System.runAs(ocsCollBPO){
      Test.startTest();
      String exceptionMsg;
      try {
        ASDAC_RewardsController.unlinkProfile(null);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
    /**************************************************************************
    Purpose    : Get User Record                                           
    Parameters : username
    Returns    : User record                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }   
}