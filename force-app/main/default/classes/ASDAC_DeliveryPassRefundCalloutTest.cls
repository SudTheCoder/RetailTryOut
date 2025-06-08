/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-06-21
* @Component Type               : Apex Class
* @component Name               : ASDAC_DeliveryPassRefundCalloutTest
* @description                  : ASDAC-10110
* @Modified By                  : Deepakshi
* @Modified Date		        : 2024-04-10
************************************************************************************/
@isTest
public with sharing class ASDAC_DeliveryPassRefundCalloutTest {
    
    /**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-06-21
* @Method Name                  : testsetup
* @Modified By                  : Deepakshi
* @Modified Date		        : 2024-04-10
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
            
            Id pricebookId = Test.getStandardPricebookId();
            Product2 objProd = new Product2(Name = 'TestProd1',ItemId__c = 'TEST',Description = 'Delivery Pass',NumberOfInstallments__c = 12);
            insert objProd;
            
            Order objOrder = new Order(Name='Test Order 1',AccountId=ObjAccount.Id,EffectiveDate=system.today(),Status='Draft',Pricebook2Id = pricebookId);
            Insert objOrder;
            
            PricebookEntry pe = new PricebookEntry(UnitPrice=123, Product2Id = objProd.Id, Pricebook2Id = pricebookId);
            Insert pe;
            
            OrderItem objOrderProduct = new OrderItem(OrderId = objOrder.Id,PricebookEntryId=pe.Id, UnitPrice=123, TotalLineAmount=123, Quantity=1);
            insert objOrderProduct;
            //Create ContactPointAddress
            ContactPointAddress cpa = new ContactPointAddress(AddressLine1__c ='123',AddressLine2__c='sdf',AddressLine3__c='dfc',City__c='testCity',Country='United Kingdom',CountryCode='GB',Country__c='GB',Name ='123, sdf, dfc, testCity, 201012',PostalCode__c='ABC12');
            insert cpa;
            
            
            //Create Customer Card
            CustomerCard__c cc = new CustomerCard__c(AccountId__c=objAccount.id,AddressId__c = cpa.id,CardToken__c='4e4406aa-da7d-4d6f-bd69-cbbd5a8e6741',ExpiryDate__c ='02/2098',MaskedCardNumber__c='************4675',NameOnCard__c='Niteesh Kumart',CardBrand__c='1');        
            insert cc;
            
            Contact objContact = new Contact();
            objContact.LastName = 'DG Test';
            objContact.AccountId = objAccount.Id;
            
            insert objContact; 
            
            Asset objAsset = new Asset();
            objAsset.Name = 'Test Asset123';
            objAsset.Product2Id = objProd.id;
            objAsset.Recurring_Slot_Frequency__c = 'Daily';
            objAsset.Recurring_Slot_1__c = Datetime.now().addDays(1);
            objAsset.AccountId = objAccount.Id;
            objAsset.ContactId = objContact.Id;
            objAsset.Recurring_Slot_Template_Id__c = '10';
            objAsset.Recurring_Slot_Status__c = '';
            objAsset.Renewal_Payment_Failed_Counter__c = 1;
            objAsset.Renewal_Payment_Status__c = 'Initiated';
            objAsset.Recurring_Slot_Status__c = 'Active';
            objAsset.shopOrderNumber__c = 'MDP123';
            objAsset.PurchaseDate = system.today();
            objAsset.Customer_Card__c = cc.id;
            insert objAsset;
            
        }
    }
    
    /**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-06-21
* @Method Name                  : testInitiateRefund
* @Modified By                  : Deepakshi
* @Modified Date		        : 2024-04-09
**********************************************************************************/
    @IsTest
    static void testInitiateRefund() {
        Asset objAsset = [SELECT Id, Refund_Order_Id__c,Name,Account.PersonContactId FROM Asset where Name = 'Test Asset123' LIMIT 1];
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        ASDAC_DeliveryPassRefundMockTest mockResponse = new ASDAC_DeliveryPassRefundMockTest();
        Test.setMock(HttpCalloutMock.class, mockResponse);
        System.runAs(objUser){
            Test.startTest();
            ASDAC_DeliveryPassRefundCallout.initiateRefund(objAsset.id);
            
            Test.stopTest();
        }
    }   
}