/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-02-06
 * @description                  : Option for filters, sort, pagination
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
 ***************************************************************************************************/
public with sharing class ASDAC_OrderHistoryOption {
  @AuraEnabled
  public String filters { get; set; }
  @AuraEnabled
  public String sortFields { get; set; }
  @AuraEnabled
  public Integer pageNumber { get; set; }
  @AuraEnabled
  public Integer pageSize { get; set; }

  public ASDAC_OrderHistoryOption() {
    pageNumber = 1;
    pageSize = 5;
  }

  public String toQueryString() {
    Integer offset = pageSize * (pageNumber - 1);
    Map<String, String> params = new Map<String, String>();
    params.put('limit', pageSize + '');
    params.put('offset', offset + '');
    params.put('query', filters);
    params.put('sortFields', sortFields);
    List<String> paramList = new List<String>();
    for (String param : params.keySet()) {
      String value = params.get(param);
      if (String.isNotBlank(value)) {
        value = EncodingUtil.urlEncode(value, 'UTF-8');
        paramList.add(param + '=' + value);
      }
    }
    String query = String.join(paramList, '&');
    return query;
  }
}