import { api, LightningElement } from "lwc";
import ASDAC_ContactUsPhoneNote from "@salesforce/label/c.ASDAC_ContactUsPhoneNote";
import ASDAC_ContactUsPhoneNumber from "@salesforce/label/c.ASDAC_ContactUsPhoneNumber";
import ASDAC_ContactUsPhoneMoreNote from "@salesforce/label/c.ASDAC_ContactUsPhoneMoreNote";
import ASDAC_ContactUsPhoneButtonTitle from "@salesforce/label/c.ASDAC_ContactUsPhoneButtonTitle";
import { dispatchEventOnClick, contactUsButtonsClickFunction, getDataLayerMetadata, SURVEY_SECTION_NAME, SURVEY_SUBSECTION_NAME, CONTACTUS_SECTION_NAME, CONTACTUS_SUBSECTION_NAME, CALLUS_MORE_LABEL} from "c/asdacSendDataToAdobeCmp";

export default class AsdacContactUsButtonsCmp extends LightningElement {
  @api isFeedback = false;
  @api showCallChannelComponent;
  contactUsButtonsMetadata;
  adobeMetadata;
  more = false;
  labels = {
    phone: {
      link: "tel:" + ASDAC_ContactUsPhoneNumber,
      moreNotes: ASDAC_ContactUsPhoneMoreNote.split(/\r?\n/g),
      label:ASDAC_ContactUsPhoneButtonTitle,
      combinedData: []
    }
  };
  get showCallChannel(){
    return this.isFeedback ? this.showCallChannelComponent:true;
  }

  callPhoneNumber(event) {
    const phoneNumber = event.currentTarget.textContent;
    window.location.href = 'tel:' + phoneNumber;
}

  get containerClass() {
    return "cta-container" + (this.isFeedback ? " cta-container-feedback slds-var-p-horizontal_small" : "");
  }

  get moreIcon() {
    return this.more ? "utility:chevrondown" : "utility:chevronright";
  }

  get moreDropdownClass() {
    return "more-dropdown cta-note" + (this.isFeedback ? " more-dropdown-feedback" : "");
  }

  async connectedCallback() {
    if(ASDAC_ContactUsPhoneNote || ASDAC_ContactUsPhoneNumber){
      let notes = ASDAC_ContactUsPhoneNote?.split(",");
      let numbers = ASDAC_ContactUsPhoneNumber?.split(",");
      if(notes && numbers){
        for (let i = 0; i < notes.length; i++) {
          let showMore = (i === 0) ? true : false;
          let customCss = (i !== 0) ? 'slds-p-bottom_large': '';
          this.labels.phone.combinedData.push({ note: notes[i], number: numbers[i],label:ASDAC_ContactUsPhoneButtonTitle,showMore: showMore , customCss: customCss});
        }
      }

    }
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
  }
  showMore(event) {
    event.preventDefault();
    event.stopPropagation();
    this.more = !this.more;
    this.processAdobeData(CALLUS_MORE_LABEL);
  }

  trackData(event){
    const buttonLabel = event.currentTarget.dataset.title;
    const buttonItem = event.currentTarget.dataset.label;
    this.processAdobeData(buttonLabel, buttonItem);
  }

  processAdobeData(buttonLabel, buttonItem){
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {      
      this.contactUsButtonsMetadata = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === buttonLabel);
    }
    if(this.contactUsButtonsMetadata){
      this.contactUsButtonsMetadata.SectionName__c = this.isFeedback? SURVEY_SECTION_NAME : CONTACTUS_SECTION_NAME;
      this.contactUsButtonsMetadata.SubsectionName__c = this.isFeedback? SURVEY_SUBSECTION_NAME : CONTACTUS_SUBSECTION_NAME;
      let webformInformation = {
        isSendUsMessageWebform: true,
        sectionName: this.contactUsButtonsMetadata.SectionName__c, 
        subSectionName: this.contactUsButtonsMetadata.SubsectionName__c ,
      }
      sessionStorage.setItem("webformInformation", JSON.stringify(webformInformation));  
       const linkURL = (this.contactUsButtonsMetadata?.ChannelType__c && (buttonLabel !== CALLUS_MORE_LABEL))?"tel:" + buttonItem: '';
      let linkName = (buttonLabel === ASDAC_ContactUsPhoneButtonTitle) ? buttonItem : buttonLabel;
      let contactUsButtonAnalyticsDetail = contactUsButtonsClickFunction(linkName, linkURL, this.contactUsButtonsMetadata, this.contactUsButtonsMetadata.SubsectionName__c);
      dispatchEventOnClick(contactUsButtonAnalyticsDetail, this.contactUsButtonsMetadata.OnclickEventName__c);
    }
  }
}