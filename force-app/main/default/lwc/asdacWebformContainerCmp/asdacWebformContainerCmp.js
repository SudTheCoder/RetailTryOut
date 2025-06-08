import { api, LightningElement } from "lwc";

export default class AsdacWebformContainerCmp extends LightningElement {
  @api formType;
  isRendered = false;

  renderedCallback() {
    if (this.isRendered) {
      return;
    }
    this.isRendered = true;
    const style = document.createElement("style");
    style.innerHTML = ".slds-form-element__label { font-family: var(--c-font-family); display: inline-flex; flex-direction: row-reverse; }";
    this.template.querySelector(".style-section").appendChild(style);
  }

  get isGeorgeRefund() {
    return this.formType === "George - Refund";
  }

  get isGeorgeVatRequest() {
    return this.formType === "George - VAT Request";
  }

  get isGeorgeGeneralEnquiry(){
    return this.formType==="George - General Enquiry";
  }

  get isGeorgeInternationalOrders(){
    return this.formType==="George - International Orders";
  }
}