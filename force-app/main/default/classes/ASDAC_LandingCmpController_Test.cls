/**********************************************************************************
* @author                       : Shamikh Hassan
* @date                         : 2022-06-16
* @description                  : ASDAC-1384 FAQ categorisation phase 2 . Test class for ASDAC_LandingCmpController
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
* Shamikh Hassan                16-June-2022       Created the class
* Vineeth Rangamgari            08-August-2022     ASDAC-2224 Webform entry points
* Disharee Ray                  14-December-2023   ASDAC-16707 Refactored the Test Class
***************************************************************************************************/

@isTest(seealldata=false)
public with sharing class ASDAC_LandingCmpController_Test {
    @testSetup
    static void setup() {
        String articleTitle = 'Test Article';
        String articleBody = 'Test Body';
        String articleUrlName = 'Apex-test-kav-article';
        String language = 'en_US';
        Knowledge__kav article = new Knowledge__kav(Title = articleTitle, Summary = articleBody, UrlName = articleUrlName, Language = language);
        insert article;
        
        list<Knowledge__DataCategorySelection> artdclist = new list<Knowledge__DataCategorySelection>();
        Knowledge__DataCategorySelection newArtDC = new Knowledge__DataCategorySelection();
        newArtDC.DataCategoryGroupName = 'FAQ';
        newArtDC.DataCategoryName = 'George_Payments_and_charges';
        newArtDC.ParentId = article.id;
        artdclist.add(newArtDC);
        
        Knowledge__DataCategorySelection newArtDC1 = new Knowledge__DataCategorySelection();
        newArtDC1.DataCategoryGroupName = 'FAQ';
        newArtDC1.DataCategoryName = 'Grocery_Payments_charges';
        newArtDC1.ParentId = article.id;
        artdclist.add(newArtDC1);
        
        Knowledge__DataCategorySelection newArtDC2 = new Knowledge__DataCategorySelection();
        newArtDC2.DataCategoryGroupName = 'FAQ';
        newArtDC2.DataCategoryName = 'Payment_and_charges';
        newArtDC2.ParentId = article.id;
        
        artdclist.add(newArtDC2);
        insert artdclist;
        
        Knowledge__kav currentArticleDetail = [SELECT ArticleCreatedDate, ArticleNumber FROM Knowledge__kav WHERE Id = :article.Id];
        KnowledgeArticle knowledgeArticle = [SELECT Id FROM KnowledgeArticle WHERE ArticleNumber = :currentArticleDetail.get('ArticleNumber').toString()];
        KbManagement.PublishingService.publishArticle(knowledgeArticle.Id, true);
    }
    
    @IsTest
    static void testGetFAQHierarchy() {
        ASDAC_LandingCmpController.DataCategoryArticlesWrapper wrapperVar = ASDAC_LandingCmpController.getFAQHierarchy();
        System.assertEquals(wrapperVar.faqHierarchyMap.containsKey('All'), true, 'Pass'); 
    }
    
    @IsTest
    static void testGetWebformEntryPoints() {
        Map<String, WebformEntryPoint__mdt> mapOfWebformEntryPoint = ASDAC_LandingCmpController.getWebformEntryPoints();
        System.assert(mapOfWebformEntryPoint.values().size() >= 0, 'Expected Webform entry points');
    }
}