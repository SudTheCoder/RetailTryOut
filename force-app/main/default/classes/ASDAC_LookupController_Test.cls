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
 * Vineeth Rangamgari            24-August-2022  ASDAC-2092 Auto completion (Help Centre)
 * Disharee Ray                  25-August-2022  ASDAC-2086 Enable personalized articles
 * Vineeth Rangamgari            08-August-2022  ASDAC-2087 Enable pinned articles
 * Vineeth Rangamgari            12-October-2022 ASDAC-3542 Search Results
 * Vineeth Rangamgari            20-October-2022 ASDAC-3512 Help Centre: Knowledge Article Page
 * Vineeth Rangamgari            22-Nov-2022     ASDAC-3529 Help Centre iterations - related content
 * Disharee Ray                  11-Jan-2023     ASDAC-3543 Help Centre Iterations - Featured Results
 ***************************************************************************************************/
@isTest(seealldata=false)
public with sharing class ASDAC_LookupController_Test {
  public final static String ARTICLE_TITLE = 'Test Article';
  public final static String RELATED_ARTICLE_TITLE = 'Test Related Article';
  public final static String FEATURED_ARTICLE_TITLE = 'Test Featured Article';
  @testSetup
  static void setup() {
    String articleTitle = ARTICLE_TITLE;
    String articleBody = 'Test Body';
    String articleUrlName = 'Apex-test-kav-article';
    String language = 'en_US';
    Knowledge__kav article = new Knowledge__kav(Title = articleTitle, Summary = articleBody, UrlName = articleUrlName, Language = language);
    insert article;
    Topic topic = new Topic(Name = 'Test-Personalized');
    insert topic;
    TopicAssignment tas = new TopicAssignment(TopicId = topic.Id, EntityId = article.Id);
    insert tas;

    Knowledge__kav relatedArticle = new Knowledge__kav(Title = RELATED_ARTICLE_TITLE, Summary = articleBody, UrlName = RELATED_ARTICLE_TITLE.replace(' ', '-'), Language = language);
    insert relatedArticle;
      
    Knowledge__kav featuredArticle = new Knowledge__kav(Title = FEATURED_ARTICLE_TITLE,
                                                        Summary = articleBody,
                                                        UrlName = FEATURED_ARTICLE_TITLE.replace(' ', '-'),
                                                        Language = language,
                                                        Featured_Article__c=true,
                                                        Feature_Result_Title__c=FEATURED_ARTICLE_TITLE,
                                                        Feature_Result_Text__c='Test1');
    insert featuredArticle;

    String groupName = 'FAQ';
    List<String> categories = ASDAC_TestDataUtility.getKnowledgeCategories(groupName);
    String category = categories[0];
    List<Knowledge__DataCategorySelection> dcSelections = new List<Knowledge__DataCategorySelection>();
    for (Integer i = 0;i < 2;i++) {
      dcSelections.add(new Knowledge__DataCategorySelection(ParentId = article.Id, DataCategoryGroupName = groupName, DataCategoryName = category));
    }
    dcSelections[1].ParentId = relatedArticle.Id;
    insert dcSelections;

    article = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :article.Id];
    KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);

    relatedArticle = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :relatedArticle.Id];
    KbManagement.PublishingService.publishArticle(relatedArticle.KnowledgeArticleId, true);
     
    featuredArticle = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :featuredArticle.Id];
    KbManagement.PublishingService.publishArticle(featuredArticle.KnowledgeArticleId, true);
  }

  @IsTest
  static void testFetchLookupData() {
    Knowledge__kav currentArticle = [SELECT id, title, KnowledgeArticleId, Language, PublishStatus FROM Knowledge__kav WHERE title = :ARTICLE_TITLE];
    Id[] fixedSearchResults = new Id[1];
    fixedSearchResults[0] = currentArticle.id;
    Test.setFixedSearchResults(fixedSearchResults);
    List<Map<String, Object>> articles = ASDAC_LookupController.fetchLookupData(ARTICLE_TITLE, 3, 3);
    system.assertEquals(articles[0].get('Title'), ARTICLE_TITLE, 'Expected FAQ with title: ' + ARTICLE_TITLE);
  }

  @IsTest
  static void testfetchArticleByTopicName() {
    Knowledge__kav currentArticle = [SELECT id, title, KnowledgeArticleId, Language, PublishStatus FROM Knowledge__kav WHERE title = :ARTICLE_TITLE];
    Id[] fixedSearchResults = new Id[1];
    fixedSearchResults[0] = currentArticle.id;
    Test.setFixedSearchResults(fixedSearchResults);
    List<Knowledge__kav> articleList = (List<Knowledge__kav>) ASDAC_LookupController.fetchArticleByTopicName('Test', 'Test-Personalized');
    system.assertEquals(articleList[0].Title, ARTICLE_TITLE);
  }

  @IsTest
  static void testFetchArticle() {
    Knowledge__kav article = [SELECT Id,UrlName FROM Knowledge__kav WHERE Title = :ARTICLE_TITLE];
    Knowledge__kav result = (Knowledge__kav) ASDAC_LookupController.fetchArticle(article.Id);
    System.assertEquals(result.Id, article.Id, 'Expected same article');
  }

  @IsTest
  static void testFetchRelatedArticles() {
    Knowledge__kav article = [SELECT UrlName FROM Knowledge__kav WHERE Title = :ARTICLE_TITLE];
    Knowledge__kav relatedArticle = [SELECT UrlName FROM Knowledge__kav WHERE Title = :RELATED_ARTICLE_TITLE];
    List<Knowledge__kav> results = ASDAC_LookupController.fetchRelatedArticles(article.Id, 5);
    System.assertEquals(results.size(), 1, 'Expected only 1 related article');
    System.assertEquals(results[0].Id, relatedArticle.Id, 'Expected related article');
  }
    
  @IsTest
  static void testFetchFeaturedArticles() {
    String searchKey='test';
    Knowledge__kav featuredArticle = [SELECT UrlName,Feature_Result_Text__c,Featured_Article__c FROM Knowledge__kav WHERE Title = :FEATURED_ARTICLE_TITLE];
    List<Knowledge__kav> featuredResults = ASDAC_LookupController.fetchFeaturedArticles(searchKey, 1);
    System.assertEquals(featuredResults.size(), 1, 'Expected only 1 featured article');
    System.assertEquals(featuredResults[0].Featured_Article__c, featuredArticle.Featured_Article__c, 'Expected featured article');
  }
}