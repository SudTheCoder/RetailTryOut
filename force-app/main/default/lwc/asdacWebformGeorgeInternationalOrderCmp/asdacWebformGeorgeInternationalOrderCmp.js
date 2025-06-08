import { LightningElement, wire } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import createCase from "@salesforce/apex/ASDAC_WebformCmpController.createCase";
import getCaseRecordType from "@salesforce/apex/ASDAC_WebformCmpController.getCaseRecordType";
import ASDAC_WebformGeorgeInternationalOrderTitle from "@salesforce/label/c.ASDAC_WebformGeorgeInternationalOrderTitle";
import ASDAC_WebformGeorgeInternationalOrderFirstName from "@salesforce/label/c.ASDAC_WebformGeorgeRefundFirstName";
import ASDAC_WebformGeorgeInternationalOrderLastName from "@salesforce/label/c.ASDAC_WebformGeorgeRefundLastName";
import ASDAC_WebformGeorgeInternationalOrderEmail from "@salesforce/label/c.ASDAC_WebformGeorgeRefundEmail";
import ASDAC_WebformGeorgeInternationalOrderConfirmEmail from "@salesforce/label/c.ASDAC_WebformGeorgeRefundConfirmEmail";
import ASDAC_WebformGeorgeInternationalOrderId from "@salesforce/label/c.ASDAC_WebformGeorgeRefundOrderId";
import ASDAC_WebformGeorgeInternationalOrderIssueDescription from "@salesforce/label/c.ASDAC_WebformGeorgeInternationalOrderIssueDescription";
import ASDAC_WebformGeorgeInternationalOrderSendRequest from "@salesforce/label/c.ASDAC_WebformGeorgeRefundSendRequest";
import ASDAC_WebformGeorgeInternationalOrderSuccessResponse from "@salesforce/label/c.ASDAC_WebformGeorgeRefundSuccessResponse";
import ASDAC_WebformGeorgeInternationalOrderStartNewRequest from "@salesforce/label/c.ASDAC_WebformGeneralEnquiryStartNewRequest";
import ASDAC_WebformError from "@salesforce/label/c.ASDAC_WebformError";
import userId from "@salesforce/user/Id";
import UserFirstName from "@salesforce/schema/User.Contact.FirstName";
import UserLastName from "@salesforce/schema/User.Contact.LastName";
import UserEmail from "@salesforce/schema/User.Contact.Email";
import UserContactId from "@salesforce/schema/User.ContactId";
import { CurrentPageReference } from "lightning/navigation";
const WEBFORM = "George - International Orders";
export default class AsdacWebformGeorgeInternationalOrderCmp extends LightningElement {
    loading = true;
    contactId = undefined;
    firstName;
    lastName;
    email;
    confirmEmail;
    orderId;
    orderIssueDescription;
    labels = {
        title: ASDAC_WebformGeorgeInternationalOrderTitle,
        firstName: ASDAC_WebformGeorgeInternationalOrderFirstName,
        lastName: ASDAC_WebformGeorgeInternationalOrderLastName,
        email: ASDAC_WebformGeorgeInternationalOrderEmail,
        confirmEmail: ASDAC_WebformGeorgeInternationalOrderConfirmEmail,
        orderId:ASDAC_WebformGeorgeInternationalOrderId,
        orderIssueDescription:ASDAC_WebformGeorgeInternationalOrderIssueDescription,
        sendRequest: ASDAC_WebformGeorgeInternationalOrderSendRequest,
        successResponse: ASDAC_WebformGeorgeInternationalOrderSuccessResponse,
        startNewRequest: ASDAC_WebformGeorgeInternationalOrderStartNewRequest
      };
      success;
      error;
      recordTypeId;
      source;

     @wire(CurrentPageReference)
     getPageReference(pageRef) {
     const state = pageRef.state || {};
     this.source = state.source;
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
        fields: [UserFirstName, UserLastName, UserEmail, UserContactId]
      })
      getUserContact({ data, error }) {
        if (data) {
          this.contactId = getFieldValue(data, UserContactId);
          if (this.contactId) {
            this.firstName = getFieldValue(data, UserFirstName);
            this.lastName = getFieldValue(data, UserLastName);
            this.email = getFieldValue(data, UserEmail);
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
        const inputs = [...this.template.querySelectorAll('lightning-input,lightning-textarea')];
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
        let desc = "Webform entries by International Customer\n";
        desc += `First name: ${this.firstName}\n`;
        desc += `Last name: ${this.lastName}\n`;
        desc += `Email address: ${this.email}\n`;
        desc += `Order number: ${this.orderId}\n`;
        desc += `Brief description of the issue with customer's order: ${this.orderIssueDescription}\n`;
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
            OrderId__c: this.orderId,      
            Subject: WEBFORM + (this.source ? ` | ${this.source}` : ""),
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