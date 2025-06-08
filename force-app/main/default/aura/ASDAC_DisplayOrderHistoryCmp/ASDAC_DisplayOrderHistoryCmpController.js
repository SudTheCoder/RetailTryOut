({
    //Handle event of opening order in a subtab
    handleEvent : function(component, event) {
        //Order Id sent from LWC Event
        let orderId = event.getParam('orderId');
        //Account Record Id sent from LWC Event
        let businessArea = event.getParam('businessArea');
        //Initialize Workspace API instance
        let workspaceAPI = component.find("workspace");
        //Add details to Workspace API to open Order Sub tab 
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            //Open Sub tab which has Component incorporated on it
            //Parameters sent to comp : order Id, Account Id
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__ASDAC_DisplayOrdersCmp"
                    },
                    "state": {
                        "uid": orderId,
                        "c__businessArea": businessArea
                    }
                }
            }).then(function(subtabId) {
                //Set tab name as Order Id
                workspaceAPI.setTabLabel({
                    tabId : subtabId,
                    label: orderId
                });
                //Set tab icon
                workspaceAPI.setTabIcon({
                    tabId : subtabId,
                    icon : 'standard:orders',
                    iconAlt : orderId
                });
            }).catch(function(error) {
                //Error block
            });
        });
    }
})