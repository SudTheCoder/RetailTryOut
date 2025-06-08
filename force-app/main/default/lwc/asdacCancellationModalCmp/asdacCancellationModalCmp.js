import { LightningElement, track ,api} from 'lwc';
import cancelReasonsLbl from '@salesforce/label/c.ASDAC_CancellationReasonOptions';
import cancelReasonsGHSLbl from '@salesforce/label/c.ASDAC_CancellationReasonOptionsGHS';
import cancelOrderHeader from '@salesforce/label/c.ASDAC_CancelOrderHeader';
import cancelRequesttoStoreHeader from '@salesforce/label/c.ASDAC_CancelRequesttoStoreHeader';
import cancelOrderHeaderReasonCodeLabel from '@salesforce/label/c.ASDAC_CancelOrderHeaderReasonCodeLabel';
import cancelRequesttoStoreReasonCodeLabel from '@salesforce/label/c.ASDAC_CancelRequesttoStoreReasonCodeLabel';
import cancelOrder from "@salesforce/apex/ASDAC_OrderController.cancelOrder";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {FlowNavigationNextEvent} from 'lightning/flowSupport';
export default class AsdacCancellationModalCmp extends LightningElement {
	@api exitButtonClicked=false;
    @api isGeorge;
	@track isLoading = true;
	@track cancelReasons=[];
	@api isCancelRequesttoStore;
	@api refundToCreateStr;
	@api isSuccess = false;
	@api toastMessage;
	cancelOrderHeader;
	reasonCodeLabel;
	@api itemsFromFlow;

	connectedCallback() {
		if (this.isGeorge === false) {
			const cancelReasonsList = cancelReasonsGHSLbl.split(',');
			for (const cancReason of cancelReasonsList) {
				this.cancelReasons = [...this.cancelReasons, { label: cancReason.trim(), value: cancReason.trim() }];
			}
		}
		else {
			const cancelReasonsList = cancelReasonsLbl.split(',');
			for (const cancReason of cancelReasonsList) {
				this.cancelReasons = [...this.cancelReasons, { label: cancReason.trim(), value: cancReason.trim() }];
			}
		}
		if(this.isCancelRequesttoStore!== undefined && this.isCancelRequesttoStore)
		{
			this.cancelOrderHeader = cancelRequesttoStoreHeader;
			this.reasonCodeLabel =cancelRequesttoStoreReasonCodeLabel;
		}
		else{
			this.cancelOrderHeader= cancelOrderHeader;
			this.reasonCodeLabel= cancelOrderHeaderReasonCodeLabel;
		}
		this.isLoading = false;
	}

	resolveValidityIssues(reasonValue, targetInput){
		if(reasonValue){
			targetInput.setCustomValidity('');
			targetInput.reportValidity();
		}
	}

	handleReasonChange(event){
		this.resolveValidityIssues(event.target.value, event.target);
		let lstflowObj= [];
		let flowObj ={cancelReason : event.target.value};
		lstflowObj.push(flowObj);
		this.refundToCreateStr = JSON.stringify(lstflowObj);
	}

	handleCancel(){
		this.flowNavigationEvents();
		this.exitButtonClicked=true;
	}
	

	handleSubmit(){
		let isReasonValid = true;
		let requiredMessage = 'Reason is required.';
		let cancelReason = this.template.querySelector(".oiBulkReasonCls");
		if(cancelReason.value === undefined || cancelReason.value === '' || cancelReason.value === null){
			isReasonValid = false;
			cancelReason.setCustomValidity(requiredMessage);
			cancelReason.reportValidity();
		}
		if(isReasonValid && !this.isCancelRequesttoStore){
			this.callCancellationOrderMethod();	
		}
		else if(isReasonValid){ // no integration done
			this.isSuccess = true;
			this.toastMessage = 'Order cancel request sent to store.';
			this.flowNavigationEvents();
		}
	}

	flowNavigationEvents(){
		const navigateNextEvent = new FlowNavigationNextEvent();
		this.dispatchEvent(navigateNextEvent);
	}

	callCancellationOrderMethod()
	{

		const cancelOrderItems = JSON.parse(this.itemsFromFlow);
		let reasonCode = this.template.querySelector(".oiBulkReasonCls").value;

		const order = {sellingChannel: cancelOrderItems.sellingChannel, orderId: cancelOrderItems.orderId, customerId: cancelOrderItems.customerId, reason:reasonCode, orderLines: cancelOrderItems.orderItems};
		
		cancelOrder({order})
		.then(() => {
			this.isLoading = false;
			this.flowNavigationEvents();
			})
			.catch((err) => {
				console.error(err);
			let message = err.message;
			if(err.body)
			{
			try {
				message = JSON.parse(err.body.message).message;
			} catch (e) {
				message = err.body.message;
			}
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