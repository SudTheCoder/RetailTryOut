import { LightningElement } from 'lwc';

export default class AsdacComplaintParentCmp extends LightningElement {
    get options() {
        return [
            { label: '--None--', value: ''},
            { label: 'Click and Collect', value: 'ClickandCollect' },
            { label: 'Home Delivery', value: 'HomeDelivery' },
        ];
    }
}