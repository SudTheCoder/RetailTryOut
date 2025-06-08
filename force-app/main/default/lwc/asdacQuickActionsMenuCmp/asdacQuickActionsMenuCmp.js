import { LightningElement, api, wire } from 'lwc';
import getNavigationMenuItems from '@salesforce/apex/ASDAC_NavigationMenuItemsController.getNavigationMenuItems';

export default class AsdacQuickActionsMenuCmp extends LightningElement {
    @api menuName;
    channelName = 'Help';
    quickActionsMenu = [];
    isLoaded;
    error;
    @wire(getNavigationMenuItems, {
        menuName: '$menuName',
        channelName: '$channelName'
    })
    wiredMenuItems({ error, data }) {
        if (data && !this.isLoaded) {
            this.quickActionsMenu = data[0].navigationalMenuItems.map((quickActionMenuItem) => {
                const quickActionLinks = (quickActionMenuItem.subMenu || []).map(({ label, actionValue, actionType }) => ({
                    label: label,
                    actionValue: actionValue,
                    actionType: actionType
                }));
                return {
                    label: "<h3>"+quickActionMenuItem.label+"</h3>",
                    quickActionLinks
                };
            });
            this.error = undefined;
            this.isLoaded = true;
        } else if (error) {
            this.error = error;
            this.quickActionsMenu = [];
            this.isLoaded = true;
        }
    }
}