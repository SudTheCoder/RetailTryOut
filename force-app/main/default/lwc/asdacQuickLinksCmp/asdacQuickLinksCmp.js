import {
    LightningElement,
    wire,
    track
} from 'lwc';
import Quicklinkmethod from '@salesforce/apex/ASDAC_QuickLinksController.asdaQuicklink';

export default class AsdacQuickLinksCmp extends LightningElement {
    availablelinks;
    error;
    @track dataFound;
    @track displayMessage;

   @wire(Quicklinkmethod)
    wiredlinks({
        error,
        data
    }) {
        if (data) {
            this.availablelinks = data.listOfActiveMdtRecords;
            this.error = undefined;
            this.dataFound = data.isSuccess;

            if (!this.dataFound) {
                this.displayMessage = data.message;
            }

        } else if (error) {
            this.availablelinks = undefined;
            this.error = error;
            this.dataFound = false;
            this.displayMessage = error;
        }
    }
}