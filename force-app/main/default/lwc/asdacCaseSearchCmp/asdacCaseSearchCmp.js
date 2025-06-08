import { LightningElement } from 'lwc';
import getCases from "@salesforce/apex/ASDAC_CaseCustomerSearch.getCaseWithCustomerDetails";
import CaseNumberLabel from '@salesforce/label/c.ASDAC_CaseNumber';
import CaseErrorLabel from '@salesforce/label/c.ASDAC_CaseError';
import CaseNotFoundLabel from '@salesforce/label/c.ASDAC_CaseNotFoundLabel';
import Error from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import ASDAC_Search from "@salesforce/label/c.ASDAC_Search";
import ASDAC_Clear from "@salesforce/label/c.ASDAC_Clear";

const COLUMNS = [
	{label: "Name", fieldName: "Name", type: "button", typeAttributes: { label: { fieldName: "Name" }, variant: "base",name:'account' }, wrapText: true},
    {label: "Case", fieldName: "CaseId", type: "button", typeAttributes: { label: { fieldName: "CaseNumber" }, variant: "base",name:'case' }},
	{ label: "Email", fieldName: "PersonEmail", type: "email", wrapText: true },
	{ label: "Phone", fieldName: "Phone", type: "phone", wrapText: true },
	{ label: "Address Line 1", fieldName: "AddressLine1__pc", wrapText: true },
	{ label: "Postcode", fieldName: "PostalCode__pc", type: "text", wrapText: true }
];
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

export default class AsdacCaseSearchCmp extends NavigationMixin(LightningElement) {
    label = {
        CaseNumberLabel,
        CaseErrorLabel,
        CaseNotFoundLabel,
        ASDAC_Search,
        ASDAC_Clear,
        Error
    };
    caseList = [];
    columns = COLUMNS;
    showSpinner = false;
    isExecutionDone = false;
    caseNumber;
    handleChange(event) {
        this.caseNumber = event.target.value;
        if(!this.caseNumber && this.caseList.length === 0 && this.isExecutionDone)
        {
            this.hancleClear();
        }
 
    }
    handleSearch() {
        let isValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
            }, true);
        if(isValid) {
            this.showSpinner = true;
            let caseNumber;
            caseNumber = this.handleCaseNumber(this.caseNumber);
            getCases({caseNumber}).then((result) => {
                this.showSpinner = false;
                this.isExecutionDone = true;
                this.caseList = result.listOfCases.map((record) => {
                    return {
                        ...record.Account,
                        Phone: record?.Account?.CountryCode__c ? `+${record.Account.CountryCode__c} ${record.Account.Phone}` : record?.Account?.Phone,
                        CaseId: record.Id,
                        CaseNumber:record.CaseNumber
                    };
                });

            }).catch((error) => {
                this.showSpinner = false;
                this.showToast('Error', 'error', error.message);
            });
        }
    }
    
    viewRecord(event) {
		const record = event.detail.row;
        let recordId = record.Id;
        if (event.detail.action.name === 'case') {
            recordId = record.CaseId;
        }
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: recordId,
				actionName: "view"
			}
		});
        const closeUtility = new CustomEvent("minimizetab", {bubbles: true , composed : true});
        this.dispatchEvent(closeUtility);    
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(event);       
    }
    hancleClear() {
        this.caseNumber = null;
        this.caseList = [];
        this.isExecutionDone = false;
    }

    handleCaseNumber(caseNumber)
    {
        let caseNumbertochange = caseNumber;
        while(caseNumbertochange.length < 8 )
        {
            caseNumbertochange = 0+caseNumbertochange;
        }
        this.caseNumber=caseNumbertochange;
        return this.caseNumber;
    }

    handleEnter(event){
        if(event.keyCode === 13){
          this.handleSearch();
        }
      }
}