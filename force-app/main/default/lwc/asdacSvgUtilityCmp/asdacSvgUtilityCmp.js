import { LightningElement, api } from "lwc";
import svgAsdaBurgerMenu from "./asdacBurgerMenuSvg.html";
import asdacFooterMasterCard from "./asdacFooterMasterCard.html";
import asdacFooterLogo from "./asdacFooterLogo.html";
import asdacFooterVisaLogo from "./asdacFooterVisaLogo.html";
import asdacFooterAmexLogo from "./asdacFooterAmexLogo.html";
import asdacFooterSafeKeyLogo from "./asdacFooterSafeKeyLogo.html";
import asdacFooterCard1Logo from "./asdacFooterCard1Logo.html";
import asdacFooterCard2Logo from "./asdacFooterCard2Logo.html";
import asdacFooterCard3Logo from "./asdacFooterCard3Logo.html";
import asdacFooterVerifiedByVisaLogo from "./asdacFooterVerifiedByVisaLogo.html";
import asdacChatbotSvg from "./asdacChatbotSvg.html";
import asdacMailIconSvg from "./asdacMailIconSvg.html";
import asdacWhatsappSvg from "./asdacWhatsappSvg.html";
import asdacPhoneIconSvg from "./asdacPhoneIconSvg.html";
import asdacFacebookIcon from "./asdacFacebookIcon.html";
import asdacTwitterIcon from "./asdacTwitterIcon.html";
import asdacInstagramIcon from "./asdacInstagramIcon.html";
import asdacPinterestIcon from "./asdacPinterestIcon.html";
import asdacLinkedinIcon from "./asdacLinkedinIcon.html";
import asdacYoutubeIcon from "./asdacYoutubeIcon.html";
import asdacVectorIcon from "./asdacVectorIcon.html";
import asdacFeedbackPositive from "./asdacFeedbackPositive";
import asdacFeedbackNegative from "./asdacFeedbackNegative";
import asdacContactWidgetSvg from "./asdacContactWidgetSvg";
import asdacDeleteAttachmentIcon from "./asdacDeleteAttachmentIcon";
import asdacCameraIcon from "./asdacCameraIcon";
import asdacWebformOrderIcon from "./asdacWebformOrderIcon";

export default class AsdacSvgUtilityCmp extends LightningElement {
  @api message;
  @api svgname;
  renderHtml = {
    burgerMenu: svgAsdaBurgerMenu,
    mastercard: asdacFooterMasterCard,
    footerLogo: asdacFooterLogo,
    visaLogo: asdacFooterVisaLogo,
    amexLogo: asdacFooterAmexLogo,
    safeKeyLogo: asdacFooterSafeKeyLogo,
    footercard1: asdacFooterCard1Logo,
    footercard2: asdacFooterCard2Logo,
    footercard3: asdacFooterCard3Logo,
    VerifiedLogo: asdacFooterVerifiedByVisaLogo,
    chatbotIcon: asdacChatbotSvg,
    mailIcon: asdacMailIconSvg,
    whatsappIcon: asdacWhatsappSvg,
    phoneIcon: asdacPhoneIconSvg,
    facebook: asdacFacebookIcon,
    twitter: asdacTwitterIcon,
    instagram: asdacInstagramIcon,
    pinterest: asdacPinterestIcon,
    linkedin: asdacLinkedinIcon,
    youtube: asdacYoutubeIcon,
    vectorIcon: asdacVectorIcon,
    contactUS: asdacContactWidgetSvg,
    FeedbackPositive: asdacFeedbackPositive,
    FeedbackNegative: asdacFeedbackNegative,
    deleteAttachmentIcon: asdacDeleteAttachmentIcon,
    cameraIcon:asdacCameraIcon,
    orderIcon:asdacWebformOrderIcon
  };
  render() {
    if (this.renderHtml[this.svgname]) {
      return this.renderHtml[this.svgname];
    }
    return svgAsdaBurgerMenu;
  }
}