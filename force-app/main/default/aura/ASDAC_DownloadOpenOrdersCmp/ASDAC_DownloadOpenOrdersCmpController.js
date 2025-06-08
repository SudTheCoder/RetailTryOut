({
    
	invoke : function(component, event, helper) {
        let content = "data:text/xls;charset=utf-8,";
        let fileName = component.get("v.customerName") + '_Open_Orders.xls';
        
        // Create an anchor element to prompt the download
        let encodedUri = encodeURI(content);
        let link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", fileName);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
    
})