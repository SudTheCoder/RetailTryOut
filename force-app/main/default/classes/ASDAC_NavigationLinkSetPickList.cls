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
global with sharing class ASDAC_NavigationLinkSetPickList extends VisualEditor.DynamicPickList{
    global ASDAC_NavigationLinkSetPickList(){}
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
            'ASDAC_Navigational Menu',
            'ASDAC_Navigational_Menu'
        );
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        List<NavigationLinkSet> navigationLinkSetList = [
            SELECT MasterLabel, DeveloperName
            FROM NavigationLinkSet
        ];
        for (NavigationLinkSet navigationLinkSet : navigationLinkSetList) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(
                navigationLinkSet.MasterLabel,
                navigationLinkSet.DeveloperName
            );
            picklistValues.addRow(value);
        }
        return picklistValues;
    }
}