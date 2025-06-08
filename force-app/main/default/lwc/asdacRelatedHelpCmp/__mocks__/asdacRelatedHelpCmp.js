import { api, LightningElement } from "lwc";

export default class AsdacRelatedHelpCmp extends LightningElement {
  @api articleId;
  @api maxResults = 5;
}