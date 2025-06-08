export { dispatchEventOnClick, dispatchEventOnLoad, getDataLayerMetadata };
export { genericClickFunction, genericSearchClickFunction ,breadcrumbClickFunction} from './dl-homePageClicks';
export { pageLoadFunction } from './dl-pageLoad';
export { genericSurveyClickFunction } from './dl-surveyClicks';
export { contactUsButtonsClickFunction } from './dl-contactUsClicks';
export { webformSubmitClickFunction ,webformInitiationFunction} from './dl-webformClicks';
export {
    ANNOUNCEMENTS_LABEL,
    BRAND_SELECTION_LABEL,
    CONTACT_US_LABEL,
    CONTENT_SEARCH_ICON_LABEL,
    CONTENT_SEARCH_SUGGESTION_LABEL,
    FIND_ASDA_STORE_LABEL,
    PROMOTIONAL_BANNER_LABEL,
    STORE_SEARCH_ICON,
    CONTENT_SEARCH_ICON,
    FAQ_LABEL,
    SEARCHRESULTS_LABEL,
    SEND_FEEDBACK_LABEL,
    SURVEY_NAME_PREFIX,
    SURVEY_UPVOTE_DOWNVOTE_RESPONSE_LABEL,
    SURVEY_DOWNVOTE_RESPONSE_REASON_LABEL,
    SURVEY_SECTION_NAME,
    SURVEY_SUBSECTION_NAME,
    CONTACTUS_SECTION_NAME,
    CONTACTUS_SUBSECTION_NAME,
    CALLUS_MORE_LABEL,
    SOCIAL_ICON_LABEL,
    SEARCH_TERM_EMPTY_LABEL,
    WEBFORM_LABEL,
    WEBFORM_LINK_NAME,
    BREADCRUMBWIDGET_LABEL,
    YOUR_ORDERS_LABEL,
    FOOTERCLICKS_LABEL,
    GEORGE_BRAND_LABEL,
    GROCERY_BRAND_LABEL,
    HEADERCLICKS_LABEL,
    ASDA_LOGO_LABEL,
    INTERNALLINK_CLICK_LABEL,
    HOW_CAN_WE_HELP_LABEL
} from './dl-constant';
import {
    EVENT_CLICK,
    EVENT_LOAD
} from './dl-constant';
import getUser from '@salesforce/apex/ASDAC_WithoutSharingUtility.getUser';
import getDataLayerEventMetadata from '@salesforce/apex/ASDAC_WithoutSharingUtility.getDataLayerEventMetadata';
import userId from "@salesforce/user/Id";

function dispatchEventOnClick(asdaDigitaldata, eventName) {
    fireEvent(eventName, asdaDigitaldata, EVENT_CLICK);
}

function dispatchEventOnLoad(asdaDigitaldata, eventName) {
    setTimeout(function() {fireEvent(eventName, asdaDigitaldata, EVENT_LOAD)}, 1000);
}

function fireEvent(eventName, asdaDigitaldata, actionType) {
    document.dispatchEvent(new CustomEvent(eventName, { 'detail': { action: actionType, value: asdaDigitaldata } }));
}

const fetchDataLayerEventMetadata = () => {
    return getDataLayerEventMetadata().then((result) => {
        return JSON.parse(JSON.stringify(result));
    }).catch((error) => {
        console.log(error);
    });
};

const fetchLoggedInUserData = () => {
    return getUser({ userId: userId }).then((result) => {
        if (result.length > 0) {
            return {
                contactId: result[0].contactId,
                firstName: result[0].firstName,
                lastName: result[0].lastName,
                email: result[0].email,
                language: result[0].LocaleSidKey,
                country: result[0].Country
            }
        }
        return null;
    }).catch((error) => {
        console.log(error);
    });
};

async function getDataLayerMetadata() {
    const dataLayerEventMetadataRecords = await fetchDataLayerEventMetadata();
    const userObj = await fetchLoggedInUserData();
    const dataLayer = {
        dataLayerEventMetadataRecords: dataLayerEventMetadataRecords,
        userDetails: userObj
    };
    return dataLayer;
}