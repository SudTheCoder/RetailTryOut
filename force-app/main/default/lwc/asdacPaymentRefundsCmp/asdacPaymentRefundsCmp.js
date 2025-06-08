import { LightningElement, api, track} from 'lwc';

export default class AsdacPaymentRefundsCmp extends LightningElement {
    @track caseRecord = {};
    @track panelRenderObj = {};

    @api 
    get caseRecordSetter() {
        return this.caseRecord;
    }

    set caseRecordSetter(value) {
        this.caseRecord = value;
        this.panelRenderObj = {};
        if(this.caseRecord.BusinessArea__c) {
            if(this.caseRecord.BusinessArea__c === 'George') {
                this.panelRenderObj.isGeorge = true;
                if(this.caseRecord.ContactReasonLevel2__c) {
                    if(this.caseRecord.ContactReasonLevel2__c === 'Incorrect Refund Amount' ||
                       this.caseRecord.ContactReasonLevel2__c === 'Refund Not Received' ||
                       this.caseRecord.ContactReasonLevel2__c === 'Payment / Refund Issues') {
                            this.panelRenderObj.showRefunedDate = true;
                            this.panelRenderObj.showRefunedAmount = true;
                    }
                    else if(this.caseRecord.ContactReasonLevel2__c === 'Request A Refund') {
                        this.panelRenderObj.showRefunedAmount = true;
                    }
                }                   
            }
        }
    }
}