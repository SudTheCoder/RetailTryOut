import { api, LightningElement, wire } from "lwc";
import { publish, MessageContext } from 'lightning/messageService';
import recordTypeMessageChannel from '@salesforce/messageChannel/recordTypeMessageChannel__c';

export default class AsdacCaseRecordTypePicklistCmp extends LightningElement {
  @api recordTypeList = [];
  _recordTypeId;

  @api
  get recordTypeId() {
    return this._recordTypeId;
  }
  set recordTypeId(value) {
    this._recordTypeId = value;
  }

  get recordTypeOptions() {
    return this.recordTypeList.map((rt) => ({
      label: rt.Name,
      value: rt.Id
    }));
  }

  @wire(MessageContext)
  messageContext;

  handleRecordTypeChange(evt) {
    this._recordTypeId = evt.detail.value;
    this.publishData();
  }

  publishData() {
    publish(this.messageContext, recordTypeMessageChannel, { value: this._recordTypeId });
  }

  connectedCallback() {
    this.publishData();
  }

  @api validate() {
    let isValid = !!this._recordTypeId;
    return { isValid, errorMessage: "Please select a choice." };
  }
}