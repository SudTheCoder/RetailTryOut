import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import ASDAC_StoreLocatorBaseURL from "@salesforce/label/c.ASDAC_StoreLocatorBaseURL";
import ASDAC_StoreLocatorWidgetTitle from "@salesforce/label/c.ASDAC_StoreLocatorWidgetTitle";
import ASDAC_StoreLocatorWidgetText from "@salesforce/label/c.ASDAC_StoreLocatorWidgetText";
import currentUserLanguage from "@salesforce/i18n/lang";
import ASDAC_StoreLocatorErrorMessage from "@salesforce/label/c.ASDAC_StoreLocatorErrorMessage";
import { dispatchEventOnClick, genericSearchClickFunction, getDataLayerMetadata, FIND_ASDA_STORE_LABEL, STORE_SEARCH_ICON, SEARCH_TERM_EMPTY_LABEL } from "c/asdacSendDataToAdobeCmp";
export default class AsdacStoreLocatorWidget extends NavigationMixin(
  LightningElement
) {
  @api title;
  @api description;
  searchValue;
  StoreLocatorUrlToBeRedirected;
  labels;
  masterLabel = FIND_ASDA_STORE_LABEL;
  findAsdaStoreMetadataDataLayer;
  adobeMetadata;
  ErrorMessage = ASDAC_StoreLocatorErrorMessage;

  async connectedCallback() {
    this.labels = {
      isYextStoreLocator: this.title ? false : true,
      title: this.title ? this.title : ASDAC_StoreLocatorWidgetTitle,
      description: this.description ? this.description : ASDAC_StoreLocatorWidgetText
    }
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.findAsdaStoreMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
    }
  }

  handleEnter(event){
    if(event.keyCode === 13){
      this.handleSearch(event);
    }
  }
  
  handleChange(event) {
    this.searchValue = event.detail.value;
    if (this.labels.isYextStoreLocator) {
      this.StoreLocatorUrlToBeRedirected =
        ASDAC_StoreLocatorBaseURL +
        "?q=" +
        this.searchValue +
        "&qp=" +
        this.searchValue +
        "&l=" +
        currentUserLanguage;
    }
  }

  validateInputs() {
    let isValid = true;
    let searchString = this.template.querySelector(".searchString");
    const searchInputValue = this.searchValue;
    if (!searchInputValue || !searchInputValue.trim()) {
      this.searchValue = "";
      setTimeout(() => {
        searchString.reportValidity();
      }, 50);
      return false;
    }
    return isValid;
  }

  handleSearch(event) {
    let searchTerm;
    if(this.searchValue?.trim()){
      searchTerm = this.searchValue;
    } else {
      searchTerm = SEARCH_TERM_EMPTY_LABEL;
    }
    if(this.findAsdaStoreMetadataDataLayer){
      let url = this.searchValue?.trim() ? this.StoreLocatorUrlToBeRedirected.replaceAll(' ','%20') : '';
      let findAsdaStoreAnalyticsDetail = genericSearchClickFunction(STORE_SEARCH_ICON, url, searchTerm, this.findAsdaStoreMetadataDataLayer, null);
      dispatchEventOnClick(findAsdaStoreAnalyticsDetail, this.findAsdaStoreMetadataDataLayer.OnclickEventName__c);
    }
    event.preventDefault();
    event.stopPropagation();
    if (!this.validateInputs()) {
      return false;
    }
    if (this.labels.isYextStoreLocator) {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: this.StoreLocatorUrlToBeRedirected
        }
      });
    }
  }
}