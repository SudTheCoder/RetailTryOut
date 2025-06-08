import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AsdacNavigationMenuLogo extends NavigationMixin(
    LightningElement
) {
    @api formfactor;
    @api page;
    @api logo;


    handleClick(evt) {
        // use the NavigationMixin from lightning/navigation to perform the navigation.
        // prevent default anchor link since lightning navigation will be handling the click
        evt.stopPropagation();
        evt.preventDefault();
        // Navigate to the home page
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}