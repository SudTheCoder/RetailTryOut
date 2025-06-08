import { LightningElement, wire } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import createCase from "@salesforce/apex/ASDAC_WebformCmpController.createCase";
import getCaseRecordType from "@salesforce/apex/ASDAC_WebformCmpController.getCaseRecordType";
import CaseInfoToCapture from "@salesforce/schema/Case.InfoToCapture__c";
import userId from "@salesforce/user/Id";
import UserFirstName from "@salesforce/schema/User.Contact.FirstName";
import UserLastName from "@salesforce/schema/User.Contact.LastName";
import UserEmail from "@salesforce/schema/User.Contact.Email";
import UserPhone from "@salesforce/schema/User.Contact.Phone";
import UserContactId from "@salesforce/schema/User.ContactId";
import ASDAC_WebformGeorgeRefundTitle from "@salesforce/label/c.ASDAC_WebformGeorgeRefundTitle";
import ASDAC_WebformGeorgeRefundFirstName from "@salesforce/label/c.ASDAC_WebformGeorgeRefundFirstName";
import ASDAC_WebformGeorgeRefundLastName from "@salesforce/label/c.ASDAC_WebformGeorgeRefundLastName";
import ASDAC_WebformGeorgeRefundEmail from "@salesforce/label/c.ASDAC_WebformGeorgeRefundEmail";
import ASDAC_WebformGeorgeRefundConfirmEmail from "@salesforce/label/c.ASDAC_WebformGeorgeRefundConfirmEmail";
import ASDAC_WebformGeorgeRefundPhone from "@salesforce/label/c.ASDAC_WebformGeorgeRefundPhone";
import ASDAC_WebformGeorgeRefundPostcode from "@salesforce/label/c.ASDAC_WebformGeorgeRefundPostcode";
import ASDAC_WebformGeorgeRefundOrderDate from "@salesforce/label/c.ASDAC_WebformGeorgeRefundOrderDate";
import ASDAC_WebformGeorgeRefundOrderTotal from "@salesforce/label/c.ASDAC_WebformGeorgeRefundOrderTotal";
import ASDAC_WebformGeorgeRefundOrderId from "@salesforce/label/c.ASDAC_WebformGeorgeRefundOrderId";
import ASDAC_WebformGeorgeRefundReturnedTo from "@salesforce/label/c.ASDAC_WebformGeorgeRefundReturnedTo";
import ASDAC_WebformGeorgeRefundStore from "@salesforce/label/c.ASDAC_WebformGeorgeRefundStore";
import ASDAC_WebformGeorgeRefundReturnItemsCount from "@salesforce/label/c.ASDAC_WebformGeorgeRefundReturnItemsCount";
import ASDAC_WebformGeorgeRefundReturnReason from "@salesforce/label/c.ASDAC_WebformGeorgeRefundReturnReason";
import ASDAC_WebformGeorgeRefundReturnReasonDetail from "@salesforce/label/c.ASDAC_WebformGeorgeRefundReturnReasonDetail";
import ASDAC_WebformGeorgeRefundReturnCodePrompt from "@salesforce/label/c.ASDAC_WebformGeorgeRefundReturnCodePrompt";
import ASDAC_WebformGeorgeRefundReturnCode from "@salesforce/label/c.ASDAC_WebformGeorgeRefundReturnCode";
import ASDAC_WebformGeorgeRefundReturnCodeHelp from "@salesforce/label/c.ASDAC_WebformGeorgeRefundReturnCodeHelp";
import ASDAC_WebformGeorgeRefundAttachments from "@salesforce/label/c.ASDAC_WebformGeorgeRefundAttachments";
import ASDAC_WebformGeorgeRefundSendRequest from "@salesforce/label/c.ASDAC_WebformGeorgeRefundSendRequest";
import ASDAC_WebformGeorgeRefundSuccessResponse from "@salesforce/label/c.ASDAC_WebformGeorgeRefundSuccessResponse";
import ASDAC_WebformGeorgeRefundStartNewRequest from "@salesforce/label/c.ASDAC_WebformGeorgeRefundStartNewRequest";
import ASDAC_WebformError from "@salesforce/label/c.ASDAC_WebformError";
import { CurrentPageReference } from "lightning/navigation";

const WEBFORM = "George - Refund";
const RETURNED_TO_OPTIONS = [
  { label: "Store", value: "Store" },
  { label: "Courier", value: "Courier" }
];
const RETURN_REASON_OPTIONS = {
  DAMAGED: { label: "Damaged", contactReasonLevel2: "Damaged / Faulty" },
  DAMAGED_PACKAGING: {
    label: "Damaged Packaging",
    contactReasonLevel2: "Damaged / Faulty"
  },
  FAULTY: { label: "Faulty", contactReasonLevel2: "Damaged / Faulty" },
  MISSING_ITEMS: {
    label: "Missing Items",
    contactReasonLevel2: "Missing Part / Weight"
  },
  MISSING_PARTS: {
    label: "Missing Parts",
    contactReasonLevel2: "Missing Part / Weight"
  },
  GENERAL_ISSUE: {
    label: "General Issue with quality",
    contactReasonLevel2: "General Issue"
  }
};
export default class AsdacWebformGeorgeRefundCmp extends LightningElement {
  loading = true;
  contactId = undefined;
  firstName;
  lastName;
  email;
  confirmEmail;
  phone;
  postcode;
  orderDate;
  orderTotal;
  orderId;
  returnedTo;
  returnedToOptions = RETURNED_TO_OPTIONS;
  store;
  returnItemsCount;
  returnReason;
  returnReasonOptions = Object.keys(RETURN_REASON_OPTIONS).map((key) => ({
    ...RETURN_REASON_OPTIONS[key],
    value: key
  }));
  returnReasonDetail;
  caseInfoToCapturePicklist;
  returnCodePrompt;
  returnCodePromptOptions = [
    { label: "Yes", value: "Yes" },
    { label: "No", value: "No" }
  ];
  returnCode = "ASD";
  attachments;
  labels = {
    title: ASDAC_WebformGeorgeRefundTitle,
    firstName: ASDAC_WebformGeorgeRefundFirstName,
    lastName: ASDAC_WebformGeorgeRefundLastName,
    email: ASDAC_WebformGeorgeRefundEmail,
    confirmEmail: ASDAC_WebformGeorgeRefundConfirmEmail,
    phone: ASDAC_WebformGeorgeRefundPhone,
    postcode: ASDAC_WebformGeorgeRefundPostcode,
    orderDate: ASDAC_WebformGeorgeRefundOrderDate,
    orderTotal: ASDAC_WebformGeorgeRefundOrderTotal,
    orderId: ASDAC_WebformGeorgeRefundOrderId,
    returnedTo: ASDAC_WebformGeorgeRefundReturnedTo,
    store: ASDAC_WebformGeorgeRefundStore,
    returnItemsCount: ASDAC_WebformGeorgeRefundReturnItemsCount,
    returnReason: ASDAC_WebformGeorgeRefundReturnReason,
    returnReasonDetail: ASDAC_WebformGeorgeRefundReturnReasonDetail,
    returnCodePrompt: ASDAC_WebformGeorgeRefundReturnCodePrompt,
    returnCode: ASDAC_WebformGeorgeRefundReturnCode,
    returnCodeHelp: ASDAC_WebformGeorgeRefundReturnCodeHelp,
    attachments: ASDAC_WebformGeorgeRefundAttachments,
    sendRequest: ASDAC_WebformGeorgeRefundSendRequest,
    successResponse: ASDAC_WebformGeorgeRefundSuccessResponse,
    startNewRequest: ASDAC_WebformGeorgeRefundStartNewRequest
  };
  success;
  error;
  recordTypeId;
  source;

  @wire(CurrentPageReference)
  getPageReference(pageRef) {
    const state = pageRef.state || {};
    this.source = state.source;
    this.returnReason = state.returnReason;
  }

  get maxOrderDate() {
    const today = new Date();
    const date = `${today.getFullYear()}-${("0" + (today.getMonth() + 1)).slice(-2)}-${("0" + today.getDate()).slice(-2)}`;
    return date;
  }

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

  @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: CaseInfoToCapture })
  getCasePicklistValues({ data, error }) {
    if (data) {
      this.caseInfoToCapturePicklist = data;
    } else if (error) {
      this.error = ASDAC_WebformError;
    }
  }

  get isCustomer() {
    // returns true if the logged in user is a Customer
    return !!this.contactId;
  }

  get hideStore() {
    return this.returnedTo !== "Store";
  }

  get returnReasonDetailOptions() {
    if (!this.caseInfoToCapturePicklist || !this.returnReason) {
      return [];
    }
    const contactReason = RETURN_REASON_OPTIONS[this.returnReason].contactReasonLevel2;
    const controllerValue = this.caseInfoToCapturePicklist.controllerValues[contactReason];
    return this.caseInfoToCapturePicklist.values.filter((option) => option.validFor.includes(controllerValue));
  }

  get hideReturnCode() {
    return this.returnCodePrompt !== "Yes";
  }

  handleChange(event) {
    const key = event.target.name;
    this[key] = event.detail.value;
    if (key === "returnReason") {
      // Reset the controlled field on controlling field change
      this.returnReasonDetail = undefined;
    }
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
    desc += `Date of order: ${this.orderDate.split("-").reverse().join("-")}\n`;
    desc += `Order total: £${Number(this.orderTotal).toFixed(2)}\n`;
    desc += `Order number: ${this.orderId}\n`;
    desc += `Returned to: ${this.returnedTo + (this.hideStore ? "" : " (" + this.store + ")")}\n`;
    desc += `Number of items returned: ${this.returnItemsCount || "--No-Entry--"}\n`;
    desc += `Reason for return: ${RETURN_REASON_OPTIONS[this.returnReason].label}\n`;
    desc += `Detailed reason for return: ${this.returnReasonDetail}\n`;
    desc += `Has return code: ${this.returnCodePrompt}\n`;
    if (!this.hideReturnCode) {
      desc += `Return code: ${this.returnCode}\n`;
    }

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

    // Validation for lightning-combobox
    const inputs = this.template.querySelectorAll("lightning-combobox");
    for (let i = 0; i < inputs.length; i++) {
      if (!inputs.item(i).reportValidity()) {
        return false;
      }
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
        OrderId__c: this.orderId,
        ContactReasonLevel2__c: RETURN_REASON_OPTIONS[this.returnReason].contactReasonLevel2,
        [CaseInfoToCapture.fieldApiName]: this.returnReasonDetail,
        Subject: WEBFORM + (this.source ? ` | ${this.source}` : ""),
        Description: this.getDescription()
      };
      if (!this.isCustomer) {
        // Guest Users
        caseObject.SuppliedEmail = this.email;
      }

      const files = await Promise.all((this.attachments || []).map(this.convertFile));

      createCase({ caseObject, files })
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
    if (!this.isCustomer) {
      this.firstName = "";
      this.lastName = "";
      this.email = "";
      this.confirmEmail = "";
      this.phone = "";
      this.postcode = "";
    }
    this.orderDate = "";
    this.orderTotal = "";
    this.orderId = "";
    this.returnedTo = "";
    this.store = "";
    this.returnItemsCount = "";
    this.returnReason = "";
    this.returnReasonDetail = "";
    this.returnCodePrompt = "";
    this.returnCode = "ASD";
    this.attachments = [];
    window.scrollTo({ left: 0, top: 0 });
  }

  async convertFile(file) {
    const document = {
      name: file.name,
      type: file.type
    };
    const buffer = await file.arrayBuffer();
    document.body = window.btoa(new Uint8Array(buffer).reduce((data, byte) => data + String.fromCharCode(byte), ""));
    return document;
  }

  disableEvent(event) {
    event.preventDefault();
  }

  handleNewRequest() {
    this.success = false;
    this.error = "";
  }
}