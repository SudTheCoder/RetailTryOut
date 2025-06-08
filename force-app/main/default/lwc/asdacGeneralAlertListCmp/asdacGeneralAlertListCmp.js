import { LightningElement, wire } from 'lwc';
import getAlerts from '@salesforce/apex/ASDAC_GeneralAlertController.getAlerts';
import ASDAC_General_Alerts_Error from '@salesforce/label/c.ASDAC_General_Alerts_Error';

export default class AsdacGeneralAlertListCmp extends LightningElement {
  alerts = [];
  error;

  @wire(getAlerts)
  wireGetAlerts({ data, error }) {
    if (data) {
      this.alerts = data;
    }
    else if (error) {
      console.error(error);
      this.error = ASDAC_General_Alerts_Error;
      setTimeout(() => {
        this.error = undefined;
      }, 5000); // hide error after 5s
    }
  }
}