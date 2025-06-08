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
 * Disharee Ray                  14-Dec-2023     ASDAC-16707 Added displayCategories method
 ***************************************************************************************************/
public with sharing class ASDAC_DataCategoryHelper {
  /**
   * ****************************************************************************************************
   * @description method to get Data Category structure
   * @return List\<DescribeDataCategoryGroupStructureResult\>
   * ****************************************************************************************************
   */
  public List<DescribeDataCategoryGroupStructureResult> getDescribeDataCategoryGroupStructureResults() {
    List<DescribeDataCategoryGroupResult> describeCategoryResult;
    List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
    try {
      List<String> objType = new List<String>();
      objType.add('KnowledgeArticleVersion');
      describeCategoryResult = Schema.describeDataCategoryGroups(objType);
      List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
      for (DescribeDataCategoryGroupResult singleResult : describeCategoryResult) {
        DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
        p.setSobject(singleResult.getSobject());
        p.setDataCategoryGroupName(singleResult.getName());
        pairs.add(p);
      }
      describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
      for (DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult) {
        singleResult.getName();
        Schema.DataCategory[] toplevelCategories = singleResult.getTopCategories();
        List<Schema.DataCategory> allCategories = getAllCategories(toplevelCategories);
        for (Schema.DataCategory category : allCategories) {
          category.getName();
        }
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return describeCategoryStructureResult;
  }

  /**
   * ****************************************************************************************************
   * @param categories data category array
   * @description method to get all Data Categories
   * @return Schema.DataCategory[]
   * ****************************************************************************************************
   */
  public Schema.DataCategory[] getAllCategories(Schema.DataCategory[] categories) {
    if (categories.isEmpty()) {
      return new List<Schema.DataCategory>{};
    } else {
      Schema.DataCategory[] categoriesClone = categories.clone();
      Schema.DataCategory category = categoriesClone[0];
      Schema.DataCategory[] allCategories = new List<Schema.DataCategory>{ category };
      categoriesClone.remove(0);
      categoriesClone.addAll(category.getChildCategories());
      allCategories.addAll(getAllCategories(categoriesClone));
      return allCategories;
    }
  }
    
    public Map<String, List<String>> displayCategories(List<Schema.DataCategory> allCategories, String parentName,Map<String, List<String>> parentCategoryToChildCategoryMap){
	 for(Schema.DataCategory category : allCategories) {
         if(parentName!='' && parentName!=null){
           if(!parentCategoryToChildCategoryMap.containsKey(parentName)){
            parentCategoryToChildCategoryMap.put(parentName, new List<String>{});  
         }
         if(category.getName()!=null){
           parentCategoryToChildCategoryMap.get(parentName).add(category.getName()); 
         }   
         }
         
	   Schema.DataCategory[] childs = category.getChildCategories();
	   if(!childs.isEmpty()){
	     displayCategories(childs, category.getName(),parentCategoryToChildCategoryMap);
	   } 
	 }
     return parentCategoryToChildCategoryMap;
	}
}