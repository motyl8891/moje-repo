/**
 * @File Name          : SDODLeadTriggerHandler.cls
 * @Description        : 
 * @Author             : Ananth Chilapally
 * @Group              : 
 * @Last Modified By   : Ananth Chilapally
 * @Last Modified On   : 2019-11-21 15:26:57
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2019-11-18   Ananth Chilapally     Initial Version
 * 1.1	  2020-22-7	   Shubham Jagatap       U-1903 - Replaced Hard coded values by global constants
**/
public class SDODLeadTriggerHandler {
    public static void contributionValidtaion (List<SDOD_Lead__c> newItems) {
        Try{
            for (SDOD_Lead__c sd:newItems)
            {
                if(sd.Contribution__c > 100){
                    sd.addError(GlobalConstants.CONTRIBUTION_ERROR);
                }
            }
        }catch(Exception e){	}
    }
    
public static void AddAdditionalRecorder(List<SDOD_Lead__c> newItems) {
	Map<Id, List<Recorder__c>> lead2Recorders = new Map<Id, List<Recorder__c>>();
	Map<Id, String> lead2creatorEmail = new Map<Id, String>();
	List<String> allEmails = new List<String>();
	try{
        for(SDOD_Lead__c sd:newItems){
            //U-1903
			String character = GlobalConstants.CHAR_A;
			List<Recorder__c> allRecorders = new List<Recorder__c>();
			//Create primary recorder
			Recorder__c owner = new Recorder__c(SDOD_Lead__c = sd.id);
			owner.Recorder_Email__c = sd.Creator_Email__c;
			owner.Email__c = sd.Creator_Email__c;
			owner.Recorder_A_Z_del__c = character;	
			allRecorders.add(owner);
			allEmails.add(sd.Creator_Email__c);
			lead2creatorEmail.put(sd.id, sd.Creator_Email__c);
			
			//Create additional recorders
            if(sd.Additional_Recorders__c!=null){
				String addRec = sd.Additional_Recorders__c;
				addRec = addRec.replaceAll('\\s+','');          
				List<String> recslist=addRec.split(GlobalConstants.COMMA);
				if(!recslist.isEmpty()){
                    Integer i = 1;
					for(String email : recsList){
						Integer[] ASCIINumericRepresentation = character.getChars(); // [65]
						String nextCharacter = String.fromCharArray(new List<Integer> {ASCIINumericRepresentation[0] + i}); // 66 = 'B'
						Recorder__c recorder = new Recorder__c(SDOD_Lead__c = sd.id);
						recorder.Recorder_A_Z_del__c = nextCharacter;
						recorder.Email__c = email;
						recorder.Recorder_Email__c = email;
						allRecorders.add(recorder);
						allEmails.add(email);
                        i++;
					}
				}
			}
			lead2Recorders.put(sd.id, allRecorders);
        }
		 
		for(Id leadId : lead2Recorders.keySet()){
			List<Recorder__c> leadRecorders = lead2Recorders.get(leadId);
			Integer numberOfRecorders = leadRecorders.size();
			
			Decimal toround= (100/numberOfRecorders);
			Decimal contribution = toround.setScale(4);
			Decimal ownerContribution=0;
        
			if(toround<100)
			{
				ownerContribution=100-toround*numberOfRecorders;
			}
			// to write query outside loop.
            map<String ,Employee__c> mapEmail=new map<String,Employee__c>();            
            for(Employee__c emp:[select Email__c from Employee__c where Email__c in: allEmails]){                
                if(!String.isEmpty(emp.Email__c)){                    
                    mapEmail.put(emp.Email__c,emp);                    
                }                
            }
			for(Recorder__c recorder : leadRecorders){
//NS
				/*for(Employee__c emp : [select id,Email__c from Employee__c where Email__c in: allEmails]){
					if(emp.Email__c == recorder.email__c){
						recorder.Recorder_Employee_Name__c = emp.id;
					}
				}*/
                if(mapEmail.containsKey(recorder.email__c)){
                    recorder.Recorder_Employee_Name__c = mapEmail.get(recorder.email__c).id;
                }
                
				if(recorder.Email__c == lead2creatorEmail.get(leadId)){
					//Set owner contribution
					recorder.Contribution__c = contribution+ownerContribution;
				}
				else{
					//Set additional contributions
					recorder.Contribution__c = contribution;
				}
			}
			lead2Recorders.put(leadId, leadRecorders);
		}
		List<Recorder__c> recorders2insert = new list<Recorder__c>();
		for(Id leadId : lead2Recorders.keySet()){
			recorders2insert.addall(lead2Recorders.get(leadId));
		}
		if(!recorders2insert.isEmpty()){
			insert recorders2insert;
		}
	}
	catch(Exception e) {
		EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODLeadTriggerHandler,
		GlobalConstants.AddAdditionalRecorder, GlobalConstants.SDODLeadTriggerHandler, true, e)));
	}
} 

    
    //  Bydefault owner Should be LHR.
    public static void checkLHRValue(List<SDOD_Lead__c> newItems){
        try{
        for(SDOD_Lead__c newsdod : newItems){
       SDOD_Lead__c oldsdod=(SDOD_Lead__c)Trigger.oldMap.get(newsdod.id);
            if(newsdod.LHR__c!=null && newsdod.LHR__c != oldsdod.LHR__c ){
         AssigntoQueue(newItems);
            }}}
            catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODLeadTriggerHandler, 
                                                                       GlobalConstants.checkLHRValue, GlobalConstants.SDODLeadTriggerHandler, true, e)));
            }}
   
    public static void AssigntoQueue (List<SDOD_Lead__c> newItems){
        
        integer i=0;
        set<id> SDODIds = new set<id>();
        list<string>recs= new list<string>();

        for(SDOD_Lead__c ldid : newItems)
        {
            SDODIds.add(ldid.ownerid);
        }
        List<SDOD_Lead__c> updatePlatformLeads = new list<SDOD_Lead__c>();

        list<string> NamesOfQueues = new list<string>();
        Map<string,Group> MapOfGroups2 = new Map<string,group>();
        //U-1903
//NS
        for(SDODLeadQueueAssignment__mdt a : [select id,SDOD_Lead_Stage__c,userEmail__c,QueueName__c,Market_Area__c,Customer_Unit__c,Product_Or_Service_Area__c, Business_Area__c 
                                              from SDODLeadQueueAssignment__mdt where SDOD_Lead_Stage__c = :GlobalConstants.DRecorded ])
        {
            NamesOfQueues.add(a.QueueName__c);
        } 
		//U-1903
        set<id> ownerid = new set<id>(); 
//NS
        for(group g : [SELECT Id, Name FROM Group where type = :GlobalConstants.QUEUE and Name in:NamesOfQueues]) 
        {
            MapOfGroups2.put(g.Name,g);
        }

        for(SDOD_Lead__c p : newItems) 
        {
            if(p.Creator_Email__c==null)
            p.Creator_Email__c= userinfo.getUserEmail();
			//U-1903
            if(p.stage__c == GlobalConstants.DRecorded && P.LHR__c == null)
            {
//NS
                for(SDODLeadQueueAssignment__mdt a : [select id,SDOD_Lead_Stage__c,userEmail__c,QueueName__c,Market_Area__c,Customer_Unit__c,Product_Or_Service_Area__c, Business_Area__c 
                                                      from SDODLeadQueueAssignment__mdt where SDOD_Lead_Stage__c = :GlobalConstants.DRecorded ]) 
                    {	//U-1903
                        If((p.MarketArea__c==GlobalConstants.MNEA||p.MarketArea__c==GlobalConstants.MOAI)
                        && (p.Business_Area__c == a.Business_Area__c)&&
                        (p.stage__c == a.SDOD_Lead_Stage__c && p.Customer_Unit_Code__c == a.Customer_Unit__c && p.IsDeleted==false)
                        )
                        { 
                            if(MapOfGroups2.get(a.QueueName__c) != null)
                            {  
                                group matchingqueue = MapOfGroups2.get(a.QueueName__c);
                                p.ownerid = matchingqueue.id;
                                ownerid.add(matchingqueue.id);
                                updatePlatformLeads.add(p);
                            }

                        }
                        //U-1903
                        else if((p.MarketArea__c==GlobalConstants.MMEA ||p.MarketArea__c==GlobalConstants.MANA ||p.MarketArea__c==GlobalConstants.MELA)&&
                        (p.stage__c == a.SDOD_Lead_Stage__c && p.Customer_Unit_Code__c == a.Customer_Unit__c && p.IsDeleted==false))
                        {
 
                            if(MapOfGroups2.get(a.QueueName__c) != null)
                            {  
                                group matchingqueue = MapOfGroups2.get(a.QueueName__c);
                                p.ownerid = matchingqueue.id;
                                ownerid.add(matchingqueue.id);
                                updatePlatformLeads.add(p);
                            }
                        }
                        else
                        {
                            i++;
                        }
                    }
                    if(i==NamesOfQueues.size())
                    P.adderror(GlobalConstants.QUEUE_NOT_AVAILABLE_ERROR);  //U-1903
            }
            else if(p.stage__c == GlobalConstants.DRecorded && P.LHR__c != null && P.ownerid != P.LHR__c)
            {
                p.ownerid = p.LHR__c;
                updatePlatformLeads.add(p);
            }

         
        }
        
        for(SDOD_Lead__c SL: updatePlatformLeads){
            AccessSharing(SL.id,SL.ownerid);
        }
    }
    
    public static void AssignToSales (List<SDOD_Lead__c> newItems,List<SDOD_Lead__c> oldItems) {  
        Try{
        List<Opportunity> newOpps = new list<Opportunity>();
        List<SDOD_Lead__c> updatePlatformLeads = new list<SDOD_Lead__c>();
        list<string> NamesOfQueues = new list<string>();
        Map<string,Group> MapOfGroups2 = new Map<string,group>();
        Integer i=0;
		//U-1903

//NS
        for(SDODLeadQueueAssignment__mdt a : [select id,SDOD_Lead_Stage__c,userEmail__c,QueueName__c,Market_Area__c,Customer_Unit__c,Product_Or_Service_Area__c 
                                              from SDODLeadQueueAssignment__mdt where SDOD_Lead_Stage__c=: GlobalConstants.SDOD_C_Stage ])
        {
            NamesOfQueues.add(a.QueueName__c);
        } 
          
//NS
        for(group g : [SELECT Id, Name FROM Group where type = :GlobalConstants.QUEUE and Name in:NamesOfQueues]) 
        {
            MapOfGroups2.put(g.Name,g);
        }
        for(SDOD_Lead__c p :newItems) 
        {	//U-1903
            if(p.stage__c == GlobalConstants.SDOD_C_Stage )
            {   
//NS
                for(SDODLeadQueueAssignment__mdt a : [select id,SDOD_Lead_Stage__c,userEmail__c,QueueName__c,Market_Area__c,Customer_Unit__c,Product_Or_Service_Area__c 
                                                      from SDODLeadQueueAssignment__mdt where SDOD_Lead_Stage__c=: GlobalConstants.SDOD_C_Stage ])
                {
                    If(p.stage__c == a.SDOD_Lead_Stage__c && P.MarketArea__c == a.Market_Area__c)
                    {
                        SDOD_Lead__c pu = new SDOD_Lead__c(id=p.id);
                        group matchingqueue = MapOfGroups2.get(a.QueueName__c);
                        pu.ownerid = matchingqueue.id;
                        updatePlatformLeads.add(pu);
                        AccessSharing(pu.id,pu.ownerid);
                     }
                }
            }
         
        }
            
        update updatePlatformLeads;
            }catch(Exception e){	}
 }

 
    public static void AccessSharing(id leadid,id ownerid){
        Try{
        List<ID> lstID=new List<ID>(); 
        lstid.add(ownerid); 
        for( GroupMember gp:[Select id, UserOrGroupId From GroupMember where GroupId =: ownerid])
        {
            lstID.add(gp.UserOrGroupId);
        }
         
        for(id gid: lstID){
            SDOD_Lead__Share sdodShare=new SDOD_Lead__Share();
            sdodShare.ParentID = leadid;
            sdodShare.UserOrGroupId = gid;
            //U-1903
            sdodShare.AccessLevel = GlobalConstants.EDIT;
            sdodShare.RowCause=Schema.SDOD_Lead__Share.RowCause.Manual;
            Database.SaveResult sr = Database.insert(sdodShare,false);
        }
            }catch(Exception e){	}
    }

    public static void AccessToRecord (List<SDOD_Lead__c> newItems) {
        Try{
        List<GroupMember> gm=new List<GroupMember>();
        List<SDOD_Lead__c> sdod=new List<SDOD_Lead__c>();
        List<Id> idList=new List<Id>();
        List<Id> ownerList=new List<Id>();
        boolean check=false;
        
        for (SDOD_Lead__c sd:newItems)
        {
            //U-1903
            if(sd.Stage__c == GlobalConstants.DRecorded && sd.Approved_by_LHR__c==true )   
            ownerList.add(sd.ownerid);
        }
        
        for(GroupMember gm1:[select group.id,group.name,userorgroupid from groupmember where 
                             group.id in :ownerList])
        {
            if(gm1.userorgroupid!=userinfo.getuserid())
            {
               check=true;
            }
        }
        
        if(check)
        {
            for (SDOD_Lead__c sd:newItems)
            {
                sd.addError(GlobalConstants.CANNOT_UPDATE_LEAD_ERROR);
                
            }
        }   
        }catch(Exception e){	}
    }

}