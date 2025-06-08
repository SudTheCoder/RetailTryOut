import { LightningElement ,api } from 'lwc';
import { dispatchEventOnClick, webformSubmitClickFunction, getDataLayerMetadata, WEBFORM_LABEL, WEBFORM_LINK_NAME } from "c/asdacSendDataToAdobeCmp";
import ASDAC_ContactUsMailLink from "@salesforce/label/c.ASDAC_ContactUsMailLink";

export default class AsdacWebformDataLayerCmp extends LightningElement {
  @api caseObject;
  @api formTitle;
  @api status;
  @api errorMessage;
  @api journeyName;
  webformDataLayer;
  adobeMetadata;
  masterLabel=WEBFORM_LABEL;
  asdaDigitaldata={};
  eventName;

  async connectedCallback() {
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.webformDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
    }
    if(this.webformDataLayer){
      const formSubmitDetail={
        linkName:WEBFORM_LINK_NAME,
        formTitle:this.formTitle,
        status:this.status,
        errorMessage:this.errorMessage,
        journeyName:this.journeyName,
        datalayerObj:this.webformDataLayer
      }
      if(!window.location.href.includes(ASDAC_ContactUsMailLink)){
        sessionStorage.removeItem("webformInformation");
      }
      const webformAnalyticsDetail = webformSubmitClickFunction(formSubmitDetail);
      dispatchEventOnClick(webformAnalyticsDetail, this.webformDataLayer.OnclickEventName__c);
    }
  }
}