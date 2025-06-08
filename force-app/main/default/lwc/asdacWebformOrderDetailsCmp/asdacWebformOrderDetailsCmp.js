import { LightningElement, track, api } from "lwc";
import DELIVERYPASSERRORMSG from "@salesforce/label/c.ASDAC_DeliveryPassErrorMsg";
import DELIVERYPASSLABEL from "@salesforce/label/c.ASDAC_DeliveryPassLabel";
import 	disableOrderNumberValidationPermission from '@salesforce/customPermission/ASDAC_DisableOrderNumberValidationPermission';

export default class AsdacWebformOrderDetailsCmp extends LightningElement {
  @api orderNumberLabel;
  @api orderDateLabel;
  @api orderValueLabel;
  @api maxProducts = 8;
  @track _orders = [];
  @track todaysDate;
  orderDetailsList = [];
  hasDisableOrderNumberValidationPermission = disableOrderNumberValidationPermission;
  deliveryPassOrderErrorMsg= false;
  labels ={
    DELIVERYPASSERRORMSG,
    DELIVERYPASSLABEL
  };
  

  connectedCallback() {
    this.dispatchEvent(new CustomEvent("webformload", { bubbles: true }));
    let today = new Date();
    this.todaysDate = today.toISOString();
    if (this._orders.length === 0) {
      this.addOrder();
    }
  }

  renderedCallback() {
    this._orders.forEach((order) => {
      const combobox = this.template.querySelector(`[data-id="${order.id}"]`);
      if (combobox) {
        combobox.classList.toggle('red-border', order.deliveryPassOrderErrorMsg);
      }
    });
  }
    deliveryPassOptions = [
        { label: 'Select', value: 'select' },
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

  @api
  get casesOrderDetails() {
    const ordersData = this._orders.map(({ number, date, value, deliveryPassOrder }) => {
      return {
        "orders": [
          {
            "orderId": number,
            "orderDate": date,
            "orderTotal": value,
            "deliveryPassOrder": deliveryPassOrder
          }
        ],
        "isVatRequest": true
      };
    });

    ordersData.forEach((row) => {
      if ((row.orders[0].orderId || row.orders[0].orderDate || row.orders[0].orderTotal) && (typeof row.orders[0].orderId === 'string')) {
        this.orderDetailsList.push(JSON.stringify(row));
      }
    })
    return this.orderDetailsList;
  }

  @api
  get orders() {
    const orders = this._orders.map(({ number, date, value,deliveryPassOrder }) => ({ number, date, value, deliveryPassOrder}));
    return JSON.stringify(orders);
  }

  setdeliverypassorder(value){
    return value === "select";
  }

  set orders(ordersJson) {
    const orders = JSON.parse(ordersJson);
    const addOrder = (order) =>
      this.addOrder(order.number, order.date, order.value, order.deliveryPassOrder, this.setdeliverypassorder(order.deliveryPassOrder));
    this._orders = [];
    (orders || []).forEach(addOrder);
    setTimeout(() => {
      this.template.querySelectorAll("lightning-input").forEach((el) => el.reportValidity());
    }, 100);
  }


  addOrder(number = "", date = "", value = "", deliveryPassOrder= "select", deliveryPassOrderErrorMsg = false) {
    const order = {
      id: window.crypto.randomUUID(),
      number,
      date,
      value,
      deliveryPassOrder,
      deliveryPassOrderErrorMsg,
      removable: this._orders.length !== 0
    };
    this._orders.push(order);
  }

  removeOrder(evt) {
    const index = evt.target.dataset.index;
    this._orders.splice(index, 1);
  }

  handleChange(evt) {
    const index = evt.target.dataset.index;
    const field = evt.target.name.replace("order-", "");
    let value = evt.detail.value;
    if (evt.target.type === "number") {
      value = Number(value);
    }
    this._orders[index][field] = value;
  }

  get disableAddOrders() {
    return this._orders.length >= this.maxProducts;
  }
  
  @api validate() {
    for (let order of this._orders) {
      if (!(order.number) || !(order.date) || !(order.value) || (order.deliveryPassOrder === 'select')) {
        return { isValid: false, errorMessage: "" };
      }
      const selectedDate = new Date(order.date);
      const currentDate = new Date();
      if (selectedDate > currentDate) {
          return { isValid: false, errorMessage: "" };
      }
      if (!(/^\d{13,14}$/.test(order.number)) && !this.hasDisableOrderNumberValidationPermission) {
        return { isValid: false, errorMessage: "" };
      }
      if(!/^\d+\.?\d*$/.test(order.value)){
        return { isValid: false, errorMessage: "" };
      }
    }
    return { isValid: true };
  }
}