import { LightningElement, wire, track, api } from "lwc";
import hasGHSAccess from '@salesforce/customPermission/ASDAC_GHSAccessPermission';
import { getRecord } from "lightning/uiRecordApi";
import reasonCodeField from "@salesforce/schema/Goodwill__c.ReasonCode__c";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import goodWillObject from "@salesforce/schema/Goodwill__c";
import getVoucherRecords from "@salesforce/apex/ASDAC_VoucherRequestController.getVoucherRecords";
import getGoodWillLimit from "@salesforce/apex/ASDAC_VoucherRequestController.getGoodWillLimit";
import doWalletIdentity from "@salesforce/apex/ASDAC_GoodWillWalletIdentity.doWalletIdentity";
import emailField from "@salesforce/schema/Account.PersonEmail";
import nameField from "@salesforce/schema/Account.Name";
import ASDAC_VoucherAmountError from "@salesforce/label/c.ASDAC_VoucherAmountError";
import { FlowNavigationNextEvent } from "lightning/flowSupport";
import submitButtonLabel from '@salesforce/label/c.ASDAC_SubmitButtonLabel';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';
import notesLabel from '@salesforce/label/c.ASDAC_NotesLabel';
import emailAddressLabel from '@salesforce/label/c.ASDAC_EmailAddressLabel';
import approvalLimitExceedMessage from '@salesforce/label/c.ASDAC_PartialRefundApprovalLimitExceedMessage';
import businessAreaLabel from '@salesforce/label/c.ASDAC_Business_Area';
import voucherMaxAmountMessage from '@salesforce/label/c.ASDAC_VoucherMaxAmountMessage';
import voucherAmountLabel from '@salesforce/label/c.ASDAC_VoucherAmountLabel';
import confirmVoucherAmountLabel from '@salesforce/label/c.ASDAC_ConfirmVoucherAmountLabel';
import voucherAmountCurrencyLabel from '@salesforce/label/c.ASDAC_VoucherAmountCurrencyLabel';
import voucherAmountMismatchError from '@salesforce/label/c.ASDAC_VoucherAmountMismatchError';
import fillRequiredFieldsMessage from '@salesforce/label/c.ASDAC_FillRequiredFieldsMessage';
import reasonCodeLabel from '@salesforce/label/c.ASDAC_ReasonCodeLabel';
import issueVoucherOptionsLabel from '@salesforce/label/c.ASDAC_IssueVoucherOptionsLabel';
import issueVoucherOption1 from '@salesforce/label/c.ASDAC_IssueVoucherOption1';
import issueVoucherOption2 from '@salesforce/label/c.ASDAC_IssueVoucherOption2';
import mandatoryFieldError from '@salesforce/label/c.ASDAC_MandatoryFieldError';
import georgeLabel from '@salesforce/label/c.ASDAC_GeorgeLabel';
import groceryLabel from '@salesforce/label/c.ASDAC_GroceryLabel';
import voucherType from '@salesforce/label/c.ASDAC_VoucherType';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AsdacVoucherRequestCmp extends LightningElement {

@track isLoading = true;
  @track hasError = false;
@track maximumAmount;
@track voucherOptions = [];
@track email;
@track Voucherid;
@track fieldVisible = false;
@api recordId;
@api caseRecordId;
@api availableActions = [];
  @api exitButtonClicked=false;
  @api goodwillRecVariable;
  @api customerName;
  @api voucherAmount;
  @api Notes;
  @api strBusinessArea;
  @api hasTechnicalErrorOccurred=false;
  @api refundToCreateStr;
  @api voucherCode;
  @api reason;
  @api voucherValue;
  isButtonClicked = false;

  error;
defaultValue = "option1";
defaultBusinessAreaValue = georgeLabel;
vouchOpt = [];
selectedValue1;
reasonCode = [];
hasRendered = true;
isReasonValid = true;
isNotesValid = true;
isVoucherAmount = true;
isValidateAmount = true;
  isLimitExceeded = false;
  accessToken;
  name;
  isValidAmount;
  voucherMaxLimit;
  label = {
    submitButtonLabel,
    cancelButtonLabel,
    notesLabel,
    emailAddressLabel,
    approvalLimitExceedMessage,
    businessAreaLabel,
    voucherAmountLabel,
    confirmVoucherAmountLabel,
    voucherAmountCurrencyLabel,
    voucherAmountMismatchError,
    fillRequiredFieldsMessage,
    reasonCodeLabel,
    issueVoucherOptionsLabel
};

@track getVoucherRecord = {
  objectApiName: "Goodwill__c",
  BusinessArea__c: georgeLabel
};

get options() {
  return [
    { label: issueVoucherOption1, value: "option1" },
    { label: issueVoucherOption2, value: "option2" }
  ];
}
get businessArea() {
    if (hasGHSAccess) {
        return [{
                label: georgeLabel,
                value: 'George'
            },
            {
                label: groceryLabel,
                value: 'GHS'
            },
        ];
    } else {
        return [{
            label: georgeLabel,
            value: 'George'
        }];
    }
}
async connectedCallback() {
  this.isLoading = false;
    this.strBusinessArea = this.defaultBusinessAreaValue;
  }

@wire(getGoodWillLimit)
getVoucherLimit({ error, data }) {
  if (data) {
    this.voucherMaxLimit=data; 
  } else if (error) {
    console.error(error);
  }
}

  get maxAmountMessage() {
    return voucherMaxAmountMessage + this.voucherMaxLimit;
  }

@wire(getRecord, { recordId: "$recordId", fields: emailField })
wireEmail({ error, data }) {
  if (data) {
    this.email = data.fields.PersonEmail.value;
  } else if (error) {
    console.error(JSON.stringify(error));
  }
}
  @wire(getRecord, { recordId: '$recordId', fields: nameField })
    wireName({ error,data}) {
         if (data) {
            this.name = data.fields.Name.value;
        }
        else if (error) {
            console.error( JSON.stringify( error ) );
         }
    }

@wire(getVoucherRecords)
wiredMetaData({ error, data }) {
  if (data) {
    for (const mtd of data) {
      if (mtd.ASDAC_VoucherAmt__c != null) {

        this.vouchOpt.push(mtd.ASDAC_VoucherAmt__c);
          this.vouchOpt.sort(function(a, b) {
            return a - b;
          });

      } else if (mtd.ASDAC_MaximumAmount__c != null) {
        this.maximumAmount = mtd.ASDAC_MaximumAmount__c;
      }
    }
    for (const reOptions of this.vouchOpt) {
      this.voucherOptions = [
        ...this.voucherOptions,
        { label: reOptions, value: reOptions }
      ];
    }
  } else if (error) {
    console.error(JSON.stringify(error));
  }
}

@wire(getObjectInfo, { objectApiName: goodWillObject })
objectInfo;

@wire(getPicklistValues, {
  recordTypeId: "$objectInfo.data.defaultRecordTypeId",
  fieldApiName: reasonCodeField
})
wiredReasonCodeData({ error, data }) {
  if (data) {
    this.reasonCode = data.values.map((objPL) => {
      return {
        label: `${objPL.label}`,
        value: `${objPL.value}`
      };
    });
  } else if (error) {
    console.error(JSON.stringify(error));
  }
}
resolveValidityIssues(reasonValue, targetInput) {
  if (
    reasonValue !== undefined ||
    reasonValue !== "" ||
    reasonValue !== null
  ) {
    targetInput.setCustomValidity("");
    targetInput.reportValidity();
  }
}
handleReasonChange(event) {
  this.resolveValidityIssues(event.target.value, event.target);
  this.getVoucherRecord.ReasonCode__c = event.target.value;
}
getNotes(event) {
  this.getVoucherRecord.Notes__c = event.target.value;
    this.Notes = this.getVoucherRecord.Notes__c;
}
handleBusinessAreaChange(event) {
  this.getVoucherRecord.BusinessArea__c = event.target.value;
    this.strBusinessArea = event.target.value;
}
handleAmountOptionsChange(event) {
  this.resolveValidityIssues(event.target.value, event.target);
  this.getVoucherRecord.VoucherAmount__c = event.target.value;
}

handleSelected(event) {
  this.selectedValue1 = event.target.value;
    this.hasError = false;
  if (this.selectedValue1 === "option2") {
    this.fieldVisible = true;
  } else {
    this.fieldVisible = false;
  }
}

handleAmtChange(event) {
  this.hasError = false;
    let inputFld = event.target;
    let value =inputFld.value;
    if(parseFloat(value) <= 0){
      inputFld.setCustomValidity(`${inputFld.label} must be greater than 0.00`);
      return;
    }else if(isNaN(value) || !value) {
      this.getVoucherRecord.VoucherAmount__c = null;
      inputFld.value = '';
      return;
    }
  inputFld.setCustomValidity('');
    this.getVoucherRecord.VoucherAmount__c = value;
    this.validateAmount();
}

validateAmount() {
  const input = this.template.querySelector(".confirmAmount");
  let amount = this.template.querySelector(
    'lightning-input[data-name="amount"]'
  ).value;
  let confirmAmount = this.template.querySelector(
    'lightning-input[data-name="confirm amount"]'
  ).value;
    if(confirmAmount && amount && (Number(confirmAmount).toFixed(2) > 0.00) && (Number(amount).toFixed(2) > 0.00)) {
  if ((Number(amount).toFixed(2)) !== Number(confirmAmount).toFixed(2)) {
        input.setCustomValidity(' ');
    input.reportValidity();
        this.hasError = true;
    return false;
  }
      this.hasError = false;
  input.setCustomValidity("");
  return input.reportValidity();
}
  }

handleCancel() {
    this.exitButtonClicked=true;
    if (this.availableActions.find((action) => action === "NEXT")) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
  }
}

validateReasonField() {
  let requiredMessage = mandatoryFieldError;
  [...this.template.querySelectorAll(".reasonCls")].forEach((input) => {
    if (
      input.value === undefined ||
      input.value === "" ||
      input.value === null
    ) {
      this.isReasonValid = false;
      input.setCustomValidity(requiredMessage);
      input.reportValidity();
    } else {
      this.isReasonValid = true;
    }
  });
}

validateNotesField() {
  let requiredMessage = mandatoryFieldError;
  [...this.template.querySelectorAll(".notesCls")].forEach((input) => {
    if (
      input.value === undefined ||
      input.value === "" ||
      input.value === null
    ) {
      this.isNotesValid = false;
      input.setCustomValidity(requiredMessage);
      input.reportValidity();
    } else {
      input.setCustomValidity('');
      input.reportValidity();
      this.isNotesValid = true;
    }
  });
}

validateAmountInputField() {
  let requiredMessage = mandatoryFieldError;
  if (this.fieldVisible === false) {
    [...this.template.querySelectorAll(".voucherAmt1")].forEach((input) => {
      if (
        input.value === undefined ||
        input.value === "" ||
        input.value === null
      ) {
        this.isVoucherAmount = false;
        input.setCustomValidity(requiredMessage);
        input.reportValidity();
      } else {
        this.isVoucherAmount = true;
      }
    });
  } else {
    [...this.template.querySelectorAll(".voucherAmt")].forEach((input) => {
      if (
        input.value === undefined ||
        input.value === "" ||
        input.value === null
      ) {
        this.isVoucherAmount = false;
        input.setCustomValidity(requiredMessage);
        input.reportValidity();
      } else if(input.value<=0.00){
        this.isVoucherAmount = false;
        input.setCustomValidity(`${input.label} must be greater than 0.00`);
        input.reportValidity();
      }else {
        this.isVoucherAmount = true;
      }
    });

    [...this.template.querySelectorAll(".confirmAmount")].forEach((input) => {
      if (
        input.value === undefined ||
        input.value === "" ||
        input.value === null
      ) {
        this.isVoucherAmount = false;
        input.setCustomValidity(requiredMessage);
        input.reportValidity();
      } else if(input.value<=0.00){
        this.isVoucherAmount = false;
        input.setCustomValidity(`${input.label} must be greater than 0.00`);
        input.reportValidity();
      }else {
        this.isVoucherAmount = this.isVoucherAmount ? true : false;
      }
    });
  }
}
amountInputTypeValidation() {
  const input = this.template.querySelector(".confirmAmount");
  let amount = this.template.querySelector(
    'lightning-input[data-name="amount"]'
  ).value;
  let confirmAmount = this.template.querySelector(
    'lightning-input[data-name="confirm amount"]'
  ).value;
  if (amount !== confirmAmount) {
    this.isValidateAmount = false;
      input.setCustomValidity(' ');
    input.reportValidity();
      this.hasError =true;
  } else {
    input.setCustomValidity("");
    input.reportValidity();
    this.isValidateAmount = true;
      this.hasError =false;
  }
}

  async isGoodwillLimitExceededFn() {
    let voucherAmount = this.template.querySelector("[data-id='voucher-amount']").value;
    try{
      this.isValidAmount = (this.voucherMaxLimit && (voucherAmount <= this.voucherMaxLimit)) ? true : false;
      if (this.isValidAmount === false && voucherAmount !== undefined) {
        this.isLimitExceeded = true;
        this.voucherAmountError = ASDAC_VoucherAmountError;
      } else {
        this.isLimitExceeded = false;
        this.voucherAmountError = '';
      }
    }
    catch (error){
      console.log("Error");
      if(error.body && error.body.message){
        this.error = error.body.message;

      }
    }
  }

  async getVoucherCodeFn() {
    try{
      let response = await doWalletIdentity({accId: this.recordId, strVoucherType: voucherType, gw: this.getVoucherRecord });
      let voucherData = JSON.parse(response);
      this.getVoucherRecord.Voucher_Code__c = this.getVoucherRecord.BusinessArea__c === 'George' ? voucherData.gift_certificate_code : voucherData.accountId;
    } catch(error){
      let message;
      try {
          message = JSON.parse(error.body.message).message;
      } catch (e) {
          message = error.body.message;
        }
      this.hasTechnicalErrorOccurred = true;
      const event = new ShowToastEvent({
        variant: "error",
        title: "Error",
        message
      });
      this.dispatchEvent(event);
    }
}

  async handleSubmit(event) {
  this.isButtonClicked = true;
  event.preventDefault();
  //reason should be require
  this.validateReasonField();
  //notes should be required
  this.validateNotesField();
  // amount enter should be require
  this.validateAmountInputField();
    // validate all amount validations
  if (this.fieldVisible === true && this.isVoucherAmount) {
    this.amountInputTypeValidation();
  }

    let options = this.template.querySelector('lightning-radio-group[data-name="optionTypes"]').value;

    if (options === "option2") {
      this.getVoucherRecord.Types__c = 'Dynamic';
    } else {
      this.getVoucherRecord.Types__c = 'Regular';
    }

    await this.isGoodwillLimitExceededFn();
    this.getVoucherRecord.Email__c = this.email;
  this.getVoucherRecord.CaseId__c = this.caseRecordId;
  this.getVoucherRecord.AccountId__c = this.recordId;

    let lstflowObj= [];
    let flowObj ={
      refundReason : this.getVoucherRecord.ReasonCode__c
    };
    lstflowObj.push(flowObj);
    this.refundToCreateStr = JSON.stringify(lstflowObj);

    if (this.isNotesValid && this.isReasonValid && this.isVoucherAmount && this.isValidateAmount && !this.isLimitExceeded) {
      await this.getVoucherCodeFn();
      this.goodwillRecVariable = JSON.stringify(this.getVoucherRecord);
      this.voucherCode = this.getVoucherRecord.Voucher_Code__c;
      this.reason = this.getVoucherRecord.ReasonCode__c;
      this.voucherValue = this.getVoucherRecord.VoucherAmount__c;
      this.customerName = this.name;
      if (this.availableActions.find((action) => action === "NEXT")) {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
        }
  }
  this.isButtonClicked = false;
}
}