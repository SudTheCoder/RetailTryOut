import { LightningElement, api} from 'lwc';

export default class AsdacUnavailableItemsListCmp extends LightningElement {

    @api orderWrapper;
    @api unavailableItemList;
    unavailableItems;
    orderItems;
    
    connectedCallback(){
      this.unavailableItems = this.unavailableItemList.map(ordItm => ({ ...ordItm, quantity: Number(ordItm.quantity) }));
      this.orderItems = this.unavailableItems;
      this.showItemTags();
    }

    showItemTags(){
      for(let key of this.unavailableItems){
        key.showTags = false;
        if(key.nilPickQty>0){
            key.showTags = true;
            key.isNilPick = true;
        }
        if(key.isSubstitutedLine){
            key.showTags = true;
        }
        if(key.isPersonalisedPromotion){
            key.showTags = true;
        }
      }
    }

    handleSearchUnavItemsGHS(event) {
      event.target.value = event.target.value.replace(/^[ A-Za-z0-9_@./#&+-]*$/.g, "");
      let regex = new RegExp(event.target.value.toLowerCase().replace(/[[\]*(){}+?.,\\^$|]/g, "\\$&"));

      this.orderItems = this.unavailableItems.filter(
        row => regex.test(row.productDescription.toLowerCase()) || 
        regex.test(row.productId.toLowerCase()));
    }  
}