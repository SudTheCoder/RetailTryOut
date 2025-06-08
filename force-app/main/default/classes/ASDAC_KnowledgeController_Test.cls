/******************************************************************************
Name: ASDAC_KnowledgeController_Test
===============================================================================
Req: 
ASDAC-928 Analyse the FAQs in the knowledge management system (POC)
===============================================================================
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                	DATE         	DETAIL
1.0       Vineeth Rangamgari 		1 Sep 2022     Initial Development
2.0       Disharee Ray          10 July 2023   ASDAC-13589 [Knowledge Import] Unable to import knowledge articles via Knowledge import Wizard
******************************************************************************/
@IsTest
public with sharing class ASDAC_KnowledgeController_Test {
  private final static String RECORD_TYPE = 'FAQ';
  private final static String TOPIC_SUFFIX = 'VGVzdCBUb3BpYw==';
  private final static String EXISTING_TOPIC = 'Existing ' + TOPIC_SUFFIX;

  @TestSetup
  static void createArticles() {
    List<Knowledge__kav> articles = new List<Knowledge__kav>();
    for (Integer i = 0; i < 4; i++) {
      Knowledge__kav article = new Knowledge__kav(Title = 'Test-Article-' + (i + 1), UrlName = System.currentTimeMillis() + '-' + (i + 1));
      articles.add(article);
    }
    insert articles;

    articles = [SELECT Title, UrlName, KnowledgeArticleId FROM Knowledge__kav WHERE Id IN :articles];

    for (Integer i = 0; i < 2; i++) {
      KbManagement.PublishingService.publishArticle(articles[i].KnowledgeArticleId, true);
    }

    articles[1].Id = KbManagement.PublishingService.editOnlineArticle(articles[1].KnowledgeArticleId, false);

    List<Topic> existingTopics = new List<Topic>{ new Topic(Name = EXISTING_TOPIC), new Topic(Name = EXISTING_TOPIC + ' deletable') };
    insert existingTopics;

    List<TopicAssignment> existingTopicAssignments = new List<TopicAssignment>();
    for (Topic t : existingTopics) {
      existingTopicAssignments.add(new TopicAssignment(EntityId = articles[3].Id, TopicId = t.Id));
    }
    insert existingTopicAssignments;

    List<String> categories = ASDAC_TestDataUtility.getKnowledgeCategories(RECORD_TYPE);
    List<Knowledge__DataCategorySelection> categorySelections = new List<Knowledge__DataCategorySelection>();
    for (Integer i = 0; i < 4; i++) {
      Integer j = Math.mod(i, categories.size());
      categorySelections.add(
        new Knowledge__DataCategorySelection(ParentId = articles[0].Id, DataCategoryGroupName = RECORD_TYPE, DataCategoryName = categories[j])
      );
    }
    ASDAC_WithoutSharingUtility.insertObjects(categorySelections);
  }

  @IsTest
  static void testGetFields() {
    List<String> fields = ASDAC_KnowledgeController.getFields(RECORD_TYPE);
    System.assert(fields.contains('URL Name'), 'Expected URL Name field');
    System.assert(fields.contains('Keywords'), 'Expected Keywords field');
    System.assert(fields.contains('Categories'), 'Expected Categories field');
  }

  // Export
  // 2 articles in draft state
  // 1 article in published state
  // 1 article in both published and draft state

  @IsTest
  static void testExportPublishedArticles() {
    List<Map<String, Object>> articles = ASDAC_KnowledgeController.exportKnowledge(RECORD_TYPE, 'Published');
    System.assertEquals(2, articles.size(), 'Expected 2 articles to be exported');
  }

  @IsTest
  static void testExportDraftArticles() {
    List<Map<String, Object>> articles = ASDAC_KnowledgeController.exportKnowledge(RECORD_TYPE, 'Draft');
    System.assertEquals(3, articles.size(), 'Expected 3 articles to be exported');
  }

  @IsTest
  static void testExportAllArticles() {
    List<Map<String, Object>> articles = ASDAC_KnowledgeController.exportKnowledge(RECORD_TYPE, 'Any');
    System.assertEquals(4, articles.size(), 'Expected 4 articles to be exported');
  }

  // Import
  // 1 article in published state
  // 1 article in draft state
  // 1 article in both published and draft state
  // 1 new article

  @IsTest
  static void testImportArticles() {
    List<Knowledge__kav> publishedArticles = [SELECT Title, UrlName FROM Knowledge__kav WHERE PublishStatus = 'Online'];
    List<Knowledge__kav> draftArticles = [SELECT Title, UrlName FROM Knowledge__kav WHERE PublishStatus = 'Draft'];
    List<Knowledge__kav> articles = new List<Knowledge__kav>{
      publishedArticles[0],
      publishedArticles[1],
      draftArticles[2],
      new Knowledge__kav(Title = 'Test-Article-8')
    };
    List<List<String>> keywords = new List<List<String>>{
      new List<String>{ 'Refund ' + TOPIC_SUFFIX, 'Return ' + TOPIC_SUFFIX, 'Pinned ' + TOPIC_SUFFIX },
      new List<String>{ 'Payment ' + TOPIC_SUFFIX, 'Payment ' + TOPIC_SUFFIX, 'Personalized ' + TOPIC_SUFFIX },
      new List<String>{ EXISTING_TOPIC, 'Return ' + TOPIC_SUFFIX, 'Over Charged ' + TOPIC_SUFFIX, 'OverCharged' + TOPIC_SUFFIX },
      new List<String>{ 'International ' + TOPIC_SUFFIX, 'Europe ' + TOPIC_SUFFIX }
    };
    List<String> dataCategories = ASDAC_TestDataUtility.getKnowledgeCategories(RECORD_TYPE);
    List<List<String>> categories = new List<List<String>>();
    for (Integer i = 0; i < articles.size(); i++) {
      Integer j = Math.mod(dataCategories.size() - 1 - i, dataCategories.size());
      categories.add(new List<String>{ dataCategories[j] });
    }
    categories[0].add(categories[0][0]);

    List<Map<String, Object>> articleList = new List<Map<String, Object>>();
    for (Integer i = 0; i < articles.size(); i++) {
      Map<String, Object> articleMap = new Map<String, Object>();
      articleMap.put('Title', articles[i].Title);
      articleMap.put('URL Name', articles[i].UrlName);
      articleMap.put('Keywords', keywords[i]);
      articleMap.put('Categories', categories[i]);
      articleList.add(articleMap);
    }

    Integer numberOfImportedArticles = ASDAC_KnowledgeController.importKnowledge(RECORD_TYPE, articleList);
    System.assertEquals(4, numberOfImportedArticles, 'Expected 4 articles to be imported');
  }
}