/**********************************************************************************
 * @author                       : Disharee Ray
 * @date                         : 2022-10-12
 * @description                  : ASDAC-4050 HC Header -> Burger Menu (Based on Asda site)
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * Disharee Ray                12-Oct-2022    Created the class
 * Disharee Ray                28-October-2022  Updated the class for ASDAC-3502
 ***************************************************************************************************/
global with sharing class ASDAC_NavigationMenuItemsController {
    private STATIC FINAL String   LANGUAGE = 'en_US';
    private STATIC FINAL Integer  NUMBER_OF_PAGE = 0;
    private STATIC FINAL Integer  PAGE_SIZE = 250;
    @testVisible
    private static ConnectApi.ManagedContentVersionCollection mockedContentCollection;
    @testVisible
    private static ConnectApi.NavigationMenuItemCollection mockedNavMenusList;
    @testVisible
    private static ConnectApi.ManagedContentChannelCollection mockedContentChannelCollection;  
    
    public ASDAC_NavigationMenuItemsController() {
    }
   /**
   * ****************************************************************************************************
   * @description method to get a list of wrapper which consists NavigationMenuItem & ManagedContentVersions
   * @return String
   * ****************************************************************************************************
   */
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItemsWrapper> getNavigationMenuItems(String menuName,String channelName,Integer maxPageSize,String contentType){
        NavigationMenuItemsWrapper wrapper = new NavigationMenuItemsWrapper();
        List<NavigationMenuItemsWrapper> wrapperList = new List<NavigationMenuItemsWrapper>();
        if (String.isEmpty(menuName)) {
            return new List<NavigationMenuItemsWrapper>();
        }
        try {
        String networkId;
        if (Test.isRunningTest()) {
          networkId= [SELECT NetworkId FROM NetworkMember
                      WHERE MemberId = :UserInfo.getUserId()
                      ORDER BY Id DESC LIMIT 1].NetworkId;      
        }else{
          networkId = Network.getNetworkId();
        }
        // find the link set belonging to the navigation menuName and active networkId
        List<NavigationLinkSet> linkSets = [
            SELECT Id,DeveloperName
            FROM NavigationLinkSet
            WHERE DeveloperName = :menuName AND NetworkId = :networkId
        ];

        String linkSetId = linkSets.get(0).Id;
        String navigationLinkSetDeveloperName=null;
        List<ConnectApi.NavigationMenuItemType> menuItemsToSkip = new List<ConnectApi.NavigationMenuItemType>{
            ConnectApi.NavigationMenuItemType.Event, // not supported in custom component nav menus
            ConnectApi.NavigationMenuItemType.SystemLink // not supported in nav menus
        };
        ConnectApi.PublishStatus publishStatusEnum = ConnectApi.PublishStatus.Live;
        ConnectApi.NavigationMenuItemCollection menu;
        if (Test.isRunningTest()) {
         menu = mockedNavMenusList;
        } else {
         menu = ConnectApi.NavigationMenu.getCommunityNavigationMenu(networkId,linkSetId, navigationLinkSetDeveloperName,
                                                                     publishStatusEnum,true, false,menuItemsToSkip); 
        }
        List<ConnectApi.NavigationMenuItem> items = menu.menuItems;
        if(contentType=='cms_image'){
          List<ConnectApi.ManagedContentVersion> cmsMediaContents=retrieveMediaFromCMS(channelName,maxPageSize,contentType); 
          wrapper.mediaContents=cmsMediaContents;
         }
        wrapper.navigationalMenuItems=items;
        wrapperList.add(wrapper);
        return wrapperList;
      }catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
      }
    }
   /**
   * ****************************************************************************************************
   * @description method to get a list of ManagedContentVersion which consists all the CMS images
   * @return List<ConnectApi.ManagedContentVersion>
   * ****************************************************************************************************
   */
    @AuraEnabled (cacheable=true)
    public static List<ConnectApi.ManagedContentVersion> retrieveMediaFromCMS(String channelName,Integer maxPageSize,String contentType){
       String channelId = getChannelId(channelName);
       ConnectApi.ManagedContentVersionCollection contentCollection;
       if (Test.isRunningTest()) {
        contentCollection = mockedContentCollection;
       } else {
        contentCollection = ConnectApi.ManagedContent.getAllContent(channelId, NUMBER_OF_PAGE, maxPageSize,LANGUAGE , 
                                                                    contentType,false,null,null,true);
       }
       List<ConnectApi.ManagedContentVersion> mediaItems= contentCollection.items;
       return mediaItems;
    }
   /**
   * ****************************************************************************************************
   * @description method to get the channel Id
   * parameter String
   * @return String
   * ****************************************************************************************************
   */
    @AuraEnabled (cacheable=true)
    public static String getChannelId(String channelName){
        ConnectApi.ManagedContentChannelCollection channelRepObj;
        if (Test.isRunningTest()) {
          channelRepObj = mockedContentChannelCollection;
        } else {
          channelRepObj = ConnectApi.ManagedContent.getAllDeliveryChannels(NUMBER_OF_PAGE,PAGE_SIZE);   
        }       
        for(ConnectApi.ManagedContentChannel channelObj: channelRepObj.channels){
            if(channelObj.channelName == channelName){
                return channelObj.channelId;
            }
        }
        return null;
    }
    //NavigationMenuItemsWrapper class to bind NavigationMenuItem & ManagedContentVersion
    public class NavigationMenuItemsWrapper{
     @AuraEnabled
     public List<ConnectApi.NavigationMenuItem> navigationalMenuItems {get;set;}
     @AuraEnabled
     public List<ConnectApi.ManagedContentVersion> mediaContents {get;set;}
    }
}