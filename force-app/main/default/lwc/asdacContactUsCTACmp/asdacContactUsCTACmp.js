import { LightningElement, api, wire } from "lwc";
import getNavigationMenuItems from "@salesforce/apex/ASDAC_NavigationMenuItemsController.getNavigationMenuItems";
import ASDAC_ContactUsTitle from "@salesforce/label/c.ASDAC_ContactUsTitle";
import ASDAC_ContactUsSocialTitle from "@salesforce/label/c.ASDAC_ContactUsSocialTitle";
import { dispatchEventOnClick, dispatchEventOnLoad, pageLoadFunction, contactUsButtonsClickFunction, getDataLayerMetadata, SOCIAL_ICON_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacContactUsCTACmp extends LightningElement {
  @api socialsMenuName;
  socialsMenu = [];
  masterLabel = SOCIAL_ICON_LABEL;
  contactUsSocialIconsMetadata;
  adobeMetadata;
  labels = {
    title: ASDAC_ContactUsTitle,
    socialTitle: ASDAC_ContactUsSocialTitle
  };

  @wire(getNavigationMenuItems, { menuName: "$socialsMenuName", channelName: "Help" })
  wiredMenuItems({ data }) {
    if (data) {
      this.socialsMenu = data[0].navigationalMenuItems.map((menuItem) => {
        const socials = (menuItem.subMenu || []).map(({ label, actionValue }) => ({ icon: label, link: actionValue }));
        return {
          label: menuItem.label,
          socials
        };
      });
    }
  }

  async connectedCallback() {
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.contactUsSocialIconsMetadata = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
      const contactUsSocialIconsAnalyticsDetail = pageLoadFunction(this.contactUsSocialIconsMetadata, this.adobeMetadata?.userDetails);
      dispatchEventOnLoad(contactUsSocialIconsAnalyticsDetail, this.contactUsSocialIconsMetadata.OnloadEventName__c);
    }
  }

  trackData(event){
    const iconDetail = event.currentTarget.dataset;
    if(this.contactUsSocialIconsMetadata){
      const subsectionName=this.contactUsSocialIconsMetadata?.SubsectionName__c +`${iconDetail.menu}`;
      const contactUsSocialIconsAnalyticsDetail = contactUsButtonsClickFunction(iconDetail.title, iconDetail.url, this.contactUsSocialIconsMetadata, subsectionName);
      dispatchEventOnClick(contactUsSocialIconsAnalyticsDetail, this.contactUsSocialIconsMetadata.OnclickEventName__c);
    }
  }
}