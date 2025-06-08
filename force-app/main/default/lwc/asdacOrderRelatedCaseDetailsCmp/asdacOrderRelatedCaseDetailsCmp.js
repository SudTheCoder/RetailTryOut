import { LightningElement, track, wire, api } from "lwc";
import getcase from "@salesforce/apex/ASDAC_CaseSelector.getCase";
import ASDAC_CaseNumber from "@salesforce/label/c.ASDAC_CaseNumber";
import ASDAC_CaseRecordType from "@salesforce/label/c.ASDAC_CaseRecordType";
import ASDAC_ContactReasonLevel1 from "@salesforce/label/c.ASDAC_ContactReasonLevel1";
import ASDAC_ContactReasonLevel2 from "@salesforce/label/c.ASDAC_ContactReasonLevel2";
import ASDAC_WorkQueue from "@salesforce/label/c.ASDAC_WorkQueue";
import ASDAC_Status from "@salesforce/label/c.ASDAC_Status";
import ASDAC_CreatedDate from "@salesforce/label/c.ASDAC_CreatedDate";

const COLS = [
  {
    label: ASDAC_CaseNumber,
    fieldName: "recordLink",
    type: "url",
    typeAttributes: {
      label: { fieldName: "caseNumber" },
      tooltip: "CaseNumber",
      target: "_self"
    }
  },
  { label: ASDAC_CaseRecordType, fieldName: "recordTypeName" },
  { label: ASDAC_ContactReasonLevel1, fieldName: "contactReasonLevel1" },
  { label: ASDAC_ContactReasonLevel2, fieldName: "contactReasonLevel2" },
  { label: ASDAC_WorkQueue, fieldName: "workQueue" },
  { label: ASDAC_Status, fieldName: "status" },
  { label: ASDAC_CreatedDate, fieldName: "formattedCreatedDate" }
];
export default class AsdacOrderRelatedCaseDetails extends LightningElement {
  @track data;
  @api recordId;
  cols = COLS;
  error;
  @track caseList = [];
  @track orderid = "";
  @api orderWrapper;
  connectedCallback() {
    this.orderid = this.orderWrapper.orderId;
  }

  @wire(getcase, { orderid: "$orderid" })
  getcaseList({ error, data }) {
    if (data) {
      let tempcaseList = [];
      for (let row of data) {
        let tempRecord = Object.assign({}, row);
        tempRecord.recordLink = "/" + tempRecord.id;
        tempcaseList.push(tempRecord);
      }
      this.caseList = tempcaseList;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.caseList = undefined;
    }
  }
}