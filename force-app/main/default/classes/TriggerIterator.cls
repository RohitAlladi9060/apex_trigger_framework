/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Interfaces
 * @group-content ../ApexDocContent/Interfaces.html
 * @description An interface class having methods for setting trigger iterations.
 **/

public interface TriggerIterator {

    /**
     * @description Checks if the maximum number of Trigger Iterations has been broken
     * @param triggerHandler Object trigger handler passed to TriggerFactory
     * @return Boolean variable determining if trigger should execute
     **/
    Boolean hasIterationsRemaining(TriggerHandler triggerHandler);

    /**
     * @description Compares the current trigger iterations with max trigger iterations for the object.
     * @param currentTriggerIterationsVO , MaxIterationsVO, object Name and Trigger Context.
     * @return Boolean variable determining if trigger should execute
     **/
    Boolean compareTriggerIterations(TriggerIterationsVO currentTriggerIterationsVO, TriggerIterationsVO setMaxIterationsVO,
                                    String sObjectApiName, String triggerContext);

    /**
     * @description Updates the VO class with the current trigger iterations for that trigger context of an sObject.
     * @param currentTriggerIterationsVO , sObject , Trigger Context.
     * @return TriggerIterationsVO
     **/
    TriggerIterationsVO updateCurrentTriggerIterations(TriggerIterationsVO currentTriggerIterationsVO,
                                            String sObjectApiName, String triggerContext);

    /**
     * @description Retrieves the current trigger iterations of an sObject for that trigger context.
     * @param currentTriggerIterationsVO , sObject , Trigger Context.
     * @return TriggerIterationsVO
     **/
    TriggerIterationsVO getCurrentTriggerIterations(TriggerIterationsVO currentTriggerIterationsVO, String sObjectApiName, String triggerContext);

    /**
     * @description Sets the Max Trigger iterations for the sObject.
     * @param setMaxIterations , sObjectApiName
     * @return TriggerIterationsVO
     **/
    TriggerIterationsVO getSetMaxIterations(TriggerIterationsVO setMaxIterations, String sObjectApiName);

    /**
     * @description Adds Trigger Iteration errors to records
     * @param errorMessage Error to add to Records
     * @return N/A
     **/
    void addErrorToRecords(String errorMessage);

    /**
     * @description Initially sets the maxTriggerIterations value on TriggerFactory
     * @return TriggerIterationsVO object for maxTriggerIterations
     **/
    TriggerIterationsVO setMaxIterations();

    /**
     * @description Returns a list of Trigger_Iterations_Settings metadata records
     * @return List of Trigger_Iterations_Settings metadata records
     **/
    List<SObject> getTriggerIterationsSettings();

    /**
     * @description this method retrieves the status of the trigger for the sObject.
     * @return Boolean
     **/
    Boolean getTriggerStatus();

    /**
     * @description this method retrieves sObject API name of the record.
     * @return String object API name */
    String getSObjectApiName();
}