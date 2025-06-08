import { LightningElement, api , wire} from 'lwc';
import assignToMe from '@salesforce/apex/ASDAC_AssignToMeController.assignToMe';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import userId from '@salesforce/user/Id';
import { getRecord} from 'lightning/uiRecordApi';
import OWNER_ID from '@salesforce/schema/Case.OwnerId';
import { publish, MessageContext } from 'lightning/messageService';
import consoleMessageChannel from '@salesforce/messageChannel/consoleMessageChannel__c';
import caseAssignmentSuccessMessage from '@salesforce/label/c.ASDAC_CaseAssignmentSuccessMessage';
import caseAlreadyAssignedMessage from '@salesforce/label/c.ASDAC_CaseAlreadyAssignedMessage';

const fields = [OWNER_ID];
export default class AsdacAssignCaseToMeCmp extends LightningElement {

    @api recordId;
    isSameOwner  = false;
    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields})
    caseRecord({error, data}) {
        if(data) {
            if(userId === data.fields.OwnerId.value) {
                this.isSameOwner = true;
            }
        }
        else if (error) {
            this.showToast(false, error);
        }
    }

    @api invoke() {
        if(!this.isSameOwner) {
            assignToMe({recordId : this.recordId}).then((result) => {
                if(result.isSuccess) {
                    this.showToast(true, caseAssignmentSuccessMessage);
                    const payload = { data : {recordId : this.recordId, message : 'refresh'}};
                    publish(this.messageContext, consoleMessageChannel, payload);
                }
                else {
                    this.showToast(false, result.message);
                }
            }).catch((error) => {
                this.showToast(false, error.message);
            });
        }
        else {
            this.showToast(false, caseAlreadyAssignedMessage);
        }
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