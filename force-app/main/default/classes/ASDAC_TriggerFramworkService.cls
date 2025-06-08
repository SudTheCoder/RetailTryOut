/* *********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is Account Object Trigger Handler Class contains business logic.
********************************************************************************************* */
public virtual class ASDAC_TriggerFramworkService {
  // holds name of the tirgger handler class that needs to be bypassed
  @testvisible
  private static Set<String> bypassedHandlers;
  //map of trigger handler and boolean that tells whether the current handler is already inactive by
  //custom settings
  private static Map<String, Boolean> triggerStatusMap;
  //object name on which the trigger is executed
  public static String triggerObj;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private TriggerContext context;

  // static initialization
  static {
    triggerStatusMap = new Map<String, Boolean>();
    bypassedHandlers = new Set<String>();
  }
  
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is constructor of the class.
**********************************************************************************************/ 
 public ASDAC_TriggerFramworkService() {
    this.setTriggerContext();
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   main method that will be called during execution.
**********************************************************************************************/
  public void run() {
    if(validateRun()) {
      // dispatch to the correct handler method
      System.debug('Inside run()');
      switch on this.context {
        when BEFORE_INSERT {
          this.beforeInsert();
        }
        when BEFORE_UPDATE {
          this.beforeUpdate();
        }
        when BEFORE_DELETE {
          this.beforeDelete();
        }
        when AFTER_INSERT {
          this.afterInsert();
        }
        when AFTER_UPDATE {
          system.debug('after update');
          this.afterUpdate();
        }
        when AFTER_DELETE {
          this.afterDelete();
        }
        when AFTER_UNDELETE {
          this.afterUndelete();
        }
        when else {
		 //default case 
		 System.debug('no event initiated the trigger');
        }
      }
    }

    
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   sets the current trigger context
**********************************************************************************************/
  @TestVisible
  private void setTriggerContext() {
    if((Trigger.isBefore && Trigger.isInsert)) {
      this.context = TriggerContext.BEFORE_INSERT;
    } else if((Trigger.isBefore && Trigger.isUpdate) ){
      this.context = TriggerContext.BEFORE_UPDATE;
    } else if((Trigger.isBefore && Trigger.isDelete)) {
      this.context = TriggerContext.BEFORE_DELETE;
    } else if((Trigger.isAfter && Trigger.isInsert)) {
      this.context = TriggerContext.AFTER_INSERT;
    } else if((Trigger.isAfter && Trigger.isUpdate)) {
      this.context = TriggerContext.AFTER_UPDATE;
    } else if((Trigger.isAfter && Trigger.isDelete)) {
      this.context = TriggerContext.AFTER_DELETE;
    } else if((Trigger.isAfter && Trigger.isUndelete)) {
      this.context = TriggerContext.AFTER_UNDELETE;
    }
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   validates that this trigger should continue to run.
**********************************************************************************************/  
  @TestVisible
  private Boolean validateRun() {
    String handlerName = getHandlerName();
    Boolean triggerEnabled = isTriggerActive(handlerName);
    Boolean triggerBypassed = ASDAC_TriggerFramworkService.isBypassed(handlerName);
    return !triggerBypassed && triggerEnabled;
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         String handler name
@return        void
@description   to validate whether trigger is disabled by custom settings.
**********************************************************************************************/
  @TestVisible
  private Boolean isTriggerActive(String handlerName) {
    Boolean enabledTrigger = false;
    if (triggerStatusMap.containsKey(handlerName)) {
      enabledTrigger = triggerStatusMap.get(handlerName);
    } else {
      enabledTrigger = ASDAC_TriggerSetting__mdt.getInstance(triggerObj).IsActive__c;
      triggerStatusMap.put(handlerName,enabledTrigger);
    }
    return enabledTrigger;    
  }
   
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        String name of the handler
@description   fetches the name of the trigger handler class.
**********************************************************************************************/
  public String getHandlerName() {
    return this.toString().substringBefore(':');
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   used to implement custom logic beforeInsert trigger scenario
**********************************************************************************************/ 
  @TestVisible
  protected virtual void beforeInsert(){}
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   used to implement custom logic beforeUpdate trigger scenario
**********************************************************************************************/ 
  @TestVisible
  protected virtual void beforeUpdate(){}
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   used to implement custom logic beforeDelete trigger scenario
**********************************************************************************************/ 
  @TestVisible
  protected virtual void beforeDelete(){}
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   used to implement custom logic afterInsert trigger scenario
**********************************************************************************************/ 
  @TestVisible
  protected virtual void afterInsert(){}
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   used to implement custom logic afterUpdate trigger scenario
**********************************************************************************************/ 
  @TestVisible
  protected virtual void afterUpdate(){}
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   used to implement custom logic afterDelete trigger scenario
**********************************************************************************************/ 
  @TestVisible
  protected virtual void afterDelete(){}
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   used to implement custom logic afterUndelete trigger scenario
**********************************************************************************************/ 
  @TestVisible
  protected virtual void afterUndelete(){}

  
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         Strin handler name
@return        void
@description   This method is used to bypass a particular trigger
**********************************************************************************************/ 
  public static void bypass(String handlerName) {
    ASDAC_TriggerFramworkService.bypassedHandlers.add(handlerName);
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         Strin handler name
@return        void
@description   This method is used to clear bypass for a particular trigger
**********************************************************************************************/ 
  public static void clearBypass(String handlerName) {
    ASDAC_TriggerFramworkService.bypassedHandlers.remove(handlerName);
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         Strin handler name
@return        void
@description   This method is used to check whether particular trigger is bypassed or not
**********************************************************************************************/ 
  public static Boolean isBypassed(String handlerName) {
    return ASDAC_TriggerFramworkService.bypassedHandlers.contains(handlerName);
  }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method is used to remove bypass for all triggers
**********************************************************************************************/ 
  public static void clearAllBypasses() {
    ASDAC_TriggerFramworkService.bypassedHandlers.clear();
  }

  // possible trigger contexts
  @TestVisible
  private enum TriggerContext {
    BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
    AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
    AFTER_UNDELETE
  }

/* *********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   Exception class for trigger exception case
********************************************************************************************* */
  public class TriggerHandlerException extends Exception {}

}