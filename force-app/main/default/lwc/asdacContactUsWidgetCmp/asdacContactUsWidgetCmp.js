import { LightningElement } from 'lwc';
import ASDAC_ContactUsLabel from "@salesforce/label/c.ASDAC_ContactUsLabel";
import ASDAC_ContactUsText from "@salesforce/label/c.ASDAC_ContactUsText";
import ASDAC_ContactUsButtonLabel from "@salesforce/label/c.ASDAC_ContactUsTitle";
import { dispatchEventOnClick, genericSearchClickFunction, getDataLayerMetadata, CONTACT_US_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacContactUsWidgetCmp extends LightningElement {
  labels = {
    subject: ASDAC_ContactUsLabel,
    description: ASDAC_ContactUsText,
    buttonLabel: ASDAC_ContactUsButtonLabel
  };
  masterLabel = CONTACT_US_LABEL;
  contactUsMetadataDataLayer;
  adobeMetadata;
  
  async connectedCallback() {
    setTimeout(() => {
    this.pageUrl = window.location.href;
    this.pageName = document.title;
    }, 50);
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.contactUsMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
    }
  }
  trackData(event){
    const buttonLabel = event.target.textContent;
    if(this.contactUsMetadataDataLayer){
      let url = window.location.href;
      const contentSearchData = {
        contentSearchSuggestionData: null,
        contentSearchResultsData: {
        pageUrl : this.pageUrl,
        pageName : this.pageName
        }
      }
      let contactUsAnalyticsDetail = genericSearchClickFunction(buttonLabel, url, '', this.contactUsMetadataDataLayer, contentSearchData);
      dispatchEventOnClick(contactUsAnalyticsDetail, this.contactUsMetadataDataLayer.OnclickEventName__c);
    }
  }
}