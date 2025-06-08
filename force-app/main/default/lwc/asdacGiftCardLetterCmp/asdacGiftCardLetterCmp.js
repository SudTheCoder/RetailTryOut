import { LightningElement, api} from 'lwc';
import generatePdf from '@salesforce/apex/ASDAC_StandardLetterCmp.generatePdf'

export default class AsdacGiftCardLetterCmp extends LightningElement {

    @api recordId;
    
    @api
    async invoke(){
        generatePdf({recordId:this.recordId,type:'GiftCardLetter'}).then(result=>{
            window.open(result[1]);
        }).catch(()=>{
        })
    }

}