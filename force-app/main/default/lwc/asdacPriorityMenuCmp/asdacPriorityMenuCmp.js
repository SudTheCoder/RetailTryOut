import { LightningElement } from "lwc";
import { dispatchEventOnClick, genericSearchClickFunction, getDataLayerMetadata, HOW_CAN_WE_HELP_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacPriorityMenuCmp extends LightningElement {
  pageUrl;
  pageName;
  menuTiles = [
    { Id: 0, label: "Payments and charges", pageApiName: "Payments_and_charges__c" },
    { Id: 1, label: "Asda Rewards" , pageApiName: "Asda_Rewards__c"}
  ];

  async connectedCallback() {
    setTimeout(() => {
    this.pageUrl = window.location.href;
    this.pageName = document.title;
  }, 50);
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
  }

  trackData(event){
    let data=event.target.dataset;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.dataLayerMetadataRecord = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === HOW_CAN_WE_HELP_LABEL);
    }

    if(this.dataLayerMetadataRecord){
      let linkurl = window.location.href;
      const contentSearchData = {
        contentSearchSuggestionData: null,
        contentSearchResultsData: {
        pageUrl : this.pageUrl,
        pageName : this.pageName
        }
      }
      const dataLayerAnalyticsDetail = genericSearchClickFunction(data.title, linkurl, '', this.dataLayerMetadataRecord, contentSearchData);
      dispatchEventOnClick(dataLayerAnalyticsDetail, this.dataLayerMetadataRecord.OnclickEventName__c);
    }
  }
}