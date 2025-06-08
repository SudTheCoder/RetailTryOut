//Import Apex Methods
import getResponseMethod from '@salesforce/apex/ASDAC_CalloutUtilityCmpController.getResponseMethod';
    export function getResponse(mdtName, stringifiedJSON){
        return getResponseMethod({mdtName, stringifiedJSON});
    }