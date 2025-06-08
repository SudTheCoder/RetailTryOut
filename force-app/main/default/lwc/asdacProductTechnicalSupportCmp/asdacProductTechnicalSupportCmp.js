import { LightningElement, api, track} from 'lwc';

export default class AsdacProductTechnicalSupportCmp extends LightningElement {
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
        }
    }
}