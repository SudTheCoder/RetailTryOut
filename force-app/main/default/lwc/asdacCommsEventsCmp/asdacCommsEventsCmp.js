import { LightningElement, api, track} from 'lwc';
import { getResponse } from 'c/asdacCalloutUtilityCmp';
import channelLabel from '@salesforce/label/c.ASDAC_ChannelLabel';
import subjectLabel from '@salesforce/label/c.ASDAC_SubjectLabel';
import timeStampLabel from '@salesforce/label/c.ASDAC_TimeStampLabel';
import recipientStatusLabel from '@salesforce/label/c.ASDAC_RecipientStatusLabel';
import senderLabel from '@salesforce/label/c.ASDAC_SenderLabel';
import messagePreviewLabel from '@salesforce/label/c.ASDAC_MessagePreviewLabel';
import businessLineLabel from '@salesforce/label/c.ASDAC_BusinessLineLabel';
import failReasonCodeLabel from '@salesforce/label/c.ASDAC_FailReasonCodeLabel';
import openTimeStampLabel from '@salesforce/label/c.ASDAC_OpenTimeStampLabel';
import clickTimeStampLabel from '@salesforce/label/c.ASDAC_ClickTimeStampLabel';
import bounceTimeStampLabel from '@salesforce/label/c.ASDAC_BounceTimeStampLabel';
import toDateFilterLabel from '@salesforce/label/c.ASDAC_ToDateFilterLabel';
import fromDateFilterLabel from '@salesforce/label/c.ASDAC_FromDateFilterLabel';
import commsNotFoundMessage from '@salesforce/label/c.ASDAC_CommsNotFoundMessage';
import previousButtonLabel from '@salesforce/label/c.ASDAC_Previous';
import nextButtonLabel from '@salesforce/label/c.ASDAC_Next';
import loadingSpinnerAlternateText from '@salesforce/label/c.ASDAC_LoadingSpinnerAlternateText';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const COLUMNS = [
	{label: channelLabel, fieldName: "channel", type: "text", wrapText: true},
    {label: subjectLabel, fieldName: "subject", type: "text", wrapText: true},
	{label: timeStampLabel, fieldName: "timestamp", type: "datetime", wrapText: true },
	{label: recipientStatusLabel, fieldName: "recipientstatus", type: "text", wrapText: true },
    {label: senderLabel, fieldName: "sender", type: "text", wrapText: true },
    {label: messagePreviewLabel, fieldName: "messagepreview", type: "text", wrapText: true },
    {label: businessLineLabel, fieldName: "businessline", type: "text", wrapText: true },
    {label: failReasonCodeLabel, fieldName: "failreasoncode", type: "text", wrapText: true },
    {label: openTimeStampLabel, fieldName: "opentimestamp", type: "datetime", wrapText: true },
    {label: clickTimeStampLabel, fieldName: "clicktimestamp", type: "datetime", wrapText: true },
    {label: bounceTimeStampLabel, fieldName: "bouncetimestamp", type: "datetime", wrapText: true }
];
export default class AsdacCommsEventsCmp extends LightningElement {
    @api recordId;
    //Pagination Attributes
    @track
    paginationList = [];
    staticPaginationList = [];
    pgSize = 25;
    startIndex;
    isNextDisabled;
    isPreviousDisabled;
    startPosition;
    endPosition;
    totalSize;
    commsList = [];
    responseJSON = '';

    columns = COLUMNS;
    data;
    filterObj = {};
    filteredRecords = [];
    showCommsList = false;
    avoidRecursion = false;
    loading = true;
    label = {
        commsNotFoundMessage,
        previousButtonLabel,
        toDateFilterLabel,
        fromDateFilterLabel,
        nextButtonLabel,
        loadingSpinnerAlternateText
    };
    connectedCallback() {
        this.hanldeCalloutResponseReturnEvent();
    }

    populatePaginatedList(startIndex, endIndex, fullList) {
        let paginatedList = [];
        for(let i = startIndex ; i <= endIndex ; i++) {
            if(i < fullList.length) {
        		paginatedList.push(fullList[i]);
            }
            else {
                break;
            }
        }
        this.paginationList = paginatedList;
        this.staticPaginationList = paginatedList;
        this.startIndex = startIndex;
        let hasNext = endIndex < (fullList.length -  1) ? true : false;
        let hasPrevious = (startIndex != 0) ? true : false;
        this.isNextDisabled = !hasNext;
        this.isPreviousDisabled = !hasPrevious; 
        this.startPosition = startIndex + 1;
        this.endPosition = startIndex + paginatedList.length;
        this.totalSize = fullList.length;
    }

    handleNext() {
    	let startIndex = this.startIndex;
    	let pageSize = this.pgSize;
        startIndex = startIndex + pageSize;
        let endIndex   = startIndex + (pageSize - 1);
        this.applyFilters(startIndex, endIndex);
    }

    handlePrevious() {
    	let startIndex = this.startIndex;
    	let pageSize = this.pgSize;
        startIndex = startIndex - pageSize;
        let endIndex   = startIndex + (pageSize - 1);
        this.applyFilters(startIndex, endIndex);
    }

    handleFilter(event) {
        let filterField = event.target.dataset.id;
        this.filterObj[filterField] = event.target.value;
        this.applyFilters(0, this.pgSize - 1);
    }

    applyFilters(startIndex, endIndex) {
        let self = this;
        let filteredRecords = self.commsList;
        let filterFields = Object.keys(self.filterObj);
        let filterLogic = {
            timeStampFrom: (data) => new Date(data.timestamp.split(",",1)).setHours(0, 0, 0, 0) >= new Date(self.filterObj.timeStampFrom).setHours(0, 0, 0, 0),
            timeStampTo: (data) => new Date(data.timestamp.split(",",1)).setHours(0, 0, 0, 0) <= new Date(self.filterObj.timeStampTo).setHours(0, 0, 0, 0),
            openTimeStampFrom: (data) => new Date(data.opentimestamp.split(",",1)).setHours(0, 0, 0, 0) >= new Date(self.filterObj.openTimeStampFrom).setHours(0, 0, 0, 0),
            openTimeStampTo: (data) => new Date(data.opentimestamp.split(",",1)).setHours(0, 0, 0, 0) <= new Date(self.filterObj.openTimeStampTo).setHours(0, 0, 0, 0),
            clickTimeStampFrom: (data) => new Date(data.clicktimestamp.split(",",1)).setHours(0, 0, 0, 0) >= new Date(self.filterObj.clickTimeStampFrom).setHours(0, 0, 0, 0),
            clickTimeStampTo: (data) => new Date(data.clicktimestamp.split(",",1)).setHours(0, 0, 0, 0) <= new Date(self.filterObj.clickTimeStampTo).setHours(0, 0, 0, 0),
            bounceTimeStampFrom: (data) => new Date(data.bouncetimestamp.split(",",1)).setHours(0, 0, 0, 0) >= new Date(self.filterObj.bounceTimeStampFrom).setHours(0, 0, 0, 0),
            bounceTimeStampTo: (data) => new Date(data.bouncetimestamp.split(",",1)).setHours(0, 0, 0, 0) <= new Date(self.filterObj.bounceTimeStampTo).setHours(0, 0, 0, 0)
        };

        filteredRecords = filteredRecords.filter((data) => {
            for (let filterField of filterFields) {
                if (self.filterObj[filterField]) {
                    const filterLogicFn = filterLogic[filterField];
                    if (filterLogicFn) {
                        if (!filterLogicFn(data)) {
                            return false;
                        }
                    } else {
                        if (!data[filterField].toLowerCase().includes(self.filterObj[filterField].toLowerCase())) {
                            return false;
                        }
                    }
                }
            }
            return true;
        });
        this.populatePaginatedList(startIndex, endIndex, filteredRecords);
    }

    hanldeCalloutResponseReturnEvent() {
        if(!this.avoidRecursion) {
            this.loading = true;
            this.avoidRecursion = true;
            getResponse('GetCommsEvent', JSON.stringify({
                recordId : this.recordId
            })).then(result => {
                let eventData = JSON.parse(result);
                let commsList = eventData.isSuccess && eventData.strData ? JSON.parse(eventData.strData).sort((a,b) => (new Date(a.timestamptosort) > new Date(b.timestamptosort) ? -1 : 1)) : null;
                this.preparePaginatedList(commsList);
            }).catch(error => {
                this.handleError(error);
            }).finally(() => {
                this.loading = false;
            });
        }
    }
    
    preparePaginatedList(jsResult) {
        if(jsResult && jsResult.length) {
            jsResult.forEach((row) => {
                row.id = window.crypto.randomUUID();
                if(row.channel === 'Email') {
                        row.ischannelemail = true;
                }
                else {
                        row.ischannelemail = false;
                }
                }); 
            this.commsList = jsResult;
            let endIndex = this.pgSize - 1;
            this.populatePaginatedList(0, endIndex, this.commsList);   
            this.showCommsList = true;  
        }     
    }

    handleError(error) {
        let messageStr = error.message;
        if (error.body && error.body.message) {
            try {
                messageStr = JSON.parse(error.body.message).message;
                
            } catch(e) {
                messageStr = error.body.message;
            }
        }    
        const event = new ShowToastEvent({
            variant: "error",
            message: messageStr
        });
        this.dispatchEvent(event);
    }
}