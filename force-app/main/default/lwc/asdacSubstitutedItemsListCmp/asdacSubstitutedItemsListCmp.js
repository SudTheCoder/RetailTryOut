import { api, LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class AsdacSubstitutedItemsListCmp extends LightningElement {
  @api orderWrapper;
  @api orderSubstitutedItems;
  @track flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
  @track showRefundGroceryModal = false;
  @track isOnCaseRecord = false;
  @track caseRecordId;
  subItems;
  orderItems
  @track isAllItemsRefundable = true;

  connectedCallback() {
    this.isGeorge = this.orderWrapper.sellingChannel === "GEORGE.COM" ? true : false;
    this.subItems = this.orderSubstitutedItems.map((ordItm) => ({...ordItm,quantity: Number(ordItm.quantity),isDiscounted: this.isDiscountValid(ordItm.discountedPrice,ordItm.totalPrice)}));
    this.orderItems = this.subItems;

    this.showItemTags();
  }

  isDiscountValid(discountedPrice,totalPrice) {
		return discountedPrice !== totalPrice;
	}

  all(event) {
    const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
    for (const toggleElement of toggleList) {
      toggleElement.checked = event.target.checked;
    }
    this.handleItemLevelCheckbox(null);
  }

  handleItemLevelCheckbox(event) {
		if(event?.target && !event?.target?.checked){
			const selectAllCheckbox = this.template.querySelector('.selectAllCls');
			selectAllCheckbox.checked = false;
		} else{
			let i = 0;
			const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
			for (const toggleElement of toggleList) {
				i = toggleElement.checked ? i + 1 : i;
			}
			const selectAllCheckbox = this.template.querySelector('.selectAllCls');
			selectAllCheckbox.checked = (i === toggleList.length) ? true : false;
		}
		let selectedLineIds = this.getSelectedLineIds();
		

		const refundItems = this.filterItems(selectedLineIds, "isGhsRefundDisabled");
		this.isAllItemsRefundable = refundItems.length === 0 ? true : false;
	
	}

  getSelectedLineIds() {
    return [...this.template.querySelectorAll("lightning-input")]
      .filter((element) => element.checked && element.dataset.value)
      .map((element) => element.dataset.value);
  }

  showItemTags(){
    for(let key of this.subItems){
      key.showTags = false;
      if(key.isNilPick){
          key.showTags = true;
      }
      if(key.isSubstitutedLine){
          key.showTags = true;
      }
      if(key.isPersonalisedPromotion){
          key.showTags = true;
      }
    }
  }

  //method to handle multi refund operation
  handleMultiRefund() {
    this.handleRefunds(this.getSelectedLineIds());
  }


   //method to handle individual item's refund
	handleRefund(event) {
    this.handleRefunds([event.target.value]);
  }

  //method which sets flow parameters for quick case logging
	setFlowVariable() {
		if (this.caseId === undefined || this.caseId === '' || this.caseId === null) {
			this.isOnCaseRecord = false;
			this.caseRecordId = '';
		}
		else {
			this.isOnCaseRecord = true;
			this.caseRecordId = this.caseId;
		}
	}

  //method to set the variables for flow
	setFlowInputVariables(resultGrocery, buttonActionNameGhs) {
		this.showRefundGroceryModal = true;
		this.flowInputVariables = [
			{ name: 'orderId', type: 'String', value: this.orderWrapper.orderId },
			{ name: 'customerId', type: 'String', value: this.orderWrapper.customerId },
			{ name: 'refundedItemListFromOrderDetail', type: 'String', value: JSON.stringify(resultGrocery) },
			{ name: 'isOnCaseRecord', type: 'Boolean', value: this.isOnCaseRecord },
			{ name: 'CaseRecordId', type: 'String', value: this.caseRecordId },
			{ name: 'buttonActionName', type: 'String', value: buttonActionNameGhs },	
      { name: 'isGeorgeOrNot', type: 'Boolean', value: this.isGeorge}
		];
	}

  //method to close the quick case logging modal once operation is completed.
  handleFlowStatusChange(event) {
    let refreshWindow = true;
		if (event.detail.status === 'FINISHED') {
			this.showRefundGroceryModal = false;
			const outputVariables = event.detail.outputVariables;
			for(let outputVar of outputVariables) {
				if(outputVar.name === 'exitButtonClicked'){
					refreshWindow = !(outputVar.value);
				}
			}
			if(refreshWindow){
				const refreshOrderEvent = new CustomEvent("refreshorder", { bubbles: true, composed: true });
				this.dispatchEvent(refreshOrderEvent);
			}
		}
	}

  filterItems(selectedLineIds, filterField){
    const selectedIds = new Set(selectedLineIds);
    const result = this.subItems.filter(oi => selectedIds.has(oi.lineId) && !oi[filterField]);
    return result;
  }

  handleRefunds(selectedLineIds) {
    if (selectedLineIds.length === 0) {
      this.showErrorToastMsg('No items to refund.');
    } else {
      this.setFlowVariable();
      const resultGhs = this.filterItems(selectedLineIds, "isGhsRefundDisabled");
      if (resultGhs.length > 0) {
                const { orgId, sellingChannel, addressInfo, orderId, customerId} = this.orderWrapper;	
				const order = { orgId, sellingChannel, addressInfo, orderId, customerId };
				order.orderLines = resultGhs.map((orderLine) => {	
					const returnOrderLine = Object.keys(orderLine).reduce((returnLine, key) => {	
						const value = orderLine[key];	
						if (typeof value != "object" && !Array.isArray(value)) {	
							returnLine[key] = value;	
						}	
						return returnLine;	
					}, {});	
					return returnOrderLine;	
				});
        this.setFlowInputVariables(order, 'REFUND');
      } else {
        this.showRefundGroceryModal = false;
        this.showErrorToastMsg('Selected Items are not available for Refund.');
      }
    }
  }
 
  showErrorToastMsg(pError) {
    const toEvt = new ShowToastEvent({
      title: "Error",
      variant: "error",
      message: pError
    });
    this.dispatchEvent(toEvt);
  }

  handleCloseModal(){
		this.showRefundGroceryModal = false;
	}

  handleSearchSubItemsGHS(event) {
    event.target.value = event.target.value.replace(/^[ A-Za-z0-9_@./#&+-]*$/.g, "");
    let regex = new RegExp(event.target.value.toLowerCase().replace(/[[\]*(){}+?.,\\^$|]/g, "\\$&"));

    this.orderItems = this.subItems.filter(
			row => regex.test(row.productDescription.toLowerCase()) || 
			regex.test(row.productId.toLowerCase()));
  }
}