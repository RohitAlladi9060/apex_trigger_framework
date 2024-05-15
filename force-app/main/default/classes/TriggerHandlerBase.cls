/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group - Classes
 * @description Trigger handler parent. Virtual class for implementing the interface for standard triggers.
 * Gives you the ability to override only the methods you are using.
 */
public virtual class TriggerHandlerBase implements TriggerHandler {

    // Insert Operations
    public virtual void beforeInsert( List<sObject> newSObjects ) {
    	//Empty intentionally
    }
    public virtual void afterInsert( Map<Id,sObject> newSObjects ) {
    	//Empty intentionally
    }

    // Update Operations
    public virtual void beforeUpdate( Map<Id,sObject> newSObjects, Map<Id,sObject> oldSObjects ) {
    	//Empty intentionally
    }
    public virtual void afterUpdate( Map<Id,sObject> newSObjects, Map<Id,sObject> oldSObjects ) {
    	//Empty intentionally
    }

    // Delete Operations
    public virtual void beforeDelete( Map<Id,sObject> oldSObjects ) {
        //Empty intentionally
    }
    public virtual void afterDelete( Map<Id,sObject> oldSObjects ) {
        //Empty intentionally
    }

    // UnDelete Operations
    public virtual void afterUnDelete( Map<Id,sObject> newSObjects ) {
        //Empty intentionally
    }
    
    /* @description Prepares and returns the Map of Objects changed filtered by specific field name
     * @fieldName FieldName for filtering the changed objects
     * @newSObjects Map of new SObjects on which Trigger is executed
     * @oldSObjects Map of old SObjects on which Trigger is executed
     * @return Map<Id, sObject> Map of objects changed with respect to the fieldName provided
     **/
    public Map<Id, sObject> getObjectsChangedOnField(final String fieldName,final Map<Id,sObject> newSObjects,final Map<Id,sObject> oldSObjects)	{
    	Map<Id,sObject> changedObjectsMap = new Map<Id,sObject>();
    	for(Id key : newSObjects.keySet())	{
    		SObject oldObject = oldSObjects.get(key);
    		SObject newObject = newSObjects.get(key);
    		if(oldObject.get(fieldName) != newObject.get(fieldName)) {
    			changedObjectsMap.put(key,newObject);
    		}
    	}
    	return changedObjectsMap;
    }
}