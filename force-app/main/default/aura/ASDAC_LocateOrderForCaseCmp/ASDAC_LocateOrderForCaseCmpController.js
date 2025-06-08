({
    openOrderTab : function(component, event, helper) {
        let accId = event.getParam('c__recordId');
        let caseId = event.getParam('c__caseId');
        let orderId = event.getParam('uid');
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openTab({
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__ASDAC_DisplayOrdersCmp"
                    },
                    "state": {
                        "c__recordId": accId,
                        "c__caseId": caseId,
                        "uid": orderId
                    }
                }
            }).then(function(subtabId) {
                workspaceAPI.setTabLabel({
                    tabId : subtabId,
                    label: orderId
                });
                workspaceAPI.setTabIcon({
                    tabId : subtabId,
                    icon : 'standard:orders',
                    iconAlt : orderId
                });
            }).catch(function(error) {
            });
        });
        
    },

    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})