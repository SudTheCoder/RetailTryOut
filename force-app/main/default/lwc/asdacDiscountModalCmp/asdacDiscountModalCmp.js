import { LightningElement, track, api, wire } from 'lwc';
import discountReasonsLbl from '@salesforce/label/c.ASDAC_DiscountReasonOptions';
import refundPercentLbl from '@salesforce/label/c.ASDAC_RefundPercentageOptions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {FlowNavigationNextEvent, FlowNavigationFinishEvent} from 'lightning/flowSupport';
import escalatePartialRefund from "@salesforce/apex/ASDAC_RefundRequestController.escalatePartialRefund";
import getPersonContactId from "@salesforce/apex/ASDAC_RefundRequestController.getPersonContactId";
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import CaseNumber from "@salesforce/schema/Case.CaseNumber";
import partialRefundOrder from "@salesforce/apex/ASDAC_OrderController.partialRefundOrder";
import userId from '@salesforce/user/Id';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ASDAC_PartialRefundApprovalLimitExceedMessage from '@salesforce/label/c.ASDAC_PartialRefundApprovalLimitExceedMessage';

const fields = [CaseNumber];

export default class AsdacDiscountModalCmp extends LightningElement {
	@api totalItems;
    @api refundToCreateStr;
    @api totalRefundForFlow;
    @api escalatedAmount;
    @api approverStr;
    @api exitButtonClicked;
    @api itemsFromFlow;
    @api caseRecordId;
    @api availableActions   = [];
    
	@track discountReasons  = [];
    @track refundPercentage = [];
    @track approver         = [];
    @track refundToCreate   = [];
    @track approverMap      = [];

    @track isLoading = true;
	@track moreThanOne;
	@track isApplyAll;
    @track poundSymbol = '£';
    @track defaultPercentage;
    @track totalRefund;
    @track hasRendered = true;
    @track refund;
    @track escalatedRefund;
    @track helptextContent;
    @track caseNumber;
    @track discountedItems;
    @track order;
    @track disableSubmit = false;
    disableSubmitMap = {};
    timeoutId = null;
    userRoleName;
    partialRefundLimitExceedMessage=ASDAC_PartialRefundApprovalLimitExceedMessage;
    showRefundLimitExceededMessage=false;

    @wire(getRecord, { recordId: "$caseRecordId", fields })
    getCaseNumber({ data, error }) {
        if (data) {
          this.caseNumber = getFieldValue(data, CaseNumber);
        } else if (error) {
            this.displayToastMessage('Error','Error','Some error Occurred! -> '+error);
        }
      }

      @wire(getRecord, { recordId: userId, fields: [RoleName] })
      getUserDetails({ error, data }) {
          if (error) {
            this.displayToastMessage('Error','Error','Some error Occurred! -> '+error);
          } else if (data) {
            this.userRoleName = getFieldValue(data, RoleName);
          }
      }

	connectedCallback() {
    let tempString = this.itemsFromFlow;
        if(tempString){
            this.order = JSON.parse(tempString);
            this.discountedItems = this.order.orderLines;
        }
        this.discountedItems.forEach((item) => {
            item.selectedQty = item.quantity;
            item.totalPrice = item.lineTotal;
            item.qtyOptions = []; 
            item.qtyOptions.push({label : '1', value : 1});
            item.disabledCombobox = true;
            if(item.quantity >1){
                for(let i = 2; i <= item.quantity; i++) {
                    item.qtyOptions.push({label : `${i}`, value : i });
                }
            }     
        })

		const discountReasonsList = discountReasonsLbl.split(',');
        const refundPerList = refundPercentLbl.split(',');
        this.defaultPercentage = refundPerList[0];

        for(const discReason of discountReasonsList){
			this.discountReasons = [...this.discountReasons, {label: discReason.trim(), value: discReason.trim()}];
		}
		for(const refundPer of refundPerList){
			this.refundPercentage = [...this.refundPercentage, {label: refundPer.trim(), value: refundPer.trim()}];
		}

		if(this.discountedItems){
			if(this.discountedItems.length > 1){
				this.moreThanOne = true;
			}else{
				this.moreThanOne = false;
			}
		}

		this.isApplyAll = false;
		this.isLoading = false;
	}

    handleQuantityChange(event) {
        let item = this.discountedItems[event.target.dataset.index];
        item.selectedQty = parseInt(event.target.value);
        item.totalPrice = item.selectedQty * parseFloat(item.unitTotal);
        let percentValue = parseFloat(this.template.querySelector(`lightning-combobox[data-percent-index='${event.target.dataset.index}']`).value.replace(/[^\d.]/g, ''));
        item.updatedLineAmount = item.lineTotal - ((percentValue/100) * item.totalPrice);
        this.discountedItems[event.target.dataset.index] = item;
        [...this.template.querySelectorAll(".oiupdatedLineAmt")].forEach((row) => {
            if(item.lineId === row.dataset.id) {
                row.textContent = this.poundSymbol + parseFloat(item.updatedLineAmount, 2).toFixed(2);
            }
        });
        this.totalRefund = parseFloat(0).toFixed(2);
        [...this.template.querySelectorAll(".oiRefundAmt")].forEach((row) => {
            if(item.lineId === row.dataset.id) {
                let value = parseFloat(item.totalPrice,2) * (parseFloat(percentValue,2)/100);
                row.value = this.poundSymbol + value.toFixed(2);
                this.totalRefund = parseFloat(this.totalRefund, 2) + parseFloat(value, 2); 
                this.totalRefund = this.totalRefund.toFixed(2);
            }
        });
        this.updateTotalRefund();
    }

    renderedCallback(){
        if(this.hasRendered) {
            this.totalRefund = 0;
            this.refund = 0;
            this.escalatedRefund =0;
            [...this.template.querySelectorAll(".oiPercentageCls")].forEach((input) => {
                let percentage = input.value.replace(/[^\d.]/g, '');

                [...this.template.querySelectorAll(".oiRefundAmt")].forEach((row) => {
                    let value;
                    if(row.dataset.id === input.dataset.id){
                        value = parseFloat(row.dataset.totalPrice,2)*parseFloat(percentage,2)/100;
                        row.value = value.toFixed(2);
                        this.totalRefund = parseFloat(this.totalRefund, 2) + parseFloat(value, 2); 
                        this.totalRefund = this.totalRefund.toFixed(2);
                        
                    }
                });

                [...this.template.querySelectorAll(".oiupdatedLineAmt")].forEach((row) => {
                    let value = row.textContent.replace(/[^\d.]/g, '');
                    
                    if(row.dataset.id === input.dataset.id){
                        value = parseFloat(row.dataset.lineTotal,2) - (parseFloat(row.dataset.totalPrice,2)*(parseFloat(percentage,2)/100)).toFixed(2);
                        row.textContent = this.poundSymbol+value.toFixed(2);
        
                    }
                });

            });
            this.refund = this.totalRefund;
            this.escalatedRefund = '0.00';
            
            this.hasRendered = false;
        }
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
				[...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
					input.value = reasonValue;
                    this.resolveValidityIssues(reasonValue, input);
				});
			}
			if(notesValue !== undefined || notesValue !== ''){
				[...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
					input.value = notesValue;
				});
			} 
		}else{
			this.isApplyAll = false;
		}
	}

	handleMultiReasonChange(event){
		if(this.isApplyAll){
			[...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
				input.value = event.target.value;
                this.resolveValidityIssues(event.target.value, input);
			});
		}
		
	}
	handleMultiNotesChange(event){
		if(this.isApplyAll){
			[...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
				input.value = event.target.value;
			});
		}
	}

    handleReasonChange(event){
		this.resolveValidityIssues(event.target.value, event.target);
	}


    handleRefundPercentageChange(event){
        this.totalRefund = parseFloat(0).toFixed(2);
        this.escalatedRefund = parseFloat(0).toFixed(2);
        this.refund= parseFloat(0).toFixed(2);
        let percentage = event.target.value.replace(/[^\d.]/g, '');
        let datasetId = event.target.dataset.id;
        let fromRefundPercentage= true;

        // Apex call to check escalate condition
        this.checkEscalatePartialRefund(percentage,datasetId,fromRefundPercentage)
    }

    checkEscalatePartialRefund(percentage,datasetId,fromRefundPercentage){

        escalatePartialRefund({
            userRole: this.userRoleName,
            refundPercent : percentage
            }).then( result =>{
            if(result){
                if(result.approver != null){
                    for(const index of this.approverMap ){                        
                            if (index.key=== datasetId) {
                                this.approverMap.splice(index,1);
                            }
                    }                   
                    this.approverMap.push({key:datasetId, value:result.approver});
                }
                let isDisabled = false;
                for (let prop in this.disableSubmitMap) {
                    if(this.disableSubmitMap[prop]) {
                        isDisabled = true;
                    }
                }
                this.disableSubmit = isDisabled;
                this.showEscalate(result.escalate, percentage, datasetId,fromRefundPercentage);
            }
        }).catch(error =>{
            this.error = error;
            this.displayToastMessage('Error','Error','Some error Occurred! -> '+this.error);
        });

    }

    showEscalate(isEscalate, percentage, datasetId,fromRefundPercentage){
        this.showRefundLimitExceededMessage = false;
        this.discountedItems.forEach((item) => {
            if(item.lineId === datasetId) {
                item.isEscalated = isEscalate;
            }
            if (item.isEscalated) {
                this.showRefundLimitExceededMessage = true;
                return; 
            }
        });
        
      
        [...this.template.querySelectorAll(".oiRefundAmt")].forEach((row) => {
            let value = row.value.replace(/[^\d.]/g, '');
            if(fromRefundPercentage){
                if(row.dataset.id === datasetId){
                    value = (parseFloat(row.dataset.totalPrice,2)*parseFloat(percentage,2)/100) || 0;
                    row.value = value.toFixed(2);
                    if((parseFloat(row.value) < parseFloat(row.dataset.totalPrice))){
                        row.setCustomValidity('');
                        row.reportValidity();   
                        this.disableSubmitMap[row.dataset.id] = false;   
                    }  
                }
            }    
            this.totalRefund = parseFloat(this.totalRefund, 2) + parseFloat(value, 2); 
            this.totalRefund = this.totalRefund.toFixed(2);

        });
        let isDisabled = false;
                for (let prop in this.disableSubmitMap) {
                    if(this.disableSubmitMap[prop]) {
                        isDisabled = true;
                    }
                }
        this.disableSubmit = isDisabled;
        
        [...this.template.querySelectorAll(".oiupdatedLineAmt")].forEach((row) => {
            let value = row.textContent.replace(/[^\d.]/g, '');
            
            if(row.dataset.id === datasetId){
                value = parseFloat(row.dataset.lineTotal,2) - (parseFloat(row.dataset.totalPrice,2)*(parseFloat(percentage,2)/100)).toFixed(2);
                row.textContent = this.poundSymbol+value.toFixed(2);

            }
        });
        
        this.updateTotalRefund();
    }
    
    handleRefundAmtChange(event) {     
        clearTimeout(this.timeoutId);
        let {value,dataset} = event.target;
        this.disableSubmit = true;
    
        this.timeoutId = setTimeout(()=> {
            let changedAmt = value.replace(/[^\d.]/g, ''); 
            this.totalRefund = parseFloat(0).toFixed(2);       
            let isAmtValid;
            let requiredMessage = 'Invalid Amount';
            changedAmt = isNaN(parseFloat(changedAmt)) ? parseFloat(0) : changedAmt;
            this.escalatedRefund = parseFloat(0).toFixed(2);
            this.refund= parseFloat(0).toFixed(2);
            
            if(parseFloat(changedAmt) <=0 || (parseFloat(changedAmt) > parseFloat(dataset.totalPrice)) || isNaN(value.replace(/\u00A3/g, ''))){
                isAmtValid = false;
                [...this.template.querySelectorAll(".oiRefundAmt")].forEach((input) => {
                    if(input.dataset.id === dataset.id){
                        input.setCustomValidity(requiredMessage);
                        input.reportValidity();
                    }
                });                
                this.disableSubmitMap[dataset.id] = true;
                
            }
            else{
                this.disableSubmitMap[dataset.id] = false;
                isAmtValid = true;
                [...this.template.querySelectorAll(".oiRefundAmt")].forEach((input) => {
                    if(input.dataset.id === dataset.id){
                        input.setCustomValidity('');
                        input.reportValidity();
                    }
                });
            }

            if(isAmtValid){
                this.updateLineAmount(changedAmt,event);
                // update percentage
                this.updatePercentage(
                    {
                        target:
                        {
                            value:value,
                            dataset:dataset
                        }
                        
                    },changedAmt, true);
                this.updateTotalRefund();
            }
        }
        ,1000);
        
    }
    updatePercentage(event, changedAmt){
        let percentage;
        let datasetId = event.target.dataset.id;
        let fromRefundPercentage = false;

        [...this.template.querySelectorAll(".oiPercentageCls")].forEach((input) => {
            if(input.dataset.id === event.target.dataset.id){
                let newPerc = ((parseFloat(changedAmt)/parseFloat(event.target.dataset.totalPrice))*100).toFixed(2);
                let option= parseFloat(newPerc) + '%';
                this.refundPercentage = [ ...this.refundPercentage, {label: option, value: option} ];
                input.value =option;
                percentage = parseFloat(newPerc);
            }
        });

        this.refundPercentage = this.refundPercentage.filter((item, index, self) =>
            index === self.findIndex((t) => (
            t.value === item.value 
        )));
        this.checkEscalatePartialRefund(percentage,datasetId,fromRefundPercentage);
    }
    updateTotalRefund(){
        this.totalRefund = parseFloat(0).toFixed(2);
        this.escalatedRefund = parseFloat(0).toFixed(2);
        this.refund= parseFloat(0).toFixed(2);
        
        [...this.template.querySelectorAll(".oiRefundAmt")].forEach((input) => {
            let amt = input.value.replace(/[^\d.]/g, '');
            this.totalRefund = isNaN(parseFloat(amt)) ? parseFloat(0) : parseFloat(this.totalRefund) + parseFloat(amt);
            [...this.template.querySelectorAll(".isEscl")].forEach((row) => {
                if(input.dataset.id === row.dataset.id){
                    this.escalatedRefund = parseFloat(this.escalatedRefund) +  parseFloat(amt);
                    this.escalatedRefund = isNaN(this.escalatedRefund) ? parseFloat(0) : this.escalatedRefund.toFixed(2);
                    
                }
            });
        });
        this.totalRefund = parseFloat(this.totalRefund).toFixed(2);
        this.refund = parseFloat(this.totalRefund) - parseFloat(this.escalatedRefund);
        this.refund=  (this.refund).toFixed(2);
    }

    updateLineAmount(changedAmt,event){
        [...this.template.querySelectorAll(".oiupdatedLineAmt")].forEach((row) => {
            let value = row.textContent.replace(/[^\d.]/g, '');
            
            if(row.dataset.id === event.target.dataset.id){
                value = parseFloat(row.dataset.lineTotal,2) - parseFloat(changedAmt, 2);
                row.textContent = this.poundSymbol+value.toFixed(2);
            }
        });
    }

	handleCancel(){
        this.exitButtonClicked = true;
        this.finishFlowEvent()
	}

    displayToastMessage(title, variant, message){
        const toEvt = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message
        });
        this.dispatchEvent(toEvt);
    }

    @track newDiscountItemList;
	
    handleSubmit(){
        if(this.disableSubmit){
            return;
        }                       
        this.newDiscountItemList = this.discountedItems;
		let isReasonValid = true;
		let requiredMessage = 'Reason is required.';
        let isAmtValid = true;
		[...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
			if(input.value === undefined || input.value === '' || input.value === null){
				isReasonValid = false;
				input.setCustomValidity(requiredMessage);
				input.reportValidity();
			}
		});

        this.lineToDiscountMap = new Map();
        this.lineToDiscountNotesMap = new Map();
        this.lineToDiscountReasonMap = new Map();

        [...this.template.querySelectorAll(".oiRefundAmt")].forEach((input) => {
            let amt = input.value.replace(/[^\d.]/g, '');
			if(amt <=0 || (parseFloat(amt) > parseFloat(input.dataset.totalPrice)) || isNaN(input.value.replace(/\u00A3/g, '')) ){
				isAmtValid = false;
			}
            this.lineToDiscountMap.set(
                input.dataset.id.toString(),
                amt
              );
		});
    
        [...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
            this.lineToDiscountNotesMap.set(
                input.dataset.id.toString(),
                input.value
              );
        });

        [...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
            this.lineToDiscountReasonMap.set(
                input.dataset.id.toString(),
                input.value
              );
        });


            if(isReasonValid  && isAmtValid && !this.showRefundLimitExceededMessage){

                this.disableSubmit = true;
                for(const index of this.approverMap ){
                    this.approver.push(index.value);
                }
                this.fetchUpdatedTableValues();
                if(parseFloat(this.refund) > 0){
                    this.dispatchEvent(new CustomEvent('closemodal'));
                    this.refundToCreate = this.newDiscountItemList;
                }
                if(parseFloat(this.escalatedRefund) > 0){
                    this.dispatchEvent(new CustomEvent('closemodal'));
                    this.approver = [...new Set(this.approver)];
                    
                    this.approverStr = JSON.stringify(this.approver);

                }
                
                this.refundToCreateStr = JSON.stringify(this.newDiscountItemList);
                this.totalRefundForFlow = this.poundSymbol+this.refund;
                this.escalatedAmount = this.escalatedRefund;

                this.callPartialRefundOrder();
                
            }
	}

    finishFlowEvent(){
        if (this.availableActions.find((action) => action === 'FINISH')) {
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
            }
            
        else if(this.availableActions.find((action) => action === 'NEXT')){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    fetchUpdatedTableValues(){
        // partial refund reason
        let reasonMap = [];
        [...this.template.querySelectorAll(".oiReasonCls")].forEach((input) => {
            let key = input.dataset.id;
            reasonMap.push({key:key, value:input.value});
        });
        for(const index of reasonMap ){
            this.newDiscountItemList = this.newDiscountItemList.map(obj => {
                if (obj.lineId === index.key) {
                  return {...obj, reason: index.value};
                }
                return obj;
            });
        }

        let notesMap=[];
        [...this.template.querySelectorAll(".oiNotesCls")].forEach((input) => {
            let key = input.dataset.id;
            notesMap.push({key:key, value:input.value});
        });
        for(const index of notesMap ){
            this.newDiscountItemList = this.newDiscountItemList.map(obj => {
                if (obj.lineId === index.key) {
                    return {...obj, notes: index.value};
                }
                return obj;
            });
        }

        this.getRefundPercentage();
        this.getRefundAmount();
        this.getUpdatedLineAmount();
    }

    getRefundPercentage(){
        let percentMap=[];
        [...this.template.querySelectorAll(".oiPercentageCls")].forEach((input) => {
            let key = input.dataset.id;
            let value = input.value.replace(/[^\d.]/g, '');
            percentMap.push({key:key, value:value});
        });
        for(const index of percentMap ){
            this.newDiscountItemList = this.newDiscountItemList.map(obj => {
                if (obj.lineId === index.key) {
                    return {...obj, percent: index.value};
                }
                return obj;
            });
        }
    }

    getRefundAmount(){
         // for refund amt 
         let refundAmtMap=[];
         [...this.template.querySelectorAll(".oiRefundAmt")].forEach((input) => {
            let key = input.dataset.id;
            let value = input.value.replace(/[^\d.]/g, '');
            refundAmtMap.push({key:key, value:value});
        });
        for(const index of refundAmtMap ){
            this.newDiscountItemList = this.newDiscountItemList.map(obj => {
                if (obj.lineId === index.key) {
                    return {...obj, refundAmount: index.value};
                }
                return obj;
            });
        }
    }

    getUpdatedLineAmount(){
        let updatedLineAmtMap=[];
         [...this.template.querySelectorAll(".oiupdatedLineAmt")].forEach((input) => {
            let key = input.dataset.id;
            let value = input.textContent.replace(/[^\d.]/g, '');
            updatedLineAmtMap.push({key:key, value:value});
        });
        for(const index of updatedLineAmtMap ){
            this.newDiscountItemList = this.newDiscountItemList.map(obj => {
                if (obj.lineId === index.key) {
                    return {...obj, updatedLineAmount: index.value};
                }
                return obj;
            });
        }
    }

    callPartialRefundOrder()
    {
        const order = JSON.parse(this.itemsFromFlow);
        order.orderLines = this.discountedItems.map((ol) => {
        const orderLine = ol;
        orderLine.discount = this.lineToDiscountMap.get(orderLine.lineId);
        orderLine.notes = this.lineToDiscountNotesMap.get(orderLine.lineId);
        orderLine.reason = this.lineToDiscountReasonMap.get(orderLine.lineId);
        return orderLine;
        });

        partialRefundOrder({ order })
                .then(() => {
                this.isLoading = false;
                this.finishFlowEvent();
                })
                .catch((err) => {
                let message;
                try {
                    message = JSON.parse(err.body.message).message;
                } catch (e) {
                    message = err.body.message;
                }
                const event = new ShowToastEvent({
                    variant: "error",
                    title: "Error",
                    message
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                });
    }
}