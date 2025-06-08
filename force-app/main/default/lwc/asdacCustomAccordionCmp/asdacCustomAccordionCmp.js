import { api, LightningElement } from "lwc";
import { dispatchEventOnClick, genericClickFunction } from "c/asdacSendDataToAdobeCmp";

export default class AsdacCustomAccordionCmp extends LightningElement {
@api menuItem;
isAccordionCollapsed;
accordionIcon="utility:chevronright";
@api headerMetadataDataLayer;

get sectionClass() {
  return this.isAccordionCollapsed ? 'slds-section slds-is-open' : 'slds-section';
}

handleClick(event){
  event.preventDefault();
  this.isAccordionCollapsed = !this.isAccordionCollapsed;
  this.accordionIcon= (this.isAccordionCollapsed)?"utility:chevrondown":"utility:chevronright";
}
//onclick of the hyperlink
handleNavigation(event) {
  this.dispatchEvent(new CustomEvent('navigation'));
    if(this.headerMetadataDataLayer){
        let data=event.target.dataset;
        let parser = new DOMParser();
        let doc = parser.parseFromString(data.title, 'text/html');
        let title = doc.documentElement.textContent;
        let headerAnalyticsDetail=genericClickFunction(title,data.url,this.headerMetadataDataLayer);
        dispatchEventOnClick(headerAnalyticsDetail, this.headerMetadataDataLayer.OnclickEventName__c);
      }
}
}