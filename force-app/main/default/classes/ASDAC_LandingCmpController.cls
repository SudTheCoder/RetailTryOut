/**********************************************************************************
 * @author                       : Shamikh Hassan
 * @date                         : 2022-06-06
 * @description                  : ASDAC-1197 FAQ categorisation phase 1
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Shamikh Hassan                06-June-2022    Created the class
 * Vineeth Rangamgari            08-August-2022  ASDAC-2224 Webform entry points
 * Disharee Ray                  14-Dec-2023     ASDAC-16707 refactored getFAQHierarchy method & removed other unused methods
 * Disharee Ray                  07-June-2024    ASDAC-20623 inroduced wrapper class & added a extra map to hold the data category details
 ***************************************************************************************************/
public with sharing class ASDAC_LandingCmpController {
  /**
   * ****************************************************************************************************
   * @description method to get FAQ Hierarchy
   * @Returns a wrapper object with one Map<String,String> for category labels and a Map<String,Map<String,List<Knowledge__kav>>> to get the entire FAQ hierarchy.
   * ****************************************************************************************************
   */
  @AuraEnabled
  public static DataCategoryArticlesWrapper getFAQHierarchy() {
    Map<String, List<String>> parentCategoryToChildCategoryMap= new Map<String, List<String>>();
    Map<String,Map<String,List<Knowledge__kav>>> faqHierarchyMap= new Map<String,Map<String,List<Knowledge__kav>>>();
    Map<String, String> categoryUniqueNameToLabelMap = new Map<String, String>();
    DataCategoryArticlesWrapper resWrap = new DataCategoryArticlesWrapper();
    try {
      if (
        !Knowledge__kav.SObjectType.getDescribe().isAccessible() ||
        !Knowledge__DataCategorySelection.SObjectType.getDescribe().isAccessible()
      ) {
        throw new AuraException('Insufficient Privileges');
      }
    ASDAC_DataCategoryHelper dc = new ASDAC_DataCategoryHelper();
    for (
        DescribeDataCategoryGroupStructureResult singleResult : dc.getDescribeDataCategoryGroupStructureResults()
      ) {
        Schema.DataCategory[] toplevelCategories = singleResult.getTopCategories();
        List<Schema.DataCategory> allCategories = dc.getAllCategories(
          toplevelCategories
        );
        List<Schema.DataCategory> categoryToIterate = new List<Schema.DataCategory>();
        for (Schema.DataCategory category : allCategories) {
          if (category.getName().equalsIgnoreCase('All')) {
            categoryToIterate.add(category);
          }
        }
        categoryUniqueNameToLabelMap = buildCategoryMap(
          categoryToIterate,
          categoryUniqueNameToLabelMap
        );
        parentCategoryToChildCategoryMap = dc.displayCategories(
          categoryToIterate,
          '',
          parentCategoryToChildCategoryMap
        );
      }
      Map<String, List<Knowledge__kav>> categoryToArticlesMap = getCategoryToArticleMap();
      if (!categoryToArticlesMap.isEmpty()) {
        faqHierarchyMap = buildFaqHierarchyMap(
          parentCategoryToChildCategoryMap,
          categoryToArticlesMap
        );
      }
      resWrap.categoryUniqueNameToLabelMap = categoryUniqueNameToLabelMap;
      resWrap.faqHierarchyMap = faqHierarchyMap;
      return resWrap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * ****************************************************************************************************
   * @description method to get Webform entry points
   * @return Map\<String, WebformEntryPoint__mdt\>
   * ****************************************************************************************************
   */
  @AuraEnabled
  public static Map<String, WebformEntryPoint__mdt> getWebformEntryPoints() {
    List<WebformEntryPoint__mdt> webformEntryPoints = WebformEntryPoint__mdt.getAll()
      .values();
    Map<String, WebformEntryPoint__mdt> mapOfWebformEntryPoint = new Map<String, WebformEntryPoint__mdt>();
    for (WebformEntryPoint__mdt webformEntryPoint : webformEntryPoints) {
      mapOfWebformEntryPoint.put(
        webformEntryPoint.MasterLabel,
        webformEntryPoint
      );
    }
    return mapOfWebformEntryPoint;
  }

  /**
   * ****************************************************************************************************
   * @description method to get a Map of Data category to its all the related article list
   * @return Map<String,List<Knowledge__kav>>
   * ****************************************************************************************************
   */
  public static Map<String, List<Knowledge__kav>> getCategoryToArticleMap() {
    Map<String, List<Knowledge__kav>> categoryToArticlesMap = new Map<String, List<Knowledge__kav>>();
    for (Knowledge__DataCategorySelection kdc : [
      SELECT Id, ParentId, Parent.Title, Parent.UrlName, DataCategoryName
      FROM Knowledge__DataCategorySelection
      WHERE Parent.PublishStatus = 'Online'
    ]) {
      if (!categoryToArticlesMap.containsKey(kdc.DataCategoryName)) {
        categoryToArticlesMap.put(
          kdc.DataCategoryName,
          new List<Knowledge__kav>{}
        );
      }
      Knowledge__kav kav = new Knowledge__kav(
        Id = kdc.ParentId,
        Title = kdc.Parent.Title,
        UrlName = kdc.Parent.UrlName
      );
      categoryToArticlesMap.get(kdc.DataCategoryName).add(kav);
    }
    return categoryToArticlesMap;
  }

  /**
   * ****************************************************************************************************
   * @description method to get a Map of parent Data category to its child map of categoryToArticlesMap
   * @return Map<String,Map<String,List<Knowledge__kav>>>
   * ****************************************************************************************************
   */
  public static Map<String, Map<String, List<Knowledge__kav>>> buildFaqHierarchyMap(
    Map<String, List<String>> parentCategoryToChildCategoryMap,
    Map<String, List<Knowledge__kav>> categoryToArticlesMap
  ) {
    Map<String, Map<String, List<Knowledge__kav>>> dataCategoryHierarchyToArticlesMap = new Map<String, Map<String, List<Knowledge__kav>>>();
    for (String category : parentCategoryToChildCategoryMap.keySet()) {
      if (!dataCategoryHierarchyToArticlesMap.containsKey(category)) {
        dataCategoryHierarchyToArticlesMap.put(
          category,
          new Map<String, List<Knowledge__kav>>()
        );
      }
      for (
        String subCategory : parentCategoryToChildCategoryMap.get(category)
      ) {
        if (
          !dataCategoryHierarchyToArticlesMap.get(category)
            .containsKey(subcategory)
        ) {
          dataCategoryHierarchyToArticlesMap.get(category)
            .put(subcategory, new List<Knowledge__kav>());
        }
        if (categoryToArticlesMap.containsKey(subCategory)) {
          dataCategoryHierarchyToArticlesMap.get(category)
            .get(subcategory)
            .addAll(categoryToArticlesMap.get(subCategory));
        }
      }
    }
    return dataCategoryHierarchyToArticlesMap;
  }

  /**
   * ****************************************************************************************************
   * @description method to get a Map of Data category with Unique name as key & label as value
   * @return Map<String,String>
   * ****************************************************************************************************
   */
  public static Map<String, String> buildCategoryMap(
    List<Schema.DataCategory> allCategories,
    Map<String, String> categoryUniqueNameToLabelMap
  ) {
    for (Schema.DataCategory category : allCategories) {
      if (!categoryUniqueNameToLabelMap.containskey(category.getName())) {
        categoryUniqueNameToLabelMap.put(
          category.getName(),
          category.getlabel()
        );
      }
      Schema.DataCategory[] childs = category.getChildCategories();
      if (!childs.isEmpty()) {
        buildCategoryMap(childs, categoryUniqueNameToLabelMap);
      }
    }
    return categoryUniqueNameToLabelMap;
  }

  /**
   * ****************************************************************************************************
   * @description wrapper class to hold 2 different maps & pass it to respective lwc
   * @return DataCategoryArticlesWrapper
   * ****************************************************************************************************
   */
  public class DataCategoryArticlesWrapper {
    @AuraEnabled
    public Map<String, String> categoryUniqueNameToLabelMap;
    @AuraEnabled
    public Map<String, Map<String, List<Knowledge__kav>>> faqHierarchyMap;
  }
}