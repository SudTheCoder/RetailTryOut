import { LightningElement, track, api, wire } from 'lwc';
import doManualRefundCallout from "@salesforce/apex/ASDAC_ManualRefundRequestController.doManualRefundCallout";
import getCustomerDefaultCard from "@salesforce/apex/ASDAC_ManualRefundRequestController.getCustomerDefaultCard";
import getManualRefundLimit from "@salesforce/apex/ASDAC_ManualRefundRequestController.getManualRefundLimit";
import georgeLabel from '@salesforce/label/c.ASDAC_GeorgeLabel';
import groceryLabel from '@salesforce/label/c.ASDAC_GroceryLabel';
import reasonCodeLabel from '@salesforce/label/c.ASDAC_ReasonCodeLabel';
import submitButtonLabel from '@salesforce/label/c.ASDAC_SubmitButtonLabel';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';
import notesLabel from '@salesforce/label/c.ASDAC_NotesLabel';
import businessAreaLabel from '@salesforce/label/c.ASDAC_Business_Area';
import emailAddressLabel from '@salesforce/label/c.ASDAC_EmailAddressLabel';
import fillRequiredFieldsMessage from '@salesforce/label/c.ASDAC_FillRequiredFieldsMessage';
import LightningConfirm from "lightning/confirm";
import { FlowNavigationNextEvent } from "lightning/flowSupport";
import mandatoryFieldError from '@salesforce/label/c.ASDAC_MandatoryFieldError';
import emailField from "@salesforce/schema/Account.PersonEmail";
import { getRecord } from "lightning/uiRecordApi";
import voucherAmountMismatchError from '@salesforce/label/c.ASDAC_VoucherAmountMismatchError';
import approvalLimitExceedMessage from '@salesforce/label/c.ASDAC_PartialRefundApprovalLimitExceedMessage';
import voucherMaxAmountMessage from '@salesforce/label/c.ASDAC_VoucherMaxAmountMessage';
import manualRefundAmountLabel from '@salesforce/label/c.ASDAC_ManualRefundAmountLabel';
import confirmManualRefundAmountLabel from '@salesforce/label/c.ASDAC_ConfirmManualRefundAmountLabel';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class AsdacManualRefundRequestCmp extends LightningElement {  
	@api recordId;
    @track isLoading=false;
    @track isModalOpen = true;
    @api notes = '';
    @track showError = false;
    @track amountClass = '';
    @track email;    
    @track hasError = false;
    @track defaultCardToken = '';
    @track errorMessage ='';
    @api manualRefundAmount;
    manualRefundAmountMaxLimit;
    @api reasonCode;
    @api businessArea;
    submitClicked = false;
    @api availableActions = [];
    isAmountValid = true;
    isReasonValid = true;
    isBusinessAreaValid = true;
    @api exitButtonClicked=false;
    @api hasTechnicalErrorOccurred = false;
    isLimitExceeded = false;
    @api transactionId;
    @api transactionStatus;
	@track methodType = 'Post'
    businessAreaOptions = [
        { label: georgeLabel, value: 'George' },
        { label: groceryLabel, value: 'Grocery' }
    ];

    reasonCodes = {
        'Grocery': [
            'Delivery Charge Refund',
            'Minimum Basket Spend Refund',
            'Customer Charged for Order not delivered, Goods not returned',
            'Customer Charged for Order not collected, RCNC Goods returned',
            'Customer Charged for Order not delivered, Goods returned',
            'Delivery Pass Refund',
            'Customer Overcharged, Bank Charges Incurred',
            'Refund of Carrier Bag Charge',
            'Technical Error when processing refund',
            'Refund Clothing Essential Refund'
        ],
        'George': [
            'Payment Card has expired or Cancelled',
            'Refund Incorrectly Processed',
            'System Issue unable to issue Goodwill',
            'System Issue unable to issue Refund'
        ]
    };


    label = {
        submitButtonLabel,
        cancelButtonLabel,
        notesLabel,
        businessAreaLabel,
        fillRequiredFieldsMessage,
        reasonCodeLabel,
        emailAddressLabel,
        voucherAmountMismatchError,
        approvalLimitExceedMessage,
        manualRefundAmountLabel,
        confirmManualRefundAmountLabel
    };

    get maxAmountMessage() {
        return voucherMaxAmountMessage + this.manualRefundAmountMaxLimit;
    }

    get reasonCodeOptions() {
        if(!this.businessArea){
            const businessAreas = Object.keys(this.reasonCodes);
            return this.reasonCodes[businessAreas[0]].concat(this.reasonCodes[businessAreas[1]]).map(reason => {
                return { label: reason, value: reason };
            });
        }
        return this.reasonCodes[this.businessArea].map(reason => {
            return { label: reason, value: reason };
        });
    }
    @wire(getManualRefundLimit)
    getManualRefundLimit({ error, data }) {
        if (data) {
            this.manualRefundAmountMaxLimit=data; 
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: emailField })
    wireEmail({ error, data }) {
        if (data) {
            this.email = data.fields.PersonEmail.value;
        } else if (error) {
            console.error(JSON.stringify(error));
        }
    }

    @wire(getCustomerDefaultCard,{ recordId: "$recordId"})
    wiredDefaultCard({ error, data }) {
        if (data) {            
            this.defaultCardToken = data;
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'No Default Card found for this customer to refund amount';
            this.showToast('Error', 'Failed to fetch default card token: ' + error.body.message, 'error'); // Show error toast
        } else {
            this.errorMessage = 'No Default Card found for this customer';
            this.showToast('Error', 'Failed to fetch default card', 'error'); // Show error toast
        }
        
    }

    get isManualRefundDisabled() {
        return this.submitClicked || this.defaultCardToken == null || this.defaultCardToken === '';
    }
    handleAmtChange(event) {
        let inputFld = event.target;
        let value =inputFld.value;
        if(parseFloat(value) <= 0){
            inputFld.setCustomValidity(`${inputFld.label} must be greater than 0.00`);
            return;
        }else if(isNaN(value) || !value) {
            inputFld.value = '';
            this.manualRefundAmount = null;
            return;
        }
        this.manualRefundAmount = parseFloat(value);
        inputFld.setCustomValidity('');
        this.validateAmount();
    }

    validateAmount(){
        const input = this.template.querySelector(".confirmAmount");
        let amount = this.template.querySelector(
            'lightning-input[data-name="amount"]'
            ).value;
        let confirmAmount = this.template.querySelector(
            'lightning-input[data-name="confirm amount"]'
            ).value;
        if(confirmAmount && amount && (Number(confirmAmount).toFixed(2) > 0.00) && (Number(amount).toFixed(2) > 0.00)) {
            if ((Number(amount).toFixed(2)) !== Number(confirmAmount).toFixed(2)) {
                input.setCustomValidity(' ');
                input.reportValidity();
                this.hasError = true;
            } else{
                this.hasError = false;
                input.setCustomValidity("");
                input.reportValidity();
            }       
        }
    }

    handleBusinessAreaChange(event) 
    {
        this.businessArea = event.target.value;
        this.reasonCode = '';
    }

    handleNotesChange(event) 
    {
        this.notes = event.target.value;
    }

    handleReasonCodeChange(event) {
        let inputFld = event.target;
        let value =inputFld.value;
        if(!value) {
            inputFld.value = '';
            this.reasonCode = null;
            return;
        }
        this.reasonCode = value;
        inputFld.setCustomValidity('');
    }

    validateBusinessAreaField(){
        let requiredMessage = mandatoryFieldError;
        [...this.template.querySelectorAll(".businessAreaCls")].forEach((input) => {
          if (
            input.value === undefined ||
            input.value === "" ||
            input.value === null
          ) {
            this.isBusinessAreaValid = false;
            input.setCustomValidity(requiredMessage);
            input.reportValidity();
          } else {
            this.isBusinessAreaValid = true;
          }
        });
    }

    validateReasonField() {
        let requiredMessage = mandatoryFieldError;
        [...this.template.querySelectorAll(".reasonCls")].forEach((input) => {
          if (
            input.value === undefined ||
            input.value === "" ||
            input.value === null
          ) {
            this.isReasonValid = false;
            input.setCustomValidity(requiredMessage);
            input.reportValidity();
          } else {
            this.isReasonValid = true;
          }
        });
    }

    validateAmountField() {
        let requiredMessage = mandatoryFieldError;
        [...this.template.querySelectorAll(".refundAmtCls")].forEach((input) => {
            if (
                input.value === undefined ||
                input.value === "" ||
                input.value === null
            ) {
                this.isAmountValid = false;
                input.setCustomValidity(requiredMessage);
                input.reportValidity();
            } else if(parseFloat(input.value) <= 0){
                this.isAmountValid = false;
                input.setCustomValidity(`${input.label} must be greater than 0.00`);
                input.reportValidity();
            }else {
                this.isAmountValid = true;
            }
        });
        [...this.template.querySelectorAll(".confirmAmount")].forEach((input) => {
            if (
                input.value === undefined ||
                input.value === "" ||
                input.value === null
            ) {
                this.isAmountValid = false;
                input.setCustomValidity(requiredMessage);
                input.reportValidity();
            } else if(input.value<=0.00){
                this.isAmountValid = false;
                input.setCustomValidity(`${input.label} must be greater than 0.00`);
                input.reportValidity();
            }else {
                this.isAmountValid = this.isAmountValid ? true : false;
            }
        });
        this.validateAmount();
    }

    async doManualRefundCalloutFn(){
        this.isLoading = true;
        try{
            let result = await doManualRefundCallout({stringifiedJSON:JSON.stringify({recordId: this.recordId, businessArea: this.businessArea, payoutAmount: parseFloat(this.manualRefundAmount), reasonCode: this.reasonCode, notes: this.notes, cardToken: this.defaultCardToken,methodType: this.methodType })});
            let response = JSON.parse(result);
            let responseData =null;
            if (response.isSuccess) {
                responseData = response.strData ? JSON.parse(response.strData) : null;
                this.transactionId = responseData.id;
                this.transactionStatus = responseData.status;
            } else {
                this.hasTechnicalErrorOccurred = true;
                this.showToast('Error', JSON.parse(response.strMessage).message, 'error');
            }
            this.isLoading = false;
        } catch(error){
            let message;
            try {
                message = JSON.parse(error.body.message).message;
            } catch (e) {
                message = error.body.message;
            }
            this.isLoading = false;
            this.hasTechnicalErrorOccurred = true;
            this.showToast('Error', message, 'error');
        }
    }

    async isManualRefundLimitExceededFn() {
        let manualRefundAmount = this.template.querySelector("[data-id='payout-amount']").value;
        try{
          let isAmountWithinLimit = (this.manualRefundAmountMaxLimit && (manualRefundAmount <= this.manualRefundAmountMaxLimit)) ? true : false;
          if (isAmountWithinLimit === false && manualRefundAmount !== undefined) {
            this.isLimitExceeded = true;
          } else {
            this.isLimitExceeded = false;
          }
        }
        catch (error){
          if(error.body && error.body.message){
            this.error = error.body.message;
    
          }
        }
    }

    handleCancel() {
        this.exitButtonClicked=true;
        if (this.availableActions.find((action) => action === "NEXT")) {
          const navigateNextEvent = new FlowNavigationNextEvent();
          this.dispatchEvent(navigateNextEvent);
      }
    }

    async handleSubmit(event) {
        this.submitClicked = true;
        event.preventDefault();
        this.validateBusinessAreaField();
        this.validateReasonField();
        this.validateAmountField();
        await this.isManualRefundLimitExceededFn();
        if (this.isBusinessAreaValid && this.isReasonValid && this.isAmountValid && !this.hasError && !this.isLimitExceeded) {
            const result = await LightningConfirm.open({
                message: "Are you sure you want to submit the refund?",
                variant: "headerless",
                label: "This is the aria-label value",
            // label value isn't visible in the headerless variant
            });
            if (result) {
                await this.doManualRefundCalloutFn();
                if (this.availableActions.find((action) => action === "NEXT")) {
                    const navigateNextEvent = new FlowNavigationNextEvent();
                    this.dispatchEvent(navigateNextEvent);
                }
            } else {
                this.submitClicked = true;
            }          
        }
        this.submitClicked = false;
    }
    // Method to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, // can be 'success', 'error', 'warning', or 'info'
            mode: 'dismissable' // 'dismissable' means the user can close the toast
        });
        this.dispatchEvent(evt); // Dispatch the event to show the toast
    }
}