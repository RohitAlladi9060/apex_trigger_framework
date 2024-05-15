/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group - Classes
 * @description Factory for creating trigger handler instance
 **/
public class TriggerFactory {

    public static TriggerIterator triggerIterator {
        get {
            if (triggerIterator == null) {
                triggerIterator = new TriggerIteratorImpl();
            }
            return triggerIterator;
        }
        set;
    }

    public static Boolean testOverride {
        get {
            if (testOverride == null) {
                testOverride = false;
            }
            return testOverride;
        }
        set;
    }

    public static TriggerIterationsVO currentTriggerIterations { get; set; }

    public static TriggerIterationsVO setMaxIterations {
        get {
            if (setMaxIterations == null && testOverride == false) {
                setMaxIterations = triggerIterator.setMaxIterations();
            }
            return setMaxIterations;
        }
        set;
    }

    public static Integer testSetMaxIterations {
        get {
            if (Test.isRunningTest() && testSetMaxIterations == null) {
                testSetMaxIterations = 20;
            }
            return testSetMaxIterations;
        }
        set;
    }

    // Exception used for when handlerName is not a proper class name
    //  or class is not an instance of TriggerHanlder
    public class HandlerException extends Exception {
    }

    // Creates and Executes the TriggerHandler
    public static void createAndExecuteHandler(String handlerName) {
        TriggerHandler handler = create(handlerName);
        execute(handler);
    }

    // Creates a TriggerHandler based off the handlerName that is passed in
    public static TriggerHandler create(String handlerName) {
        System.Type classType = Type.forName(handlerName);
        // Need to check to see if it is a valid class or not
        if (classType == null) {
            throw new HandlerException('Not a valid class name for ' + handlerName);
        }

        Object handler = classType.newInstance();

        if (!(handler instanceOf TriggerHandler)) {
            throw new HandlerException('Not a valid instance of Trigger Handler for class name ' + handlerName);
        }

        return (TriggerHandler) handler;

    }

    public static String getTriggerHandlerName(TriggerHandler handler) {
        String handlerStr = String.valueOf(handler);
        return handlerStr.left(handlerStr.indexOf(':'));
    }

    // Call the various DML operations in the trigger context
    public static void execute(TriggerHandler handler) {
        String sObjectAPIName = triggerIterator.getSObjectApiName();
        Boolean isTriggerActive = [SELECT IsActive__c FROM Trigger_iteration__mdt WHERE label=:sObjectAPIName LIMIT 1].IsActive__c;   
        if (!triggerIterator.getTriggerStatus()) {
            return;
        }
        if(!isTriggerActive){
            triggerIterator.addErrorToRecords('Trigger is inactive for: ' + sObjectAPIName);
        }
        // Handles before DML operations Insert, Update, Delete, and Undelete
        try {
            if (triggerIterator.hasIterationsRemaining(handler)) {
                if (Trigger.isBefore) {
                    if (Trigger.isInsert) {
                        tryBeforeInsert(handler, Trigger.new);
                    } else if (Trigger.isUpdate) {
                        tryBeforeUpdate(handler, Trigger.newMap, Trigger.oldMap);
                    } else if (Trigger.isDelete) {
                        tryBeforeDelete(handler, Trigger.oldMap);
                    }
                } else if (Trigger.isAfter) {
                    if (Trigger.isInsert) {
                        tryAfterInsert(handler, Trigger.newMap);
                    } else if (Trigger.isUpdate) {
                        tryAfterUpdate(handler, Trigger.newMap, Trigger.oldMap);
                    } else if (Trigger.isDelete) {
                        tryAfterDelete(handler, Trigger.oldMap);
                    } else if (Trigger.isUnDelete) {
                        tryAfterUndelete(handler, Trigger.newMap);
                    }
                }
            } else {
                ExceptionHelper helper = new ExceptionHelperImpl();
                triggerIterator.addErrorToRecords('Number of Trigger Iterations was exceeded for: ' + sObjectAPIName);
                helper.throwFriendlyException(new TriggerIterationsException('Number of Trigger Iterations was exceeded for: ' + sObjectAPIName));
            }
        } catch (Exception exc) {
            triggerIterator.addErrorToRecords(exc.getMessage());
            ExceptionHelper helper = new ExceptionHelperImpl();
            helper.throwFriendlyException(exc);
        }
    }

    @TestVisible
    private static String tryBeforeInsert(TriggerHandler handler, List<SObject> newSObjects) {
        String retVal = TRF_Constants.BLANK;
        try {
            handler.beforeInsert(newSObjects);
            String handlerName = getTriggerHandlerName(handler);
            TriggerMonitor trigMon = TriggerMonitor.getInstance();
            trigMon.beforeInsert(handlerName);
        } catch (Exception exc) {
            retVal = addErrorToRecord(newSObjects[0], exc);
        }
        return retVal;
    }

    @TestVisible
    private static String tryBeforeUpdate(TriggerHandler handler, Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        String retVal = TRF_Constants.BLANK;
        try {
            handler.beforeUpdate(newMap, oldMap);
            String handlerName = getTriggerHandlerName(handler);
            TriggerMonitor trigMon = TriggerMonitor.getInstance();
            trigMon.beforeInsert(handlerName);
        } catch (Exception exc) {
            retVal = addErrorToRecord(newMap.values()[0], exc);
        }
        return retVal;
    }

    @TestVisible
    private static String tryAfterInsert(TriggerHandler handler, Map<Id, SObject> newMap) {
        String retVal = TRF_Constants.BLANK;
        try {
            handler.afterInsert(newMap);
            String handlerName = getTriggerHandlerName(handler);
            TriggerMonitor trigMon = TriggerMonitor.getInstance();
            trigMon.afterInsert(handlerName);
        } catch (Exception exc) {
            retVal = addErrorToRecord(newMap.values()[0], exc);
        }
        return retVal;
    }

    @TestVisible
    private static String tryAfterUpdate(TriggerHandler handler, Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        String retVal = TRF_Constants.BLANK;
        try {
            handler.afterUpdate(newMap, oldMap);
            String handlerName = getTriggerHandlerName(handler);
            TriggerMonitor trigMon = TriggerMonitor.getInstance();
            trigMon.afterInsert(handlerName);
        } catch (Exception exc) {
            retVal = addErrorToRecord(newMap.values()[0], exc);
        }
        return retVal;
    }

    @TestVisible
    private static String tryBeforeDelete(TriggerHandler handler, Map<Id, SObject> oldMap) {
        String retVal = TRF_Constants.BLANK;
        try {
            handler.beforeDelete(oldMap);
            String handlerName = getTriggerHandlerName(handler);
            TriggerMonitor trigMon = TriggerMonitor.getInstance();
            trigMon.beforeDelete(handlerName);
        } catch (Exception exc) {
            retVal = addErrorToRecord(oldMap.values()[0], exc);
        }
        return retVal;
    }

    @TestVisible
    private static String tryAfterDelete(TriggerHandler handler, Map<Id, SObject> oldMap) {
        String retVal = TRF_Constants.BLANK;
        try {
            handler.afterDelete(oldMap);
            String handlerName = getTriggerHandlerName(handler);
            TriggerMonitor trigMon = TriggerMonitor.getInstance();
            trigMon.afterDelete(handlerName);
        } catch (Exception exc) {
            retVal = addErrorToRecord(oldMap.values()[0], exc);
        }
        return retVal;
    }

    @TestVisible
    private static String tryAfterUndelete(TriggerHandler handler, Map<Id, SObject> newMap) {
        String retVal = TRF_Constants.BLANK;
        try {
            handler.afterUndelete(newMap);
            String handlerName = getTriggerHandlerName(handler);
            TriggerMonitor trigMon = TriggerMonitor.getInstance();
            trigMon.afterUndelete(handlerName);
        } catch (Exception exc) {
            retVal = addErrorToRecord(newMap.values()[0], exc);
        }
        return retVal;
    }

    private static String addErrorToRecord(SObject record, Exception exc) {
        //throw exc;
        ExceptionHelper helper = new ExceptionHelperImpl();
        return helper.addFriendlyError(exc, record);
    }
}