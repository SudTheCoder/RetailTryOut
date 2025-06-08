//Import LWC
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Start LWC JS
export default class AsdacRefundItemsRelatedListCmp extends LightningElement {
	//All the Order related details
	@api orderWrapper;
	//instance used for Search and display the items on screen
	@track isReceiveClicked=false;
	@track itemsToReceive = [];

	@api returnOrdersList; // pass retrunOrders list
	@track returnOrders;
	@track returnOrderId;
	orderItemsSearchNotFound = false;
	customerName;

	//Connected callback to set variables on load
	connectedCallback() {
		this.returnOrders = this.returnOrdersList;
		this.customerName= this.orderWrapper.billToContact.name;
	}

	//method to handle select all items functionality
	selectall(event) {
		const index = Number(event.target.dataset.index);
		const returnOrder = this.returnOrders[index];
		const toggleList = this.template.querySelectorAll(`[data-id="${returnOrder.orderId}"] [data-id^="toggle"]`);
		for (const toggleElement of toggleList) {
			toggleElement.checked = event.target.checked;
		}
	}

	//method to handle searching the line items
	handleSearchItems(event) {
		event.target.value = event.target.value.replace(/^[ A-Za-z0-9_@./#&+-]*$/.g, "");
		const regex = new RegExp(event.target.value.toLowerCase().replace(/[[\]*(){}+?.,\\^$|]/g, "\\$&"));

		this.returnOrders = this.returnOrdersList.filter(returnOrders =>
			returnOrders.orderItems.some(orderItem => {
				return regex.test(orderItem.productDescription?.toLowerCase()) || 
				regex.test(orderItem.productId?.toLowerCase())
			}));

		this.orderItemsSearchNotFound = this.returnOrders.length === 0;
	}

	handleMultiReceive(event){
		const index = Number(event.target.dataset.index);
		const returnOrder = this.returnOrders[index];
		let receiveItemList=[];
		let checkboxSelections = [...this.template.querySelectorAll(`[data-id="${returnOrder.orderId}"] [data-id^="toggle"]`)]
			.filter(element => element.checked)
			.map(element => Number(element.dataset.index));
		checkboxSelections = new Set(checkboxSelections);

		receiveItemList = returnOrder.orderItems.filter(function (oItem, idx) {
			return !oItem.isRecieveDisabled && checkboxSelections.has(idx);
		});

		if (receiveItemList.length === 0) {
			const toEvt = new ShowToastEvent({
				title: "Error",
				variant: "error",
				message: 'No items to receive.'
			});
			this.dispatchEvent(toEvt);
		} else{
			this.returnOrderId = returnOrder.orderId;
			this.itemsToReceive = receiveItemList;
			this.isReceiveClicked = true;
		}
	}

	handleReceive(event){
		const orderIndex = Number(event.target.dataset.orderIndex);
		const index = Number(event.target.dataset.index);
		const returnOrder = this.returnOrders[orderIndex];
		this.returnOrderId = returnOrder.orderId;
		this.itemsToReceive = [returnOrder.orderItems[index]];
		this.isReceiveClicked = true;
	}

	handleClose(){
		this.isReceiveClicked = false;
	}
}