@isTest
public with sharing class ASDAC_MockInterfaceOverride_Test { 
    @isTest
    static void testPassThrough() {
        List<SObject> mockRecords = createMockAccounts(2); // Dynamically create 2 mock accounts
        ASDAC_MockInterfaceOverride mockInterface = new ASDAC_MockInterfaceOverride(mockRecords);
        List<SObject> result = mockInterface.passThrough(new List<SObject>());
        System.assertEquals(mockRecords, result, 'The passThrough method did not return the expected list of mock records.');
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