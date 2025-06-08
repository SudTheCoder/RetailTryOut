/**
* @author -         Dependra Singh- Publicis Sapient
* @date -           13 May 2022
* @description -    A Utility class for Describe/Schema, Recordtypes functions 
* Modified by     Version     Change Date
**/
public with sharing class ASDAC_CommonUtility{
    
    // Field Label >> Field API Name
    public static Map<String, String> mapFieldLabelandAPIName = new Map<String, String>();
    // Field API Name >> Field Label
    public static Map<String, String> mapFieldAPINameandLabel = new Map<String, String>();
    
    //Record Type Variables 
    private static Map<String, Map<String,Schema.RecordTypeInfo>>   mapRecordTypeByName = new Map<String, Map<String,Schema.RecordTypeInfo>>();
    private static Map<String, Map<Id, Schema.RecordTypeInfo>>      mapRecordTypeById   = new Map<String, Map<Id, Schema.RecordTypeInfo>>();

    

    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         13 May 2022
    Version -      1.0 
    Function -     Get Object API Name (e.g. Lead, Account, OpportunityLineItem etc.)
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static void getAllSObjects(){
        Schema.getGlobalDescribe();  
    }

    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         13 May 2022
    Version -      1.0 
    Function -     Get Object API Name (e.g. Lead, Account, OpportunityLineItem etc.)
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static String getSObjectAPIName(String pObjectType){
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{pObjectType});
        String objectAPIName = describeSobjectsResult[0].getName();
        return objectAPIName;
    }

    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         13 May 2022
    Version -      1.0 
    Function -     Get all fields of a specific object (e.g. Lead, Account etc.)
    Modified by     Version     Change Date
	Need to add return type 
    ****************************************************************************************/
    public static void getSObjectAllFields(Schema.SObjectType sObjType){
        // Get All related fields of a specific SObject Type (e.g. Lead, Account etc.)
        Map<String, Schema.SObjectField> mapFields = sObjType.getDescribe().fields.getMap();
        // Process All fields and populate a map with Field Label >> Field API Name
        for(String fieldAPIName : mapFields.keySet()){
            mapFieldLabelandAPIName.put( mapFields.get(fieldAPIName).getDescribe().getLabel(), String.ValueOf( mapFields.get(fieldAPIName) ) );
            mapFieldAPINameandLabel.put( String.ValueOf( mapFields.get(fieldAPIName) ), mapFields.get(fieldAPIName).getDescribe().getLabel() );
        }
    }

    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         13 May 2022
    Version -      1.0 
    Function -     Get Field API Name (e.g. Status etc.)
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static String getFieldAPIName(Schema.SObjectType sObjType, String pFieldLabel){
        // contains Field API Name
        String fieldAPIName = '';
        // Get all fields of a specific object (e.g. Lead, Account etc.)
        getSObjectAllFields(sObjType);
        // Verify the Field Label is present or not
        if( mapFieldLabelandAPIName.containsKey(pFieldLabel) ){
            fieldAPIName = mapFieldLabelandAPIName.get(pFieldLabel);
        }
        return fieldAPIName;
    }
        
    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         13 May 2022
    Version -      1.0 
    Function -     Get Field Label (e.g. Status etc.)
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static String getFieldLabel(Schema.SObjectType sObjType, String pFieldAPIName){
        // contains Field API Name
        String fieldLabel = '';
        // Get all fields of a specific object (e.g. Lead, Account etc.)
        getSObjectAllFields(sObjType);
        // Verify the Field Label is present or not
        if( mapFieldAPINameandLabel.containsKey(pFieldAPIName) ){
            fieldLabel = mapFieldAPINameandLabel.get(pFieldAPIName);
        }
        return fieldLabel;
    }
        
    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         13 May 2022
    Version -      1.0 
    Function -     Get list of Feild Set members (Field API Name, Field Label, Field Type, Field Required, Field DB Required)
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static List<Schema.FieldSetMember> getFieldSetMemebers(Schema.SObjectType sObjType, String fieldSetAPIName){        
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjType.getDescribe();                
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetAPIName);        
        return fieldSetObj.getFields(); 
    }

    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         13 May 2022
    Version -      1.0 
    Function -     Get Picklist values of a specific Field of an Object
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static Map<String, String> getFieldPicklistValues(Schema.SObjectType sObjType, String pFieldAPIName){
        // Contains Field Label and Field API Name
        // Picklist Label >> Picklist Value
        Map<String, String> mapPicklistValues = new Map<String, String>();
        
        // Get the specific SObject Type (e.g. Lead, Account etc.)
        //SObjectType objectType = Schema.getGlobalDescribe().get(pObjectType);
        // Get All related fields of a specific SObject Type (e.g. Lead, Account etc.)
        Map<String, Schema.SObjectField> mapFields = sObjType.getDescribe().fields.getMap();
        // Get the Picklist Values for a specific 
        list<Schema.PicklistEntry> lstPicklistValues = mapFields.get(pFieldAPIName).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for(Schema.PicklistEntry picklist : lstPicklistValues){ 
            mapPicklistValues.put(picklist.getLabel(), picklist.getValue());
        }
        return mapPicklistValues;
    }
    
   /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0
    Function -     Get all picklist value by passing the object and field name
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/
	public static List<Schema.PicklistEntry> getPicklistEntries(String objectName, String fieldName) {
		Schema.DescribeSObjectResult objectDescribe = getSObjectType(objectName).getDescribe();
		return objectDescribe.Fields.getMap().get(fieldName).getDescribe().getPicklistValues();
	}
    
    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0 
    Function -     Load/Populate Maps with Record Type Id or Record Type Name for specific object
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/    
    private static void initialize(Schema.SObjectType sObjType, String sObjectAsString) {
        if (!mapRecordTypeByName.containsKey(sObjectAsString) || !mapRecordTypeById.containsKey(sObjectAsString)) {
            Schema.DescribeSObjectResult d = sObjType.getDescribe();
            //SonarQube suggestion : Use getRecordTypeInfosByDeveloperName instead of getRecordTypeInfosByName : Amey -- STARTS
            Map<String,Schema.RecordTypeInfo> rtMapByStdDevName = d.getRecordTypeInfosByDeveloperName();
            Map<String,Schema.RecordTypeInfo> rtByDevNameMap = new map<String,Schema.RecordTypeInfo>();
            for(Schema.RecordTypeInfo rcInf : rtMapByStdDevName.values()){
                rtByDevNameMap.put(rcInf.getName(), rcInf);
            }
            mapRecordTypeByName.put(sObjectAsString, rtByDevNameMap);
            //SonarQube suggestion : Use getRecordTypeInfosByDeveloperName instead of getRecordTypeInfosByName : Amey -- ENDS
            mapRecordTypeById.put(sObjectAsString, d.getRecordTypeInfosById());
        }
    }

    /*************************************************************************************** 
    Developer -    Dependra SIngh
    Date -         14 May 2022
    Version -      1.0 
    Function -     Get Record Type Id
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/    
    public static ID getRecordTypeId(Schema.SObjectType sObjType, String sRecordTypeName, String sObjectAsString){
        initialize(sObjType, SObjectAsString);
        if (mapRecordTypeByName.get(sObjectAsString).containsKey(sRecordTypeName)) {
            Schema.RecordTypeInfo rtInfo = mapRecordTypeByName.get(sObjectAsString).get(sRecordTypeName);
            return rtInfo.getRecordTypeId();
        }
        return null;
    }
    
    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0 
    Function -     Get Record Type Name
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/    
    public static String getRecordTypeName(Schema.SObjectType sObjType, Id recordTypeId, String sObjectAsString) {
        initialize(sObjType, sObjectAsString);
        if (mapRecordTypeById.get(sObjectAsString).containsKey(recordTypeId)) {
            Schema.RecordTypeInfo rtInfo =  mapRecordTypeById.get(sObjectAsString).get(recordTypeId);
            return rtInfo.getName();
        }
        
        return null;
    }
   /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0
    Function -     Get All the Record Types of a specific SObject Type
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static Schema.SObjectType getSObjectType(String objectName) {
		return Schema.getGlobalDescribe().get(objectName);
	}
   /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0
    Function -     Get All the Record Types of a specific SObject Type
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/
	public static Schema.SObjectType getSObjectType(Id recordId) {
		return recordId.getSobjectType();
	}
    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0
    Function -     Get All the Record Types of a specific SObject Type
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/
	public static Id getRecordTypeId(String objectName, String recordTypeDeveloperName) {
		Schema.SObjectType objectType = getSObjectType(objectName);
		return objectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
	}
    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0
    Function -     Get All the Record Types of a specific SObject Type
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/
	public static Map<String, Id> getRecordTypeIdsByObject(String objectName) {
		Map<String, Id> recordTypesByDeveloperName = new Map<String, Id>();
		for(Schema.RecordTypeInfo info : getSObjectType(objectName).getDescribe().getRecordTypeInfosByDeveloperName().values()) {
			recordTypesByDeveloperName.put(info.getName(), info.getRecordTypeId());
		}
		return recordTypesByDeveloperName;
	}

    /*************************************************************************************** 
    Developer -    Dependra Singh- Publicis Sapient
    Date -         14 May 2022
    Version -      1.0
    Function -     Generate the GUID 
    #############Change Log#############
    Modified by     Version     Change Date
    ****************************************************************************************/
	public static String generateGUID() {
		Blob aesKey = Crypto.generateAesKey(128);
		String hexKey = EncodingUtil.convertToHex(aesKey);
		List<String> segments = new List<String>();

		segments.add(hexKey.substring(0, 8));
		segments.add(hexKey.substring(8, 12));
		segments.add(hexKey.substring(12, 16));
		segments.add(hexKey.substring(20));
		return String.join(segments, '-');
	}
   /*************************************************************************************** 
    Developer -    Kishor- Publicis Sapient
    Date -         28 Oct 2022
    Version -      1.0
    Function -     Deleting all consent related to specific object. 
    Param   -      Map<Id,SObject> oldMap, String objName
    #############Change Log#############
    Modified by     Version     Change Date
   

    ****************************************************************************************/  
    public static void deleteConsents(Map<Id,SObject> oldMap, String objName){
        Set<Id> idSetOfParentIds = oldMap.keySet();
        String privacyConsentStatus;
        privacyConsentStatus = ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT;
        
        // Construct query based on tigger object 
        String query = 'SELECT Id, Account__c, ContactPointId '+
                       'FROM ContactPointConsent ';
        if(objName == ASDAC_GlobalConstants.OBJACCOUNT) {
             query += 'WHERE Account__c in :idSetOfParentIds '+
                      'WITH SECURITY_ENFORCED';
        } else {
             query += 'WHERE ContactPointId in :idSetOfParentIds '+
                'AND PrivacyConsentStatus =: privacyConsentStatus ' +
                'WITH SECURITY_ENFORCED';
        } 
      
        List<ContactPointConsent> lstConsents = Database.query(String.escapeSingleQuotes(query));
        System.debug('consent list inside common utility '+lstConsents);
        if(Schema.sObjectType.ContactPointConsent.isDeletable()) {
            Database.DeleteResult[] delResultList = Database.delete(lstConsents,false);
            logResults(delResultList,objName,lstConsents,oldMap);
        }   
    }
   /*************************************************************************************** 
    Developer -    Kishor- Publicis Sapient
    Date -         28 Oct 2022
    Version -      1.0
    Function -     This method is used to log all the errors if any error during deletion. 

    Param   -      Database.DeleteResult[] delResultList, String objName, List<ContactPointConsent> lstConsents, Map<Id,SObject> oldMap    
    #############Change Log#############
    Modified by     Version     Change Date
   

    ****************************************************************************************/  
    public static void logResults(Database.DeleteResult[] delResultList, String objName, List<ContactPointConsent> lstConsents, Map<Id,SObject> oldMap) {
        List<ErrorLog> errorLogs = new List<ErrorLog>();
        Map<Id,Id> consentToParentMap = new Map<Id,Id>();
        // map parent id with Contact point consent id.
        for(ContactPointConsent objCPC: lstConsents) {
                if(objName == ASDAC_GlobalConstants.OBJACCOUNT) {
                    consentToParentMap.put(objCPC.Id, objCPC.Account__c);
                } else {
                    consentToParentMap.put(objCPC.Id,objCPC.ContactPointId);
                }
        }
        // Log the error in the message and create the log object with required details
        for(Database.DeleteResult dr : delResultList) {
            if(dr.isSuccess() == false) {
                ErrorLog errorLog = new ErrorLog();
                for(Database.Error err : dr.getErrors()) {
                    errorLog.externalId = String.valueOf(oldmap.get(consentToParentMap.get(dr.id)).get('ExternalId__c'));
                    errorLog.message = ASDAC_GlobalConstants.DELETE_EXCEPTION + ' ' +
                                       objName + ' ' + 
                                       err.getMessage() + ' ' + 
                                       err.getFields();
                    errorLogs.add(errorLog);                   
                }
            }
        }
        // If error exist create the log record.
        if(errorLogs.size() > 0) {
            String exceptionMessage = ':'+errorLogs;
            ASDAC_Logger.logException(exceptionMessage);
            ASDAC_Logger.writeLogsToDatabase();
        }

    }

    /*************************************************************************************** 
    Developer -    Vineeth Rangamgari
    Date -         8 March 2023
    Version -      1.0 
    Function -     Get Static Resource as String
    Modified by     Version     Change Date
    ****************************************************************************************/
    public static String getStaticResource(String resourceName) {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = :resourceName WITH SECURITY_ENFORCED LIMIT 1];
        return sr.Body.toString();
    }

/**********************************************************************************************
    @author        Sapient: Kishor Chand
    @date          28 Oct 2022
    @param         ASDAC_TriggerHandlerObj
    @return        void
    @description   Wrapper class for logging errors
**********************************************************************************************/
     public class ErrorLog{
        public String externalId{get;set;}
        public String message{get;set;}
    }
}