import { LightningElement, api } from "lwc";
import { dispatchEventOnClick, genericSearchClickFunction, getDataLayerMetadata, YOUR_ORDERS_LABEL, GEORGE_BRAND_LABEL, GROCERY_BRAND_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacGroceryHelpCmp extends LightningElement {
    @api groceryOrdersURL;
    yourOrderMetadataDataLayer;
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
        const buttonLabel = event.target.textContent;
        let subType;
        let brand = document.title.includes(GEORGE_BRAND_LABEL) ? GEORGE_BRAND_LABEL : GROCERY_BRAND_LABEL;
        let yourGroceryOrderMetadataDataLayer;
        if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
            this.yourOrderMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === YOUR_ORDERS_LABEL);
            yourGroceryOrderMetadataDataLayer = { ...this.yourOrderMetadataDataLayer };
        }
        if (this.yourOrderMetadataDataLayer) {
            subType = this.yourOrderMetadataDataLayer.OnclickEventSubtype__c;
            yourGroceryOrderMetadataDataLayer.OnclickEventSubtype__c = brand + ' ' + subType;
            const contentSearchData = {
                contentSearchSuggestionData: null,
                contentSearchResultsData: {
                pageUrl : this.pageUrl,
                pageName : this.pageName
                }
              }
            const yourGroceryOrderAnalyticsDetail = genericSearchClickFunction(buttonLabel, this.groceryOrdersURL, '', yourGroceryOrderMetadataDataLayer, contentSearchData);
            dispatchEventOnClick(yourGroceryOrderAnalyticsDetail, yourGroceryOrderMetadataDataLayer.OnclickEventName__c);
        }
    }
}