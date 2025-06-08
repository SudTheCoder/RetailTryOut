declare module "@salesforce/apex/ASDAC_LookupController.fetchLookupData" {
  export default function fetchLookupData(param: {searchKey: any, maxResults: any, maxKeywords: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_LookupController.fetchArticleByTopicName" {
  export default function fetchArticleByTopicName(param: {searchKey: any, topicName: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_LookupController.fetchArticle" {
  export default function fetchArticle(param: {articleId: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_LookupController.fetchRelatedArticles" {
  export default function fetchRelatedArticles(param: {articleId: any, maxResults: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_LookupController.fetchFeaturedArticles" {
  export default function fetchFeaturedArticles(param: {searchKey: any, maxResults: any}): Promise<any>;
}
