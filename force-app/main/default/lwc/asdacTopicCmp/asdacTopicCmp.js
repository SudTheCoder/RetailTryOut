import { api, LightningElement } from "lwc";
import getFAQHierarchy from "@salesforce/apex/ASDAC_LandingCmpController.getFAQHierarchy";
import noFAQFoundMessage from "@salesforce/label/c.ASDAC_NoArticlesRelatedToCategoryFoundMessage";
import { dispatchEventOnLoad, pageLoadFunction, dispatchEventOnClick, genericSearchClickFunction, getDataLayerMetadata, SOCIAL_ICON_LABEL, FAQ_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacTopicsCmp extends LightningElement {
  @api topic;
  @api topicHeader;
  masterLabel = SOCIAL_ICON_LABEL;
  dataLayerMetadataRecord;
  FaqDataLayerMetadataRecord;
  adobeMetadata;
  pageUrl;
  pageName;
  categoryClicked = '';
  dataCategoryArray = [];
  returnedMap = [];
  DataCategoryLabelMap = [];
  innerMap = [];

  get noFAQFoundMessage() {
    return noFAQFoundMessage + ` ${this.categoryClicked}`;
  }

  async connectedCallback() {
    setTimeout(() => {
      this.pageUrl = window.location.href;
      this.pageName = document.title;
    }, 50); 
    this.categoryClicked = this.topic;
    sessionStorage.removeItem("loadEventTriggered");
    if (this.topic) {
      if (!window.dataLayer) {
        window.dataLayer = await getDataLayerMetadata();
      }
      this.adobeMetadata = window.dataLayer;
      if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
        this.dataLayerMetadataRecord = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
        this.FaqDataLayerMetadataRecord = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === FAQ_LABEL);
        setTimeout(() => {
        const dataLayerAnalyticsDetail = pageLoadFunction(this.dataLayerMetadataRecord, this.adobeMetadata?.userDetails);
        dispatchEventOnLoad(dataLayerAnalyticsDetail, this.dataLayerMetadataRecord.OnloadEventName__c);
        }, 50);
      }
      this.fetchArticlesByCategory(this.topic);
    }
  }

  trackData(event) {
    let data = event.target.dataset;
    let faqDataLayerMetadataRecordCopy;
    faqDataLayerMetadataRecordCopy = { ...this.FaqDataLayerMetadataRecord };
    faqDataLayerMetadataRecordCopy.SectionName__c = this.pageName;
    if (this.FaqDataLayerMetadataRecord) {
      let linkurl = window.location.href;
      const contentSearchData = {
        contentSearchSuggestionData: null,
        contentSearchResultsData: {
          position: parseInt(data.index) + 1,
          pageUrl: this.pageUrl,
          pageName: this.pageName
        }
      }
      let dataLayerAnalyticsDetail = genericSearchClickFunction(data.title, linkurl, '', faqDataLayerMetadataRecordCopy, contentSearchData);
      if (this.pageName === 'Asda Rewards'){
        dataLayerAnalyticsDetail.sectionInteraction ={
          ...dataLayerAnalyticsDetail?.sectionInteraction,
          ...{
            subSectionName: data.category
          }
        };
      }
      dispatchEventOnClick(dataLayerAnalyticsDetail, faqDataLayerMetadataRecordCopy.OnclickEventName__c);
    }
  }

  handleKeyPress(event) {
    if (event.key === 'Enter' && !event?.target?.dataset?.urlAlias) {
      this.handleClick(event);
    }
  }

  handleClick(event) {
    this.categoryClicked = event.currentTarget.dataset?.label;
    this.dataCategoryArray=this.dataCategoryArray.map(item=>{
       if(item.label === this.categoryClicked){
         item.expanded= !item.expanded;
       }else{
        item.expanded=false;
       }
      return item;
    });
    this.dataCategoryArray = [...this.dataCategoryArray];
  }

  fetchArticlesByCategory(topicVal) {
    const topicApiName = topicVal
      .replace(/[^a-z0-9]+/gi, " ")
      .trim()
      .replace(/\s/g, "_");
    getFAQHierarchy()
      .then((data) => {
        this.returnedMap = data?.faqHierarchyMap;
        this.DataCategoryLabelMap = data?.categoryUniqueNameToLabelMap;
        this.dataCategoryArray = this.getListByKey(this.returnedMap, topicApiName);
      })
      .catch(console.error);
  }

  getListByKey(map, searchKey) {
    let tempArray = [];
    for (let key1 in map) {
      if (map.hasOwnProperty(key1)) {
        let innerMapIndex = 0;
        let outerMapIndex = 0;
        for (let key2 in map[key1]) {
          if (map[key1].hasOwnProperty(key2) && key2 === searchKey) {
            if(map[key1][key2].length>0){
              tempArray.push({
                'isArticle': true,
                'index': outerMapIndex,
                'articles': map[key1][key2],
                'showArticle': map[key1][key2].length>0,
              });
              outerMapIndex++;
            }
          }
         }
        if (key1 === searchKey) {
          this.innerMap = map[searchKey];
          for (let key2 in this.innerMap) {
            if (this.innerMap.hasOwnProperty(key2)) {
              tempArray.push({
                'index': innerMapIndex,
                'name': key2,
                'expanded': false,
                'label': this.DataCategoryLabelMap.hasOwnProperty(key2) ? this.DataCategoryLabelMap[key2] : key2.replaceAll('_', " "),
                'articles': this.innerMap[key2],
                'showArticle': this.innerMap[key2].length>0,
              });
              innerMapIndex++;
            }
          }
        }
      }
    }
    return tempArray;
  }
}