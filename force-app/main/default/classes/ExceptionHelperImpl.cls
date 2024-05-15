/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Exception Helper Classes
 * @group-content ../ApexDocContent/Classes.html
 * @description Implementation for ExceptionHelper interface
 **/
public class ExceptionHelperImpl implements ExceptionHelper {

    final String VALIDATION_EXCEPTION_NAME = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    final String END_OF_VALIDATION_ERROR_MSG = ': []';

    @TestVisible
    private String thrownExceptionMessage;

    public String addFriendlyError(Exception exc, SObject errorRecord) {

        writeToDebugLog(exc, 'FRIENDLY HANDLED EXCEPTION'); //May need to change this as other scenarios surface
        String friendlyErrorMsg = makeErrorMessageUserFriendly(exc.getMessage());
        errorRecord.addError(friendlyErrorMsg);
        return friendlyErrorMsg;
    }

    public void throwFriendlyException(Exception exc) {

        writeToDebugLog(exc, 'FRIENDLY HANDLED EXCEPTION'); //May need to change this
        String friendlyErrorMsg = makeErrorMessageUserFriendly(exc.getMessage());
        thrownExceptionMessage = friendlyErrorMsg;
        throw new AuraHandledException(friendlyErrorMsg);
    }

    private String makeErrorMessageUserFriendly(String inputMessage) {

        String friendlyErrorMsg = EXH_Constants.DFLT_FRIENDLY_ERR_MSG;
        String profileName = [SELECT Name from Profile WHERE Id =: Userinfo.getProfileId() LIMIT 1].Name;
        if (profileName != EXH_Constants.PROFILE_SYSTEM_ADMIN) {
            if (inputMessage.contains(VALIDATION_EXCEPTION_NAME)) {
                if (inputMessage.contains(END_OF_VALIDATION_ERROR_MSG)) {
                    friendlyErrorMsg = inputMessage.substringBetween(VALIDATION_EXCEPTION_NAME,
                            END_OF_VALIDATION_ERROR_MSG);
                } else {
                    friendlyErrorMsg = inputMessage.substringAfter(VALIDATION_EXCEPTION_NAME);
                }
                friendlyErrorMsg = friendlyErrorMsg.removeStart(',').trim();
            }
        }
        else{
            friendlyErrorMsg = inputMessage;
        }
        return friendlyErrorMsg;
    }

    private void writeToDebugLog(Exception exc, String logSectionName) {

        System.debug('******* BEGIN ' + logSectionName + ' *******' );
        System.debug(exc.getMessage());
        System.debug(exc.getStackTraceString());
        Object theInstantiatedObject = Type.forName('').newInstance();

        System.debug('******** END ' + logSectionName + ' ********');
    }
}