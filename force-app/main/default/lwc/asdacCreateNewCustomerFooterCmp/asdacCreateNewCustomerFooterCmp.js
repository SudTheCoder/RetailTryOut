import { LightningElement, api} from 'lwc';

export default class AsdacCreateNewCustomerFooterCmp extends LightningElement {
    showCreateNew = false;
    showModifyInputs = false;
    handleClick(event) {
        this.dispatchEvent(new CustomEvent(event.target.name)); 
    }

    @api showNewHandler() {
        this.showCreateNew = true;
    }

    @api showModifyHandler() {
        this.showModifyInputs = true;
    }

    @api hideNewAndResetHandler() {
        this.showCreateNew = false;
        this.showModifyInputs = false;
    }
}