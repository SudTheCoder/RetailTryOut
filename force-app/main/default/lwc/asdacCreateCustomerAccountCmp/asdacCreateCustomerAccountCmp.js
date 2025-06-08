import { LightningElement, api, wire } from 'lwc';
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import suppliedFirstname from "@salesforce/schema/Case.SuppliedFirstname__c";
import suppliedLastname from "@salesforce/schema/Case.Supplied_Lastname__c";
import suppliedEmail from "@salesforce/schema/Case.SuppliedEmail";
import suppliedPhone from "@salesforce/schema/Case.SuppliedPhone";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCustomerAccount from '@salesforce/apex/ASDAC_CreateNewCustomerController.createCustomerAccount';
import successToastTitle from '@salesforce/label/c.ASDAC_SuccessToastTitle';
import errorToastTitle from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import suppliedEmailMandatoryMessage from '@salesforce/label/c.ASDAC_SuppliedEmailMandatoryMessage';
import suppliedLastNameMandatoryMessage from '@salesforce/label/c.ASDAC_SuppliedLastNameMandatoryMessage';
import createAccountToastErrorMessage from '@salesforce/label/c.ASDAC_CreateAccountToastErrorMessage';

export default class AsdacCreateCustomerAccountCmp extends LightningElement {
  @api recordId;
  accountDetail = {};
  caseNumber;
  isExecuting = false;

  @wire(getRecord, {
    recordId: '$recordId',
    fields: [suppliedFirstname, suppliedLastname, suppliedEmail, suppliedPhone]
  })
  getCaseDetails({ data, error }) {
    if (data) {
      this.accountDetail = {
        FirstName: getFieldValue(data, suppliedFirstname),
        LastName: getFieldValue(data, suppliedLastname),
        PersonEmail: getFieldValue(data, suppliedEmail),
        Phone: getFieldValue(data, suppliedPhone)
      }
    } else {
      const errorMessage = Array.isArray(error) ? error[0] : error;
      this.displayToastMessage(errorToastTitle, 'Error', createAccountToastErrorMessage + errorMessage);
    }
  }

  @api async invoke() {
    if (this.isExecuting) {
      return;
    }
    if (!this.accountDetail.PersonEmail || !this.accountDetail.PersonEmail.trim()) {
      this.displayToastMessage(errorToastTitle, 'Error', suppliedEmailMandatoryMessage);
    } else if (!this.accountDetail.LastName || !this.accountDetail.LastName.trim()) {
      this.displayToastMessage(errorToastTitle, 'Error', suppliedLastNameMandatoryMessage);
    } else {
      this.isExecuting = true;
      await createCustomerAccount({ accountDetail: this.accountDetail })
        .then(result => {
          if (result.isSuccess) {
            this.displayToastMessage(successToastTitle, 'success', result.message);
            this.updateRecordView();
          }
          else {
            this.displayToastMessage(errorToastTitle, 'Error', createAccountToastErrorMessage + result.message);
          }
        })
        .catch(error => {
          this.displayToastMessage(errorToastTitle, 'Error', createAccountToastErrorMessage + error.message);
        }).finally(()=>{
          this.isExecuting = false;
        });   
    }
  }

  displayToastMessage(title, variant, message) {
    const toEvt = new ShowToastEvent({
      title: title,
      variant: variant,
      message: message
    });
    this.dispatchEvent(toEvt);
  }

  updateRecordView() {
    setTimeout(() => {
         eval("$A.get('e.force:refreshView').fire();");
    }, 1000); 
 }
}