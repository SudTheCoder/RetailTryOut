import { LightningElement,track,api } from 'lwc';
import { FlowNavigationNextEvent,FlowNavigationFinishEvent } from 'lightning/flowSupport';
import createRefundOverrideRequest from "@salesforce/apex/ASDAC_OrderController.createRefundOverrideRequest";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import successMessage from '@salesforce/label/c.ASDAC_RefundOverrideSuccessMessage';

export default class AsdacOverrideModalCmp extends LightningElement {

    @track isLoading = true;
    @track orderWrapper;
    @api exitButtonClicked = false;
    @api availableActions=[];
    @api refundToCreateStr;
    @api orderWrapperFromFlow;
    @track requiredNotesMessage = 'Notes is required.';
    @track notes;
    @track orderItems = [];

    connectedCallback(){
        this.isLoading = false;
        this.orderWrapper = JSON.parse(this.orderWrapperFromFlow);
    }

    resolveValidityIssues(reasonValue, targetInput) {
        if (reasonValue !== undefined || reasonValue !== '' || reasonValue !== null) {
            targetInput.setCustomValidity('');
            targetInput.reportValidity();
        }
    }

    handleNoteChange(event) {
        this.resolveValidityIssues(event.target.value, event.target);
    }

    handleCancel() {
        this.exitButtonClicked = true;
    }

    checkValidityOnSubmit(componentClass, message){
        let isValid = true;
        [...this.template.querySelectorAll(componentClass)].forEach((input) => {
			if(input.value === undefined || input.value === '' || input.value === null){
				isValid = false;
				input.setCustomValidity(message);
				input.reportValidity();
			}
		});
        return isValid;
    }

    handleSubmit() {
        let isNoteValid = this.checkValidityOnSubmit(".oiNotesCls", this.requiredNotesMessage);
        if(isNoteValid){
            const note = this.template.querySelector(".oiNotesCls");
            this.orderWrapper.orderLines = this.orderWrapper.orderLines.map(ordItm => ({ ...ordItm, notes: note.value.toString() }));
            this.refundToCreateStr = JSON.stringify( this.orderWrapper.orderLines);
            createRefundOverrideRequest({ order: this.orderWrapper })
                .then((createData) => {
                    this.displayToastMessage("Success","success", successMessage);
                    this.isLoading = false;
                    if(this.availableActions.find((action) => action === 'NEXT')){
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
                    }
                    else if (this.availableActions.find((action) => action === 'FINISH')) {
                        const navigateFinishEvent = new FlowNavigationFinishEvent();
                        this.dispatchEvent(navigateFinishEvent);
                    }
                })
                .catch((err) => {
                    const error = this.getError(err);
                    console.error('error--------'+JSON.stringify(error));
                    this.displayToastMessage("Error","error", this.getErrorMessage(err));
                    
                    this.isLoading = false;
                });
        }
    }

    getError(err) {
        let error = err;
        if (err.body) {
            try {
                error = JSON.parse(err.body.message);
            } catch(e) {
                error = err.body;
            }
        }
        return error;
    }

    getErrorMessage(err) {
        return this.getError(err).message;
    }

    displayToastMessage(title, variant, message){
        const toEvt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(toEvt);
    }


}