import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import Case from '@salesforce/schema/Case';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import DEFAULT_CASE_STATUS from '@salesforce/label/c.ASDAC_DefaultCaseStatus';
import  getStoreId from "@salesforce/apex/ASDAC_OrderController.getStoreId";
import FULFILLMENT_LOGO from '@salesforce/resourceUrl/ASDAC_FulfillmentOrderLogo';
import GROCERY_FULFILLMENT_LOGO from '@salesforce/resourceUrl/ASDAC_GroceryFulfillmentOrderLogo';
import getCustomerIdFromCallout from "@salesforce/apex/ASDAC_CustomerSearch.getCustomerIdFromCallout";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isPFTeamPermission from '@salesforce/customPermission/PF_Team_Permission';
import isGHSPermission from '@salesforce/customPermission/ASDAC_GHSAccessPermission';
import ASDAC_SuspendedAccount from '@salesforce/label/c.ASDAC_SuspendedAccount';
import ASDAC_Unsuspend_Account from '@salesforce/label/c.ASDAC_Unsuspend_Account';
import ASDAC_UnderAuditLabel from '@salesforce/label/c.ASDAC_UnderAuditLabel';
import ASDAC_Remove_Audit from '@salesforce/label/c.ASDAC_Remove_Audit';
import ASDAC_Log_Action from '@salesforce/label/c.ASDAC_Log_Action';
import contactReasonLevel2 from '@salesforce/label/c.ASDAC_ContactReasonLevel2Value';
import getParentCaseIdVatReceipt from "@salesforce/apex/ASDAC_CaseSelector.getVATParentCase";
import generatePdf from '@salesforce/apex/ASDAC_DownloadVatReceiptController.generatePdf';
import {updateRecord} from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Case.Id';
import IS_VAT_RECEIPT_GENERATED_FIELD from '@salesforce/schema/Case.IsVatReceiptGenerated__c';
import ASDAC_Vat_Case_not_found from '@salesforce/label/c.ASDAC_VAtCaseNotFound';
import ASDAC_Toast_No_VAT_Case from '@salesforce/label/c.ASDAC_ToastNoVATCase';
import ASDAC_ghsHideCancellationTooltipReasonCodes from '@salesforce/label/c.ASDAC_ghsHideCancellationTooltipReasonCodes';
import getOrder from '@salesforce/apex/ASDAC_OrderController.getOrder';

export default class AsdacOrderSpecificDetailsCmp extends NavigationMixin(LightningElement) {
    @api orderWrapper;
    @api isGeorge;
    @api caseId;
    @track isShowCancelModal;
    @track showManualTransModal = false;
    @track showRefundGeorgeModal = false;
    @track showYNumber = false;
    @track flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
    isManualCardDisplayed = false;
    @track isModalOpen = false;
    @track showPaymentMethod = false;
    @track noRecTypeFound;
    @track customerSupportRecTypeId;
    @track yNumberText = 'Show Y-numbers';
    @track isDeliveryChargeRefundButton = false;
	isDisabled=true;
	fulfillmentOrder= FULFILLMENT_LOGO;
	groceryFulfillmentLogo= GROCERY_FULFILLMENT_LOGO;
    showCancelButton = true;
    orderStatus;
    showCancelledFields = false;
    exchangeOrderList = [];
    @track isCancelRequesttoStore = false;
    // New tracked property to disable duplicate "Cancel Request to Store" clicks.
    @track canceltostoreclicked = false;
    showRefundGroceryModal = false;
    @track isSuspendUnsuspendUnderAuditRemoveAudit = false;
    @track isVATEnabled;
    @track downloadVat = false;
    @track orderId;
    @track caseVatID;
    @track isVATRecipetDownloaded = false;
    @track isLoading = false;
    @track cancelledStatusHelpText;
    @track showCancelHelpText = false;
	

    label = {
        ASDAC_SuspendedAccount,
        ASDAC_Unsuspend_Account,
        ASDAC_UnderAuditLabel,
        ASDAC_Remove_Audit,
        ASDAC_Log_Action
    };

    @wire(getObjectInfo, { objectApiName: Case })
	Function({ error, data }) {
        if (data) {
            for (let key in data.recordTypeInfos) {
                if (data.recordTypeInfos[key].name === 'Customer Support') {
                    this.customerSupportRecTypeId = key;
                    this.noRecTypeFound = false;
                }
            }
        }
        if (error) {
            this.noRecTypeFound = true;
        }
    }

    async connectedCallback() {
		if(this.orderWrapper.exchangeOrders){
            this.getExchangeOrderList();
        }
		this.isDisabled= (this.isGeorge === false && this.orderWrapper.orderLevelStatus!=='Cancelled') ? false : true ;
		this.showCancelledFields = (this.isGeorge === false && this.orderWrapper.orderLevelStatus!=='Cancelled') ? false : true ;
        this.isDeliveryChargeRefundButton = this.orderWrapper.isDeliveryChargeRefundDisabled;
		this.showCancelButton = this.isGeorge === true ? false : true;
        this.orderId = this.orderWrapper.orderId;

		if(!this.orderWrapper.isVATEnabled)
		{
            let caseVatReturnID = await this.getParentCaseIdVatReceipt();
            this.isVATRecipetDownloaded = (caseVatReturnID !== null && caseVatReturnID !== '') ? false : true;
		}
		else
		{
            this.isVATRecipetDownloaded = true;
        }

        const ghsHideCancelTooltipReasonCodes = ASDAC_ghsHideCancellationTooltipReasonCodes.split(',');
        this.showCancelHelpText = this.showCancelledFields && ghsHideCancelTooltipReasonCodes.includes(this.orderWrapper.cancellationReasonCode);
        this.cancelledStatusHelpText = this.orderWrapper.cancellationReason;

		
    }

    get isDeliveryPass() {
        return this.orderWrapper.isDeliveryPassUsed ? 'Yes' : 'No';
    }

  get hasPFTeamAccess(){
        return isPFTeamPermission;
    }
  get hasGHSAccess(){
        return isGHSPermission;
    }

	get hasYNumbers(){
        return this.exchangeOrderList.length === 0 ? false : true;
    }

    // Computed getter for disabled status on the Cancel Request to Store menu item.
    get cancelrequestdisabled() {
        return this.orderWrapper.isStoreCancelDisabled || this.canceltostoreclicked;
    }

    @track isOnCaseRecord;
    @track caseRecordId = '';
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

    handleFlowStatusChange(event) {
        let refreshWindow = true;
        if (event.detail.status === 'FINISHED') {
            this.showRefundGeorgeModal = false;
            this.isSuspendUnsuspendUnderAuditRemoveAudit = false;
            this.showRefundGroceryModal = false;
            const outputVariables = event.detail.outputVariables;
			if(outputVariables){
			for(let outputVar of outputVariables) {
				if(outputVar.name === 'exitButtonClicked'){
					refreshWindow = !(outputVar.value);
                    }
                }
            }
			if(refreshWindow){
				const refreshOrderEvent = new CustomEvent("refreshorder", { bubbles: true, composed: true });
                this.dispatchEvent(refreshOrderEvent);
            }
        }
    }

	getExchangeOrderList(){
        const exchangeOrders = this.orderWrapper.exchangeOrders;
		this.exchangeOrderList = exchangeOrders.filter(order => order.orderCategory?.toLowerCase() !== 'reship').map(element => element.orderId);
    }

	handleNavigateExchangeOrder(event){
        const orderId = event.detail.value;
        this.dispatchEvent(new CustomEvent('openorderdetail', {
			bubbles: true , 
			composed : true, 
            detail: {
				//c__recordId: customer.ExternalId__c,
                uid: orderId,
                c__searched: true
            }
        }));
    }

    setFlowInputVariables(buttonActionName) {
        this.showRefundGeorgeModal = true;
        this.flowInputVariables = [
            { name: 'orderId', type: 'String', value: this.orderWrapper.orderId },
            { name: 'customerId', type: 'String', value: this.orderWrapper.customerId },
            { name: 'isOnCaseRecord', type: 'Boolean', value: this.isOnCaseRecord },
            { name: 'CaseRecordId', type: 'String', value: this.caseRecordId },
            { name: 'buttonActionName', type: 'String', value: buttonActionName },
			{ name: 'orderWrapperString', type: 'String', value: JSON.stringify(this.orderWrapper)},
			{ name: 'isGeorgeOrNot', type: 'Boolean', value: this.isGeorge}
        ];
		if ( buttonActionName==='CANCEL' && this.isCancelRequesttoStore===true) {
			if (this.orderWrapper.storeNumber === undefined || this.orderWrapper.storeNumber === '' || this.orderWrapper.storeNumber === null) {
				//do nothing
			}
			else{
				this.flowInputVariables.push({name: 'storeNumber', type:'String', value: this.orderWrapper.storeNumber });
            }
			this.flowInputVariables.push({name: 'isCancelRequesttoStore', type: 'Boolean', value: this.isCancelRequesttoStore});
			this.flowInputVariables.push({name: 'customerAddress1', type:'String', value: this.orderWrapper.billToAddress.addressLine1 });
			this.flowInputVariables.push({name: 'customerAddress2', type:'String', value: this.orderWrapper.billToAddress.addressLine2 });
			this.flowInputVariables.push({name: 'customerAddressCity', type:'String', value: this.orderWrapper.billToAddress.city });
			this.flowInputVariables.push({name: 'customerAddressZipCode', type:'String', value: this.orderWrapper.billToAddress.zipCode });
        }
        if(buttonActionName==='Suspend Account'|| buttonActionName==='Unsuspend Account' || buttonActionName==='Under Audit' || buttonActionName==='Remove Audit'){
            this.flowInputVariables=[];
            this.flowInputVariables.push({name: 'recordId', type: 'String', value: this.orderWrapper.customerSalesforceAccId});			
        }
    }

    handleShippingFeeRefundClick(){
        this.flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
        this.setFlowVariable();
        this.setFlowInputVariables('SHIPPING FEE REFUND');
    }


    handleCancelOrderClick(){
        this.isCancelRequesttoStore = false;
        this.setFlowVariable();
        this.setFlowInputVariables('CANCEL');
    }

    handleCancelRequestOrderClick() {
        // Prevent duplicate cancellation requests
        if (this.canceltostoreclicked) {
            return;
        }
        this.canceltostoreclicked = true;
        this.isCancelRequesttoStore = true;
        this.setFlowVariable();
        this.setFlowInputVariables('CANCEL');
    }

    handleSuspendAccountClick(){
        this.flowApiName="ASDAC_AccountSuspensionFlow";
        this.setFlowVariable();
        this.setFlowInputVariables('Suspend Account');
        this.isSuspendUnsuspendUnderAuditRemoveAudit = true;
    }

    handleUnsuspendAccountClick(){
        this.flowApiName="ASDAC_UnsuspendAccountFlow";
        this.setFlowVariable();
        this.setFlowInputVariables('Unsuspend Account');
        this.isSuspendUnsuspendUnderAuditRemoveAudit = true;
    }

    handleUnderAuditClick(){
        this.flowApiName="ASDAC_Account_Under_Audit";
        this.setFlowVariable();
        this.setFlowInputVariables('Under Audit');
        this.isSuspendUnsuspendUnderAuditRemoveAudit = true;
    }

    handleRemoveAuditClick(){
        this.flowApiName="ASDAC_RemoveAuditNotesFlow";
        this.setFlowVariable();
        this.setFlowInputVariables('Remove Audit');
        this.isSuspendUnsuspendUnderAuditRemoveAudit = true;
    }

	async getOrderStoreId(){
        const orderId = this.orderWrapper.orderId;
		const businessArea = this.isGeorge ?  'George' : 'Grocery';
		const result = await getOrder({orderId, businessArea});
        const storeNumber = result.storeNumber != '0' ? result.storeNumber : '0000';
		const storeId = await getStoreId({storeNumber});
        return storeId;
    }

    async handleCreateCaseClick(){	
        const storeId = await this.getOrderStoreId();
        const defaultValues = encodeDefaultFieldValues({
		    BusinessArea__c : this.isGeorge ?  'George' : 'Grocery',
            OrderId__c: this.orderWrapper.orderId,
            ContactId: this.orderWrapper.customerSalesforceConId,
            AccountId: this.orderWrapper.customerSalesforceAccId,
			Status : DEFAULT_CASE_STATUS,//Assigned
            CreatedfromOrder__c: true,
            Store__c: storeId
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
				actionName: 'new',
            },
            state: {
                useRecordTypeCheck: 1,
				  defaultFieldValues:defaultValues
            }
        });
    }

    handleManualCardTransaction(){
        this.showManualTransModal = true;
    }

	handleOrderLevelRefund(){
        this.showRefundGroceryModal = true;
        this.flowApiName = 'ASDAC_OrderDetailsActionScreenFlow';
        this.setFlowVariable();
        this.setFlowInputVariables('ORDER LEVEL REFUND');
        this.showRefundGeorgeModal = false;
    }

    handleCloseModal(){
        this.showManualTransModal = false;
        this.showPaymentMethod = false;
        this.isShowCancelModal = false;
		this.showRefundGeorgeModal =false;
        this.showRefundGroceryModal = false;
        this.isSuspendUnsuspendUnderAuditRemoveAudit = false;
        this.downloadVat = false;
    }
    handlePaymentMethodClick(){
        this.showPaymentMethod = true;
    }

    handleShowYNumberSection(){
        if(!this.showYNumber){
            this.showYNumber = true;
        }else{
            this.showYNumber = false;
        }
        if(this.yNumberText === 'Show Y-numbers'){
            this.yNumberText = 'Hide Y-numbers';
        }else{
            this.yNumberText = 'Show Y-numbers';
        }
    }

	handleParentOrderClick(){
		
        getCustomerIdFromCallout({ orderId: this.orderWrapper.salesOrderId })
            .then((result) => {
				if (!result.isSuccess) {throw new Error(result.message);} // handled by catch block
				
                this.dispatchEvent(new CustomEvent('openorderdetail', {
						bubbles: true , 
						composed : true, 
                    detail: {
                        uid: this.orderWrapper.salesOrderId,
                        c__searched: true
                    }
                }));
            })
            .catch((error) => {
                let toastEvent = new ShowToastEvent({
                    title: "Error",
                    variant: "error",
                    message: error.message
                });
                this.dispatchEvent(toastEvent);
                this.customers = null;
                this.loading = false;
            });
			
    }

	async handleDownloadVAT(){
        this.downloadVat = true;
        this.caseVatID = await this.getParentCaseIdVatReceipt();

			if(this.caseVatID == ASDAC_Vat_Case_not_found)
			{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: ASDAC_Toast_No_VAT_Case,
                    variant: 'info'
                })
            );
			}	
			else
			{
            this.isLoading = true;
            await this.insertCaseFilesVATReceipt();
				
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.caseVatID,
                    objectApiName: 'Case',
                    actionName: 'view'
					},
            });
            this.isVATRecipetDownloaded = true;
    }


	}
	createTask(){
        const defaultValues = {
			Business_Area__c : this.isGeorge ?  'George' : 'GHS',
            Order_Number__c: this.orderWrapper.orderId,
			OriginalOrderTotal__c:this.orderWrapper.originalOrderTotal,
			Related_To__c:this.orderWrapper.customerSalesforceAccId,
			DateofTransaction__c:this.orderWrapper.orderDate
        };
			
        const navigateToLogAction = () => {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Log_Action__c',
				actionName: 'new',
                },
                state: {
                    useRecordTypeCheck: 1,
                    defaultFieldValues: encodeDefaultFieldValues(defaultValues)
                }
            });
        };
        if(this.orderWrapper.storeNumber) 
            getStoreId({ storeNumber: this.orderWrapper.storeNumber }).then(result => {
                defaultValues.Store_Name__c = result;
                navigateToLogAction();
            });
         else 
            navigateToLogAction();
		
    }

	async getParentCaseIdVatReceipt()
	{

		const caseVatID = await getParentCaseIdVatReceipt({orderid: this.orderId,contactReasonVatReceipt:contactReasonLevel2})
        return caseVatID;
    }

	async insertCaseFilesVATReceipt()
	{
		
		await generatePdf({ orderId: this.orderId,
			sellingChannel: this.orderWrapper.sellingChannel , caseId : this.caseVatID})

        this.isLoading = false;
		
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.caseVatID;
        fields[IS_VAT_RECEIPT_GENERATED_FIELD.fieldApiName] = true;
        const recordInput = { fields };
			updateRecord(recordInput) .then(() => {

			}) .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
		
    }
}