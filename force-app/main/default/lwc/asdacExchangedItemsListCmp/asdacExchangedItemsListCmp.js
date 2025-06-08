//Import LWC
import { api, LightningElement, track } from "lwc";

export default class AsdacExchangedItemsListCmp extends LightningElement {
  //All the Order related details
  @api orderWrapper;
	@track allExchangeOrders;
	@track exchangeOrders;

  @track isModalOpen = false;

  lstshipmentrecords = [];

  @track isGeorge;
	@track lineItemNameForTrackingDetail;
	@track shippingAddressForTrackingDetail;

  isexchangeorder = true;
  orderItemsSearchNotFound = false;

  //Connected callback to set variables on load
  connectedCallback() {
    this.allExchangeOrders = JSON.parse(JSON.stringify(this.orderWrapper.exchangeOrders));
    this.allExchangeOrders.forEach((order) => { order.orderLines = order.orderItems;
                                                order.isReship = order.orderCategory?.toLowerCase()!=="exchange" ? true : false  });
    this.exchangeOrders = this.allExchangeOrders;

    this.isGeorge = (this.orderWrapper.sellingChannel === "GEORGE.COM") ? true : false;
  }

  //method to handle searching the line items
  handleSearchItems(event) {
    event.target.value = event.target.value.replace(/^[ A-Za-z0-9_@./#&+-]*$/.g, "");
		const regex = new RegExp(event.target.value.toLowerCase().replace(/[()]/g, "\\$&"));

    this.exchangeOrders = this.allExchangeOrders.filter(returnOrders =>
			returnOrders.orderItems.some(orderItem => {
        return regex.test(orderItem.productDescription.toLowerCase()) || 
        regex.test(orderItem.productId.toLowerCase())
      }));

    this.orderItemsSearchNotFound = this.exchangeOrders.length === 0;
  }

  handleTrackingDetailsModal(event) {
    let orderIndex = Number(event.target.dataset.orderIndex);
    let index = Number(event.target.dataset.index);
    this.lineItemNameForTrackingDetail = this.exchangeOrders[orderIndex].orderItems[index].productDescription;
		this.shippingAddressForTrackingDetail = this.exchangeOrders[orderIndex].orderItems[index].shippingAddress;
    this.lstshipmentrecords = this.exchangeOrders[orderIndex].orderItems[index].shipmentDetails;
    this.isModalOpen = true;
  }

  handleCloseTrackingDetailsModal() {
    this.isModalOpen = false;
  }
}