import { LightningElement, api, track, wire } from 'lwc';
import checkDuplicatesAndCreate from '@salesforce/apex/ASDAC_CreateNewCustomerController.checkDuplicatesAndCreate';
import createNewCustomer from '@salesforce/apex/ASDAC_CreateNewCustomerController.createNewCustomer';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { checkPhoneNumberFormats } from 'c/asdacUtilCmp';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ASDAC_PostCodeSpaceError from "@salesforce/label/c.ASDAC_PostCodeSpaceError";
import PersonalInfoLabel from "@salesforce/label/c.ASDAC_Personal_Information";
import TitleLabel from "@salesforce/label/c.ASDAC_Title";
import PhoneLabel from "@salesforce/label/c.ASDAC_Phone";
import PhoneErrorLabel from "@salesforce/label/c.ASDAC_PhoneError";
import AddressInfoLabel from "@salesforce/label/c.ASDAC_Address_Information";
import RegionLabel from "@salesforce/label/c.ASDAC_Region";
import CountryLabel from "@salesforce/label/c.ASDAC_CountryLabel";
import HastrickLabel from "@salesforce/label/c.ASDAC_Hastrick";
import PotentialDuplicateErrorLabel from "@salesforce/label/c.ASDAC_PotentialDuplicatedError";
import EmailLabel from "@salesforce/label/c.ASDAC_Email";
import PostcodeLabel from "@salesforce/label/c.ASDAC_Postcode";
import ErrorTitle from '@salesforce/label/c.ASDAC_ErrorToastTitle';
import { loadScript } from 'lightning/platformResourceLoader';
import POSTCODE_SCRIPT from '@salesforce/resourceUrl/idealPostCodeLookup';
import ASDAC_IdealPostCodeAPIKey from "@salesforce/label/c.ASDAC_IdealPostCodeAPIKey";
import ASDAC_SearchYourPostcodeLabel from "@salesforce/label/c.ASDAC_SearchYourPostcodeLabel";
import ASDAC_SearchYourPostcodeButtonLabel from "@salesforce/label/c.ASDAC_SearchYourPostcodeButtonLabel";
import ASDAC_IdealPostcodeErrorMessage from "@salesforce/label/c.ASDAC_IdealPostcodeErrorMessage";
import ASDAC_MandatoryFieldError from "@salesforce/label/c.ASDAC_MandatoryFieldError";


const COLUMNS = [
    {
        label:'Email Duplicate', 
        fieldName: '',
        cellAttributes:{ 
            iconName: {
                fieldName: 'EmailSameIcon'
            }
        }
    },
    {
        label:'Phone Duplicate', 
        fieldName: '',
        cellAttributes:{ 
            iconName: {
                fieldName: 'PhoneSameIcon'
            }
        }
    },
    {
        label: "Name",
        fieldName: "Url",
        type: "url",
        typeAttributes: { label: { fieldName: "Name" }, target: '_blank' },
        wrapText: true
    },
    {
        label: "Email",
        fieldName: "PersonEmail",
        wrapText: true
    },
    { label: "Phone", fieldName: "Phone", wrapText: true },
    { label: "Address Line 1", fieldName: "AddressLine1__pc", wrapText: true },
    {
        label: "Postcode/Zip",
        fieldName: "PostalCode__pc",
        type: "text",
        wrapText: true
    }
];
export default class AsdacCreateNewCustomerCmp extends NavigationMixin(LightningElement) {
    label = {
		PersonalInfoLabel,
        TitleLabel,
        PhoneLabel,
        PhoneErrorLabel,
        AddressInfoLabel,
        RegionLabel,
        CountryLabel,
        HastrickLabel,
        PotentialDuplicateErrorLabel,
        EmailLabel,
        PostcodeLabel,
        ASDAC_SearchYourPostcodeLabel,
        ASDAC_SearchYourPostcodeButtonLabel
    };

    @track accountObj = {
        "objectApiName":"Account",
        "Country__pc" : "GB"
    }
    customers;
    isDuplicatesExist = false;
    isLoading = false;
    columns = COLUMNS;
    @track countryCodeOptions;
    @track salutionOptions;
    @api accountRec;
    countryOptions;
    personAccRecTypeId;
    address = {};
    errormessage="";
    searchedPostalCodeValue;
    showPostcodeError = false;
    get message(){
        return this.errormessage;
    }

    get isAddressLookupButtonDisabled(){
        return this.searchedPostalCodeValue===undefined || this.searchedPostalCodeValue?.trim().length === 0 ;
    }

    validateInputs() {
        let isValid = [...this.template.querySelectorAll("lightning-input-field"), ...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
            let validPostCode = true;
            if (field.disabled) {
                if (field.getAttribute('data-name') === 'PostalCode__pc') {
                    if (!field.value) {
                        validPostCode = false;
                    }
                }
            }
            let reportValidity = field.reportValidity() && validPostCode;
            if (!validPostCode) {
                //show error message
                this.showPostcodeError = true;
            }
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && reportValidity);
        }, true);
        if(!isValid) {
            return false;
        }
        let hasAsterisk = false;
        [...this.template.querySelectorAll("lightning-input-field")].forEach((field) => {
            if (field?.value && field.value?.includes('*')) {
                isValid = false;
                hasAsterisk = true;
            }
        });
        if(hasAsterisk) {
            throw new Error(HastrickLabel);
        }
        return true;
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
                    option.value = option.label;
                    option.label = `+${option.label}`;
                });
                this.countryCodeOptions = picklistValues;
            }
        }
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

    //to get salutaion field 
    @wire(getPicklistValues, { recordTypeId: "$personAccRecTypeId", fieldApiName: "Account.Salutation" })
    wireSalutaionPicklist({ data, error }) {
        if (error) {
            const event = new ShowToastEvent({
                title: ErrorTitle,
                variant: "error",
                message: error.body.message
            });
            this.dispatchEvent(event);
        } else if (data) {
            this.salutionOptions = JSON.parse(JSON.stringify(data.values));
            this.salutionOptions.unshift({"label":"--None--"});
        }
    }

    //to get country options 
    @wire(getPicklistValues, { recordTypeId: "$personAccRecTypeId", fieldApiName: "Account.Country__pc" })
    wireCountryPicklist({ data, error }) {
        if (error) {
            const event = new ShowToastEvent({
                title: ErrorTitle,
                variant: "error",
                message: error.body.message
            });
            this.dispatchEvent(event);
        } else if (data) {
            this.countryOptions = JSON.parse(JSON.stringify(data.values));
            this.countryOptions.unshift({ "label": "--None--" });
        }
    }

    connectedCallback(){
        loadScript(this, POSTCODE_SCRIPT)
        .then(() => {
            this.initPostcodeLookup();
        })
        .catch(error => {
            console.log('Error loading Postcode Lookup script: ' + error);
        })
        .finally(() => {
         this.handleDefaultValues(this.accountRec)
        });
    }

    initPostcodeLookup() {
        // Initialize the Postcode Lookup using the loaded script
        const context = this.template.querySelector('[data-ref="postcodeLookup"]');
        const button = this.template.querySelector('[data-ref="button"]');
        const selectContainer = this.template.querySelector('[data-ref="selectContainer"]');
        const message = this.template.querySelector('[data-ref="message"]');
        // Replace 'iddqd' with your actual API key
        const apiKey = ASDAC_IdealPostCodeAPIKey;
        const globalThis=this;

        const lookup = window.IdealPostcodes.PostcodeLookup.setup({
            apiKey,
            context,
            button,
            selectContainer,
            message,

            inputStyle: {
                width: '100%',
                padding: '8px',
                border: '1px solid rgb(201, 201, 201)',
                'border-radius': '4px'
            },
            selectStyle: {
                border: '1px solid rgb(201, 201, 201)',
                width: '100%',
                padding: '8px',
                cursor: 'pointer',
                outline: 'none',
                'border-radius': '4px'
            },
            messageStyle: {
                color: 'red'
            },
            onAddressesRetrieved:function(addresses){
                globalThis.errormessage='';
               },
            onAddressSelected: (address) => this.handleAddressSelected(address),
            onSearchCompleted: function (error) {
                // this will be invoked on all 4XX and 5XX errors
                if (error) {
                    globalThis.errormessage=ASDAC_IdealPostcodeErrorMessage;
                    this.enableAddressFields();
                    console.log('error on search completed---' + JSON.stringify(error));
                }
            },
            onSearchError: function (error) {
                //Invoked when a request succeeds but the API returns an error code
                // Examples of errors includes "lookup balance exhausted" and "lookup limit reached" errors.
                if (error) {
                    globalThis.errormessage=ASDAC_IdealPostcodeErrorMessage;
                    this.enableAddressFields();
                    console.log('error on search error---' + JSON.stringify(error));
                }
            },
            onSelectRemoved: () => this.enableAddressFields(),
            onFailedCheck: function (error) {
                globalThis.errormessage=ASDAC_IdealPostcodeErrorMessage;
                this.enableAddressFields();
                // executes when api key is wrong and gives a 404 http status
                console.log('in onFailedCheck-----' + JSON.stringify(error));
            },
        });
    }

    handleAddressSelected(address) {
        this.address = {
            AddressLine1__pc: address.line_1,
            AddressLine2__pc: address.line_2,
            AddressLine3__pc: address.line_3,
            City__pc: address.post_town,
            Country__pc: address.country_iso_2 === this.accountObj.Country__pc ? this.accountObj.Country__pc : (address.country === 'England') ? address.country_iso_2 : address.country,
            PostalCode__pc: address.postcode
        };
        this.accountObj = { ...this.accountObj, ...this.address };
        [...this.template.querySelectorAll(".addressField")].forEach((inputFld) => {
            inputFld.disabled = true;
        });
    }

    mapCustomer(customer) {
        return {
            ...customer,
            Url: "/" + customer.Id,
            Phone: customer.CountryCode__c ? `+${customer.CountryCode__c} ${customer.Phone}` : customer.Phone,
            EmailSameIcon : (customer.PersonEmail === this.accountObj.Loginid__c) ? 'action:approval' : 'action:close',
            PhoneSameIcon : (customer.Phone === this.accountObj.Phone) ? 'action:approval' : 'action:close',
        };
    }

    @api async handleSubmit() {
        try {
            if(!this.validateInputs()) {
                return;
            }
            this.isLoading = true;
            this.accountObj.PersonEmail = this.accountObj.Loginid__c;
            this.accountObj.Source__c = 'Contact Centre';
            this.accountObj.LastName = this.accountObj.LastName__pc.substring(0, 40);
            this.accountObj.FirstName = this.accountObj.FirstName__pc.substring(0, 40);
            if (this.accountObj.CountryCode__c) {
                this.accountObj.SecondaryLoginId__c = this.accountObj.Phone;
            }
            if(this.accountObj.PostalCode__pc) {
                this.accountObj.PostalCode__pc = this.accountObj.PostalCode__pc.trim();
            }
            await checkDuplicatesAndCreate({newCustomer : this.accountObj}).then((result) => {
                this.isLoading = false;
                if(!result.isSuccess) {
                    throw new Error(result.message);
                }

                this.isDuplicatesExist = result.isDuplicateExists;
                if (result.isDuplicateExists ) {
                    const event = new ShowToastEvent({
                        title: ErrorTitle,
                        variant: "error",
                        message: PotentialDuplicateErrorLabel
                    });
                    this.dispatchEvent(event);
                }

                let showCreateNew = true;
                if(!result.isDuplicateExists) {
                    this.redirectToCustomer(result.listOfAccounts[0].Id);
                    return;
                }
                this.customers = result.listOfAccounts.map((customer) => {
                    if(showCreateNew && (customer.PersonEmail === this.accountObj.Loginid__c || customer.Phone === this.accountObj.Phone)) {
                        showCreateNew = false;
                    }
                    return this.mapCustomer(customer);
                });
                [...this.template.querySelectorAll("lightning-input"), ...this.template.querySelectorAll("lightning-input-field"), ...this.template.querySelectorAll("lightning-combobox")].forEach((inputFld) => {
                    inputFld.disabled = true;
                });
                this.dispatchEvent(new CustomEvent("duplicateexists", { detail: {showCreateNew} }));
            });
        } catch (error) {
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: ErrorTitle,
                variant : 'error',
                message: error.message,
            });
            this.dispatchEvent(event);
        }
    }

    handleEnter(event){
		if(event.keyCode === 13){
            this.dispatchEvent(new CustomEvent("handleOnEnterPress"));
        }
    }

    @api handleCreateNew() {
        this.isLoading = true;
        if(this.accountObj.PostalCode__pc) {
            this.accountObj.PostalCode__pc = this.accountObj.PostalCode__pc.trim();
        }
        createNewCustomer({newCustomer : this.accountObj}).then((result) => {
            this.isLoading = false;
            if(result.isSuccess) {
                this.redirectToCustomer(result.listOfAccounts[0].Id);
            }
            else {
                const event = new ShowToastEvent({
                    title: ErrorTitle,
                    variant : 'error',
                    message: result.message,
                });
                this.dispatchEvent(event);
            }
        }).catch((error) => {
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: ErrorTitle,
                variant : 'error',
                message: error.message,
            });
            this.dispatchEvent(event);
        });
    }

    redirectToCustomer(customerId) {
        this.dispatchEvent(new CustomEvent("redirecttocustomer", { detail: {customerId} }));
    }

    @api handleUpdate() {
        [...this.template.querySelectorAll("lightning-input-field"), ...this.template.querySelectorAll("lightning-input"), ...this.template.querySelectorAll("lightning-combobox")].forEach((inputFld) => {
            inputFld.disabled = false;
        });
        this.customers = null;
        this.isDuplicatesExist = false;
    }

    handleDefaultValues(accountObj) {
        this.accountObj.FirstName__pc = accountObj.FirstName;
        this.accountObj.LastName__pc = accountObj.LastName;
        this.accountObj.PostalCode__pc = accountObj.PostalCode__pc;
        this.accountObj.Loginid__c = accountObj.LoginId__c;
        this.accountObj.Phone = accountObj.phone;
        this.accountObj.CountryCode__c = accountObj.CountryCode__c;
        this.accountObj.AddressLine1__pc = accountObj.AddressLine1__pc;
        if (this.accountObj?.PostalCode__pc) {
            this.initiateAddressSearchOnPostCode(this.accountObj.PostalCode__pc.trim());
        }
        [...this.template.querySelectorAll(".addressField")].forEach((inputFld) => {
            inputFld.disabled = true;
        });
    }

    onChangeHandler(event) {
        this.accountObj[event.target.dataset.name] = event.target.value;
    }

    onPostalCodeChange(event){
        this.searchedPostalCodeValue=event.target.value?.trimStart();
        this.showPostcodeError = false;
    }

    checkPhoneNumberValidations() {
        const countryCodeFld = this.template.querySelector('.countryCodeClass');
        let phoneFld = this.template.querySelector('.phone');
        Promise.resolve().then(() => {
            checkPhoneNumberFormats(countryCodeFld, phoneFld);
        });
    }
    checkPostCodeValidations(event) {
        let postalCodeFld = event.target;
        postalCodeFld.setCustomValidity('');
        if(!postalCodeFld.value?.trim()){
            postalCodeFld.setCustomValidity(ASDAC_MandatoryFieldError);
        } 
        else if(postalCodeFld.value?.trim().split(' ').length > 2) {
            postalCodeFld.setCustomValidity(ASDAC_PostCodeSpaceError);
        }
        postalCodeFld.reportValidity(); 
    }


    initiateAddressSearchOnPostCode(postCodeEntered) {
        let intervalFlag=0;
        const myInterval = setInterval(() => {
            intervalFlag++;
            if(this.template.querySelector('.idpc-input')){
            this.template.querySelector('.idpc-input').value = postCodeEntered;
            this.searchedPostalCodeValue=postCodeEntered;
            clearInterval(myInterval);
            }else if(intervalFlag>=5){
             clearInterval(myInterval); 
            }
           }, 1000);
    }

    enableAddressFields() {
        [...this.template.querySelectorAll(".addressField")].forEach((inputFld) => {
            inputFld.disabled = false;
        });
    }
}