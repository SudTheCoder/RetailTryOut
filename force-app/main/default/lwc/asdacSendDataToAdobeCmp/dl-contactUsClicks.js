import { userInformation, pageInformation, linkTrackingInformation, eventInformation } from './dl-common';

export const contactUsButtonsClickFunction = (linkName, linkUrl, datalayerObj, subsectionName) => ({
    linkTracking: linkTrackingInformation(linkName, linkUrl),
    sectionInteraction: {
        sectionName: datalayerObj.SectionName__c,
        subSectionName: subsectionName,
        ...(datalayerObj?.ChannelType__c && {channelType:datalayerObj.ChannelType__c}),
        ...(datalayerObj?.JourneyName__c && {formName:datalayerObj.JourneyName__c})
    },
    event: eventInformation(datalayerObj.OnclickEventSubtype__c, datalayerObj.OnclickEventType__c),
    user: userInformation,
    page: pageInformation(false,false,datalayerObj)
});