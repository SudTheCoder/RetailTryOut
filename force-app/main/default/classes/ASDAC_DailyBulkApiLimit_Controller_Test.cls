/***************************************************************************************************************************
* Author:       Ramdev Chahar
* Date:         02 Nov 2022
* Description:  Test class for ASDAC_DailyBulkAPILimit_controller class
**************************************************************************************************************************/
@isTest
private class ASDAC_DailyBulkApiLimit_Controller_Test {
    public static final String ASSERT_FAILED_MSG = 'Daily Bulk API limit should not be null';
    /********************************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          02 Nov 2022
    @description   test method for get DailyBulkAPILimit
    *********************************************************************************************************/
    @IsTest
    static void testGetDailyBulkAPILimit(){
        test.startTest();
            Map<String, String> returnedMap = ASDAC_DailyBulkApiLimit_Controller.getDailyBulkAPILimit();
        test.stopTest();
        System.AssertNotEquals(returnedMap.get('max'), null, ASSERT_FAILED_MSG);
        
    }
}