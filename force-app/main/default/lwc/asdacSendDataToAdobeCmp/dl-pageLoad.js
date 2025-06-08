import { userInformation, pageLoadDuration,pageInformation, eventInformation,currentDateTimeStamp } from './dl-common';
export const pageLoadFunction = (dataLayerObj) => ({
    page: pageInformation(false,false,dataLayerObj,{pageLoadTime: pageLoadDuration(),dateTimeStamp: currentDateTimeStamp()}),
    user: userInformation,
    event: eventInformation(dataLayerObj.OnloadEventSubtype__c, dataLayerObj.OnloadEventType__c),
});