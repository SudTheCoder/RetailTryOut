import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { dispatchEventOnClick, genericClickFunction} from "c/asdacSendDataToAdobeCmp";

export default class AsdacNavigationMenuItem extends NavigationMixin(
    LightningElement
) {
    /**
     * The NavigationMenuItem from the Apex controller,
     * contains a label and a target.
     */
    @api item = {};
    @api headerMetadataDataLayer;
    @track href = '#';
    get isExternalURL(){
        return this.item.actionType === 'ExternalLink'? true:false;
    }
    /**
     * the PageReference object used by lightning/navigation
     */
    pageReference;
    connectedCallback() {
        const { actionType, actionValue } = this.item;
        // get the correct PageReference object for the menu item type
        if (actionType === 'SalesforceObject') {
            // aka "Salesforce Object" menu item
            this.pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: actionValue
                },  
            };
        } else if (actionType === 'ExternalLink') {
            // aka "External URL" menu item
            this.pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: actionValue
                }
            };
        }
        // use the NavigationMixin from lightning/navigation to generate the URL for navigation.
        if (this.pageReference) {
            this[NavigationMixin.GenerateUrl](this.pageReference).then(
                (url) => {
                    this.href = url;
                }
            );
        }
    }

    handleNavigation(event) {
        this.dispatchEvent(new CustomEvent('navigation'));
        let data=event.target.dataset;
        const element = this.template.querySelector("c-asdac-custom-accordion-cmp");
        if (this.headerMetadataDataLayer && !element) {
            let headerAnalyticsDetail = genericClickFunction(data.label, data.url, this.headerMetadataDataLayer);
            dispatchEventOnClick(headerAnalyticsDetail, this.headerMetadataDataLayer.OnclickEventName__c);
          }
    }
    
}