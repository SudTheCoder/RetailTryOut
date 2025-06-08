import { LightningElement,api,track} from 'lwc';
import getCustomerId from "@salesforce/apex/ASDAC_OrderController.getCustomerId";
import getOrderList from "@salesforce/apex/ASDAC_DeliveryPassController.getOrderList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

export default class AsdacDeliveryPassCalloutCmp extends LightningElement {
    @api recordId;
    @track sellingChannel="ASDA_GROCERIES";
    @track pageNumber = 1;
    @track pageSize = 100; 
    @track filter;
    @track totalRecCount = 0;
    @track loading = true;
    @track sortFields = 'creationDate:desc:date';
 
    connectedCallback() {
        this.init();
    }

    async init() {
        try {
            await Promise.all([this.storeCustomerId()]);
            this.getOrderHistory();
        } catch (err) {
            this.handleError(err);
        }
    }

    storeCustomerId() {
        return getCustomerId({ personAccountId: this.recordId }).then((customerId) => {
            this.filter = {
              orgId: { "=": "ASDA" },
              customerId: { "=": customerId },
              deliveryPassId :{"=!":null},
              sellingChannel: { "=": this.sellingChannel } 
            };
        });
    }

    get filters() {
        if (!this.filter) {
            return undefined;
        }
        return Object.keys(this.filter)
            .flatMap((field) => {
                const ops = this.filter[field];
                return Object.keys(ops).map((op) => `${field}${op}${ops[op]}`);
            })
            .join(";");
    }

    getOrderHistory() {
        this.loading = true;
        this.error = false;
        const { filters, sortFields, pageNumber, pageSize } = this;
        const option = { filters, sortFields, pageNumber, pageSize };
        getOrderList({ option: option, personAccountId: this.recordId })
        .then(async (data) => {
            if(data){
                let newList = data.map(id => ({recordId: id}));
                await notifyRecordUpdateAvailable(newList);
                this.loading = false;
            }
        })
        .catch(this.handleError.bind(this));
    }

    handleError(error) {
        let message;
        if (error.body) {
            try {
                error = JSON.parse(error.body.message);
            } catch(e) {
                error = error.body;
            }
        }
        message = error.message;
        
        this.error = error;
        this.orders = [];
        this.loading = false;
        const event = new ShowToastEvent({
            title: message,
            variant: "error"
        });
        this.dispatchEvent(event);
    }
   
}