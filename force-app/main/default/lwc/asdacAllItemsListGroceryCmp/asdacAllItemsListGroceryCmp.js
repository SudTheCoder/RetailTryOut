import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ASDAC_OmsGroceryDeliveryAddressLabel from "@salesforce/label/c.ASDAC_OmsGroceryDeliveryAddressLabel";
import ASDAC_OmsGroceryDeliveryFulfilmentLabel from "@salesforce/label/c.ASDAC_OmsGroceryDeliveryFulfilmentLabel";
import ASDAC_OmsGroceryCollectionAddressLabel from "@salesforce/label/c.ASDAC_OmsGroceryCollectionAddressLabel";
import ASDAC_OmsGroceryCollectionFulfilmentLabel from "@salesforce/label/c.ASDAC_OmsGroceryCollectionFulfilmentLabel";
import ASDAC_OmsGroceryCollectionLabel from "@salesforce/label/c.ASDAC_OmsGroceryCollectionLabel";
import ASDAC_OmsGroceryDeliveryLabel from "@salesforce/label/c.ASDAC_OmsGroceryDeliveryLabel";

export default class AsdacAllItemsGroceryCmp extends LightningElement {
    @api orderWrapper;
    @api selectedLineItemIdList = [];
    @track orderItems;
    @track flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
    @track showRefundGeorgeModal = false;
    @track caseRecordId;
    @track isOnCaseRecord = false;
    @track isAllItemsShown = true;
    @track allUnavailableItemsLabel;
    @track isModalOpenFullFillmentHeader;
	@track progressStep1;
	@track progressStep2;
    @track isAllItemsRefundable = true;
    ghsOrderId = 'AP-202205160032'; //for NF UI can be removed later
	isModalVisible = false;
	isGrocery = false;
	orderItemsSearchNotFound = false;
	@track originalOrderItems;

    connectedCallback() {
        this.originalOrderItems = this.orderWrapper.orderItems.filter(ordItm => !ordItm.isCharitableProduct).map((ordItm, index) => ({ ...ordItm, quantity: Number(ordItm.quantity),isDiscounted: this.isDiscountValid(ordItm.discountedPrice, ordItm.totalPrice) }));
		this.orderItems = this.originalOrderItems;	
		this.showItemTags();
        this.isGeorge = (this.orderWrapper.sellingChannel === "GEORGE.COM") ? true : false;
		this.isGrocery = (this.orderWrapper.sellingChannel === "ASDA_GROCERIES") ? true : false;
		this.getprogress();
    }

	isDiscountValid(discountedPrice,totalPrice) {
		return discountedPrice !== totalPrice;
	}

    get categoryMap() {
        const categories = [];
        const categoryMap = {};
        this.orderItems.forEach(oi => {
            if (!categoryMap[oi.productType]) {
                categoryMap[oi.productType] = [];
                categories.push(oi.productType);
            }
            categoryMap[oi.productType].push(oi);
        });
		let categoriesModified = categories.map(key => {
			const modifiedKey = this.capitalize(key);

			const item={
				key: modifiedKey,
				value: categoryMap[key]
			}
			return item;
		})
		return categoriesModified;        
    }

	get flagBoolean(){
		let flag;
		if(this.orderWrapper.progressDot === 2){
			flag = true;
		}
		else{
			flag = false;
		}
		return flag;
	}

	capitalize(str) {
		return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
	}

   getprogress() {
        const progress = Array(2).fill(0).map((v, i) => ({ value: i + 1 }));
		if(this.orderWrapper.status != null){
			progress[this.orderWrapper.progressDot - 1].label = this.orderWrapper.status;
			this.progressStep1 = progress[0].label;
			this.progressStep2 = progress[1].label;
		}
   	}

	showItemTags(){
		for(let key of this.originalOrderItems){
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

	get isRefundDisabled() {
		return (this.orderItems || []).every(orderItem => orderItem.isGhsRefundDisabled);
	}

    selectallGHS(event) {
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
		const refundItems = this.getfilterItems(selectedLineIds, "isGhsRefundDisabled");
		this.isAllItemsRefundable = refundItems.length === 0 ? true : false;
    }

    handleSearchItemsGHS(event) {
        event.target.value = event.target.value.replace(/^[ A-Za-z0-9_@./#&+-]*$/.g, "");
        let regex = new RegExp(event.target.value.toLowerCase().replace(/[[\]*(){}+?.,\\^$|]/g, "\\$&"));

		this.orderItems = this.originalOrderItems.filter(
			row => regex.test(row.productDescription.toLowerCase()) || 
			regex.test(row.productId.toLowerCase()));

		this.orderItemsSearchNotFound = this.orderItems.length === 0;
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

	//method to close the quick case logging modal once operation is completed.
	handleFlowStatusChange(event) {
		let refreshWindow = true;
		if (event.detail.status === 'FINISHED') {
			this.showRefundGeorgeModal = false;
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

	//method to set the variables for flow
	setFlowInputVariables(result, buttonActionName) {
		this.showRefundGeorgeModal = true;
		this.flowInputVariables = [
			{ name: 'orderId', type: 'String', value: this.orderWrapper.orderId },
			{ name: 'customerId', type: 'String', value: this.orderWrapper.customerId },
			{ name: 'refundedItemListFromOrderDetail', type: 'String', value: JSON.stringify(result) },
			{ name: 'isOnCaseRecord', type: 'Boolean', value: this.isOnCaseRecord },
			{ name: 'CaseRecordId', type: 'String', value: this.caseRecordId },
			{ name: 'buttonActionName', type: 'String', value: buttonActionName },	
			{ name: 'isGeorgeOrNot', type: 'Boolean', value: this.isGeorge}
		];
		if (this.orderWrapper.isExchangeOrder) {
			this.flowInputVariables.push({ name: 'isExchangeOrder', type: 'Boolean', value: this.orderWrapper.isExchangeOrder });
		}
		if ( this.orderWrapper.salesOrderId) {
			this.flowInputVariables.push({ name: 'salesOrderId', type: 'String', value: this.orderWrapper.salesOrderId });
		}
	}

	getSelectedLineIds() {
		return [...this.template.querySelectorAll('lightning-input')]
			.filter(element => element.checked && element.value)
			.map(element => Number(element.value));
	}

	getfilterItems(selectedLineIds, filterField){
		const selectedIds = new Set(selectedLineIds);
		const result = this.orderItems.filter((oi) => {
			return selectedIds.has(oi.orderLineId) && !oi[filterField]
		})
		return result;
	}

	handleRefunds(selectedLineIds) {
		if (selectedLineIds.length === 0) {
			this.showErrorToast('No items to refund.');
		} 
		else {
			this.setFlowVariable();
			const result = this.getfilterItems(selectedLineIds, "isGhsRefundDisabled");
			if (result.length > 0) {
				const { orgId, sellingChannel, addressInfo, orderId, customerId,currencyISOCode} = this.orderWrapper;	
				const order = { orgId, sellingChannel, addressInfo, orderId, customerId,currencyISOCode };	
				order.orderLines = result.map((orderLine) => {	
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
			} 
			else {
				this.showRefundGeorgeModal = false;
				this.showErrorToast('Selected Items are not available for Refund.');
			}
		}
	}

	handleCloseModal(event){
		this.showRefundGeorgeModal = false;
	}

	//method to handle multi refund/return-refund operation
	handleMultiRefund() {
		this.handleRefunds(this.getSelectedLineIds());
	}

	//method to handle individual item's refund/return-refund
	handleRefund(event) {
        this.handleRefunds([Number(event.target.value)]);
	}

   
    //method to handle showing toast message
	showErrorToast(pError) {
		const toEvt = new ShowToastEvent({
			title: "Error",
			variant: "error",
			message: pError
		});
		this.dispatchEvent(toEvt);
	}

	get isDelivery() {
		return this.orderWrapper.orderFulfilmentTypeGrocery.toLowerCase() === "home delivery" || this.orderWrapper.orderFulfilmentTypeGrocery.toLowerCase() === "express delivery";
	}

	get shippingAddressLabel() {
		return this.isDelivery ? ASDAC_OmsGroceryDeliveryAddressLabel : ASDAC_OmsGroceryCollectionAddressLabel;
	}

	get fulfilmentStoreLabel() {
		return this.isDelivery ? ASDAC_OmsGroceryDeliveryFulfilmentLabel : ASDAC_OmsGroceryCollectionFulfilmentLabel;
	}

	get deliveryOrPickupLabel(){
		return this.isDelivery ? ASDAC_OmsGroceryDeliveryLabel : ASDAC_OmsGroceryCollectionLabel;
	}

    handleOpenModalHeader() {
        this.isModalOpenFullFillmentHeader = true;
    }
    closeModal() {
        this.isModalOpenFullFillmentHeader = false;
    }

    handleTrackingDetailsGHS() {
        this.isModalVisible = true;
    }

    handleCloseTrackingDetailsModal(event) {
        this.isModalVisible = event.detail;
    }
}