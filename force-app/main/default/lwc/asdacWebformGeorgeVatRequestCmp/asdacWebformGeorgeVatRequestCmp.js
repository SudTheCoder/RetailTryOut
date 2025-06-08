import { LightningElement, wire } from "lwc";
import createCase from "@salesforce/apex/ASDAC_WebformCmpController.createCase";
import ASDAC_WebformGeorgeVatRequestTitle from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestTitle";
import ASDAC_WebformGeorgeVatRequestFirstName from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestFirstName";
import ASDAC_WebformGeorgeVatRequestLastName from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestLastName";
import ASDAC_WebformGeorgeVatRequestEmail from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestEmail";
import ASDAC_WebformGeorgeVatRequestConfirmEmail from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestConfirmEmail";
import ASDAC_WebformGeorgeVatRequestPhone from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestPhone";
import ASDAC_WebformGeorgeVatRequestPostcode from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestPostcode";
import ASDAC_WebformGeorgeVatRequestOrderDate from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestOrderDate";
import ASDAC_WebformGeorgeVatRequestOrderTotal from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestOrderTotal";
import ASDAC_WebformGeorgeVatRequestOrderId from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestOrderId";
import ASDAC_WebformGeorgeVatRequestSendRequest from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestSendRequest";
import ASDAC_WebformGeorgeVatRequestSuccessResponse from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestSuccessResponse";
import ASDAC_WebformGeorgeVatRequestStartNewRequest from "@salesforce/label/c.ASDAC_WebformGeorgeVatRequestStartNewRequest";
import ASDAC_WebformError from "@salesforce/label/c.ASDAC_WebformError";
import { CurrentPageReference } from "lightning/navigation";

const WEBFORM = "George - VAT Request";
const CONTACT_REASON_LEVEL_2 = "VAT Receipt";
export default class AsdacWebformGeorgeVatRequestCmp extends LightningElement {
  loading = false;
  firstName;
  lastName;
  email;
  confirmEmail;
  phone;
  postcode;
  orderDate;
  orderTotal;
  orderId;
  labels = {
    title: ASDAC_WebformGeorgeVatRequestTitle,
    firstName: ASDAC_WebformGeorgeVatRequestFirstName,
    lastName: ASDAC_WebformGeorgeVatRequestLastName,
    email: ASDAC_WebformGeorgeVatRequestEmail,
    confirmEmail: ASDAC_WebformGeorgeVatRequestConfirmEmail,
    phone: ASDAC_WebformGeorgeVatRequestPhone,
    postcode: ASDAC_WebformGeorgeVatRequestPostcode,
    orderDate: ASDAC_WebformGeorgeVatRequestOrderDate,
    orderTotal: ASDAC_WebformGeorgeVatRequestOrderTotal,
    orderId: ASDAC_WebformGeorgeVatRequestOrderId,
    sendRequest: ASDAC_WebformGeorgeVatRequestSendRequest,
    successResponse: ASDAC_WebformGeorgeVatRequestSuccessResponse,
    startNewRequest: ASDAC_WebformGeorgeVatRequestStartNewRequest
  };
  success = false;
  error;

  @wire(CurrentPageReference)
  getPageReference(pageRef) {
    const state = pageRef.state || {};
    this.source = state.source;
  }

  get maxOrderDate() {
    const today = new Date();
    const date = `${today.getFullYear()}-${("0" + (today.getMonth() + 1)).slice(-2)}-${("0" + today.getDate()).slice(-2)}`;
    return date;
  }

  handleChange(event) {
    const key = event.target.name;
    this[key] = event.detail.value;
  }

  validateInputs() {
    const inputs = [...this.template.querySelectorAll("lightning-input")];
    for (let input of inputs) {
      if (!input.required) {
        continue;
      }
      const key = input.name;
      const value = this[key];
      if (!value || !value.trim()) {
        this[key] = "";
        setTimeout(() => {
          input.reportValidity();
        }, 50);
        return false;
      }
    }
    return true;
  }

  validateEmail() {
    const input = this.template.querySelector(".confirmEmailSelector");
    if (this.confirmEmail !== this.email) {
      input.setCustomValidity("Email does not match");
      input.reportValidity();
      return false;
    }

    input.setCustomValidity("");
    return input.reportValidity();
  }

  getDescription() {
    let desc = "Webform entries by Customer\n";
    desc += `First name: ${this.firstName}\n`;
    desc += `Last name: ${this.lastName}\n`;
    desc += `Email address: ${this.email}\n`;
    desc += `Phone number: ${this.phone}\n`;
    desc += `House No / Postcode: ${this.postcode || "--No-Entry--"}\n`;
    desc += `Date of order: ${this.orderDate.split("-").reverse().join("-")}\n`;
    desc += `Order total: £${Number(this.orderTotal).toFixed(2)}\n`;
    desc += `Order number: ${this.orderId}\n`;

    return desc;
  }

  async handleSubmit(event) {
    event.preventDefault(); // stop the form from submitting

    if (!this.validateInputs()) {
      return false;
    }

    if (!this.validateEmail()) {
      return false;
    }

    try {
      this.success = undefined;
      this.error = undefined;
      this.loading = true;
      const caseObject = {
        Webform__c: WEBFORM,
        SuppliedName: `${this.firstName} ${this.lastName}`.trim(),
        SuppliedEmail: this.email,
        ContactReasonLevel2__c: CONTACT_REASON_LEVEL_2,
        OrderId__c: this.orderId,
        Subject: WEBFORM + (this.source ? ` | ${this.source}` : ""),
        Description: this.getDescription()
      };

      createCase({ caseObject, files: [] })
        .then((caseId) => {
          this.success = true;
          this.loading = false;
          this.handleReset();
        })
        .catch((error) => {
          this.error = ASDAC_WebformError;
          this.loading = false;
        });
    } catch (error) {
      this.error = error.message;
      this.loading = false;
    }
  }

  handleReset() {
    this.firstName = "";
    this.lastName = "";
    this.email = "";
    this.confirmEmail = "";
    this.phone = "";
    this.postcode = "";
    this.orderDate = "";
    this.orderTotal = "";
    this.orderId = "";
    window.scrollTo({ left: 0, top: 0 });
  }

  disableEvent(event) {
    event.preventDefault();
  }

  handleNewRequest() {
    this.success = false;
    this.error = "";
  }
}