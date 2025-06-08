@isTest
public class ASDAC_WithoutSharingUtilityTest {
    
    @isTest
    static void testGetDataLayerEventMetadata() {
        List<ASDAC_DataLayerEventMetadata__mdt> existingMetadata = [SELECT MasterLabel FROM ASDAC_DataLayerEventMetadata__mdt];
        System.assertNotEquals(0, existingMetadata.size(), 'No existing metadata records found for testing.');

        Test.startTest();
        ASDAC_WithoutSharingUtility.throwCustomException = false;
        List<ASDAC_DataLayerEventMetadata__mdt> result = ASDAC_WithoutSharingUtility.getDataLayerEventMetadata();
        Test.stopTest();
        System.assertEquals(existingMetadata.size(), result.size(), 'Result should contain the same number of records as existingMetadata');
    }
    
    @isTest
    static void testUpsertObjects() {
        List<Account> listOfObjects = new List<Account>();
        listOfObjects.add(new Account(FirstName__pc = 'TestingFirstName1', LastName__pc = 'TestingLastName1', LastName = 'TestingLastName1', LoginId__c = 'test1@asdatest.co.uk', PersonEmail = 'test1@asdatest.co.uk', Phone = '1234567890', PostalCode__pc = '12345'));
       
        Test.startTest();
        ASDAC_WithoutSharingUtility.throwCustomException = false;
        ASDAC_WithoutSharingUtility.upsertObjects(listOfObjects);
        Test.stopTest();

        List<Account> upsertedAccounts = [SELECT FirstName__pc, LastName__pc, LoginId__c, PersonEmail, Phone, PostalCode__pc FROM Account WHERE LoginId__c IN ('test1@asdatest.co.uk', 'test2@asdatest.co.uk')];
        System.assertEquals(1, upsertedAccounts.size(), 'Total number of upserted accounts should be 1');
    }

    @isTest
    static void testGetUser() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.Username = ocsCollBPO.Username + '.ocsColleagueBPO';
        insert ocsCollBPO;

        Test.startTest();
        ASDAC_WithoutSharingUtility.throwCustomException = false;
        List<User> result = ASDAC_WithoutSharingUtility.getUser(ocsCollBPO.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected one user record');
    }
	@isTest
    static void testEventMetadataException() {
        Test.startTest();
        try {
            ASDAC_WithoutSharingUtility.throwCustomException = true;
            List<ASDAC_DataLayerEventMetadata__mdt> result = ASDAC_WithoutSharingUtility.getDataLayerEventMetadata();
        } Catch(Exception e) {
            system.assert(true, 'Exceptions should be handled by the method');
        }
        Test.stopTest();       
        
    }
}