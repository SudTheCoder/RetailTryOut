/**********************************************************************************
 * @author                       : Deepakshi Grover
 * @date                         : 2023-05-17
 * @Component Type               : Apex Class
 * @component Name               : ASDAC_HashTokenGeneratorTest
 * @description                  : ASDAC-10298
 * @Modified By                  : Deepakshi
 * @Modified Date		         : 2023-05-23
 **********************************************************************************/
@IsTest
private with sharing class ASDAC_HashTokenGeneratorTest {
    
    
    @IsTest
    static void testDoEECallout() {
        String strRequest = 'sampleRequest';
        String strMethod = 'POST';
        String strURL = '/api/endpoint';
        
        Test.startTest();
        ASDAC_HashTokenGenerator.sendAISRequest(strRequest, strMethod, strURL);
        Test.stopTest();
    }
    
}