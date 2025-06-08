public class ASDAC_MockInterfaceOverride extends ASDAC_MockInterface{
    final List<SObject> objectList;

    public ASDAC_MockInterfaceOverride(List<SObject> mockRecords){
        this.objectList = mockRecords;
    }

    public override List<SObject> passThrough(List<SObject> records){
        return objectList;
    }
}