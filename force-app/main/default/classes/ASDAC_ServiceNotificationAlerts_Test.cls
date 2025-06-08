/******************************************************************************
Name: ASDAC_ServiceNotificationAlerts_Test
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
* Description : This Test class is used to cover ASDAC_ServiceNotificationAlerts Apex class
*/
@isTest
public with sharing class ASDAC_ServiceNotificationAlerts_Test {
    /**
* Description : This Test method is used for creating user, public groups and ServiceNotification__c test records. 
*/
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> userRecords = new List<User>();
        User user1 = new User(Alias = 'shiva', Email='saishivaa@asdatest.co.uk', LastName='shiva',  
                              ProfileId = p.Id, UserName='saishivaa@asdatest.co.uk' ,EmailEncodingKey='UTF-8', 
                              LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
        User user2 = new User(Alias = 'shiva', Email='saishivaa@asdatest.co.uk', LastName='shivaa', ProfileId = p.Id,
                              UserName='saishiva@asdatest.co.uk' ,EmailEncodingKey='UTF-8', 
                              LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Vancouver');
        userRecords.add(user1);
        userRecords.add(user2);
        insert userRecords;
        List<Group> groupRecords = new List<Group>();
        Group group1 = new Group(Name='GroupOne', DeveloperName='GroupOne');
        Group group2 = new Group(Name='GroupTwo', DeveloperName='GroupTwo');
        groupRecords.add(group1);
        groupRecords.add(group2);
        insert groupRecords;
        ServiceNotification__c serviceRecord = new ServiceNotification__c(Name='service');
        insert serviceRecord;
        
    }
    /**
* Description : This Test method is used to Calling ASDAC_ServiceNotificationAlerts methods
*/
      @istest 
        public static  void fetchUserGroupRecordsnullvalue(){
        try{
            test.startTest();
            ASDAC_ServiceNotificationAlerts.fetchRecords('Group', 'Name', 'Test', null);
            test.stopTest();
            
            
        }catch(Exception e){
            system.debug('Error in fetchUserGroupRecordsnullvalue > '+e.getMessage());
        }
    }

    @IsTest
    static void getListOfRecipientsTest1() {
        UserRole notificationRole = new UserRole(Name = 'OCS CRM Administrator');
        insert notificationRole;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testuser', Email = 'testuserr_cc@asdatest.co.uk', LastName = 'Test',
                             ProfileId = p.Id, UserName = 'testuserr_cc@asdatest.co.uk', EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Phoenix',
                             UserRoleId = notificationRole.Id);
        
        insert user;

        ASDAC_ServiceNotificationAlerts.getListOfRecipients(new List<String>{ user.Id });

    }     
     /**
* Description : This Test method is used for fatch the group records. 
*/
         @istest 
        public static  void fetchUserGroupRecordsnull(){
        try{
            List<ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper> listDetailWrapper = new List<ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper>();
            ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper detailWrapper = new ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper();
            detailWrapper.message = 'message';
            detailWrapper.notificationType = 'Alert';
            listDetailWrapper.add(detailWrapper);
      
            test.startTest();
            ASDAC_ServiceNotificationAlerts.fetchRecords('account', 'Name', 'Test', '1');
            test.stopTest();
            
            
        }catch(Exception e){
            system.debug('error in fetchUserGroupRecordsnull > '+e.getMessage());        
        }
    }
     /**
* Description : This Test method is used for Group data test records. 
*/
    @istest static  void fetchUserGroupRecords(){
        try{
            test.startTest(); 
            ASDAC_ServiceNotificationAlerts.fetchRecords('Group', 'Name', 'Test', '1');
            test.stopTest();
        }catch(Exception e){
            system.debug('error in fetchUserGroupRecords > '+e.getMessage());        
        }
    }
   
     /**
* Description : This Test method is used for creating user, a pass the recipient records. 
*/
    @istest 
    public static  void saveRecipientRecordTest(){
        Map<Id,User> users =new Map<Id, User>( [Select id , Name from User where IsActive = true WITH SECURITY_ENFORCED ]);
        ServiceNotification__c service = [SELECT Id, Name FROM ServiceNotification__c  WITH SECURITY_ENFORCED LIMIT 1];
        List<String> listOfRecipientIds = new List<String>();
        for(Id ids : users.keyset()){
            listOfRecipientIds.add(ids);
        }
        string alluser = 'All User';
               
        ASDAC_ServiceNotificationAlerts.saveRecipientRecord(service.id, 'Test', alluser);
    }
      /**
* Description : This Test method is used for creating user, public groups and ServiceNotification__c test records. 
*/
    @istest 
    public static  void getListOfRecipientsTest(){
        Map<Id,User> users =new Map<Id, User>( [Select id , Name from User where IsActive = true WITH SECURITY_ENFORCED ]);
        List<String> listOfRecipientIds = new List<String>();
        for(Id ids : users.keyset()){
            listOfRecipientIds.add(ids);
        }
        list<Group> listOfAllUserGrp=[SELECT Id, Name FROM Group WHERE DeveloperName = 'AllCustomerServiceUsers' WITH SECURITY_ENFORCED LIMIT 1];
        LIst<string>listOfAllUserGrpstring = new  LIst<string>();
        for(Group gr : listOfAllUserGrp){
            listOfAllUserGrpstring.add(gr.id);
            
        }
        ASDAC_ServiceNotificationAlerts.getListOfRecipients(listOfAllUserGrpstring);	
    }
     /**
* Description : This Test method is used for pass the recipient and empty value test records. 
*/
    @istest 
    public static  void getListOfRecipientsTestempty(){
        
        list<Group> listOfAllUserGrp=[SELECT Id, Name FROM Group WHERE DeveloperName = 'AllCustomerServiceUsers' WITH SECURITY_ENFORCED LIMIT 0];
        LIst<string>listOfAllUserGrpstring = new  LIst<string>();
        for(Group gr : listOfAllUserGrp){
            listOfAllUserGrpstring.add(gr.id);
            
        }
        
        ASDAC_ServiceNotificationAlerts.getListOfRecipients(listOfAllUserGrpstring);	
    }
     /**
* Description : This Test method is used for pass the recipient and empty value and null value test records. 
*/
     @istest 
    public static  void getListOfRecipientsTestnull(){
    
        ASDAC_ServiceNotificationAlerts.getListOfRecipients(null);	
    }
    
    @istest static  void publishEventsTest(){
        Map<Id,User> users =new Map<Id, User>( [Select id , Name from User where IsActive = true WITH SECURITY_ENFORCED ]);
        List<String> listOfRecipientIds = new List<String>();
        for(Id ids : users.keyset()){
            listOfRecipientIds.add(ids);
        }
        List<ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper> listDetailWrapper = new List<ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper>();
        ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper detailWrapper = new ASDAC_ServiceNotificationAlerts.AlertDetailsWrapper();
        detailWrapper.message = 'message';
        detailWrapper.notificationType = 'Alert';
        detailWrapper.listOfRecipientIds = listOfRecipientIds;
        listDetailWrapper.add(detailWrapper);
        test.startTest();
        ASDAC_ServiceNotificationAlerts.publishEvents(listDetailWrapper);
            

        test.stopTest();
    }
     @istest static  void getAllUserGroupId(){
        try{
            test.startTest();
            List<Group> listOfAllUserGrp = [SELECT Id, Name FROM Group where DeveloperName = 'ASDAC_AllCustomerServiceUsers'];
            delete listOfAllUserGrp;
           ASDAC_ServiceNotificationAlerts.getAllUserGroupId();      
            test.stopTest();
        }catch(Exception e){
            system.debug('error in getAllUserGroupId > '+e.getMessage());        
        }
    }
      @istest static  void getAllUserGroupId1(){
        try{
            test.startTest();
           ASDAC_ServiceNotificationAlerts.getAllUserGroupId();      
            test.stopTest();
        }catch(Exception e){
            system.debug('error in getAllUserGroupId > '+e.getMessage());        
        }
    }
     @isTest
    static void testRecordsDataConstructor() {
        String expectedLabel = 'Test Label';
        String expectedValue = 'Test Value';
        ASDAC_ServiceNotificationAlerts.RecordsData rd = new ASDAC_ServiceNotificationAlerts.RecordsData(expectedLabel, expectedValue);

        System.assertEquals(expectedLabel, rd.label);
        System.assertEquals(expectedValue, rd.value);
    }
}