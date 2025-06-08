import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {getRecord} from 'lightning/uiRecordApi';
const FIELDS = [
    'Case.ContactReasonLevel1__c',
    'Case.ContactReasonLevel2__c',
    'Case.ContactReasonLevel3__c',
    'Case.BusinessArea__c',
    'Case.Account.AddressLine1__pc',
    'Case.Account.AddressLine2__pc',
    'Case.Account.AddressLine3__pc',
    'Case.Account.City__pc',
    'Case.Account.Country__pc',
    'Case.Account.PostalCode__pc'
];

export default class AsdacCustomerSupportParentCmp extends LightningElement {
    @api recordId;
    @track contactReason1 = {};
    @track caseRecord;
    @wire(getRecord, {recordId: '$recordId', fields: FIELDS}) 
    wiredCase({error, data}) {
        if (error) {
            const event = new ShowToastEvent({
            title: "Error",
            variant: "error",
            message: error.message
            });
            this.dispatchEvent(event);
        } else if (data) {
            this.contactReason1 = {};
            this.caseRecord = {
                'BusinessArea__c' : data.fields.BusinessArea__c.value,
                'ContactReasonLevel1__c' : data.fields.ContactReasonLevel1__c.value,
                'ContactReasonLevel2__c' : data.fields.ContactReasonLevel2__c.value,
                'ContactReasonLevel3__c' : data.fields.ContactReasonLevel3__c.value
            }
            if(data.fields.Account.value) {
                this.populateAddressFields(data.fields.Account.value.fields)
            }
            if(this.caseRecord.ContactReasonLevel1__c === 'Product & Technical Support') {
                this.contactReason1.isPTS = true;
            }
            else if(this.caseRecord.ContactReasonLevel1__c === 'Order Management') {
                this.contactReason1.isOM = true;
            }
            else if(this.caseRecord.ContactReasonLevel1__c === 'Payment & Refunds') {
                this.contactReason1.isPR = true;
            }
        }
    }

    populateAddressFields(accountAddressObj) {
        this.caseRecord.customerAddress = (accountAddressObj.AddressLine1__pc.value ? accountAddressObj.AddressLine1__pc.value + ', ' : '') +
                                          (accountAddressObj.AddressLine2__pc.value ? accountAddressObj.AddressLine1__pc.value + ', ': '') +
                                          (accountAddressObj.AddressLine3__pc.value ? accountAddressObj.AddressLine3__pc.value + ', ': '') +
                                          (accountAddressObj.City__pc.value ? accountAddressObj.City__pc.value + ', ': '') +
                                          (accountAddressObj.Country__pc.value ? accountAddressObj.Country__pc.value + ', ' : '') +
                                          (accountAddressObj.PostalCode__pc.value ? accountAddressObj.PostalCode__pc.value : '');
    }
}