({    
    invoke : function(component, event, helper) {
        // Get the record ID attribute
        let orderAction = component.get("v.actionName");  
  
        let contactName;
        let isCancelRequesttoStore = component.get("v.isCancelRequesttoStore");
        let totalAmt = component.get("v.totalRefundAmt").replace(/[^\d.]/g, '');
        let action = component.get("c.getPersonContactId");
        action.setParams({
            customerId: component.get("v.customerId")
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                contactName = response.getReturnValue();
                if(orderAction === "Refund"){
                   helper.showToastMsg(component,contactName);
                   helper.createCaseComment(component);
                }
                else if(orderAction === "Order Level Refund"){
                    let successmessage = helper.getMessageForOrderAction(orderAction, totalAmt, contactName);
                        helper.showWarningToast(successmessage);
                }
                else if(orderAction === "Cancel" && !isCancelRequesttoStore){
                    let cancelmessage = helper.getMessageForOrderAction(orderAction, totalAmt, contactName);
                    helper.showToast(cancelmessage);
                }
                else if(orderAction !== "Cancel"){
                    let successmessage = helper.getMessageForOrderAction(orderAction, totalAmt, contactName);  
                    helper.showToast(successmessage);
                    helper.createCaseComment(component);
                }
                
            }
            else if (state === "INCOMPLETE") {
                // do something
                 console.log("Unknown error 1");
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