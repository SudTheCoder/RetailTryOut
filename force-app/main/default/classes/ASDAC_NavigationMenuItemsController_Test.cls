/**********************************************************************************
 * @author                       : Disharee Ray
 * @date                         : 2022-10-12
 * @description                  : ASDAC-4050 HC Header -> Burger Menu (Based on Asda site)
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 * Disharee Ray                  12-October-2022  Created the Class
 * Disharee Ray                  28-October-2022  Updated the class for ASDAC-3502
 ***************************************************************************************************/
@IsTest
public class ASDAC_NavigationMenuItemsController_Test {
  private STATIC FINAL String  CHANNEL_NAME = 'Help';
  private STATIC FINAL String  CHANNEL_ID = '123X34';
  private STATIC FINAL String  LANGUAGE = 'en_US';
  private STATIC FINAL String  PUBLISHED_STATE = 'Live';
  private STATIC FINAL String  MENU_NAME = 'ASDAC_Navigational_Menu';
  private STATIC FINAL Integer PAGE_SIZE = 250;
  private STATIC FINAL Integer NUMBER_OF_PAGE = 0;
  private STATIC FINAL String  CUSTOMER_PROFILE = 'Help Centre Customer';
  private STATIC FINAL String  ADMIN_PROFILE = 'System Administrator';
  private STATIC FINAL String  GUEST_PROFILE = 'Help Profile';
  private STATIC FINAL String  CONTENT_KEY = '1234';
  private STATIC FINAL String  CMS_TYPE = 'cms_image';
  private STATIC FINAL String  TITLE = 'ASDA_test';
  private STATIC FINAL String  ACTIONVALUE = 'https://test.asda.com/';
  private STATIC FINAL String  MENU_LABEL = 'ASDA Test Menu';
   
 /*getNavigationMenuItems_test is used to setup all ConnectApi data & retreive the NavigationMenuItemsWrapper from apex class*/
  @IsTest
  static void getNavigationMenuItems_test() {

    UserRole adminRole = new UserRole(Name = 'Admin');
    insert adminRole;
    Profile adminProfile = ASDAC_TestDataUtility.getProfile(ADMIN_PROFILE);
    User adminUser = ASDAC_TestDataUtility.getUser('admin.customer@asdatest.co.uk', adminProfile.Id);
    adminUser.UserRoleId = adminRole.Id;
    insert adminUser;

    String customerEmail = 'sample.customer@asdatest.co.uk';
    System.runAs(adminUser) {
      Account customer = new Account(FirstName = 'Sample', LastName = 'Customer', LoginId__c = customerEmail, PersonEmail = customerEmail);
      insert customer;
      customer = [SELECT PersonContactId FROM Account WHERE Id = :customer.Id];

      Profile customerProfile = ASDAC_TestDataUtility.getProfile(CUSTOMER_PROFILE);
      User customerUser = ASDAC_TestDataUtility.getUser(customerEmail, customerProfile.Id);
      customerUser.ContactId = customer.PersonContactId;
      customerUser.FederationIdentifier = 'FID-customer-user';
      insert customerUser;
    }
   User customerUser = [SELECT Id FROM User WHERE Username = :customerEmail];
   ConnectApi.ManagedContentVersionCollection managedContentVerColl = new ConnectApi.ManagedContentVersionCollection();
   managedContentVerColl.items = new List<ConnectApi.ManagedContentVersion>();
   ConnectApi.ManagedContentVersion managedContentVersion = new ConnectApi.ManagedContentVersion();
   managedContentVersion.contentKey=CONTENT_KEY;
   managedContentVersion.type=CMS_TYPE;
   managedContentVersion.title=TITLE;
   managedContentVerColl.items.add(managedContentVersion);
   ASDAC_NavigationMenuItemsController.mockedContentCollection = managedContentVerColl;
      
   ConnectApi.NavigationMenuItemCollection managedNavMenusList =new ConnectApi.NavigationMenuItemCollection();
   managedNavMenusList.menuItems = new List<ConnectApi.NavigationMenuItem>();
   ConnectApi.NavigationMenuItem menuItem = new ConnectApi.NavigationMenuItem();
   menuItem.actionValue=ACTIONVALUE;
   menuItem.label=MENU_LABEL;
   managedNavMenusList.menuItems.add(menuItem);
   ASDAC_NavigationMenuItemsController.mockedNavMenusList = managedNavMenusList;
       
   ConnectApi.ManagedContentChannelCollection managedContentChannelColl = new ConnectApi.ManagedContentChannelCollection();
   managedContentChannelColl.channels = new List<ConnectApi.ManagedContentChannel>();
   ConnectApi.ManagedContentChannel managedContentChannel = new ConnectApi.ManagedContentChannel();
   managedContentChannel.channelName=CHANNEL_NAME;
   managedContentChannel.channelId=CHANNEL_ID;
   managedContentChannelColl.channels.add(managedContentChannel);
   ASDAC_NavigationMenuItemsController.mockedContentChannelCollection = managedContentChannelColl;
   /*getNavigationMenuItems method is called & NavigationMenuItemsWrapper will be retuned*/
   Test.startTest();
    System.runAs(customerUser) {
    List<ASDAC_NavigationMenuItemsController.NavigationMenuItemsWrapper> navigationMenuWrapper= ASDAC_NavigationMenuItemsController.getNavigationMenuItems(MENU_NAME,CHANNEL_NAME,PAGE_SIZE,CMS_TYPE);
    for(ASDAC_NavigationMenuItemsController.NavigationMenuItemsWrapper wrapper:navigationMenuWrapper){
     System.assertEquals(TITLE, wrapper.mediaContents[0].title);
     System.assertEquals(CONTENT_KEY, wrapper.mediaContents[0].contentKey);
     System.assertEquals(ACTIONVALUE, wrapper.navigationalMenuItems[0].actionValue);
     System.assertEquals(MENU_LABEL, wrapper.navigationalMenuItems[0].label);
    }
    String nonExistentChannelName = 'Nonexistent Channel';
    String channelId = ASDAC_NavigationMenuItemsController.getChannelId(nonExistentChannelName);
    System.assertEquals(null, channelId);
   }
   Test.stopTest();
  }
  /*Test the Excetion handling block*/
  @isTest
  static void getNavigationMenuItemsException_test() {
    Boolean isExceptionOccured = false;
    try {
      ASDAC_NavigationMenuItemsController.getNavigationMenuItems(MENU_NAME,CHANNEL_NAME,PAGE_SIZE,CMS_TYPE);
    } catch (Exception ex) {
      isExceptionOccured = true;
    }
    System.assertEquals(true, isExceptionOccured, 'Exception occured');
  }
  
  /*Test scenarion when empty navigational menu name is passed*/
  @IsTest
  static void emptyMenuName_test() {
    String menuName='';  
    List<ASDAC_NavigationMenuItemsController.NavigationMenuItemsWrapper> navigationMenuWrapper= ASDAC_NavigationMenuItemsController.getNavigationMenuItems(menuName,CHANNEL_NAME,PAGE_SIZE,CMS_TYPE);
    System.assertEquals(true, navigationMenuWrapper.isEmpty());
  }
}