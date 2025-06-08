declare module "@salesforce/apex/ASDAC_KnowledgeController.getFields" {
  export default function getFields(param: {recordType: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_KnowledgeController.exportKnowledge" {
  export default function exportKnowledge(param: {recordType: any, publishStatus: any}): Promise<any>;
}
declare module "@salesforce/apex/ASDAC_KnowledgeController.importKnowledge" {
  export default function importKnowledge(param: {recordType: any, articleList: any}): Promise<any>;
}
