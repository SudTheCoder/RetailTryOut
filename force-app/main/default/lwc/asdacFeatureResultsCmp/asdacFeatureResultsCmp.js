import { LightningElement, api } from 'lwc';
import fetchFeaturedArticles from "@salesforce/apex/ASDAC_LookupController.fetchFeaturedArticles";

export default class AsdacFeatureResultsCmp extends LightningElement {
    @api searchTerm = "";
    minSearchLength = 2;
    maxResults = 1;
    featuredArticles = [];

    get showFeaturedResult() {
        return this.featuredArticles && this.featuredArticles.length > 0;
    }
    connectedCallback() {
        if (this.searchTerm.length < this.minSearchLength) {
            return;
        }
        this.loading = true;
        fetchFeaturedArticles({ searchKey: this.searchTerm, maxResults: this.maxResults })
            .then((data) => {
                this.featuredArticles = data;
                this.loading = false;
            })
            .catch((error) => {
                this.loading = false;
                console.error(error);
            });
    }
}