import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import retrieveMediaFromCMS from "@salesforce/apex/ASDAC_NavigationMenuItemsController.retrieveMediaFromCMS";
import { dispatchEventOnClick, dispatchEventOnLoad, genericClickFunction, pageLoadFunction, getDataLayerMetadata, ANNOUNCEMENTS_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacAnnouncementsListCmp extends NavigationMixin(
  LightningElement
) {
  @api cmsContentType;
  @api maxPageSize;
  channelName = "Help";
  newsCMSContentList = [];
  masterLabel = ANNOUNCEMENTS_LABEL;
  announcementMetadataDataLayer;
  adobeMetadata;
  userData;


  get isAnnouncementPresent() {
    return this.newsCMSContentList.length > 0;
  }


  async connectedCallback() {
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords && !window.location.href.includes('redirectPage')) {
      this.announcementMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
      setTimeout(() => {
      let announcementAnalyticsDetail = pageLoadFunction(this.announcementMetadataDataLayer, this.adobeMetadata?.userDetails);
      dispatchEventOnLoad(announcementAnalyticsDetail, this.announcementMetadataDataLayer.OnloadEventName__c);
      }, 50);
    }
  }

  @wire(retrieveMediaFromCMS, {
    channelName: "$channelName",
    maxPageSize: "$maxPageSize",
    contentType: "$cmsContentType"
  })
  wiredNewsContents({ error, data }) {
    if (data && !this.isLoaded) {
      this.newsCMSContentList = JSON.parse(JSON.stringify(data));
      this.error = undefined;
      this.isLoaded = true;
    } else if (error) {
      this.error = error;
      this.menuItems = [];
      this.isLoaded = true;
    }
  }

  handleNavigateToRecord(event) {
    event.preventDefault();
    const contentType = event.target.getAttribute("content-type");
    const contentId = event.target.getAttribute("content-id");
    const contentURL = event.target.getAttribute("content-url");
    const contentTitle = event.target.getAttribute("content-title");
    this[NavigationMixin.Navigate]({
      type: "standard__managedContentPage",
      attributes: {
        contentTypeName: contentType,
        contentKey: contentURL + '-' + contentId
      }
    });
    const announcementURL= window.location.href+contentType+`/`+contentURL + '-' + contentId;
    if(this.announcementMetadataDataLayer){
      let announcementAnalyticsDetail = genericClickFunction(contentTitle, announcementURL, this.announcementMetadataDataLayer);
      dispatchEventOnClick(announcementAnalyticsDetail, this.announcementMetadataDataLayer.OnclickEventName__c);
    }
  }
}