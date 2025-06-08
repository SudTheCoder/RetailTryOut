import { LightningElement, track, api, wire } from 'lwc';
import doManualRefundCallout from "@salesforce/apex/ASDAC_ManualRefundRequestController.doManualRefundCallout";
import georgeLabel from '@salesforce/label/c.ASDAC_GeorgeLabel';
import groceryLabel from '@salesforce/label/c.ASDAC_GroceryLabel';
import createRecordErrorToastTitle from '@salesforce/label/c.ASDAC_CreateRecordErrorToastTitle';
import successToastTitle from '@salesforce/label/c.ASDAC_SuccessToastTitle';
import caseUpdatedSuccessToastMessage from '@salesforce/label/c.ASDAC_ManaulRefundPayoutStatusUpdatedToastMeaasge';
import caseUpdatedFailedToastMessage from '@salesforce/label/c.ASDAC_ManaulRefundPayoutStatusUpdatedFailedToastMeaasge';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import ID_FIELD from '@salesforce/schema/Case.Id';
import PAYOUT_STATUS from '@salesforce/schema/Case.PayoutStatus__c';
import CASE_CLOSED_REASON from '@salesforce/schema/Case.CaseClosedReason__c';
import CLICK_COUNT from '@salesforce/schema/Case.click_count__c';
import BUSINESS_AREA from '@salesforce/schema/Case.BusinessArea__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import WORK_QUEUE from '@salesforce/schema/Case.WorkQueue__c';
import PAYOUT_ID from '@salesforce/schema/Case.Payout_Id__c';
import OWNER_ID from '@salesforce/schema/Case.OwnerId';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
const fields = [PAYOUT_ID, ID_FIELD, PAYOUT_STATUS, CLICK_COUNT, CASE_STATUS, WORK_QUEUE, OWNER_ID, CASE_CLOSED_REASON, BUSINESS_AREA];
export default class AsdacGetManualRefundStatus extends LightningElement {
    @api recordId;
    @track parseresponse;
    @track clickcountIncrement;
    @track isLoading = false;
    @track queueMap = new Map();
    @track warningMessage = '';
    @track isButtonDisabled = false;
    @track methodType = 'Get'
    @api caseStatus;
    @track caseOwnerID;
    @track payoutID;
    @api caseQueueName;
    @api caseClosedReason;
    @track queueName;
    @track queueId;
    @track businessArea;
    @api groupID;
    @api hasTechnicalErrorOccurred = false;
    isLimitExceeded = false;
    @api transactionId;
    @api transactionStatus;

    @track clickCount = 0;
    businessAreaOptions = [
        { label: georgeLabel, value: 'George' },
        { label: groceryLabel, value: 'Grocery' }
    ];


    @wire(getRecord, { recordId: '$recordId', fields: fields })
    wiredAccount({ error, data }) {
        if (data) {
            this.caseRecord = data;
            this.clickCount = getFieldValue(data, CLICK_COUNT);
            this.businessArea = getFieldValue(data, BUSINESS_AREA);
            this.payoutID = getFieldValue(data, PAYOUT_ID);
            this.error = undefined;
            this.isLoading = false;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }

        this.clickcountIncrement = this.clickCount;
        if (this.clickcountIncrement >= 2) {
            this.isButtonDisabled = true;
            this.warningMessage = 'Already exceeded 2 attempts!';
        }
    }

    async handleClick(event) {

        event.preventDefault();
        const { name } = event.target;

        if (name === 'cancel') {
            this.dispatchEvent(new CloseActionScreenEvent());
            return;
        }

        if (name === 'getPayoutStatus') {


            this.clickcountIncrement = this.clickcountIncrement + 1;
            await this.doManualRefundCalloutFn(this.clickcountIncrement);
        }

    }
    async doManualRefundCalloutFn(clickcountIncrement) {
        this.isLoading = true;
        try {

            await doManualRefundCallout({ stringifiedJSON: JSON.stringify({ recordId: this.recordId, businessArea: this.businessArea, methodType: this.methodType, payoutID: this.payoutID }) })
                .then(result => {
                    this.parseresponse = JSON.parse(result)
                });
            
            let response = this.parseresponse;
            const fields = {};
           
            let responseData = null;
            if (response.isSuccess) {
                responseData = response.strData ? JSON.parse(response.strData) : null;

                this.transactionId = responseData.id;
                this.transactionStatus = responseData.status;

                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[PAYOUT_STATUS.fieldApiName] = this.transactionStatus;
                fields[CLICK_COUNT.fieldApiName] = clickcountIncrement;

                const recordInput = { fields };
                this.updateCaseRecord(recordInput);
            } else {
                this.hasTechnicalErrorOccurred = true;
                this.showToast('Error', JSON.parse(response.strMessage).message, 'error');
            }
            this.isLoading = false;

        } catch (error) {
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




    async updateCaseRecord(recordInput) {

        try {
            await updateRecord(recordInput);
            const event = new ShowToastEvent({
                variant: "Success",
                message:caseUpdatedSuccessToastMessage,
                title: successToastTitle
            });
            this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());

        }
        catch (error) {
            const event = new ShowToastEvent({
                variant: "Error",
                message:caseUpdatedFailedToastMessage,
                title: createRecordErrorToastTitle
            });
            this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());
            
        }
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, 
            mode: 'dismissable' 
        });
        this.dispatchEvent(evt); 
    }


}