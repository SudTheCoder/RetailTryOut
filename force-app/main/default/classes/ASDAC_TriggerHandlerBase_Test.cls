/***************************************************************************************************************************
* Author:       Ramdev Chahar
* Date:         27/06/2022
* Description:  Test Class For ASDAC_TriggerHandlerBase Class
**************************************************************************************************************************/
@IsTest
public class ASDAC_TriggerHandlerBase_Test {
    public STATIC FINAL string ERROR_OCCURRED = 'Error Occured';
/***************************************************************************************************************************
* Author:       Ramdev Chahar
* Date:         27/06/2022
* Description:  Test Method For Main Entry
**************************************************************************************************************************/
    @isTest
    static void testMainEntry() {
        ASDAC_TriggerHandlerBase thb = new ASDAC_TriggerHandlerBase();
        String errorMsg = '';
        
        test.startTest();
        try{
            thb.mainEntry(null);
        }Catch(Exception e){
            errorMsg = ERROR_OCCURRED; 
        }
        test.stopTest();
        
        System.assertEquals(ERROR_OCCURRED,errorMsg,'The error message does not match');
        
    }
/***************************************************************************************************************************
* Author:       Ramdev Chahar
* Date:         27/06/2022
* Description:  Test Method For inProgressEntry
**************************************************************************************************************************/
    @isTest
    static void testInProgressEntry() {
        ASDAC_TriggerHandlerBase thb = new ASDAC_TriggerHandlerBase();
        ASDAC_TriggerHandlerObj tho = new ASDAC_TriggerHandlerObj();
        String errorMsg = 'No Error';
        tho.triggerObject = 'ContactPointAddress';
        test.startTest();
        try{
            thb.inProgressEntry(tho);
        }Catch(Exception e){
            errorMsg = ERROR_OCCURRED;
        }
        test.stopTest();
        
        System.assertEquals('No Error',errorMsg,'The error message does not match');
        
    }
}