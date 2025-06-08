import { api, LightningElement } from "lwc";
import fetchRelatedArticles from "@salesforce/apex/ASDAC_LookupController.fetchRelatedArticles";

export default class AsdacRelatedHelpCmp extends LightningElement {
  @api maxResults = 5;
  actions = [];
  articleId_;

  get showHelp() {
    return this.actions && this.actions.length > 0;
  }

  @api
  get articleId() {
    return this.articleId_;
  }
  set articleId(value) {
    this.articleId_ = value;
    this.getRelatedArticles();
  }

  getRelatedArticles() {
    if (this.articleId_) {
      fetchRelatedArticles({ articleId: this.articleId_, maxResults: this.maxResults })
        .then((articles) => {
          this.actions = articles.map((article) => ({
            label: article.Title,
            actionValue: article.UrlName,
            recordId: article.Id
          }));
        })
        .catch(console.error);
    }
  }
}