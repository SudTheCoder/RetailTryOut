import { LightningElement, wire, track } from 'lwc';
import Please_Provide_Search_Inputs from "@salesforce/label/c.Please_Provide_Search_Inputs";
import Customers_Not_Found from "@salesforce/label/c.Customers_Not_Found";
import OrderNumberHelp from "@salesforce/label/c.ASDAC_OrderNumberHelp";
import OrderNumberHelpGrocery from "@salesforce/label/c.ASDAC_OrderNumberHelpGrocery";
import ELIGIBLE_PROFILES from "@salesforce/label/c.ASDAC_CreateNewCustomerEligibleProfiles";
import PI_HASH_SEARCH_ERROR from "@salesforce/label/c.ASDAC_PiHashSearchError";
import hasGHSAccess from '@salesforce/customPermission/ASDAC_GHSAccessPermission';
import { publish, MessageContext, subscribe, APPLICATION_SCOPE, createMessageContext } from 'lightning/messageService';
import consoleMessageChannel from '@salesforce/messageChannel/consoleMessageChannel__c';
import dataMessageChannel from '@salesforce/messageChannel/dataMessageChannel__c';
import Please_Select_An_Order_Type from "@salesforce/label/c.ASDAC_SelectOrderType";
import ASDAC_SEARCH from "@salesforce/label/c.ASDAC_Search";
import ASDAC_ORDER_NUMBER from "@salesforce/label/c.ASDAC_WebformGeorgeRefundOrderId";
import ASDAC_PIHASH from "@salesforce/label/c.ASDAC_PIHash";
import ASDAC_FORMAT_ERROR_MSG from "@salesforce/label/c.ASDAC_FormatErrorMsg";
import ASDAC_DESCRIPTION from "@salesforce/label/c.ASDAC_DescriptionError";
import ASDAC_ERROR_TITLE from "@salesforce/label/c.ASDAC_ErrorToastTitle";
import ASDAC_CLOSE from "@salesforce/label/c.ASDAC_Close";
import ASDAC_CLEAR from "@salesforce/label/c.ASDAC_Clear";
import ASDAC_CARD_MSG from "@salesforce/label/c.ASDAC_CardMsg";
import ASDAC_ORDER_TYPE from "@salesforce/label/c.ASDAC_Order_Type";
import ASDAC_ORDER_SEARCH_ALERT from "@salesforce/label/c.ASDAC_OrderSearchAlert";
import ASDAC_ORDER_FORMAT from "@salesforce/label/c.ASDAC_invalidOrderFormatMessageGeorge";
import 	hasDisableOrderNumberValidationPermission from '@salesforce/customPermission/ASDAC_DisableOrderNumberValidationPermission';
import getOrder from '@salesforce/apex/ASDAC_OrderController.getOrder';

export default class AsdacOrderSearchCmp extends LightningElement {
	encCardPassed = true;
    label = {
		Customers_Not_Found,
		Please_Provide_Search_Inputs,
		ELIGIBLE_PROFILES,
		Please_Select_An_Order_Type,
		PI_HASH_SEARCH_ERROR,
		ASDAC_SEARCH,
		ASDAC_ORDER_NUMBER,
		ASDAC_PIHASH,
		ASDAC_FORMAT_ERROR_MSG,
		ASDAC_DESCRIPTION,
		ASDAC_ERROR_TITLE,
		ASDAC_CLOSE,
		ASDAC_CLEAR,
		ASDAC_CARD_MSG,
		ASDAC_ORDER_TYPE,
		ASDAC_ORDER_SEARCH_ALERT
	};
	subscription = null;
	typeOfOrder="";
	isOrderTypeSelected=false;
	isOrderNumber= true;
	isGeorge= false;
	OrderNumberHelpText;
	maxLength;

    @wire(MessageContext)
    messageContext;
	@track responseJSON = '';
	@track isError = false;
	@track errorMessageToDisplay='';
	isSearchDisabled = true;
	showSpinner = false;

	connectedCallback(){
		this.handleSubscribe();
	}

	get options() {
		if(hasGHSAccess){
			return [
				{ label: 'George', value: 'George' },
				{ label: 'Grocery', value: 'GHS' },
			];
		}else{
			return [
				{ label: 'George', value: 'George' }
			];
		}        
    }
	
	handleOptionChange(event) {
		this.isOrderNumber= false;
		this.isSearchDisabled = true;
        this.typeOfOrder = event.target.value;
		if(this.typeOfOrder === 'George'){
            this.isGeorge=true;
			this.OrderNumberHelpText = OrderNumberHelp;
			this.maxLength = 9;
		}
		else{
			this.isGeorge=false;
			this.OrderNumberHelpText = OrderNumberHelpGrocery;
			this.maxLength = 14;
		}
		if(hasDisableOrderNumberValidationPermission){
			this.OrderNumberHelpText = '';
			this.maxLength = null;
		}
    }
	
	handleSearchForOrder(event) {
		event.preventDefault();
		if (this.encCardPassed) {
			let orderIdTempValue = this.template.querySelector("lightning-input[data-order-field=Order_Id]").value.trim();
			const radioGroupOrderType = this.template.querySelector('lightning-radio-group');
			if (!radioGroupOrderType.value) {
				this.isError = true;
				this.errorMessageToDisplay = this.label.Please_Select_An_Order_Type;
				return;
			}
			if (!orderIdTempValue) {
				this.isError = true;
				this.errorMessageToDisplay = this.label.Please_Provide_Search_Inputs;
				return;
			}
			if (orderIdTempValue) {
				this.showSpinner = true;
				const orderId = orderIdTempValue;
				const businessArea = radioGroupOrderType.value;

				this.dispatchEvent(new CustomEvent('openorderdetail', {
					bubbles: true , 
					composed : true, 
					detail: {
						uid: orderId,
						c__businessArea: businessArea,
						c__searched: true
					}
				}));
				this.showSpinner = false;
				this.loading = false;
				const closeUtility = new CustomEvent("minimizetab", {bubbles: true , composed : true});
				this.dispatchEvent(closeUtility);

			}
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


	handleSubscribe() { 
        if (this.subscription) {
            return;
        }
        this.context = createMessageContext();
        this.subscription = subscribe(this.context, dataMessageChannel, (message) => {
            this.handleMessage(message);
        }, {scope: APPLICATION_SCOPE});
    }
 
    handleMessage(event) {
        if (event) {
            let message = event.message;
			if(message.isCalled){
				const payload = { data : {
					response: this.responseJSON
				}};
				publish(this.messageContext, consoleMessageChannel, payload);
			}
        }
    }

	get subscribeStatus() {
        return this.subscription ? 'TRUE' : 'FALSE';
    }

    handleClearOrder() {
		this.isOrderNumber= true;
		this.isSearchDisabled = true;
		this.OrderNumberHelpText='';
		const radioGroup = this.template.querySelector('lightning-radio-group');
		radioGroup.value = null;	
		[...this.template.querySelectorAll(".orderInCls")].forEach((input) => {
			input.value = null;
            input.setCustomValidity('');
			input.reportValidity();
		});
        this.encCardPassed = true;
		this.closeError();
	}

	handleEnter(event){
		if(event.keyCode === 13){
			this.handleSearchForOrder(event);
		}
	}

	closeError() {
        this.errorMessageToDisplay = '';
		this.isError = false;
    }

	handleChange(event) {
        let orderNumber = event.target.value;
		if(hasDisableOrderNumberValidationPermission){
			this.isSearchDisabled = false;
		}
		else if(this.typeOfOrder === 'George'){
			this.validateOrderNumber();
		}		
        if(!orderNumber || orderNumber.length === 0)
        {
			this.isSearchDisabled = true;
            this.closeError();
			event.target.setCustomValidity('');
			event.target.reportValidity();
        }
    }

	validateOrderNumber() {
		let element = this.template.querySelector("lightning-input[data-order-field=Order_Id]");
		if (element.name === 'Order_Id') {
			let orderIdValue = element.value?.trim();
			this.maxLength = orderIdValue.startsWith('Y') ? 10 : 9;
			if (orderIdValue && this.typeOfOrder === 'George') {
				let message = '';
				if (!(/^(Y?\d{0,9}|\d{9})$/.test(orderIdValue))) {
					message = ASDAC_ORDER_FORMAT;
					this.isSearchDisabled = true;
				} else if ((/^(Y?\d{0,9})$/.test(orderIdValue)) && orderIdValue.length === 10) {
					this.isSearchDisabled = false;
				} else if ((/^(\d{9})$/.test(orderIdValue)) && orderIdValue.length === 9) {
					this.isSearchDisabled = false;
				} else{
					this.isSearchDisabled = true;
				}	
				element.setCustomValidity(message);
				element.reportValidity();
			}
		}
	}
	

	checkOrderIdValidity(event, regexPattern){
		let isPatternValid = regexPattern.test(event.target.value);
		if(!isPatternValid){
			event.target.setCustomValidity(ASDAC_ORDER_FORMAT);
			event.target.reportValidity();
			
			return false;
		}
			event.target.setCustomValidity('');
			event.target.reportValidity();
			return true;
	}

	handleOrderGroceryOnBlur(event){
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

	handleOrderGroceryOnChange(event){
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

}