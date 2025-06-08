@IsTest
public with sharing class ASDAC_OrderController_Test {
  private final static String ORDER_LIST_MOCK_RESOURCE_NAME = 'SampleGetOrderListMock';
  private final static String ORDER_LIST_MOCK_RESOURCE_NAME_GHS = 'SampleHistoryJsonResponseGrocery';
  private final static String ORDER_LIST_MOCK_NULL_DATES = 'SampleOrderHistoryNullWrapper';
  private final static String ORDER_MOCK_RESOURCE_NAME = 'SampleGetOrderMock';
  private final static String GHS_ORDER_MOCK_RESOURCE_NAME = 'SampleGetGhsOrderMock';
  private final static String BUNDLE_ORDER_MOCK_RESOURCE_NAME = 'SampleGetOrderMockBundles';
  private final static String EXCHANGE_ORDER_MOCK_RESOURCE_NAME = 'SampleExchangeOrderWrapper';
  public static final String BUSINESS_AREA= 'George';
  public static final String GHS_BUSINESS_AREA= 'GROCERY';
  public static final String ORDER_ID = 'AP-202205160031';
  private final static String RETRUN_PREVIEW_MOCK_RESOURCE_NAME = 'SampleReturnPreviewWrapper';
  private final static String RETRUN_ORDER_MOCK_RESOURCE_NAME = 'SampleReturnOrderWrapper';
  private final static String TIMEOUT_EXCEPTION_MESSAGE = 'Timeout';
  private final static String VALIDATION_EXCEPTION_MESSAGE = 'Unauthorized';
  private final static String TECHNICAL_EXCEPTION_MESSAGE = 'Internal Server Error';
  private final static String GENERIC_TECHNICAL_EXCEPTION_MESSAGE = 'Something went wrong. Please try again later.';
  private final static String APEX_EXCEPTION_MESSAGE = 'Invalid JSON';
  private final static String EXPECTED_TIMEOUT_EXCEPTION_MESSAGE = 'Expected handled Timeout error message';
  private final static String EXPECTED_VALIDATION_EXCEPTION_MESSAGE = 'Expected exact Validation error message';
  private final static String EXPECTED_TECHNICAL_EXCEPTION_MESSAGE = 'Expected handled Tecnical error message';
  private final static String RETURN_EXPECTED_TECHNICAL_EXCEPTION_MESSAGE = 'Return could not be created due to a technical error. Please try again.';
  private final static String GHSREFUND_EXPECTED_TECHNICAL_EXCEPTION_MESSAGE = 'Refund could not be created due to a technical error. Please try again.';
  private final static String REFUND_TIMEOUT_EXCEPTION_MESSAGE = 'The transaction is in progress. Please check after sometime to know whether the transaction is a success or not.';
  private final static String EXPECTED_APEX_EXCEPTION_MESSAGE = 'Expected handled Apex error message';
  private final static String DELIVERY_CHARGE_REFUND_MOCK_RESOURCE_NAME = 'SampleDeliveryChargeRefundWrapper';
  private final static String WHOLE_ORDER_REFUND_MOCK_RESOURCE_NAME = 'SampleWholeOrderWrapper';
  private final static String PARTIAL_REFUND_MOCK_RESOURCE_NAME='SamplePartialRefundWrapper';
  private final static String ATP_MOCK_RESOURCE_NAME='SampleATPWrapper';
  private final static String CANCEL_ORDER_MOCK_RESOURCE_NAME='SampleCancelOrderWrapper';
  public final static String  USER_RECORD = 'testUser_0@testing_0.com';
    
  @TestSetup
  static void createData(){
    User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
    ocsASDABaseUser.userName = ocsASDABaseUser.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
    insert ocsASDABaseUser;
    ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsASDABaseUser},ASDAC_GlobalConstants.STRING_TEAMLEAD_UK_PSG_NAME);
	}
 
  @IsTest
  static void testGetOrders() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_LIST_MOCK_RESOURCE_NAME));
      ASDAC_OrderHistoryResponse orderHistory = ASDAC_OrderController.getOrders(new ASDAC_OrderHistoryOption());
      ASDAC_OrderHistoryResponse orderHistoryResponse = new ASDAC_OrderHistoryResponse();
      System.assert(orderHistory != null, 'Expected Order History response');
      ASDAC_OrderHeaderResponse order = orderHistory.data[0];
      System.assert(String.isNotEmpty(order.orderId), 'Expected Order Id to not be empty');
      System.assert(String.isNotEmpty(order.formattedOrderDate), 'Expected formatted order date to not be empty');
      System.assert(String.isNotEmpty(order.sellingChannel), 'Expected sellingChannel to not be empty');
      System.assert(String.isNotEmpty(order.orderFulfilmentType), 'Expected orderFulfilmentType to not be empty');
      System.assert(String.isNotEmpty(order.formattedDeliveryDate), 'Expected formattedDeliveryDate to not be empty');
      System.assert(String.isNotEmpty(order.orderStatus), 'Expected orderStatus to not be empty');
      System.assert(String.isNotEmpty(order.fulfillmentType), 'Expected fulfillmentType to not be empty');
      System.assert(String.isNotEmpty(order.storeAddress), 'Expected storeAddress to not be empty');
      System.assert(String.isNotEmpty(order.formattedTotalAmount), 'Expected formattedTotalAmount to not be empty');
      System.assert(String.isNotEmpty(order.formattedActionDate), 'Expected formattedActionDate to not be empty');
      Test.stopTest();
    }
  }
    
    @IsTest
  static void testGetOrdersGrocery() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_LIST_MOCK_RESOURCE_NAME_GHS));
      ASDAC_OrderHistoryResponse orderHistory = ASDAC_OrderController.getOrders(new ASDAC_OrderHistoryOption());
      ASDAC_OrderHistoryResponse orderHistoryResponse = new ASDAC_OrderHistoryResponse();
      System.assert(orderHistory != null, 'Expected Order History response');
      ASDAC_OrderHeaderResponse order = orderHistory.data[1];
      System.assert(String.isNotEmpty(order.orderId), 'Expected Order Id to not be empty');
      System.assert(String.isNotEmpty(order.formattedOrderDate), 'Expected formatted order date to not be empty');
      System.assert(String.isNotEmpty(order.sellingChannel), 'Expected sellingChannel to not be empty');
      System.assert(String.isNotEmpty(order.orderFulfilmentType), 'Expected orderFulfilmentType to not be empty');
      System.assert(String.isNotEmpty(order.formattedDeliveryDate), 'Expected formattedDeliveryDate to not be empty');
      System.assert(String.isNotEmpty(order.orderStatus), 'Expected orderStatus to not be empty');
      System.assert(String.isNotEmpty(order.fulfillmentType), 'Expected fulfillmentType to not be empty');
      System.assert(String.isNotEmpty(order.storeAddress), 'Expected storeAddress to not be empty');
      System.assert(String.isNotEmpty(order.formattedTotalAmount), 'Expected formattedTotalAmount to not be empty');
      System.assert(String.isNotEmpty(order.formattedActionDate), 'Expected formattedActionDate to not be empty');
      Test.stopTest();
    }
  }
    
     @IsTest
  static void testGetOrdersNullDates() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_LIST_MOCK_NULL_DATES));
      ASDAC_OrderHistoryResponse orderHistory = ASDAC_OrderController.getOrders(new ASDAC_OrderHistoryOption());
      System.assert(orderHistory != null, 'Expected Order History response');
      ASDAC_OrderHeaderResponse order = orderHistory.data[0];
      System.debug(orderHistory.data[0]);
      System.assert(String.isNotEmpty(order.orderId), 'Expected Order Id to not be empty');
      System.assert(String.isEmpty(order.formattedOrderDate), 'Expected formatted order date to  be empty');
      System.assert(String.isEmpty(order.formattedActionDate), 'Expected formatted action date to be empty');
      System.assert(String.isEmpty(order.formattedTotalAmount), 'Expected formattedTotalAmount to not be empty');
      System.assert(String.isEmpty(order.formattedDeliveryDate), 'Expected formattedDeliveryDate to not be empty');
      Test.stopTest();
    }
  }
 
  @IsTest
  static void testGetOrdersTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderController.getOrders(new ASDAC_OrderHistoryOption());
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(System.Label.ASDAC_OmsTechnicalExceptionMessage, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }


  @IsTest
  static void testGetOrdersApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderController.getOrders(new ASDAC_OrderHistoryOption());
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testGetOrder() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_MOCK_RESOURCE_NAME));
      ASDAC_OrderResponse orderResponse = ASDAC_OrderController.getOrder(BUSINESS_AREA,ORDER_ID,null);
      ASDAC_OrderLineStateResponse lineStateRes = new ASDAC_OrderLineStateResponse();
      System.assert(orderResponse != null, 'Expected Order response');
      System.assert(String.isEmpty(orderResponse.customerSalesforceConId), 'Expected customerSalesforceConId to not be empty');
      System.assert(orderResponse.isCancelDisabled != null, 'Expected cancel to not be null');
      System.assert(orderResponse.isRefundDisabled != null, 'Expected refund to not be null');
      System.assert(orderResponse.isExchangeDisabled != null, 'Expected exchange to not be null');
      System.assert(orderResponse.isDiscountDisabled != null, 'Expected discount to not be null');
      System.assertEquals(orderResponse.orderLines, orderResponse.orderItems, 'Expected orderItems to be orderLines');
      System.assertEquals(orderResponse.orderLines[0].shipments, orderResponse.orderLines[0].shipmentDetails, 'Expected orderItems to be orderLines');
      System.assertEquals('30 September 2022, Fri 06:34 AM', orderResponse.orderLines[0].shipments[0].estimateDeliveryDate, 'Expected estimateDeliveryDate');
      System.assertEquals('05 November 2023, Sun 02:19 PM', orderResponse.orderLines[0].shipments[0].promiseDeliveryDate, 'Expected promiseDeliveryDate');
      System.assertEquals('30 September 2022, Fri 06:34 AM', orderResponse.orderLines[0].shipments[0].shipDate, 'Expected shipDate');
      System.assertEquals('Melrose Rugs', orderResponse.orderLines[0].shipments[0].fulfillmentCentreName, 'Expected fulfillmentCentreName');
      Test.stopTest();
    }
 }
    
    @IsTest
  static void testGetOrderBundles() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(BUNDLE_ORDER_MOCK_RESOURCE_NAME));
      ASDAC_OrderResponse orderResponse = ASDAC_OrderController.getOrder(BUSINESS_AREA,ORDER_ID,null);
      System.assert(orderResponse != null, 'Expected Order response');
      System.assertEquals(orderResponse.orderLines, orderResponse.orderItems, 'Expected orderItems to be orderLines');
      Test.stopTest();
    }
  }
    
  @IsTest
  static void testGetGhsOrder() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(GHS_ORDER_MOCK_RESOURCE_NAME));
      ASDAC_OrderResponse orderResponse = ASDAC_OrderController.getOrder(GHS_BUSINESS_AREA,ORDER_ID,null);
      System.assert(orderResponse != null, 'Expected Order response');
      System.assertEquals(orderResponse.orderLines, orderResponse.orderItems, 'Expected orderItems to be orderLines');
      String returnAssociationType = orderResponse.returnOrders[0].orderLines[0].associationDetails[0].associationType;
      Integer returnAssociationId = orderResponse.returnOrders[0].orderLines[0].associationDetails[0].associatedLineId;
      System.assertEquals(returnAssociationType, 'SalesOrder', 'Expected AssociationType to be SalesOrder');
      System.assertEquals(returnAssociationId, 1, 'Expected AssociationId to be 1');
      System.assertEquals(orderResponse.rewardVouchers[0].rewardVoucherId, '19348055590', 'Expected rewardVoucherId to be 19348055590');
      System.assertEquals(orderResponse.rewardVouchers[0].amountUsed, 10.25, 'Expected amountUsed to be 10.25');
      Test.stopTest();
    }
  }

  @IsTest
  static void testGetOrderTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderController.getOrder(BUSINESS_AREA,ORDER_ID,null);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(GENERIC_TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, 'Expected handled Technical error message');
      Test.stopTest();
    }
  }

  @IsTest
  static void testGetOrderApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderController.getOrder(BUSINESS_AREA,ORDER_ID,null);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testExchangeOrder() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Exchange successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(EXCHANGE_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.exchangeOrder(orderWrapper);
      System.assert(response != null, 'Expected successfull Exchange');
      Test.stopTest();
    }
  }

  @IsTest
  static void testExchangeOrderTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(EXCHANGE_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.exchangeOrder(orderWrapper);
      } catch (Exception ex) {
        Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(System.Label.ASDAC_OmsExchangeTechnicalExceptionMessage, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testExchangeOrderApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(EXCHANGE_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.exchangeOrder(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testGetCustomerId() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Account customerAccount = ASDAC_TestDataUtility.createPersonAccount(true);
      String crmId = [SELECT PersonContactId FROM Account WHERE Id = :customerAccount.Id]?.PersonContactId;
      String customerId = ASDAC_OrderController.getCustomerId(customerAccount.Id);
      System.assertEquals(crmId, customerId, 'Expected CRM Id');
      Test.stopTest();
    }
  }

  @IsTest
  static void testGetOrderHistoryFields() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      List<ASDAC_OrderHistoryField__mdt> fields = ASDAC_OrderController.getOrderHistoryFields();
      System.assert(fields.size() > 0, 'Expected Order History fields');
      Test.stopTest();
    }
  }
    
  
  @IsTest
  static void testCreateReturnPreviewRequest() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(RETRUN_ORDER_MOCK_RESOURCE_NAME));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_PREVIEW_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      ASDAC_ReturnPreviewResponse response = ASDAC_OrderController.createReturnPreviewRequest(orderWrapper);
      System.assert(response != null, 'Expected successfull Return Preview');
      ASDAC_OrderTotal orderTotal = response.orderTotals;
      System.assert(orderTotal != null, 'Expected orderTotals to not be null');
      System.assertEquals(response.orderLines,response.orderLines, 'Expected orderItems to be orderLines');
      Test.stopTest();
      }
  }

  @IsTest
  static void testReturnPreviewTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_PREVIEW_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createReturnPreviewRequest(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(GENERIC_TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testReturnPreviewApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createReturnPreviewRequest(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
    @IsTest
  static void testCreateReturnRequest() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Return successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.createReturnRequest(orderWrapper);
      System.assert(response != null, 'Expected successfull Return');
      Test.stopTest();
    }
  }

  @IsTest
  static void testCreateReturnGeorgeTimeoutException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(408, TIMEOUT_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createReturnRequest(orderWrapper);
      } catch (Exception ex) {
        Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(RETURN_EXPECTED_TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_VALIDATION_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testCreateReturnGroceryTimeoutException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(408, TIMEOUT_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        orderWrapper.sellingChannel = ASDAC_OMSConstants.ASDA_GROCERIES_STRING;
        ASDAC_OrderController.createReturnRequest(orderWrapper);
      } catch (Exception ex) {
        Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(REFUND_TIMEOUT_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TIMEOUT_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

    @IsTest
  static void testCreateReturnTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createReturnRequest(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(RETURN_EXPECTED_TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
     @IsTest
  static void testCreateReturnApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createReturnRequest(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
     @IsTest
  static void testCreateWholeOrderRefundRequest() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Refund successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(WHOLE_ORDER_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.createWholeOrderRefundRequest(orderWrapper);
      System.assert(response != null, 'Expected successfull Refund');
      Test.stopTest();
    }
  }

  @IsTest
  static void testWholeOrderRefundTimeoutException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(408, TIMEOUT_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(WHOLE_ORDER_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createWholeOrderRefundRequest(orderWrapper);
      } catch (Exception ex) {
        Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(REFUND_TIMEOUT_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TIMEOUT_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
  @IsTest
  static void testWholeOrderRefundTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(WHOLE_ORDER_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createWholeOrderRefundRequest(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(GHSREFUND_EXPECTED_TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
   @IsTest
  static void testWholeOrderRefundApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(WHOLE_ORDER_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createWholeOrderRefundRequest(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  //receive request test cases
  @IsTest
  static void testReceiveRequest() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Return successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.receiveRequest(orderWrapper);
      System.assert(response != null, 'Expected successfull Return');
      Test.stopTest();
    }
  }

    @IsTest
  static void testReceiveRequestTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.receiveRequest(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(System.Label.ASDAC_OmsGeorgeReceiveTechnicalExceptionMessage, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
     @IsTest
  static void testReceiveRequestApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.receiveRequest(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testDeliveryChargeRefundOrder() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Delivery charge refunded successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(DELIVERY_CHARGE_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.deliveryChargeRefundOrder(orderWrapper);
      System.assert(response != null, 'Expected successfull delivery charge');
      Test.stopTest();
    }
  }

  @IsTest
  static void testDeliveryChargeRefundOrderTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(DELIVERY_CHARGE_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.deliveryChargeRefundOrder(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(System.Label.ASDAC_OmsDeliveryChargeTechnicalExceptionMessage, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testDeliveryChargeRefundOrderApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(DELIVERY_CHARGE_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.deliveryChargeRefundOrder(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
         
  @IsTest
  static void testCreateRefundOverrideRequest() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Return successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.createRefundOverrideRequest(orderWrapper);
      System.assert(response != null, 'Expected successfull Return');
      Test.stopTest();
    }
  }
     @IsTest
  static void testRefundOverrideTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createRefundOverrideRequest(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(GHSREFUND_EXPECTED_TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
     @IsTest
  static void testRefundOverrideApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(RETRUN_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createRefundOverrideRequest(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
    
   @IsTest
  static void testStoreValidationRule() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      try {
        Store__c testStore = new Store__c(Name='TestStore',StoreNumber__c = 'T81T',PostalCode__c='10007',City__c='test',StoreFormat__c='Supermarket');
        insert testStore;
        String storeId = ASDAC_OrderController.getStoreId('T81T');
        System.assertEquals(teststore.id,storeId, 'TestStore');
      } catch (DmlException e) {
        String expectedExceptionMessage = 'Store Number shouldn\'t exceed more than 4 characters';
        System.assert(e.getMessage().contains(expectedExceptionMessage), 'Validation rule exception should be thrown');
      }
      Test.stopTest();
    }
  } 
    
  @IsTest
  static void testPartialRefundOrder() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Partial refund successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(PARTIAL_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.partialRefundOrder(orderWrapper);
      System.assert(response != null, 'Expected successfull Partial Refund');
      Test.stopTest();
    }
  }
    
  @IsTest
  static void testPartialRefundOrderTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(PARTIAL_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.partialRefundOrder(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(System.Label.ASDAC_OmsPartialRefundTechnicalExceptionMessage, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
  @IsTest
  static void testPartialRefundOrderApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(PARTIAL_REFUND_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.partialRefundOrder(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
  
  @IsTest
  static void testCancelOrder() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(201, '"Cancel Order successful"'));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(CANCEL_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.cancelOrder(orderWrapper);
      System.assert(response != null, 'Expected successfull cancel order');
      Test.stopTest();
    }
  }

  @IsTest
  static void testCancelOrderTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(CANCEL_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.cancelOrder(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(System.Label.ASDAC_OmsCancelOrderTechnicalExceptionMessage, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testCancelOrderApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(CANCEL_ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.cancelOrder(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
   static void testATPOrder() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ATP_MOCK_RESOURCE_NAME));
      ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(ATP_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
      String response = ASDAC_OrderController.createATPRequest(orderWrapper);
      ASDAC_GetOrderATPWrapper responseString = new ASDAC_GetOrderATPWrapper();
      responseString= (ASDAC_GetOrderATPWrapper) JSON.deserialize(response, ASDAC_GetOrderATPWrapper.class);
      System.assert(responseString != null, 'Expected successfull');
      Test.stopTest();
    }
  }
    
  @IsTest
  static void testATPOrderTechnicalException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createATPRequest(orderWrapper);
      } catch (Exception ex) {
          Map<String, Object> exceptionMap = (Map<String, Object>) JSON.deserializeUntyped(ex.getMessage());
        exceptionMsg = (String) exceptionMap.get('message');
      }
      System.assertEquals(System.Label.ASDAC_OmsATPTechnicalExceptionMessage, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      System.assertNotEquals(TECHNICAL_EXCEPTION_MESSAGE, exceptionMsg, EXPECTED_TECHNICAL_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @IsTest
  static void testATPOrderApexException() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(200, APEX_EXCEPTION_MESSAGE));

      String exceptionMsg;
      try {
        ASDAC_OrderWrapper orderWrapper = (ASDAC_OrderWrapper) JSON.deserialize(ASDAC_CommonUtility.getStaticResource(ORDER_MOCK_RESOURCE_NAME), ASDAC_OrderWrapper.class);
        ASDAC_OrderController.createATPRequest(orderWrapper);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg != null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }
    
    @IsTest
  static void getOrderFulfillDateTest() {
    User asdaBaseUsr = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    System.runAs(asdaBaseUsr) {
      Test.startTest();
      ASDAC_OrderIntegrationService instance = new ASDAC_OrderIntegrationService();
      instance.createRequest('{}');
      Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_MOCK_RESOURCE_NAME));
      String exceptionMsg;
      try {
        List<String> idList  = new List<String>();
        idList.add('7871413');
        List<String> respose =  ASDAC_OrderController.getOrderFulfillDate(idList);
      } catch (Exception ex) {
        exceptionMsg = ex.getMessage();
      }
      System.assert(exceptionMsg == null, EXPECTED_APEX_EXCEPTION_MESSAGE);
      Test.stopTest();
    }
  }

  @isTest
  static void testGetUserGroups() {
    User testUser = getUserRecord(USER_RECORD + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX);
    Group testGroup = new Group(
        Name = System.Label.ASDAC_OverrideRefundEligiblePublicGroups,
        Type = 'Regular'
    );
    insert testGroup;
    GroupMember testGroupMember = new GroupMember(
        GroupId = testGroup.Id,
        UserOrGroupId = testUser.Id
    );
    insert testGroupMember;

    Test.startTest();
    List<String> userGroups = ASDAC_OrderController.getUserGroups(testUser.Id);
    Test.stopTest();

    Assert.areEqual(1, userGroups.size(), 'User should belong to one group');
    Assert.areEqual(System.Label.ASDAC_OverrideRefundEligiblePublicGroups, userGroups[0], 'Group name should be ' + System.Label.ASDAC_OverrideRefundEligiblePublicGroups);
  }
    
    private static User getuserRecord(String username) {
      return [SELECT Id FROM User WHERE UserName = :username];
    }
}