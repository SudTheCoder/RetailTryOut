/**********************************************************************************
 * @author                       : Sai
 * @date                         : 2022-10-14
 * @description                  : ASDAC-3395  
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Sai                 14-10-2022     Created the Test class
 ***************************************************************************************************/
@isTest
public class ASDAC_QuickLinksController_Test {
    @isTest
    public static void fetchquicklinkTest() {
            Test.StartTest();
                ASDAC_QuickLinksController.ResponseWrapper respWrap = ASDAC_QuickLinksController.asdaQuicklink();
                System.assertEquals(respWrap.isSuccess, TRUE, 'no link found.');
            Test.StopTest();
        
    }


    
}