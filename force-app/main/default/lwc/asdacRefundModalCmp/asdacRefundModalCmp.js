import { LightningElement, track, api } from 'lwc';
import refundReasonsLbl from '@salesforce/label/c.ASDAC_RefundReasonOptions';
import GHSrefundReasonsLbl from '@salesforce/label/c.ASDAC_RefundReasonOptionsGHS';
import returnTypeLbl from '@salesforce/label/c.ASDAC_ReturnTypeOptions';
import refundTypeLbl from '@salesforce/label/c.ASDAC_RefundTypeOptions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {FlowNavigationNextEvent,FlowNavigationFinishEvent} from 'lightning/flowSupport';
import createReturnPreviewRequest from "@salesforce/apex/ASDAC_OrderController.createReturnPreviewRequest";
import createReturnRequest from "@salesforce/apex/ASDAC_OrderController.createReturnRequest";

export default class AsdacRefundModalCmp extends LightningElement {
	@track isLoading = true;
    @track newRefundItemList=[];
	@api totalItems;
	@track moreThanOne;
	@track isApplyAll;
	@track refundReasons=[];
    @track returnTypes=[];
	@track refundTypes = [];
    @track newRefundAmount;
    @track totalRefund;
    @track refundAmtSoFar;
    @track poundSymbol = '£';
    @track hasRendered = true;
    @track contactName;
    @api itemsFromFlow; 
    @track refundedItems;
    @api caseRecordId;
    @api availableActions = [];
    @api refundToCreateStr;
    @api totalRefundForFlow;
    @api exitButtonClicked=false;
    @track order;
    @track updatedData;
	@track isGrocery;
    @track requiredReasonMessage = 'Reason is required.';
    @track requiredNotesMessage = 'Notes is required.';
    @track requiredTypeMessage = 'Type is required.';
    isSubmitting = false;

	connectedCallback(){
        let tempString = this.itemsFromFlow;
        this.order = JSON.parse(tempString);
        this.order.totalRefundAmt = 0;
        this.order.orderLines.forEach((orderLine) => {
          orderLine.reason = '';
          orderLine.notes = '';
          orderLine.actionType = '';
          orderLine.refundableQuantity = this.order.sellingChannel==='ASDA_GROCERIES'? orderLine.refundableQuantity : orderLine.quantity;
        });

	    this.isGrocery = this.order.sellingChannel==='ASDA_GROCERIES'? true:false;

        if(tempString){
            this.refundedItems = this.order.orderLines;
        }

	    this.resetRefundColumn();
        const returnTypeList = returnTypeLbl.split(',');
      
        for(const reType of returnTypeList){
			this.returnTypes = [...this.returnTypes, {label: reType.trim(), value: reType.trim()}];
		}

	    const refundTypeList = refundTypeLbl.split(',');
      
        for(const reType of refundTypeList){
			this.refundTypes = [...this.refundTypes, {label: reType.trim(), value: reType.trim()}];
		}

        if(this.order.sellingChannel==='ASDA_GROCERIES'){
            
            const refundReasonsList = GHSrefundReasonsLbl.split(',');
            for(const reReason of refundReasonsList){
                this.refundReasons = [...this.refundReasons, {label: reReason.trim(), value: reReason.trim()}];
            }
        }
        else{
            const refundReasonsList = refundReasonsLbl.split(',');
            for(const reReason of refundReasonsList){
                this.refundReasons = [...this.refundReasons, {label: reReason.trim(), value: reReason.trim()}];
            }
        }

		this.moreThanOneItemCountCheck();
		this.isApplyAll = false;
        this.refundAmtSoFar = 0.00; // handle it in apex
	}

    renderedCallback(){
        if(this.hasRendered){
            this.hasRendered = false;

           this.setQuantityPicklist();

           return Promise.resolve().then(() => {
            for(const items of this.order.orderLines){
                if(items.isUomEach){
                    items.quantity = '1';
                }
            }
        }).then(() => {
            this.callReturnPreviewRequest();
         });    
        }
    }
	
    get removeDisabled() {
        return !(this.refundedItems && this.refundedItems.length > 1);
    }

    get totalRefundAmount() {
        let total = 0;
        for (let refundItem of (this.refundedItems || [])) {
            total += (refundItem.refundAmount || 0);
        }
        return total;
    }

    moreThanOneItemCountCheck(){
        if(this.refundedItems !== undefined){
			if(this.refundedItems.length > 1){
				this.moreThanOne = true;
			}else{
				this.moreThanOne = false;
			}
		}
    }

    removeRow(event) {
        this.refundedItems.splice(event.target.dataset.index, 1);
        this.moreThanOneItemCountCheck();
        this.resetRefundColumn();
    }

    resetRefundColumn(){
        this.refundedItems = this.refundedItems.map((ordItm, index) => ({ ...ordItm, isRefundTypeDisabled: index>0 ? true:false}));
        this.order.orderLines = this.refundedItems;
    }	

    callReturnPreviewRequest(){
        this.isLoading = true;
        const order = this.getReturnPreviewRequestOrder();
        createReturnPreviewRequest({ order })
            .then((data) => {
                this.updateRefundAfterPreviewCall(data);
                this.isLoading = false;
            })
            .catch((err) => {
                console.error(this.getErrorMessage(err));
                this.displayToastMessage("Error","error", this.getErrorMessage(err));
                this.isLoading = false;
            });
        
    }
    
    updateRefundAfterPreviewCall(responseData){
        this.order.totalRefundAmt = responseData.orderTotals.totalAmount;

        const refundAmountMap = {};
        for(const newObj of responseData.orderLines) {
            refundAmountMap[newObj.associationDetails[0].associatedLineId] = newObj.lineTotals.totalAmount;
        }
        this.refundedItems.forEach((obj) => {
            obj.refundAmount = refundAmountMap[obj.orderLineId];
            if(obj.isBundle){
                let tempAmount=0;
                obj.bundleItems.forEach((bunItem) =>{
                    tempAmount += refundAmountMap[bunItem.orderLineId]
                })
                obj.refundAmount = tempAmount;
            } 
        });
    }

    setQuantityPicklist(){
        [...this.template.querySelectorAll(".oiQuantity")].forEach((row) => {
            row.options =[];
            if(!JSON.parse(row.dataset.isuomeach)){
                row.disabled = true;
                row.value = row.dataset.value;
                row.options =[{label: `${row.value}` , value: `${row.value}`}];
            }
            else{
                if(parseInt(row.dataset.value,10) === 1 || parseInt(row.dataset.value,10) === 0){
                   row.disabled = true;
                   row.value = row.dataset.value;
               }
               else{
                   row.disabled = false;
                   row.value = '1';  
               } 
               
               for (let i = 1; i <= row.dataset.value; i++) {
                  row.options = [...row.options, {label: `${i}` , value:  `${i}` }]
               }
            }
        });
    }

    handleQuantityChange(event){
        this.isLoading  = true;
        for(const items of this.order.orderLines){
           if(items.lineId === event.target.dataset.id){
                items.quantity = event.target.value;
            }
        }
       
        return Promise.resolve().then(() => {
            this.callReturnPreviewRequest();
         });
    }

    resolveValidityIssues(reasonValue, targetInput){
		if(reasonValue !== undefined || reasonValue !== '' || reasonValue !== null){
			targetInput.setCustomValidity('');
			targetInput.reportValidity();
		}
	}

	handleApplyAll(event){
		if(event.target.checked){
			this.isApplyAll = true;
			let reasonValue = this.template.querySelector(".oiMultiReasonCls").value;
			let notesValue = this.template.querySelector(".oiMultiNotesCls").value;
			if(reasonValue !== undefined || reasonValue !== ''){
               this.setApplyAllValueResolveValidity(".oiReasonCls",reasonValue);
			}
			if(notesValue !== undefined || notesValue !== ''){
                this.setApplyAllValueResolveValidity(".oiNotesCls",notesValue);
			}
		}else{
			this.isApplyAll = false;
		}
	}

    setApplyAllValueResolveValidity(componentClass, value){
        [...this.template.querySelectorAll(componentClass)].forEach((input) => {
            input.value = value;
            this.resolveValidityIssues(value, input);
        });
    }

	handleMultiReasonChange(event){
		if(this.isApplyAll){
          this.setApplyAllValueResolveValidity(".oiReasonCls",event.target.value);
		}
		
	}

	handleMultiNotesChange(event){
		if(this.isApplyAll){
           this.setApplyAllValueResolveValidity(".oiNotesCls",event.target.value)
		}
	}

    handleReasonChange(event){
        this.isApplyAll = false;
		this.resolveValidityIssues(event.target.value, event.target);
	}

    handleNotesChange(event){
		this.resolveValidityIssues(event.target.value, event.target);
	}

    handleReturnTypeChange(event){
		this.resolveValidityIssues(event.target.value, event.target);
	}

	handlerefundTypeChange(event){
        this.setApplyAllValueResolveValidity(".oiTypeCls",event.target.value);
    }

	handleCancel(){
        this.exitButtonClicked=true;
        if(this.availableActions.find((action) => action === 'NEXT')){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        else if (this.availableActions.find((action) => action === 'FINISH')) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
            }
            
       }

    checkValidityOnSubmit(componentClass, message){
        let isValid = true;
        [...this.template.querySelectorAll(componentClass)].forEach((input) => {
			if(input.value === undefined || input.value === '' || input.value === null){
				isValid = false;
				input.setCustomValidity(message);
				input.reportValidity();
			}
		});
        return isValid;
    }

	handleSubmit(){
        this.newRefundItemList = this.refundedItems;
		
        let isReasonValid = this.checkValidityOnSubmit(".oiReasonCls", this.requiredReasonMessage);
        let isNotesValid = this.checkValidityOnSubmit(".oiNotesCls", this.requiredNotesMessage);
        let isTypeValid = this.checkValidityOnSubmit(".oiTypeCls", this.requiredTypeMessage);

        if(isReasonValid && isNotesValid && isTypeValid){
                this.isSubmitting = true;
                this.isLoading = true;
            const order = this.getReturnPreviewRequestOrder();
            createReturnPreviewRequest({ order })
                .then(async (data) => {
                    this.updatedData = data;
                    this.updatedData.orderLines.forEach((orderLine) => {
                        orderLine.reason = '';
                        orderLine.notes = '';
                        orderLine.actionType = '';
                      });
                    const { addressInfo} = order;
                    this.updatedData.addressInfo = addressInfo;
                    await this.fetchUpdatedTableValues();
                    await this.createReturnOrderRequest();
                })
                .catch((err) => {
                    console.error(this.getErrorMessage(err));
                    this.displayToastMessage("Error","error", this.getErrorMessage(err));
                })
      }
	}

    async createReturnOrderRequest(){
        return new Promise((resolve) => {
            createReturnRequest({ order: this.updatedData })
                .then((createData) => {
                    this.isLoading = false;
                    if(this.availableActions.find((action) => action === 'NEXT')){
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
                    }
                    else if (this.availableActions.find((action) => action === 'FINISH')) {
                        const navigateFinishEvent = new FlowNavigationFinishEvent();
                        this.dispatchEvent(navigateFinishEvent);
                    }
                })
                .catch((err) => {
                    const error = this.getError(err);
                    this.displayToastMessage("Error","error", this.getErrorMessage(err));
                    if (error.statusCode === 408 && this.isGrocery) {
                        this.handleTimeout({ isGhsRefundDisabled: true });
                    }
                    this.isLoading = false;
                });
                resolve('fetchUpdatedTableValues completed successfully');
        });
       
    }

    async fetchUpdatedTableValues(){
        return new Promise((resolve) => {
            this.getReturnTypeNotesReason();

            if(!this.isGrocery){
                this.updatedData.orderLines.forEach((orderLine) => {
                    orderLine.fulfillmentType = this.order.orderFulfilmentType;
                    orderLine.fulfillmentService = this.order.fulfillmentService;
                });
            }

            this.totalRefundForFlow = this.poundSymbol + this.updatedData.orderTotals.totalAmount.toFixed(2);
            this.refundToCreateStr = JSON.stringify(this.updatedData.orderLines);
            resolve('fetchUpdatedTableValues completed successfully');
        });
    }

    displayToastMessage(title, variant, message){
        const toEvt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(toEvt);
    }

    getReturnTypeNotesReason(){
        let dataMap=[];
        [...this.template.querySelectorAll(".oiTypeCls")].forEach((input) => {
            let key = parseInt(input.dataset.id,10);
            dataMap.push({key:key, type:input.value, notes: '', reason:''});
        });
        [...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
            let key = parseInt(input.dataset.id,10);
            dataMap.find(obj => obj.key === key).notes = input.value;
        });
        [...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
            let key = parseInt(input.dataset.lineid,10);
            dataMap.find(obj => obj.key === key).reason = input.value;

        });
        dataMap = this.updateBundleItems(dataMap);
        for(const index of dataMap){
            this.updatedData.orderLines = this.updatedData.orderLines.map(obj => {
                if (obj.associationDetails[0].associatedLineId === index.key) {
                    return {...obj, actionType: index.type, notes: index.notes, reason: index.reason};
                }
                return obj;
            });
        }
    }

    updateBundleItems(map) {      
        this.order.orderLines.forEach((orderLine) => {
            if (orderLine.isBundle && orderLine.bundleItems) {
                orderLine.bundleItems.forEach((bundleItem) => {
                    if(map.map(obj => obj.key).includes(bundleItem.parentId)){
                        let bundleParentData = map.find(obj => obj.key === bundleItem.parentId);
                        map.push({key:bundleItem.orderLineId, type:bundleParentData.type, notes:bundleParentData.notes, reason:bundleParentData.reason});

                    }
                })
            }
        });
        return map;
    }

    getReturnPreviewRequestOrder() {
        const order = { ...this.order };
        order.orderLines.forEach((orderLine) => {
            orderLine.reason = 'refund preview';
          });
        order.orderLines = order.orderLines.reduce((orderItems, ordItm) => {
            if (!ordItm.isBundle) {
                orderItems.push(ordItm);
                return orderItems;
            }
            const orderItem = { ...ordItm };
            delete orderItem.bundleItems;
            orderItems.push(orderItem);
            return orderItems.concat(ordItm.bundleItems);
        }, []);
        return order;
    }

    getError(err) {
        let error = err;
        if (err.body) {
            try {
                error = JSON.parse(err.body.message);
            } catch(e) {
                error = err.body;
            }
        }
        return error;
    }

    getErrorMessage(err) {
        return this.getError(err).message;
    }

    handleTimeout(timeout = {}) {
        this.handleCancel();
        const timeoutEvent = new CustomEvent("timeout", {
            bubbles: true,
            composed: true,
            detail: timeout
        });
        this.dispatchEvent(timeoutEvent);
    }
}