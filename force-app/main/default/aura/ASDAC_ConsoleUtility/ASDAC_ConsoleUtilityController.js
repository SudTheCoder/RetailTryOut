({
	handleMessage: function(component, event, helper){
        let data = event.getParam('data');
        if(component.get('v.recordId') && component.get('v.recordId') === data.recordId) {
			if(data.message === 'refresh') {
                let workspaceAPI = component.find("myworkspace");
                workspaceAPI.getEnclosingTabId().then(function(tabId){
                    workspaceAPI.refreshTab({
                        tabId: tabId,
                        includeAllSubtabs: true
                    });
                });
            }            
        }
    },
})