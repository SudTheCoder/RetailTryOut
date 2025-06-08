import isGuestUser from '@salesforce/user/isGuest';
import FORM_FACTOR from '@salesforce/client/formFactor';
import {WEB_PLATFORM_LABEL, MOBILE_PLATFORM_LABEL, CUSTOMER_TYPE, MOBILE_DEVICE, DESKTOP_DEVICE, USER_DATA_NOT_AVAILABLE} from './dl-constant';

  export const userInformation = {
    userLoggedInStatus: !isGuestUser,
    customerType: CUSTOMER_TYPE
  };

  export const getUserCountry = (loggedInUserCountry) => {
    return !isGuestUser ? loggedInUserCountry : USER_DATA_NOT_AVAILABLE
  }

  export const getUserLanguage = (loggedInUserLanguage) => {
    return !isGuestUser ? loggedInUserLanguage : navigator.language
  }

  export const deviceType = () => {
    return /Mobi|Android/i.test(navigator.userAgent) ? MOBILE_DEVICE : DESKTOP_DEVICE
  }

  export const platformType = () => {
    return /Mobi|Android/i.test(navigator.userAgent) ? MOBILE_PLATFORM_LABEL : WEB_PLATFORM_LABEL
  }

  export const eventInformation = (eventSubType, eventType) => {
    return {
      subType: eventSubType,
      type: eventType
    }
  }

  export const linkTrackingInformation = (linkName, linkUrl) => {
    return {
      linkName: linkName,
      ...(linkUrl && {linkURL: linkUrl})
    }
  }

  export const pageLoadDuration = () => {
    return (performance.getEntriesByType("navigation")[0].duration / 1000)
  }

  export const currentDateTimeStamp = () => {
    return new Date(new Date().toUTCString().replace(' GMT','')).toLocaleString('en-Gb').replace(',','')
  }

  export const pageInformation = (pageUrl,pageName,datalayerObj,mergeFields={}) => {
    let userData = window.dataLayer?.userDetails;
    let returnObject = {
      pageName: pageName ? pageName : document.title,
      pageUrl: pageUrl ? pageUrl : window.location.href,
      platform: platformType(),
      currentDomain: datalayerObj?.CurrentDomain__c,
      language: getUserLanguage(userData?.language),
      country:  getUserCountry(userData?.country),
      pageShortUrl: pageUrl ? pageUrl.split(window.location.origin)[1] : window.location.pathname,
      deviceType: deviceType(),
      viewPort: FORM_FACTOR,
    }
    return {...returnObject,...mergeFields};
  }