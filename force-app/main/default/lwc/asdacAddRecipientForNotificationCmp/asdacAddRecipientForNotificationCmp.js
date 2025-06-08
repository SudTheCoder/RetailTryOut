import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import fetchRecords from '@salesforce/apex/ASDAC_ServiceNotificationAlerts.fetchRecords';
import getAllUserGroupId from '@salesforce/apex/ASDAC_ServiceNotificationAlerts.getAllUserGroupId';
import saveRecipientRecord from '@salesforce/apex/ASDAC_ServiceNotificationAlerts.saveRecipientRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AsdacAddRecipientForNotificationCmp extends LightningElement {
    @track selectedMenuItem;
    @track sObjectApiName;
    @api recordId;
    @track menuItems = [
        { id: 'user', value: "user", label: "User", iconName: "standard:individual", checked: true, type : 'User' },
        { id: 'queue', value: "queue", label: "Queue", iconName: "standard:orders", checked: false, type : 'Queue'},
        { id: 'allUsers', value: "allUsers", label: "All Users", iconName: "standard:groups", checked: false, type : 'All User' }
    ]
    @api value;
    @api label;
    @api placeholder;
    @api required = false;
    @track searchString;
    @track selectedRecord;
    @track recordsList;
    @track message;
    @track showPill = false;
    @track showSpinner = false;
    @track showDropdown = false;
    isRendered = false;

    renderedCallback() {
      if (this.isRendered) {
        return;
      }
      this.isRendered = true;
      const style = document.createElement("style");
      style.innerHTML = ".slds-pill,.slds-pill__label { width: 100%; } .slds-modal__content {min-height : 40vh}";
      this.template.querySelector(".style-section").appendChild(style);
    }

    connectedCallback() {
        this.selectedMenuItem = this.menuItems[0];
        this.sObjectApiName = 'User';

        if (this.value) {
            this.fetchData();
        }
    }
    handleMenuClick(event) {
        let self = this;
        this.menuItems.forEach(function (menuItem) {
            menuItem.checked = false;
            if (menuItem.value === event.target.value) {
                self.selectedMenuItem = menuItem;
                menuItem.checked = true;
            }
        });
        //If "All User" menu is Selected 
        if (this.selectedMenuItem.label === this.menuItems[2].label) {
            getAllUserGroupId().then((result) => {
                this.sObjectApiName = 'Group';
                this.selectedRecord = {
                    label: 'All Customer Service Users',
                    value: result.allUserGrpId
                };
                this.value = this.selectedRecord.value;
                this.showDropdown = false;
                this.showPill = true;
            }).catch((error) => {

            });
        }
        else {
            // If User is Selected
            if (this.selectedMenuItem.label === this.menuItems[0].label) {
                this.sObjectApiName = 'User';
            }
            //If Queue is Selected
            else if (this.selectedMenuItem.label === this.menuItems[1].label) {
                this.sObjectApiName = 'Group';
            }
        }

        this.showPill = false;
        this.value = '';
        this.selectedRecord = '';
        this.searchString = '';
    }
    handleCancel(event) {
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    searchRecords(event) {
        this.searchString = event.target.value;
        if (this.searchString) {
            this.fetchData();
        } else {
            this.showDropdown = false;
        }
    }

    selectItem(event) {
        if (event.currentTarget.dataset.key) {
            let index = this.recordsList.findIndex(x => x.value === event.currentTarget.dataset.key)
            if (index != -1) {
                this.selectedRecord = this.recordsList[index];
                this.value = this.selectedRecord.value;
                this.showDropdown = false;
                this.showPill = true;
            }
        }
    }

    removeItem() {
        if (this.selectedMenuItem.label === this.menuItems[2].label) {
            const event = new ShowToastEvent({
                message: 'You Cannot Remove All Users Group If All User is selected.',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
        else {
            this.showPill = false;
            this.value = '';
            this.selectedRecord = '';
            this.searchString = '';
        }
    }

    showRecords() {
        if (this.recordsList && this.searchString) {
            this.showDropdown = true;
        }
    }

    blurEvent() {
        this.showDropdown = false;
    }

    fetchData() {
        this.showSpinner = true;
        this.message = '';
        this.recordsList = [];
        fetchRecords({
            objectName: this.sObjectApiName,
            filterField: 'Name',
            searchString: this.searchString,
            value: this.value
        })
            .then(result => {
                if (result && result.length > 0) {
                    if (this.value) {
                        this.selectedRecord = result[0];
                        this.showPill = true;
                    } else {
                        this.recordsList = result;
                    }
                } else {
                    this.message = "No Records Found for '" + this.searchString + "'";
                }
                this.showSpinner = false;
            }).catch(error => {
                this.message = error.message;
                this.showSpinner = false;
            })
        if (!this.value) {
            this.showDropdown = true;
        }
    }
    saveRecord() {
        if (!this.selectedRecord.label) {
            const event = new ShowToastEvent({
                message: 'User/Group needs to be selected.',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
        else {
            saveRecipientRecord({serviceNotifId : this.recordId, stringifiedRecordData : JSON.stringify(this.selectedRecord), typeOfRecipient : this.selectedMenuItem.type}).then((result) => {
                if(result.isSuccess) {
                    const event = new ShowToastEvent({
                        message: 'Recipient inserted successfully.',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                                        window.location.reload();

                }
                else {
                     const event = new ShowToastEvent({
                        message: result.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                    window.location.reload();

                }
            }).catch((error) => {
                     const event = new ShowToastEvent({
                        message: error.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                                        window.location.reload();

            });
        }
    }
}