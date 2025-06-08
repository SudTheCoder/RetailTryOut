({
	showNotificationHelper : function(component, notificationDetails) {
		let action = component.get('c.getListOfRecipients');
        action.setParams({listOfRecipientIds : notificationDetails.listOfRecipientIds});
		action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
				let respWrap = response.getReturnValue();
				if(respWrap.showNotification) {
					let toastType = {
						'Critical' : 'error',
						'High'	: 'warning',
						'Medium' : 'info',
						'Low' : 'success'
					};
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": notificationDetails.notificationType,
                        "message": notificationDetails.message,
                        "mode" : "sticky",
                        "type" : toastType[notificationDetails.notificationType]
                    });
                    toastEvent.fire();     
				}
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})