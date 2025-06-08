import { LightningElement, track, wire } from 'lwc';
import getRecords from '@salesforce/apex/ASDAC_DisplayDirectoryController.getRecords';
import directoryContactNameLabel from '@salesforce/label/c.ASDAC_DirectoryContactNameLabel';
import directoryContactEmailLabel from '@salesforce/label/c.ASDAC_DirectoryContactEmailLabel';
import directoryContactTypeLabel from '@salesforce/label/c.ASDAC_DirectoryContactTypeLabel';
import ASDAC_Search from '@salesforce/label/c.ASDAC_Search';
import ASDAC_NoContactRecordsFoundMessage from "@salesforce/label/c.ASDAC_NoContactRecordsFoundMessage";

const DSVCOLUMNS = [
    { label: directoryContactNameLabel, fieldName: 'FcDsvName__c', sortable: true, wrapText: true },
    { label: directoryContactEmailLabel, fieldName: 'ContactEmail__c', sortable: true, wrapText: true }
];

const FCCOLUMNS = [
    { label: directoryContactTypeLabel, fieldName: 'FcDsvName__c', sortable: true, wrapText: true },
    { label: directoryContactEmailLabel, fieldName: 'ContactEmail__c', sortable: true, wrapText: true }
];

const TOYOUCOLUMNS = [
    { label: directoryContactEmailLabel, fieldName: 'ContactEmail__c', sortable: true, wrapText: true }
];

export default class AsdacDisplayDirectoryCmp extends LightningElement {

    dsvcolumns = DSVCOLUMNS;
    fccolumns = FCCOLUMNS;
    toyoucolumns = TOYOUCOLUMNS;
    @track data;
    @track sortBy;
    @track sortDirection;
    @track initialRecords;
    @track searchKey;
    @track dataDSV;
    @track dataFC;
    @track dataToYou;
    error;
    searchbarLabel=ASDAC_Search;
    isContactsPresent = true;

    get noRecordsFoundMessage(){
        return ASDAC_NoContactRecordsFoundMessage;
    }

    @wire(getRecords)
    wiredDirectoryContactData({ error, data }) {
        if (data) {
            this.data = data;
            this.initialRecords = data;
            this.isContactsPresent = data.length > 0 ? true : false;
            this.error = undefined;
            this.distibuteData();
        } else if (error) {
            this.isContactsPresent = false;
            this.error = error;
            this.data = undefined;
        }
    }

    handleSortDSV(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.dataDSV = this.sortData(event.detail.fieldName, event.detail.sortDirection, this.dataDSV);        
    }

    handleSortFC(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.dataFC = this.sortData(event.detail.fieldName, event.detail.sortDirection, this.dataFC);        
    }

    sortData(fieldname, direction, data) {
        let parseData = JSON.parse(JSON.stringify(data));
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = x[fieldname] ? x[fieldname].toLowerCase() : '';
            y = y[fieldname] ? y[fieldname].toLowerCase() : '';
            return isReverse * ((x > y) - (y > x));
        });
        return parseData;
    }

    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase().trim();
        this.searchKey=searchKey;
        if (searchKey) {
            this.data = this.initialRecords;
            if (this.data) {
             this.data=this.data.filter(item=> item.FcDsvName__c.toLowerCase().includes(searchKey));
             this.distibuteData();
            }
        } else {
            this.data = this.initialRecords;
            this.distibuteData()
        }
    }

    distibuteData() {
        this.dataDSV = this.data.filter(element => element.Type__c === 'DSV');
        this.dataFC = this.data.filter(element => element.Type__c === 'FC');
        this.dataToYou = this.data.filter(element => element.Type__c === 'ToYou');
      }

}