import { api, LightningElement} from "lwc";
import enableReleaseBFeature from '@salesforce/customPermission/ASDAC_ReleaseBFeatures';
import CustomerSearchLabel from '@salesforce/label/c.ASDAC_Customer_Search';
import OrderSearchLabel from '@salesforce/label/c.ASDAC_Order_Search';
import SkipSearchLabel from '@salesforce/label/c.ASDAC_Skip_Search';
import CaseSearchLabel from '@salesforce/label/c.ASDAC_Case_Search';


export default class AsdacCustomerSearch extends LightningElement {
	@api newCustomerTab = false;
	label = {
		CustomerSearchLabel,
		OrderSearchLabel,
		SkipSearchLabel,
		CaseSearchLabel
    };

	get hasBFeatureAccess(){
		return enableReleaseBFeature;
	}
}