/***********************************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-16
* @Component Type               : Apex Class
* @component Name               : ASDAC_RenewalSchedulerTest
* @description                  : ASDAC-8813 - GHS - DP SME - Auto-renew payload along with Payment authorization - 3
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-03-22
************************************************************************************************************************/
@isTest
public with sharing class ASDAC_RenewalSchedulerTest {
    
     /**********************************************************************************
     * @author                       : Deepakshi Grover
     * @date                         : 2023-03-17
     * @Method Name                  : testsetup
     * @Modified By                  : Deepakshi
     * @Modified Date		         : 2023-03-22
     **********************************************************************************/
    @testsetup
    static void testsetup() {
        Profile objProfile = [Select id,Name from Profile where Name = 'System Administrator'];
        User objUser = new User(Username = 'recurringslot@asdatest.co.uk',ProfileId = objProfile.Id ,Alias = 'test123',Email = 'test123@asdatest.co.uk',EmailEncodingKey = 'UTF-8',LastName = 'McTesty', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',LanguageLocaleKey = 'en_US');
        insert objUser;
        
        System.runAs(objUser){
            Account objAccount = new Account();
            objAccount.Name = 'DG Test';
            objAccount.Loginid__c ='dg@asdatest.co.uk';
            insert objAccount;
            
            Contact objContact = new Contact();
            objContact.LastName = 'DG Test';
            objContact.AccountId = objAccount.Id;
            insert objContact; 
            
            Asset objAsset = new Asset();
            objAsset.Name = 'Test Asset123';
            objAsset.Recurring_Slot_Frequency__c = 'Daily';
            objAsset.Recurring_Slot_1__c = Datetime.now().addDays(1);
            objAsset.AccountId = objAccount.Id;
            objAsset.ContactId = objContact.Id;
            objAsset.Auto_Renew__c = true;
            objAsset.UsageEndDate = System.today();
            insert objAsset;
        }  
    }
    
     /**********************************************************************************
     * @author                       : Deepakshi Grover
     * @date                         : 2023-03-17
     * @Method Name                  : XMLSchedulerTest
     * @Modified By                  : Deepakshi
     * @Modified Date		         : 2023-03-22
     **********************************************************************************/
    @isTest
    static void xmlSchedulerTest(){
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        String strXML;
        System.runAs(objUser){
            Asset objAsset = [Select id,name from Asset where name='Test Asset123' limit 1];
            strXML = '<?xml version="1.0" encoding="UTF-8"?><orders xmlns="http://www.demandware.com/xml/impex/order/2006-10-31"><order order-no="00002205"><order-date>2023-01-05T14:31:09.000Z</order-date><created-by>storefront</created-by><original-order-no>00002205</original-order-no><currency>GBP</currency><customer-locale>en_US</customer-locale><taxation>gross</taxation><invoice-no>00003502</invoice-no><customer><customer-no>00002022</customer-no><customer-name>Adam Pilacki</customer-name><customer-email>adam.pilacki@publicissapient.com</customer-email><billing-address><salutation>Mr</salutation><first-name>Adam</first-name><last-name>Devtest</last-name><address1>Test BILLING street</address1><address2>Apartment 101/BILLING</address2><city>TestBILLINGCity1</city><postal-code>A12B 3CD</postal-code><country-code>US</country-code><phone>000111000111</phone></billing-address></customer><status><order-status>OPEN</order-status><shipping-status>NOT_SHIPPED</shipping-status><confirmation-status>CONFIRMED</confirmation-status><payment-status>NOT_PAID</payment-status></status><channel-type>Storefront</channel-type><current-order-no>00002205</current-order-no><product-lineitems><product-lineitem><gross-price>3.85</gross-price><base-price>3.85</base-price><lineitem-text>Delivery pass Sample Product</lineitem-text><tax-basis>3.85</tax-basis><position>1</position><product-id>5871309</product-id><product-name>Delivery pass Sample Product</product-name><quantity unit="">1.0</quantity><tax-rate>0.0</tax-rate><shipment-id>00004002</shipment-id><gift>false</gift><custom-attributes><custom-attribute attribute-id="asdaIsCharitableProduct">false</custom-attribute><custom-attribute attribute-id="departmentId">1215165876400</custom-attribute><custom-attribute attribute-id="DP_ServiceStartDate">2023-01-05T14:31:09.000Z</custom-attribute><custom-attribute attribute-id="DP_ServiceEndDate">2024-01-05T14:31:09.000Z</custom-attribute><custom-attribute attribute-id="DP_PlanDurationCount">12</custom-attribute><custom-attribute attribute-id="DP_PlanDurationType">months</custom-attribute></custom-attributes></product-lineitem><product-lineitem><gross-price>3.18</gross-price><base-price>3.18</base-price><lineitem-text>Ramen Noodles Chinese Hot & Sour Soup</lineitem-text><tax-basis>3.18</tax-basis><position>2</position><product-id>5878943</product-id><product-name>Ramen Noodles Chinese Hot & Sour Soup</product-name><quantity unit="">1.0</quantity><tax-rate>0.0</tax-rate><shipment-id>00004002</shipment-id><gift>false</gift><custom-attributes><custom-attribute attribute-id="asdaIsCharitableProduct">false</custom-attribute><custom-attribute attribute-id="departmentId">1215165876400</custom-attribute><custom-attribute attribute-id="departmentName">Tinned Food</custom-attribute></custom-attributes></product-lineitem><product-lineitem><gross-price>2.75</gross-price><base-price>2.75</base-price><lineitem-text>Pretzels Sour Cream & Chive Flavour</lineitem-text><tax-basis>2.75</tax-basis><position>3</position><product-id>5858378</product-id><product-name>Pretzels Sour Cream & Chive Flavour</product-name><quantity unit="">1.0</quantity><tax-rate>0.0</tax-rate><shipment-id>00004002</shipment-id><gift>false</gift><custom-attributes><custom-attribute attribute-id="asdaIsCharitableProduct">false</custom-attribute><custom-attribute attribute-id="departmentId">1215685031916</custom-attribute><custom-attribute attribute-id="departmentName">Party & Entertaining</custom-attribute></custom-attributes></product-lineitem></product-lineitems><shipping-lineitems><shipping-lineitem><gross-price>5.00</gross-price><base-price>5.00</base-price><lineitem-text>Shipping</lineitem-text><tax-basis>5.00</tax-basis><item-id>STANDARD_SHIPPING</item-id><shipment-id>00004002</shipment-id><tax-rate>0.0</tax-rate></shipping-lineitem></shipping-lineitems><shipments><shipment shipment-id="00004002"><status><shipping-status>NOT_SHIPPED</shipping-status></status><shipping-method>ASDADelivery</shipping-method><shipping-address><salutation>Mr</salutation><first-name>Adam</first-name><last-name>Devtest</last-name><address1>Test SHIPPING street</address1><address2>Apartment 101/SHIPPING</address2><city>TestSHIPPINGCity1</city><postal-code>A12B 3CD</postal-code><country-code>US</country-code><phone>000111000111</phone></shipping-address><gift>false</gift><totals><merchandize-total><gross-price>9.78</gross-price></merchandize-total><adjusted-merchandize-total><gross-price>9.78</gross-price></adjusted-merchandize-total><shipping-total><gross-price>5.00</gross-price></shipping-total><adjusted-shipping-total><gross-price>5.00</gross-price></adjusted-shipping-total><shipment-total><gross-price>14.78</gross-price></shipment-total></totals></shipment></shipments><totals><merchandize-total><gross-price>9.78</gross-price></merchandize-total><adjusted-merchandize-total><gross-price>9.78</gross-price></adjusted-merchandize-total><shipping-total><gross-price>5.00</gross-price></shipping-total><adjusted-shipping-total><gross-price>5.00</gross-price></adjusted-shipping-total><order-total><gross-price>14.78</gross-price></order-total></totals><payments><payment><custom-method><method-name>INGENICO_OGONE_CARD</method-name><custom-attributes><custom-attribute attribute-id="ingenicoOgoneAuthorisationCode">724596101</custom-attribute><custom-attribute attribute-id="ingenicoOgoneCardToken">bce31ca2-9822-4850-a065-9fe87b78b458</custom-attribute><custom-attribute attribute-id="ingenicoOgonePaymentProductID">3.0</custom-attribute><custom-attribute attribute-id="ingenicoOgonePaymentProductName">MasterCard</custom-attribute></custom-attributes></custom-method><amount>14.78</amount><processor-id>INGENICO_OGONE_CREDIT</processor-id><transaction-id>3252285590_0</transaction-id></payment></payments><custom-attributes><custom-attribute attribute-id="asdaCashpotEarned">0.0</custom-attribute><custom-attribute attribute-id="asdaDyCookieConsent">true</custom-attribute><custom-attribute attribute-id="asdaDyIdCookie">1418634829187345228</custom-attribute><custom-attribute attribute-id="asdaDyjsession">ttahxbr49m8d2hgc6q3siaaf4g0gzfqn</custom-attribute><custom-attribute attribute-id="asdaVouchers">[]</custom-attribute><custom-attribute attribute-id="asda_amend_cutoff_processed">false</custom-attribute><custom-attribute attribute-id="asda_oms_exported">no</custom-attribute><custom-attribute attribute-id="asda_order_retry_count">0</custom-attribute><custom-attribute attribute-id="createdFromBasketID">85fb4e289867510077c1b1f8e2</custom-attribute><custom-attribute attribute-id="ingenicoOgoneIsAuthorized">true</custom-attribute><custom-attribute attribute-id="ingenicoOgoneIsCancellable">true</custom-attribute><custom-attribute attribute-id="ingenicoOgoneIsRefundable">false</custom-attribute><custom-attribute attribute-id="ingenicoOgoneMerchantID">AdamPilackiPublicisDev1</custom-attribute><custom-attribute attribute-id="ingenicoOgoneStatus">PENDING_CAPTURE</custom-attribute><custom-attribute attribute-id="ingenicoOgoneStatusCategory">AUTHORIZED</custom-attribute><custom-attribute attribute-id="ingenicoOgoneStatusCode">5</custom-attribute><custom-attribute attribute-id="ingenicoOgoneTransactionID">3252285590</custom-attribute><custom-attribute attribute-id="isIngenicoOgoneOrder">true</custom-attribute></custom-attributes></order></orders>';
            Map<Id,String> mapXML = new Map<Id,String>();
            mapXML.put(objAsset.Id, strXML);
            Test.startTest();
            
            ASDAC_RenewalScheduler objCallout = new ASDAC_RenewalScheduler();
            System.schedule('Renew','0 0 13 * * ?', objCallout); 
            
            Test.stopTest();
        }
        System.assertNotEquals('', strXML);
    }
    
}