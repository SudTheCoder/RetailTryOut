import { LightningElement,api } from 'lwc';

export default class AsdacTrackingDetailsModalCmp extends LightningElement {
    
    @api lstshipmentdetails;
    @api isexchangeorder;
    isMultiShipment = true;
    shipmentDetails;
    @api isgeorge;
        @api isgrocery;
    @api orderwrapper;
    @api lineitemname;
    
    @api shippingaddress;

    connectedCallback (){

        if(this.isgeorge && this.isgeorge !== undefined && this.lstshipmentdetails !== undefined)
        {
            this.shipmentDetails = this.lstshipmentdetails[0];

        
        if(this.lstshipmentdetails.length < 2 && this.lstshipmentdetails.length > 0){
            this.isMultiShipment = false;
        }
         }
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        const modalCloseEvent= new CustomEvent("closetrackingdetailsmodal",{detail:false });
        this.dispatchEvent(modalCloseEvent);
    }

}