import { LightningElement, api, track } from "lwc";
import excahngeReasonsLbl from "@salesforce/label/c.ASDAC_ExchangeReasonOptions";
import returnTypesLbl from '@salesforce/label/c.ASDAC_ReturnTypeOptions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {FlowNavigationNextEvent,FlowNavigationFinishEvent} from 'lightning/flowSupport';
import exchangeOrder from "@salesforce/apex/ASDAC_OrderController.exchangeOrder";
import APTCheckRequest from "@salesforce/apex/ASDAC_OrderController.createATPRequest";

export default class AsdacExchangeModalCmp extends LightningElement {
  @track isLoading = true;
  @api totalItems;
  @api itemsFromFlow;
  @api caseRecordId;
  @api availableActions = [];
  @api exitButtonClicked=false;
  @api refreshWindow=false;

  @api orderCancel;
  @track moreThanOne = false;
  @track isApplyAll;
  @track cancelReasons = [];
  @track exchangeItems;
  @track order;
  @track lineToQuantityMap;
  @track lineToReasonMap;
  @track lineToNotesMap;
  hasRendered = false;
  @track atpInventory;
  @track showQuantityorStockError = false;
  @api refundToCreateStr;

  get returnTypes() {
    return returnTypesLbl.split(/,/g).map((v) => {
      const label = v.trim();
      return { label, value: label };
    });
  }

  connectedCallback() {
    let tempString = this.itemsFromFlow;
    if(tempString){
      this.order = JSON.parse(tempString);
      this.exchangeItems = this.order.orderLines;
    }

    this.moreThanOne = false;
    const cancelReasonsList = excahngeReasonsLbl.split(",");
    for (const cancReason of cancelReasonsList) {
      this.cancelReasons = [
        ...this.cancelReasons,
        { label: cancReason.trim(), value: cancReason.trim() }
      ];
    }

    this.modifyExchangeList();
    this.isApplyAll = false;
    this.isLoading = false;
  }

  modifyExchangeList(){
    if(this.exchangeItems !== undefined) {
      this.exchangeItemsSizeCheck();
      for(let item of this.exchangeItems){
        item.style = (!item.quantity) ? "border: 2px solid #f00" : ''; 
        item.selectedQuantity = 1;
        if(item.isOutofStock || item.showStockWaring){
          this.showQuantityorStockError = true;
          item.style = "border: 2px solid #f00"; 
        }
      }
    }
  }

  exchangeItemsSizeCheck(){
    if(this.exchangeItems.length > 1){
      this.moreThanOne = true;
    }
  }

  removeRow(event) {
    this.showQuantityorStockError = false;
    this.exchangeItems.splice(event.target.dataset.index, 1);
    for (let item of this.exchangeItems) {
      if(item.isOutofStock || item.showStockWaring){
        this.showQuantityorStockError = true;
        item.style = "border: 2px solid #f00"; 
        break;
      }
    }
  }

  quantityChange(event){
    this.isLoading = true; 
    let index = event.target.dataset.index;
    this.exchangeItems[index].selectedQuantity= event.target.value;
    this.showQuantityorStockError = false; 
    this.inventoryItemCheck({ orderLines: this.exchangeItems }).then(() => {
      this.quantityPicklistSet();
      this.isLoading = false;
    })
  }
  
  inventoryItemCheck(order) {
    this.atpInventory = null;
    this.isLoading = true;
  
    return APTCheckRequest({ order })
      .then((data) => {  
        
        this.atpInventory = JSON.parse(data);
        const productQuantityMap = this.createProductQuantityMap(this.atpInventory);
        this.updateOrderItems(productQuantityMap);
      }).catch((err) => {
        let message;
        try {
          message = JSON.parse(err.body.message).message;
        } catch (e) {
          message = err.body.message;
        }
        const event = new ShowToastEvent({
          variant: "error",
          title: "Error",
          message
        });
        this.dispatchEvent(event);
        this.isLoading = false;  
      });
  }

  createProductQuantityMap(data) {
    const productQuantityMap = new Map();
    if (data && data.availabilityByProducts) {
      data.availabilityByProducts.forEach(atpData => {
        const productId = atpData.productId;
        const atp = atpData.availabilityByFulfillmentTypes[0].availabilityDetails[0].atp;
        productQuantityMap.set(productId, atp);
      });
    }
    return productQuantityMap;
  }

  updateOrderItems(productQuantityMap) {
    this.exchangeItems = this.exchangeItems.map(item => {
      let availableQuantity = 0;
        if (productQuantityMap && productQuantityMap.has(item.productId)) {
            availableQuantity = productQuantityMap.get(item.productId);
        }
      item.availableQuantity = availableQuantity;
      item.isOutofStock = availableQuantity <= 0;
      item.showStockWaring = availableQuantity > 0 && item.availableQuantity < item.selectedQuantity;
      if(item.availableQuantity >= item.selectedQuantity && !item.isOutofStock){
        item.showStockWaring = false;
        item.style = ''; 
      }
      else if(item.availableQuantity < item.selectedQuantity && item.availableQuantity!=0){
        item.showStockWaring = true;
        item.style = "border: 2px solid #f00"; 
        this.showQuantityorStockError = true;
      }
      if( item.isOutofStock|| item.showStockWaring){
        item.style = "border: 2px solid #f00"; 
        this.showQuantityorStockError = true;
      }
      return item;
    });
  }

  get removeDisabled() {
    return !(this.exchangeItems && this.exchangeItems.length > 1);
  }

  resolveValidityIssues(reasonValue, targetInput) {
    if (
      reasonValue !== undefined || reasonValue !== "" || reasonValue !== null
    ) {
      targetInput.setCustomValidity("");
      targetInput.reportValidity();
    }
  }

  NoteValidityIssues(notesValue, targetInput) {
    if (
      notesValue !== undefined || notesValue !== "" || notesValue !== null
    ) {
      targetInput.setCustomValidity("");
      targetInput.reportValidity();
    }
  }

  handleApplyAll(event) {
    if (event.target.checked) {
      this.isApplyAll = true;
      let reasonValue = this.template.querySelector(".oiMultiReasonCls").value;
      let notesValue = this.template.querySelector(".oiMultiNotesCls").value;

      if (notesValue !== undefined || notesValue !== "") {
        [...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
          input.value = notesValue;
          this.NoteValidityIssues(notesValue, input);        
        });
      }
      if (reasonValue && (reasonValue.toString() !== undefined || reasonValue.toString() !== "" || reasonValue.toString() !== null)) {
        [...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
          input.value = reasonValue;
          this.resolveValidityIssues(reasonValue, input);
        });
      }
    } else {
      this.isApplyAll = false;
    }
  }

  handleMultiReasonChange(event) {
    if (this.isApplyAll) {
      [...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
        input.value = event.target.value;
        this.resolveValidityIssues(event.target.value, input);
      });
    }
  }

  handleMultiNotesChange(event) {
    if (this.isApplyAll) {
      [...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
        input.value = event.target.value;
        this.NoteValidityIssues(event.target.value, input);
      });
    }
  }

  handleReasonChange(event) {
    this.resolveValidityIssues(event.target.value, event.target);
  }

  handleNotesChange(event) {
    this.NoteValidityIssues(event.target.value, event.target);
  }

  handleChange(event) {
    const index = Number(event.target.dataset.index);
    const field = event.target.name;
    this.exchangeItems[index][field] = event.target.value;
  }

  handleCancel() {
    this.exitButtonClicked=true;
    this.refreshWindow=false;
    this.flowNavigationEvents();
  }

  handleSubmit() {
    if (!this.exchangeItemsExists()) {
      return;
    }
    let isReasonValid = true;
    let requiredMessage = "Reason is required.";
    [...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
      if (!input.value) {
        isReasonValid = false;
        input.setCustomValidity(requiredMessage);
        input.reportValidity();
      }
    });
    [...this.template.querySelectorAll(".oiReturnTypeCls")].forEach((input) => {
      isReasonValid = input.reportValidity() && isReasonValid;
    });
    if (!isReasonValid) {
      return;
    }
    this.isLoading = true;
    this.inventoryItemCheck({ orderLines: this.exchangeItems })
    .then(() => {
      if (!this.showQuantityorStockError) {
        this.createExchange();
      }
      else{
        this.isLoading = false;
      }
    })
  }

  createExchange(){
    this.lineToQuantityMap = new Map();
    this.lineToReasonMap = new Map();
    this.lineToNotesMap = new Map();

    [...this.template.querySelectorAll(".Quantity")].forEach((input) => {
      this.lineToQuantityMap.set(
        input.dataset.id.toString(),
        input.value
      );
    });
    [...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
      this.lineToReasonMap.set(
        input.dataset.id.toString(),
        input.value.toString()
      );
    });
    [...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
      let noteValue =
        input.value !== undefined || input.value !== "" ? input.value : "";
        this.lineToNotesMap.set(input.dataset.id, noteValue);
    });

    const order = JSON.parse(this.itemsFromFlow);
    const updatedItems = this.exchangeItems.map(this.setInputs.bind(this));
    this.refundToCreateStr = JSON.stringify(updatedItems);
    order.orderLines = updatedItems.reduce((lines, ol) => {
      if (ol.isBundle) { // Send bundle children instead of bundle parent for Exchange
        const { fulfillmentType, fulfillmentService, promisedDeliveryDate, reason, notes, actionType} = ol;
        ol.bundleItems.forEach((bundleItem) => {
          Object.assign(bundleItem, { fulfillmentType, fulfillmentService, promisedDeliveryDate, reason, notes, actionType });
          lines.push(bundleItem);
        });
      } else {
        lines.push(ol);
      }
      return lines;
    }, []);

    exchangeOrder({ order })
      .then(() => {
        this.isLoading = false;
        this.flowNavigationEvents();
      })
      .catch((err) => {
        let message;
        try {
          message = JSON.parse(err.body.message).message;
        } catch (e) {
          message = err.body.message;
        }
        const event = new ShowToastEvent({
          variant: "error",
          title: "Error",
          message
        });
        this.dispatchEvent(event);
        this.isLoading = false;
      });
  }

  setInputs(orderLine) {
    const lineId = orderLine.lineId;
    // Get estimated delivery date based on Delivery type
    orderLine.fulfillmentType = 'DELIVERY';
    orderLine.fulfillmentService = 'STANDARD';
    orderLine.promisedDeliveryDate = new Date(Date.now() + (5 * 24 * 60 * 60 * 1000));
    orderLine.quantity = this.lineToQuantityMap.get(lineId);
    orderLine.reason = this.lineToReasonMap.get(lineId);
    orderLine.notes = this.lineToNotesMap.get(lineId);
    return orderLine;
  }

  flowNavigationEvents(){
    if(this.availableActions.find((action) => action === 'NEXT')){
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    } else if (this.availableActions.find((action) => action === 'FINISH')) {
      const navigateFinishEvent = new FlowNavigationFinishEvent();
      this.dispatchEvent(navigateFinishEvent);
      }
  }

  exchangeItemsExists() {
    if (!this.exchangeItems || !this.exchangeItems.length) {
      const toEvt = new ShowToastEvent({
        title: "Error",
        variant: "error",
        message: "No items to Exchange!"
      });
      this.dispatchEvent(toEvt);
      return false;
    }
    return true;
  }

  renderedCallback() {
    if (!this.hasRendered) {
      this.quantityPicklistSet();
      this.hasRendered = true;
    }
  }

  quantityPicklistSet(){
    const quantityRows= [...this.template.querySelectorAll(".Quantity")];
    quantityRows.forEach((row) => {
      const value = parseInt(row.dataset.value, 10);
      const lineId = row.dataset.id;
      const orderLineIndex = this.exchangeItems.findIndex(item => item.lineId === lineId);
      if (value === 1 || value === 0) {
        row.disabled = true;
      } else {
        row.disabled = false;
      }
      if (orderLineIndex !== -1) { 
        const selectedQuantity = this.exchangeItems[orderLineIndex].selectedQuantity;
        row.value = selectedQuantity.toString();
      }
      row.options = Array.from({ length: value }, (_, index) => {
        const optionValue = index + 1;
        return { label: `${optionValue}`, value: `${optionValue}` };
      });
    });
  }
}