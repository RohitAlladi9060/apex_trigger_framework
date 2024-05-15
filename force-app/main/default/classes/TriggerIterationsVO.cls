/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Classes
 * @group-content ../ApexDocContent/Classes.html
 * @description A VO class for setting the variables for Trigger Iterator.
 **/
public class TriggerIterationsVO {

    private static final Integer DEFAULT_ITERATIONS = 0;

    public TriggerIterationsVO() {
        this.sObjectApiNames = new Set<String>();
        this.beforeInsertIterations = new Map<String, Integer>();
        this.afterInsertIterations = new Map<String, Integer>();
        this.beforeUpdateIterations = new Map<String, Integer>();
        this.afterUpdateIterations = new Map<String, Integer>();
        this.beforeDeleteIterations = new Map<String, Integer>();
        this.afterDeleteIterations = new Map<String, Integer>();
        this.afterUnDeleteIterations = new Map<String, Integer>();
    }

    public void initialize(String sObjectApiName) {
        this.sObjectApiNames = new Set<String>{sObjectApiName};
        this.beforeInsertIterations = new Map<String, Integer>{sObjectApiName => DEFAULT_ITERATIONS};
        this.afterInsertIterations = new Map<String, Integer>{sObjectApiName => DEFAULT_ITERATIONS};
        this.beforeUpdateIterations = new Map<String, Integer>{sObjectApiName => DEFAULT_ITERATIONS};
        this.afterUpdateIterations = new Map<String, Integer>{sObjectApiName => DEFAULT_ITERATIONS};
        this.beforeDeleteIterations = new Map<String, Integer>{sObjectApiName => DEFAULT_ITERATIONS};
        this.afterDeleteIterations = new Map<String, Integer>{sObjectApiName => DEFAULT_ITERATIONS};
        this.afterUnDeleteIterations = new Map<String, Integer>{sObjectApiName => DEFAULT_ITERATIONS};
    }

    public void initialize(String sObjectApiName, Integer iterations) {
        this.sObjectApiNames = new Set<String>{sObjectApiName};
        this.beforeInsertIterations = new Map<String, Integer>{sObjectApiName => iterations};
        this.afterInsertIterations = new Map<String, Integer>{sObjectApiName => iterations};
        this.beforeUpdateIterations = new Map<String, Integer>{sObjectApiName => iterations};
        this.afterUpdateIterations = new Map<String, Integer>{sObjectApiName => iterations};
        this.beforeDeleteIterations = new Map<String, Integer>{sObjectApiName => iterations};
        this.afterDeleteIterations = new Map<String, Integer>{sObjectApiName => iterations};
        this.afterUnDeleteIterations = new Map<String, Integer>{sObjectApiName => iterations};
    }

    public TriggerIterationsVO(String sObjectApiName) {
        initialize(sObjectApiName);
    }

    public TriggerIterationsVO(String sObjectApiName, Integer iterations) {
        initialize(sObjectApiName,iterations);
    }

    public Set<String> sObjectApiNames;
    public Map<String, Integer> beforeInsertIterations;
    public Map<String, Integer> afterInsertIterations;
    public Map<String, Integer> beforeUpdateIterations;
    public Map<String, Integer> afterUpdateIterations;
    public Map<String, Integer> beforeDeleteIterations;
    public Map<String, Integer> afterDeleteIterations;
    public Map<String, Integer> afterUnDeleteIterations;
}