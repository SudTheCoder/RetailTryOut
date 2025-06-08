/**
 * @description       : LWC for refund goodwill submission from screen flow
 * @author            : Arjun Singh
 * @group             :
 * @last modified on  : 18-07-2023
 * @last modified by  : Arjun Singh
 **/
import { LightningElement, track, api } from "lwc";
export default class AsdacWebformRefundGoodwillSubmissionCmp extends LightningElement {
	@api maxOrders = 10;
	@api maxProducts = 10;
	@api reasonText;
	@api currency;
	@track todaysDate =new Date().toISOString();
	setOrdersTriggered = false;
	@track _orders = [
		{
			id: window.crypto.randomUUID(),
			orderId: "",
			customerName: "",
			deliveryDate: "",
			items: [
				{
					id: window.crypto.randomUUID(),
					cin: "",
					qty: "",
					value: "",
					reason: "",
					removable: false
				}
			],
			comment: "",
			commentRequired: false,
			removable: false,
			disableAddItem: false
		}
	];
	labels = {		
		orderId: 'Order Number',
		customerName: 'Customer Name',
		deliveryDate:'Date of Delivery',
		comment: 'Comment',
		removeOrderBtn: 'Remove this order',
		addOrderBtn: '+ Add an order',
		cin: 'Description or CIN',
		units: 'Number of units',
		refundValue: 'Refund Value',
		refundReason:'Refund reason',
		removeItemBtn: 'Remove this item',
		addItemBtn: '+ Add an item',
		itemsText: 'Items',
		missingRequiredField:'Please check the required fields',
		invalidDateField:'Please check delivery date,Delivery Date is invalid',
		namePatternMismatch:'Please enter only letters in this field'	
	};
	get refundReasons() {
		return [
			{ label: "Item missing", value: "Item missing" },
			{ label: "Short dated", value: "Short dated" },
			{ label: "Out of date", value: "Out of date" },
			{ label: "Damaged", value: "Damaged" },
			{ label: "Unsuitable sub", value: "Unsuitable sub" },
			{ label: "Changed their mind", value: "Changed their mind" },
			{
				label: "Order charges but not delivered",
				value: "Order charges but not delivered"
			},
			{ label: "eVoucher", value: "eVoucher" }
		];
	}

	@api
	get casesOrderDetails() {
		let thisThis = this;
		const orders = this._orders.map((order) => {
			let orderItems = order.items.map((item) => {
				return {
					[thisThis.labels.cin] : item.cin,
					[thisThis.labels.units]: item.qty,
					[thisThis.labels.refundValue]: this.currency?  this.currency + item.value:item.value,
					[thisThis.labels.refundReason]: item.reason
				};
			});

			let orderDetails = {
				[thisThis.labels.orderId]: order.orderId,
				[thisThis.labels.customerName]: order.customerName,
				[thisThis.labels.deliveryDate]:  new Date(order.deliveryDate).toLocaleDateString('en-GB'),
				[thisThis.labels.comment]: order.comment,
				[thisThis.labels.itemsText]: orderItems
			};
			return JSON.stringify(orderDetails, null, 2).replaceAll(/[{}"]/g, "");
		});
		return orders;
	}
	@api
	get orders() {
		const orders = this._orders.map((order) => {
			let orderItems = order.items.map((item) => {
				return {
					cin: item.cin,
					qty: item.qty,
					value: item.value,
					reason: item.reason
				};
			});
			let orderDetails = {
				orderId: order.orderId,
				customerName: order.customerName,
				deliveryDate: order.deliveryDate,
				comment: order.comment,
				items: orderItems
			};
			return orderDetails;
		});
		return JSON.stringify(orders);
	}

	set orders(ordersJson) {
		const orders = JSON.parse(ordersJson);
		this._orders = orders.map((order, index) => {
			let commentRequired = false;
			let orderItems = order.items.map((item, itemIndex) => {
				if (item.reason === "eVoucher") {
					commentRequired = true;
				}
				return {
					id: window.crypto.randomUUID(),
					cin: item.cin,
					qty: item.qty,
					value: item.value,
					reason: item.reason,
					removable: itemIndex !== 0
				};
			});
			let orderDetails = {
				id: window.crypto.randomUUID(),
				orderId: order.orderId,
				customerName: order.customerName,
				deliveryDate: order.deliveryDate,
				comment: order.comment,
				items: orderItems,
				removable: index !== 0,
				commentRequired: commentRequired,
				disableAddItem: order.items.length >= this.maxProducts - 1
			};
			return orderDetails;
		}, this);
		this.setOrdersTriggered = true;	
	}
	renderedCallback() {
		if (this.setOrdersTriggered ) {
			this.template.querySelectorAll("lightning-input").forEach((el) => el.reportValidity());	
			this.template.querySelectorAll("lightning-combobox").forEach((el) => el.reportValidity());	
			this.template.querySelectorAll("lightning-textarea").forEach((el) => el.reportValidity());	
		}
	}
	addOrder(orderDetails) {
		const order = {
			id: window.crypto.randomUUID(),
			orderId: orderDetails.orderId,
			customerName: orderDetails.customerName,
			deliveryDate: orderDetails.deliveryDate,
			items: [
				{
				id: window.crypto.randomUUID(),
				cin: "",
				qty: "",
				value: "",
				reason: "",
				removable: false
				}
			],
			comment: orderDetails.comment,
			commentRequired: false,
			removable: this._orders.length !== 0,
			disableAddItem:false
		};
		this._orders.push(order);
	}
	addItem(evt) {
		const index = evt?.target ? evt.target.dataset.index : "";
		if (this._orders[index].items.length >= this.maxProducts - 1) {
			this._orders[index].disableAddItem = true;
		}
		const item = {
			id: window.crypto.randomUUID(),
			cin: "",
			qty: "",
			value: "",
			reason: "",
			removable: this._orders[index].items.length !== 0
		};
		this._orders[index].items.push(item);
	}
	removeOrder(evt) {
		const index = evt.target.dataset.index;
		this._orders.splice(index, 1);
	}

	removeItem(evt) {
		const index = evt.target.dataset.index;
		const productIndex = evt.target.dataset.item;
		this._orders[index].items.splice(productIndex, 1);
		if (this._orders[index].items.length < this.maxProducts) {
			this._orders[index].disableAddItem = false;
		}
		//check if comment required
		this.checkCommentRequired(index);
	}
	handleChange(evt) {
		const index = evt.target.dataset.index;
		const productIndex = evt.target.dataset.item;
		const field = evt.target.name;
		let value = evt.detail.value;
		if (evt.target.type === "number") {
			value = Number(value);
		}
		// set order/item values
		if (productIndex) {
			this._orders[index].items[productIndex][field] = value;
			// comment required
			if (field === "reason") {
				this.checkCommentRequired(index);
			}
		} else {
			this._orders[index][field] = value;
		}
	}
	checkCommentRequired(index) {
		//loop on each item to check if comment required
		let commentRequired = false;
		for (let product of this._orders[index].items) {
		if (product.reason === "eVoucher") {
			commentRequired = true;
		}
		}
		this._orders[index].commentRequired = commentRequired;
	}
	get disableAddOrders() {
		return this._orders.length >= this.maxOrders;
	}

	@api validate() {
		for (let order of this._orders) {
			// check order fields
			if (
				!order.orderId ||
				!order.customerName ||
				!order.deliveryDate ||
				(order.commentRequired && !order.comment)
			) {
				return { isValid: false, errorMessage: "" };
			}
			// customer name match
			//match customer name pattern
			const reg = /^[a-zA-Z ]+$/;
			if (!reg.test(order.customerName)) {
				return { isValid: false, errorMessage: "" };
			}
			// check order date 
			const selectedDate = new Date(order.deliveryDate);
			const currentDate = new Date();
			if (selectedDate > currentDate) {
				return { isValid: false, errorMessage: "" };
			}
			//check items data
			for (let item of order.items) {
				// check items fields
				if (!item.cin || !item.qty || !item.value || !item.reason) {
					return { isValid: false, errorMessage: "" };
				}
			}
		}
		return { isValid: true };
	}
}