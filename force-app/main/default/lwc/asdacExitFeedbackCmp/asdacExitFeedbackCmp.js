import { api, LightningElement } from "lwc";
import createTask from "@salesforce/apex/ASDAC_TaskCreateController.createTask";
import ASDAC_FeedbackWidgetFreeTextDisclaimers from "@salesforce/label/c.ASDAC_FeedbackWidgetFreeTextDisclaimers";
import ASDAC_FeedbackWidgetHeader from "@salesforce/label/c.ASDAC_FeedbackWidgetHeader";
import ASDAC_FeedbackWidgetUpvoteLabel from "@salesforce/label/c.ASDAC_FeedbackWidgetUpvoteLabel";
import ASDAC_FeedbackWidgetDownvoteLabel from "@salesforce/label/c.ASDAC_FeedbackWidgetDownvoteLabel";
import ASDAC_FeedbackSubmissionMessage from "@salesforce/label/c.ASDAC_FeedbackSubmissionMessage";
import ASDAC_FeedbackWidgetNegativeFeedbackText from "@salesforce/label/c.ASDAC_FeedbackWidgetNegativeFeedbackText";
import ASDAC_FeedbackWidgetTellUsMoreToImproveText from "@salesforce/label/c.ASDAC_FeedbackWidgetTellUsMoreToImproveText";
import ASDAC_FeedbackWidgetOtherButtonLabel from "@salesforce/label/c.ASDAC_FeedbackWidgetOtherButtonLabel";
import ASDAC_FeedbackWidgetSendFeedbackButtonLabel from "@salesforce/label/c.ASDAC_FeedbackWidgetSendFeedbackButtonLabel";
import ASDAC_FeedbackWidgetGetMoreHelpText from "@salesforce/label/c.ASDAC_FeedbackWidgetGetMoreHelpText";
import ASDAC_FeedbackWidgetChipButtonsLabel from "@salesforce/label/c.ASDAC_FeedbackWidgetChipButtonsLabel";
import ASDAC_FeedbackWidgetFreeTextValidationMessage from "@salesforce/label/c.ASDAC_FeedbackWidgetFreeTextValidationMessage";
import { dispatchEventOnClick, genericSurveyClickFunction, getDataLayerMetadata, SURVEY_NAME_PREFIX, SURVEY_UPVOTE_DOWNVOTE_RESPONSE_LABEL, SURVEY_DOWNVOTE_RESPONSE_REASON_LABEL, SEND_FEEDBACK_LABEL } from "c/asdacSendDataToAdobeCmp";

const TRUE_VALUE = "true";

export default class AsdacExitFeedbackCmp extends LightningElement {
  @api articleId;
  @api showCallChannel;
  @api showMessageChannel;
  feedBack;
  clickedUpvote;
  clickedButton;
  clickedSendFeedback = false;
  taskDescription;
  baseURL;
  isValid;
  currentPageContent;
  adobeMetadata;
  surveyResponseMetadataDataLayer;
  taskCreatedSuccessfully = false;
  hidePlaceholder = false;
  disabled = false;
  labels = {
    header: ASDAC_FeedbackWidgetHeader,
    upvote: {
      label: ASDAC_FeedbackWidgetUpvoteLabel,
      submissionText: ASDAC_FeedbackSubmissionMessage
    },
    downvote: {
      label: ASDAC_FeedbackWidgetDownvoteLabel,
      submissionText: ASDAC_FeedbackSubmissionMessage,
      negativeFeedback: {
        header: ASDAC_FeedbackWidgetNegativeFeedbackText,
        improveText: ASDAC_FeedbackWidgetTellUsMoreToImproveText,
        otherButton: {
          label: ASDAC_FeedbackWidgetOtherButtonLabel,
          sendFeedbackButtonLabel: ASDAC_FeedbackWidgetSendFeedbackButtonLabel,
          freeTextDisclaimer: ASDAC_FeedbackWidgetFreeTextDisclaimers,
          freeTextValidationMessage: ASDAC_FeedbackWidgetFreeTextValidationMessage
        },
        contactus: {
          header: ASDAC_FeedbackWidgetGetMoreHelpText
        },
        chipButtons: ASDAC_FeedbackWidgetChipButtonsLabel.split(',')
      }
    }
  };

  async connectedCallback() {
    this.feedBack = true;
    this.clickedUpvote = false;
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
  }

  get upvoteClass() {
    return `feedback-button${this.articleId ? "" : " feedback-upvote"}`;
  }

  get downvoteClass() {
    return `feedback-button${this.articleId ? "" : " feedback-downvote"}`;
  }

  get showCallChannelComponent() {
    if (this.showCallChannel) {
      return this.showCallChannel;
    } else if (
      this.currentPageContent &&
      this.currentPageContent.showCallChannel
    ) {
      return this.currentPageContent.showCallChannel.value === TRUE_VALUE;
    }
    return false;
  }

  get showMessageChannelComponent() {
    if (this.showMessageChannel) {
      return this.showMessageChannel;
    } else if (
      this.currentPageContent &&
      this.currentPageContent.showMessageChannel
    ) {
      return this.currentPageContent.showMessageChannel.value === TRUE_VALUE;
    }
    return false;
  }

  get getMoreHelp() {
    return this.showCallChannelComponent || this.showMessageChannelComponent;
  }

  get freeTextPlaceholder() {
    return this.hidePlaceholder ? '' : this.labels.downvote.negativeFeedback.otherButton.freeTextDisclaimer;
  }

  handleInputChange(event) {
    this.taskDescription = event.target.value;
  }

  async handleClick(event) {
    this.baseURL = window.location.href;
    let tskdescription;
    let masterLabel;
    if (event.currentTarget.dataset.id) {
      tskdescription = event.currentTarget.dataset.id;
      this.isValid = true;
      masterLabel = SURVEY_DOWNVOTE_RESPONSE_REASON_LABEL;
    } else {
      this.disabled = true;
      tskdescription = this.taskDescription;
      this.isValid = [
        ...this.template.querySelectorAll("lightning-input")
      ].reduce((validSoFar, field) => {
      if( field.value?.trim() === ""){
          field.value = "";
        }
        return validSoFar && field.reportValidity();
      }, true);
      masterLabel = SEND_FEEDBACK_LABEL;
    }
    if (this.isValid) {
      await createTask({ description: tskdescription, subject: this.baseURL })
        .then((result) => {
          if (result.isSuccess) {
            this.taskCreatedSuccessfully = true;
            this.clickedSendFeedback = true;
            this.clickedButton = false;
          }
        })
        .catch((error) => {
          console.error(error);
        });
    }
    this.trackData(masterLabel, event.target.textContent);
  }

  handleUpvote() {
    this.clickedUpvote = true;
    this.feedBack = false;
    this.trackData(SURVEY_UPVOTE_DOWNVOTE_RESPONSE_LABEL, this.labels.upvote.label);
  }

  handleDownvote() {
    this.feedBack = false;
    this.clickedUpvote = false;
    this.trackData(SURVEY_UPVOTE_DOWNVOTE_RESPONSE_LABEL, this.labels.downvote.label);
    this.checkSelectedPageCMSContent();
  }

  handleButton(event) {
    this.clickedButton = true;
    this.trackData(SURVEY_DOWNVOTE_RESPONSE_REASON_LABEL, event.target.textContent);
  }

  checkSelectedPageCMSContent() {
    if (
      window.contactUsMetadata.filter((e) => e.label === document.title)
        .length > 0
    ) {
      let contactUsMetadata = window.contactUsMetadata;
      const selectedPageIndex = contactUsMetadata.findIndex(
        (x) => x.label === document.title
      );
      if (
        contactUsMetadata[selectedPageIndex] &&
        contactUsMetadata[selectedPageIndex].staticPageContent &&
        contactUsMetadata[selectedPageIndex].staticPageContent.contentNodes
      ) {
        this.currentPageContent =
          contactUsMetadata[selectedPageIndex].staticPageContent.contentNodes;
      }
    }
  }

  togglePlaceholder(event) {
    this.hidePlaceholder = event.type === "focus" ? true : false;
  }

  trackData(masterLabel, buttonLabel){
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.surveyResponseMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === masterLabel);
    }
    if(this.surveyResponseMetadataDataLayer){
      let surveyName = SURVEY_NAME_PREFIX + document.title;
      let SurveyAnalyticsDetail;
      let status;
      let formName;
      let subType;
      subType = this.surveyResponseMetadataDataLayer.OnclickEventSubtype__c;
      if(buttonLabel === 'Send feedback'){
        status = (this.taskCreatedSuccessfully && this.isValid) ? 'Success' : 'Error';
        formName = buttonLabel;
      }
      else{
        status = '';
        formName = '';
        if(buttonLabel === 'Yes' || buttonLabel === 'No' ){
          subType = buttonLabel + ' ' + this.surveyResponseMetadataDataLayer.OnclickEventSubtype__c;
        }
      }
      const surveyData = {
        linkName: buttonLabel,
        surveyName: surveyName,
        status: status,
        formName: formName,
        subType: subType,
        datalayerObj: this.surveyResponseMetadataDataLayer
      }
      SurveyAnalyticsDetail = genericSurveyClickFunction(surveyData);  
      dispatchEventOnClick(SurveyAnalyticsDetail, this.surveyResponseMetadataDataLayer.OnclickEventName__c);
    }
    this.disabled = false;
  }
}