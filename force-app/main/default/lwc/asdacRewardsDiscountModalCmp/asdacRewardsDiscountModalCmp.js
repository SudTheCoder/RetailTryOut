import { LightningElement,api } from 'lwc';

export default class AsdacRewardsDiscountModalCmp extends LightningElement {
	@api orderwrapper;
	rewardVoucherWrapper;

	connectedCallback(){
		this.rewardVoucherWrapper = this.orderwrapper.rewardVouchers.map((voucher, index) => {
            return { ...voucher, serialNumber: index + 1 };
        });
	}

    handleCloseModal(){
		this.dispatchEvent(new CustomEvent('closemodal'));
	}
}