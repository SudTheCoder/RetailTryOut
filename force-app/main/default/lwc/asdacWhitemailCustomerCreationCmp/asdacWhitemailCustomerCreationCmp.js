import { LightningElement, api, track, wire } from 'lwc';

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

import { loadScript } from 'lightning/platformResourceLoader';
import POSTCODE_SCRIPT from '@salesforce/resourceUrl/idealPostCodeLookup';
import ASDAC_IdealPostCodeAPIKey from "@salesforce/label/c.ASDAC_IdealPostCodeAPIKey";
import ASDAC_SearchYourPostcodeLabel from "@salesforce/label/c.ASDAC_SearchYourPostcodeLabel";
import ASDAC_SearchYourPostcodeButtonLabel from "@salesforce/label/c.ASDAC_SearchYourPostcodeButtonLabel";
import ASDAC_IdealPostcodeErrorMessage from "@salesforce/label/c.ASDAC_IdealPostcodeErrorMessage";

import ADDRESS_LINE1 from '@salesforce/schema/Case.Address_Line_1__c';
import ADDRESS_LINE2 from '@salesforce/schema/Case.Address_Line_2__c';
import ADDRESS_LINE3 from '@salesforce/schema/Case.Address_Line_3__c';
import CITY from '@salesforce/schema/Case.City__c';
import COUNTRY from '@salesforce/schema/Case.Country__c';
import POSTCODE from '@salesforce/schema/Case.Post_Code__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';

const fields = [ADDRESS_LINE1, ADDRESS_LINE2,ID_FIELD,ADDRESS_LINE3,CITY,COUNTRY,POSTCODE];

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

export default class AsdacWhitemailCustomerCreationCmp extends LightningElement {


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
        "objectApiName":"Case",
        "Country__pc" : "GB"
    }
    customers;
    isDuplicatesExist = false;
    isLoading = false;
    columns = COLUMNS;
    @track countryCodeOptions;
    @track salutionOptions;
    @api accountRec;
	@api addressLine1;
	@api addressLine2;
	@api addressLine3;
	@api city;
	@api country;
	@api postcode;
	@api recordId;
  
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

   

    connectedCallback(){
        loadScript(this, POSTCODE_SCRIPT)
        .then(() => {
            this.initPostcodeLookup();
        })
        .catch(error => {
            console.log('Error loading Postcode Lookup script: ' + error);
        })
        //.finally(() => {
       //  this.handleDefaultValues(this.accountRec)
      //  });
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
		
		this.addressLine1=address.line_1;
	    this.addressLine2=address.line_2;
		this.addressLine3=address.line_3;
		this.city=address.post_town;
		this.country=address.country_iso_2 === this.accountObj.Country__pc ? this.accountObj.Country__pc : (address.country === 'England') ? address.country_iso_2 : address.country;;
		this.postcode=address.postcode;
        
      
	
		this.updateCaseRecord(this.addressLine1,this.addressLine2,this.addressLine3,this.city,this.country,this.postcode);
        
          

    }
	updateCaseRecord(addressLine1,addressLine2,addressLine3,city,country,postcode)
	{ 
       
		const fields={};
		fields[ID_FIELD.fieldApiName] =this.recordId;
       
		fields[ADDRESS_LINE1.fieldApiName] =this.addressLine1;
		fields[ADDRESS_LINE2.fieldApiName] =this.addressLine2;
        
		fields[ADDRESS_LINE3.fieldApiName] =this.addressLine3;
		fields[CITY.fieldApiName] =this.city;
		fields[COUNTRY.fieldApiName] =this.country;
		fields[POSTCODE.fieldApiName] =this.postcode;
		const recordInput={ fields};
		this.updateAddresRecord(recordInput)
        
	}
    updateAddresRecord(recordInput){
    
         updateRecord(recordInput);
       
        

        } 
   

    onChangeHandler(event) {
        this.accountObj[event.target.dataset.name] = event.target.value;
    }

    onPostalCodeChange(event){
        this.searchedPostalCodeValue=event.target.value?.trimStart();
        this.showPostcodeError = false;
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