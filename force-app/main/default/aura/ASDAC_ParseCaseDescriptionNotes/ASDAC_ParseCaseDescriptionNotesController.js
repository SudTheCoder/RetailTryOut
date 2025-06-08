({
    invoke : function(component, event, helper) {
        let tempString = JSON.parse(component.get("v.refundToCreateStr"));
        let itemDescription = '';
        let itemReason = '';
        
        if(component.get("v.actionName") === 'Delivery Charge Refund' || component.get("v.actionName") === 'Order Level Refund'){
            itemDescription = 'Reason: '+ tempString[0].refundReason;
            itemReason = 'Reason: '+ tempString[0].notes;
        }
        else if(component.get("v.actionName") === 'eVoucher'){
            itemDescription = 'Reason: '+ tempString[0].refundReason;
        }
        else if(component.get("v.actionName") === 'Cancel'){
            itemDescription = 'Reason: '+ tempString[0].cancelReason;
        }
        else if(component.get("v.actionName") === 'Override'){
            for(let key of tempString){
            itemDescription += key.productId+' '+ key.notes+' \n';
        }
        }
        else{
            for(let key of tempString){
                itemDescription += 'Item: '+ key.productDescription+' , Reason: '+ key.reason+' \n';
                itemReason += 'Item: '+ key.productDescription+' , Reason: '+ key.notes+' \n';
            }
        }

        component.set("v.itemDescription",itemDescription);
        component.set("v.itemReason",itemReason);
    }
})