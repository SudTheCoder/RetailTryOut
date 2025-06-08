import { LightningElement, api, wire } from 'lwc';
import getNavigationMenuItems from '@salesforce/apex/ASDAC_NavigationMenuItemsController.getNavigationMenuItems';
import { dispatchEventOnClick, genericClickFunction, getDataLayerMetadata, FOOTERCLICKS_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class Footer extends LightningElement {
    @api menuName;
    channelName = 'Help';
    menuItemData = [];
    footerMetadataDataLayer;
    masterLabel = FOOTERCLICKS_LABEL;
    adobeMetadata;

    get copyrightInfo(){
      return `© ASDA ${new Date().getFullYear()}`;
    }

    async connectedCallback() {
        if (!window.dataLayer) {
          window.dataLayer = await getDataLayerMetadata();
        }
        this.adobeMetadata = window.dataLayer;
        if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
          this.footerMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
        }
      }
    @wire(getNavigationMenuItems, {
        menuName: '$menuName',
        channelName: '$channelName'
    })
    wiredMenuItems({ data }) {
        if (data && !this.isLoaded) {
            this.menuItemData = data[0].navigationalMenuItems.map(menuItem => {
                let doc = new DOMParser().parseFromString(menuItem.label, "text/html");
                return {
                    ...menuItem,
                    label: doc.documentElement.textContent
                };
            });
        }
    }

    trackData(event){
        if(this.footerMetadataDataLayer){
           let data=event.target.dataset;
            let footerAnalyticsDetail=genericClickFunction(data.title,data.url,this.footerMetadataDataLayer);
            dispatchEventOnClick(footerAnalyticsDetail, this.footerMetadataDataLayer.OnclickEventName__c);
          }
    }
}