// Import LWC
import { api, LightningElement, track } from 'lwc';
//Import Libraries
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import APTCheckRequest from "@salesforce/apex/ASDAC_OrderController.createATPRequest";

//Start LWC JS
export default class AsdacAllItemsListCmp extends LightningElement {
	//All the Order related details
    @api orderWrapper;
	//Flow for Quick Case logging
    @track flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
	//Flag to open/hide quick case logging
    @track showRefundGeorgeModal = false;
	//instance basically used for Search and display the items on screen
    @track orderItems;
	//passes case Id from case if opened from Case
    @api caseId;
	//indicates if component is opened from Case
    @track isOnCaseRecord;
	//Holds the case record Id if opened from Case layout
    @track caseRecordId = '';

    @api fulfillKey;
    @api fulfillOdrItem;

	@track fulfillMap=[];
    @track isModalOpen = false;
    @track itemNameHelpTextContent;
	@track progressBarSteps=[];
    @track currentStep;
    @track progressError = false;
	@track allDone=false;
    @track stepsMoreThanOne;
    @track cancelledState = 'CANCELLED';
    @track isOrderCancelled;
    @track isAllItemsExchangable = true;
    lstshipmentrecords = [];
    @track isGeorge;
    @track atpInventory;
    @track isAllItemsRefundable = true;
    @track isAllItemsDiscountable = true;
    @track lineItemNameForTrackingDetail;
    @track shippingAddressForTrackingDetail;
    @track categoryMap = [];  // Grouped items by category

    bundleMap = {};

	//Connected callback to set variables on load
    connectedCallback() {
        this.isGeorge = (this.orderWrapper.sellingChannel === "GEORGE.COM") ? true : false;
        this.orderItems = JSON.parse(JSON.stringify(this.orderWrapper.orderItems));
        this.orderItems.forEach(item => {
            item.quantity = Number(item.quantity);
        });
        this.itemNameHelpTextContent  = "UPC: 5059191242459, Size: 14-16L, Colour: Black, Warranty: 2 year manufacturer warranty, Warranty End Date: 26 Aug 2024 12:00am";
        this.generateBundleMap();
         
    // Group items by productType (or change the grouping as needed)
        let catMap = {};
        this.orderItems.forEach(item => {
            let cat = item.productType || 'Uncategorized';
            if (!catMap[cat]) {
                catMap[cat] = [];
            }
            catMap[cat].push(item);
        });
        this.categoryMap = Object.keys(catMap).map(key => {
            return { key: key, value: catMap[key] };
        });

        if(this.orderWrapper.orderLevelFulfilmentType === 'Collect'){
			this.progressBarSteps = [{key:'Placed', value:true},{key:'Preparing', value:true},{key:'Ready to Collect', value:true},{key:'Picked Up', value:true}];
            this.currentStep = 'Ready to Collect';
        }
        else{
			this.progressBarSteps = [{key:'Placed', value:true},{key:'Preparing', value:true},{key:'On the way', value:false},{key:'Delivered', value:true}];
            this.currentStep = 'On the way';
        }

        if(this.orderWrapper.orderId === 'AD-20230526101'){
			this.progressBarSteps = [{key:'Order Cancelled', value:false}];
        }

        this.noOfSteps = this.progressBarSteps.length;
		if(this.progressBarSteps.length>1){
			this.stepsMoreThanOne = true
		}
		else{
			this.stepsMoreThanOne = false;
		}
    }

    generateBundleMap() {
        const bundleMap = this.orderWrapper.orderItems.reduce((map, ordItm) => {
            if (ordItm.parentId) {
                // Map to bundle child item to parentId
                if (!map[ordItm.parentId]) {
                    map[ordItm.parentId] = {};
                }
                // Merge bundle child items based on orderLineId
                if (!map[ordItm.parentId][ordItm.orderLineId]) {
                    map[ordItm.parentId][ordItm.orderLineId] = { ...ordItm };
                } else {
                    map[ordItm.parentId][ordItm.orderLineId].quantity += ordItm.quantity;
                }
            }
            return map;
        }, {});

        this.bundleMap = Object.keys(bundleMap).reduce((map, parentId) => {
            // Convert the map of orderLineId to orderLine to array of orderLines
            map[parentId] = Object.values(bundleMap[parentId]);
            return map;
        }, {});
    }

    addError() {
        this.progressError = true;
    }
    removeError() {
        this.progressError = false;
    }

	passwordHintClass = "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide"
    togglePasswordHint() {
		this.passwordHintClass = this.passwordHintClass === 'slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide' ? "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-rise-from-ground" : "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide"
    }

	//method to handle select all items functionality
    selectall(event) {
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
        const exchangeItems = this.filterItems(selectedLineIds, "isExchangeDisabled");
        const inStockItems = exchangeItems.filter(element => !element.isOutofStock);

		if(inStockItems.length === 0){
            this.isAllItemsExchangable = true;
		}else{
            this.isAllItemsExchangable = false;
        }

        const refundItems = this.filterItems(selectedLineIds, "isRefundDisabled");
        this.isAllItemsRefundable = refundItems.length === 0 ? true : false;

        const discountItems = this.filterDiscountItems(selectedLineIds, "isDiscountDisabled");
        this.isAllItemsDiscountable = discountItems.length === 0 ? true : false;
    }

	//method to handle searching the line items
    handleSearchItems(event) {
        event.target.value = event.target.value.replace(/^[ A-Za-z0-9_@./#&+-]*$/.g, "");
        let regex = new RegExp(event.target.value.toLowerCase().replace(/[[\]*(){}+?.,\\^$|]/g, "\\$&"));

        this.orderItems = this.orderWrapper.orderItems.filter(
            row => regex.test(row.productDescription.toLowerCase()) ||
			regex.test(row.productId.toLowerCase()));
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
            { name: 'fulfilmentType', type: 'String', value: this.orderWrapper.orderFulfilmentType },
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

    // Returns an array of selected lineId strings from checkboxes
    getSelectedLineIds() {
        const checkboxes = this.template.querySelectorAll('[data-id="toggle"]');
        let selected = [];
        checkboxes.forEach(cb => {
            if (cb.checked && cb.dataset.value) {
                selected.push(cb.dataset.value);
            }
        });
        return selected;
    }

    filterItems(selectedLineIds, filterField) {
        const selectedSet = new Set(selectedLineIds);
        return this.orderItems.filter(oi => selectedSet.has(oi.lineId) && !oi[filterField]);
    }

    filterDiscountItems(selectedLineIds, filterField) {
        const selectedSet = new Set(selectedLineIds);
        return this.orderItems.filter(oi => selectedSet.has(oi.lineId) && !oi[filterField] && oi.isBundle === false);
    }
    
    handleRefunds(selectedLineIds) {
        if (selectedLineIds.length === 0) {
            this.showErrorToast('No items to refund.');
        } else {
            this.setFlowVariable();
            const result = this.filterItems(selectedLineIds, "isRefundDisabled");
            if (result.length > 0) {
                const { orgId, sellingChannel, orderId, customerId, currencyISOCode, orderFulfilmentType, fulfillmentService } = this.orderWrapper;
                const order = { orgId, sellingChannel, orderId, customerId, currencyISOCode, orderFulfilmentType, fulfillmentService };
                order.orderLines = result.map(orderLine => {
                    let returnOrderLine = {};
                    Object.keys(orderLine).forEach(key => {
                        let value = orderLine[key];
                        if (typeof value !== "object" && !Array.isArray(value)) {
                            returnOrderLine[key] = value;
                        }
                    });
                    if (returnOrderLine.isBundle) {
                        returnOrderLine.bundleItems = this.bundleMap[orderLine.orderLineId];
                    }
                    return returnOrderLine;
                });
                this.setFlowInputVariables(order, 'REFUND');
            } else {
                this.showRefundGeorgeModal = false;
                this.showErrorToast('Selected Items are not available for Refund.');
            }
        }
    }

	//method to handle multi refund/return-refund operation
    handleMultiRefund() {
        this.handleRefunds(this.getSelectedLineIds());
    }

	//method to handle individual item's refund/return-refund
    handleRefund(event) {
        let lineId = event.target.dataset.value;
        console.log("Refund button clicked for lineId:", lineId);
        this.handleRefunds([lineId]);
    }

    handleExchanges(selectedLineIds) {
        if (selectedLineIds.length === 0) {
            this.showErrorToast('No items to exchange.');
        } else {
            this.setFlowVariable();
            const result = this.filterItems(selectedLineIds, "isExchangeDisabled");
            if (result.length > 0) {
				const { orgId, sellingChannel, orderId, customerId, eVouchersAsDiscount, billToAddress, billToContact,fulfillmentService } = this.orderWrapper;
				const order = { orgId, sellingChannel, orderId, customerId,fulfillmentService,eVouchersAsDiscount };
                order.addressInfo = [
                    {
                        "contact": billToContact,
						"address":billToAddress,
                        "isActive": true,
                        "type": "billTo"
                    }
                ];
                order.orderLines = result.map(orderLine => {
                    let exchangeOrderLine = {};
                    Object.keys(orderLine).forEach(key => {
                        let value = orderLine[key];
                        if (typeof value !== "object" && !Array.isArray(value)) {
                            exchangeOrderLine[key] = value;
                        }
                    });
                    exchangeOrderLine.shipToContact = orderLine.shipToContact;
                    exchangeOrderLine.shipToAddress = orderLine.shipToAddress;
                    if (exchangeOrderLine.isBundle) {
                        exchangeOrderLine.bundleItems = this.bundleMap[orderLine.orderLineId];
                    }
                    return exchangeOrderLine;
                });

                this.inventoryItemCheck(order);
            } else {
                this.showexchangeModal = false;
                this.showErrorToast('Items seem to be already exchanged.');
            }
        }
    }

    // --- Updated Individual Exchange Handler ---
    // Marked as async so we can await the ATP (inventory) check.
    async handleExchange(event) {
        let lineId = event.target.dataset.value;
        console.log("Exchange button clicked for lineId:", lineId);
        // Find the corresponding item from orderItems.
        const item = this.orderItems.find(itm => itm.lineId === lineId);
        if (!item) return;
        
        // Construct an order for just this item.
        const { orgId, sellingChannel, orderId, customerId, eVouchersAsDiscount, billToAddress, billToContact, fulfillmentService } = this.orderWrapper;
        let order = { orgId, sellingChannel, orderId, customerId, fulfillmentService, eVouchersAsDiscount };
        order.addressInfo = [{
            "contact": billToContact,
            "address": billToAddress,
            "isActive": true,
            "type": "billTo"
        }];
        // Use this single item as the order line.
        order.orderLines = [item];
        
        // Run the ATP check for this item.
        await this.inventoryItemCheck(order);
        
        // Re-read the updated item.
        const updatedItem = this.orderItems.find(itm => itm.lineId === lineId);
        if (updatedItem && updatedItem.isOutofStock) {
            // If now marked as out of stock, show a toast message.
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Out of Stock',
                    variant: 'error',
                    message: 'The selected item is out of stock and cannot be exchanged.'
                })
            );
            return;
        }
        // Otherwise, proceed with the regular exchange process.
        this.handleExchanges([lineId]);
    }
    // --- End Updated Individual Exchange Handler ---


	async inventoryItemCheck(order){
        try {
			this.atpInventory=null;
			let inventoryString = await APTCheckRequest({order :order});
            this.atpInventory = JSON.parse(inventoryString);
        }
        catch (error) {
            let message;
            try {
                message = JSON.parse(error.body.message).message;
			}catch (e) {
                message = error.body.message;
            }
            const event = new ShowToastEvent({
                variant: "error",
                title: "Error",
                message
            });
            this.dispatchEvent(event);
        }
        this.modifyExchangeList(order);
    }

	modifyExchangeList(order){
		if(order !== undefined) {
            let isAllItemsOutOfStock = this.compareATPData(order);
			if(!isAllItemsOutOfStock){
                this.setFlowInputVariables(order, 'EXCHANGE');
            }
			else{
                this.isAllItemsExchangable = true;
            }
        }
        this.updateOrderLines(order);
    }

	compareATPData(order){
        let isAllItemsOutOfStock = this.isAllItemsOutOfStock();
		if(!isAllItemsOutOfStock){
			for(let item of order.orderLines){
				if(!item.isExchangeDisabled){
					if(this.atpInventory != null && this.atpInventory.availabilityByProducts.length>0){
                        this.updateATPData(item);
                    }
					else{
                        item.isOutofStock = true;
                    }
                }
            }
        }
        return isAllItemsOutOfStock;
    }

	updateATPData(item){
        item.isOutofStock = true;
		for(let key of this.atpInventory.availabilityByProducts){
			if(key.productId === item.productId){
                item.availableQuantity = key.availabilityByFulfillmentTypes[0].availabilityDetails[0].atp;  
                item.isOutofStock = this.exchangeisOutofStockCheck(key.availabilityByFulfillmentTypes); 
                break;
            }
        }
        return item;
    }
    
	updateOrderLines(order){
        let itemsList = JSON.parse(JSON.stringify(this.orderItems));
		for(let item of itemsList){
			if(!item.isExchangeDisabled){
				for(let canItem of order.orderLines){
					this.updateItems(item,canItem);
                }
            }
        }
        this.orderItems = itemsList;
    }

	updateItems(item,canItem){
		if(this.atpInventory != null && this.atpInventory.availabilityByProducts.length>0){
			for(let key of this.atpInventory.availabilityByProducts){
				this.returnItemsOnUpdate(key,item,canItem);
            }
        }
		else if(item.productId === canItem.productId && !item.isExchangeDisabled){
            this.itemOutOfStock(item);
        }
    }

	returnItemsOnUpdate(key,item,canItem){
		if(key.productId === item.productId && item.productId === canItem.productId && !item.isExchangeDisabled){
            item.isOutofStock = this.exchangeisOutofStockCheck(key.availabilityByFulfillmentTypes); 
            item.style = (item.isOutofStock) ? "border: 2px solid #f00" : ''; 
        }
		else if(item.productId === canItem.productId && item.isExchangeDisabled){
            this.itemOutOfStock(item);
        }
    }

	itemOutOfStock(item){
        item.isOutofStock = true;
        item.style = "border: 2px solid #f00"; 
    }

	isAllItemsOutOfStock(){
		let isAllItemsOutOfStock = false;
		if(this.atpInventory === null){
			isAllItemsOutOfStock = true;
		}
		return isAllItemsOutOfStock;
    }

	exchangeisOutofStockCheck(val){
        let outofstock = false;
		for(let key of val){
			if(key.fulfillmentType ==='DELIVERY'){
				outofstock = (key.availabilityDetails[0].atp === 0) ? true : false;
            }
        }
        return outofstock;
    }


	//method to handle multi replace/exchange operation
    handleMultiExchange() {
        this.handleExchanges(this.getSelectedLineIds());
    }

    handleDiscounts(selectedLineIds) {
        if (selectedLineIds.length === 0) {
            this.showErrorToast('No item to partial refund.');
        } else {
            this.setFlowVariable();
            const result = this.filterDiscountItems(selectedLineIds, "isDiscountDisabled");
            if (result.length > 0) {
                const { orgId, sellingChannel, orderId } = this.orderWrapper;
                const order = { orgId, sellingChannel, orderId };
                order.orderLines = result;
                this.setFlowInputVariables(order, 'PARTIAL REFUND');
            } else {
                this.showexchangeModal = false;
                this.showErrorToast('Selected Items are not available for partial refund.');
            }
        }
    }

	//method to handle multi discount/partial refund operation
    handleMultiDiscount() {
        this.handleDiscounts(this.getSelectedLineIds());
    }

	//method to handle individual item's discount/partial refund
    handleDiscount(event) {
        let lineId = event.target.dataset.value;
        console.log("Partial Refund button clicked for lineId:", lineId);
        this.handleDiscounts([lineId]);
    }

    showErrorToast(pError) {
        const evt = new ShowToastEvent({
            title: "Error",
            variant: "error",
            message: pError
        });
        this.dispatchEvent(evt);
    }

	//method to handle closing of the case logging modal from cross button
    handleCloseModal() {
        this.showRefundGeorgeModal = false;
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

    handleCloseTrackingDetailsModal(event) {
        this.isModalOpen = event.detail;
    }

    handleTrackingDetailsModal(event) {
        let lineId = event.target.dataset.value;
        const selectedItem = this.orderItems.find(item => item.lineId === lineId);
        if (selectedItem) {
            this.lstshipmentrecords = selectedItem.shipmentDetails;
            this.lineItemNameForTrackingDetail = selectedItem.productDescription;
            this.shippingAddressForTrackingDetail = selectedItem.shippingAddress;
            this.isModalOpen = true;
        }
    }
}