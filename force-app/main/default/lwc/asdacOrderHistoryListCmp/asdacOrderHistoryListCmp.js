import { LightningElement, api, track } from "lwc";
import getCustomerId from "@salesforce/apex/ASDAC_OrderController.getCustomerId";
import getOrders from "@salesforce/apex/ASDAC_OrderController.getOrders";
import getOrderHistoryFields from "@salesforce/apex/ASDAC_OrderController.getOrderHistoryFields";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from "lightning/platformResourceLoader";
import ASDAC_OrderHistoryIdField from "@salesforce/label/c.ASDAC_OrderHistoryIdField";
import ASDAC_OrderHistoryInitialSortField from "@salesforce/label/c.ASDAC_OrderHistoryInitialSortField";
import ASDAC_OrderHistoryInitialSortOrder from "@salesforce/label/c.ASDAC_OrderHistoryInitialSortOrder";
//Import Resources
import HideLightningHeader from "@salesforce/resourceUrl/ASDAC_CustomerDetails";

const ORDER_ID_FIELD = ASDAC_OrderHistoryIdField;
const INITIAL_SORT_FIELD = ASDAC_OrderHistoryInitialSortField;
const INITIAL_SORT_ORDER = ASDAC_OrderHistoryInitialSortOrder;

const DEBOUNCE_DELAY = 300;

const COLUMN_HEADER_CLASS = "slds-grid slds-gutters slds-grid_vertical-align-center slds-has-flexi-truncate ";
const COLUMN_VALUE_CLASS = "slds-cell-wrap ";
const COL_HEADER_ALIGN_RIGHT = 'slds-grid_align-end'; 
const COL_HEADER_ALIGN_LEFT = 'slds-grid_align-start'; 
const COL_VAL_ALIGN_RIGHT = 'slds-text-align_right';
const COL_VAL_ALIGN_LEFT = 'slds-text-align_left';


export default class AsdacOrderHistoryListCmp extends LightningElement {
    @api recordId;
    @track error;
    @track orders;
    @api sellingChannel;

    loading = true;

    connectedCallback() {
        loadStyle(this, HideLightningHeader);

        this.init();
    }

    async init() {
        try {
            await Promise.all([this.storeCustomerId(), this.storeOrderHistoryFields()]);
            this.getOrderHistory();
        } catch (err) {
            this.handleError(err);
        }
    }

    storeCustomerId() {
        return getCustomerId({ personAccountId: this.recordId }).then((customerId) => {
            if (this.sellingChannel === "ASDA_GROCERIES") {
                this.filter = {
                    orgId: { "=": "ASDA" },
                    customerId: { "=": customerId },
                    orderType: { "=": "SalesOrder" },
                    sellingChannel: { "=": this.sellingChannel },
                    orderModel: {"=!":"DELIVERY_PASS"}
                };
            } else {
                this.filter = {
                    orgId: { "=": "ASDA" },
                    customerId: { "=": customerId },
                    orderType: { "=": "SalesOrder" },
                    orderCategory: { "=": "eComm" },
                    sellingChannel: { "=": this.sellingChannel }
                };
            }
        });
    }

    storeOrderHistoryFields() {
        return getOrderHistoryFields().then((data) => {
            const cols = data
                .map((col) => {
                    const column = {};
                    Object.keys(col).forEach((key) => {
                        const value = col[key];
                        const newKey = key
                            .replace("__c", "")
                            .replace(/_+/gi, "_")
                            .replace(/_[a-z]/gi, (s) => s.replace(/_/g, "").toUpperCase())
                            .replace(/^[a-z]/gi, (s) => s.toLowerCase());
                        column[newKey] = value;
                    });
                    column.isIdField = column.developerName === ORDER_ID_FIELD;
                    column.class = COLUMN_HEADER_CLASS + (column.columnAlignment === 'Right' ? COL_HEADER_ALIGN_RIGHT : COL_HEADER_ALIGN_LEFT);
                    column.filterId = column.id + "_filter";
                    column.filterText = false;
                    if (column.filterField) {
                        if ((column.filterType || "").toUpperCase() === "DATE") {
                            column.filterDate = true;
                        } else {
                            column.filterText = true;
                        }
                    }
                    column.sortable = !!column.sortField;
                    return column;
                })
                .sort((a, b) => a.position - b.position);
            
            this.columns = cols;
            const index = cols.findIndex((col) => col.sortable && col.developerName === INITIAL_SORT_FIELD);
            if (index >= 0) {
                this.sortColumnIndex = index;
            }
        });
    }

    getOrderHistory() {
        this.loading = true;
        this.error = false;
        const { filters, sortFields, pageNumber, pageSize } = this;
        const option = { filters, sortFields, pageNumber, pageSize };
        getOrders({ option })
            .then((data) => {
                this.totalRecCount = data.totalCount;
                this.totalPage = Math.ceil(data.totalCount / this.pageSize) || 1;
                this.startingRecord = data.totalCount ? data.startIndex + 1 : 0;
                this.endingRecord = data.startIndex + data.data.length;

                this.orders = data.data;
                this.loading = false;
            })
            .catch(this.handleError.bind(this));
    }

    timeoutId;
    debounce(callback = () => {}, immediate = false) {
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(callback, immediate ? 0 : DEBOUNCE_DELAY);
    }

    @track columns = [];

    @track filter;

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

    onFilterChange(event) {
        const { field, op } = event.target.dataset;
        const value = event.target.value;
        if (!value) {
            delete (this.filter[field] || {})[op];
        } else {
            const ops = { ...this.filter[field], [op]: value };
            this.filter[field] = ops;
        }
        this.debounce(() => {
            this.pageNumber = 1;
            this.getOrderHistory();
        });
    }

    onOrderNumClick(event) {
        const index = event.target.dataset.index;
        const order = this.orders[index];
        event.preventDefault();
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent("openorder", {
                detail: {
                    orderId: order.orderId,
                    businessArea: order.sellingChannel
                }
            })
        );
    }

    sortColumnIndex;
    isAscSort = INITIAL_SORT_ORDER.toUpperCase() !== "DESC";

    get sortFields() {
        if (typeof this.sortColumnIndex === "number") {
            return this.columns[this.sortColumnIndex].sortField.replace("{}", this.isAscSort ? "asc" : "desc");
        }
        return "";
    }

    onSort(event) {
        const index = Number(event.currentTarget.dataset.index);
        if (!this.columns[index].sortable) {
            return;
        }
        this.sortColumnIndex = index;
        this.isAscSort = !this.isAscSort;
        this.debounce(() => {
            this.pageNumber = 1;
            this.getOrderHistory();
        });
    }

    @track pageNumber = 1;
    @api pageSize = 10;
    @track totalPage = 1;
    @track totalRecCount = 0;
    @track startingRecord = 0;
    @track endingRecord = 0;

    get disablePrevious() {
        return this.pageNumber <= 1;
    }
    get disableNext() {
        return this.pageNumber >= this.totalPage;
    }

    onPrev() {
        this.debounce(() => {
            this.pageNumber -= 1;
            this.getOrderHistory();
        }, true);
    }
    onNext() {
        this.debounce(() => {
            this.pageNumber += 1;
            this.getOrderHistory();
        }, true);
    }

    get data() {
        if (!this.orders) {
            return [];
        }
        const idPrefix = window.crypto.randomUUID();
        return this.orders.map((row, rowIndex) => {
            const rowId = `${idPrefix}_${rowIndex}`;
            return {
                id: rowId,
                data: this.columns.map((col, colIndex) => {
                    const cell = {
                        id: `${rowId}_${colIndex}`,
                        value: row[col.fieldName],
                        isIdField: col.isIdField,
                        class: COLUMN_VALUE_CLASS + (col.columnAlignment === 'Right' ? COL_VAL_ALIGN_RIGHT : COL_VAL_ALIGN_LEFT)
                    };

                    if (cell.isIdField) {
                        cell.url = `/lightning/cmp/c__ASDAC_DisplayOrdersCmp?uid=${cell.value}&c__businessArea=${row.sellingChannel}`;
                    }
                    return cell;
                })
            };
        });
    }

    get noOrders() {
        return !this.error && this.data.length === 0;
    }

    getError(err) {
        let error = err;
        if (err.body) {
            try {
                error = JSON.parse(err.body.message);
            } catch(e) {
                error = err.body;
            }
        }
        return error;
    }

    handleError(error) {
        let message = this.getError(error).message;
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