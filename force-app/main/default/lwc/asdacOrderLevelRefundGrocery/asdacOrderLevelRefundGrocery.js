import { LightningElement, api, track } from 'lwc';
import GHSOrderLevelRefundOptionsLbl from '@salesforce/label/c.ASDAC_GHSOrderLevelRefundOptions';
import createWholeOrderRefundRequest from "@salesforce/apex/ASDAC_OrderController.createWholeOrderRefundRequest";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {FlowNavigationNextEvent,FlowNavigationFinishEvent} from 'lightning/flowSupport';

export default class AsdacOrderLevelRefundGrocery extends LightningElement {

    @track orderWrapper;
    @api exitButtonClicked=false;
    @api orderWrapperFromFlow;
    @api caseRecordId;
    @api refundToCreateStr;
    @api availableActions = [];
    @track isSubmitDisabeld = true;
    @track refundReasons=[];
    refundAmount;
    @track order;
    @track isLoading = true;
    @track requiredReasonMessage = 'Reason is required.';
    @track requiredNotesMessage = 'Notes is required.';
    @track amountDisabled = true;
    @track refundToCreate = [];
    @api totalRefundForFlow;
    poundSymbol = '£';

    connectedCallback(){
        this.orderWrapper = JSON.parse(this.orderWrapperFromFlow);
        const GHSRefundOptions = GHSOrderLevelRefundOptionsLbl.split(',');
        for(const reReason of GHSRefundOptions){
            this.refundReasons = [...this.refundReasons, {label: reReason.trim(), value: reReason.trim()}];
        }

        this.order = {...this.orderWrapper, orderLines:[]};
        this.order.orderLines= this.order.orderItems.filter(item => item.isGhsRefundDisabled === false);
       
          this.order.orderLines = this.order.orderLines.map(orderLine => ({
            ...orderLine,
            reason: '',
            notes: ''
          }));
          
          this.isLoading = false;
    }

    get placeHolderValue(){
        return `${(parseFloat(0, 10)/100).toFixed(2)}`;
    }

    handleCloseModal(){
        this.exitButtonClicked=true;
        if (this.availableActions.find((action) => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            }
    
        else if(this.availableActions.find((action) => action === 'FINISH')){
            const navigateFinishEvent = new FlowNavigationFinishEvent();
                this.dispatchEvent(navigateFinishEvent);
        }    
	}

    amountOnChange(event){
        let inputFld = event.target;
        let value = parseFloat(inputFld.value.replace('.',''), 10);
        if(isNaN(value) || !value) {
        inputFld.value = '';
        return;
        } 
        inputFld.value = `${(parseFloat(value, 10)/100).toFixed(2)}`;

    }

    resolveValidityIssues(reasonValue, targetInput){
		if(reasonValue){
			targetInput.setCustomValidity('');
			targetInput.reportValidity();
		}
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

    handleReasonChange(event){
        if(this.amountDisabled){
            this.refundAmount = this.orderWrapper.totalAmount ;
            this.isSubmitDisabeld = this.refundAmount <= 0;
        }

		this.resolveValidityIssues(event.detail.value, event.target);
	}

    handleNotesChange(event){
		this.resolveValidityIssues(event.target.value, event.target);
	}

    handleAmountChange(event){
        let requiredMessage = 'Invalid Amount';
        this.refundAmount = event.target.value.replace(/[^\d.]/g, '');
        if(isNaN(event.target.value.replace(/\u00A3/g, '')) || parseFloat(this.refundAmount) > parseFloat(this.orderWrapper.totalAmount)){
                event.target.setCustomValidity(requiredMessage);
                event.target.reportValidity();
                this.isSubmitDisabeld = true;
        }
        else if(this.refundAmount > 0){
                this.isSubmitDisabeld = false;
                event.target.setCustomValidity('');
                event.target.reportValidity();
        }else if(this.refundAmount === 0){
            this.isSubmitDisabeld = true;
        }else{
                this.isSubmitDisabeld = true;
                event.target.setCustomValidity('');
                event.target.reportValidity();
        }
    }

    handleSubmit(event){
        let isReasonValid = this.checkValidityOnSubmit(".oiReasonCls", this.requiredReasonMessage);
        let isNotesValid = this.checkValidityOnSubmit(".oiNotesCls", this.requiredNotesMessage);
        if(isReasonValid && isNotesValid){
            let note = this.template.querySelector(".oiNotesCls").value;
            let refundReason = this.template.querySelector(".oiReasonCls").value;
            let amount = this.template.querySelector(".oiAmountCls");
            let refundReqRec={
                notes : note.toString(),
                refundReason : refundReason.toString(),
                orderId : this.orderWrapper.orderId,
            }
            this.refundToCreate.push(refundReqRec);
            this.refundToCreateStr = JSON.stringify(this.refundToCreate);
            this.totalRefundForFlow = this.poundSymbol +amount.value;
            this.order.reason = refundReason;
            this.order.notes = note;
            this.order.orderLines = this.order.orderLines.map(obj => {
                return {...obj, reason: refundReason, notes: note };
            });
            createWholeOrderRefundRequest({ order: this.order })
            .then((data)=>{
                this.isLoading = false;
                this.finishNextEventFlow();
            })
            .catch((err) => {
                const error = this.getError(err);
                this.displayToastMessage("Error","error", error.message);
                if (error.isTimeout) {
                    this.handleTimeout({ isGhsRefundDisabled: true });
                }
                this.isLoading = false;
            });
        }
    }

    finishNextEventFlow(){
        if (this.availableActions.find((action) => action === 'FINISH')) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
            }
            
        else if(this.availableActions.find((action) => action === 'NEXT')){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    displayToastMessage(title, variant, message){
        const toEvt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(toEvt);
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

    handleTimeout(timeout = {}) {
        this.handleCloseModal();
        const timeoutEvent = new CustomEvent("timeout", {
            bubbles: true,
            composed: true,
            detail: timeout
        });
        this.dispatchEvent(timeoutEvent);
    }
}