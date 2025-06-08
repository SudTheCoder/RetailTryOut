import { LightningElement, api } from 'lwc';

export default class AsdacErrorMessageBannersCmp extends LightningElement {
    @api errorMessageToDisplay;
}