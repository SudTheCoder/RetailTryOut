import { LightningElement, api, track} from 'lwc';
import generatePdf from '@salesforce/apex/ASDAC_DownloadVatReceiptController.generatePdf';
import vatReceiptFileName from '@salesforce/label/c.ASDAC_VatReceiptFileName';
 
export default class AsdacDownloadVatReceiptCmp extends LightningElement {
    @api orderWrapper;
    @track isLoading = true;
    connectedCallback(){
        
        generatePdf({ orderId: this.orderWrapper.orderId,
                      sellingChannel: this.orderWrapper.sellingChannel
                    })
        .then((result) => {
            if(result){
                const byteCharacters = window.atob(result);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: 'application/pdf' });

                const downloadLink = document.createElement('a');
                downloadLink.href = URL.createObjectURL(blob);
                downloadLink.download = vatReceiptFileName.replace('{0}', this.orderWrapper.orderId);
                document.body.appendChild(downloadLink);
                downloadLink.click();
                document.body.removeChild(downloadLink);
                
                this.dispatchEvent(new CustomEvent('closemodal'));
            }
            this.isLoading = false;
        })
    }
}