import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.FirstName";
import ASDA_LOGO from "@salesforce/resourceUrl/asdaLogo";
import getNavigationMenuItems from "@salesforce/apex/ASDAC_NavigationMenuItemsController.getNavigationMenuItems";
import { dispatchEventOnClick, genericClickFunction, getDataLayerMetadata, HEADERCLICKS_LABEL, ASDA_LOGO_LABEL } from "c/asdacSendDataToAdobeCmp";
import ASDAC_ASDASiteURL from "@salesforce/label/c.ASDAC_ASDASiteURL";
export default class AsdacHeaderCmp extends NavigationMixin(LightningElement) {
  @api menuName;
  @api asdaLogoContentId;
  @api cmsContentType;
  @api maxPageSize;
  @track userFirstName;
  error;
  href = "#";
  isLoaded;
  menuItems = [];
  showBurgerMenu;
  menuItemData;
  asdaLogoIcon;
  asdaLogo = ASDA_LOGO;
  asdaSiteUrl = ASDAC_ASDASiteURL;
  moreASDAwebsiteLabel = "More Asda websites";
  channelName = "Help";
  mediaItems;
  masterLabel = HEADERCLICKS_LABEL;
  @track headerMetadataDataLayer;
  adobeMetadata;
  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  })
  wireuser({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.userFirstName = data.fields.FirstName.value;
    }
  }

  async connectedCallback() {
    if (!window.dataLayer) {
      window.dataLayer = await getDataLayerMetadata();
    }
    this.adobeMetadata = window.dataLayer;
    if (this.adobeMetadata?.dataLayerEventMetadataRecords) {
      this.headerMetadataDataLayer = this.adobeMetadata.dataLayerEventMetadataRecords.find(item => item.Label === this.masterLabel);
    }
  }


  @wire(getNavigationMenuItems, {
    menuName: "$menuName",
    channelName: "$channelName",
    maxPageSize: "$maxPageSize",
    contentType: "$cmsContentType"
  })
  wiredMenuItems({ error, data }) {
    if (data && !this.isLoaded) {
      let wrapperData = JSON.parse(JSON.stringify(data))[0];
      this.mediaItems = wrapperData.mediaContents.map((mediaItem) => {
        return {
          title: mediaItem.title,
          content: mediaItem.contentNodes.source,
          contentKey: mediaItem.contentKey
        };
      });
      let asdaLogoContent = this.mediaItems.filter(
        (item) => item.contentKey === this.asdaLogoContentId
      );
      this.asdaLogoIcon =
        asdaLogoContent.length > 0
          ? asdaLogoContent[0].content.url
          : this.asdaLogo;
      this.menuItemData = wrapperData.navigationalMenuItems;
      let navSubMenus = this.menuItemData
        .filter(
          (filteredMenu) => filteredMenu.label === this.moreASDAwebsiteLabel
        )[0]
        .subMenu.map((obj, index) => this.NavigationMenusArray(obj, index, []));
      this.menuItems = this.menuItemData.map((obj, index) =>
        this.NavigationMenusArray(obj, index, navSubMenus)
      );
      this.error = undefined;
      this.isLoaded = true;
    } else if (error) {
      this.error = error;
      this.menuItems = [];
      this.isLoaded = true;
    }
  }

  handleBurgerMenuToggle(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    if (this.showBurgerMenu) {
      this.showBurgerMenu = false;
    } else {
      this.showBurgerMenu = true;
    }
  }

  handleNavigation() {
    this.showBurgerMenu = false;
  }

  NavigationMenusArray(obj, index, navSubMenus) {
    let mediaContentArray = this.mediaItems.filter(
      (x) => x.title === obj.label
    );

    return {
      target: obj.target,
      id: index,
      label: obj.label,
      actionType: obj.actionType,
      actionValue: obj.actionValue,
      imageUrl:
        mediaContentArray.length > 0 ? mediaContentArray[0].content.url : "",
      subMenu: obj.label === this.moreASDAwebsiteLabel ? navSubMenus : []
    };
  }
  trackData() {
    if (this.headerMetadataDataLayer) {
      let buttonLabel = ASDA_LOGO_LABEL;
      let url = this.asdaSiteUrl;
      const headerAnalyticsDetail = genericClickFunction(buttonLabel, url, this.headerMetadataDataLayer);
      dispatchEventOnClick(headerAnalyticsDetail, this.headerMetadataDataLayer.OnclickEventName__c);
    }
  }
}