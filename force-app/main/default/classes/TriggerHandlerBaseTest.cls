/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Test Classes
 * @group-content ../ApexDocContent/TestClasses.html
 * @description TriggerHandlerBase is a virtual class for overriding standard TriggerHandlers.
 *   Writing test coverage for this class incase all of the methods are overriding with every handler
 *   0 asserts due to nothing happens in these methods at this level
 **/
@IsTest
private class TriggerHandlerBaseTest {

    static TestMethod void callEveryMethodTest(){
        TriggerHandlerBase triggerHandler = new TriggerHandlerBase();
        triggerHandler.beforeInsert(null);
        triggerHandler.afterInsert(null);
        triggerHandler.beforeUpdate(null, null);
        triggerHandler.afterUpdate(null, null);
        triggerHandler.beforeDelete(null);
        triggerHandler.afterDelete(null);
        triggerHandler.afterUnDelete(null);

    }
}