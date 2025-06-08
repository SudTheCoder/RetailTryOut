@isTest
public class ASDAC_VatReceiptWrapperTest {
	
     private final static String USER_NAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
    
    /**************************************************************************
    Purpose    : Test Setup data                                           
    Parameters : NA
    Returns    : NA                                        
    **************************************************************************/ 
    @TestSetup
    static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        
    }
    
    @isTest
    static void testASDAC_VatReceiptWrapper() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_VatReceiptWrapper wrapper = new ASDAC_VatReceiptWrapper();
            wrapper.orderId = 'testOrderId';
            wrapper.sellingChannel = 'testSellingChannel';
            wrapper.orderDate = DateTime.newInstance(2022, 1, 1, 12, 30, 0);
            wrapper.vatDate = 'testVatDate';
            wrapper.vatRegistrationNumber = 'testVatRegistrationNumber';
            wrapper.vatRateDeliveryCharge = 5;
            wrapper.vatAmountDeliveryCharge = 3;
            wrapper.currentDeliveryCharge = 2;
            wrapper.customerId = 'testBillToContactName';
            wrapper.billToContact = new ASDAC_OrderContact();
            wrapper.shipToAddress = new ASDAC_OrderAddress();
            wrapper.orderFulfilmentTypeGrocery = 'testFulfillmentType';
            wrapper.multisaveDiscount = 1;
            wrapper.asdaRewardDiscount = 2;
            wrapper.colleagueDiscount = 3;
            wrapper.marketingCouponAmount = 4;
            wrapper.eVoucherAmount = 5;
            wrapper.vatAmount = 6;
            wrapper.vatTotalPrice = 7;
    
            System.assertEquals('£5.00', wrapper.formattedvatRateDeliveryCharge);
            System.assertEquals('£3.00', wrapper.formattedvatAmountDeliveryCharge);
            System.assertEquals('£2.00', wrapper.formattedcurrentDeliveryCharge);
            System.assertEquals('£1.00', wrapper.formattedmultisaveDiscount);
            System.assertEquals('£2.00', wrapper.formattedasdaRewardDiscount);
            System.assertEquals('£3.00', wrapper.formattedcolleagueDiscount);
            System.assertEquals('£4.00', wrapper.formattedmarketingCouponAmount);
            System.assertEquals('£5.00', wrapper.formattedeVoucherAmount);
            System.assertEquals('01 January 2022', wrapper.formattedVatOrderDate);
    
            Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>> testCategoryMap = new Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>>();
            List<ASDAC_VatReceiptWrapper.LineItemDetails> testLineItems = new List<ASDAC_VatReceiptWrapper.LineItemDetails>();
            ASDAC_VatReceiptWrapper.LineItemDetails lineItem = new ASDAC_VatReceiptWrapper.LineItemDetails();
            lineItem.productDescription = 'testProductDescription';
            lineItem.discountedPrice = 0;
            lineItem.quantity = 1;
            lineItem.unitPrice = 0;
            lineItem.discountedPrice = 0;
            lineItem.vatRate = 0;
            lineItem.exVat = 0;
            lineItem.vatAmount = 0;
            testLineItems.add(lineItem);
            testCategoryMap.put('TestCategory', testLineItems);
            testCategoryMap.put(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR, testLineItems);
            testCategoryMap.put(ASDAC_OMSConstants.VAT_REFUNDS_STR, testLineItems);
    
            wrapper.categoryMap = testCategoryMap;
            Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>> formattedMap = wrapper.categoryMap;
            System.assertEquals(3, formattedMap.size());
    
            String quantityFormattedNegative = lineItem.quantityFormatted;
            System.assertEquals('-1', quantityFormattedNegative);
    
            String unitPriceFormatted = lineItem.unitPriceFormatted;
            System.assertEquals('-£0.00', unitPriceFormatted);
    
            String discountedPriceFormatted = lineItem.discountedPriceFormatted;
            System.assertEquals('-£0.00', discountedPriceFormatted);
    
            String vatAmountFormatted = lineItem.vatAmountFormatted;
            System.assertEquals('-£0.00', vatAmountFormatted);
        }
    }
    @isTest
    static void testFormattedvatAmount() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_VatReceiptWrapper wrapper = new ASDAC_VatReceiptWrapper();
            wrapper.categoryList = new List<String>{'TestCategory'};
            wrapper.categoryMap = new Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>>{'TestCategory' => new List<ASDAC_VatReceiptWrapper.LineItemDetails>()};
            wrapper.vatAmountDeliveryCharge = 5;
            wrapper.categoryMap.get('TestCategory').add(new ASDAC_VatReceiptWrapper.LineItemDetails());
            wrapper.categoryMap.get('TestCategory')[0].vatAmount = 3;
            System.assertEquals('£8.00', wrapper.formattedvatAmount);
        }
    }
    
    
    @isTest
    static void testFormattedvatTotalPrice() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_VatReceiptWrapper wrapper = new ASDAC_VatReceiptWrapper();
            wrapper.currentDeliveryCharge = 2;
            wrapper.categoryList = new List<String>{'TestCategory'};
            wrapper.categoryMap = new Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>>{'TestCategory' => new List<ASDAC_VatReceiptWrapper.LineItemDetails>()};
            wrapper.categoryMap.get('TestCategory').add(new ASDAC_VatReceiptWrapper.LineItemDetails());
            wrapper.categoryMap.get('TestCategory')[0].discountedPrice = 5;
            wrapper.categoryMap.get('TestCategory')[0].refundAmount = 1;
            System.assertEquals('£6.00', wrapper.formattedvatTotalPrice);
        }   
    }
    
    @isTest
    static void testGetFormattedMap() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_VatReceiptWrapper wrapper = new ASDAC_VatReceiptWrapper();
            Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>> value = new Map<String, List<ASDAC_VatReceiptWrapper.LineItemDetails>>();
            List<ASDAC_VatReceiptWrapper.LineItemDetails> lineItems = new List<ASDAC_VatReceiptWrapper.LineItemDetails>();
            lineItems.add(new ASDAC_VatReceiptWrapper.LineItemDetails());
            value.put('TestCategory', lineItems);
            value.put(ASDAC_OMSConstants.VAT_DELIVERY_COST_STR, lineItems);
            value.put(ASDAC_OMSConstants.VAT_REFUNDS_STR, lineItems);
            wrapper.getFormattedMap(value);
            System.assertEquals(3, wrapper.categoryList.size());
        }
    }
    
    @isTest
    static void testUpdateLineItems() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_VatReceiptWrapper wrapper = new ASDAC_VatReceiptWrapper();
            List<ASDAC_VatReceiptWrapper.LineItemDetails> lineItems = new List<ASDAC_VatReceiptWrapper.LineItemDetails>();
            lineItems.add(new ASDAC_VatReceiptWrapper.LineItemDetails());
            wrapper.updateLineItems(lineItems, true);
            System.assertEquals(true, lineItems[0].isRefundItem);
        }
    }
    
    /**************************************************************************
    Purpose    : Get User Record                                           
    Parameters : username
    Returns    : User record                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
}