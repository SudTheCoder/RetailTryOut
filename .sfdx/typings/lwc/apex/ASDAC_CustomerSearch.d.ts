declare module "@salesforce/apex/ASDAC_CustomerSearch.getFields" {
  export default function getFields(): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_CustomerSearch.getCustomersList" {
  export default function getCustomersList(param: {filters: any, customFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_CustomerSearch.getCustomerIdFromCallout" {
  export default function getCustomerIdFromCallout(param: {orderId: any}): Promise<any>;
}
