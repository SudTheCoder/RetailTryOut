import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {getRecord,getFieldValue} from 'lightning/uiRecordApi';
import ContactReasonLevel1 from '@salesforce/schema/Case.ContactReasonLevel1__c';
import ContactReasonLevel2 from '@salesforce/schema/Case.ContactReasonLevel2__c';
import ContactReasonLevel3 from '@salesforce/schema/Case.ContactReasonLevel3__c';
import CONTACT_NAME_FIELD from '@salesforce/schema/Contact.Name';
import { subscribe, MessageContext } from 'lightning/messageService';
import recordTypeMessageChannel from '@salesforce/messageChannel/recordTypeMessageChannel__c';

const fields = [CONTACT_NAME_FIELD];

export default class AsdacContactReasonCaseDependentPicklistCmp extends LightningElement {

    @api caseRecTypeId;
    @api picklistLevel1Value;
    @api picklistLevel2Value;
    @api picklistLevel3Value;
    @api newLevel1Value;
    @api newLevel2Value;
    @api newLevel3Value;

    @track level1Options;
    @track level2Options;
    @track level3Options;
    @track valueLevel1;
    @track valueLevel2;
    @track valueLevel3;
    @track hasRendered = true;

    @api contactRecordId;
    @api isPicklistValid;

    @wire(getRecord, { recordId: '$contactRecordId', fields : fields})
    Contact;

    get contactName() {
        return getFieldValue(this.Contact.data, CONTACT_NAME_FIELD);
    }

    @wire(MessageContext)
    messageContext;
    subscription;

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, recordTypeMessageChannel, (detail) => {
            if (this.caseRecTypeId) {
                // Record type changed
                this.picklistLevel1Value = null;
                this.picklistLevel2Value = null;
                this.picklistLevel3Value = null;
            }
            this.caseRecTypeId = detail.value;
        });
    }

    @wire(getPicklistValues, { recordTypeId: '$caseRecTypeId', fieldApiName: ContactReasonLevel1 })
    level1FieldInfo({ data, error }) {
        if (data){
            this.level1Options = data.values;
        }
        else {
           this.error = error;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$caseRecTypeId', fieldApiName: ContactReasonLevel2 })
    level2FieldInfo({ data, error }) {
        if (data) {
            this.level2data = data;
            this.level2Options = data.values;

            let key = this.level2data.controllerValues[this.valueLevel1];
            this.level2Options = this.level2data.values.filter(opt => opt.validFor.includes(key));

        }
        this.error = error;
    }

    @wire(getPicklistValues, { recordTypeId: '$caseRecTypeId', fieldApiName: ContactReasonLevel3 })
    level3FieldInfo({ data, error }) {
        if (data) {
            this.level3data = data;
            this.level3Options = data.values;

            let key2 = this.level3data.controllerValues[this.valueLevel2];
            this.level3Options = this.level3data.values.filter(opt => opt.validFor.includes(key2));
        }
        this.error = error;
    }

    connectedCallback(){
        this.handleSubscribe();
        this.newLevel1Value = this.picklistLevel1Value;
        this.valueLevel1 = this.picklistLevel1Value;
        
        this.newLevel2Value = this.picklistLevel2Value;
        this.valueLevel2 = this.picklistLevel2Value;
        
        this.newLevel3Value = this.picklistLevel3Value;
        this.valueLevel3 = this.picklistLevel3Value;
    }

    handleLevel1Change(event) {
        let key = this.level2data.controllerValues[event.target.value];
        this.level2Options = this.level2data.values.filter(opt => opt.validFor.includes(key));

        this.newLevel1Value = event.target.value;
        this.picklistLevel1Value = event.target.value;
        this.picklistLevel2Value = null;
        this.picklistLevel3Value = null;
    }

    handleLevel2Change(event){
        let key = this.level3data.controllerValues[event.target.value];
        this.level3Options = this.level3data.values.filter(opt => opt.validFor.includes(key));
        
        this.newLevel2Value = event.target.value;
        this.picklistLevel2Value = event.target.value;
        this.picklistLevel3Value = null;
    }

    handleLevel3Change(event){
        this.newLevel3Value = event.target.value;
        this.picklistLevel3Value = event.target.value;
    }

    @api validate() {
        const isValid = this.level1Options.findIndex((opt) => (opt.value === this.picklistLevel1Value)) >= 0;
        
        this.isPicklistValid = isValid;
        return { isValid,  errorMessage: "" };
    }

    renderedCallback() {
       if(!this.isPicklistValid){
           this.template.querySelector('.level1').reportValidity();
       }
      }
    

}