/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Utility Classes
 * @group-content ../ApexDocContent/Classes.html
 * @description Test data utility
 **/
public class TRF_TestDataUtility {

    /**
     * @Method createAccounts
     * @Params number of records to create, boolean to insert
     * @description creates test data for accounts.
     **/
    public static List<Account> createAccounts(integer numOfRecords, Boolean isInsert){
        List<Account> testAccounts = new List<Account>();
        for(integer i = 0; i < numOfRecords; i++){
            Account acc = new Account();
            acc.Name = 'Test Account ' + i;
            testAccounts.add(acc);
        }

        if(isInsert){
            insert testAccounts;
        }

        return testAccounts;
    }

    /**
     * @description Creates a single test user
     * @param profileName Name of the profile given to the test user
     * @return User object
     **/
    public static User createUser(String profileName) {
        List<User> users = createUsers(profileName, 1, 0);
        return users[0];
    }

    /**
     * @description Creates test users that can be inserted in a setup or test method
     * @param profileName Name of profile to use
     * @param numUsers The number of users to create
     * @return List of users to be inserted
     */
    public static List<User> createUsers(String profileName, Integer numUsers, Integer startIndex) {
        List<User> users = new List<User>();
        Profile prof = [Select id from Profile where name = :profileName];
        for (Integer i = startIndex; i < startIndex + numUsers; i++) {
            User usr = new User();
            usr.FirstName = profileName + i;
            usr.LastName = 'Test';
            usr.Email = 'Test@vz.com';
            usr.Alias = 'test' + i;
            usr.Username = 'test' + i + '@vz.com';
            usr.LocaleSidKey = TRF_Constants.LOCALE_EN_US;
            usr.TimeZoneSidKey = 'GMT';
            usr.ProfileID = prof.Id;
            usr.LanguageLocaleKey = TRF_Constants.LOCALE_EN_US;
            usr.EmailEncodingKey = 'UTF-8';
            users.add(usr);
        }
        return users;
    }
}