import { LightningElement, api } from 'lwc';
import closeCases from '@salesforce/apex/ASDAC_CloseBulkCasesController.closeCases';
import closeCasesTitle from '@salesforce/label/c.ASDAC_CloseCasesTitle';
import saveButtonLabel from '@salesforce/label/c.ASDAC_SaveButtonLabel';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';

export default class AsdacBulkCloseCasesCmp extends LightningElement {
    @api openCases;
    @api closedCaseNumbers;
    listOfCasesToClosed = [];
    isLoading = true;
    label = {
		closeCasesTitle,
		saveButtonLabel,
		cancelButtonLabel
	};
    fields = {
        Status : 'Closed'
    };
    connectedCallback(event) {
        this.openCases = this.openCases.replace(/\"/g, "");
        if(this.closedCaseNumbers) {
            this.closedCaseNumbers = this.closedCaseNumbers.replace(/\"/g, "");
        }
        this.isLoading = false;
    }
    handleChange(event) {
        this.fields[event.target.fieldName] = event.target.value;
    }
    async handleClick(event) {
        if(event.target.name === 'cancel') {
            this.dispatchEvent(new CustomEvent('cancelclicked',{
                bubbles: true,
                composed: true,
            }));            
        }
        else if(event.target.name === 'save') {
            event.preventDefault(); // stop the form from submitting
            let isValid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
                            // Return whether all fields up to this point are valid and whether current field is valid
                            // reportValidity returns validity and also displays/clear message on element based on validity
                            return (validSoFar && field.reportValidity());
                            }, true);
            if(isValid) {
                this.isLoading = true;
                let caseNumbersToClosed = [];
                this.openCases.split(',').forEach(caseId => {
                    let caseIdAndCaseNumber = caseId.split("-");
                    caseNumbersToClosed.push(caseIdAndCaseNumber[1]);
                    let caseObj = {
                        "objectApiName":"Case",
                        "Id" : caseIdAndCaseNumber[0]
                    };
                    for (const key in this.fields) {
                        caseObj[key] = this.fields[key];
                    }
                    this.listOfCasesToClosed.push(caseObj);
                });
                let resultDetail = await closeCases({listOfCasesToClosed : this.listOfCasesToClosed, caseNumbersToClosed, closedCaseNumbers : this.closedCaseNumbers}).catch(error => {
                    resultDetail = {
                        isSuccess : false,
                        message : error
                    }
                });
                this.isLoading = false;
                resultDetail.message = resultDetail.message ? resultDetail.message.replace('\n', '\n') : resultDetail.message;
                this.dispatchEvent(new CustomEvent(
                    'resultdetailevent', 
                    {
                        detail: resultDetail,
                        bubbles: true,
                        composed: true,
                    }
                ));
            }
        }
    }
}