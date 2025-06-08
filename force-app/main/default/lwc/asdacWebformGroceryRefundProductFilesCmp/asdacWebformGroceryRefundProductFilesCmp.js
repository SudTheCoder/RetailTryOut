import { LightningElement, api, track } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import ASDAC_GroceryRefundReasonPicklistOptions from "@salesforce/label/c.ASDAC_GroceryRefundReasonPicklistOptions";
import ASDAC_WebformAttachmentUploadDisclaimerText from "@salesforce/label/c.ASDAC_WebformAttachmentUploadDisclaimerText";
import ASDAC_AttachmentFileSizeLimit from "@salesforce/label/c.ASDAC_AttachmentFileSizeLimit";
import ASDAC_AttachmentsTotalFileSizeLimit from "@salesforce/label/c.ASDAC_AttachmentsTotalFileSizeLimit";
import ASDAC_AttachmentFileSizeLimitExceededErrorMessage from "@salesforce/label/c.ASDAC_AttachmentFileSizeLimitExceededErrorMessage";
import ASDAC_AttachmentsTotalFileSizeLimitExceededErrorMessage from "@salesforce/label/c.ASDAC_AttachmentsTotalFileSizeLimitExceededErrorMessage";
import ASDAC_FileNameRestriction from "@salesforce/label/c.ASDAC_FileNameRestriction";


// eslint-disable-next-line @lwc/lwc/no-leading-uppercase-api-name
export default class AsdacWebformGroceryRefundProductFilesCmp extends LightningElement {
  @api maxProducts = 10;
  @api maxProductQuantity = 999;
  @api uploadAttachmentLabel;
  @api productNameLabel;
  @api productPriceLabel;
  @api productDescriptionLabel;   
  @api ProductQuantityLabel;
  @api productSizeLabel = 'Product Size';
  @api refundRequestReasonLabel;
  @api accept = '.png,.jpeg,.jpg';
  @track _products = [];
  @api isForSecurityTag = false;
  @api isProductQueryFlow=false;
  attachments = [];
  _contentVersions = [];
  loading = false;
  errorMessage = [];
  validity = true;

  get refundRequestReasonOptions() {
    const refundReason= ASDAC_GroceryRefundReasonPicklistOptions.split(',').map(item=>{
      return{
        label:item,
        value:item
      };
    });
    return refundReason;
  }

  get quantityValidation() {
    return `Item Quantity can't be greater than ${this.maxProductQuantity} or less than 1`;
  }

  get attachmentUploadDisclaimer(){
    return ASDAC_WebformAttachmentUploadDisclaimerText;
  }

  connectedCallback() {
    if (this._products.length === 0) {
      this.addProduct();
    }
  }

  @api
  get caseDescription() {
    let products;
    if (this.isForSecurityTag) {
      products = this._products.map(({ name, size, quantity }) => {
        return {
          "Product Name": name,
          "Product Size": size,
          "Product Quantity": quantity
        }
      });
    } else if (this.isProductQueryFlow) {
        products = this._products.map(({ name, price, description }) => {
          return {
            "Product Name": name,
            "Product Price": price,
            "Product Description": description
          }
        });
      }
    else {
      products = this._products.map(({ name, refundRequestReason, quantity }) => {
        return {
          "Product Name": name,
          "Refund Reason": refundRequestReason,
          "Product Quantity": quantity
        }
      });
    }
    
    const productsData = products.map(product => JSON.stringify(product, null, 2).replaceAll(/[{}"]/g, '')).join('');
    return productsData;
  }

  @api
  get products() {
    const products = this._products.map(({ name, refundRequestReason, quantity, size, price, description }) => ({ name, refundRequestReason, quantity, size, price, description }));
    return JSON.stringify(products);
  }

  set products(productsJson) {
    const products = JSON.parse(productsJson);
    const addProduct = (product) => this.addProduct(product.name, product.refundRequestReason, product.quantity,product.size,product.price,product.description);
    this._products = [];
    (products || []).forEach(addProduct);
    setTimeout(() => {
      this.template.querySelectorAll("lightning-input,lightning-combobox").forEach((el) => el.reportValidity());
    }, 100);
  }

  @api
  get files() {
    return this._contentVersions;
  }

  set files(contentVersions) {
    this._contentVersions = contentVersions;
    this.validity = true;
    this.errorMessage = [];
    let emptyFileNames = '';
    this.attachments = contentVersions.map((cv) => {
      if (!cv.VersionData) {
        // add error
        this.validity = false;
        emptyFileNames += ', '+cv.Title;
      }

      return { 
        name: cv.Title, contentVersion: cv 
      };
    });
    emptyFileNames && this.errorMessage.push('Empty file(s) - '+emptyFileNames.replace(',',''));
  }

  get disableAddProduct() {
    return this._products.length >= this.maxProducts;
  }

  addProduct(name = "", refundRequestReason = "", quantity = "",size="",price="",description="") {
    if (this.disableAddProduct) {
      return;
    }
    const product = {
      id: window.crypto.randomUUID(),
      name,
      refundRequestReason,
      quantity,
      removable: this._products.length !== 0,
      size:size,
      price,
      description,  
    };
    this._products.push(product);
  }

  removeProduct(evt) {
    const index = evt.target.dataset.index;
    this._products.splice(index, 1);
  }

  handleChange(evt) {
    const index = evt.target.dataset.index;
    const field = evt.target.name.replace("product-", "");
    let value = evt.detail.value;
    if (evt.target.type === "number") {
      value = Number(value);
    }
    this._products[index][field] = value;
  }

  async handleAttachments(evt) {
    this.loading = true;
    this.attachments = evt.detail.value;
    try {
      this.errorMessage = [];
      let emptyFileNames = '';
      this.validity = true;
      let thisThis = this;
      const files = await Promise.all(
        this.attachments.map(async function (file) {
          if (file.contentVersion) {
            return file.contentVersion;
          }
          let versionDataString = window.btoa(new Uint8Array(await file.arrayBuffer()).reduce((data, byte) => data + String.fromCharCode(byte), ""));
          if (!versionDataString) {
            // add error
            thisThis.validity = false;
            emptyFileNames += ', '+file.name;
            thisThis.errorMessage += 'Empty file - '+file.name+' ';
          }
          return {
            FirstPublishLocationId: "",
            ContentLocation: "S",
            PathOnClient: file.name,
            Title: file.name,
            VersionData: versionDataString,
            ContentSize: file.size
          };
        })
      );
      emptyFileNames && thisThis.errorMessage.push('Empty file(s) - '+emptyFileNames.replace(',',''));
      this._contentVersions = files;
      const attributeChangeEvent = new FlowAttributeChangeEvent("files", files);
      this.dispatchEvent(attributeChangeEvent);
      this.loading = false;
    } catch (error) {
      console.error(error);
    }
  }

  @api validate() {
    let totalFileSize = 0;
    let isAttachmentFileSizeLimitExceeded = false;
    let fileSizeLimitExceededAttachmentNames = '';
    let invalidFileNames = '';
    let isInvalidAttachmentTitleFlag = false;
    const attachmentNamePattern = /^[a-zA-Z0-9\s\-\.]+$/;
    for (let product of this._products) {
      if (((!(product.name && product.quantity > 0 && product.quantity <= this.maxProductQuantity)) || (this.isForSecurityTag && !(product.size.trim())) || (!this.isForSecurityTag && !product.refundRequestReason)) && !(this.isProductQueryFlow) ) {
        this.validity = false;
      } 
      if ((this.isProductQueryFlow) && (!(product.name && product.price && product.description) || (product.price < 0))){  
        this.validity = false;
      } 
    }
    for (let cv of this._contentVersions) {
      if(!attachmentNamePattern.test(cv.Title)){
        this.validity = false;
        invalidFileNames += ', '+cv.Title;
        isInvalidAttachmentTitleFlag=true;
      }
      if (cv.ContentSize > ASDAC_AttachmentFileSizeLimit) {
        this.validity = false;
        isAttachmentFileSizeLimitExceeded = true;
        fileSizeLimitExceededAttachmentNames += ', '+cv.Title;
      }
      totalFileSize = totalFileSize + cv.ContentSize;
    }

    isInvalidAttachmentTitleFlag && this.errorMessage.push(isInvalidAttachmentTitleFlag ? ASDAC_FileNameRestriction.replace('{}',invalidFileNames.replace(',','')) : '');

    isAttachmentFileSizeLimitExceeded && this.errorMessage.push(isAttachmentFileSizeLimitExceeded ? (ASDAC_AttachmentFileSizeLimitExceededErrorMessage+' -'+fileSizeLimitExceededAttachmentNames.replace(',',''))+'. ' : '');

    if (totalFileSize > ASDAC_AttachmentsTotalFileSizeLimit && this._contentVersions.length > 1) {
      this.validity = false;
      this.errorMessage.push(ASDAC_AttachmentsTotalFileSizeLimitExceededErrorMessage);
    }
    return { isValid: this.validity, errorMessage: this.errorMessage.join('<br>') };  
  }
}