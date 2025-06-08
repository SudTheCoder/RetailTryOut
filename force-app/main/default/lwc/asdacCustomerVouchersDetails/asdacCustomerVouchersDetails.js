/**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 24/02/2023
* @description                  : ASDAC-6277 - Rel B - Geo - GV - CCA UI API integration - View Customer's Voucher History

**********************************************************************************/

import { LightningElement, wire, api } from 'lwc';
import getVoucherHistoryServicedata from '@salesforce/apex/ASDAC_CustomerVourcherHistoryCRM.getVoucherHistoryServicedata';
import getMerkelAuthToken from '@salesforce/apex/ASDAC_AuthorizeSFCCForVoucher.getMerkelAuthToken';
import toDisableVoucher from '@salesforce/apex/ASDAC_DisableCustomerVoucherService.toDisableVoucher';
import LightningConfirm from "lightning/confirm";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createContentNote from '@salesforce/apex/ASDAC_VouchersDetailsController.createContentNote';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import ROLE_NAME from "@salesforce/schema/User.UserRole.Name";
import ELIGIBLE_ROLES from "@salesforce/label/c.ASDAC_RemoveVoucherEligibleRoles";
import disableVoucherSuccessToastMessage from "@salesforce/label/c.ASDAC_DisableVoucherSuccessToastMessage";
import successToastTitle from '@salesforce/label/c.ASDAC_SuccessToastTitle';
import errorToastTitle from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import enterNotes from '@salesforce/label/c.ASDAC_EnterNotes';
import disableVoucherHeaderLabel from '@salesforce/label/c.ASDAC_DisableVoucherHeaderLabel';
import disableVoucherHeaderMessage from '@salesforce/label/c.ASDAC_DisableVoucherHeaderMessage';
import submitButtonLabel from '@salesforce/label/c.ASDAC_SubmitButtonLabel';
import cancelButtonLabel from '@salesforce/label/c.ASDAC_CancelButtonLabel';
import notesLabel from '@salesforce/label/c.ASDAC_NotesLabel';
import ASDACNOTESERROR from '@salesforce/label/c.ASDAC_NotesError';

export default class AsdacCustomerVouchersDetails extends LightningElement {
    isRoleEligible;
    COLUMNS;
    sortedBy = 'issueDate';
    selectedRow;
    defaultSortDirection = 'desc';
    GEOVoucherColumns;

    label = {
        enterNotes,
        submitButtonLabel,
        cancelButtonLabel,
        notesLabel,
        ASDACNOTESERROR
    };

    @wire(getRecord, { recordId: USER_ID, fields: [ROLE_NAME] })
    wiredUser({ error, data }) {
        if (error) {
            const event = new ShowToastEvent({
                title: errorToastTitle,
                variant: "error",
                message: error.message
            });
            this.dispatchEvent(event);
        } else if (data) {
            this.isRoleEligible = ELIGIBLE_ROLES.includes(data.fields.UserRole.value?.fields.Name.value) ? true : false;
        }

    }

    VOUCHER_COLUMNS_C = [
        { label: 'Type', fieldName: 'type', type: 'text' },
        { label: 'Date of issue', fieldName: 'issueDate', type: 'datetime' },
        { label: 'Value', fieldName: 'amountValue', type: 'currency', cellAttributes: { alignment: 'left' } },
        { label: 'Redeemed', fieldName: 'redeemed', type: 'text' },
        { label: 'Voucher Id', fieldName: 'code', type: 'text' },
        { label: 'Expiry date', fieldName: 'expiryDate', type: 'datetime' },
        { label: 'Reason code', fieldName: 'description', type: 'text' },
        {
            type: 'button-icon',
            initialWidth: 50,
            typeAttributes: {
                iconName: 'utility:close',
                title: 'disable',
                variant: 'bare',
                alternativeText: 'disable'
            }
        }

    ];
    VOUCHER_COLUMNS1_C = [
        { label: 'Type', fieldName: 'type', type: 'text' },
        { label: 'Date of issue', fieldName: 'issueDate', type: 'datetime' },
        { label: 'Value', fieldName: 'amountValue', type: 'currency', cellAttributes: { alignment: 'left' } },
        { label: 'Redeemed', fieldName: 'redeemed', type: 'text' },
        { label: 'Voucher Id', fieldName: 'code', type: 'text' },
        { label: 'Expiry date', fieldName: 'expiryDate', type: 'datetime' },
        { label: 'Reason code', fieldName: 'description', type: 'text' },
    ];

    @api recordId;
    anotherAccessToken;
    response = [];
    merchantId;
    voucherResult;
    showSecondModal = false;
    notes = '';
    isNotesError = false;

    //calling the getMerkelAuthToken to get the access token
    async connectedCallback() {
        try {
            this.COLUMNS = this.isRoleEligible ? this.VOUCHER_COLUMNS_C : this.VOUCHER_COLUMNS1_C;
            this.accessToken = await getMerkelAuthToken();
            this.sortDirection = this.defaultSortDirection;

        } catch (error) {
            console.error(error);
        }
    }

    sortData() {
        const sortedData = [...this.response];
        sortedData.sort((a, b) => {
            const dateA = new Date(a.issueDate);
            const dateB = new Date(b.issueDate);

            if (dateA < dateB) {
                return this.sortDirection === 'asc' ? -1 : 1;
            }
            if (dateA > dateB) {
                return this.sortDirection === 'asc' ? 1 : -1;
            }
            return 0;
        });

        if (this.defaultSortDirection === 'desc') {
            sortedData.reverse();
        }

        this.response = sortedData;
    }

    handleHeaderAction(event) {
        let field = event.detail.fieldName;
        if (field === 'issueDate') {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortDirection = 'asc';
        }
        this.sortedBy = field;
        this.sortData();
    }

    //calling  the getvoucherdata method of server to get the API Response by using access token
    @wire(getVoucherHistoryServicedata, { accId: '$recordId' })
    getVoucherData({ error, data }) {
        if (data) {

            this.response = data;
            this.sortData();
        } else if (error) {
            console.error(error);
        }
    }

    //handling the confirmation of disabling the voucher
    async handleConfirmClick(event) {
        const row = event.detail.row;
        this.rowToDelete = row;
        this.selectedRow = row;

        const buttonClickEvent = new CustomEvent('buttonclick', {
            detail: {
                row: row,
                message: disableVoucherHeaderMessage,
                variant: "Header", // headerless
                label: disableVoucherHeaderLabel,
                theme: "warning"
            }
        });

        const result = await LightningConfirm.open({
            message: buttonClickEvent.detail.message,
            variant: buttonClickEvent.detail.variant,
            label: buttonClickEvent.detail.label,
            theme: buttonClickEvent.detail.theme
        });

        //result is true if OK was clicked
        if (result) {
            this.showSecondModal = true;
        } else {
            //and false if cancel was clicked
            this.handleErrorAlertClick();
        }
    }

    //handling the errorClick if "CANCEL" was clicked
    async handleErrorAlertClick() {
        this.showSecondModal = false;
    }


    ///handling the event if "OK" was Clicked
    async handleRowAction(row) {
        try {
            //calling getMerkelAuthToken for getting the access token again because it gets expire afer sometime
            this.anotherAccessToken = await getMerkelAuthToken();
            //callling the wiredDisableVoucher where we are calling toDisableVoucher apex method imperatively of server 
            this.disableVoucher(row.merchantId);

        }
        catch (error) {
            console.error('Error:', error);
        }
    }

    disableVoucher(merchantIds) {
        let token = this.anotherAccessToken;


        toDisableVoucher({ merchantId: merchantIds, access_token: token })
            .then(result => {
                this.voucherResult = result;
                const updateResponse = [...this.response];
                const index = this.response.findIndex(item => item.merchantId === merchantIds);
                if (index !== -1) {
                    updateResponse.splice(index, 1);
                    this.response = updateResponse;
                }

                this.showToast();
                return refreshApex(this.getVoucherData);

            })
            .catch(error => {
                console.error('Error:', error);
                // Handle the error
            });
    }
    resetNotes() {
        this.notes = '';
        this.isNotesError = false;
    }

    handleOnChange(event) {
        this.notes = event.target.value;
        this.isNotesError = false;
    }

    async handleSecondModalOK() {
        if (this.notes.trim() === '') {
            this.isNotesError = true;
        } else {
            const evoucherValue = this.selectedRow.amountValue;
            const content = `${this.notes} | Amount: ${evoucherValue}`;
            const contentDoclnkId = await createContentNote({
                title: 'Evoucher Notes',
                content: content,
                recordId: this.recordId
            });
            if (contentDoclnkId) {
                this.showSecondModal = false;
            }
            const row = this.selectedRow;
            await this.handleRowAction(row);
            // Reset the notes and close the second modal
            this.notes = '';
        }
    }

    handleSecondModalCancel() {
        // Close the second modal
        this.showSecondModal = false;
        this.resetNotes();
    }

    showToast() {
        const event = new ShowToastEvent({
            title: successToastTitle,
            message: disableVoucherSuccessToastMessage,
            variant: 'success',
        })
        this.dispatchEvent(event);
    }

}