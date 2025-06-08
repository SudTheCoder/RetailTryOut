/**********************************************************************************************
@author         Dependra Singh
@date           11 May 2022
@description:   This TriggerHandlerBase Class needs to be implemented by handler class
@revisions:     
**********************************************************************************************/
public virtual class ASDAC_TriggerHandlerBase{
    
    public class NotImplementedException extends Exception{}
    
    /**********************************************************************************************

    @param          ASDAC_TriggerHandlerObj inputParam
    @return         void
    @description    This method is the code that fires initially for a trigger
    **********************************************************************************************/

    public virtual void mainEntry(ASDAC_TriggerHandlerObj inputParam){        
        throw new NotImplementedException('Error Not Implemented');
    }
            
    /**********************************************************************************************
    @author        
    @param          CARE_TriggerHandlerObj inputParam
    @return         void
    @description    This method will fire if a trigger is already running. It has a default
                    implementation that will just run the handler of the respective object
                    if it is not overwitten
    **********************************************************************************************/
    public virtual void inProgressEntry(ASDAC_TriggerHandlerObj inputParam){  
        //By default just call the main entry of the invoking classes controller object 
        String typeName = ASDAC_GlobalConstants.PREFIX + inputParam.triggerObject + ASDAC_GlobalConstants.HANDLERSUFFIX;
        Type t = Type.forName(typeName);
        ASDAC_TriggerHandlerBase activeFunction = (ASDAC_TriggerHandlerBase)t.newInstance();            
        
        //Update the dispatcher active function so that it references the new object
        ASDAC_TriggerCentralDispatcher.activeFunction = activeFunction;
    
        activeFunction.MainEntry(inputParam);
            
        //Reset the active function so that it points to the current class
        ASDAC_TriggerCentralDispatcher.activeFunction = this;
    }
}