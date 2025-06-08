@isTest
public class ASDAC_ReturnPreviewResponse_Test {
    
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
    
	@isTest static void testASDAC_ReturnPreviewResponse() {
        
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_ReturnPreviewResponse previewResponse = new ASDAC_ReturnPreviewResponse();
            
            previewResponse.updateTime = '2024-04-15T12:00:00Z';
            previewResponse.orgId = 'Org123';
            previewResponse.orderId = 'Order123';
            previewResponse.customerId = 'Customer123';
            previewResponse.orderCategory = 'Online';
            previewResponse.orderDate = '2024-04-14';
            previewResponse.billingCurrency = 'USD';
            previewResponse.refundStatus = 'Pending';
            previewResponse.refundPaymentMethod = 'CreditCard';
            
            ASDAC_OrderTotal orderTotal = new ASDAC_OrderTotal();
            orderTotal.totalAmount = 100.00;
            previewResponse.orderTotals = orderTotal;
            
            ASDAC_ReturnPreviewResponse.ASDAC_PreviewResponseorderLines orderLine = new ASDAC_ReturnPreviewResponse.ASDAC_PreviewResponseorderLines();
            orderLine.updateTime = '2024-04-15T12:01:00Z';
            orderLine.orderLineId = 'Line123';
            orderLine.orderLineType = 'Standard';
            orderLine.quantity = '2';
            orderLine.productId = 'Prod123';
            orderLine.productDescription = 'Sample Product';
            orderLine.uom = 'EA';
            orderLine.isBundle = false;
            
            ASDAC_ReturnPreviewResponse.LineAssociationDetails associationDetail = new ASDAC_ReturnPreviewResponse.LineAssociationDetails();
            associationDetail.associatedLineId = 456;
            orderLine.associationDetails = new List<ASDAC_ReturnPreviewResponse.LineAssociationDetails>{associationDetail};
            
            previewResponse.orderLines.add(orderLine);
            
    
            System.assertEquals('2024-04-15T12:00:00Z', previewResponse.updateTime);
            System.assertEquals('Org123', previewResponse.orgId);
            System.assertEquals('Order123', previewResponse.orderId);
            System.assertEquals('Customer123', previewResponse.customerId);
            System.assertEquals('Online', previewResponse.orderCategory);
            System.assertEquals('2024-04-14', previewResponse.orderDate);
            System.assertEquals('USD', previewResponse.billingCurrency);
            System.assertEquals('Pending', previewResponse.refundStatus);
            System.assertEquals('CreditCard', previewResponse.refundPaymentMethod);
            System.assertEquals(100.00, previewResponse.orderTotals.totalAmount);
            
            System.assertEquals('2024-04-15T12:01:00Z', previewResponse.orderLines[0].updateTime);
            System.assertEquals('Line123', previewResponse.orderLines[0].orderLineId);
            System.assertEquals('Standard', previewResponse.orderLines[0].orderLineType);
            System.assertEquals('2', previewResponse.orderLines[0].quantity);
            System.assertEquals('Prod123', previewResponse.orderLines[0].productId);
            System.assertEquals('Sample Product', previewResponse.orderLines[0].productDescription);
            System.assertEquals('EA', previewResponse.orderLines[0].uom);
            System.assertEquals(false, previewResponse.orderLines[0].isBundle);
            System.assertEquals(456, previewResponse.orderLines[0].associationDetails[0].associatedLineId);
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