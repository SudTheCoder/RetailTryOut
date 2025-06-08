import { api, LightningElement, track} from 'lwc';

export default class AsdacOrderManagementCmp extends LightningElement {
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
            }
            else if(this.caseRecord.BusinessArea__c === 'Grocery') {
                this.panelRenderObj.isGrocery = true;                
            }
        }
    }
    get options() {
        return [
            { label: '--None--', value: ''},
            { label: 'Click and Collect', value: 'ClickandCollect' },
            { label: 'Home Delivery', value: 'HomeDelivery' },
        ];
    }
}