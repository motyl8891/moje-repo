global class SendEmailToNotifyCloseDateBatch implements Database.Batchable<sObject>  {
    map<string,list<opportunity>> OwnerEmailWithOpplistmap = new map<string,list<opportunity>>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, Account.Name, OpportunityNumber__c, StageName, CloseDate, Owner.Email, owner.name FROM Opportunity 
                                         WHERE (CloseDate <= Next_N_Days:7) 
                                         and (RecordTypeId =: GlobalConstants.standardOppRecordTypeId OR RecordTypeId =: GlobalConstants.frameOppRecordTypeId)
                                         and StageName not in('Closed Won', 'Closed Lost', 'Closed-Withdrawn', 'Closed-Duplicate') 
                                         /*and owner.name='Shubham Jagtap' */
                                         order by owner.name]);
    }
    
    global void execute(Database.BatchableContext BC, List<opportunity> scope){
        for(opportunity opp : scope){
            if(!OwnerEmailWithOpplistmap.Containskey(opp.owner.email)){
                OwnerEmailWithOpplistmap.put(opp.owner.email, new list<opportunity>());
            }
            OwnerEmailWithOpplistmap.get(opp.owner.email).add(opp);
            
        } 
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(string email : OwnerEmailWithOpplistmap.keyset()){
            List<Opportunity> OpportunitiesWithCloseDateInPast =  new List<Opportunity>();
            List<Opportunity> OpportunitiesWithCloseDateInNextSevenDays =  new List<Opportunity>();

            for(opportunity opp : OwnerEmailWithOpplistmap.get(email)){
                if(opp.CloseDate < date.Today()){
                    OpportunitiesWithCloseDateInPast.add(opp);
                }
                if(opp.CloseDate >= date.Today() && opp.CloseDate <= date.Today()+7){
                    OpportunitiesWithCloseDateInNextSevenDays.add(opp);
                }
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            list<string> toAddresses = new list<string>();
            toAddresses.add(email);
            mail.setToAddresses(toAddresses);
            mail.setSubject('Review your Salesforce Opportunities with close date in the past or in next 7 days.');                
            String username = OwnerEmailWithOpplistmap.get(email)[0].owner.name;
            String htmlBody = '';
            
            htmlBody = '<head><style>'+
                +'table, th, td {border: 1px solid black;border-collapse: collapse;}'+
                +'th, td {padding: 2px;padding-right:5px;padding-left:5px;}'+
                +'th {text-align: left;}'+
                +'</style></head>'; 
            
            htmlBody += 'Hi '+username+','+
                +'<br><br>You are the Owner of the following Opportunities in Salesforce which have a close date in the past or in the coming 7 days.';

            htmlBody += '<br><br><b>Opportunities with close date in the past:</b>';
            htmlBody += '<br><br><table style="width: -webkit-fill-available;"><tr><th>No</th><th>Name</th><th>Account</th><th>Stage</th><th>Close Date</th></tr>';
            for(opportunity opp : OpportunitiesWithCloseDateInPast){
                String CloseDate = opp.CloseDate.format();  
                String Name = opp.Name;
                String OpportunityNumber = opp.OpportunityNumber__c;
                String AccountName = opp.Account.Name;
                datetime dt = opp.CloseDate;
                string ClosedDate = dt.format('M/d/yyyy');
                string StageName = opp.StageName;
                string View = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ opp.id;
                string clickhere = view;                    
                htmlBody += '<tr><td>' + '<a href="'+View+'"'+'>'+OpportunityNumber+'</a>' +'</td><td>'+ Name + '</td><td>' + AccountName + '</td><td>' + StageName + '</td><td>' + CloseDate + '</td></tr>';                    
            }
            htmlBody += '</table>';

            htmlBody += '<br><br><b>Opportunities with close date in next seven days:</b>';
            htmlBody += '<br><br><table style="width: -webkit-fill-available;"><tr><th>No</th><th>Name</th><th>Account</th><th>Stage</th><th>Close Date</th></tr>';
            for(opportunity opp : OpportunitiesWithCloseDateInNextSevenDays){
                String CloseDate = opp.CloseDate.format(); 
                String Name = opp.Name;
                String OpportunityNumber = opp.OpportunityNumber__c;
                String AccountName = opp.Account.Name;
                datetime dt = opp.CloseDate;
                string ClosedDate = dt.format('M/d/yyyy');
                string StageName = opp.StageName;
                string View = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ opp.id;
                string clickhere = view;                    
                htmlBody += '<tr><td>' + '<a href="'+View+'"'+'>'+OpportunityNumber+'</a>' +'</td><td>'+ Name + '</td><td>' + AccountName + '</td><td>' + StageName + '</td><td>' + CloseDate + '</td></tr>';                    
            }
            htmlBody += '</table><br>';

            htmlBody += +'<b>You should:</b>'+
			+'<ol><li>Review and check the close dates and sales stages of the Opportunities with close dates in thenext 7 days and, if they are not accurate, update them.</li>'+
            +'<li>Take action to update the Opportunities with close dates in the past - either move the close date into the future or update the sales stage to Closed - Won/ Lost/ Withdrawn, as appropriate.</li></ol>'+
			+'<br><br>Regards,'+'<br />Salesforce Team';
            
            mail.sethtmlBody(htmlBody);
            if(!OpportunitiesWithCloseDateInPast.isEmpty() || !OpportunitiesWithCloseDateInNextSevenDays.isEmpty()){
                mails.add(mail);  
            }                  
        }
        
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        } 
    }
    global void finish(Database.BatchableContext BC){        
    }
}