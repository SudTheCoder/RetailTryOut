import { LightningElement, api, track, wire } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import ROLE_NAME from "@salesforce/schema/User.UserRole.Name";
import ELIGIBLE_ROLES from "@salesforce/label/c.ASDAC_OverrideRefundEligibleRoles";
import ELIGIBLE_PUBLICGROUPS from "@salesforce/label/c.ASDAC_OverrideRefundEligiblePublicGroups";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserGroups from '@salesforce/apex/ASDAC_OrderController.getUserGroups';

export default class AsdacRefundedItemsListGroceryCmp extends LightningElement {
  @api orderWrapper;
  @track refundOrders = [];
  @track flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
  @track showOverrideModal= false;
  ampm = false;
  originalItems;
  isRefundEnabled = true;
  isRoleEligible;
  isPublicGroupEligible;
  @track returnOrderList = [];
  @track isOnCaseRecord = false;
  @track caseRecordId;
  @api caseId;
  enabledRefundOrdersCount = 0;
  isSelectAllEnabled = false;
  @track userGroups = [];

  @wire(getRecord, { recordId: USER_ID, fields: [ROLE_NAME] })
	wiredUser({ error, data }) {
		if (error) {
			const event = new ShowToastEvent({
				title: "Error",
				variant: "error",
				message: error.message
			});
			this.dispatchEvent(event);
		} else if (data) { 
			this.isRoleEligible = ELIGIBLE_ROLES.includes(data.fields.UserRole.value?.fields.Name.value) ? true : false;
		}
        
	}

  connectedCallback() {
    this.checkUserGroup();
    this.isGeorge = (this.orderWrapper.sellingChannel === "GEORGE.COM") ? true : false;
    this.returnOrderList = this.orderWrapper.returnOrders.map(rorder => ({
      ...rorder, 
      orderItems: rorder.orderItems.map(item => ({
      ...item,
      returnOrderId: rorder.orderId,
      dateTime: rorder.formattedOrderDate,
      reason: item.returnReason,
      actionType: item.refundMode
    }))
      }));

    for(let returnOrder of this.returnOrderList){
      for(let item of returnOrder.orderItems){
        this.refundOrders.push(item);

      }
    }
    for(let i=0; i < this.refundOrders.length; i++){
      if(this.refundOrders[i].isOverrideDisabled === false){
        this.enabledRefundOrdersCount ++ ; 
      } 
    }

    this.showItemTags();
    this.originalItems = this.refundOrders;
  }

  checkUserGroup() {
    getUserGroups({ userId: USER_ID })
      .then(result => {
          this.userGroups = result;
          this.isPublicGroupEligible = this.userGroups.includes(ELIGIBLE_PUBLICGROUPS);
      })
      .catch(error => {
          console.error('Error fetching user groups:', error);
      });
  }

  showItemTags() {
    for(let key of this.refundOrders){
      key.showTags = false;
      if(key.isPersonalisedPromotion){
        key.showTags = true;
      }
    }
  }
  
  selectAllRefund(event){
    const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');
        for (const toggleElement of toggleList) {
          if (!toggleElement.disabled) {
            toggleElement.checked = event.target.checked;
          }
        }
    this.isRefundEnabled = this.getSelectedLineIds().length === 0;
  }

  handleItemLevelCheckbox(event) {
    if(!event.target.disabled){
      this.isRefundEnabled = this.getSelectedLineIds().length === 0;
      this.isSelectAllEnabled = this.getSelectedLineIds().length === this.enabledRefundOrdersCount;
    }
  }

  handleSearchItemsRefund(event) {    
    event.target.value = event.target.value.replace(/[^ A-Za-z0-9_@./#&+-]/g, "");
    let regex = new RegExp(event.target.value.toLowerCase());
    this.refundOrders = this.originalItems.filter(
    row => regex.test(row.productDescription.toLowerCase()) || 
    regex.test(row.productId.toLowerCase()));  
  }

  getSelectedLineIds(){
    let selectedIds = [...this.template.querySelectorAll('lightning-input')]
    .filter(element => element.checked && element.dataset.value)
    .map(element => Number(element.dataset.value));
    return selectedIds;
  } 

  handleCloseModal(){
		this.showOverrideModal = false;
	}

 
  handleRefundOverride() {
    let selectedLineIds = new Set(this.getSelectedLineIds());
    
		const result = this.refundOrders.filter((oi, index) => selectedLineIds.has(index));
    if (result.length > 0) {
      this.setFlowVariable();
      const { orgId, sellingChannel, addressInfo, orderId, customerId} = this.orderWrapper;	
				const order = { orgId, sellingChannel, addressInfo, orderId, customerId };	
      order.orderLines = result;
      this.setFlowInputVariables(order, 'OVERRIDE');
    }
    else {
      this.showOverrideModal = false;
      this.showErrorToast('Selected Items are not available for Refund.');
    } 
	}
 
  handleFlowStatusChange(event) {
    let refreshWindow = true;
		if (event.detail.status === 'FINISHED') {
			this.showOverrideModal = false;
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

  setFlowInputVariables(result,buttonActionName) {
		this.showOverrideModal = true;
		this.flowInputVariables = [
			{ name: 'orderId', type: 'String', value: this.orderWrapper.orderId },
			{ name: 'customerId', type: 'String', value: this.orderWrapper.customerId },
			{ name: 'isOnCaseRecord', type: 'Boolean', value: this.isOnCaseRecord },
      { name: 'CaseRecordId', type: 'String', value: this.caseRecordId },
			{ name: 'refundedItemListFromOrderDetail', type: 'String', value: JSON.stringify(result) },
			{ name: 'buttonActionName', type: 'String', value: buttonActionName },	
			{ name: 'isGeorgeOrNot', type: 'Boolean', value: this.isGeorge}
		];
	}

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
}