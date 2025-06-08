public class ASDAC_CustomLookupLWCControllerService {
    
    public static List<SObject> getRecords(String sObjectName, String searchParametersJsonString) {
        ASDAC_CustomLookupMetadata__mdt metadataRecord = ASDAC_CustomLookupMetadata__mdt.getInstance(sObjectName);
		Type serviceClassName = Type.forName(metadataRecord.ServiceClassName__c);
        ASDAC_CustomSearchInterface customSearchInterface = (ASDAC_CustomSearchInterface) serviceClassName.newInstance();
        List<SObject> listOfRecords = customSearchInterface.getLookupRecords(searchParametersJsonString);
        return listOfRecords;
    }

}