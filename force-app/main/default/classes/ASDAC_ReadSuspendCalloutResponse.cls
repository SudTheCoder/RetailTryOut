/**********************************************************************************
* @author                       : Disharee Ray
* @date                         : 2024-01-18
* @description                  : ASDAC-17025 Suspend Account From order pages - Integration  with ADB2C
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer      Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Disharee Ray   18-Jan-2024        ASDAC-17025 Suspend Account From order pages - Integration with ADB2C
***************************************************************************************************/
public class ASDAC_ReadSuspendCalloutResponse {
    @InvocableMethod(label = 'Parse Suspend Callout Error response')
    public static List<ASDAC_SuspendAccountCalloutResponse> readSuspendCalloutErrorResponse(List<String> errorResponse){
        List<ASDAC_SuspendAccountCalloutResponse> response = new List<ASDAC_SuspendAccountCalloutResponse>();
        String inputString = errorResponse[0];
        ASDAC_SuspendAccountCalloutResponse response1 = (ASDAC_SuspendAccountCalloutResponse) JSON.deserialize(inputString, ASDAC_SuspendAccountCalloutResponse.class);
        response.add(response1);
        return response;
    }
}