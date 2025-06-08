@isTest
public with sharing class ASDAC_ObjectManager_Test {
    @isTest
    static void testRecords() {
        List<SObject> mockRecords = createMockAccounts(2); // Dynamically create 2 mock accounts
		ASDAC_MockInterface mock = new ASDAC_MockInterface();
		ASDAC_ObjectManager.setMock(mock);
        List<SObject> result = ASDAC_ObjectManager.records(mockRecords);
        System.assertEquals(mockRecords, result, 'The records method did not return the expected list of records.');
    }

    @isTest
    static void testSetMock() {
        ASDAC_MockInterface mock = new ASDAC_MockInterface();
        ASDAC_ObjectManager.setMock(mock);
        System.assertEquals(mock, ASDAC_ObjectManager.mockInstance, 'The setMock method did not set the mock instance correctly.');
    }
    
    // Method to create a list of mock Account records
    static List<SObject> createMockAccounts(Integer count) {
        List<SObject> accounts = new List<SObject>();
        for (Integer i = 1; i <= count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        return accounts;
    }
}