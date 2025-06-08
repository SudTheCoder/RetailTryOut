//Import LWC
import { LightningElement,api, track } from 'lwc';
//Access custom permissions for logged in user
import isPnFUser from '@salesforce/customPermission/PF_Team_Permission';

//Start LWC JS
export default class AsdacPaymentMethodModalCmp extends LightningElement {
    //All the Order related details
    @api orderWrapper;
    //Indicates if it's a George order or GHS
    @api isGeorge;
    //List of all the payment methods
    @track paymentMethodsList;
    //List of paypal payments
    @track paypalList=[];
    //List of credit card payments
    @track creditCardList=[];
    //List of Gift card payments
    @track giftCardList=[];
    //Set rendering for Loading icon
    @track isLoading = true;
    //Indicates if paypal is available
    @track isPaypalAvailable = false;
    //Indicates if gift card is available
    @track isGiftCardAvailable = false;
    //Indicates if credit card is available
    @track isCreditCardAvailable = false;
    //Indicates if full gift card number should be visible
    @track isShowGiftCardNumber = false;
    //Indicates if logged in user is PnF
    @track isPandFUser = isPnFUser;
    //Set text for Gift card show/hide button
    @track giftCardText = 'Show';

    //Close the modal
    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    //Connected callback to set variables on load
    connectedCallback(){
        this.paymentMethodsList = JSON.parse(JSON.stringify(this.orderWrapper.paymentDetails.filter(item => !item.isCardDisabled)));

        function compareByAmount(a, b) {
            const amountA = a.totalInvoiced;
            const amountB = b.totalInvoiced;
            return amountB - amountA;
        }

        this.paymentMethodsList.sort(compareByAmount);

        this.paymentMethodsList.forEach(item => {
            if(!item.billToAddress){
                item.billToAddress = this.orderWrapper.billToAddress;
            }
            if(!item.billToContact){
                item.billToContact = this.orderWrapper.billToContact;
            } 
        });

        this.isLoading = false;
    }
}