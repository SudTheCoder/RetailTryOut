({
    doInit: function (component, event, helper) {
        //Added This logic to prevent calling this logic in certain condtions
        if (component.get("v.pageReference").state.c__isCalled === "layout") {
            let tablabel = component.get("v.pageReference").state.uid;
            let workspaceAPI = component.find("workspace");
            workspaceAPI.getEnclosingTabId().then((response) => {
                let opendTab = response.tabId;
                workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: tablabel
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'standard:orders',
                iconAlt: tablabel
            });
        }); 
    }
},
 
 handleEvent : function(component, event) {
    //Order Id sent from LWC Event
    let orderId = event.getParam('uid');
    //Check if Customer search is performed
    let isSearched = event.getParam('c__searched');
    //Initialize Workspace API instance
    let workspaceAPI = component.find("workspace");
    //Add details to Workspace API to open Order Sub tab 
    workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
        //Open Tab which has Component incorporated on it
        //Parameters sent to comp : order Id, Account Id, is Customer Searched flag
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__ASDAC_DisplayOrdersCmp"
                },
                "state": {
                    "uid": orderId,
                    "c__searched": isSearched
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
            //Errors
        });
    });
},


    closeTab : function(component, event){
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
});