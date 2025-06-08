import { LightningElement, track, api } from 'lwc';
import {FlowNavigationNextEvent,FlowNavigationFinishEvent} from 'lightning/flowSupport';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import refundTypeLbl from '@salesforce/label/c.ASDAC_ShippingFeeRefundType';
import refundReasonLbl from '@salesforce/label/c.ASDAC_ShippingFeeRefundReason';
import deliveryChargeRefundOrder from "@salesforce/apex/ASDAC_OrderController.deliveryChargeRefundOrder";

export default class AsdacShippingFeeRefundModalCmp extends LightningElement {

    @api exitButtonClicked=false;
    @api orderWrapperFromFlow;
    @api caseRecordId;
    @track isLoading = true;
    @track refundTypes=[];
    @track refundReasons=[];
    @track poundSymbol = '£';
    @api availableActions = [];
    @track isAmountDisabled =  true;
    @track orderWrapper;
    @track shippingFee;
    @track orderTotal;
    @track currentDeliveryCharge;
    selectedValue = 'Cash';
    isRefundTypeDisabled=true;

    connectedCallback(){
        const refundReasonsList = refundReasonLbl.split(',');
        const refundTypeList = refundTypeLbl.split(',');
       for(const reReason of refundReasonsList){
			this.refundReasons = [...this.refundReasons, {label: reReason.trim(), value: reReason.trim()}];
		}
       for(const reType of refundTypeList){
			this.refundTypes = [...this.refundTypes, {label: reType.trim(), value: reType.trim()}];
		}

       this.orderWrapper = JSON.parse(this.orderWrapperFromFlow);
       this.currentDeliveryCharge = this.orderWrapper.currentDeliveryCharge ? this.orderWrapper.currentDeliveryCharge.toFixed(2) : 0.00;
       this.shippingFee = this.orderWrapper.shippingFee;
       this.orderTotal = this.orderWrapper.totalAmount;
       this.isLoading = false;
    }

    handleTypeChange(event){
        this.resolveValidityIssues(event.target.value, event.target);
      
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

    handleAmountChange(event){
        let requiredMessage = 'Invalid Amount';
        let amt = event.target.value.replace(/[^\d.]/g, '');
        if(isNaN(event.target.value.replace(/\u00A3/g, ''))){
                event.target.setCustomValidity(requiredMessage);
                event.target.reportValidity();
        }
        else if((parseFloat(amt) > parseFloat(event.target.dataset.totalfee))){
                event.target.setCustomValidity('Amount cannot exceed delivery charge amount');
                event.target.reportValidity();
        }
        else{
                event.target.setCustomValidity('');
                event.target.reportValidity();
        }
    }

    resolveValidityIssues(reasonValue, targetInput){
		if(reasonValue !== undefined || reasonValue !== '' || reasonValue !== null){
			targetInput.setCustomValidity('');
			targetInput.reportValidity();
		}
	}
    handleReasonChange(event){
		this.resolveValidityIssues(event.target.value, event.target);
	}

    handleNotesChange(event){
		this.resolveValidityIssues(event.target.value, event.target);
	}

    handleCancel(){
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

    @track refundToCreate = [];
    @api refundToCreateStr;
    @api totalRefundForFlow;
    handleSubmit(){
		let isReasonValid = true;
		let requiredReasonMessage = 'Reason is required.';
        let requiredNotesMessage = 'Notes is required.';
        let requiredTypeMessage = 'Select a Refund Type';
        let isNotesValid = true;
        let isAmtValid = true;
        let isTypeValid = true;

        let reason = this.template.querySelector(".oiReasonCls");
        let notes = this.template.querySelector(".oiNotesCls");
        let amount = this.template.querySelector(".oiAmountCls");
        let type = this.template.querySelector(".oiTypeCls");

        if(notes.value === undefined || notes.value === '' || notes.value === null || notes.value.trim() === ''){
            isNotesValid = false;
            notes.setCustomValidity(requiredNotesMessage);
            notes.reportValidity();
        }

        if(type.value === undefined || type.value === '' || type.value === null){
            isTypeValid = false;
            type.setCustomValidity(requiredTypeMessage);
            type.reportValidity();
            
        }

        if(reason.value === undefined || reason.value === '' || reason.value === null){
            isReasonValid = false;
            reason.setCustomValidity(requiredReasonMessage);
            reason.reportValidity();
        } 
        let amt =amount.value;
        if(!amount.value){
            amt = 0.00;
        }
        if((parseFloat(amt) > parseFloat(amount.dataset.totalfee)) || isNaN(amount.value)){
            isAmtValid = false;
        }


		if(isReasonValid && isNotesValid && isAmtValid && isTypeValid){
            
            let refundReqRec={
                refundType : type.value.toString(),
                notes : notes.value.toString(),
                refundReason : reason.value.toString(),
                refundAmount : amount.value.toString().replace(/\u00A3/g, ''),
                orderId : this.orderWrapper.orderId,
                lineTotal : this.orderWrapper.shippingFee
            }
            this.refundToCreate.push(refundReqRec);
            this.refundToCreateStr = JSON.stringify(this.refundToCreate);
            this.totalRefundForFlow = parseFloat(amount.value);
            this.totalRefundForFlow = this.totalRefundForFlow.toFixed(2);

            const orderItems = JSON.parse(this.orderWrapperFromFlow);
            const sellingChannel = orderItems.sellingChannel;
            const orderId = orderItems.orderId;
            const order = {sellingChannel: sellingChannel, orderId: orderId, discount: amount.value, reason:reason.value, notes:notes.value, orderLines: orderItems.orderItems};
            deliveryChargeRefundOrder({ order })
                            .then(() => {
                            this.isLoading = false;
                            this.finishNextEventFlow();
                            })
                            .catch((err) => {
                            let deliveryMessage;
                            try {
                                deliveryMessage = JSON.parse(err.body.message).message;
                            } catch (e) {
                                deliveryMessage = err.body.message;
                            }
                            const event = new ShowToastEvent({
                                variant: "error",
                                title: "Error",
                                message: deliveryMessage
                            });
                            this.dispatchEvent(event);
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

}