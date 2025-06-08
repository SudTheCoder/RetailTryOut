import getRecords from '@salesforce/apex/ASDAC_CustomLookupLWCController.getsearchedRecords';
import { api, LightningElement, track, wire } from 'lwc';

export default class AsdacCustomLookupCmp extends LightningElement {
    @api recordId;
    @api flowRecordId;
    @api businessArea;
    @api isIssueEvoucher;
    @api iconName;
    @api searchPlaceholder='Search';
    @api selectedCaseId;
    @api taskType;
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;
    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    get searchParametersStringifiedJSON() {
        let jsonString = JSON.stringify({
            searchTerm : this.searchTerm,
            recordId : this.flowRecordId,
            businessArea : this.businessArea === 'George' ? 'George' : 'Grocery' ,
            isIssueEvoucher : this.isIssueEvoucher === true ? true : false,
            taskType: this.taskType
        });
        return jsonString;
    }

    formatRecordData(data) {
    data = JSON.parse(JSON.stringify(data));
        for (let index in data) {      
            if (data[index].CreatedDate){   
                   data[index].CreatedDate = data[index].CreatedDate.split('T')[0];
            }            
        }
        return data;
    }

    @wire(getRecords, {sObjectName: 'Case', searchParametersJsonString : '$searchParametersStringifiedJSON'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = this.formatRecordData(data);
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onSelect(event) {

        this.selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        let selectedRecordSubject = event.currentTarget.dataset.subject;

        const valueSelectedEvent = new CustomEvent('lookupselected', {detail: this.selectedId });
        this.dispatchEvent(valueSelectedEvent);

        this.selectedCaseId = this.selectedId;

        this.isValueSelected = true;
        this.selectedName = selectedName +' '+ selectedRecordSubject;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }
}