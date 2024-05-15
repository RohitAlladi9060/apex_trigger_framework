/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Exception Helper Interfaces
 * @group-content ../ApexDocContent/Interfaces.html
 * @description Interface for adding/throwing friendly exception messages
 **/
public interface ExceptionHelper {

    /**
     * Replaces the exception message with a friendly one and adds to errorRecord.
     * @param exc The exception
     * @param errorRecord Object from trigger context to which to add the friendly error message
     * @return The friendly error message
     **/
    String addFriendlyError(Exception exc, SObject errorRecord);

    /**
     * Throws an exception with a friendly error message. Suitable for non-trigger contexts.
     * @param exc The exception
     */
    void throwFriendlyException(Exception exc);
}