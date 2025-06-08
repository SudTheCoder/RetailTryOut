import { LightningElement, api, wire } from 'lwc';
import retrieveMediaFromCMS from "@salesforce/apex/ASDAC_NavigationMenuItemsController.retrieveMediaFromCMS";
import { dispatchEventOnClick, genericClickFunction, getDataLayerMetadata, PROMOTIONAL_BANNER_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacPromotedBlockCmp extends LightningElement {
    @api cmsContentType;
    @api imageTitle;
    maxPageSize =250;
    channelName = "Help";
    imageCMSContent= [];
    isLoaded;
    url;
    imageLink;
    title;
    altText;
    isPromotedImagePresent= false;
    promotionalBannerMetadataDataLayer;
    masterLabel = PROMOTIONAL_BANNER_LABEL;
    adobeMetadata;

    async connectedCallback() {
      if (!window.dataLayer) {
        window.dataLayer = await getDataLayerMetadata();
      }
      this.adobeMetadata = window.dataLayer;
      if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
        this.promotionalBannerMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
      }
    }
      

    @wire(retrieveMediaFromCMS, {
      channelName: "$channelName",
      maxPageSize: "$maxPageSize",
      contentType: "$cmsContentType"
    })
    wiredContents({ error, data }) {
      if (data && !this.isLoaded) {
        this.imageCMSContent = JSON.parse(JSON.stringify(data));
        for(let row of this.imageCMSContent){
          if(row.title=== this.imageTitle){
          this.url=row.contentNodes.source?.unauthenticatedUrl;
          this.imageLink=row.contentNodes.thumbUrl?.value;
          this.isPromotedImagePresent=true;
          this.title= row.title;
          this.altText = row.contentNodes.altText?.value; 
          }
        }
        this.error = undefined;
        this.isLoaded = true;
      } else if (error) {
        this.error = error;
        this.imageCMSContent = [];
        this.isLoaded = true;
      }
    }

    trackData(){
      if(this.promotionalBannerMetadataDataLayer){
        let promotionalBannerAnalyticsDetail = genericClickFunction(this.altText, this.imageLink, this.promotionalBannerMetadataDataLayer);
        dispatchEventOnClick(promotionalBannerAnalyticsDetail, this.promotionalBannerMetadataDataLayer.OnclickEventName__c);
      }
    }
}