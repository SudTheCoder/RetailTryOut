import { LightningElement, track, wire} from 'lwc';
import getCustomersList from '@salesforce/apex/ASDAC_CustomerDetailSearch.getCustomersList';
import Customers_Not_Found from "@salesforce/label/c.Customers_Not_Found";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const COLUMNS = [
	{label: "Name", fieldName: "Name", type: "button", typeAttributes: { label: { fieldName: "Name" }, variant: "base" }, wrapText: true},
	{ label: "Email", fieldName: "PersonEmail", type: "email", wrapText: true },
	{ label: "Phone", fieldName: "Phone", type: "phone", wrapText: true },
	{ label: "Address Line 1", fieldName: "AddressLine1__pc", wrapText: true },
	{ label: "Postcode", fieldName: "PostalCode__pc", type: "text", wrapText: true }
];
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { checkPhoneNumberFormats } from 'c/asdacUtilCmp';
import ASDAC_PostCodeSpaceError from "@salesforce/label/c.ASDAC_PostCodeSpaceError";
import ASDAC_Postcode from "@salesforce/label/c.ASDAC_Postcode";
import ASDAC_FirstName from "@salesforce/label/c.ASDAC_FirstName";
import ASDAC_LastName from "@salesforce/label/c.ASDAC_LastName";
import ASDAC_HouseNameNumber from "@salesforce/label/c.ASDAC_HouseNameNumber";
import ASDAC_ContactNumber from "@salesforce/label/c.ASDAC_ContactNumber";
import ASDAC_Email from "@salesforce/label/c.ASDAC_Email";
import ASDAC_Search from "@salesforce/label/c.ASDAC_Search";
import ASDAC_Clear from "@salesforce/label/c.ASDAC_Clear";
import ASDAC_CreateNewCustomer from "@salesforce/label/c.ASDAC_CreateNewCustomer";
import ASDAC_Previous from "@salesforce/label/c.ASDAC_Previous";
import ASDAC_Next from "@salesforce/label/c.ASDAC_Next";
import ASDAC_ErrorMsg from "@salesforce/label/c.ASDAC_ErrorMsg";
import ErrorTitle from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ASDAC_CreateCustomerPermission from '@salesforce/customPermission/ASDAC_CreateCustomerPermission';

export default class AsdacCustomerSearchUpgradedCmp extends NavigationMixin(LightningElement) {
    label = {
        ASDAC_Postcode,
        ASDAC_FirstName,
        ASDAC_LastName,
        ASDAC_HouseNameNumber,
        ASDAC_ContactNumber,
        ASDAC_Email,
        ASDAC_Search,
        ASDAC_Clear,
        ASDAC_CreateNewCustomer,
        ASDAC_Previous,
        ASDAC_Next,
        Customers_Not_Found,
        ASDAC_ErrorMsg
    };
    //Pagination Attributes
    paginationList = [];
    pgSize = 25;
    startIndex;
    isNextDisabled;
    isPreviousDisabled;
    startPosition;
    endPosition;
    totalSize;
    personAccRecTypeId;

    //Columns
    columns = COLUMNS;
    @track
    searchDetails = {
        countryCode : '44'
    };
    listOfAccounts = [];
	customers = null;
    customersExist = false;
    loading = false;
    listOfPopulatedFields = [];
	showNewCustomerBtn = false;

    @track
    countryCodeOptions;
    accountObj = {
        CountryCode__c : '44'
    };

	get showNewCustomer() {
		return this.showNewCustomerBtn && ASDAC_CreateCustomerPermission ? true : false;
	}

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    wireGetObjectInfo({ data, error }) {
        if (error) {
            const event = new ShowToastEvent({
                title: ErrorTitle,
                variant: "error",
                message: error.body.message
            });
            this.dispatchEvent(event);
        } else if (data) {
            // Returns a map of record type Ids 
            const rtis = data.recordTypeInfos;
            this.personAccRecTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Person Account');
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$personAccRecTypeId", fieldApiName: "Account.CountryCode__c" })
	wireCountryCodePicklist({ data, error }) {
		if (error) {
			const event = new ShowToastEvent({
				title: ErrorTitle,
				variant: "error",
				message: error.body.message
			});
			this.dispatchEvent(event);
		} else if (data) {
            let picklistValues = JSON.parse(JSON.stringify(data.values));
            if(picklistValues) {
                picklistValues.forEach((option) => {
                    option.label = `+${option.label}`;
                });
                this.countryCodeOptions = picklistValues;
            }
		}
	}

    onChangeHandler(event) {
        if(event.target.name === 'postalCode'){
            const nonAlphanumericRegex = /[^a-zA-Z0-9\s]/g;
            let postCodeValue = event.target.value;
	    event.target.value = postCodeValue.replace(nonAlphanumericRegex, '');
        }  
        this.searchDetails[event.target.name] = event.target.value;
        this.accountObj[event.target.dataset.fieldName] = event.target.value;
        this.checkPostalCodeRequired(event);
        if(event.target.name === 'phone'){
            this.checkPhoneNumberFormats();
        }  
    }

    async handleSearch() {
        this.customers = null;
        this.customersExist = false;
        let hasValue = false;
        
        let postalCodeFld = this.template.querySelector("lightning-input[data-id='postalCode']");
        postalCodeFld.setCustomValidity('');
        if(postalCodeFld.value?.trim().split(' ').length > 2) {
            postalCodeFld.setCustomValidity(ASDAC_PostCodeSpaceError);
            postalCodeFld.reportValidity(); 
            return;
        } 
        if(this.searchDetails.postalCode) {
            this.searchDetails.postalCode = this.searchDetails.postalCode.trim();
        }
        let isValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
            }, true);
        for(let key in this.searchDetails) {
            if(key === 'countryCode') {
                continue;
            }
            if(this.searchDetails[key]) {
                hasValue = true;
                break;
            }
        }
        if(!hasValue) {
            const event = new ShowToastEvent({
                title: ErrorTitle,
                variant: "error",
                message: ASDAC_ErrorMsg
              });
            this.dispatchEvent(event); 
            return;     
        }
        if(isValid) {
            this.getCustomerListFromServer();
        }
    }

    getCustomerListFromServer() {
        this.loading = true;
        getCustomersList({stringifiedSearchWrapper : JSON.stringify(this.searchDetails)}).then(result => {
            this.loading = false;
            if(result.isSuccess) {
                this.showNewCustomerBtn = true;
                if(result.hasPostalCodeError) {
                    Promise.resolve().then(() => {
                        let postalCodeElmnt = this.template.querySelector("lightning-input[data-id='postalCode']");
                        postalCodeElmnt.required = true;
                        postalCodeElmnt.setCustomValidity(result.message);
                        postalCodeElmnt.reportValidity();
                    })                        
                }
                this.customers = result.listOfAccounts.map((customer) => {
                    return {
                        ...customer,
                        Phone: customer.CountryCode__c ? `+${customer.CountryCode__c} ${customer.Phone}` : customer.Phone
                    };
                });
                if(this.customers.length) {
                    this.customersExist = true;
                    let endIndex = this.pgSize - 1;
                    this.populatePaginatedList(0, endIndex);
                }
            }
            else {
                const event = new ShowToastEvent({
                    title: ErrorTitle,
                    variant: "error",
                    message: result.message
                  });
                this.dispatchEvent(event);
            }
        }).catch(error => {
                this.loading = false;
        });
    }

    populatePaginatedList(startIndex, endIndex) {
		let fullList = this.customers;
        let paginatedList = [];
        for(let i = startIndex ; i <= endIndex ; i++) {
            if(i < fullList.length) {
        		paginatedList.push(fullList[i]);
            }
            else {
                break;
            }
        }
        this.paginationList = paginatedList;
        this.startIndex = startIndex;
        let hasNext = endIndex < (fullList.length -  1) ? true : false;
        let hasPrevious = (startIndex != 0) ? true : false;
        this.isNextDisabled = !hasNext;
        this.isPreviousDisabled = !hasPrevious; 
        this.startPosition = startIndex + 1;
        this.endPosition = startIndex + paginatedList.length;
        this.totalSize = fullList.length;
    }
    

    handleNext() {
    	let startIndex = this.startIndex;
    	let pageSize = this.pgSize;
        startIndex = startIndex + pageSize;
        let endIndex   = startIndex + (pageSize - 1);
        this.populatePaginatedList(startIndex, endIndex);	
    }

    handlePrevious() {
    	let startIndex = this.startIndex;
    	let pageSize = this.pgSize;
        startIndex = startIndex - pageSize;
        let endIndex   = startIndex + (pageSize - 1);
        this.populatePaginatedList(startIndex, endIndex);	
    }

    viewCustomer(event) {
		const record = event.detail.row;
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: record.Id,
				actionName: "view"
			}
		});
        const closeUtility = new CustomEvent("minimizetab", {bubbles: true , composed : true});
        this.dispatchEvent(closeUtility);  
    }

    handleClear(event) {
        this.searchDetails = {
            countryCode : '44'
        };
        this.accountObj = {
            CountryCode__c : '44'
        };
        this.customers = null;
        this.customersExist = false;
        this.loading = false;
        this.listOfPopulatedFields = [];
        this.showNewCustomerBtn = false;
        Promise.resolve().then(() => {
            [...this.template.querySelectorAll("lightning-input")].forEach((element) => {
                if(element.dataset.id === 'postalCode') {
                    element.required = false       
                } 
                element.setCustomValidity('');
                element.reportValidity();           
            });
        })
    }

    checkPostalCodeRequired(event) {
        //populating the list of fields that are populated. we are ignoring country code.
        if(event.target.value && !this.listOfPopulatedFields.includes(event.target.name) && event.target.name !== 'countryCode') {
            this.listOfPopulatedFields.push(event.target.name);
        }
        //removing the field from populated list if it got blank.
        else if(!event.target.value) {
            const index = this.listOfPopulatedFields.indexOf(event.target.name);
            if(index > -1) {
                this.listOfPopulatedFields.splice(index, 1);
            }
        }
        //logic if postal code is required.
        //1. If FirstName or LastName or FirstName&LastName is provided, and no other field is provided, show message to enter PostCode also.
        //2. If Address is provided, but postcode is not provided, show message to enter PostCode also.
        if((this.listOfPopulatedFields.length === 1 && (this.listOfPopulatedFields.includes('firstName') || this.listOfPopulatedFields.includes('lastName'))) ||
           (this.listOfPopulatedFields.length === 2 && (this.listOfPopulatedFields.includes('firstName') && this.listOfPopulatedFields.includes('lastName'))) ||
           this.listOfPopulatedFields.includes('address')) {
            Promise.resolve().then(() => {
                this.template.querySelector("lightning-input[data-id='postalCode']").required = true;                   
            })
        }
        else {
            Promise.resolve().then(() => {
                let postalCodeElmnt = this.template.querySelector("lightning-input[data-id='postalCode']");
                postalCodeElmnt.required = false
                postalCodeElmnt.setCustomValidity('');
                postalCodeElmnt.reportValidity();                               
            })
        }
    }

    createCustomer() {
		this.dispatchEvent(new CustomEvent("opennewcustomer", { bubbles: true , composed : true, detail: { accountObj: this.accountObj } }));
        const event = new CustomEvent("minimizetab", {bubbles: true , composed : true});
        this.dispatchEvent(event);
    }
    
    checkPhoneNumberFormats() {
        const countryCodeFld = this.template.querySelector('.countryCodeClass');
        let phoneFld = this.template.querySelector('.phone');
        Promise.resolve().then(() => {
            if(!phoneFld.value.startsWith('0') && countryCodeFld.value == '44') {
                phoneFld.value = '0' + phoneFld.value;
            }
            checkPhoneNumberFormats(countryCodeFld, phoneFld);
        });
    }

    handleEnter(event){
		if(event.keyCode === 13){
            this.handleSearch();
		}
    }

    checkPostCodeValidations(event) {
        let postalCodeFld = event.target;
        postalCodeFld.setCustomValidity('');
        if(postalCodeFld.value?.trim().split(' ').length > 2) {
            postalCodeFld.setCustomValidity(ASDAC_PostCodeSpaceError);
        } 
        postalCodeFld.reportValidity(); 
    }
}