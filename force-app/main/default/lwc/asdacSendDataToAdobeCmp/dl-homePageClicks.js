import { userInformation, pageInformation, linkTrackingInformation, eventInformation } from './dl-common';

export const genericClickFunction = (linkName, linkUrl, datalayerObj) => ({
    linkTracking: linkTrackingInformation(linkName, linkUrl),
    sectionInteraction: {
        sectionName: datalayerObj.SectionName__c
    },
    event: eventInformation(datalayerObj.OnclickEventSubtype__c, datalayerObj.OnclickEventType__c),
    user: userInformation,
    page: pageInformation(false,false,datalayerObj)
});

export const genericSearchClickFunction = (linkName, linkUrl, searchTerm, datalayerObj, contentSearchData) => ({
    linkTracking: linkTrackingInformation(linkName, linkUrl),
    sectionInteraction: {
        sectionName: datalayerObj.SectionName__c,
        ...(searchTerm && {searchTerm: searchTerm}),
        ...(contentSearchData?.contentSearchSuggestionData && {eacSuggestedTerm: contentSearchData?.contentSearchSuggestionData?.suggestedTerm}),
        ...(contentSearchData?.contentSearchSuggestionData && {eacSuggestedTermPosition: contentSearchData?.contentSearchSuggestionData?.position}),
        ...(contentSearchData?.contentSearchSuggestionData && {eacSuggestedTermCount: contentSearchData?.contentSearchSuggestionData?.count}),
        ...(contentSearchData?.contentSearchResultsData?.position && {faqLinkPosition: contentSearchData?.contentSearchResultsData?.position})
    },
    event: eventInformation(datalayerObj.OnclickEventSubtype__c, datalayerObj.OnclickEventType__c),
    user: userInformation,
    page: pageInformation(contentSearchData?.contentSearchResultsData?.pageUrl,contentSearchData?.contentSearchResultsData?.pageName,datalayerObj)
});

export const breadcrumbClickFunction = (breadcrumbObj, datalayerObj) => ({
    linkTracking: linkTrackingInformation(breadcrumbObj.linkName, breadcrumbObj.linkURL),
    sectionInteraction: {
        sectionName: datalayerObj.SectionName__c
    },
    event: eventInformation(datalayerObj.OnclickEventSubtype__c, datalayerObj.OnclickEventType__c),
    user: userInformation,
    page: pageInformation(breadcrumbObj.pageURL,breadcrumbObj.pageName,datalayerObj)
});