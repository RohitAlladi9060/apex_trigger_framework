/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Exception Helper Test Classes
 * @group-content ../ApexDocContent/TestClasses.html
 * @description Unit test class for ExceptionHelperImpl
 **/
@IsTest
private class ExceptionHelperImplTest {

    // Set up Marketer
    private static User setupTestUser(){
        User testUser = EXH_TestDataUtility.createUser('Read Only');
        insert testUser;
        return testUser;
    }

    // Set up System Admin
    private static User setupSystemAdminUser(){
        User sysAdmin = EXH_TestDataUtility.createUser('System Administrator');
        insert sysAdmin;
        return sysAdmin;
    }

    /**
     * Method Tested: addFriendlyError
     * | Scenario: Called
     * | Expected Result: Error added with user-friendly message.
     **/
    static testmethod void addFriendlyError_Called_ErrorAddedWithUserFriendlyMessage() {

        List<SObject> newSObjects = new List<SObject> {new Account()};

        ExceptionHelper helper = new ExceptionHelperImpl();

        String errorMsg;

        Test.startTest();
        System.runAs(setupTestUser()) {
            errorMsg = helper.addFriendlyError(new ExceptionHelperException('Ugly error message.'), newSObjects[0]);
        }
        Test.stopTest();

        System.assertEquals(EXH_Constants.DFLT_FRIENDLY_ERR_MSG, errorMsg, 'Expected friendly error message.');
    }

    /**
     * Method Tested: addFriendlyError
     * | Scenario: Error message indicates validation error
     * | Expected Result: Validation error is added in a user-friendly format
     **/
    static testMethod void addFriendlyError_ErrorMessageIndicatesValidationException_FriendlyValidationErrorAdded() {

        final String VALIDATION_ERROR_MSG = 'Update failed. First exception on row 0 with id a02m0000007u6ywAAA;' +
                ' first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, This error should appear, not oops!: []';

        List<SObject> newSObjects = new List<SObject> {new Account()};

        ExceptionHelper helper = new ExceptionHelperImpl();

        String errorMsg;

        Test.startTest();
        System.runAs(setupTestUser()) {
            errorMsg = helper.addFriendlyError(new ExceptionHelperException(VALIDATION_ERROR_MSG), newSObjects[0]);
        }
        Test.stopTest();

        System.assertEquals('This error should appear, not oops!', errorMsg, 'Expected friendly validation message.');
    }

    /**
     * Method Tested: addFriendlyError
     * | Scenario: Funky end characters (": []") missing from error message
     * | Expected Result: Validation error is added in a user-friendly format
     **/
    static testMethod void addFriendlyError_FunkyEndCharactersMissingFromErrMsg_FriendlyValidationErrorAdded() {

        final String VALIDATION_ERROR_MSG = 'Update failed. First exception on row 0 with id a02m0000007u6ywAAA;' +
                ' first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, This error should appear, not oops!';

        List<SObject> newSObjects = new List<SObject> {new Campaign()};

        ExceptionHelper helper = new ExceptionHelperImpl();

        String errorMsg;

        Test.startTest();
        System.runAs(setupTestUser()) {
            errorMsg = helper.addFriendlyError(new ExceptionHelperException(VALIDATION_ERROR_MSG), newSObjects[0]);
        }
        Test.stopTest();

        System.assertEquals('This error should appear, not oops!', errorMsg, 'Expected friendly validation message.');
    }

    /**
     * Method Tested: throwFriendlyException
     * | Scenario: Called
     * | Throws AuraHandledException with friendly error message.
     **/
    static testmethod void throwFriendlyException_Called_ThrowsAuraHandledExceptionWithFriendlyErrorMessage() {

        ExceptionHelperImpl helper = new ExceptionHelperImpl();

        String errorMsg;

        Test.startTest();
        try {
            System.runAs(setupTestUser()) {
                helper.throwFriendlyException(new ExceptionHelperException('Ugly error message.'));
            }
        }
        catch (AuraHandledException ahe) {
            errorMsg = ahe.getMessage();
        }
        Test.stopTest();

        System.assertEquals('Script-thrown exception', errorMsg,
                'Expected message indicating AuraHandledException as thrown.');
        System.assertEquals(EXH_Constants.DFLT_FRIENDLY_ERR_MSG, helper.thrownExceptionMessage,
                'Expected friendly validation message.');
    }

    /**
     * Method Tested: addFriendlyError
     * | Scenario: Called
     * | Expected Result: System generated Error.
     **/
    static testmethod void addFriendlyError_Called_ErrorAddedNotWithUserFriendlyMessage() {

        List<SObject> newSObjects = new List<SObject> {new Campaign()};

        ExceptionHelper helper = new ExceptionHelperImpl();

        String errorMsg;

        Test.startTest();
        System.runAs(setupSystemAdminUser()) {
            errorMsg = helper.addFriendlyError(new ExceptionHelperException('Ugly error message.'), newSObjects[0]);
        }
        Test.stopTest();
        System.assertNotEquals(EXH_Constants.DFLT_FRIENDLY_ERR_MSG, errorMsg, 'Expected not the friendly error message.');
    }

    public class ExceptionHelperException extends Exception {}

}