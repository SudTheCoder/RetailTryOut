//Importing LWC libraries and Apex method
import { LightningElement, wire, track } from 'lwc';
import getActiveHotTopics from '@salesforce/apex/ASDAC_HotTopicController.getActiveHotTopics';
import Hot_Topic_Title from '@salesforce/label/c.ASDAC_HotTopicTitle';


//Columns to display with their proprties
const columns = [ 
	{ label: 'Hot Topic', fieldName: 'Name', type: 'string'},
	{ label: 'ID', fieldName: 'RedirectURL', type: 'url',
    typeAttributes: { label: { fieldName: 'HotTopicId__c' }}},
    { label: 'Last Updated', fieldName: 'LastModifiedDate', type: 'date'},
];

export default class AsdacHotTopicListCmp extends LightningElement {
	label = {
		Hot_Topic_Title
    };

	//Variables
	@track searchName = '';
	@track hotTopics;
	@track dataFound;
	@track displayMessage;
	@track columns = columns;
	

	//Wire method to fetch active hot topics/throw message in case no active hot topics are present
	@wire(getActiveHotTopics)
	wireRecord({ data, error }) {
		if (data) {
			this.dataFound = data.isSuccess;
			if(!this.dataFound){
				this.displayMessage = data.message;
				return;
			}
			this.hotTopics = JSON.parse(JSON.stringify(data.hotTopicList));
			this.hotTopics.forEach((hotTopic) => {
				hotTopic.RedirectURL = `/${hotTopic.Id}`;
			});
			this.error = undefined;
		} else {
			this.hotTopics = undefined;
			this.error = error;
			this.dataFound = false;
			this.displayMessage = error;
		}
	}
}