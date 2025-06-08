import { LightningElement, api } from "lwc";
import { dispatchEventOnClick, genericSearchClickFunction, getDataLayerMetadata, webformInitiationFunction, WEBFORM_LABEL, INTERNALLINK_CLICK_LABEL, YOUR_ORDERS_LABEL, GEORGE_BRAND_LABEL, GROCERY_BRAND_LABEL } from "c/asdacSendDataToAdobeCmp";
import ASDAC_HCWebformPagesMap from "@salesforce/label/c.ASDAC_HCWebformPagesMap";

export default class AsdacGeorgeHelpCmp extends LightningElement {
    @api internationalOrderPageURL;
    @api georgeOrdersURL;
    @api returnAndExChangeFAQUrlAlias;
    dataLayerMetadataRecord;
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
    }

    trackData(event) {
        let data = event.target.dataset;
        const linkName = event.target.textContent;
        let linkUrl = data.url;
        let isRecommendedLinkClick = event.target.classList.contains('underlineLink');
        let webformName = '';
        const webformMapList = JSON.parse(ASDAC_HCWebformPagesMap.replaceAll(/\r\n/g, ''))[0];
        let dataLayerMetadataRecordCopy;
        let datalayerMetadataLabel;

        if (webformMapList[linkUrl]) {
            webformName = webformMapList[linkUrl];
          }
        if(isRecommendedLinkClick){
            datalayerMetadataLabel = webformName ? WEBFORM_LABEL : INTERNALLINK_CLICK_LABEL;
        }
        else {
            datalayerMetadataLabel = YOUR_ORDERS_LABEL;
        }
        let brand = document.title.includes(GEORGE_BRAND_LABEL) ? GEORGE_BRAND_LABEL : GROCERY_BRAND_LABEL;
        if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
            this.dataLayerMetadataRecord = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === datalayerMetadataLabel);
            dataLayerMetadataRecordCopy = { ...this.dataLayerMetadataRecord };
        }
        if (this.dataLayerMetadataRecord) {
            dataLayerMetadataRecordCopy.OnclickEventSubtype__c = isRecommendedLinkClick ? this.dataLayerMetadataRecord.OnclickEventSubtype__c : (brand + ' ' + this.dataLayerMetadataRecord.OnclickEventSubtype__c);
            const contentSearchData = {
                contentSearchSuggestionData: null,
                contentSearchResultsData: {
                pageUrl : this.pageUrl,
                pageName : this.pageName
                }
              }
            const dataLayerAnalyticsDetail = isRecommendedLinkClick && webformName ? webformInitiationFunction(linkUrl, linkUrl, webformName, this.dataLayerMetadataRecord) : genericSearchClickFunction(linkName, linkUrl, '', dataLayerMetadataRecordCopy, contentSearchData);
            dispatchEventOnClick(dataLayerAnalyticsDetail, this.dataLayerMetadataRecord.OnclickEventName__c);
        }
    }
}