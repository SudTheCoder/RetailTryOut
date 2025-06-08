import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { dispatchEventOnClick, genericClickFunction } from "c/asdacSendDataToAdobeCmp";
export default class AsdacLoginCmp extends NavigationMixin(LightningElement)
{
  @api userName;
  @api headerMetadataDataLayer;

  get isLoggedIn() {
    return this.userName ? true : false;
  }

  handleClick(event) {
    event.preventDefault();
    event.preventDefault();
    let buttonName = event.target.name;
    let communityPageToBeRedirected = 'Login';
    this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            name: communityPageToBeRedirected
        },
    }); 
    this.handleNavigation();   
      if (this.headerMetadataDataLayer) {
        let url = window.location.href  + `${communityPageToBeRedirected}`;
        let headerAnalyticsDetail = genericClickFunction(buttonName, url, this.headerMetadataDataLayer);
        dispatchEventOnClick(headerAnalyticsDetail, this.headerMetadataDataLayer.OnclickEventName__c);
      }
  }

  handleNavigation() {
    this.dispatchEvent(new CustomEvent('navigation'));
  }
}