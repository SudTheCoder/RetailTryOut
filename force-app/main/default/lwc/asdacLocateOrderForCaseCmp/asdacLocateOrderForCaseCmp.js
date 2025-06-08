import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//ASDAC-2024 - ENDS
import ACCOUNT_EXT_ID from '@salesforce/schema/Case.Account.ExternalId__c';
import CONTACT_ID from '@salesforce/schema/Case.ContactId';
import CONTACT_REASON_LEVEL2 from '@salesforce/schema/Case.ContactReasonLevel2__c';

//ASDAC-2024 - STARTS
import ID_FIELD from '@salesforce/schema/Case.Id';
import ORDERID_FIELD from '@salesforce/schema/Case.OrderId__c';
import BUSINESS_AREA_FIELD from '@salesforce/schema/Case.BusinessArea__c';
import ORDER_FULFILLEDDATE_FIELD from '@salesforce/schema/Case.OrderFulfilledDate__c';
import getOrder from '@salesforce/apex/ASDAC_OrderController.getOrder';
//ASDAC-2024 - ENDS

import customerNotFound from '@salesforce/label/c.ASDAC_LinkOrderCustomerError';
import orderNotFound from '@salesforce/label/c.ASDAC_LinkOrderNotFoundError';
import ASDAC_OrderNotFoundLabel from '@salesforce/label/c.ASDAC_OrderNotFoundLabel';
import caseUpdatedSuccessToastMessage from '@salesforce/label/c.ASDAC_CaseUpdatedSuccessToastMessage';
import createRecordErrorToastTitle from '@salesforce/label/c.ASDAC_CreateRecordErrorToastTitle';
import successToastTitle from '@salesforce/label/c.ASDAC_SuccessToastTitle';
import errorToastTitle from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import linkOrderTitle from '@salesforce/label/c.ASDAC_LinkOrderTitle';
import enterOrderNumberLabel from '@salesforce/label/c.ASDAC_EnterOrderNumberLabel';
import searchOrderButtonLabel from '@salesforce/label/c.ASDAC_SearchOrderButtonLabel';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';
import contactReasonLevel2 from '@salesforce/label/c.ASDAC_ContactReasonLevel2Value';
import  getStoreId from "@salesforce/apex/ASDAC_OrderController.getStoreId";
import STORE_FIELD from '@salesforce/schema/Case.Store__c';
import invalidOrderFormatMessage from '@salesforce/label/c.ASDAC_invalidOrderFormatMessageGeorge';
import { CloseActionScreenEvent } from 'lightning/actions';
import 	hasDisableOrderNumberValidationPermission from '@salesforce/customPermission/ASDAC_DisableOrderNumberValidationPermission';

const fields = [ACCOUNT_EXT_ID, STORE_FIELD,ID_FIELD, ORDERID_FIELD, BUSINESS_AREA_FIELD, CONTACT_ID,CONTACT_REASON_LEVEL2];

export default class AsdacLocateOrderForCaseCmp extends NavigationMixin(LightningElement) {
	@track isLoading=true;
	@api recordId;
	caseRecord;
	customerId;
	@api valueInput;
	@track isError;
	contactId;
	businessArea;
	orderCustomerId;
	orderId;
	contactReason;
	label = {
		linkOrderTitle,
		enterOrderNumberLabel,
		searchOrderButtonLabel,
		cancelButtonLabel
	};

	@track isSearchDisabled=true;

	@wire(getRecord, { recordId: '$recordId', fields: fields })
	wiredAccount({ error, data }) {
		if (data) {
			this.caseRecord = data;
			this.customerId = getFieldValue(data, ACCOUNT_EXT_ID);
			this.contactId = getFieldValue(data,CONTACT_ID);
			this.contactReason = getFieldValue(data,CONTACT_REASON_LEVEL2);
			this.businessArea = getFieldValue(data, BUSINESS_AREA_FIELD)
			this.error = undefined;
			this.isLoading = false;
		} else if (error) {
			this.error = error;
			this.record = undefined;
		}
	}

	get isGeorge(){
		return this.businessArea === 'George';
	}

	get maxLengthGeorge(){
		return !hasDisableOrderNumberValidationPermission ? 10 : null;
	}

	get maxLengthGrocery(){
		return !hasDisableOrderNumberValidationPermission ? 14 : null;
	}
	
	handleOrderOnBlur(event){
		if(event.target.value === '' || event.target.value === null){
			event.target.setCustomValidity('');
			event.target.reportValidity();
			return;
		}
		
		if(hasDisableOrderNumberValidationPermission){
			this.isSearchDisabled = false;
		}
		else{
			const patternRegex = /^(B\d{9}|\d{9})$/;
			let isPatternValid = this.checkOrderIdValidity(event, patternRegex);
			if(isPatternValid){
				this.isSearchDisabled = false;
			}
		}
	}

	handleOrderOnChange(event){
		if(hasDisableOrderNumberValidationPermission){
			this.isSearchDisabled = false;
		}
		else{
			this.isSearchDisabled = true;
			let orderId = event.target.value;
			const nonAlphanumericRegex = /[^a-zA-Z0-9]/g;
		
            event.target.value = orderId.replace(nonAlphanumericRegex, '');

			const patternRegex = /^(?:B\d{0,9}|\d{0,9})$/;
			this.checkOrderIdValidity(event, patternRegex);
			if(/^(B\d{9}|\d{9})$/.test(event.target.value)){
				this.isSearchDisabled = false;
			}
			else{
				this.isSearchDisabled = true;
			}
		}
	}

	checkOrderIdValidity(event, regexPattern){
		let isPatternValid = regexPattern.test(event.target.value);
		if(!isPatternValid){
			event.target.setCustomValidity(invalidOrderFormatMessage);
			event.target.reportValidity();
			
			return false;
		}
			event.target.setCustomValidity('');
			event.target.reportValidity();
			return true;
	}

	handleOrderOnBlurGrocery(event){
		if(event.target.value === '' || event.target.value === null){
			event.target.setCustomValidity('');
			event.target.reportValidity();
			return;
		}
		
		if(hasDisableOrderNumberValidationPermission){
			this.isSearchDisabled = false;
		}
		else{
			const patternRegex = /^\d{13,14}$/;
			let isPatternValid = this.checkOrderIdValidity(event, patternRegex);
			if(isPatternValid){
				this.isSearchDisabled = false;
			}
		}
	}

	handleOrderOnChangeGrocery(event){
		if(hasDisableOrderNumberValidationPermission){
			this.isSearchDisabled = false;
		}
		else{
			this.isSearchDisabled = true;
			let orderId = event.target.value;
			const nonDigitRegex = /\D/g; 
            event.target.value = orderId.replace(nonDigitRegex, '');

			const patternRegex = /^\d{13,14}$/;
			let isPatternValid = patternRegex.test(event.target.value);
			if(isPatternValid){
				this.isSearchDisabled = false;
				event.target.setCustomValidity('');
				event.target.reportValidity();
			}
		}
	}

	isInputValid() {
		let isValid = true;
		let inputFields = this.template.querySelectorAll('lightning-input,lightning-radio-group');
		inputFields.forEach(inputField => {
			if (!inputField.checkValidity()) {
				inputField.reportValidity();
				isValid = false;
			}
		});
		return isValid;
	}

	async handleClick(event) {

		event.preventDefault();
		const { name } = event.target;
	
		if (name === 'cancel') {
			this.dispatchEvent(new CloseActionScreenEvent());
			return;
		}
		if (name === 'search') {
			await this.handleSearch();
		}
	}

	async handleSearch() {
		if (!this.isInputValid()) {
			return;
		}
		try
			{
			const orderId = this.template.querySelector('.orderId').value;
			this.orderId = orderId;
			const businessArea = this.businessArea;

			const result = await getOrder({orderId, businessArea});
			this.orderCustomerId =result.customerId;
			
			const storeNumber = result.storeNumber != '0' ? result.storeNumber : '0000';
			
			const storeId = await getStoreId({storeNumber});
			
			const fields = {};
			fields[ID_FIELD.fieldApiName] = this.recordId;
			fields[ORDERID_FIELD.fieldApiName] = orderId;
			fields[ORDER_FULFILLEDDATE_FIELD.fieldApiName] = (this.contactReason === contactReasonLevel2) ? result.orderFulfilledDate : "";
			fields[STORE_FIELD.fieldApiName] = storeId;

			const recordInput = { fields };
			if(this.contactId !== this.orderCustomerId)
				{
					throw new Error(customerNotFound);
				}

			this.updateCaseRecord(recordInput);
			
			}
			catch(error) {
				let errMessage = this.getErrorMessage(error);
				if(errMessage === ASDAC_OrderNotFoundLabel && this.orderId)
				{
					this.errorMessageToDisplay = orderNotFound;
					this.callToastError();
				}
				else if(this.orderId) {
					this.errorMessageToDisplay = errMessage || error.message;
					this.callToastError();
				}
				this.customers = null;
				this.loading = false;
			}
	}

	async updateCaseRecord(recordInput)
	{
		
		try {
			await updateRecord(recordInput);
			const event = new ShowToastEvent({
			variant: "Success",
			message: caseUpdatedSuccessToastMessage,
			title: successToastTitle
			});
			this.dispatchEvent(event);
			this.dispatchEvent(new CloseActionScreenEvent());

			} 
		catch (error) {
			const event = new ShowToastEvent({
				variant: "Error",
				message: error.body.message,
				title: createRecordErrorToastTitle
			});
			this.dispatchEvent(event);
			this.dispatchEvent(new CloseActionScreenEvent());

			}
	}
	callToastError()
	{
		const event = new ShowToastEvent({
			variant: "Error",
			message: this.errorMessageToDisplay,
			title: errorToastTitle
		});
		this.dispatchEvent(event);
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
}