/******************************************************************************
Name: ASDAC_MedalliaCSATSurveySendService
===============================================================================
Req: 
ASDAC-3300 CSAT trigger
===============================================================================
Purpose: Send Survey To Medallia for CSAT
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		12 Dec 2022     Initial Development
2.0       Disharee Ray        14 Feb 2023     ASDAC-7041 CSAT trigger - Response and Error Handling in SFSC
3.0       Disharee Ray        15 May 2023     ASDAC-11740 CSAT Integration Fix
******************************************************************************/
public with sharing class ASDAC_MedalliaCSATSurveySendService implements ASDAC_IntegrationServices {
    public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {
        ASDAC_IntegrationUtility.IntegrationWrapper initWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
        initWrapper.metadataRecord = integrationMdt;
        initWrapper.requestBody = createRequest(stringifiedJSON);
    ASDAC_IntegrationUtility.HttpResponseWrapper httpResponseWrap = ASDAC_IntegrationUtility.sendRequest(
      initWrapper,
      false
    );
    ASDAC_IntegrationUtility.ResultWrapper resultWrap;
    HttpResponse resp = httpResponseWrap.response;
        if(resp.getStatusCode() == 200 || resp.getStatusCode() == 202) {
            resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(true, '', resp.getBody());            
        }
        else {
            resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(false, '', resp.getBody());                        
        }
        insert httpResponseWrap.log;                                                                                                                                                                     
        return resultWrap;
    }
    
  public static String createRequest(String reqkey) {
    RequestHelperWrapper reqHlprWrap = (RequestHelperWrapper) JSON.deserialize(
      reqkey,
      RequestHelperWrapper.class
    );
    Case cseRecord = [
      SELECT
        Id,
        AgentId__c,
        CaseNumber,
        Store__r.StoreNumber__c,
        Status,
        Origin,
        CreatedDate,
        ClosedDate,
        Owner.Name,
        Owner.UserRole.Name,
        RecordType.Name,
        ContactReasonLevel1__c,
        ContactReasonLevel2__c,
        ContactReasonLevel3__c,
        Contact.FirstName,
        Contact.LastName,
        ContactEmail,
        SuppliedEmail,
        OwnerId,
        BusinessArea__c
      FROM Case
      WHERE Id = :reqHlprWrap.caseId
    ];
    return JSON.serialize(new RequestWrapper(cseRecord));
  }

  public class RequestHelperWrapper {
    public String caseId;
    public RequestHelperWrapper(String caseId) {
      this.caseId = caseId;
    }
  }

  public class RequestWrapper {
    public String TRANSACTION_ID;
    public String Unique_ID;
    public String STORE_NUMBER;
    public String Status;
    public String Order_type;
    public String Created_time;
    public String Closed_time;
    public String Colleague_name;
    public String Profile_id;
    public String contact_reason_level_1;
    public String contact_reason_level_2;
    public String contact_reason_level_3;
    public String contact_reason_level_4;
    public String FIRST_NAME;
    public String LAST_NAME;
    public String EMAIL_ADDRESS;
    public String AGENT_ID;
    public String AGENT_DISPLAY_NAME;
    public RequestWrapper(Case caseRecord) {
      this.TRANSACTION_ID = caseRecord.Id;
      this.Unique_ID = caseRecord.CaseNumber;
      this.STORE_NUMBER = (caseRecord.BusinessArea__c ==ASDAC_GlobalConstants.STRING_GROCERY_CASE_BUSINESSAREA)?ASDAC_GlobalConstants.STRING_MEDALLIA_GHS_STOREID:
                          (caseRecord.BusinessArea__c ==ASDAC_GlobalConstants.STRING_STORES_CASE_BUSINESSAREA)?
                          ASDAC_GlobalConstants.STRING_MEDALLIA_STR_STOREID:ASDAC_GlobalConstants.STRING_MEDALLIA_GRG_STOREID;
      this.Status = caseRecord.Status;
      this.Order_type = caseRecord.Origin;
      this.Created_time = String.valueOf(caseRecord.CreatedDate);
      this.Closed_time = String.valueOf(caseRecord.ClosedDate);
      this.Colleague_name = caseRecord.Owner.Name;
      this.Profile_id = caseRecord.Owner.UserRole.Name;
      this.contact_reason_level_1 = caseRecord.RecordType.Name;
      this.contact_reason_level_2 = caseRecord.ContactReasonLevel1__c;
      this.contact_reason_level_3 = caseRecord.ContactReasonLevel2__c;
      this.contact_reason_level_4 = caseRecord.ContactReasonLevel3__c;
      this.FIRST_NAME = caseRecord.Contact.FirstName;
      this.LAST_NAME = caseRecord.Contact.LastName;
      this.EMAIL_ADDRESS = (String.isNotBlank(caseRecord.ContactEmail)
        ? caseRecord.ContactEmail
        : caseRecord.SuppliedEmail);
      this.AGENT_ID = caseRecord.AgentId__c;
      this.AGENT_DISPLAY_NAME = caseRecord.Owner.Name;
    }
  }
}