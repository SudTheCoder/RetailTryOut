import {api } from 'lwc';
import LightningModal from 'lightning/modal';
import { dispatchEventOnClick, genericClickFunction, getDataLayerMetadata, BRAND_SELECTION_LABEL} from "c/asdacSendDataToAdobeCmp";
import modal from '@salesforce/resourceUrl/BrandModal';
import { loadStyle} from 'lightning/platformResourceLoader';

export default class AsdacBrandSelectionModalCmp extends LightningModal {
  masterLabel = BRAND_SELECTION_LABEL;
  brandSelectionMetadataDataLayer;
  adobeMetadata;
  @api options = [];

  get brandSelectionItems(){
    return this.options.map(item=>{
      return{
        ...item,
        selectedClass:`slds-button slds-button_stretch slds-button_brand ${item.label === 'Groceries' ? 'button-grocery' : 'button-george'}`
      }; 
    })
  }
  
  async connectedCallback() {
    this.pageUrl = window.location.href;
    this.pageName = document.title;
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    Promise.all([
      loadStyle(this, modal)
  ])
  }

  trackData(event){
    event.stopPropagation();
    const {textContent}=event.target;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.brandSelectionMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === textContent);
    }
    if(this.brandSelectionMetadataDataLayer){
      const linkUrl = window.location.href + this.brandSelectionMetadataDataLayer.OnclickEventPageUrl__c;
      let brandSelectionAnalyticsDetail = genericClickFunction(textContent, linkUrl, this.brandSelectionMetadataDataLayer);
      dispatchEventOnClick(brandSelectionAnalyticsDetail, this.brandSelectionMetadataDataLayer.OnclickEventName__c);
      this.close(`/${this.brandSelectionMetadataDataLayer.OnclickEventPageUrl__c}`);
    }
  }
}