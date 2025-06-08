import { LightningElement, api, wire } from 'lwc';
import reOpenToMe from '@salesforce/apex/ASDAC_ReopenCaseController.reOpenToMe';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from 'lightning/messageService';
import consoleMessageChannel from '@salesforce/messageChannel/consoleMessageChannel__c';
import reopenCaseSuccessToastMessage from '@salesforce/label/c.ASDAC_ReopenCaseSuccessToastMessage';

export default class AsdacReopenCaseToMeCmp extends LightningElement {

    @api recordId;
    isSameOwner = false;
    @wire(MessageContext)
    messageContext;

    @api invoke() {  
            reOpenToMe({ recordId: this.recordId }).then((result) => {
                if (result.isSuccess) {
                    this.showToast(true, reopenCaseSuccessToastMessage);
                    const payload = { data : {recordId : this.recordId, message : 'refresh'}};
                    publish(this.messageContext, consoleMessageChannel, payload);
                }
                else {
                    this.showToast(false, result.message);
                }
            }).catch((error) => {
                this.showToast (false, error.message);
            });
        }
    

    showToast(isSuccess, message) {
        let variant = isSuccess ? 'Success' : 'Error';
        const toastEvent = new ShowToastEvent({
            title: variant,
            variant: variant,
            message: message
        });
        this.dispatchEvent(toastEvent);
    }
}