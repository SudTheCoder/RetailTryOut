({    
    invoke : function(component, event, helper) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success!",
            type: 'success',
            mode: 'dismissible',
            message: 'eVoucher issued to '+ component.get("v.customerName")
        });
        toastEvent.fire(); 
        window.location.reload();
    }
    
})