declare module "@salesforce/apex/ASDAC_ServiceNotificationAlerts.getAllUserGroupId" {
  export default function getAllUserGroupId(): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_ServiceNotificationAlerts.fetchRecords" {
  export default function fetchRecords(param: {objectName: any, filterField: any, searchString: any, value: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_ServiceNotificationAlerts.saveRecipientRecord" {
  export default function saveRecipientRecord(param: {serviceNotifId: any, stringifiedRecordData: any, typeOfRecipient: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_ServiceNotificationAlerts.getListOfRecipients" {
  export default function getListOfRecipients(param: {listOfRecipientIds: any}): Promise<any>;
}
