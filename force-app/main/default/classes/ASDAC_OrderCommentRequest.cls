public class ASDAC_OrderCommentRequest {
    public String comment;
    public String commentedBy;
    public String commentType;
    public ASDAC_OrderCommentRequest(){
        if(Test.isRunningTest()){
            comment = 'Test';
        }
    }
}