import { api, LightningElement } from "lwc";
import { dispatchEventOnClick, genericClickFunction, getDataLayerMetadata } from "c/asdacSendDataToAdobeCmp";
import MyModal from 'c/asdacBrandSelectionModalCmp';
import { NavigationMixin } from 'lightning/navigation';

export default class AsdacMenuItemCmp  extends NavigationMixin(LightningElement){
  @api label = "";
  @api noBorder = false;
  showModal = false;
  dataLayerMetadataRecord;
  adobeMetadata;

  get isHelpWithAnOrder() {
    return this.label === 'Help with an order';
  }

    async connectedCallback() {
      sessionStorage.removeItem("searchData");
      if(this.label === 'Help with an order'){
      if (!window.dataLayer) {
        window.dataLayer = await getDataLayerMetadata();
      }
      this.adobeMetadata = window.dataLayer;
      if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
        this.dataLayerMetadataRecord = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.label);
      }
    }
    }

  get buttonClass() {
    return "slds-button slds-button_outline-brand menu-button" + (this.noBorder ? " no-border" : "");
  }
    openModal() {
     MyModal.open({
      size: 'small',
      label: "Modal Heading",
      options: [
        { id: 1, label: 'Groceries'},
        { id: 2, label: 'George'},
      ]
    }).then((result) => {
        if(result){
          const navigateToUrl = result;
          if (navigateToUrl) {
              this.handleNavigate(navigateToUrl);
          }
        }
    });
    if(this.dataLayerMetadataRecord){
      let dataLayerAnalyticsDetail = genericClickFunction(this.label, '', this.dataLayerMetadataRecord);
      dispatchEventOnClick(dataLayerAnalyticsDetail, this.dataLayerMetadataRecord.OnclickEventName__c);
    }
  }

  handleNavigate(urlValue) {
    if (urlValue) {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: urlValue
        }
      });
    }
  }
}