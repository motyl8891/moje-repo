/**
 * @File Name          : ReactivateUser.cls
 * @Description        : 
 * @Author             : Ananth Chilapally
 * @Group              : 
 * @Last Modified By   : Ananth Chilapally
 * @Last Modified On   : 2019-10-17 11:08:11
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    2019-10-05   Ananth Chilapally     Initial Version
**/
public class ReactivateUser {
    public String emailoutput{get;set;}
    public Boolean framelocation {get;set;}
    public String hdnValue { get; set; }
    public Boolean showmysupport{get; set;}
    public String sfdcURL {get; set;} {sfdcURL = System.Url.getOrgDomainUrl().toExternalForm();}
    Organization currOrg = [Select IsSandbox from Organization limit 1];
    
    public PageReference showValue() {
        Try{
        showmysupport = false;
        framelocation = false;
        hdnValue += '%';
        List<User> userList= [select id,name,Email, FirstName, IsActive, LastLoginDate from User where Email like :hdnValue];
        if(userList.size() > 1){
            showmysupport = true;
        	emailoutput = userList.size() + ' users are associated with your email address. Please raise a support ticket for the same.';
        }
        if(userList.size() == 1){
            framelocation = true;
            for(User e:userList)
            {
                String numdays;
                //Calculate the number of days since last login
                if(e.LastLoginDate!=null){
                    numdays =  '(' + (Date.valueOf(e.LastLoginDate)).daysBetween(system.today()) + ' days ago)';
                } else {
                    numdays = '(no previous logins recorded)';
                }
                //If user is inactive then activate it.
                if(!e.IsActive) {
                    e.IsActive = true;
                    emailoutput = 'Hi ' + e.FirstName + ', your last login date was ' + e.LastLoginDate + numdays + '. Your access to Salesforce is activated now.';
                } else {
                    emailoutput = 'Hi ' + e.FirstName + ', Your access to Salesforce is already active. Your last login date was '	+ e.LastLoginDate  + numdays + '.';
                }
                //If it's a Sandbox.
                if (currOrg.IsSandbox){
                    if(e.Email.contains('.invalid')){
                        e.Email = e.Email.replace('.invalid','');
                        emailoutput += ' Replace the base URL in the browser before /setup to ' + sfdcURL + ' in the email that you receive for reactivation.';
                    }                  
                }
            }            
        } else if(userList.size() == 0){
            showmysupport = true;
            emailoutput = 'You do not have access to Salesforce. Please raise a support ticket for the same.';
        }

        update userList;
        }catch(Exception e){	}
    return null;
    }
}