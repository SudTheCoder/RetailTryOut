/**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 25/05/2023
* @description                  : ASDAC_7904 Rel C - GHS - GV - CCA UI API integration - View Customer's Voucher History

**********************************************************************************/

import { LightningElement, api,wire} from 'lwc';
import getWalletForGettingVouchers from '@salesforce/apex/ASDAC_GoodWillWalletIdentity.getWalletForGettingVouchers';
import getGoodwillVoucher from '@salesforce/apex/ASDAC_GoodWillVoucher.getGoodwillVoucher';
import doDisableVoucher from '@salesforce/apex/ASDAC_DisableGoodWillVoucher.doDisableVoucher';
import LightningConfirm from "lightning/confirm";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createContentNote from '@salesforce/apex/ASDAC_VouchersDetailsController.createContentNote';
import enterNotes from '@salesforce/label/c.ASDAC_EnterNotes';
import submitButtonLabel from '@salesforce/label/c.ASDAC_SubmitButtonLabel';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';
import voucherDisabledMessage from '@salesforce/label/c.ASDAC_GHSVoucherDisableSuccess';
import voucherDisableWarning from '@salesforce/label/c.ASDAC_GHSVoucherDisableWarning';
import notesLabel from '@salesforce/label/c.ASDAC_NotesLabel';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import ROLE_NAME from "@salesforce/schema/User.UserRole.Name";
import ELIGIBLE_ROLES from "@salesforce/label/c.ASDAC_RemoveVoucherEligibleRoles";
import ASDACNOTESERROR from '@salesforce/label/c.ASDAC_NotesError';


export default class AsdacGoodwillVoucherDetails extends LightningElement {
isRoleEligible; 
isNotesError = false;
COLUMNS;
label = {
	enterNotes,
	submitButtonLabel,
	cancelButtonLabel,
	notesLabel,
	ASDACNOTESERROR
};

@wire(getRecord, { recordId: USER_ID, fields: [ROLE_NAME] })
wiredUser({ error, data }) {
	if (error) {
		const event = new ShowToastEvent({
			title: "Error",
			variant: "error",
			message: error.message
		});
		this.dispatchEvent(event);
	} else if (data) { 
		this.isRoleEligible = ELIGIBLE_ROLES.includes(data.fields.UserRole.value?.fields.Name.value) ? true : false;
		if(this.isRoleEligible) {
			this.COLUMNS = this.VoucherGHS;
		}
		else {
			this.COLUMNS = this.VoucherGHS1;
		}
	}

}

VoucherGHS = [
	{ label: 'Type',   fieldName: 'clientType',  type: 'text' },
	{ label: 'Date of issue', fieldName: 'issueDate',  type: 'datetime' },
	{ label: 'Value',   fieldName: 'discountAmount',type: 'currency', cellAttributes: { alignment: 'left' }},
	{ label: 'Voucher id',fieldName:'voucherId', type: 'text'},
	{ label: 'Date of expiry', fieldName: 'expiryDate',  type: 'datetime' },
	{ label: 'Reason code',fieldName:'reasonCode', type: 'text'},
	{ label: 'Locked',fieldName:'locked', type: 'text'},
	{type: 'button-icon', 
		initialWidth: 50,
		typeAttributes: {
			iconName: 'utility:close',
			title: 'disable',
			variant: 'bare',
			alternativeText: 'disable',
			disabled: {fieldName: 'isRewardsVoucher'}
		}            
	}
	
];
VoucherGHS1 = [
	{ label: 'Type',   fieldName: 'clientType',  type: 'text' },
	{ label: 'Date of issue', fieldName: 'issueDate',  type: 'datetime' },
	{ label: 'Value',   fieldName: 'discountAmount',type: 'currency', cellAttributes: { alignment: 'left' }},
	{ label: 'Voucher id',fieldName:'voucherId', type: 'text'},
	{ label: 'Date of expiry', fieldName: 'expiryDate',  type: 'datetime' },
	{ label: 'Reason code',fieldName:'reasonCode', type: 'text'},
	{ label: 'Locked',fieldName:'locked', type: 'text'},
	
];

@api recordId;
walletId;
accountId;
responseData=[]; 
voucherResult;
showSecondModal = false;
notes = '';
rowToDelete = {};

async connectedCallback() {
	try {
		const data = await getWalletForGettingVouchers({ accId: this.recordId });
		this.walletId = data;
	} catch (error) {
		console.error(error);
	}
}

@wire(getGoodwillVoucher, {walletId: '$walletId'})
getVoucherData({ error, data }) {
	if (data) {
		this.responseData=data;
		
	} else if (error) {
		console.error(error);
	}
}


async handleDisableClick(event){
	const buttonClickEvent = new CustomEvent('buttonclick', {
		detail: {
			row: event.detail.row,
			message: voucherDisableWarning,
			variant: "Header", // headerless
			label: "Remove Evoucher" ,
			theme: "warning"
		}
	});

	const result = await LightningConfirm.open({
		message: buttonClickEvent.detail.message,
		variant: buttonClickEvent.detail.variant,
		label: buttonClickEvent.detail.label,
		theme : buttonClickEvent.detail.theme
	});

	//result is true if OK was clicked
	if (result) {
	   this.rowToDelete = buttonClickEvent.detail.row;
		this.showSecondModal = true;
	} else {
		//and false if cancel was clicked
		this.handleErrorAlertClick();
	}
}

//handling the errorClick if "CANCEL" was clicked
async handleErrorAlertClick() {
	this.showSecondModal = false;
}
resetNotes(){
	this.notes = '';
	this.isNotesError= false;
}

handleOnChange(event) {
	this.notes = event.target.value;
	this.isNotesError= false;
}

handleSecondModalOK() {
	if (this.notes.trim() === '') {
		this.isNotesError = true;
	} else {
		this.isNotesError = false;
		const content = `${this.notes} | 
		Amount: ${this.rowToDelete.discountAmount}`;
		createContentNote({ title: 'Evoucher Notes', content: content, recordId: this.recordId })
			.then(() => {
				this.doDisable(this.rowToDelete.voucherId);
				this.showSecondModal = false;
				this.notes = '';
			})
			.catch(error => {
				console.error(error);
			});
	}
}

handleSecondModalCancel() {
	this.showSecondModal = false;
	this.resetNotes();
}

doDisable(accountIds){
	doDisableVoucher({walletId:this.walletId, voucherId:accountIds})
		.then(result => {
		

			this.voucherResult = result;

			const index = this.responseData.findIndex(item => item.voucherId === accountIds);
		let arrayForSort =[];
			if (index !== -1) {
			arrayForSort = [...this.responseData]
			arrayForSort.splice(index, 1);
			this.responseData = arrayForSort;
			}

			this.showToast();
			return refreshApex(this.getVoucherData);

		})
		.catch(error => {
			console.error('Error:', error);
				let message;
		try {
			message = JSON.parse(error.body.message).message;
		} catch (e) {
			message = error.body.message;
		}
		const event = new ShowToastEvent({
		variant: "error",
		title: "Error",
		message
		});
		this.dispatchEvent(event);
		});
}

showToast(){
	const event = new ShowToastEvent({
		title: 'Success',
		message: voucherDisabledMessage,
		variant: 'success',
	})
	this.dispatchEvent(event);
}
}