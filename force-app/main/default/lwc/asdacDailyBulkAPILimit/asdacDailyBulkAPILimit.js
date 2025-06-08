import { LightningElement, track, wire } from 'lwc';
import getDailyBulkAPILimit from '@salesforce/apex/ASDAC_DailyBulkApiLimit_Controller.getDailyBulkAPILimit';

const columns = [
    { label: 'Label', fieldName: 'label' },
    { label: 'Remaining / Max', fieldName: 'indication' },
    { label: '%', fieldName: 'score', type: 'percent', initialWidth: '10' }
];
export default class AsdacDailyBulkAPILimit extends LightningElement {
    columns = columns;
    error;
    @track dailyBulkLimit = [];
    dataLoaded = false;

    @wire(getDailyBulkAPILimit)
    wiredMethod({ error, data }) {
        if (data) {
            let obj = [{
                "label" : 'Daily Bulk API Batches',
                "indication" : ''+(data.max - data.consumed)+'/'+data.max,
                "score" : data.consumed/data.max
            }]
            this.dailyBulkLimit = JSON.parse(JSON.stringify(obj));
            this.error = undefined
            this.dataLoaded = true;
        } else if (error) {
            this.error = error;
        }
    }
}