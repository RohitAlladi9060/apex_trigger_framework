/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group  Interfaces
 * @description Should be implemented by all trigger handler classes
 **/
public interface TriggerHandler {
    // Insert Operations
    void beforeInsert( List<sObject> newSObjects );
    void afterInsert( Map<Id,sObject> newSObjects );

    // Update Operations
    void beforeUpdate( Map<Id,sObject> newSObjects, Map<Id,sObject> oldSObjects );
    void afterUpdate( Map<Id,sObject> newSObjects, Map<Id,sObject> oldSObjects );

    // Delete Operations
    void beforeDelete( Map<Id,sObject> oldSObjects );
    void afterDelete(  Map<Id,sObject> oldSObjects );

    // UnDelete Operations
    void afterUnDelete( Map<Id,sObject> newSObjects );
}