/**********************************************************************************
 * @author                       : Shamikh Hassan
 * @date                         : 2022-06-16
 * @description                  : ASDAC-1384 FAQ categorisation phase 2 . Test class for ASDAC_LandingCmpController
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Shamikh Hassan                16-June-2022    Created the class
 * Vineeth Rangamgari            08-August-2022  ASDAC-2224 Webform entry points
 * Vineeth Rangamgari            24-August-2022  ASDAC-2092 Auto completion (Help Centre)
 * Disharee Ray                  25-August-2022  ASDAC-2086 Enable personalized articles
 * Vineeth Rangamgari            26-August-2022  ASDAC-2087 Enable pinned articles
 * Vineeth Rangamgari            12-October-2022 ASDAC-3542 Search Results
 * Vineeth Rangamgari            20-October-2022 ASDAC-3512 Help Centre: Knowledge Article Page
 * Vineeth Rangamgari            22-Nov-2022     ASDAC-3529 Help Centre iterations - related content
 * Disharee Ray                  10-January-2023 ASDAC-3543 Help Centre Iterations - Featured Results
 ***************************************************************************************************/
public with sharing class ASDAC_LookupController {
  /**
   * ****************************************************************************************************
   * @param searchKey search key
   * @description method to fetch lookup search result
   * @return List\<Knowledge__kav\>
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static List<Map<String, Object>> fetchLookupData(String searchKey, Integer maxResults, Integer maxKeywords) {
    string sWildCardText = String.escapeSingleQuotes('*' + searchKey.replace('*', '\\*') + '*');
    if (maxResults == null || maxResults == 0) {
      maxResults = 3;
    }
    List<List<SObject>> soslResult = [
      FIND :sWildCardText
      IN ALL FIELDS
      RETURNING
        Knowledge__kav(
          Id,
          Title,
          Answer__c,
          UrlName
          WHERE PublishStatus = 'Online' AND Language = 'en_US' AND Featured_Article__c != true
          LIMIT :maxResults)
    ];
    List<Knowledge__kav> articles = (List<Knowledge__kav>) soslResult[0];
    Map<Id, Map<String, Object>> mapIdToArticle = new Map<Id, Map<String, Object>>();
    Map<Id, List<String>> mapIdToKeywords = new Map<Id, List<String>>();
    for (Knowledge__kav article : articles) {
      Map<String, Object> articleMap = new Map<String, Object>();
      articleMap.put('Id', article.Id);
      articleMap.put('Title', article.Title);
      articleMap.put('Answer__c', article.Answer__c);
      articleMap.put('UrlName', article.UrlName);
      mapIdToArticle.put(article.Id, articleMap);
      mapIdToKeywords.put(article.Id, new List<String>());
    }
    if (maxKeywords > 0) {
      for (TopicAssignment ta : ASDAC_WithoutSharingUtility.getTopicAssignmentsByArticles(mapIdToArticle.keySet())) {
        if (mapIdToKeywords.get(ta.EntityId).size() >= maxKeywords) {
          continue;
        }
        mapIdToKeywords.get(ta.EntityId).add(ta.Topic.Name);
      }
      for (Id articleId : mapIdToArticle.keySet()) {
        mapIdToArticle.get(articleId).put('Keywords', mapIdToKeywords.get(articleId));
      }
    }
    return mapIdToArticle.values();
  }

  /**
   * ****************************************************************************************************
   * @param searchKey search key
   * @param topicName topic name
   * @description method to fetch articles based on search key and topic attached
   * @return List\<Knowledge__kav\>
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static List<Knowledge__kav> fetchArticleByTopicName(String searchKey, String topicName) {
    string sWildCardText = String.escapeSingleQuotes('*' + searchKey.replace('*', '\\*') + '*');
    List<List<SObject>> soslResult = [
      FIND :sWildCardText
      IN ALL FIELDS
      RETURNING Knowledge__kav(Id, Title WHERE PublishStatus = 'Online' AND Language = 'en_US' AND Featured_Article__c != true ORDER BY ArticleTotalViewCount DESC LIMIT 25)
    ];
    Map<Id, Knowledge__kav> articlesMap = new Map<Id, Knowledge__kav>((List<Knowledge__kav>) soslResult[0]);
    List<TopicAssignment> topicAssignments = ASDAC_WithoutSharingUtility.getTopicAssignmentsByTopic(topicName, articlesMap.keySet());
    List<Knowledge__kav> articles = new List<Knowledge__kav>();
    for (TopicAssignment topicsAssignment : topicAssignments) {
      articles.add(articlesMap.get(topicsAssignment.EntityId));
    }
    return articles;
  }

  /**
   * ****************************************************************************************************
   * @param articleId article Id
   * @description method to fetch article record
   * @return Knowledge__kav
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static Knowledge__kav fetchArticle(string articleId) {
    String query = 'Select Id, Title, Answer__c, UrlName, QuickTip__c, Show_Call_Channel__c, Show_Message_Channel__c FROM Knowledge__kav Where Id = :articleId AND PublishStatus = \'Online\' LIMIT 1 UPDATE VIEWSTAT';
    List<Knowledge__kav> articles = Database.query(query);
    if (articles.isEmpty()) {
      throw new AuraHandledException('Invalid Id');
    }
    return articles[0];
  }

  /**
   * ****************************************************************************************************
   * @param articleId article Id
   * @description method to fetch related articles based on the given article's category
   * @return List\<Knowledge__kav\>
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static List<Knowledge__kav> fetchRelatedArticles(string articleId, Integer maxResults) {
    List<String> categories = new List<String>();
    for (Knowledge__DataCategorySelection dcSelection : [SELECT DataCategoryName FROM Knowledge__DataCategorySelection WHERE ParentId = :articleId WITH SECURITY_ENFORCED]) {
      categories.add(dcSelection.DataCategoryName + '__c');
    }
    if (categories.size() == 0) {
      return new List<Knowledge__kav>();
    }
    String query = 'Select Title, UrlName FROM Knowledge__kav WHERE Id != :articleId AND PublishStatus = \'Online\' AND Featured_Article__c != true WITH DATA CATEGORY FAQ__c AT (' + String.join(categories, ', ') + ') ORDER BY ArticleTotalViewCount DESC LIMIT :maxResults';
    List<Knowledge__kav> articles = Database.query(query);
    return articles;
  }

 /**
   * ****************************************************************************************************
   * @param searchKey search term
   * @param maxResults maximum number of articles to be returned
   * @description method to fetch featured articles
   * @return List\<Knowledge__kav\>
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static List<Knowledge__kav> fetchFeaturedArticles(String searchKey,Integer maxResults) {
       String query = 'SELECT Id, Title, Upload_Feature_Result_Image__c, Feature_Result_Title__c, Feature_Result_Text__c, Featured_Article__c FROM Knowledge__kav WHERE '+
                      'Featured_Article__c= true AND PublishStatus = \'Online\' ORDER BY LastPublishedDate  DESC LIMIT :maxResults';
       List<Knowledge__kav> articles = Database.query(query);
       return articles; 
  }
}