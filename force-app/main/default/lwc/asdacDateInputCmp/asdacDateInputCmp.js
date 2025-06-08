import { api, LightningElement } from "lwc";

export default class AsdacDateInputCmp extends LightningElement {
  @api name;
  @api label = "Date";
  _value = "";
  @api required = false;
  @api max;
  @api min;
  valid = true;
  errorMessage = "";

  @api
  get value() {
    return this._value;
  }

  set value(value) {
    if (value) {
      this._value = value;
    } else {
      this._value = "";
    }
  }

  get containerClass() {
    return "slds-form-element" + (this.valid ? "" : " slds-has-error");
  }

  handleChange(evt) {
    this.dispatchEvent(new CustomEvent("change", { detail: { value: evt.target.value } }));
  }

  @api
  reportValidity() {
    const inputElement = this.template.querySelector("input");
    const valid = inputElement.validity.valid;
    if (inputElement.validity.valueMissing) {
      this.errorMessage = "Complete this field.";
    } else if (!valid) {
      this.errorMessage = "Invalid date";
    } else {
      this.errorMessage = "";
    }
    this.valid = valid;
    return this.valid;
  }
}