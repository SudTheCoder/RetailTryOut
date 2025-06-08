@IsTest
public with sharing class ASDAC_DisplayDirectoryController_Test {
    @IsTest
    public static void fetchDirectoryContactRecordsTest() {
        Test.StartTest();
        List <ASDAC_FcDsvMappingWithLocationID__mdt> directoryRecords = ASDAC_DisplayDirectoryController.getRecords();
        System.assertEquals(directoryRecords.size()>0, true, 'Records found.');
        Test.StopTest();       
    }

}