import { api, LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import basePath from "@salesforce/community/basePath";

export default class AsdacHelpNavigationCmp extends NavigationMixin(LightningElement) {
  @api pageApiName;
  @api attributes = ""; // Format: key1=value1,key2=value2...
  @api recordId;
  @api recordName;
  @api object = "Knowledge__kav";
  @api contentType;
  @api urlAlias;
  @api params = ""; // Format: key1=value1,key2=value2...
  @api replace = false;
  @api button = false;
  @api internalLink;
  @api externalLink;
  url;

  get linkClass() {
    return this.button ? "button" : "link";
  }

  get state() {
    const state = (this.params || "").split(",").reduce((state, el) => {
      const [key, value] = el.split("=");
      if (key) {
        state[key] = value;
      }
      return state;
    }, {});
    return state;
  }

  get pageReference() {
    const pageReference = {};
    if (this.contentType && this.contentType !== 'faq') {
      pageReference.type = "standard__managedContentPage";
      pageReference.attributes = {
        contentTypeName: this.contentType,
        urlAlias: this.urlAlias
      };
    } else if (this.recordId) {
      pageReference.type = "standard__recordPage";
      pageReference.attributes = {
        recordId: this.recordId,
        urlName: this.urlAlias,
        objectApiName: this.object,
        actionName: "view"
      };
    } else if (this.externalLink) {
      pageReference.type = "standard__webPage";
      pageReference.attributes = {
        url: this.externalLink
      };
    } else if (this.internalLink) {
      const internalPageURL = this.internalLink.startsWith(basePath) ? this.internalLink : basePath + this.internalLink;
      pageReference.type = "standard__webPage";
      pageReference.attributes = {
        url: internalPageURL
      };
    } else {
      const attributes = (this.attributes || "").split(",").reduce((attr, el) => {
        const [key, value] = el.split("=");
        if (key) {
          attr[key] = value;
        }
        return attr;
      }, {});
      pageReference.type = "comm__namedPage";
      pageReference.attributes = attributes;
      pageReference.attributes.name = this.pageApiName || "Home";
    }
    pageReference.state = this.state;
    return pageReference;
  }

  renderedCallback() {
    this[NavigationMixin.GenerateUrl](this.pageReference).then((url) => (this.url = url));
  }

  navigate(evt) {
    evt.preventDefault();
    this[NavigationMixin.Navigate](this.pageReference, this.replace);
    if (!this.externalLink) window.scrollTo({ left: 0, top: 0 });
  }
}