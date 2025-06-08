import { api, LightningElement } from "lwc";

export default class AsdacWebformEntryPointCmp extends LightningElement {
  _webform;
  @api params;
  pageApiName;

  @api
  get webform() {
    return this._webform;
  }

  set webform(wf) {
    this._webform = wf;
    this.pageApiName = `Webform_${this._webform.replace(/[^A-Za-z]+/g, "_")}__c`;
  }
}