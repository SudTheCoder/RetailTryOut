/******************************************************************************
Name: ASDAC_ServiceNotificationAlerts
===============================================================================
Req: 
ASDAC-2055 Service Incident Alerts
===============================================================================
Purpose:To Create a record in Notification Recepient object
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.1       Sai Shivakoti   		26 August 2022   Initial Development
******************************************************************************/
/**
 * Description : This class is udsed for fetching user and public groups records. 
 */
public  with sharing  class ASDAC_ServiceNotificationAlerts {
    public Static final Set<String> SET_NOTIFICATION_ROLES = new Set<String>{'OCS CRM Administrator',
        																	 'OCS Content Manager',
        																	 'OCS Team Leader UK',
                                                                             'OCS Team Leader BPO',
                                                                             'OCS Ops Manager UK',
                                                                             'OCS Senior Manager UK',
                                                                             'OCS Colleague Tier 2 UK',
        																	 'OCS Colleague Tier 1 UK',
                                                                             'OCS Colleague Tier 1 BPO',
                                                                             'OCS Colleague Tier 2 BPO',
        																	 'OCS Reporting Analyst'};
    /* @authour : Sai Shivakoti  
     * Method Description : This class is udsed for fetching user and public groups records. 
     * @return : List<sObject>
     */
    @AuraEnabled
    public static ResponseWrapper getAllUserGroupId(){
        ResponseWrapper resWrap;
        try {
            Id allUsersGrpId = [SELECT Id FROM Group WHERE DeveloperName = 'ASDAC_AllCustomerServiceUsers'][0].Id;
            resWrap = new ResponseWrapper(true, '', allUsersGrpId);		            
        }
        catch(Exception ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_ServiceNotificationAlerts');
            ASDAC_Logger.writeLogsToDatabase();
            resWrap = new ResponseWrapper(false, ex.getMessage(), '');		            
        } 
        return resWrap;
    }
    
    
	@AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ String.escapeSingleQuotes(value) + '\'';
            } else {
                searchString = searchString.trim() + '%';
                query += ' WHERE ' + filterField + ' LIKE : searchString';
            }
            if(objectName == 'Group') {
                String queueType;
                queueType= 'Queue';
				query += ' AND Type = : queueType';                
            }
            else {
                String automatedProcess;
                automatedProcess = 'Automated Process';
                query += ' AND Name != : automatedProcess';
            }
            query += ' LIMIT 49999';
	        for(SObject s : Database.query(String.escapeSingleQuotes(query))) {
	            recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
	        }
            return recordsDataList;
	    } catch (Exception err) {
	    	if(String.isNotBlank(err.getMessage()) && err.getMessage().contains( 'error:' ) ) {
				throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } 
            else {
                AuraHandledException e = new AuraHandledException(err.getMessage());
                e.setMessage(err.getMessage());
                throw e;
            }
	    }
    }
    
    
    @AuraEnabled 
    public static ResponseWrapper saveRecipientRecord(Id serviceNotifId, String stringifiedRecordData, String typeOfRecipient) {
        ResponseWrapper resWrap;
        Savepoint sp = Database.setSavepoint();
        try {
            reswrap = new ResponseWrapper(true, '', null);
        	RecordsData recordDataWrap = (RecordsData)JSON.deserialize(stringifiedRecordData, RecordsData.class);
            insert new NotificationRecipient__c(ServiceNotification__c = serviceNotifId, Name = recordDataWrap.label, RecipientId__c = recordDataWrap.value, Type__c = typeOfRecipient);            
        }
        catch(Exception ex) {
            Database.rollback(sp);
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_ServiceNotificationAlerts');
            ASDAC_Logger.writeLogsToDatabase();
            reswrap = new ResponseWrapper(false, ex.getMessage(), null);
        }
        return reswrap;
    }
    
    @AuraEnabled
    public static ResponseWrapper getListOfRecipients(List<String> listOfRecipientIds) {
        ResponseWrapper respWrap;
        try {
            respWrap = new ResponseWrapper(true, '', null);
			List<Group> listOfAllUserGrp = [SELECT Id, Name FROM Group WHERE Id IN : listOfRecipientIds AND DeveloperName = 'ASDAC_AllCustomerServiceUsers' LIMIT 1];
            User user = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
            if(!listOfAllUserGrp.isEmpty()) {
                if(SET_NOTIFICATION_ROLES.contains(user.UserRole.Name)) {
					respWrap.showNotification = true;					                    
                }
            }
            else {
                Set<String> setOfUserIds = getListOfRecipientsFromGroup(new Set<String>(listOfRecipientIds));
                if(setOfUserIds.contains(user.Id)) {
					respWrap.showNotification = true;					 
                }
            }            
        }
        catch(Exception ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_ServiceNotificationAlerts');
            ASDAC_Logger.writeLogsToDatabase();
			respWrap = new ResponseWrapper(false, ex.getMessage(), null);           
        }
        return respWrap;
    }
    
    public static Set<String> getListOfRecipientsFromGroup(Set<String> setOfUserIds) {
        for(GroupMember grpMember : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN : setOfUserIds]) {
            if(String.valueOf(grpMember.UserOrGroupId).startsWith('005')){
                setOfUserIds.add(grpMember.UserOrGroupId);                
            }
            else{
                for(GroupMember publicGrpMember : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = : grpMember.UserOrGroupId]) {
                    setOfUserIds.add(publicGrpMember.UserOrGroupId);                        
                }
            }
        }
        return setOfUserIds;
    }

     /* @authour : Sai Shivakoti  
     * Method Description : Creating ServiceNotification__c record.
     * @param : alertDetails
     */
    @InvocableMethod
    public static void publishEvents(List<AlertDetailsWrapper> alertDetails) {
		NotificationEvent__e genericPE = new NotificationEvent__e(Data__c = JSON.serialize(alertDetails));
        EventBus.publish(genericPE);
    }
    /* @authour : Sai Shivakoti  
     * Description : 
     * @param : alertDetails
     */
    public class AlertDetailsWrapper {
        @InvocableVariable
        public List<String> listOfRecipientIds;
        @InvocableVariable
        public String notificationType;
		@InvocableVariable
        public String message;
    }
    
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String allUserGrpId;
        @AuraEnabled
        public Boolean showNotification;
        
        public ResponseWrapper(Boolean isSuccess, String message, String allUserGrpId) {
			this.isSuccess = isSuccess;
            this.message = message;
            this.allUserGrpId = allUserGrpId;
        }
    }
}