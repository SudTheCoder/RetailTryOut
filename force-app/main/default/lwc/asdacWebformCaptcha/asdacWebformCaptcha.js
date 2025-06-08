import { LightningElement, track, api, wire } from 'lwc';
import captchaResourceUrl from '@salesforce/resourceUrl/turnstileCaptcha';
import fetchBaseURL from '@salesforce/apex/ASDAC_TurnstileCaptchaService.fetchBaseURL';
import getCaptchaSettings from '@salesforce/apex/ASDAC_TurnstileCaptchaService.getCaptchaSettings';
import INVALID_CAPTCHA_TEXT from '@salesforce/label/c.Bot_protection_invalid_captcha';
export default class AsdacWebformCaptcha extends LightningElement {

    @track captchaResource;
    @track isValidCaptcha = false;
    wiredRecords;
    wiredAllowedUrlsRecords;
    responseData;
    captchaConfig;
    allowedUrls;
    @track captchaTokenStr = '';
    @track errorMessage = '';
    @api captchaErrors ='';
    constructor(){
        super();
        this.captchaResource = captchaResourceUrl;
    }
    disconnectedCallback() {
        window.removeEventListener('message', this.handleReceiveMessage,false);
    }
    @wire(fetchBaseURL)
    wiredAllowedUrls( value  ) {
        this.wiredAllowedUrlsRecords = value;
        const { data, error } = value;
        if ( data ) {                   
            this.allowedUrls = data;
            this.errorMessage = '';
        } else if ( error ) {
            this.errorMessage = error;
            this.allowedUrls = undefined;
        }
    }  

    @wire(getCaptchaSettings)
    wiredCaptchaConfig( value ) {
        this.wiredRecords = value;
        const { data, error } = value;
        if ( data ) {                        
            this.captchaConfig = data;
            this.errorMessage = '';
            //in case captcha is disable validtae true
            if (!data.Service_Enabled__c) {
                this.isValidCaptcha = true;
            } else {
                // pass site key to url
                this.captchaResource += '?sitekey='+ this.captchaConfig.Site_key__c;
            }
        } else if ( error ) {
            this.errorMessage = error;
            this.captchaConfig = undefined;
        }
    } 
    get isCaptchaEnabled() {
        return (this.captchaConfig?.Service_Enabled__c && this.captchaConfig.Site_key__c );
    }

    get isAllowedUrl(){
        return (this.allowedUrls && this.allowedUrls.length>0);
    }
    @api
    get captchaToken() {        
        return this.captchaTokenStr;
    }
    captchaLoaded(evt){ 
        if(evt.target.getAttribute('src') === this.captchaResource){
            window.addEventListener("message",this.handleReceiveMessage, false);
        }
    }
    handleReceiveMessage = (e) => {
        // Security Check | accept only from known URLs
        if (!this.allowedUrls) return;
        const hasDomain = this.allowedUrls.includes(e.origin); 
        if (!hasDomain && !e.origin) return;
        const [eventName, data] = e.data;
        if (eventName === 'token') {   
            this.captchaTokenStr =  data; 
            this.isValidCaptcha = true;              
            // send response to flow
            //this.dispatchEvent(new FlowAttributeChangeEvent('captchaToken', this.captchaTokenStr));
        } else {
            this.isValidCaptcha = false;
        }
    }
    
    @api validate() {
        if (!this.errorMessage) {
            this.errorMessage = INVALID_CAPTCHA_TEXT;
        }
        if (!this.isValidCaptcha) {            
            return { isValid: false, errorMessage: this.errorMessage};
        }        
        return  { isValid: this.isValidCaptcha};
    }
}