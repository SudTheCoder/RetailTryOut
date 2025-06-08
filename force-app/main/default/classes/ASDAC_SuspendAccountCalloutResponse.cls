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
public with sharing class ASDAC_SuspendAccountCalloutResponse {
  @InvocableVariable
  public String status;
  @InvocableVariable
  public String errorCode;
  @InvocableVariable
  public String errorDescription;
}