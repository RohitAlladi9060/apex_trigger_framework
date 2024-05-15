/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Classes
 * @group-content ../ApexDocContent/Classes.html
 * @description Used to prevent trigger handler methods from firing more than once
 **/
global class TriggerRegulator {

    public final static String ACCOUNT = 'Account';
    public final static String LEAD = 'Lead';

    //Set the flags for executing trigger.
    private static Boolean afterInsertDone = false;
    private static Boolean afterUpdateDone = false;

    private static final String BEFORE_INSERT_SFX = ' Before Insert';
    private static final String AFTER_INSERT_SFX = ' After Insert';
    private static final String BEFORE_UPDATE_SFX = ' Before Update';
    private static final String AFTER_UPDATE_SFX = ' After Update';

    private static final String BEFORE_DELETE_SFX = ' Before Delete';
    private static final String AFTER_DELETE_SFX = ' After Delete';
    private static final String AFTER_UNDELETE_SFX = ' After UnDelete';

    @TestVisible private static Set<String> inactiveTriggers = new Set<String>();
    @TestVisible private static Map<String, Integer> executedTriggers = new Map<String, Integer>();


    //Add other flags here for the other handler methods

    //After Insert
    public static Boolean hasAlreadyHandledAfterInsert() {
        return afterInsertDone;
    }

    //Deprecated.
    public static void setAlreadyHandledAfterInsert() {
        afterInsertDone = true;
    }

    //After Update
    public static Boolean hasAlreadyHandledAfterUpdate() {
        return afterUpdateDone;
    }

    public static void setAlreadyHandledAfterUpdate() {
        afterUpdateDone = true;
    }

    public static void resetAfterUpdate() {
        afterUpdateDone = false;
    }

    //Use the below flags to deactivate or activate triggers
    public static void deactivateObjectTrigger(String objectName) {
        inactiveTriggers.add(objectName);
    }

    public static void activateObjectTrigger(String objectName) {
        inactiveTriggers.remove(objectName);
    }

    public static void deactivateAllObjectTriggers() {
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values()) {
            String objectName = String.valueOf(sObjectType);
            deactivateObjectTrigger(objectName);
        }
    }

    public static void activateAllObjectTriggers() {
        inactiveTriggers = new Set<String>();
    }

    public static void deactivateAllObjectTriggersExcept(Set<String> objectNames) {
        activateAllObjectTriggers();
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values()) {
            String objectName = String.valueOf(sObjectType);
            if (!objectNames.contains(objectName)) {
                deactivateObjectTrigger(objectName);
            }
        }
    }

    public static void activateAllObjectTriggersExcept(Set<String> objectNames) {
        activateAllObjectTriggers();
        for (String objectName : objectNames) {
            deactivateObjectTrigger(objectName);
        }
    }

    public static Boolean isObjectTriggerActive(String objectName) {
        return !inactiveTriggers.contains(objectName);
    }

    private static void incrementCount(String key) {
        if (executedTriggers.get(key) == null) {
            executedTriggers.put(key, 1);
        } else {
            Integer count = executedTriggers.get(key);
            count++;
            executedTriggers.put(key, count);
        }
    }

    private static Boolean doCheck(String key, Integer maxAllowedTimes) {
        Boolean alreadyRun = true;

        incrementCount(key);

        if (executedTriggers.get(key) <= maxAllowedTimes) {
            alreadyRun = false;
        }

        return alreadyRun;
    }

    public static Integer getBeforeInsertRunCount(String objectName) {
        String key = objectName + BEFORE_INSERT_SFX;
        return executedTriggers.get(key) == null ? 0 : executedTriggers.get(key);
    }

    public static Integer getAfterInsertRunCount(String objectName) {
        String key = objectName + AFTER_INSERT_SFX;
        return executedTriggers.get(key) == null ? 0 : executedTriggers.get(key);
    }

    public static Integer getBeforeUpdateRunCount(String objectName) {
        String key = objectName + BEFORE_UPDATE_SFX;
        return executedTriggers.get(key) == null ? 0 : executedTriggers.get(key);
    }

    public static Integer getAfterUpdateRunCount(String objectName) {
        String key = objectName + AFTER_UPDATE_SFX;
        return executedTriggers.get(key) == null ? 0 : executedTriggers.get(key);
    }

    public static Integer getBeforeDeleteRunCount(String objectName) {
        String key = objectName + BEFORE_DELETE_SFX;
        return executedTriggers.get(key) == null ? 0 : executedTriggers.get(key);
    }

    public static Integer getAfterDeleteRunCount(String objectName) {
        String key = objectName + AFTER_DELETE_SFX;
        return executedTriggers.get(key) == null ? 0 : executedTriggers.get(key);
    }

    public static Boolean beforeInsertHasRun(String objectName, Integer maxAllowedTimes) {
        String key = objectName + BEFORE_INSERT_SFX;
        return doCheck(key, maxAllowedTimes);
    }

    public static Boolean afterInsertHasRun(String objectName, Integer maxAllowedTimes) {
        String key = objectName + AFTER_INSERT_SFX;
        return doCheck(key, maxAllowedTimes);
    }

    public static Boolean beforeUpdateHasRun(String objectName, Integer maxAllowedTimes) {
        String key = objectName + BEFORE_UPDATE_SFX;
        return doCheck(key, maxAllowedTimes);
    }

    public static Boolean afterUpdateHasRun(String objectName, Integer maxAllowedTimes) {
        String key = objectName + AFTER_UPDATE_SFX;
        return doCheck(key, maxAllowedTimes);
    }

    public static Boolean beforeDeleteHasRun(String objectName, Integer maxAllowedTimes) {
        String key = objectName + BEFORE_DELETE_SFX;
        return doCheck(key, maxAllowedTimes);
    }

    public static Boolean afterDeleteHasRun(String objectName, Integer maxAllowedTimes) {
        String key = objectName + AFTER_DELETE_SFX;
        return doCheck(key, maxAllowedTimes);
    }
}