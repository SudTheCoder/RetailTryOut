import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import manChargeReasonsLbl from "@salesforce/label/c.ASDAC_ManualChargeReasons";
import manRefundReasonsLbl from "@salesforce/label/c.ASDAC_ManualRefundReasons";

export default class AsdacManualCardTransactionCmp extends LightningElement {

	@track isDisplayPayCard;
	@api orderWrapper;
	@track xCtionTypeValue = 'Refund';
	@track isDisplayNewCard;
	@track chrgRfndReasons=[];
	@track paymentCards=[];
	@track isRefundReasonDisplayed = false;
	@track isChargeReasonDisplayed = false;

	get transactionTypes() {
		return [
			{ label: 'Refund', value: 'Refund' },
			{ label: 'Charge', value: 'Charge' },
		];
	}

	connectedCallback(){
		const refundReasonsList = manRefundReasonsLbl.split(',');
		for(const rfndReason of refundReasonsList){
			this.chrgRfndReasons = [...this.chrgRfndReasons, {label: rfndReason.trim(), value: rfndReason.trim()}];
		}

		for(const payMethod of this.orderWrapper.paymentMethods){
			let cardNumber = payMethod.paymentCardType + ' ' + payMethod.tokenizedCard;
			this.paymentCards = [...this.paymentCards, {label: cardNumber.trim(), value: payMethod.paymentMethodId}];
		}
	}

	getTransactionType(event){
		this.chrgRfndReasons = [];
		if(event.target.value === 'Refund'){
			this.isRefundReasonDisplayed = true;
			this.isChargeReasonDisplayed = false;
			const refundReasonsList = manRefundReasonsLbl.split(',');
			for(const rfndReason of refundReasonsList){
				this.chrgRfndReasons = [...this.chrgRfndReasons, {label: rfndReason.trim(), value: rfndReason.trim()}];
			}
		}else if(event.target.value === 'Charge'){
			this.isRefundReasonDisplayed = false;
			this.isChargeReasonDisplayed = true;
			const manChargeReasonsList = manChargeReasonsLbl.split(",");
			for(const chrgReason of manChargeReasonsList){
				this.chrgRfndReasons = [...this.chrgRfndReasons, {label: chrgReason.trim(), value: chrgReason.trim()}];
			}
		}
	}

	amtOnChange(event){
		let amt = event.target.value.replace(/\u00A3/g, '');
		event.target.value = amt;
	}

	checkAmtValidity(event){
		let amtField = this.template.querySelector('.oiAmountCls');
		// If Check to prevent 'e'(exponential) entries in the field.
		if(event.target.value && event.target.value.includes('e')){
			amtField.setCustomValidity('Enter a valid Amount');
			amtField.reportValidity();
			return;
		}
		let amt = event.target.value.replace(/\u00A3/g, '');
		
		if(isNaN(amt) || parseFloat(amt) <0){
			amtField.setCustomValidity('Enter a valid Amount');
			amtField.reportValidity();
		}
		else{
			amtField.setCustomValidity('');
			amtField.reportValidity();
			if(amt === null || amt === '' || amt === undefined){
				event.target.value= '';
			}
			else{
				event.target.value = this.orderWrapper.currencyISOCode + parseFloat(event.target.value).toFixed(2);
			}
		}
	}

	handleCancel(){
		this.dispatchEvent(new CustomEvent('closemodal'));
	}
	handleSubmit(){
		if(this.isInputValid()) {
			this.dispatchEvent(new CustomEvent('closemodal'));
			const toEvt = new ShowToastEvent({
				title: 'Success',
				variant: 'Success',
				message: 'Manual Card Transaction is successful!'
			});
			this.dispatchEvent(toEvt);
		}
	}

	isInputValid(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

		let amt = this.template.querySelector('.oiAmountCls');
		if(!amt.checkValidity()) {
			amt.reportValidity();
			isValid = false;
		}
		
        return isValid;
    }
}