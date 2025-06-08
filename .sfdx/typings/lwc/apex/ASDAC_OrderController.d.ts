declare module "@salesforce/apex/ASDAC_OrderController.getOrders" {
  export default function getOrders(param: {option: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.getOrder" {
  export default function getOrder(param: {businessArea: any, orderId: any, variables: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.exchangeOrder" {
  export default function exchangeOrder(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.createReturnPreviewRequest" {
  export default function createReturnPreviewRequest(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.createReturnRequest" {
  export default function createReturnRequest(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.createWholeOrderRefundRequest" {
  export default function createWholeOrderRefundRequest(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.receiveRequest" {
  export default function receiveRequest(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.createATPRequest" {
  export default function createATPRequest(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.getCustomerId" {
  export default function getCustomerId(param: {personAccountId: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.getOrderHistoryFields" {
  export default function getOrderHistoryFields(): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.partialRefundOrder" {
  export default function partialRefundOrder(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.deliveryChargeRefundOrder" {
  export default function deliveryChargeRefundOrder(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.cancelOrder" {
  export default function cancelOrder(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.createRefundOverrideRequest" {
  export default function createRefundOverrideRequest(param: {order: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.getStoreId" {
  export default function getStoreId(param: {storeNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_OrderController.getUserGroups" {
  export default function getUserGroups(param: {userId: any}): Promise<any>;
}
