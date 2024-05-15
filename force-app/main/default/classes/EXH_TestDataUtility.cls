/**
 * @author Rohit Alladi
 * @date Feb 2019
 * @group Test Classes
 * @group-content ../ApexDocContent/Classes.html
 * @description Test data utility
 **/
public class EXH_TestDataUtility {

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
            usr.Email = 'Test@verizon.com';
            usr.Alias = 'test' + i;
            usr.Username = 'test' + i + '@verizon.com';
            usr.LocaleSidKey = EXH_Constants.LOCALE_EN_US;
            usr.TimeZoneSidKey = 'GMT';
            usr.ProfileID = prof.Id;
            usr.LanguageLocaleKey = EXH_Constants.LOCALE_EN_US;
            usr.EmailEncodingKey = 'UTF-8';
            users.add(usr);
        }
        return users;
    }
}