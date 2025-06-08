import { api, LightningElement, wire } from 'lwc';
import PersonContactId from '@salesforce/schema/Account.PersonContactId';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import errorToastTitle from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import defaultCaseStatus from '@salesforce/label/c.ASDAC_CaseDefaultStatus';
import georgeLabel from '@salesforce/label/c.ASDAC_GeorgeLabel';

const fields = [PersonContactId];
export default class AsdacCustomerCreateCaseCmp extends NavigationMixin(LightningElement) {
  @api recordId;
  contactId;

  @wire(getRecord, { recordId: '$recordId', fields })
  getCustomerDetails({ data, error }) {
    if (data) {
      this.contactId = getFieldValue(data, PersonContactId);
    } else {
      const event = new ShowToastEvent({
        title: errorToastTitle,
        variant: "error",
        message: Array.isArray(error) ? error[0] : error,
      });
      this.dispatchEvent(event);
    }
  }

  @api invoke() {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: 'Case',
        actionName: 'new'
      },
      state: {
        nooverride: true,
        useRecordTypeCheck: true,
        defaultFieldValues: encodeDefaultFieldValues({
          AccountId: this.recordId,
          ContactId: this.contactId,
          Status: defaultCaseStatus,
          BusinessArea__c: georgeLabel
        }),
      }
    });
  }
}