import { api, LightningElement } from 'lwc';

export default class AsdacRejectedItemsListCmp extends LightningElement {
  @api orderWrapper;
  @api rejectedItems;

  searchTerm = "";

  handleSearch(event) {
    event.target.value = event.target.value.replace(/^[ A-Za-z0-9_@./#&+-]*$/.g, "");
    this.searchTerm = event.target.value;
  }

  get data() {
    let regex = new RegExp(this.searchTerm.toLowerCase().replace(/[[\]*(){}+?.,\\^$|]/g, "\\$&"), "");

    return this.rejectedItems.filter(row => regex.test(row.productDescription.toLowerCase()) || regex.test(row.productId.toLowerCase()));
  }
}