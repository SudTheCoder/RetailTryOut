@isTest
private with sharing class ASDAC_StandardLetterCmpTest {
    @isTest
    static void testRetrieveLatestComment() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Assigned'
        );
        insert testCase;       
        ApexPages.StandardController controller = new ApexPages.StandardController(testCase);
        ASDAC_StandardLetterCmp cmp = new ASDAC_StandardLetterCmp(controller);
        System.assertEquals(null, cmp.latestComment);
        CaseComment testComment = new CaseComment(
            ParentId = testCase.Id,
            CommentBody = 'Test comment'
        );
        insert testComment;
        cmp.latestComment = cmp.retrieveLatestComment();
        System.assertNotEquals(null, cmp.latestComment);
    }
    
    @isTest
    static void testGeneratePdf() {
        Case c = new Case(Subject='Test Case', Status='Assigned');
        insert c;
        CaseComment cc = new CaseComment(ParentId=c.Id, CommentBody='Test Comment');
        insert cc;
        List<String> pageStrings = ASDAC_StandardLetterCmp.generatePdf(c.Id,'Standard Letter');
        System.assertNotEquals(0, pageStrings.size());
    }

   
}