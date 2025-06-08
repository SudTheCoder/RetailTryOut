({
	// Sets an empApi error handler on component initialization
    onInit : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('empApi');

        // Uncomment below line to enable debug logging (optional)

        // Register error listener and pass in the error handler function
        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            console.error('EMP API error: ', JSON.stringify(error));
        }));
        // Get the channel from the input box
        const channel = component.find('channel').get('v.value');
        // Replay option to get new events
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(response => {
            // Process event (this is called each time we receive an event)
            // Response contains the payload of the new message received
            let notificationDetails = JSON.parse(response.data.payload.Data__c)[0];
        	helper.showNotificationHelper(component, notificationDetails);
        }))
        .then(subscription => {
            // Subscription response received.
            // We haven't received an event yet.
            // Save subscription to unsubscribe later
        });
    },
            closeQA : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})