({
    init : function (component) {
        const flowEl = component.find("flowData");
        flowEl.startFlow("ASDAC_WebformGeorgeRefundFlow");
    },
    statusChange : function (cmp, event) {
        if (event.getParam('status') === "FINISHED") {
            window.alert("Your refund request has been submitted successfully")
        }
    }
})