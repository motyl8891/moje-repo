global class OC_AN_GenericBatchJob implements Database.Batchable<sObject>
{

   public String query;

   global Database.QueryLocator start(Database.BatchableContext BC){
       
         return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
     
       //OC_AN_MC_ExternalDistributionHandler
   }

   global void finish(Database.BatchableContext BC){
    
/*Email email = new Email();
email.Subject = "Check out my way cool email";
email.Name = "Dynamic Email_" + DateTime.Now.ToShortTimeString();
email.HTMLBody = "<center>##Way Cool Email</center>";
email.TextBody = "Way Cool Email";
email.CharacterSet = "iso-8859-1";
email.CategoryID = 556442;  //This is the Folder where the email is stored.
email.CategoryIDSpecified = true;
CreateResult[] results = proxy.Create(new CreateOptions(), new APIObject[] { email }, out requestID, out status);*/
       
   }
}