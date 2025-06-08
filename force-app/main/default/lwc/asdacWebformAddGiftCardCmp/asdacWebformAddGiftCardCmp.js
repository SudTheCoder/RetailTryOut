import { LightningElement, api, track } from "lwc";
export default class AsdacWebformAddGiftCardCmp extends LightningElement {
  @api maxGiftCards = 10;
  @api giftCardNumberLabel;
  @track _giftcards = [];

  connectedCallback() {
    this.dispatchEvent(new CustomEvent("webformload", { bubbles: true }));

    if (this._giftcards.length === 0) {
      this.addGiftcard();
    }
  }

  @api
  get giftcardsCaseDescription() {
    let giftcards;
    giftcards = this._giftcards.map(({giftcardnumber}) => {
        return {
          "Gift Card Number": giftcardnumber
        };
      });
    
    const giftcardsData = giftcards.map((giftcard) => JSON.stringify(giftcard).replaceAll(/[{}"]/g, '')).join('\n');
    return giftcardsData;
  }

  @api
  get giftcards() {
    const giftcards = this._giftcards.map(({giftcardnumber}) => ({ giftcardnumber}));
    return JSON.stringify(giftcards);
  }

  set giftcards(giftcardsJson) {
    const giftcards = JSON.parse(giftcardsJson);
    const addGiftcard = (giftcard) => this.addGiftcard(giftcard.giftcardnumber);
    this._giftcards = [];
    (giftcards || []).forEach(addGiftcard);
    setTimeout(() => {
      this.template.querySelectorAll("lightning-input").forEach((el) => el.reportValidity());
    }, 100);
  }

  get disableAddGiftcard() {
    return this._giftcards.length >= this.maxGiftCards;
  }

  addGiftcard(giftcardnumber = "") {
    if (this.disableAddGiftcard) {
      return;
    }
    const giftcard = {
      id: window.crypto.randomUUID(),
      giftcardnumber,
      removable: this._giftcards.length !== 0,
    };
    this._giftcards.push(giftcard);
  }

  removeGiftcard(evt) {
    const index = evt.target.dataset.index;
    this._giftcards.splice(index, 1);
  }

  handleChange(evt) {
    const index = evt.target.dataset.index;
    const field = evt.target.name.replace("giftcard-", "");
    let value = evt.detail.value;
    this._giftcards[index][field] = value;
  }
  @api validate() {
    let regex = /^\d+$/;
    for (let giftcard of this._giftcards) {
      if (!(giftcard.giftcardnumber) || !(regex.test(giftcard.giftcardnumber))) {
        return { isValid: false, errorMessage: "" };
      }
    }
    return { isValid: true };
  }
}