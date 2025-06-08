/******************************************************************************
Name: ASDAC_KnowledgeController
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
public with sharing class ASDAC_KnowledgeController {
  private static final String URL_NAME = 'URL Name';
  private static final String URL_NAME_FIELD = 'UrlName';
  private static final String KEYWORDS = 'Keywords';
  private static final String CATEGORIES = 'Categories';

  @AuraEnabled(cacheable=true)
  public static List<String> getFields(String recordType) {
    try {
      Map<String, String> fieldMap = getFieldMap(recordType);
      List<String> fields = new List<String>();
      fields.addAll(fieldMap.keySet());
      fields.add(KEYWORDS);
      fields.add(CATEGORIES);

      return fields;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=false)
  public static List<Map<String, Object>> exportKnowledge(String recordType, String publishStatus) {
    try {
      Map<String, String> fieldMap = getFieldMap(recordType);
      List<Id> draftArticles = new List<Id>();
      List<Knowledge__kav> articles = new List<Knowledge__kav>();
      Boolean draft = false;
      Boolean published = false;
      switch on publishStatus.toLowerCase() {
        when 'any' {
          draft = true;
          published = true;
        }
        when 'published' {
          published = true;
        }
        when else {
          draft = true;
        }
      }

      if (
        !Knowledge__kav.SObjectType.getDescribe().isAccessible() ||
        !TopicAssignment.SObjectType.getDescribe().isAccessible() ||
        !Knowledge__DataCategorySelection.SObjectType.getDescribe().isAccessible()
      ) {
        throw new AuraException('Insufficient Privileges');
      }

      String language;
      language = 'en_US';
      String status;
      String query;
      if (draft) {
        status = 'Draft';
        query =
          'SELECT ' +
          String.join(fieldMap.values(), ', ') +
          ', KnowledgeArticleId FROM Knowledge__kav WHERE RecordType.Name = :recordType AND PublishStatus = :status AND Language = :language';
        articles = Database.query(String.escapeSingleQuotes(query));
        for (Knowledge__kav article : articles) {
          draftArticles.add(article.KnowledgeArticleId);
        }
      }
      if (published) {
        status = 'Online';
        query =
          'SELECT ' +
          String.join(fieldMap.values(), ', ') +
          ' FROM Knowledge__kav WHERE KnowledgeArticleId NOT IN :draftArticles AND RecordType.Name = :recordType AND PublishStatus = :status AND Language = :language';
        List<Knowledge__kav> publishedArticles = Database.query(String.escapeSingleQuotes(query));
        articles.addAll(publishedArticles);
      }

      Map<Id, Map<String, Object>> articlesMap = convertArticles(articles, fieldMap);

      List<TopicAssignment> topicAssignments = [SELECT EntityId, Topic.Name FROM TopicAssignment WHERE EntityId IN :articlesMap.keySet()];
      for (TopicAssignment ta : topicAssignments) {
        ((List<String>) articlesMap.get(ta.EntityId).get(KEYWORDS)).add(ta.Topic.Name);
      }

      List<Knowledge__DataCategorySelection> categorySelections = [
        SELECT ParentId, DataCategoryGroupName, DataCategoryName
        FROM Knowledge__DataCategorySelection
        WHERE ParentId IN :articlesMap.keySet()
      ];
      for (Knowledge__DataCategorySelection cs : categorySelections) {
        if (recordType.equalsIgnoreCase(cs.DataCategoryGroupName)) {
          ((List<String>) articlesMap.get(cs.ParentId).get(CATEGORIES)).add(cs.DataCategoryName);
        }
      }

      return articlesMap.values();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=false)
  public static Integer importKnowledge(String recordType, List<Map<String, Object>> articleList) {
    try {
      if (
        !Knowledge__kav.SObjectType.getDescribe().isCreateable() ||
        !Knowledge__kav.SObjectType.getDescribe().isUpdateable() ||
        !Topic.SObjectType.getDescribe().isAccessible() ||
        !Topic.SObjectType.getDescribe().isCreateable() ||
        !TopicAssignment.SObjectType.getDescribe().isCreateable() ||
        !TopicAssignment.SObjectType.getDescribe().isDeletable() ||
        !Knowledge__DataCategorySelection.SObjectType.getDescribe().isCreateable() ||
        !Knowledge__DataCategorySelection.SObjectType.getDescribe().isDeletable()
      ) {
        throw new AuraException('Insufficient Privileges');
      }

      List<Knowledge__kav> articles = createKnowledgeArticles(recordType, articleList);
      Map<String, Id> topicToIdMap = createTopics(articleList);
      assignTopicsToArticles(articleList, articles, topicToIdMap);
      assignDataCategories(recordType, articleList, articles);

      return articles.size();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static Map<Id, Map<String, Object>> convertArticles(List<Knowledge__kav> articles, Map<String, String> fieldMap) {
    Map<Id, Map<String, Object>> articlesMap = new Map<Id, Map<String, Object>>();
    for (Knowledge__kav article : articles) {
      Map<String, Object> articleMap = new Map<String, Object>();
      for (String field : fieldMap.keySet()) {
        String fieldApi = fieldMap.get(field);
        articleMap.put(field, article.get(fieldApi));
      }
      articleMap.put(KEYWORDS, new List<String>());
      articleMap.put(CATEGORIES, new List<String>());
      articlesMap.put(article.Id, articleMap);
    }
    return articlesMap;
  }

  private static Map<String, String> getFieldMap(String recordType) {
    FieldSet fs = Knowledge__kav.SObjectType.getDescribe().fieldSets.getMap().get(recordType);
    if (fs == null) {
      throw new AuraException('Invalid Record Type');
    }
    Map<String, String> fieldMap = new Map<String, String>();
    for (FieldSetMember fsMember : fs.fields) {
      fieldMap.put(fsMember.label, fsMember.fieldpath);
    }
    return fieldMap;
  }

  private static List<Knowledge__kav> createKnowledgeArticles(String recordType, List<Map<String, Object>> articleList) {
    List<Knowledge__kav> articles = new List<Knowledge__kav>();
    Map<String, Id> mapArticleUrlToId = createArticles(recordType, articleList, articles);
    mapArticleUrlToDraftArticle(mapArticleUrlToId);

    for (Integer i = 0; i < articles.size(); i += 1) {
      Knowledge__kav article = articles[i];
      if (String.isBlank(article.UrlName)) {
        article.UrlName = article.Title.replaceAll('[^a-zA-Z0-9\\s+]', ' ').trim().replaceAll(' ', '-');
      }
      Id articleId = mapArticleUrlToId.get(article.UrlName);
      if (String.isNotEmpty(articleId)) {
        article.Id = articleId;
      }
    }
    upsert articles;
    for (Integer i = 0; i < articles.size(); i += 1) {
      articleList[i].put('Id', articles[i].Id);
    }

    return articles;
  }

  private static Map<String, Id> createArticles(String recordType, List<Map<String, Object>> articleList, List<Knowledge__kav> articles) {
    Map<String, Id> mapArticleUrlToId = new Map<String, Id>();
    Map<String, Schema.RecordTypeInfo> recordTypeMap = Knowledge__kav.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
    Id recordTypeId = recordTypeMap.get(recordType).recordTypeId;

    Map<String, String> fieldMap = getFieldMap(recordType);
    for (Map<String, Object> articleMap : articleList) {
      Knowledge__kav article = new Knowledge__kav(RecordTypeId = recordTypeId);
      for (String field : articleMap.keySet()) {
        if (!fieldMap.containsKey(field)) {
          continue;
        }
        String apiName = fieldMap.get(field);
        if (field.equals(URL_NAME)) {
          mapArticleUrlToId.put((String) articleMap.get(field), null);
        }
        article.put(apiName, articleMap.get(field));
      }
      articles.add(article);
    }
    return mapArticleUrlToId;
  }

  private static void mapArticleUrlToDraftArticle(Map<String, Id> mapArticleUrlToId) {
    Set<Id> publishedArticles = new Set<Id>();
    Map<Id, String> mapKnowledgeToUrlName = new Map<Id, String>();
    for (Knowledge__kav article : [
      SELECT KnowledgeArticleId,UrlName
      FROM Knowledge__kav
      WHERE UrlName IN :mapArticleUrlToId.keySet() AND PublishStatus = 'Online'
    ]) {
      publishedArticles.add(article.KnowledgeArticleId);
      mapKnowledgeToUrlName.put(article.KnowledgeArticleId, article.UrlName);
    }
    for (Knowledge__kav article : [
      SELECT Id, KnowledgeArticleId
      FROM Knowledge__kav
      WHERE KnowledgeArticleId IN :publishedArticles AND PublishStatus = 'Draft'
    ]) {
      publishedArticles.remove(article.KnowledgeArticleId);
      mapArticleUrlToId.put(mapKnowledgeToUrlName.get(article.KnowledgeArticleId), article.Id);
    }
    for (Id knowledgeArticleId : publishedArticles) {
      String draftId = KbManagement.PublishingService.editOnlineArticle(knowledgeArticleId, false);
      mapArticleUrlToId.put(mapKnowledgeToUrlName.get(knowledgeArticleId), draftId);
    }
    Set<String> urlsNotPublished = new Set<String>();
    for (String url : mapArticleUrlToId.keySet()) {
      if (String.isEmpty(mapArticleUrlToId.get(url))) {
        urlsNotPublished.add(url);
      }
    }
    for (Knowledge__kav article : [SELECT UrlName FROM Knowledge__kav WHERE UrlName IN :urlsNotPublished AND PublishStatus = 'Draft']) {
      mapArticleUrlToId.put(article.UrlName, article.Id);
    }
  }

  private static Map<String, Id> createTopics(List<Map<String, Object>> articleList) {
    List<Topic> topics = new List<Topic>();
    Map<String, Id> topicToIdMap = new Map<String, Id>();

    for (Map<String, Object> articleMap : articleList) {
      List<Object> keywordList = (List<Object>) articleMap.get(KEYWORDS);
      Set<String> setOfKeywords = new Set<String>();
      for (Object keywordObject : keywordList) {
        String keyword = ((String) keywordObject).toLowerCase();
        topicToIdMap.put(keyword, null);
        setOfKeywords.add(keyword);
      }
      List<String> listOfKeywords = new List<String>();
      listOfKeywords.addAll(setOfKeywords);
      articleMap.put(KEYWORDS, listOfKeywords);
    }

    // Remove topics which differ only in the whitespaces from another topic
    for (String topic : topicToIdMap.keySet()) {
      if (topic.containsWhitespace() && topicToIdMap.containsKey(topic.replaceAll('\\s+', ''))) {
        topicToIdMap.remove(topic);
      }
    }

    List<Topic> existingTopics = [SELECT Name FROM Topic WHERE Name IN :topicToIdMap.keySet()];
    for (Topic topicObject : existingTopics) {
      topicToIdMap.put(topicObject.Name.toLowerCase(), topicObject.Id);
    }
    for (String topic : topicToIdMap.keySet()) {
      if (topicToIdMap.get(topic) == null) {
        topics.add(new Topic(Name = topic));
      }
    }
    insert topics;
    for (Topic topicObject : topics) {
      topicToIdMap.put(topicObject.Name.toLowerCase(), topicObject.Id);
    }

    return topicToIdMap;
  }

  private static void assignTopicsToArticles(List<Map<String, Object>> articleList, List<Knowledge__kav> articles, Map<String, Id> topicToIdMap) {
    List<TopicAssignment> existingTopicAssignments = [SELECT EntityId, TopicId FROM TopicAssignment WHERE EntityId IN :articles];
    Map<Id, Map<Id, Id>> mapOfKnowledgeToTopics = new Map<Id, Map<Id, Id>>();
    for (Knowledge__kav article : articles) {
      mapOfKnowledgeToTopics.put(article.Id, new Map<Id, Id>());
    }
    for (TopicAssignment ta : existingTopicAssignments) {
      mapOfKnowledgeToTopics.get(ta.EntityId).put(ta.TopicId, ta.Id);
    }

    List<List<TopicAssignment>> results = createTopicAssignments(articleList, mapOfKnowledgeToTopics, topicToIdMap);
    List<TopicAssignment> topicAssignments = results[0];
    List<TopicAssignment> deleteableTopicAssignments = results[1];

    delete deleteableTopicAssignments;

    insert topicAssignments;
  }

  private static List<List<TopicAssignment>> createTopicAssignments(
    List<Map<String, Object>> articleList,
    Map<Id, Map<Id, Id>> mapOfKnowledgeToTopics,
    Map<String, Id> topicToIdMap
  ) {
    List<TopicAssignment> topicAssignments = new List<TopicAssignment>();
    List<TopicAssignment> deleteableTopicAssignments = new List<TopicAssignment>();
    for (Map<String, Object> articleMap : articleList) {
      Id articleId = (Id) articleMap.get('Id');
      Map<Id, Id> existingTopics = mapOfKnowledgeToTopics.get(articleId);
      for (String topic : (List<String>) articleMap.get(KEYWORDS)) {
        Id topicId = topicToIdMap.get(topic.toLowerCase());
        if (topicId == null) {
          continue;
        }
        if (existingTopics.containsKey(topicId)) {
          existingTopics.remove(topicId);
          continue;
        }
        topicAssignments.add(new TopicAssignment(EntityId = articleId, TopicId = topicId));
      }
      for (Id taId : existingTopics.values()) {
        deleteableTopicAssignments.add(new TopicAssignment(Id = taId));
      }
    }
    return new List<List<TopicAssignment>>{ topicAssignments, deleteableTopicAssignments };
  }

  private static void assignDataCategories(String groupName, List<Map<String, Object>> articleList, List<Knowledge__kav> articles) {
    List<Knowledge__DataCategorySelection> articleDataCategoryAssignments = new List<Knowledge__DataCategorySelection>();

    for (Map<String, Object> articleMap : articleList) {
      List<Object> categoryList = (List<Object>) articleMap.get(CATEGORIES);
      Set<String> setOfCategories = new Set<String>();
      for (Object category : categoryList) {
        setOfCategories.add((String) category);
      }
      for (String category : setOfCategories) {
        articleDataCategoryAssignments.add(
          new Knowledge__DataCategorySelection(ParentId = (Id) articleMap.get('Id'), DataCategoryGroupName = groupName, DataCategoryName = category)
        );
      }
    }

    List<Knowledge__DataCategorySelection> existingDataCategoryAssignments = [SELECT Id FROM Knowledge__DataCategorySelection WHERE ParentId IN :articles];
    ASDAC_WithoutSharingUtility.removeDataCategoryAssignments(existingDataCategoryAssignments);

    insert articleDataCategoryAssignments;
  }
}