/******************************************************************************
Name: ASDAC_CaseDuplicationCheck
===============================================================================
Req: 
ASDAC-1202 Enhancement- Agents can follow case updates.
===============================================================================
Purpose:Controller Class for asdacCaseDuplicateRecordNotificationCmp 
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE            DETAIL
1.0       Sanskriti Vijay       16-Sept-2022    Initial Development
******************************************************************************/

public with sharing class ASDAC_CaseDuplicationCheck {   

    /***************************************************************************
    @author        Sapient: Sanskriti
    @date          16-Sept-2022
    @param         Id recordId
    @return        List<Case>
    @description   This method returns a list of all the duplicate cases having same recordType and
                   CustomerName as of the case passed from the component.
    ****************************************************************************/
  
    
	@InvocableMethod(label='Upsert Webform List of Cases' description='Upsert Webform Cases from Flow')
   	public static void upsertWebformListOfCases(List<List<Case>> caseObjectList) {
        
   		ASDAC_WebformCmpController.upsertWebformCase(caseObjectList[0]);  
  	}
}