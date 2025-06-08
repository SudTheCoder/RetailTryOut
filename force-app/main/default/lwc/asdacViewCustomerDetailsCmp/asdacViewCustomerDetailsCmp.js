//Import LWC Libraries
import { LightningElement, wire, api,track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {publish, MessageContext} from 'lightning/messageService';
import consoleMessageChannel from '@salesforce/messageChannel/consoleMessageChannel__c';
import AccountSuspend from '@salesforce/label/c.AccountSuspendLabel';
import AccountSuspendDate from '@salesforce/label/c.AccountSuspendedDateLabel';
import UnderAuditLabel from '@salesforce/label/c.UnderAuditLabel';
import UnderAuditDate from '@salesforce/label/c.UnderAuditDateLabel';
import OrderNotFoundLabel from '@salesforce/label/c.ASDAC_OrderNotFoundLabel';
import DeliveryPassOrderFulfillmentType from '@salesforce/label/c.ASADC_DeliveryPassOrderFulfillmentType';
//ASDAC-2024 - STARTS
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
//ASDAC-2024 - ENDS

//Import Resources
import HideLightningHeader from '@salesforce/resourceUrl/ASDAC_CustomerDetails';

//Import Apex Methods
import getOrder from '@salesforce/apex/ASDAC_OrderController.getOrder';
//ASDAC-2024 - STARTS
import ID_FIELD from '@salesforce/schema/Case.Id';
import ORDERID_FIELD from '@salesforce/schema/Case.OrderId__c';
import BUSINESS_AREA_FIELD from '@salesforce/schema/Case.BusinessArea__c';
//ASDAC-2024 - ENDS

const fields = [ID_FIELD, ORDERID_FIELD, BUSINESS_AREA_FIELD];

export default class AsdacViewCustomerDetailsCmp extends NavigationMixin(LightningElement) {
	//customerName : Customer Name
	@api customerName;
	//customer : Customer Details
	@api customer;
	//orderId : Searched Order Id
	@api orderId;
	//businessArea : Searched Business area
	@api businessArea;
	//Payment Card Reference : Payment Card Reference
	@api cardRefId;
	//isSearched : Set to True if searched from Order Search
	@api isSearched;
	//orderWrapper : Whole details of Orders, Order Items
	@api orderWrapper;
	//isGeorge : Indicates if it's George or Grocery
	@api isGeorge;
	//caseId : ASDAC-2024 : Indicates Id of the case record
	@api caseId;
	//recordId : ASDAC-2024 : Get Id of the case record
	@api recordId;
	@track responseJSON = "";
	@track subscription = null;
	@track riskStatusClass;
	@track isLoading = true;

	casePageError;
	label = {
		AccountSuspend,
		AccountSuspendDate,
		UnderAuditLabel,
		UnderAuditDate

	};

	@wire(MessageContext)
	messageContext;

	//Load Static Resource to hide default App Panel and set Title of Browser tab as searched Order Id
	@wire(getRecord, { recordId:'$recordId', fields })
	loadFields({error, data}) {
		if (error) {
			console.log('error', JSON.parse(JSON.stringify(error)));
		} else if (data) {
			this.orderId = getFieldValue(data, ORDERID_FIELD);
			this.businessArea = getFieldValue(data, BUSINESS_AREA_FIELD);
			loadStyle(this, HideLightningHeader);
			if (this.orderId != null) {
				document.title = this.orderId;
				this.getAllOrderDetails();
			}
		}
	}

	publishLMSRequest(){
		const payload = { message : {
			isOrderFound: true,
			errorMessage: ''
		}};
		publish(this.messageContext, consoleMessageChannel, payload);
	}

	get subscribeStatus() {
		return this.subscription ? 'TRUE' : 'FALSE';
	}

	//Fetch the URL parameters and callout to get the order related details 
	@wire(CurrentPageReference)
	getStateParameters(currentPageReference) {
		if (currentPageReference) {
			this.urlStateParameters = currentPageReference.state;
			this.setParametersBasedOnUrl();
		}
	}
	//Set URL parameters in variables
	setParametersBasedOnUrl() {
		this.orderId = this.urlStateParameters.uid || null;
		this.businessArea = this.urlStateParameters.c__businessArea;
		this.isSearched = this.urlStateParameters.c__searched || null;
		this.cardRefId = this.urlStateParameters.c__cardRef || null;

		if (this.orderId === 'blank') {
			this.orderId = null;
			if (this.cardRefId != null) {
				document.title = this.cardRefId;
			}
		}
		//ASDAC-2024 - STARTS
		this.caseId = this.urlStateParameters.c__caseId || null;
		if (this.recordId && this.recordId.startsWith('500')) {
			this.caseId = this.recordId;
		}

		if(this.orderId != null){
			this.getAllOrderDetails(); 
		}
		//ASDAC-2024 - ENDS
	}
	//Get customer name and order details from Apex
	async getAllOrderDetails() {
		try {
			const orderDetailsParameters = {
				orderId: this.orderId,
				businessArea: this.businessArea
			};

			const result = await getOrder(orderDetailsParameters);
			
			if (result.orderType === 'ReshipOrder' || result.fulfillmentType === DeliveryPassOrderFulfillmentType) {
				this.isError = true;
				let customError = {}
				customError.message = OrderNotFoundLabel;
				throw customError;
			}
			this.orderWrapper = result;
			this.customerName = result.customerName;
			this.isGeorge = result.sellingChannel === "GEORGE.COM";

			if(this.isGeorge){
				this.orderWrapper.billToContact.phone = this.orderWrapper.customerPhone;
			}
			this.error = undefined;

			//ASDAC-2024 - STARTS
			if (this.caseId && this.caseId !== this.recordId && this.orderId) {
				const fields = {};
				fields[ID_FIELD.fieldApiName] = this.caseId;
				fields[ORDERID_FIELD.fieldApiName] = this.orderId;
				const recordInput = { fields };
				try {
					await updateRecord(recordInput)
					const event = new ShowToastEvent({
						variant: "Success",
						message: 'Case updated',
						title: 'Success'
					});
					this.dispatchEvent(event);
				} catch (error) {
					const event = new ShowToastEvent({
						variant: "Error",
						message: this.getErrorMessage(error),
						title: 'Error creating record'
					});
					this.dispatchEvent(event);
				}
				//ASDAC-2024 - ENDS
			}
			this.isLoading = false;
		} catch(error) {
			let message = this.getErrorMessage(error);
			const event = new ShowToastEvent({
				variant: "Error",
				message,
				title: "Error"
			});
			this.dispatchEvent(event);
			this.error = error;
			this.orderWrapperList = undefined;
			if (this.caseId || this.urlStateParameters.c__casePage) {
				this.casePageError = message;
			}
			const closeTab = new CustomEvent('closeordertab', {bubbles: true , composed : true});
			this.dispatchEvent(closeTab);
		
			this.isLoading = false;
		}
	}

	handleRefreshOrder() {
		this.isLoading = true;
		this.orderWrapper = null;
		this.getAllOrderDetails();
	}

	handleCustomerOnClick()
	{
		const customerId = this.orderWrapper.customerSalesforceAccId;
		if(customerId){
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
			recordId: customerId,
			actionName: 'view'
			},
		});
		}

	}

	handleTimeout(evt) {
		this.isLoading = true;
		const timeout = evt.detail;
		const order = { ...this.orderWrapper };
		this.orderWrapper = null;
		Object.assign(order, timeout);
		order.orderItems.forEach((orderLine) => {
			Object.assign(orderLine, timeout);
		});
		setTimeout(() => {
			this.orderWrapper = order;
			this.isLoading = false;
		}, 10);
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
}