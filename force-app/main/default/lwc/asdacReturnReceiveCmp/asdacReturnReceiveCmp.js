import { LightningElement, track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import receiveRequest from '@salesforce/apex/ASDAC_OrderController.receiveRequest'
import exchangeReceiptSuccess from '@salesforce/label/c.ASDAC_ReceiptExchangeSuccessMsg';
import returnReceiptSuccess from '@salesforce/label/c.ASDAC_ReceiptReturnSuccessMsg';

export default class AsdacReturnReceiveCmp extends LightningElement {

    @api returnReceiveList;
    @api returnOrderId;
    @track itemsToReceive;
    @track isLoading = true;
    @track hasRendered = true;
    @track lineToQuantityMap;
    @track createdFromExchange=false;
    @track successMessage;
    @track totalAmount=0;
    @api customerName;

    connectedCallback(){
        this.isLoading = false;
        this.itemsToReceive = this.returnReceiveList;
    }
    
    renderedCallback(){
        if(this.hasRendered){
            this.hasRendered = false;
           this.setQuantityPicklist();
        }
    }   

    setQuantityPicklist(){
        [...this.template.querySelectorAll(".oiQuantity")].forEach((row) => {
            if(parseInt(row.dataset.value,2) === parseInt(0,2)){
               row.disabled = true;
               row.value = row.dataset.value;
           }
           else{
               row.disabled = false;
               row.value = row.dataset.value;
           } 
           row.options =[];
           for (let i = 1; i <= row.dataset.value; i++) {
              row.options = [...row.options, {label: `${i}` , value:  `${i}` }]
           }
          
        });
    }

    handleSubmit(){
        if (this.returnReceiveList.length > 0) {	
            this.lineToQuantityMap = new Map();
            [...this.template.querySelectorAll(".oiQuantity")].forEach((input) => {
                this.lineToQuantityMap.set(
                  input.dataset.id.toString(),
                  Number(input.value)
                );
              });
            this.returnReceiveList.forEach(item => {
                const quantity = Number(this.lineToQuantityMap.get(item.orderLineId.toString()));
                this.totalAmount += quantity * item.unitTotal;
              });
              this.totalAmount =this.totalAmount.toFixed(2);
            const order = {};
            order.orderId = this.returnOrderId;
            order.orderLines = this.returnReceiveList.map((ol) => {
                const tempOrderLine = ol;
                const orderLine = {};
                orderLine.orderLineId = tempOrderLine.orderLineId;
                orderLine.quantity = this.lineToQuantityMap.get(tempOrderLine.lineId);
                return orderLine;
              });
            this.toastMessageUpdate();  
            receiveRequest({order:order}).then(result=>{
                const evt = new ShowToastEvent({
                    message: this.successMessage,
                    variant: 'success',
                });
            this.dispatchEvent(evt);
            this.dispatchEvent(new CustomEvent('close'));
            this.updateRecordView();
            }).catch((err) => {
                let message;
                try {
                  message = JSON.parse(err.body.message).message;
                } catch (e) {
                  message = err.body.message;
                }
                const event = new ShowToastEvent({
                  variant: "error",
                  title: "Error",
                  message
                });
                this.dispatchEvent(event);
                this.isLoading = false;
              });
        }
    }

    toastMessageUpdate(){
      this.createdFromExchange = this.itemsToReceive[0].isCreatedFromExchange;
      if(this.createdFromExchange){
        this.successMessage= exchangeReceiptSuccess;
      }
      else{
        this.successMessage=  returnReceiptSuccess
                              .replace("{0}", this.totalAmount)
                              .replace("{1}", this.customerName);
      }
    }

    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000); 
     }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('close'));
    }

}