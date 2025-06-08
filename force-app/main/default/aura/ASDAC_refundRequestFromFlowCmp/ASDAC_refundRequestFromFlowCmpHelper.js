({
    createCaseComment : function(component) {
        let action = component.get("c.createCaseComment");
        action.setParams({
            actionName: component.get("v.caseCommentAction"),
            caseID: component.get("v.caseId"),
            totalRefund: component.get("v.totalRefundAmt")
        });
        
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: in case comment" + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    showToastMsg: function(component,contactName){
        let tempString = JSON.parse(component.get("v.recordsToCreate"));
        let totalAmt = component.get("v.totalRefundAmt").replace(/[^\d.]/g, '');
        let requestType = 'Return';
        let allBlindReturn = true;
        let isGeorge = component.get("v.isGeorge");

        for(let key of tempString){
            if(key.actionType!== 'Blind Return'&& key.actionType !== 'Original'){
                allBlindReturn = false;
            }
        }
        if (allBlindReturn) {
            requestType = 'Blind Return';
        }
        if(isGeorge){
            if(requestType==="Return"){
                let standardrefundLabel = $A.get("$Label.c.ASDAC_StandardReturnSuccessMsg")
                this.showToast(standardrefundLabel);
            }
            else if(requestType==="Blind Return"){
                let refundLabel = $A.get("$Label.c.ASDAC_BlindReturnSuccessMsg")
                .replace("{0}", totalAmt)
                .replace("{1}", contactName);
                this.showToast(refundLabel);
            } 
        }
        else{
            let refundLabel = $A.get("$Label.c.ASDAC_GhsRefundSuccessMessage").replace("{0}", totalAmt);
            this.showWarningToast(refundLabel);       
        }
    },

    getMessageForOrderAction: function(orderAction, totalAmt, contactName) {
        const messages = {
            "Partial Refund": $A.get("$Label.c.ASDAC_PartialRefundSuccessMsg").replace("{0}", totalAmt).replace("{1}", contactName),
            "Delivery Charge Refund": $A.get("$Label.c.ASDAC_DeliveryChargeRefundSuccessMsg").replace("{0}", totalAmt).replace("{1}", contactName),
            "Exchange": $A.get("$Label.c.ASDAC_ExchangeCreatedSuccessMsg"),
            "Order Level Refund": $A.get("$Label.c.ASDAC_GhsRefundSuccessMessage").replace("{0}", totalAmt),
            "Refund": $A.get("$Label.c.ASDAC_GhsRefundSuccessMessage").replace("{0}", totalAmt),
            "Cancel": $A.get("$Label.c.ASDAC_CancellationSucessMsg")
        };
        return messages[orderAction];
    },

    showToast: function(message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success!",
            type: 'success',
            mode: 'dismissible',
            message: message
        });
        toastEvent.fire();
    },
    
    showWarningToast: function(message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "",
            type: 'warning',
            mode: 'dismissible',
            message: message
        });
        toastEvent.fire();
    }
    
})