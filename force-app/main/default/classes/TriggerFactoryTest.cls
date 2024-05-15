/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Test Classes
 * @description Test class for TriggerFactory
 **/
@isTest
private class TriggerFactoryTest {

	/**
     * Method Tested: createAndExecuteHandler
     * | Scenario: Called with invalid handler name
     * | Expected Result: Exception is thrown
     **/
    static TestMethod void createAndExecuteHandler_CalledWithInvalidHandlerName_ExceptionThrown() {
        // Arrange
        Boolean exceptionThrown = false;

        // Act
        try {
            TriggerFactory.createAndExecuteHandler('InvalidTriggerHandler');
        } catch (TriggerFactory.HandlerException e) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown, 'TriggerFactory.HandlerException should have been thrown');
    }

}