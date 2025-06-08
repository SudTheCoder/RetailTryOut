import { NavigationMixin } from 'lightning/navigation';
import { api, LightningElement, track } from 'lwc';
import returnRefundItemsTabLabel from '@salesforce/label/c.ASDAC_ReturnRefundItemsTabLabel';
import exchangedItemsTabLabel from '@salesforce/label/c.ASDAC_ExchangedItemsTabLabel';
import partialRefundItemsTabLabel from '@salesforce/label/c.ASDAC_PartialRefundItemsTabLabel';
import ghsRefundItemsTabLabel from '@salesforce/label/c.ASDAC_GhsRefundedItemsTabLabel';
import substitutedItemsTabLabel from '@salesforce/label/c.ASDAC_SubstitutedItemsTabLabel';
import unavailableItemsTabLabel from '@salesforce/label/c.ASDAC_UnavailableItemsTabLabel';
import rejectedItemsTabLabel from '@salesforce/label/c.ASDAC_RejectedItemsTabLabel';
import allItemsTabLabel from '@salesforce/label/c.ASDAC_AllItemsTabLabel';
import noExchangeItemPresent from '@salesforce/label/c.ASDAC_NoExchangeItemPresent';
import noGhsRefundItemPresent from '@salesforce/label/c.ASDAC_NoGhsRefundItemPresent';
import noRefundItemPresent from '@salesforce/label/c.ASDAC_NoRefundItemPresent';
import noSubstituteItemPresent from '@salesforce/label/c.ASDAC_NoSubstituteItemPresent';
import noUnavailableItemPresent from '@salesforce/label/c.ASDAC_NoUnavailableItemPresent';
import noRejectedItemPresent from '@salesforce/label/c.ASDAC_NoRejectedItemPresent';

export default class AsdacOrderDetailsCmp extends NavigationMixin(LightningElement) {
    @api orderWrapper;
    @track isGeorge;
    @api selectedLineItemIdList = [];
    @track allItemsLabel;
    @track orderItems;
    @track numOfOrderItems;
    @track numOfCancelElgItems;
    @api caseId;
    @track cancelledLineItems;
    @track showexchangeModal;
    @track refundedGeorgeLineItems;
    @track showRefundGeorgeModal = false;
    @track showDiscountModal = false;
    @track showManualCardModal = false;
    @track discountedLineItems;
    @track refundedItemsLabel;
    @track isReturnedItemsPresent;
    @track exchangedItemsLabel;
    @track isExchangedItemsPresent;
    @track partialRefundItemsLabel;
    @track isUnavailableItemsPresent;
    @track isRejectedItemsPresent;
    @track flowInputVariables;
    @track flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
    @track productToLinkMap = [];
    @track isAllItemsShown = true;
    @track isRefundItemsShown = false;
    @track isExchangeItemsShown = false;
    @track isModalOpen = false;
    @track allRefundedItemsGroceryLabel;
    @track unavailableItemList = [];
    @track rejectedItemList = [];
    @track substitutedItemList = [];
    @track isGroceryRefundItemsPresent;
    @track isSubstituteItemsPresent;
    allSubstitutedItemsLabel;
    @track initialCount=0;
    @track hasRendered = true;
    @track returnorders = [];

    label={
        noExchangeItemPresent,
        noGhsRefundItemPresent,
        noRefundItemPresent,
        noSubstituteItemPresent,
        noUnavailableItemPresent,
        noRejectedItemPresent
    };

    connectedCallback() {
        this.isGeorge = (this.orderWrapper.sellingChannel === "GEORGE.COM") ? true : false;
        this.numOfOrderItems = this.orderWrapper.length;
        this.orderItems = this.orderWrapper.orderItems.map((ordItm,index) => ({ ...ordItm, quantity: Number(ordItm.quantity)}));
        this.allItemsLabel = this.setItemsTabLabel(allItemsTabLabel, this.orderWrapper.orderItems.length);
        this.numOfCancelElgItems = this.orderWrapper.cancelEligibleItemsCount;

        this.refundedItemsLabel = this.setItemsTabLabel(returnRefundItemsTabLabel, this.initialCount);
        this.partialRefundItemsLabel = this.getPartialRefundTabLabel();
        this.exchangedItemsLabel = this.getExchangeTabLabel();
        this.allUnavailableItemsLabel = this.setItemsTabLabel(unavailableItemsTabLabel, this.initialCount);
        this.allRejectedItemsLabel = this.setItemsTabLabel(rejectedItemsTabLabel, this.getRejectedItemsCount());
        this.allSubstitutedItemsLabel = this.setItemsTabLabel(substitutedItemsTabLabel, this.initialCount);
        this.allRefundedItemsGroceryLabel = this.setItemsTabLabel(ghsRefundItemsTabLabel, this.initialCount);
        
    }

    renderedCallback(){
        if(this.hasRendered){
            let substitutedItemCount = this.getSubstitutedItemsCount();
            let charitableItemCount = this.getCharitableItemCount();
            
            if (!this.isGeorge){
                this.allItemsLabel = this.setItemsTabLabel(allItemsTabLabel, (this.orderWrapper.orderItems.length - substitutedItemCount - charitableItemCount));
            }
            this.refundedItemsLabel = this.setItemsTabLabel(returnRefundItemsTabLabel, this.getReturnRefundItemsCount());
            this.allRefundedItemsGroceryLabel = this.setItemsTabLabel(ghsRefundItemsTabLabel, this.getGhsRefundItemsCount());
            this.allSubstitutedItemsLabel = this.setItemsTabLabel(substitutedItemsTabLabel, substitutedItemCount);
            this.allUnavailableItemsLabel = this.setItemsTabLabel(unavailableItemsTabLabel, this.getUnavailableItemsCount());
            this.allRejectedItemsLabel = this.setItemsTabLabel(rejectedItemsTabLabel, this.getRejectedItemsCount());
            this.hasRendered = false;
        }
    }

    getReturnRefundItemsCount() {
        let returnCount = 0;
        let returnOrders = [];
      
        if (this.orderWrapper.isExchangeOrder) {
            this.orderWrapper.returnOrders.forEach(order => {
                let isReturnOrderAdded = false;
                order.orderItems.forEach(item =>{
                    if(!item.isCreatedFromExchange && !isReturnOrderAdded){
                        returnOrders.push(order);
                        isReturnOrderAdded = true;
                    }
                })
            });
        } else {
            returnOrders = [...this.orderWrapper.returnOrders];
        }
      
        if (returnOrders) {
          returnOrders.forEach(obj => {
            if (obj.orderItems && obj.orderItems.length) {
              returnCount += obj.orderItems.length;
            }
          });
        }
      
        this.isReturnedItemsPresent = returnCount !== 0;
        this.returnOrders = returnOrders;
        return returnCount;
      }

    getExchangeTabLabel() {
        this.isExchangedItemsPresent = this.orderWrapper.exchangedItemsCount !== 0;
        return this.setItemsTabLabel(exchangedItemsTabLabel, this.orderWrapper.exchangedItemsCount);
    }

    getPartialRefundTabLabel() {
        this.isPartialRefundItemsPresent = this.orderWrapper.partialRefundItemsCount !== 0;
        return this.setItemsTabLabel(partialRefundItemsTabLabel, this.orderWrapper.partialRefundItemsCount);
    }

    tabChangeHandler(event) {
        let activetabContent = event.target.value;
        if (activetabContent === 'allItems') {
            this.isAllItemsShown = true;
            this.isRefundItemsShown = false;
            this.isExchangeItemsShown = false;
            this.isPartRefundItemsShown = false;
        } else if (activetabContent === 'refundItems') {
            this.isAllItemsShown = false;
            this.isRefundItemsShown = true;
            this.isExchangeItemsShown = false;
            this.isPartRefundItemsShown = false;
        } else if (activetabContent === 'exchangeItems') {
            this.isAllItemsShown = false;
            this.isRefundItemsShown = false;
            this.isExchangeItemsShown = true;
            this.isPartRefundItemsShown = false;
        } 
    }	

    getGhsRefundItemsCount() {
        //needs to be updated once the refund for grocery is in place
        let refundCount=0;
        this.orderWrapper.returnOrders.forEach(obj => {
            if (obj.orderItems && obj.orderItems.length) {
                refundCount += obj.orderItems.length;
            }
        });
        this.isGroceryRefundItemsPresent = refundCount !== 0;
        return refundCount;
    }

    getSubstitutedItemsCount(){
      
        this.substitutedItemList = this.orderWrapper.orderItems.filter((item) => item.hasSubstitute || item.isSubstitutedLine);
        this.isSubstituteItemsPresent=  (this.substitutedItemList.filter((item) => item.hasSubstitute)).length !==0;
        return (this.substitutedItemList.filter((item) => item.hasSubstitute)).length;
    }

    getUnavailableItemsCount(){
        this.unavailableItemList = this.orderWrapper.orderItems.filter(obj => obj.nilPickQty>0 && !obj.isCharitableProduct);
        this.isUnavailableItemsPresent = this.unavailableItemList.length !== 0;
        return this.unavailableItemList.length;
    }

    getRejectedItemsCount() {
        this.rejectedItemList = this.orderWrapper.orderItems.filter(obj => obj.rejectedQty>0 && !obj.isCharitableProduct);
        this.isRejectedItemsPresent = this.rejectedItemList.length !== 0;
        return this.rejectedItemList.length;
    }

    getCharitableItemCount(){
        this.charitableItemList = this.orderWrapper.orderItems.filter(obj => obj.isCharitableProduct);
        return this.charitableItemList.length;
    }

    setItemsTabLabel(customLabel, count){
        return customLabel.replace('{0}', count);
    }
}