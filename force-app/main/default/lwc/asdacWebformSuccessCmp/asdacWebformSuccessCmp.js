import { api, LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import ASDAC_WebformSuccess from "@salesforce/label/c.ASDAC_WebformSuccess";
import externalSitePermission from '@salesforce/customPermission/ASDAC_ExternalSitePermission';

export default class AsdacWebformSuccessCmp  extends NavigationMixin(
  LightningElement
) {
  @api successResponse;
  @api newRequestLabel;
  @api thanksMessageLabel;

  labels = {
    success: ASDAC_WebformSuccess
  };

  get accessedFromExternalSite(){
		return externalSitePermission;
	}

  connectedCallback(){
    if(this.thanksMessageLabel!==null){
      this.labels = {
        success: this.thanksMessageLabel ? this.thanksMessageLabel : ASDAC_WebformSuccess
      }
    }
  }

  handleNewRequest() {
    if(this.thanksMessageLabel){
      this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            name: 'Home'
        }
      });
    }
    else{
      const event = new CustomEvent("newrequest", {});
      this.dispatchEvent(event);
    }
  }
}