import { LightningElement, api } from "lwc";
import fetchLookupData from "@salesforce/apex/ASDAC_LookupController.fetchLookupData";
import { NavigationMixin } from "lightning/navigation";
import { dispatchEventOnClick, genericSearchClickFunction, getDataLayerMetadata, CONTENT_SEARCH_ICON_LABEL, CONTENT_SEARCH_SUGGESTION_LABEL, CONTENT_SEARCH_ICON, SEARCH_TERM_EMPTY_LABEL } from "c/asdacSendDataToAdobeCmp";

const DELAY = 300;
export default class AsdacLookup extends NavigationMixin(LightningElement) {
  _searchKey = ""; // to store input field value
  @api minSearchLength = 2; // minimum search key length (at least 2)
  lstResult = []; // to store list of returned records
  delayTimeout;
  searchIconMasterLabel = CONTENT_SEARCH_ICON_LABEL;
  searchSuggestionMasterLabel = CONTENT_SEARCH_SUGGESTION_LABEL;
  contentSearchIconClickMetadataDataLayer;
  contentSearchSuggestionClickMetadataDataLayer;
  searchResultsCount;
  adobeMetadata;
  selectedIndex = -1;

  @api
  get searchKey() {
    return this._searchKey;
  }
  set searchKey(_searchKey) {
    this.handleKeyChange({ target: { value: _searchKey } });
  }

  get isValidSearch() {
    return this.searchKey.trim().length >= this.minSearchLength;
  }

  get showSearchKey() {
    return this._searchKey.trim().length > 0;
  }

  async connectedCallback() {
    setTimeout(() => {
    this.pageUrl = window.location.href;
    this.pageName = document.title;
    }, 50);
    sessionStorage.removeItem("loadEventTriggered");
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.contentSearchIconClickMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.searchIconMasterLabel);
      this.contentSearchSuggestionClickMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.searchSuggestionMasterLabel);
    }
  }

  handleSearchClick(event) {
    event.preventDefault();
    event.stopPropagation();
    let linkName;
    let linkUrl;
    let searchTerm;
    let suggestedTerm;
    let contentSearchClickMetadataDataLayer;
    if(this.searchKey.trim()){
      searchTerm = this.searchKey.trim();
    } else {
      searchTerm = SEARCH_TERM_EMPTY_LABEL;
    }
    if (event.target.classList.item(0) === 'search-button' ||
      (event.target.classList.item(0) === 'searchtext' && this.selectedIndex === -1)) {
      linkName = CONTENT_SEARCH_ICON;
      linkUrl = this.searchKey.trim() ? (window.location.origin + this.contentSearchIconClickMetadataDataLayer.OnclickEventPageUrl__c + this._searchKey.trim().replaceAll(' ','%20')) : ''; 
      contentSearchClickMetadataDataLayer = this.contentSearchIconClickMetadataDataLayer;
      this.dispatchClickEvent(linkName, linkUrl, searchTerm, contentSearchClickMetadataDataLayer, null);
      if (!this.isValidSearch) {
        return;
      }
      this[NavigationMixin.Navigate]({
        type: "standard__search",
        attributes: {
          term: this._searchKey.trim()
        }
      });
    }
    else if (this.contentSearchSuggestionClickMetadataDataLayer) {
      let data = event.target.dataset;
      this.selectedIndex = this.selectedIndex > -1 ? this.selectedIndex : data.index;
      this.updateSearchResultSelection();
      linkName = this.lstResult[this.selectedIndex].Title;
      linkUrl = window.location.origin+this.contentSearchSuggestionClickMetadataDataLayer.OnclickEventPageUrl__c+this.lstResult[this.selectedIndex].UrlName;
      suggestedTerm = linkName;
      contentSearchClickMetadataDataLayer = this.contentSearchSuggestionClickMetadataDataLayer;
      const contentSearchData = {
        contentSearchSuggestionData: {
          suggestedTerm: suggestedTerm,
          position: parseInt(this.selectedIndex) + 1,
          count: this.searchResultsCount
        },
        contentSearchResultsData: {
          pageUrl : this.pageUrl,
          pageName : this.pageName
        }
      }
      const searchData = {
        searchTerm : searchTerm,
        suggestedTerm: suggestedTerm
      }
      sessionStorage.setItem("searchData", JSON.stringify(searchData));
      this.dispatchClickEvent(linkName, linkUrl, searchTerm, contentSearchClickMetadataDataLayer, contentSearchData);
      if (this.selectedIndex > -1 && event.key === 'Enter') {
        const pageReference = {};  
        pageReference.type = "standard__recordPage";
        pageReference.attributes = {
          recordId: this.lstResult[this.selectedIndex].Id,
          urlName: this.lstResult[this.selectedIndex].UrlName,
          objectApiName: "Knowledge__kav",
          actionName: "view"
        };
        this[NavigationMixin.Navigate](pageReference);
      }
    }    
  }
  
  dispatchClickEvent(linkName, linkUrl, searchTerm, contentSearchClickMetadataDataLayer, contentSearchSuggestionData){
    if(contentSearchClickMetadataDataLayer){
      const contentSearchAnalyticsDetail = genericSearchClickFunction(linkName, linkUrl, searchTerm, contentSearchClickMetadataDataLayer, contentSearchSuggestionData);
      dispatchEventOnClick(contentSearchAnalyticsDetail, contentSearchClickMetadataDataLayer.OnclickEventName__c);
    }
  }

  searchResult(searchKey) {
    fetchLookupData({ searchKey })
      .then((data) => {
        this.lstResult = JSON.parse(JSON.stringify(data));
        this.searchResultsCount = Object.keys(this.lstResult).length;
      })
      .catch((error) => {
        console.error(error);
      });
  }

  // update searchKey property on input field change
  handleKeyChange(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    this._searchKey = searchKey;
    if (searchKey.length < this.minSearchLength) {
      return;
    }
    this.delayTimeout = setTimeout(() => {
      this.searchResult(searchKey);
    }, DELAY);
  }

  // method to toggle lookup result section on UI
  toggleResult(event) {
    this.selectedIndex = -1;
    this.updateSearchResultSelection();
    // prevents the closure of combobox options when an option is selected
    if (event.currentTarget.contains(event.relatedTarget)) {
      return;
    }
    const lookupInputContainer = this.template.querySelector(".lookupInputContainer");
    const clsList = lookupInputContainer.classList;
    const show = event.type === "focus";
    if (show) {
      clsList.add("slds-is-open");
    } else {
      clsList.remove("slds-is-open");
    }
  }

  handleKeyPress(event) {
    const key = event.key;
    if (key === 'Enter') {
      this.handleSearchClick(event);
    }
    if (key === 'ArrowDown') {
      this.selectedIndex = Math.min(this.selectedIndex + 1, this.lstResult.length - 1);
      this.updateSearchResultSelection();
    } else if (key === 'ArrowUp') {
      this.selectedIndex = Math.max(this.selectedIndex - 1, -1);
      this.updateSearchResultSelection();
    }
  }

  updateSearchResultSelection() {
    this.lstResult = this.lstResult.map((result, index) => ({
      ...result,
      selectedClass: index === this.selectedIndex ? 'slds-listbox__item search-result-focus' : 'slds-listbox__item'
    }));
  }
}