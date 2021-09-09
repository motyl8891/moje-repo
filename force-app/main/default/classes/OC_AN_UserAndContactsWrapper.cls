public class OC_AN_UserAndContactsWrapper {
    
    public  string firstName;
    public  string lastName;
    public  string Id;
    @AuraEnabled
    public  string name;
    @AuraEnabled
    public  string email;
    
    @AuraEnabled
    public  string accName;
    
    public OC_AN_UserAndContactsWrapper(String firstName , String lastName, String Id, String name, String email){
        
        this.firstName = firstName;
        this.lastName = lastName;
        this.Id = Id;
        this.name = name;
        this.email = email;  
    }

}