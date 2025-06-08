public class ASDAC_ObjectManager {
    @TestVisible
    static ASDAC_MockInterface mockInstance = new ASDAC_MockInterface();
    @TestVisible
    public static List<sObject> records(List<sObject> records){
        return mockInstance.passThrough(records);   
    }
    
    @TestVisible
    static void setMock(ASDAC_MockInterface mock){
        mockInstance = mock;
    }
}