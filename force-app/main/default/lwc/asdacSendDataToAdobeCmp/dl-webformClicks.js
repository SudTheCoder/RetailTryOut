import { userInformation, pageInformation, linkTrackingInformation, eventInformation } from './dl-common';

export const webformInitiationFunction = (linkName, linkUrl, formTitle, datalayerObj) => {
    return {
        linkTracking: linkTrackingInformation(linkName, linkUrl),
        sectionInteraction: {
            sectionName: datalayerObj.SectionName__c,
            channelType: datalayerObj.ChannelType__c,
            formName: formTitle,
        },
        event: eventInformation(datalayerObj.OnloadEventSubtype__c, datalayerObj.OnclickEventType__c),
        user: userInformation,
        page: pageInformation(false,false,datalayerObj)
    }
}

export const webformSubmitClickFunction = (formSubmitDetail) => {
    let webformInformation = sessionStorage.getItem("webformInformation") ? JSON.parse(sessionStorage.getItem("webformInformation")) : '';
    return {
        linkTracking: linkTrackingInformation(formSubmitDetail.linkName, ''),
        sectionInteraction: {
            sectionName: (webformInformation?.isSendUsMessageWebform) ? webformInformation.sectionName : formSubmitDetail.datalayerObj.SectionName__c,
            ...(webformInformation?.subSectionName && { subSectionName: webformInformation.subSectionName }),
            channelType: formSubmitDetail.datalayerObj.ChannelType__c,
            status: formSubmitDetail.status,
            formName: formSubmitDetail.formTitle,
            journeyName: formSubmitDetail.journeyName
        },
        ...(formSubmitDetail?.errorMessage && { error: { errorMessage: formSubmitDetail.errorMessage } }),
        event: eventInformation(formSubmitDetail.datalayerObj.OnclickEventSubtype__c, formSubmitDetail.datalayerObj.OnclickEventType__c),
        user: userInformation,
        page: pageInformation(false,false,formSubmitDetail.datalayerObj)
    }    
}