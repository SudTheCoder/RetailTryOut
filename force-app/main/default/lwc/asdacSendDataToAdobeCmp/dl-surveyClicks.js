import { pageInformation, userInformation, linkTrackingInformation, eventInformation } from './dl-common';

export const genericSurveyClickFunction = (surveyData) => ({
    linkTracking: linkTrackingInformation(surveyData.linkName, ''),
    sectionInteraction: {
        sectionName: surveyData.datalayerObj.SectionName__c,
        subSectionName: surveyData.datalayerObj.SubsectionName__c,
        surveyName: surveyData.surveyName,
        journeyName: surveyData.datalayerObj.JourneyName__c,
        ...( surveyData.formName && {formName: surveyData.formName}),
        ...( surveyData.status && {status: surveyData.status})
    },
    event: eventInformation(surveyData.subType, surveyData.datalayerObj.OnclickEventType__c),
    user: userInformation,
    page: pageInformation(false,false,surveyData.datalayerObj)
});