import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class AsdacWebformCloseAccountCmp extends LightningElement {
  @api closeAccountModalText;
  @api sendRequestButtonLabel;
  @api cancelButtonLabel;
  @api sendButtonLabel;
  @api availableActions = [];
  showConfirmationModel = false;

  handleSubmit() {
    this.showConfirmationModel = true;
  }
  hideConfirmationModel() {
    this.showConfirmationModel = false;
  }

  handleGoNext() {
    if (this.availableActions.find((action) => action === 'NEXT')) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }
}