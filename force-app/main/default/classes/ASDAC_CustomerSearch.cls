/**********************************************************************************
 * @author                       : KasiViswaNath Gandham
 * @date                         : 2022-05-23
 * @description                  : ASDAC-623 Carryover Customer Account Search
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date            Description
 *---------------------------------------------------------------------------------------------------
 * KasiViswaNath Gandham         23-May-2022     Created the class
 * Vineeth Rangamgari            27-May-2022     Updated the class for ASDAC-1041
 * Vineeth Rangamgari            07-June-2022    Updated the class for ASDAC-911
 * Vineeth Rangamgari            07-July-2022    Updated the class for ASDAC-1135
 * Vineeth Rangamgari            10-August-2022  Updated the class for ASDAC-2848
 * Vineeth Rangamgari            08-Sep-2022     Removed ASDAC_Query references
 * Amey Priolkar                 04-Oct-2022     Updated the class for ASDAC-3770
 ***************************************************************************************************/
public with sharing class ASDAC_CustomerSearch {
  private static final String ADDITIONAL_FILTERS_PLACEHOLDER = '{ADDITIONAL_FILTERS}';

  /**
   * ****************************************************************************************************
   * @description method to get fields from custom metadata type
   * @return List\<FilterWrapper\>
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static List<FilterWrapper> getFields() {
    List<Customer_Search_Fields__mdt> customerSearchFields = Customer_Search_Fields__mdt.getAll().values();

    List<FilterWrapper> fields = new List<FilterWrapper>();
    for (Customer_Search_Fields__mdt searchfields : customerSearchFields) {
      FilterWrapper field = new FilterWrapper();
      field.label = searchfields.MasterLabel;
      field.field = searchfields.Account_Field__c;
      field.searchOperation = searchfields.Search_Operation__c;
      field.customQuery = searchfields.Custom_Query__c;
      field.search = '';
      field.maxLength = searchfields.Max_Length__c;
      field.fieldUniqueName = searchfields.DeveloperName;
      field.order = searchfields.Order__c;
      if ('Exactly'.equalsIgnoreCase(field.searchOperation)) {
        field.type = searchfields.Type__c;
        field.pattern = searchfields.Pattern__c;
      }
      //ASDAC-820 : Update Customer Search in tabs : STARTS
      field.isOrderId = false;
      field.isInOrderTab = false;
      if('orderId'.equalsIgnoreCase(searchfields.Account_Field__c)){
        field.isOrderId = true;
        field.isInOrderTab = true;
      }
      //ASDAC-820 : Update Customer Search in tabs : ENDS
      
      //ASDAC-3770 : Set true if field = PI Hash : STARTS
      field.isPIHash = false;
      if('PI_Hash'.equalsIgnoreCase(searchfields.DeveloperName)){
        field.isInOrderTab = true;
        field.isPIHash = true;
      }
      //ASDAC-3770 : Set true if field = PI Hash : ENDS
      
      fields.add(field);
    }
    fields.sort();
    return fields;
  }

  /**
   * ****************************************************************************************************
   * @param filters list of filters
   * @param customFilter map from custom query fields to their search values
   * @description method to get Customer records matching with the search filters
   * @return ResponseWrapper
   * ****************************************************************************************************
   */
  @AuraEnabled(cacheable=true)
  public static ResponseWrapper getCustomersList(List<FilterWrapper> filters, Map<String, String> customFilter) {
    List<Account> customers = new List<Account>();
    try {
      String query = getBaseQuery();
      query = addCaseCondition(query, customFilter.get('caseNumber'), customFilter.get('orderId'));
      query = addConditions(query, filters);

      String phone = customFilter.get('phone');
      String countryCode = customFilter.get('countryCode');
      Boolean phoneFilter = String.isNotBlank(phone);
      Boolean countryCodeFilter = String.isNotBlank(countryCode);
      if (phoneFilter) {
        phone = sanitizeSearchValue(phone);
        String phoneCondition = ' AND (SecondaryLoginId__c = :phone OR Phone = :phone)';
        if (countryCodeFilter) {
          countryCode = sanitizeSearchValue(countryCode);
          phoneCondition = ' AND CountryCode__c = :countryCode';
        }
        query = query.replace(ADDITIONAL_FILTERS_PLACEHOLDER, phoneCondition);
        customers = (List<Account>) Database.query(query);

        if (customers.size() == 0) {
          // Run custom query on ContactPointPhone if not found on Phone or SecondaryLoginId fields
          query = getBaseQuery();
          query = addCaseCondition(query, customFilter.get('caseNumber'), customFilter.get('orderId'));
          query = addConditions(query, filters);

          String phoneQuery = 'SELECT ParentId FROM ContactPointPhone WHERE TelephoneNumber = :phone';
          if (countryCodeFilter) {
            phoneQuery += ' AND CountryCode__c = :countryCode';
          }
          query = query.replace(ADDITIONAL_FILTERS_PLACEHOLDER, ' AND Id IN (' + phoneQuery + ')');
          customers = (List<Account>) Database.query(query);
        }
      } else {
        query = query.replace(ADDITIONAL_FILTERS_PLACEHOLDER, '');
        customers = (List<Account>) Database.query(query);
      }
    } catch (Exception e) {
      writeLogsToDatabase(e.getMessage());
      return new ResponseWrapper(false, e.getMessage());
    }
    return new ResponseWrapper(true, JSON.serialize(customers));
  }

  /**
   * ****************************************************************************************************
   * @param search search input value
   * @description method to sanitize the search value
   * @return String
   * ****************************************************************************************************
   */
  private static String sanitizeSearchValue(String search) {
    return String.escapeSingleQuotes(search).replace('%', '\\%').replace('_', '\\_'); // Escaping actual wildcards
  }

  /**
   * ****************************************************************************************************
   * @description method to get the base query for Customer search
   * @return String
   * ****************************************************************************************************
   */
  private static String getBaseQuery() {
    String query =
      'SELECT Id, Name, PersonEmail, CountryCode__c, Phone, AddressLine1__pc, PostalCode__pc FROM Account WHERE IsPersonAccount = TRUE' +
      ADDITIONAL_FILTERS_PLACEHOLDER +
      ' ORDER BY Name';
    return query;
  }

  /**
   * ****************************************************************************************************
   * @param query query string to which condition has to be added
   * @param caseNumber caseNumber input value
   * @param orderId orderId input value
   * @description method to add Case based condition to the existing query
   * @return String
   * ****************************************************************************************************
   */
  private static String addCaseCondition(String query, String caseNumber, String orderId) {
    if (String.isNotBlank(caseNumber) || String.isNotBlank(orderId)) {
      String caseQuery = 'SELECT ContactId FROM Case WHERE ';
      List<String> conditions = new List<String>();
      if (String.isNotBlank(caseNumber)) {
        conditions.add('CaseNumber = \'' + caseNumber + '\'');
      }
      if (String.isnotBlank(orderId)) {
        conditions.add('OrderId__c = \'' + orderId + '\'');
      }
      caseQuery += String.join(conditions, ' AND ');
      query = query.replace(ADDITIONAL_FILTERS_PLACEHOLDER, ' AND PersonContactId IN (' + caseQuery + ')' + ADDITIONAL_FILTERS_PLACEHOLDER);
    }
    return query;
  }

  /**
   * ****************************************************************************************************
   * @param query query string to which condition has to be added
   * @param filters list of filters
   * @description method to add condition to the existing query based on the filters provided
   * @return String
   * ****************************************************************************************************
   */
  private static String addConditions(String query, List<FilterWrapper> filters) {
    String conditions = '';
    for (FilterWrapper filter : filters) {
      if (filter.customQuery == true) {
        continue;
      }
      String condition = filter.getCondition();
      if (condition != null) {
        conditions += ' AND ' + condition;
      }
    }
    query = query.replace(ADDITIONAL_FILTERS_PLACEHOLDER, conditions + ADDITIONAL_FILTERS_PLACEHOLDER);
    return query;
  }

  /**
   * ****************************************************************************************************
   * @param orderId orderId which is being searched
   * @description Customer Id will be sent via integration using orderId and then respective account will be displayed
   * ****************************************************************************************************
   */
  @AuraEnabled
  public static ResponseWrapper getCustomerIdFromCallout(String orderId) {
    list<Account> accountList = new List<Account>();
    //Integration needs to be established : -- STARTS
    String customerId = 'OMSTestCustomer123';
    //Customer Id will be recevied from response - Following is a temporary placeholder
    //Integration needs to be established : -- ENDS

    try {
      if(ASDAC_ContactCentreSetting__c.getInstance().IsPersonContactIdUsed__c){
        accountList = [ SELECT Id, PersonContactId, Name, PersonEmail, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Type, CreatedDate, ExternalId__c FROM Account WHERE PersonContactId = :customerId WITH SECURITY_ENFORCED ];
      }else{
        accountList = [ SELECT Id, PersonContactId, Name, PersonEmail, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Type, CreatedDate, ExternalId__c FROM Account WHERE ExternalId__c = :customerId WITH SECURITY_ENFORCED ];
      }
      
    } catch (Exception e) {
      writeLogsToDatabase(e.getMessage());
      return new ResponseWrapper(false, e.getMessage());
    }
    return new ResponseWrapper(true, JSON.serialize(accountList));
  }

  /**
   * ****************************************************************************************************
   * @param exceptionMessage exception message
   * @description future method to write logs to database
   * ****************************************************************************************************
   */
  @Future
  private static void writeLogsToDatabase(String exceptionMessage) {
    ASDAC_Logger.logException(exceptionMessage, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, 'ASDAC_CustomerSearch');
    ASDAC_Logger.writeLogsToDatabase();
  }

  /**********************************************************************************
   * @author                       : KasiViswaNath Gandham
   * @date                         : 2022-05-23
   * @description                  : wrapper class for filter
   **********************************************************************************/
  public class FilterWrapper implements Comparable {
    /**
     * @description label for the field to show
     * ASDAC-820
     */
    @AuraEnabled
    public String fieldUniqueName { get; set; }
    /**
     * @description label for the field to show
     * ASDAC-820
     */
    @AuraEnabled
    public Boolean isOrderId { get; set; }
    /**
     * @description indicates if it's PI Hash
     * ASDAC-3770
     */
    @AuraEnabled
    public Boolean isPIHash { get; set; }
    /**
     * @description indicates if it's PI Hash
     * ASDAC-3770
     */
    @AuraEnabled
    public Boolean isInOrderTab { get; set; }
    
    /**
     * @description label for the field to show
     */
    @AuraEnabled
    public String label { get; set; }
    /**
     * @description api name of the field
     */
    @AuraEnabled
    public String field { get; set; }
    /**
     * @description search operation: Exactly, or Partial
     */
    @AuraEnabled
    public String searchOperation { get; set; }
    /**
     * @description search input value for that field
     */
    @AuraEnabled
    public String search { get; set; }
    /**
     * @description indicate whether query for this field is customized
     */
    @AuraEnabled
    public Boolean customQuery { get; set; }
    /**
     * @description input type of field (text, email, tel, number)
     */
    @AuraEnabled
    public String type { get; set; }
    /**
     * @description input pattern for field validation
     */
    @AuraEnabled
    public String pattern { get; set; }
    /**
     * @description input max length for field validation
     */
    @AuraEnabled
    public Decimal maxLength { get; set; }
    /**
     * @description sort order of the field
     */
    @AuraEnabled
    public Decimal order { get; set; }

    /**
     * ****************************************************************************************************
     * @description method to get condition for a filter
     * @return String
     * ****************************************************************************************************
     */
    public String getCondition() {
      if (!String.isNotBlank(search)) {
        return null;
      }

      String searchValue = sanitizeSearchValue(search);
      Boolean partialMatch = !'Exactly'.equalsIgnoreCase(searchOperation);
      if (partialMatch) {
        if (search.contains('*')) {
          searchValue = searchValue.replace('*', '%');
        } else {
          searchValue = '%' + searchValue + '%';
        }
      }

      List<String> fieldNames = field.split(', *');
      List<String> conditions = new List<String>();
      if (!partialMatch) {
        for (String fieldName : fieldNames) {
          conditions.add(fieldName + ' = \'' + searchValue + '\'');
        }
      } else {
        for (String fieldName : fieldNames) {
          conditions.add(fieldName + ' LIKE \'' + searchValue + '\'');
        }
      }
      return '(' + String.join(conditions, ' OR ') + ')';
    }

    /**
     * ****************************************************************************************************
     * @description method to compare with other instance
     * @return String
     * ****************************************************************************************************
     */
    public Integer compareTo(Object compareTo) {
      // Cast argument to FilterWrapper
      FilterWrapper compareToWrapper = (FilterWrapper) compareTo;

      // The return value of 0 indicates that both elements are equal
      Integer returnValue = 0;
      if (order > compareToWrapper.order) {
        // Set return value to a positive value
        returnValue = 1;
      } else if (order < compareToWrapper.order) {
        // Set return value to a negative value
        returnValue = -1;
      }
      return returnValue;
    }
  }

  /**********************************************************************************
   * @author                       : Vineeth Rangamgari
   * @date                         : 2022-06-13
   * @description                  : wrapper class for response
   **********************************************************************************/
  public class ResponseWrapper {
    /**
     * @description indicates successful request
     */
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    /**
     * @description response message
     */
    @AuraEnabled
    public String message { get; set; }

    ResponseWrapper(Boolean isSuccess, String message) {
      this.isSuccess = isSuccess;
      this.message = message;
    }
  }
}