import { LightningElement, wire, api } from "lwc";
import getLogActions from "@salesforce/apex/ASDAC_TaskCreateController.getLogActions";
import ASDAC_DisputeValue from "@salesforce/label/c.ASDAC_DisputeValue";
import ASDAC_SubjectLabel from "@salesforce/label/c.ASDAC_SubjectLabel";
import ASDAC_CreatedDate from "@salesforce/label/c.ASDAC_CreatedDate";
import ASDAC_ActionTaken from "@salesforce/label/c.ASDAC_ActionTaken";
import ASDAC_RefundValue from "@salesforce/label/c.ASDAC_RefundValue";
import ASDAC_ChargeAmount from "@salesforce/label/c.ASDAC_ChargeAmount";
import ASDAC_DisputeReason from "@salesforce/label/c.ASDAC_DisputeReason";
import ASDAC_NoTaskRecordsFoundMessage from "@salesforce/label/c.ASDAC_NoTaskRecordsFoundMessage";
import ASDAC_DescendingSortOrder from "@salesforce/label/c.ASDAC_DescendingSortOrder";
import ASDAC_CreatedDateAPI from "@salesforce/label/c.ASDAC_CreatedDateAPI";
import ASDAC_ActionIdLabel from "@salesforce/label/c.ASDAC_ActionIdLabel";

const COLS = [
  {
    label: ASDAC_ActionIdLabel,
    fieldName: 'logActionLink',
    type: 'url',
    typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
  },
  { label: ASDAC_SubjectLabel, fieldName: "subject" ,sortable: "true"},
  { label: ASDAC_ActionTaken, fieldName: "actionTaken" },
  { label: ASDAC_DisputeValue, fieldName: "disputeValue", type: "currency", cellAttributes: { alignment: 'left' }, },
  { label: ASDAC_DisputeReason, fieldName: "reason" }, 
  { label: ASDAC_RefundValue, fieldName: "refundValue", type: "currency", cellAttributes: { alignment: 'left' },},
  { label: ASDAC_ChargeAmount, fieldName: "chargeAmount", type: "currency", cellAttributes: { alignment: 'left' },},
  { label: ASDAC_CreatedDate, fieldName: "formattedCreatedDate"}
];
const SORT_ORDER = ASDAC_DescendingSortOrder;
const CREATED_DATE=ASDAC_CreatedDateAPI;

export default class AsdacOrderRelatedTaskDetailsCmp extends LightningElement {
  @api orderWrapper;
  cols = COLS;
  taskList = [];
  orderid;
  isRelatedActionsPresent = true;
  sortDirection=SORT_ORDER;
  sortBy=CREATED_DATE;

  get noRecordsFoundMessage(){
    return ASDAC_NoTaskRecordsFoundMessage+` `+ this.orderid;
  }

  connectedCallback() {
    this.orderid = this.orderWrapper.orderId;
  }

  @wire(getLogActions, { orderid: "$orderid"})
  fetchLogActionList({ error, data }) {
    if (data) {
      this.isRelatedActionsPresent = data.length > 0 ? true : false;
      if(data.length) {
        data = JSON.parse(JSON.stringify(data));
        data.forEach(res => {
            res.logActionLink = '/' + res.id;
            
        });
      }
      this.taskList = data;      
      this.error = undefined;
      this.sortLogActiondata(this.sortBy, this.sortDirection)
    } else if (error) {
      this.isRelatedActionsPresent = false;
      this.error = error;
      this.taskList = undefined;
    }
  }

  doSorting(event) { 
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortLogActiondata(this.sortBy, this.sortDirection);
}
  sortLogActiondata(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.taskList));
    let keyValue = (i) => {
      return i[fieldname];
    };
    let isReverse = direction === 'asc' ? 1: -1;
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ''; 
      y = keyValue(y) ? keyValue(y) : '';
    return isReverse * ((x > y) - (y > x));
    });
  this.taskList = parseData;
}
}