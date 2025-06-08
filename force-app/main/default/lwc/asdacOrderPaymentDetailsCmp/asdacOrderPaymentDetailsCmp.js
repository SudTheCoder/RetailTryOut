import { LightningElement, api } from 'lwc';
import ASDAC_CardDetails from '@salesforce/label/c.ASDAC_CardDetails';
import ASDAC_CardType from '@salesforce/label/c.ASDAC_CardType';
import ASDAC_TransactionType from '@salesforce/label/c.ASDAC_TransactionType';
import ASDAC_TransactionNumber from '@salesforce/label/c.ASDAC_TransactionNumber';
import ASDAC_Status from '@salesforce/label/c.ASDAC_Status';
import ASDAC_Amount from '@salesforce/label/c.ASDAC_Amount';
import ASDAC_DateTimeBSTGMT from '@salesforce/label/c.ASDAC_DateTimeBSTGMT';
import ASDAC_NoGhsPaymentTransactionPresent from "@salesforce/label/c.ASDAC_NoGhsPaymentTransactionPresent";
export default class AsdacOrderPaymentDetailsCmp extends LightningElement {
    @api orderWrapper;
    @api isGeorge;
    crediCardList = [];
    paypalList = [];
    giftCardList = [];
    voucherList = [];
    isCreditCard = false;
    isPaypal = false;
    isVoucher = false;
    isGiftCard = false;
    hasPaymentTransactions = false;
    noGhsPaymentTransactionMessage;
    totalPaypal = 0;
    totalVoucher = 0;
    totalGiftCard = 0;
    totalCreditCard = 0;
    label={
        ASDAC_CardType,
        ASDAC_CardDetails,
        ASDAC_Amount,
        ASDAC_Status,
        ASDAC_TransactionType,
        ASDAC_TransactionNumber,
        ASDAC_DateTimeBSTGMT
    };
    isRewardDiscountModalVisible = false;

    connectedCallback(){
        let paymentMethods = this.orderWrapper.paymentDetails;

        for(let key of paymentMethods){
            if(key.paymentType === 'CREDIT_CARD' && key.transactionsDetails.length > 0){
                this.isCreditCard = true;
                this.hasPaymentTransactions = true;
                this.crediCardList.push(key);
                this.totalCreditCard += key.totalInvoiced ? key.totalInvoiced : 0;
            }
            else if(key.paymentType === 'PAYPAL'&& key.transactionsDetails.length > 0){
                this.isPaypal = true;
                this.hasPaymentTransactions = true;
                this.paypalList.push(key);
                this.totalPaypal += key.totalInvoiced ? key.totalInvoiced : 0;
            }
            else if(key.paymentType === 'GIFT_CARD'&& key.transactionsDetails.length > 0){
                this.isGiftCard = true;
                this.hasPaymentTransactions = true;
                this.giftCardList.push(key);
                this.totalGiftCard += key.totalInvoiced ? key.totalInvoiced : 0;
            }
            else if(key.paymentType === 'VOUCHER'&& key.transactionsDetails.length > 0){
                this.isVoucher = true;
                this.hasPaymentTransactions = true;
                this.voucherList.push(key);
                this.totalVoucher += key.totalInvoiced ? key.totalInvoiced : 0;
            }
        }
        
        this.noGhsPaymentTransactionMessage = ASDAC_NoGhsPaymentTransactionPresent;
    }

    handleRewardsDiscount(){
        this.isRewardDiscountModalVisible = true;
    }

    handleCloseModal(){
        this.isRewardDiscountModalVisible = false;
    }
}