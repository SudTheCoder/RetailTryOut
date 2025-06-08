/**********************************************************************************
 * @author                       : Disharee Ray
 * @date                         : 2022-10-14
 * @description                  : ASDAC-4050 HC Header -> Burger Menu (Based on Asda site)
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Disharee Ray                14-Oct-2022    Created the class
 ***************************************************************************************************/
@isTest(seeAllData=false)
private with sharing class ASDAC_NavigationLinkSetPickList_Test {
 @isTest
 static void getDefaultValue_test() {
   ASDAC_NavigationLinkSetPickList timeline = new ASDAC_NavigationLinkSetPickList();
   Test.startTest();
   VisualEditor.DataRow navLinkSetDefaultValueObj = timeline.getDefaultValue();
   Test.stopTest();
   System.assertEquals('ASDAC_Navigational_Menu', navLinkSetDefaultValueObj.getValue());
  }
    
 @isTest
 static void getValues_test() {  
   List<NavigationLinkSet> navigationLinkSetList = [SELECT MasterLabel, DeveloperName FROM NavigationLinkSet];
   ASDAC_NavigationLinkSetPickList navLinkSetPicklistObj = new ASDAC_NavigationLinkSetPickList();
   Test.startTest();
   VisualEditor.DynamicPickListRows totalDynamicPicklistRows = navLinkSetPicklistObj.getValues();
   Test.stopTest();
   System.assertEquals(navigationLinkSetList.size(), totalDynamicPicklistRows.size());
  }
}