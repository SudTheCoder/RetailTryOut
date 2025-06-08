({    
    invoke : function(component, event, helper) {

        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: component.get("v.title"),
            type: component.get("v.type"),
            message: component.get("v.toastMessage")
        });
        toastEvent.fire();          
    }
    
})