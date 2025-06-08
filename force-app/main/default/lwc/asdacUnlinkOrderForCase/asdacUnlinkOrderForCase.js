import { LightningElement,api, wire, track  } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import caseUpdatedSuccessToastMessage from '@salesforce/label/c.ASDAC_CaseUpdatedSuccessToastMessage';
import createRecordErrorToastTitle from '@salesforce/label/c.ASDAC_CreateRecordErrorToastTitle';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ACCOUNT_EXT_ID from '@salesforce/schema/Case.Account.ExternalId__c';
import CONTACT_ID from '@salesforce/schema/Case.ContactId';
import CONTACT_REASON_LEVEL2 from '@salesforce/schema/Case.ContactReasonLevel2__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import ORDERID_FIELD from '@salesforce/schema/Case.OrderId__c';
import BUSINESS_AREA_FIELD from '@salesforce/schema/Case.BusinessArea__c';
import ORDER_FULFILLEDDATE_FIELD from '@salesforce/schema/Case.OrderFulfilledDate__c';
import { CloseActionScreenEvent } from 'lightning/actions';



import successToastTitle from '@salesforce/label/c.ASDAC_SuccessToastTitle';

import STORE_FIELD from '@salesforce/schema/Case.Store__c';

const fields = [ACCOUNT_EXT_ID, STORE_FIELD,ID_FIELD, ORDERID_FIELD, BUSINESS_AREA_FIELD, CONTACT_ID,CONTACT_REASON_LEVEL2];

export default class AsdacUnlinkOrderForCase extends LightningElement {
    //@track isLoading=true;
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
    

    @wire(getRecord, { recordId: '$recordId', fields: fields })
	wiredAccount({ error, data }) {
		if (data) {
			this.caseRecord = data;
			this.orderId = getFieldValue(data, ORDERID_FIELD);
            console.log(order+this.orderId);
            this.error = undefined;
			this.isLoading = false;
		} else if (error) {
			this.error = error;
			this.record = undefined;
		}
	}
    
    async handleClick(event) {
    
            event.preventDefault();
            const { name } = event.target;
	
		if (name === 'cancel') {
			this.dispatchEvent(new CloseActionScreenEvent());
			return;
		}
		if (name === 'unlinkOrder') {
			await this.unlickOrder();
		}

          }
        async unlickOrder() {
           
            try
                {
           
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[ORDERID_FIELD.fieldApiName] ="";
                fields[ORDER_FULFILLEDDATE_FIELD.fieldApiName] ="";
                fields[STORE_FIELD.fieldApiName] = "";
             const recordInput = { fields };
              this.updateCaseRecord(recordInput);
			 }
                catch(error) {
                    let errMessage = this.getErrorMessage(error);
                  
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
	
    getErrorMessage(err) {
        return this.getError(err).message;
    }
        
    

}