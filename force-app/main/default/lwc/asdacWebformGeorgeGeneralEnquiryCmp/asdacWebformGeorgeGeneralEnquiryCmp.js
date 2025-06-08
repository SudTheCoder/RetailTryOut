import { LightningElement, wire } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import createCase from "@salesforce/apex/ASDAC_WebformCmpController.createCase";
import getCaseRecordType from "@salesforce/apex/ASDAC_WebformCmpController.getCaseRecordType";
import ASDAC_WebformGeorgeGeneralEnquiryTitle from "@salesforce/label/c.ASDAC_WebformGeorgeGeneralEnquiryTitle";
import ASDAC_WebformGeneralEnquiryFirstName from "@salesforce/label/c.ASDAC_WebformGeorgeRefundFirstName";
import ASDAC_WebformGeneralEnquiryLastName from "@salesforce/label/c.ASDAC_WebformGeorgeRefundLastName";
import ASDAC_WebformGeneralEnquiryEmail from "@salesforce/label/c.ASDAC_WebformGeorgeRefundEmail";
import ASDAC_WebformGeneralEnquiryConfirmEmail from "@salesforce/label/c.ASDAC_WebformGeorgeRefundConfirmEmail";
import ASDAC_WebformGeneralEnquiryPhone from "@salesforce/label/c.ASDAC_WebformGeorgeRefundPhone";
import ASDAC_WebformGeneralEnquiryPostcode from "@salesforce/label/c.ASDAC_WebformGeorgeRefundPostcode";
import ASDAC_WebformGeneralEnquirySendRequest from "@salesforce/label/c.ASDAC_WebformGeorgeRefundSendRequest";
import ASDAC_WebformGeneralEnquirySuccessResponse from "@salesforce/label/c.ASDAC_WebformGeorgeRefundSuccessResponse";
import ASDAC_WebformGeneralEnquiryStartNewRequest from "@salesforce/label/c.ASDAC_WebformGeneralEnquiryStartNewRequest";
import ASDAC_WebformGeneralEnquiryDescription from "@salesforce/label/c.ASDAC_WebformGeneralEnquiryDescription";
import ASDAC_WebformError from "@salesforce/label/c.ASDAC_WebformError";
import userId from "@salesforce/user/Id";
import UserFirstName from "@salesforce/schema/User.Contact.FirstName";
import UserLastName from "@salesforce/schema/User.Contact.LastName";
import UserEmail from "@salesforce/schema/User.Contact.Email";
import UserPhone from "@salesforce/schema/User.Contact.Phone";
import UserContactId from "@salesforce/schema/User.ContactId";
const WEBFORM = "George - General Enquiry";
export default class AsdacWebformGeorgeGeneralEnquiryCmp extends LightningElement {
  loading = true;
  contactId = undefined;
  firstName;
  lastName;
  email;
  confirmEmail;
  phone;
  postcode;
  generalEnquiry;
  labels = {
    title: ASDAC_WebformGeorgeGeneralEnquiryTitle,
    firstName: ASDAC_WebformGeneralEnquiryFirstName,
    lastName: ASDAC_WebformGeneralEnquiryLastName,
    email: ASDAC_WebformGeneralEnquiryEmail,
    confirmEmail: ASDAC_WebformGeneralEnquiryConfirmEmail,
    phone: ASDAC_WebformGeneralEnquiryPhone,
    postcode: ASDAC_WebformGeneralEnquiryPostcode,
    generalEnquiry:ASDAC_WebformGeneralEnquiryDescription,
    sendRequest: ASDAC_WebformGeneralEnquirySendRequest,
    successResponse: ASDAC_WebformGeneralEnquirySuccessResponse,
    startNewRequest: ASDAC_WebformGeneralEnquiryStartNewRequest
  };
  success;
  error;
  recordTypeId;
  connectedCallback() {
    getCaseRecordType({ webformName: WEBFORM })
      .then((id) => {
        this.recordTypeId = id;
      })
      .catch(() => {
        this.error = ASDAC_WebformError;
      });
    if (!userId) {
      this.loading = false;
    }
  }
  @wire(getRecord, {
    recordId: userId,
    fields: [UserFirstName, UserLastName, UserEmail, UserPhone, UserContactId]
  })
  getUserContact({ data, error }) {
    if (data) {
      this.contactId = getFieldValue(data, UserContactId);
      if (this.contactId) {
        this.firstName = getFieldValue(data, UserFirstName);
        this.lastName = getFieldValue(data, UserLastName);
        this.email = getFieldValue(data, UserEmail);
        this.phone = getFieldValue(data, UserPhone);
      }
    } else if (error) {
      this.error = ASDAC_WebformError;
    }
    this.loading = false;
  }

  get isCustomer() {
    // returns true if the logged in user is a Customer
    return !!this.contactId;
  }

  handleChange(event) {
    const key = event.target.name;
    this[key] = event.detail.value;
  }

  validateInputs() {
    const inputs = [...this.template.querySelectorAll("lightning-input,lightning-textarea")];
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
    if (this.isCustomer) {
      return true;
    }
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
    if (!this.isCustomer) {
      desc += `House No / Postcode: ${this.postcode || "--No-Entry--"}\n`;
    }
    desc += `General Enquiry: ${this.generalEnquiry}\n`;
    return desc;
  }

  handleSubmit(event) {
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
        ContactId: this.contactId,
        SuppliedName: `${this.firstName} ${this.lastName}`.trim(),
        SuppliedPhone: this.phone,        
        Subject: WEBFORM,
        Description: this.getDescription()
      };
      if (!this.isCustomer) {
        // Guest Users
        caseObject.SuppliedEmail = this.email;
      }

      createCase({ caseObject})
        .then((caseId) => {
          if(caseId!=null && caseId !==''){
            this.success = true;
            this.loading = false;
            this.handleReset();
          }         
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
    this.template.querySelectorAll('lightning-input,lightning-textarea').forEach(element => {
        this[element.name] = null;     
    });
    window.scrollTo({ left: 0, top: 0 });
  }

  handleNewRequest() {
    this.success = false;
    this.error = "";
  }

  disableEvent(event) {
    event.preventDefault();
  }
}