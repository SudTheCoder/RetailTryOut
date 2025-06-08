/**********************************************************************************
* @author                       : Amey Priolkar
* @date                         : 2022-09-19
* @description                  : ASDAC-3485  Hot Topics
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Amey Priolkar                 19-Sep-2022     Created the class
***************************************************************************************************/
public with sharing class ASDAC_HotTopicController {
    
    /**********************************************************************************
    * @author                       : Amey Priolkar
    * @date                         : 2022-09-19
    * @description                  : wrapper class for filter
    **********************************************************************************/
    public class ResponseWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public List<HotTopic__c> hotTopicList;
        
        public ResponseWrapper(Boolean isSuccess, String message, List<HotTopic__c> hotTopicList) {
            this.isSuccess = isSuccess;
            this.message = message;
            this.hotTopicList = hotTopicList;
        }
    }
    
    /**
    * ****************************************************************************************************
    * @param NA
    * @description Fetch all the active Hot Topics
    * ****************************************************************************************************
    */
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getActiveHotTopics() {
        Map<Integer, List<HotTopic__c>> mapOfCseCntToHTList = new Map<Integer, List<HotTopic__c>>();
        List<Integer> listOfCaseCount = new List<Integer>();
        List<HotTopic__c> listOfHotTopics = new List<HotTopic__c>();
        for(HotTopic__c hotTopic : [SELECT Id, HotTopicId__c, Name, LastModifiedDate, 
                                    (SELECT Id FROM Cases__r) 
                                    FROM HotTopic__c 
                                    WHERE StartDate__c <= TODAY AND ExpiryDate__c >= TODAY
                                    WITH SECURITY_ENFORCED LIMIT 30]) {
			Integer caseCount = hotTopic.Cases__r.size();
			if(!mapOfCseCntToHTList.containsKey(caseCount)) {
				mapOfCseCntToHTList.put(caseCount, new List<HotTopic__c>());
				listOfCaseCount.add(caseCount);                
            }
			mapOfCseCntToHTList.get(caseCount).add(hotTopic);
        }
        if(!listOfCaseCount.isEmpty()) {
			listOfCaseCount.sort();
            for(Integer i = listOfCaseCount.size()-1; i>=0; i--) {
                listOfHotTopics.addAll(mapOfCseCntToHTList.get(listOfCaseCount[i]));
            }            
        }

        if(!listOfHotTopics.isEmpty()){
            return new ResponseWrapper(true, '', listOfHotTopics);
        }
       	return new ResponseWrapper(false, 'No Hot Topic is Trending.', new list<HotTopic__c>());
    }
}