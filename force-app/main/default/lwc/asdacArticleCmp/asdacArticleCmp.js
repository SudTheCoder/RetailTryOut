import { api, LightningElement, wire } from "lwc";
import fetchArticle from "@salesforce/apex/ASDAC_LookupController.fetchArticle";
import {
  dispatchEventOnClick, dispatchEventOnLoad, genericClickFunction, pageLoadFunction,
  getDataLayerMetadata, FAQ_LABEL, webformInitiationFunction, INTERNALLINK_CLICK_LABEL,
  WEBFORM_LABEL
} from "c/asdacSendDataToAdobeCmp";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import ASDAC_HCWebformPagesMap from "@salesforce/label/c.ASDAC_HCWebformPagesMap";

export default class AsdacArticleCmp extends NavigationMixin(LightningElement) {
  @api articleId;
  article;
  masterLabel = FAQ_LABEL;
  articleMetaDataLayer;
  adobeMetadata;
  isLoaded = false;
  loadOnConnected = false;
  richTextContent;
  isConnectedCallback;

  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.isConnectedCallback = false;
    if (this.isLoaded || ((currentPageReference?.attributes?.recordId !== this.articleId) && this.articleId)) {
      const knowledgeArticleId = currentPageReference?.attributes?.recordId;
      this.getArticleData(knowledgeArticleId);
      this.loadOnConnected = false;
    } else {
      this.loadOnConnected = true;
    }
  }

  connectedCallback() {
    this.isConnectedCallback = true;
    this.isLoaded = true;
    if (this.loadOnConnected) {
      this.getArticleData(this.articleId);
    }
  }

  async getArticleData(knowledgeId) {
    this.articleId = knowledgeId;
    this.isLoaded = false;
    if (!knowledgeId) {
      return;
    }
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }

    fetchArticle({ articleId: knowledgeId })
      .then((data) => {
        document.title = data.Title;

        data = { ...data };
        try {
          const dom = new DOMParser().parseFromString(data.Answer__c || "", "text/html");
          // responsive video player (16:9 aspect ratio)
          dom.querySelectorAll("iframe").forEach((iframe) => {
            iframe.style.position = "absolute";
            iframe.width = "100%";
            iframe.height = "100%";
            const parent = iframe.parentElement;
            const container = dom.createElement("div");
            parent.insertBefore(container, iframe);
            container.style.display = "inline-flex";
            container.style.position = "relative";
            container.style.width = "100%";
            container.style.paddingBottom = "56.25%";
            container.appendChild(iframe);
          });
          // responsive images
          dom.querySelectorAll("img").forEach((img) => {
            img.removeAttribute("width");
            img.removeAttribute("height");
            img.style = "width: 100%; height: auto;";
          });
          data.Answer__c = dom.body.innerHTML;
        } catch (e) {
          console.error(e.message);
        }
        this.article = data;
        this.richTextContent = data.Answer__c;
        this.adobeMetadata = window.dataLayer;
        if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
          this.articleMetaDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
          let FAQAnalyticsDetail = pageLoadFunction(this.articleMetaDataLayer, this.adobeMetadata?.userDetails);
          const searchData = sessionStorage.getItem("searchData") ? JSON.parse(sessionStorage.getItem("searchData")) : '';
          FAQAnalyticsDetail.page = {
            ...FAQAnalyticsDetail?.page,
            ...(searchData?.searchTerm && { searchTerm: searchData?.searchTerm }),
            ...(searchData?.suggestedTerm && { suggestedTerm: searchData?.suggestedTerm })
          };
          dispatchEventOnLoad(FAQAnalyticsDetail, this.articleMetaDataLayer.OnloadEventName__c);
        }
      })
      .catch(console.error);
  }
  renderRichTextWithLinks() {
    const container = this.template.querySelector('.answer');
    container.innerHTML = this.richTextContent;
    // Add click event listeners to the hyperlinks and handle them
    const links = container.querySelectorAll('a');
    links.forEach(link => {
      link.addEventListener('click', this.handleHyperlinkClick.bind(this));
    });
  }

  // Handle hyperlink click
  handleHyperlinkClick(event) {
    event.preventDefault();
    let webformName = '';
    const webformMapList = JSON.parse(ASDAC_HCWebformPagesMap.replaceAll(/\r\n/g, ''))[0];
    let hrefValue = event.currentTarget.getAttribute("href").trim();
    const linkURL = (hrefValue.startsWith(window.location.protocol)||hrefValue.startsWith('mailto:') || hrefValue.startsWith('tel:')) ? hrefValue : window.location.origin + `${hrefValue}`;
    const linkName = event?.srcElement?.childNodes[0].textContent;
    if (webformMapList[hrefValue]) {
      webformName = webformMapList[hrefValue];
    }
    const datalayerMetadataLabel = webformName ? WEBFORM_LABEL : INTERNALLINK_CLICK_LABEL;
    const internalLinkMetadataLayer = event?.view?.dataLayer?.dataLayerEventMetadataRecords.find(item => item.Label === datalayerMetadataLabel);
    if (internalLinkMetadataLayer) {
      let internalLinkAnalyticsDetail = webformName ?
        webformInitiationFunction(linkName, linkURL, webformName, internalLinkMetadataLayer) :
        genericClickFunction(linkName, linkURL, internalLinkMetadataLayer);
      dispatchEventOnClick(internalLinkAnalyticsDetail, internalLinkMetadataLayer.OnclickEventName__c);
    }
    this.handleNavigate(hrefValue);
  }

  // Lifecycle hook to render the rich text content
  renderedCallback() {
    if (this.richTextContent !== undefined) this.renderRichTextWithLinks();
  }

  handleQuickTipLinkClick(event) {
    if (event?.detail) this.handleHyperlinkClick(event.detail);
  }

  handleNavigate(urlValue) {
    if (!urlValue) return;
    const isMailtoOrTel = urlValue.startsWith('mailto:') || urlValue.startsWith('tel:');
    if (isMailtoOrTel) {
    window.location.href = urlValue;
    } else {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: urlValue
        }
      });
    }
    sessionStorage.removeItem("loadEventTriggered");
  }
}