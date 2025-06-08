import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import getTimeZoneOfUser from '@salesforce/apex/ASDAC_ObjectSystemInformationController.getTimeZoneOfUser';

export default class AsdacObjectSystemInformationCmp extends NavigationMixin(LightningElement) {
    @api recordId;
    @track theRecordId;
    @api objectApiName;
    @track fields = [];
    isLoaded = false;
    createdByName;
    createdById;
    createdDate;
    createdByImg;
    createdByNameValue;
    createdByIdValue;
    createdDateValue;
    createdByImgUrl;
    modifiedByName;
    modifiedById;
    modifiedDate;
    modifiedByImg;
    modifiedByNameValue;
    modifiedByIdValue;
    modifiedDateValue;
    modifiedByImgUrl;
    userTimeZoneValue;
    error;

    connectedCallback(){
        this.createdByName = this.objectApiName+'.CreatedBy.Name';
        this.createdDate = this.objectApiName+'.CreatedDate';
        this.createdById = this.objectApiName+'.CreatedById';
        this.modifiedByName = this.objectApiName+'.LastModifiedBy.Name';
        this.modifiedDate = this.objectApiName+'.LastModifiedDate';
        this.modifiedById = this.objectApiName+'.LastModifiedById';
        this.createdByImg = this.objectApiName+'.CreatedBy.SmallPhotoUrl';
        this.modifiedByImg = this.objectApiName+'.LastModifiedBy.SmallPhotoUrl';
        this.fields = [
            this.createdByName, this.createdDate, this.createdById, 
            this.modifiedByName, this.modifiedDate, this.modifiedById, 
            this.createdByImg, this.modifiedByImg
        ];

        getTimeZoneOfUser({userId: USER_ID}).then(result => {
            this.userTimeZoneValue = result;
            this.theRecordId = this.recordId;
        })
        .catch(error => {
            this.error = error;
        });
    }
    @wire(getRecord, { recordId: '$theRecordId', fields: '$fields' }) record({ error, data }){
        if (data) {
            this.createdByNameValue = getFieldValue(data,this.createdByName);
            this.createdByIdValue = getFieldValue(data,this.createdById);
            this.createdDateValue = getFieldValue(data,this.createdDate);
            this.modifiedByNameValue = getFieldValue(data,this.modifiedByName);
            this.modifiedDateValue = getFieldValue(data,this.modifiedDate);
            this.modifiedByIdValue = getFieldValue(data,this.modifiedById);
            this.createdByImgUrl = getFieldValue(data, this.createdByImg);
            this.modifiedByImgUrl = getFieldValue(data, this.modifiedByImg);
            this.isLoaded = true;
        }
        if(error){
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            }
            if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
        }
    }

    handleCreatedByIdClick(){
        this.navigateToRecordId(this.createdByIdValue);
    }

    handleModifiedByIdClick(){
        this.navigateToRecordId(this.modifiedByIdValue);
    }

    navigateToRecordId(recordId){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                "recordId": recordId,
                "objectApiName":"User",
                "actionName": "view"
            }
        });
    }

}