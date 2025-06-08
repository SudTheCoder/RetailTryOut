/******************************************************************************
Name: ASDAC_IntegrationServices
===============================================================================
Req: This Interface which every service class will inherit
===============================================================================
Purpose:Interface Class
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		7 Dec 2022     Initial Development
******************************************************************************/
public interface ASDAC_IntegrationServices {
    
    //This abstract method is used to create a request body which will be 
    //called from doCallout Method
    String createRequest(String stringifiedJSON);
    
    //This method will call the actual Http method to do the callout
    ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt metadataRecord, String stringifiedJSON);
}