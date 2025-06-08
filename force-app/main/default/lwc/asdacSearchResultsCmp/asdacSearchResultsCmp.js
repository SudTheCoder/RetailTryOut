import { api, LightningElement } from "lwc";
import fetchLookupData from "@salesforce/apex/ASDAC_LookupController.fetchLookupData";
import ASDAC_SearchNoResultLabel from "@salesforce/label/c.ASDAC_SearchNoResultLabel";
import ASDAC_SearchNoResultNote from "@salesforce/label/c.ASDAC_SearchNoResultNote";
import { dispatchEventOnClick, genericSearchClickFunction, dispatchEventOnLoad, pageLoadFunction, getDataLayerMetadata, SEARCHRESULTS_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacSearchResultsCmp extends LightningElement {
  @api searchTerm = "";
  @api minSearchLength = 2;
  @api maxResults = 10;
  @api maxCharacters = 200;
  @api maxKeywords = 3;
  articles = [];
  noResult = false;
  loading;
  labels = {
    noResultLabel: ASDAC_SearchNoResultLabel,
    noResultNote: ASDAC_SearchNoResultNote
  };
  masterLabel = SEARCHRESULTS_LABEL;
  searchResultsMetaDataLayer;
  adobeMetadata;
  userData;
  pageUrl;
  pageName = 'Search';

  async connectedCallback() {
    document.title = this.pageName;
    this.pageUrl = window.location.href;
    if (this.searchTerm.length < this.minSearchLength) {
      return;
    }
    this.loading = true;
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    fetchLookupData({ searchKey: this.searchTerm, maxResults: this.maxResults, maxKeywords: this.maxKeywords })
      .then((data) => {
        this.articles = data.map((article) => {
          const dom = new DOMParser().parseFromString(article.Answer__c || "", "text/html");
          const text = dom.body.textContent.replace(/(\r?\n)+/g, "\n").trim();
          const TeaserText__c = text.length <= this.maxCharacters ? text : text.substring(0, this.maxCharacters).trim() + "...";
          return {
            ...article,
            TeaserText__c
          };
        });
        this.noResult = data.length === 0;
        this.loading = false;
        this.adobeMetadata = window.dataLayer;
        if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
          this.searchResultsMetaDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
          setTimeout(() => {
          let searchResultAnalyticsDetail = pageLoadFunction(this.searchResultsMetaDataLayer, this.adobeMetadata?.userDetails);
          searchResultAnalyticsDetail.page ={
            ...searchResultAnalyticsDetail?.page,
            ...{
              searchTerm: this.searchTerm,
              noOfSearchResults: data.length,
              searchResultFound: !this.noResult,
            }
          };
          dispatchEventOnLoad(searchResultAnalyticsDetail, this.searchResultsMetaDataLayer.OnloadEventName__c);
          }, 50);
        }
      })
      .catch((error) => {
        this.loading = false;
        console.error(error);
      });
  }

  trackData(event){
    let data=event.target.dataset;
    if(this.searchResultsMetaDataLayer){
      let linkUrl;
      linkUrl = window.location.origin + this.searchResultsMetaDataLayer.OnclickEventPageUrl__c + data.url;
      const searchData = sessionStorage.getItem("searchData") ? JSON.parse(sessionStorage.getItem("searchData")) : '';
      const contentSearchData = {
        contentSearchSuggestionData: null,
        contentSearchResultsData: {
          position : parseInt(data.index)+1,
          pageName : this.pageName,
          pageUrl : this.pageUrl
        }
      }
      const searchResultsAnalyticsDetail = genericSearchClickFunction(data.title, linkUrl, searchData?.searchTerm, this.searchResultsMetaDataLayer, contentSearchData);
      dispatchEventOnClick(searchResultsAnalyticsDetail, this.searchResultsMetaDataLayer.OnclickEventName__c);
    }
  }
}