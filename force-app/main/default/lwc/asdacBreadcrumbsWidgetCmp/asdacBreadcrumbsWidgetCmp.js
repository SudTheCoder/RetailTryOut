import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import retrieveMediaFromCMS from "@salesforce/apex/ASDAC_NavigationMenuItemsController.retrieveMediaFromCMS";
import { dispatchEventOnClick, breadcrumbClickFunction, getDataLayerMetadata, BREADCRUMBWIDGET_LABEL } from "c/asdacSendDataToAdobeCmp";

export default class AsdacBreadcrumbsWidgetCmp extends LightningElement {
  @track breadCrumbList = [];
  @track pageName;
  @track pageType;
  @track urlAlias;
  @track pageTitle;
  @track urlChanged = false;
  @track recordId;
  cmsContentType = 'contact_us';
  maxPageSize = 250;
  channelName = "Help";
  staticPageContent;
  masterLabel = BREADCRUMBWIDGET_LABEL;
  breadcrumbMetadataDataLayer;
  adobeMetadata;
  breadcrumbObjAfterClick;
  isClickEventExecuted = false;

  get showBreadcrumbs() {
    return this.breadCrumbList.length > 1;
  }

  @wire(CurrentPageReference)
  wireParams(data) {
    this.pageType = data.type;
    switch (this.pageType) {
      case "comm__namedPage":
        this.pageName = data.attributes.name;
        this.urlAlias = data.attributes.name;
        break;
      case "standard__managedContentPage":
        this.pageName = data.attributes.contentTypeName;
        this.urlAlias = data.attributes.urlAlias;
        break;
      case "standard__search":
        this.pageName = data.state.term;
        this.urlAlias = data.state.term;
        break;
      case "standard__recordPage":
        this.urlAlias = data.attributes.urlName;
        this.recordId = data.attributes.recordId;
        this.pageName = data.attributes.objectApiName === 'Knowledge__kav' ? 'faq' : ''; 
        break;
      default:
        break;
    }
    const isHeaderRefreshed = !this.breadCrumbList.find(e => e.id === 'Home');
    if(isHeaderRefreshed){
      this.breadCrumbList.push({ label: "Help Centre", name: "ASDA help center home page", id: "Home", level: 1, pageApiName: 'Home', pageURL: window.location.origin+`/help`, pageName: 'ASDA help center home page' });
    }
    if (this.breadCrumbList.filter((e) => e.id === this.urlAlias).length > 0) {
      const currentObj = this.breadCrumbList.find((x) => x.id === this.urlAlias);
      this.removeBreadCrumb(currentObj);
    } else {
      this.urlChanged = true;
      this.observeMutations();
      this.isClickEventExecuted = false;
    }
  }
  connectedCallback() {
    if(this.pageType !== "standard__search"){
      this.breadCrumbList = [];
      this.urlChanged = this.pageName !== 'Home';
      this.breadCrumbList.push({ label: "Help Centre", name: "ASDA help center home page", id: "Home", level: 1, pageApiName: 'Home', pageURL: window.location.origin+`/help`, pageName: 'ASDA help center home page' });
      this.getStaticPageContents();
    }
  }
  observeMutations() {
    let breadCrumbObj;
    const observer = new MutationObserver((mutations) => {
      this.pageTitle = mutations[0].target.text;
      if (this.pageTitle !== 'ASDA help center home page' && this.urlChanged && !this.pageTitle.endsWith('Detail') && this.breadCrumbList.filter((e) => e.name === this.pageTitle).length <= 0) {
        observer.disconnect();
        this.urlChanged = false;
        if (this.pageName === 'faq' &&
          this.breadCrumbList.filter((e) => e.contentType === this.pageName).length > 0) {
          const foundArticleIndex = this.breadCrumbList.findIndex(x => x.contentType === this.pageName);
          breadCrumbObj = this.buildBreadcrumbObj(foundArticleIndex + 1);
          this.breadCrumbList[foundArticleIndex] = breadCrumbObj;
        } else {
          breadCrumbObj = this.buildBreadcrumbObj(this.breadCrumbList.length + 1);
          this.breadCrumbList.push(breadCrumbObj);
        }
      }
    });
    observer.observe(document.querySelector("title"), {
      subtree: true,
      characterData: true,
      childList: true
    });
    if(!this.pageTitle && (this.pageType === "standard__search")){
          this.pageTitle = 'Search';
          breadCrumbObj = this.buildBreadcrumbObj(this.breadCrumbList.length + 1);
          this.breadCrumbList.push(breadCrumbObj);
    }
  }

  removeBreadCrumb(breadCrumbObj) {
    const breadcrumbToBeRemoved = this.breadCrumbList.filter((obj) => obj.level > breadCrumbObj.level);
    this.breadCrumbList = this.breadCrumbList.filter((el) => !breadcrumbToBeRemoved.includes(el));
    this.breadcrumbObjAfterClick = {
      linkName: this.breadCrumbList.map(item => item.label).join('|'),
      linkURL: breadCrumbObj?.pageURL,
      pageURL: (breadcrumbToBeRemoved.length > 0) ? breadcrumbToBeRemoved[breadcrumbToBeRemoved.length - 1]?.pageURL : breadCrumbObj?.pageURL,
      pageName: (breadcrumbToBeRemoved.length > 0) ? breadcrumbToBeRemoved[breadcrumbToBeRemoved.length - 1]?.pageName : breadCrumbObj?.pageName,
    };
    if (this.isClickEventExecuted) this.processAdobeData();
  }
  buildBreadcrumbObj(objlevel) {
    return {
      label: this.pageTitle,
      name: this.pageTitle,
      id: (this.pageType === "standard__managedContentPage" || this.pageType === "standard__recordPage") ? this.urlAlias : this.pageName,
      level: objlevel,
      ...((this.pageName === 'news' || this.pageName === 'faq' || this.pageName === 'topics') ? { contentType: this.pageName } : { pageApiName: this.pageName }),
      ...((this.pageName === 'news' || this.pageName === 'faq' || this.pageName === 'topics') && { urlProperty: this.urlAlias }),
      ...((this.pageName === 'faq') && { recordId: this.recordId }),
      ...((this.pageTitle === 'Search') && { internalLink: '/search/'+this.pageName }),
      pageURL: window.location.href,
      pageName: document.title
    }
  }
  getStaticPageContents() {
    retrieveMediaFromCMS({
      channelName: this.channelName,
      maxPageSize: this.maxPageSize,
      contentType: this.cmsContentType
    })
      .then((data) => {
        try {
        this.staticPageContent = JSON.parse(JSON.stringify(data)).map((staticPageContent) => {
          return {
            label: staticPageContent.title,
            staticPageContent
          };
        });
        window.contactUsMetadata = this.staticPageContent;
          this.error = undefined;
        } catch (e) {
          console.error(e.message);
        }
      })
      .catch(console.error);
  }

  getAdobeMetadata() {
    if (!window.dataLayer) {
      window.dataLayer = getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.breadcrumbMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
    }
  }

  trackDataOnClick(event) {
    this.isClickEventExecuted = true;
    if (this.breadcrumbObjAfterClick && (event.target.dataset.title === document.title)) this.processAdobeData();
  }
  processAdobeData() {
    this.getAdobeMetadata();
    if (this.breadcrumbMetadataDataLayer) {
      let breadcrumbAnalyticsDetail = this.breadcrumbObjAfterClick && breadcrumbClickFunction(this.breadcrumbObjAfterClick, this.breadcrumbMetadataDataLayer);
      if (breadcrumbAnalyticsDetail) dispatchEventOnClick(breadcrumbAnalyticsDetail, this.breadcrumbMetadataDataLayer.OnclickEventName__c);
      this.isClickEventExecuted = false;
    }
  }
}