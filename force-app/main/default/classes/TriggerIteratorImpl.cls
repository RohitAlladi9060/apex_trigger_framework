/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Classes
 * @group-content ../ApexDocContent/Classes.html
 * @description This class is used to set all the trigger iteration instances, extending the Trigger iterator.
 **/
public with sharing class TriggerIteratorImpl implements TriggerIterator {

    /***** CLASS VARIABLES *****/

    @TestVisible private static final String CONTEXT_BEFORE_INSERT = 'Before Insert';
    @TestVisible private static final String CONTEXT_AFTER_INSERT = 'After Insert';
    @TestVisible private static final String CONTEXT_BEFORE_UPDATE = 'Before Update';
    @TestVisible private static final String CONTEXT_AFTER_UPDATE = 'After Update';
    @TestVisible private static final String CONTEXT_BEFORE_DELETE = 'Before Delete';
    @TestVisible private static final String CONTEXT_AFTER_DELETE = 'After Delete';
    @TestVisible private static final String CONTEXT_AFTER_UNDELETE = 'After Undelete';
    @TestVisible private static final Integer DEFAULT_MAX_ITERATIONS = 2;

    /***** IMPLEMENTATION METHODS *****/

    /**
     * @description Checks if the maximum number of Trigger Iterations has been broken
     **/
    public Boolean hasIterationsRemaining(TriggerHandler triggerHandler) {
        String sObjectApiName = getSObjectApiName();
        String triggerContext = getTriggerContext();

        TriggerFactory.currentTriggerIterations = getCurrentTriggerIterations(TriggerFactory.currentTriggerIterations, sObjectApiName, triggerContext);
        TriggerFactory.setMaxIterations = getsetMaxIterations(TriggerFactory.setMaxIterations, sObjectApiName);

        Boolean transactionLimitExceeded = compareTriggerIterations(
                TriggerFactory.currentTriggerIterations, TriggerFactory.setMaxIterations, sObjectApiName, triggerContext);
        if (!transactionLimitExceeded) {
            TriggerFactory.currentTriggerIterations = updateCurrentTriggerIterations(
                    TriggerFactory.currentTriggerIterations, sObjectApiName, triggerContext);
            return true;
        }
        return false;
    }

    /**
     * @description Adds Trigger Iteration errors to records
     **/
    public void addErrorToRecords(String errorMessage) {
        if (Trigger.new != null) {
            List<SObject> sObjects = Trigger.new;
            addErrors(sObjects, errorMessage);
        } else if (Trigger.old != null) {
            List<SObject> sObjects = Trigger.old;
            addErrors(sObjects, errorMessage);
        }
    }

    /**
     * @description Initially sets the setMaxIterations value on TriggerFactory
     **/
    public TriggerIterationsVO setMaxIterations() {
        List<Trigger_Iteration__mdt> iterationSettings = getTriggerIterationsSettings();

        TriggerIterationsVO setMaxIterationsVO = new TriggerIterationsVO();

        if (!iterationSettings.isEmpty()) {
            for (Trigger_Iteration__mdt iterationSetting : iterationSettings) {
                setMaxIterationsVO.sObjectApiNames.add(iterationSetting.MasterLabel);
                setMaxIterationsVO.beforeInsertIterations.put(iterationSetting.MasterLabel, (Integer) iterationSetting.Before_Insert_Max__c);
                setMaxIterationsVO.afterInsertIterations.put(iterationSetting.MasterLabel, (Integer) iterationSetting.After_Insert_Max__c);
                setMaxIterationsVO.beforeUpdateIterations.put(iterationSetting.MasterLabel, (Integer) iterationSetting.Before_Update_Max__c);
                setMaxIterationsVO.afterUpdateIterations.put(iterationSetting.MasterLabel, (Integer) iterationSetting.After_Update_Max__c);
                setMaxIterationsVO.beforeDeleteIterations.put(iterationSetting.MasterLabel, (Integer) iterationSetting.Before_Delete_Max__c);
                setMaxIterationsVO.afterDeleteIterations.put(iterationSetting.MasterLabel, (Integer) iterationSetting.After_Delete_Max__c);
                setMaxIterationsVO.afterUnDeleteIterations.put(iterationSetting.MasterLabel, (Integer) iterationSetting.After_Undelete_Max__c);
            }
            return setMaxIterationsVO;
        }
        return null;
    }

    /**
     * @description Returns a list of Trigger_Iteration metadata records
     **/
    public List<Trigger_Iteration__mdt> getTriggerIterationsSettings() {
        return [
                SELECT Id, MasterLabel, DeveloperName, IsActive__c, Before_Insert_Max__c,
                        After_Insert_Max__c, Before_Update_Max__c, After_Update_Max__c, Before_Delete_Max__c,
                        After_Delete_Max__c, After_Undelete_Max__c
                FROM Trigger_Iteration__mdt
                ORDER BY MasterLabel ASC
        ];
    }

    public String getSObjectApiName() {
        if (Trigger.new != null) {
            List<SObject> newSObjects = Trigger.new;
            return newSObjects[0].getSObjectType().getDescribe().getName();
        } else {
            List<SObject> oldSObjects = Trigger.old;
            return oldSObjects[0].getSObjectType().getDescribe().getName();
        }
    }

    /***** HELPER METHODS *****/

    @TestVisible
    private String getTriggerContext() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                return CONTEXT_BEFORE_INSERT;
            } else if (Trigger.isUpdate) {
                return CONTEXT_BEFORE_UPDATE;
            } else if (Trigger.isDelete) {
                return CONTEXT_BEFORE_DELETE;
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                return CONTEXT_AFTER_INSERT;
            } else if (Trigger.isUpdate) {
                return CONTEXT_AFTER_UPDATE;
            } else if (Trigger.isDelete) {
                return CONTEXT_AFTER_DELETE;
            } else if (Trigger.isUnDelete) {
                return CONTEXT_AFTER_UNDELETE;
            }
        }
        return null;
    }

    public TriggerIterationsVO getCurrentTriggerIterations(TriggerIterationsVO currentTriggerIterations, String sObjectApiName, String triggerContext) {
        TriggerIterationsVO tempCurrentTriggerIterationsVO = currentTriggerIterations;
        if (tempCurrentTriggerIterationsVO != null) {
            return setStartIterations(currentTriggerIterations, sObjectApiName, triggerContext);
        } else if (tempCurrentTriggerIterationsVO == null) {
            tempCurrentTriggerIterationsVO = new TriggerIterationsVO(sObjectApiName);
            return tempCurrentTriggerIterationsVO;
        } else if (!tempCurrentTriggerIterationsVO.sObjectApiNames.contains(sObjectApiName)) {
            return addSObjectToTriggerIterationsVO(tempCurrentTriggerIterationsVO, sObjectApiName, 0);
        } else {
            return tempCurrentTriggerIterationsVO;
        }
    }

    public TriggerIterationsVO setStartIterations(TriggerIterationsVO currentTriggerIterationsVO, String sObjectApiName, String triggerContext) {
        Integer defaultIterations = 0;
        if (triggerContext == CONTEXT_BEFORE_INSERT
                && currentTriggerIterationsVO.beforeInsertIterations.get(sObjectApiName) == null) {
             currentTriggerIterationsVO.beforeInsertIterations.put(sObjectApiName, defaultIterations);
        } else if (triggerContext == CONTEXT_BEFORE_UPDATE
                && currentTriggerIterationsVO.beforeUpdateIterations.get(sObjectApiName) == null) {
             currentTriggerIterationsVO.beforeUpdateIterations.put(sObjectApiName, defaultIterations);
        } else if (triggerContext == CONTEXT_BEFORE_DELETE
                && currentTriggerIterationsVO.beforeDeleteIterations.get(sObjectApiName) == null) {
             currentTriggerIterationsVO.beforeDeleteIterations.put(sObjectApiName, defaultIterations);
        } else if (triggerContext == CONTEXT_AFTER_INSERT
                && currentTriggerIterationsVO.afterInsertIterations.get(sObjectApiName) == null) {
             currentTriggerIterationsVO.afterInsertIterations.put(sObjectApiName, defaultIterations);
        } else if (triggerContext == CONTEXT_AFTER_UPDATE
                && currentTriggerIterationsVO.afterUpdateIterations.get(sObjectApiName) == null) {
             currentTriggerIterationsVO.afterUpdateIterations.put(sObjectApiName, defaultIterations);
        } else if (triggerContext == CONTEXT_AFTER_DELETE
                && currentTriggerIterationsVO.afterDeleteIterations.get(sObjectApiName) == null) {
             currentTriggerIterationsVO.afterDeleteIterations.put(sObjectApiName, defaultIterations);
        } else if (triggerContext == CONTEXT_AFTER_UNDELETE
                && currentTriggerIterationsVO.afterUnDeleteIterations.get(sObjectApiName) == null) {
             currentTriggerIterationsVO.afterUnDeleteIterations.put(sObjectApiName, defaultIterations);
        } else {
            return currentTriggerIterationsVO;
        }
        return currentTriggerIterationsVO;
    }

    public TriggerIterationsVO getSetMaxIterations(TriggerIterationsVO setMaxIterations, String sObjectApiName) {
        TriggerIterationsVO tempsetMaxIterationsVO = setMaxIterations;
        if (tempsetMaxIterationsVO == null) {
            if (TriggerFactory.testsetMaxIterations == null) {
                tempsetMaxIterationsVO = new TriggerIterationsVO(sObjectApiName, DEFAULT_MAX_ITERATIONS);
            } else {
                tempsetMaxIterationsVO = new TriggerIterationsVO(sObjectApiName, TriggerFactory.testsetMaxIterations);
            }
            return tempsetMaxIterationsVO;
        } else if (!tempsetMaxIterationsVO.sObjectApiNames.contains(sObjectApiName)) {
            if (TriggerFactory.testsetMaxIterations == null) {
                return addSObjectToTriggerIterationsVO(tempsetMaxIterationsVO, sObjectApiName, DEFAULT_MAX_ITERATIONS);
            }
            return addSObjectToTriggerIterationsVO(tempsetMaxIterationsVO, sObjectApiName, TriggerFactory.testsetMaxIterations);
        }else {
            return tempsetMaxIterationsVO;
        }
    }

    @TestVisible
    private TriggerIterationsVO addSObjectToTriggerIterationsVO(TriggerIterationsVO triggerIterationsVO, String sObjectApiName, Integer iterations) {
        TriggerIterationsVO tempTriggerIterationsVO = triggerIterationsVO == null ? new TriggerIterationsVO() : triggerIterationsVO;

        tempTriggerIterationsVO.sObjectApiNames.add(sObjectApiName);
        tempTriggerIterationsVO.beforeInsertIterations.put(sObjectApiName, iterations);
        tempTriggerIterationsVO.afterInsertIterations.put(sObjectApiName, iterations);
        tempTriggerIterationsVO.beforeUpdateIterations.put(sObjectApiName, iterations);
        tempTriggerIterationsVO.afterUpdateIterations.put(sObjectApiName, iterations);
        tempTriggerIterationsVO.beforeDeleteIterations.put(sObjectApiName, iterations);
        tempTriggerIterationsVO.afterInsertIterations.put(sObjectApiName, iterations);
        tempTriggerIterationsVO.afterUnDeleteIterations.put(sObjectApiName, iterations);

        return tempTriggerIterationsVO;
    }

    public Boolean compareTriggerIterations(TriggerIterationsVO currentTriggerIterationsVO, TriggerIterationsVO setMaxIterationsVO, String sObjectApiName, String triggerContext) {
        if (triggerContext == CONTEXT_BEFORE_INSERT
                && currentTriggerIterationsVO.beforeInsertIterations.get(sObjectApiName) < setMaxIterationsVO.beforeInsertIterations.get(sObjectApiName)) {
            return false;
        } else if (triggerContext == CONTEXT_BEFORE_UPDATE
                && currentTriggerIterationsVO.beforeUpdateIterations.get(sObjectApiName) < setMaxIterationsVO.beforeUpdateIterations.get(sObjectApiName)) {
            return false;
        } else if (triggerContext == CONTEXT_BEFORE_DELETE
                && currentTriggerIterationsVO.beforeDeleteIterations.get(sObjectApiName) < setMaxIterationsVO.beforeDeleteIterations.get(sObjectApiName)) {
            return false;
        } else if (triggerContext == CONTEXT_AFTER_INSERT
                && currentTriggerIterationsVO.afterInsertIterations.get(sObjectApiName) < setMaxIterationsVO.afterInsertIterations.get(sObjectApiName)) {
            return false;
        } else if (triggerContext == CONTEXT_AFTER_UPDATE
                && currentTriggerIterationsVO.afterUpdateIterations.get(sObjectApiName) < setMaxIterationsVO.afterUpdateIterations.get(sObjectApiName)) {
            return false;
        } else if (triggerContext == CONTEXT_AFTER_DELETE
                && currentTriggerIterationsVO.afterDeleteIterations.get(sObjectApiName) < setMaxIterationsVO.afterDeleteIterations.get(sObjectApiName)) {
            return false;
        } else if (triggerContext == CONTEXT_AFTER_UNDELETE
                && currentTriggerIterationsVO.afterUnDeleteIterations.get(sObjectApiName) < setMaxIterationsVO.afterUnDeleteIterations.get(sObjectApiName)) {
            return false;
        }
        return true;
    }

    public TriggerIterationsVO updateCurrentTriggerIterations(TriggerIterationsVO currentTriggerIterationsVO, String sObjectApiName, String triggerContext) {
        TriggerIterationsVO tempCurrentTriggerIterationsVO = currentTriggerIterationsVO;

        if (triggerContext == CONTEXT_BEFORE_INSERT) {
            Integer currentIterations = tempCurrentTriggerIterationsVO.beforeInsertIterations.get(sObjectApiName);
            currentIterations++;
            tempCurrentTriggerIterationsVO.beforeInsertIterations.put(sObjectApiName, currentIterations);
        } else if (triggerContext == CONTEXT_BEFORE_UPDATE) {
            Integer currentIterations = tempCurrentTriggerIterationsVO.beforeUpdateIterations.get(sObjectApiName);
            currentIterations++;
            tempCurrentTriggerIterationsVO.beforeUpdateIterations.put(sObjectApiName, currentIterations);
        } else if (triggerContext == CONTEXT_BEFORE_DELETE) {
            Integer currentIterations = tempCurrentTriggerIterationsVO.beforeDeleteIterations.get(sObjectApiName);
            currentIterations++;
            tempCurrentTriggerIterationsVO.beforeDeleteIterations.put(sObjectApiName, currentIterations);
        } else if (triggerContext == CONTEXT_AFTER_INSERT) {
            Integer currentIterations = tempCurrentTriggerIterationsVO.afterInsertIterations.get(sObjectApiName);
            currentIterations++;
            tempCurrentTriggerIterationsVO.afterInsertIterations.put(sObjectApiName, currentIterations);
        } else if (triggerContext == CONTEXT_AFTER_UPDATE) {
            Integer currentIterations = tempCurrentTriggerIterationsVO.afterUpdateIterations.get(sObjectApiName);
            currentIterations++;
            tempCurrentTriggerIterationsVO.afterUpdateIterations.put(sObjectApiName, currentIterations);
        } else if (triggerContext == CONTEXT_AFTER_DELETE) {
            Integer currentIterations = tempCurrentTriggerIterationsVO.afterDeleteIterations.get(sObjectApiName);
            currentIterations++;
            tempCurrentTriggerIterationsVO.afterDeleteIterations.put(sObjectApiName, currentIterations);
        } else if (triggerContext == CONTEXT_AFTER_UNDELETE) {
            Integer currentIterations = tempCurrentTriggerIterationsVO.afterUnDeleteIterations.get(sObjectApiName);
            currentIterations++;
            tempCurrentTriggerIterationsVO.afterUnDeleteIterations.put(sObjectApiName, currentIterations);
        }

        return tempCurrentTriggerIterationsVO;
    }

    @TestVisible
    private static void addErrors(List<SObject> sObjects, String errorMessage) {
        for (SObject record : sObjects) {
            record.addError(errorMessage);
        }
    }

    public Boolean getTriggerStatus() {
        String sObjectAPIName = getSObjectApiName();
        List<Trigger_Iteration__mdt> triggerIterations = [
                SELECT id,MasterLabel,DeveloperName,IsActive__c
                FROM Trigger_Iteration__mdt
                WHERE MasterLabel = :sObjectAPIName
                LIMIT 1
        ];
        return triggerIterations.isEmpty() ? true : triggerIterations[0].isActive__c;
    }
}