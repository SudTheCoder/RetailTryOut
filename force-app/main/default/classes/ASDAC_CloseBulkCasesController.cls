/******************************************************************************
Name: ASDAC_CloseBulkCasesController
===============================================================================
Req: 
ASDAC-1360 Bulk Close Cases.
===============================================================================
Purpose:Controller Class for the Bulk Close Case Functionality 
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		03 June 2022    Initial Development
******************************************************************************/
public with sharing class ASDAC_CloseBulkCasesController {
    public String openCaseIdsWithCaseNumbers{ get; set; }
    public String closedCaseNumbers{ get; set; }
    public ResponseWrapper resWrap{get; set;}
    
    /**************************************************************************
    Purpose    : Constructor to get selected records from list view for VF page                                          
    Parameters : ApexPages.StandardSetController cntlr
    Returns    : NA                                               
    **************************************************************************/
    public ASDAC_CloseBulkCasesController(ApexPages.StandardSetController cntlr){
        this.resWrap = new ResponseWrapper(false, JSON.serialize(Label.ASDAC_CloseBulkCasesPermissionError));
        Boolean isOpenCaseFound = false;
        Map<Id, String> mapOfCaseIdsCaseNumber = new Map<Id, String>(); 
        List<String> listOfClosedCaseNumbers = new List<String>();

                if(FeatureManagement.checkPermission(Label.ASDAC_BulkCaseAction)) {
            this.resWrap = new ResponseWrapper(false, JSON.serialize(Label.ASDAC_CloseBulkCasesSelectionError));
            if(!cntlr.getSelected().isEmpty()) {
                for(Case cse : [SELECT CaseNumber, Status FROM Case WHERE Id IN :cntlr.getSelected() WITH SECURITY_ENFORCED]){
                    if(String.isNotBlank(cse.Status) && cse.Status.equalsIgnoreCase('Closed')) {
						listOfClosedCaseNumbers.add(cse.CaseNumber);
                        continue;
                    }
                   	mapOfCaseIdsCaseNumber.put(cse.Id, cse.CaseNumber);
                    isOpenCaseFound = true; 
                }
                closedCaseNumbers = String.join(listOfClosedCaseNumbers, ',');
				this.resWrap = new ResponseWrapper(false, String.format(Label.ASDAC_AlreadyClosedCasesError, new List<Object>{listOfClosedCaseNumbers}));
            }
        }
        //If All Selected Cases are Closed
        if(isOpenCaseFound) {
            this.resWrap = new ResponseWrapper(true, '');
            openCaseIdsWithCaseNumbers = '';  
            for(Id openCaseId : mapOfCaseIdsCaseNumber.keyset()) { //querying on open case
                openCaseIdsWithCaseNumbers += (openCaseId + '-' + mapOfCaseIdsCaseNumber.get(openCaseId)) + ','; //build list of ids string concatenated with comma 
            }
            openCaseIdsWithCaseNumbers = JSON.serialize(openCaseIdsWithCaseNumbers.removeEnd(','));                
        }
    }
    
    /**************************************************************************
    Purpose    : Close the case by updating the listOfCases coming from
				 component. Although we do not need to check for fields
				 Accesses as record-edit-form on LWC is being used. so 
				 it will automatically takes care of FLS.
    Parameters : List<Case> listOfCasesToClosed - list of cases to closed
    Returns    : ResponseWrapper                                               
    **************************************************************************/
    @AuraEnabled
    public static ResponseWrapper closeCases(List<Case> listOfCasesToClosed, List<String> caseNumbersToClosed, String closedCaseNumbers) {
        ResponseWrapper resWrap;
        try {
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, listOfCasesToClosed);
            Map<String, Set<String>> mapOfObjNameToFields = securityDecision.getRemovedFields();
            if(!mapOfObjNameToFields.isEmpty()) {
                String errorMessage = Label.ASDAC_FieldPermissionError + String.join(new List<String>(mapOfObjNameToFields.get('Case')),',');
            	ASDAC_Logger.logException(errorMessage);
            	ASDAC_Logger.writeLogsToDatabase();
				return new ResponseWrapper(false, errorMessage);			   
            }
            ASDAC_WithoutSharingUtility.upsertCase(listOfCasesToClosed);
            String successMsg = String.format(Label.ASDAC_CaseClosedSuccessMessage, new List<Object>{listOfCasesToClosed.size(), caseNumbersToClosed}); 
            if(String.isNotBlank(closedCaseNumbers)) {
                successMsg = successMsg +  '\n' + String.format(Label.ASDAC_AlreadyClosedCasesError, new List<Object>{closedCaseNumbers});
            }
			resWrap = new ResponseWrapper(true, successMsg);             
        }
        catch(Exception ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_CloseBulkCasesController');
            ASDAC_Logger.writeLogsToDatabase();
			resWrap = new ResponseWrapper(false, ex.getMessage());  
        }
		return resWrap;        
    }

   	/**************************************************************************
    Purpose    : Wrapper Class to return data to LWC/VF page.                                          
    Parameters : NA
    Returns    : NA                                               
    **************************************************************************/
    public class ResponseWrapper {
        @AuraEnabled public Boolean isSuccess{get; set;}
        @AuraEnabled public String message{get; set;}
        public ResponseWrapper(Boolean isSuccess, String message) {
			this.isSuccess = isSuccess;
            this.message = message;
        }
    }
}