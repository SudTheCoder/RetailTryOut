import { LightningElement,api } from 'lwc';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';
import { CloseActionScreenEvent } from 'lightning/actions';
import unlinkProfile from "@salesforce/apex/ASDAC_RewardsController.unlinkProfile";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import successMessageLabel from '@salesforce/label/c.ASDAC_RewardsSuccessMessage';

export default class AsdacUnlinkedRewardsAccount extends LightningElement {
	@api isLoading;
    label = {
		cancelButtonLabel
	};

	handleCancelClick(event)
	{
		event.preventDefault();
		if(event.target.name === 'cancel') {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
	}

	handleProfileChange(event){
		if(event.target.value !== undefined || event.target.value !== '' || event.target.value !== null){
			event.target.setCustomValidity('');
			event.target.reportValidity();
		}
	}

	handleSubmitClick(event){
		let isValid = true;
		let crmId = this.template.querySelector(".crmId");
		let crmIdValue = crmId.value;
		if(crmIdValue === undefined || crmIdValue === '' || crmIdValue === null){
			isValid = false;
			crmId.setCustomValidity('Complete this field.');
			crmId.reportValidity();
		}
		
		if(isValid){
			this.isLoading = true;
			unlinkProfile({ crmId: crmIdValue })
                .then((data) => {
                    if(data === 200){
						this.isLoading = false;
						this.displayToastMessage("Success","Success", successMessageLabel);
						this.dispatchEvent(new CloseActionScreenEvent());
					}
                })
                .catch((err) => {
                    this.displayToastMessage("Error","error", this.getErrorMessage(err));
                    this.isLoading = false;
                });
		}
		
	}

	displayToastMessage(title, variant, message){
        const toEvt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(toEvt);
    }

	getErrorMessage(err) {
        let message = err.message;
        if (err.body) {
            try {
                message = JSON.parse(err.body.message).message;
            } catch(error) {
                message = err.body.message;
            }
        }
        return message;
    }
	
}