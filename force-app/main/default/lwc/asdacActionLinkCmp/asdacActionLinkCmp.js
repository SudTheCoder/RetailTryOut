import { LightningElement, api } from 'lwc';

export default class AsdacActionLinkCmp extends LightningElement {
    @api label;
    @api url;
    @api navigationType;
    @api recordId;
    @api contentType;

    get internalLinkPageURL(){
      return (this.navigationType==='InternalLink') && this.url;
    }
    get externalLink(){
      return (this.navigationType==='ExternalLink') && this.url;
    }
}