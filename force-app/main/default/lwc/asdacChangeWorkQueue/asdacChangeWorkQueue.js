import { LightningElement, track, wire, api } from 'lwc';
import getQueues from "@salesforce/apex/ASDAC_ChangeWorkQueueController.getListOfQueues";
import updateCaseOwner from "@salesforce/apex/ASDAC_ChangeWorkQueueController.updateCaseOwner";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import caseUpdationSuccessMessage from '@salesforce/label/c.ASDAC_CaseUpdationSuccessMessage';
import successToastTitle from '@salesforce/label/c.ASDAC_SuccessToastTitle';
import errorToastTitle from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import changeOwner from '@salesforce/label/c.ASDAC_ChangeOwner';
import selectOwnerLabel from '@salesforce/label/c.ASDAC_SelectOwnerLabel';
import commentsLabel from '@salesforce/label/c.ASDAC_CommentsLabel';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';
import existingUserToastTitle from '@salesforce/label/c.ASDAC_ExistingUserToastTitle';

export default class AsdacChangeWorkQueue extends LightningElement {
	@track queues = [];
	@track queueValue;
	@api recordId;
	isLoading = false;
	label = {
		changeOwner,
		selectOwnerLabel,
		commentsLabel,
		cancelButtonLabel
	};

	@wire(getQueues) 
	getQueues({error, data}) {
		if (error) {
			const event = new ShowToastEvent({
				title: errorToastTitle,
				variant: "error",
				message: error.message
			});
			this.dispatchEvent(event);
		} else if (data) {
			let queueRecords = JSON.parse(JSON.stringify(data.listOfQueues));
			let lstOption = [];
			for (let queueRecord of queueRecords) {
				lstOption.push({value: queueRecord.QueueId,label: queueRecord.Queue.Name});
			}
			this.queues = lstOption;
		}
	}

	selectedQueue(event){
		this.queueValue = event.target.value;
	}

	isInputValid() {
		let isValid = true;
		let inputFields = this.template.querySelectorAll('.validate');
		inputFields.forEach(inputField => {
			if(!inputField.checkValidity()) {
				inputField.reportValidity();
				isValid = false;
			}
		});
		return isValid;
	}

	handleClick(event){
		event.preventDefault();
		if(event.target.name === 'cancel') {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
		if(event.target.name === 'save') {
			if(this.isInputValid()) {
				this.isLoading = true;
				let inp = this.template.querySelector('.caseComm');
				let caseComment;
				if(inp.name === 'CaseComment'){
					caseComment = inp.value;
				}
				
				updateCaseOwner({caseId: this.recordId, caseComment: caseComment, newOwnerId: this.queueValue})
				.then(result => {
					if(!result.isSuccess){
						this.isLoading = false;
						const missingToast = new ShowToastEvent({
							title: existingUserToastTitle,
							variant: "error",
							message: result.message
						});
						this.dispatchEvent(missingToast);
					} else {
						const missingToast = new ShowToastEvent({
							title: successToastTitle,
							variant: "success",
							message: caseUpdationSuccessMessage
						});
						this.dispatchEvent(missingToast);
						
						setTimeout(function() {
							window.location.reload();
						}, 1000);
					}
				})
				.catch(error => {
					const missingToast = new ShowToastEvent({
						title: errorToastTitle,
						variant: "error",
						message: error
					});
					this.dispatchEvent(missingToast);
				});
			}
		}
	}
}