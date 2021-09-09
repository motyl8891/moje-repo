/******************************************************************* 
* @author: Gopi Krishna K
* @date: 2019-03-01  
* @description: This class is a helper class for Opportunity Sales Team trigger and contains multiple helper methods

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			16-07-2020				U-1991 - Profile related condition updated with "AccessSettings__c" custom setting
Shubham Jagatap			22-07-2020				U-1903 - Replaced Hard coded values by global constants

******************************************************************************************/

public without sharing class OpportunitySalesTeamHelper{
    
    /****************************************************************
* @author: Gopi Krishna K
* @date: 2019-03-01
* @param: oppSalesteamList
* @return: Boolean
* @description: This method calling Team Assignment update from Opportunity Sales Team records to related Opportunities one by one for each Opportunity Sales Team
*****************************************************************/
    public static Boolean updateSalesteamOnOpportunity(List<Opportunity_Sales_Team__c> oppSalesteamList){
        try{
            Set<Id> oppIdsSet = new Set<Id>();
            if(!oppSalesteamList.isEmpty()){
                for(Opportunity_Sales_Team__c oppSalesteam: oppSalesteamList){
                    oppIdsSet.add(oppSalesteam.Opportunity__c);
                }    
            }
            
            //NS
            /*List<Opportunity_Sales_Team__c> ostList = [SELECT Id, Opportunity__c, Role__c,Employee__c,Employee__r.Name,Employee__r.Signum__c,Employee__r.First_Name__c,
            											Employee__r.Last_Name__c FROM Opportunity_Sales_Team__c WHERE Opportunity__c IN: oppIdsSet 
														Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];*/
            
            //nullifying all the affected Opps CSR, CFR, and Team Assignment
            Map<String, Opportunity> idOppMap = new Map<String, Opportunity>();
            if(!oppSalesteamList.isEmpty()){
                for(Opportunity_Sales_Team__c oppSales: oppSalesteamList){
                    Opportunity opp = new Opportunity(Id = oppSales.Opportunity__c, CSR_Signum__c = GlobalConstants.BLANK, 
                                                      CFR_Signum__c = GlobalConstants.BLANK, Team_Assignment__c = GlobalConstants.BLANK);
                    idOppMap.put(opp.Id, opp);
                }
            }    
            // Create map to contain list of roles that can be sorted alphabetically
            Map<String, List<String>> idOppRoleList = new Map<String, List<String>>();
            
            //looping through all opp team members looking at their roles
            //NS 
            for(Opportunity_Sales_Team__c oppSales: [SELECT Id, Opportunity__c, Role__c,Employee__c,Employee__r.Name,Employee__r.Signum__c,Employee__r.First_Name__c,
            										Employee__r.Last_Name__c FROM Opportunity_Sales_Team__c WHERE Opportunity__c IN: oppIdsSet 
													Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                //if csr - updating csr field on opportunity. same for cfr and others
                
                if(oppSales.Role__c == GlobalConstants.CSR){
                    //if out map already contains opportunity id (in cases when cfr, csr and others are updated in one go through UI) - just updating existing Opp in map
                    idOppMap.get(oppSales.Opportunity__c).CSR_Signum__c = oppSales.Employee__r.Signum__c;
                }else if(oppSales.Role__c == GlobalConstants.CFR){
                    //if out map already contains opportunity id (in cases when cfr, csr and others are updated in one go through UI) - just updating existing Opp in map
                    idOppMap.get(oppSales.Opportunity__c).CFR_Signum__c = oppSales.Employee__r.Signum__c;
                }
                else if(oppSales.Role__c == GlobalConstants.ContractManager){
                    //if out map already contains opportunity id (in cases when cfr, csr and others are updated in one go through UI) - just updating existing Opp in map
                    idOppMap.get(oppSales.Opportunity__c).Contract_Manager_Signum__c = oppSales.Employee__r.Signum__c;
                }
                // Add role + name to list for Opportunity
                // Check if Opportunity ID is already in map
                if(idOppRoleList.get(oppSales.Opportunity__c) == null){
                    List<String> roleList = new List<String>();
                    Map<String, List<String>>  nameList = new Map<String, List<String>>();
                    roleList.add(oppSales.Role__c + GlobalConstants.COLON + GlobalConstants.SPACE 
                                 + oppSales.Employee__r.Name+ GlobalConstants.NEWLINE);
                    
                    idOppRoleList.put(oppSales.Opportunity__c, roleList);
                    //nameList.put(oppSales.Employee__r.First_Name__c,idOppRoleList.get(oppSales.Opportunity__c));
                }
                // Else, add Role to existing list
                else{
                    idOppRoleList.get(oppSales.Opportunity__c).add(oppSales.Role__c + GlobalConstants.COLON + GlobalConstants.SPACE 
                                                                   + oppSales.Employee__r.Name + GlobalConstants.NEWLINE);
                }
            }
            
            // Sort each list of roles, and map it to the opportunity.
            // Then convert all Map Opportunities into List to pass it for Update
            List<Opportunity> oppsList = new List<Opportunity>();
            for(Opportunity opp: idOppMap.values()){
                // Get list of roles for each opportunity, and sort them alphabetically
                idOppRoleList.get(opp.Id).sort();
                // For each role in the role list, add it to the opportunity Team Assignment Field
                for(String role : idOppRoleList.get(opp.Id))
                {
                    opp.Team_Assignment__c += role;
                }
                // add the opportunity to the list for updating
                oppsList.add(opp);
            }
            update oppsList;
            
            return true;
            
        }catch(NullPointerException npe){
            //U-1903
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunitySalesTeamHelper, GlobalConstants.updateSalesteamOnOpportunity, GlobalConstants.OpportunitySalesTeamHelper, true, npe)));
            return false;
        }catch(DmlException de){
            if(System.IsBatch() == false && System.isFuture() == false){
            //U-1903
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunitySalesTeamHelper, GlobalConstants.updateSalesteamOnOpportunity, GlobalConstants.OpportunitySalesTeamHelper, true, de)));
            }
            return false;
        }
    }
    // This method is used to insert Opportunity Team Members on Sales Team Members insert
    public static void insertOpportunityTeamMembersOnOpportunity (List<Opportunity_Sales_Team__c> newOppSalesTeam){
        Try{
        List<Opportunity_Sales_Team__c> oppSalesTeamList = new List<Opportunity_Sales_Team__c>();
        Set<id> salesTeamIDs = new Set<id>();
        Set<id> salesTeamOppIDs = new Set<id>();
        Set<OpportunityTeamMember> oppTeamMemberList = new Set<OpportunityTeamMember>();
        List<OpportunityTeamMember> oppTeamMemberInsertList = new List<OpportunityTeamMember>();
        set<String> empSignumIDs = new set<String>();
        List<User> userDetails = new List<User>();
        for(Opportunity_Sales_Team__c oppSalesTeam:newOppSalesTeam){
            salesTeamIDs.add(oppSalesTeam.id);
        }
        if(salesTeamIDs.size()>0){
            oppSalesTeamList = [SELECT id,Opportunity__c,Employee__c,Employee_Email__c,Employee_Signum__c,Role__c from Opportunity_Sales_Team__c where id IN:salesTeamIDs Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];         
            if(oppSalesTeamList.size()>0){
                for(Opportunity_Sales_Team__c oppSalesTeam1:oppSalesTeamList){
                    empSignumIDs.add(oppSalesTeam1.Employee_Signum__c);
                }
                if(empSignumIDs.size()>0){
                    userDetails = [SELECT id,Name,Signum__c from User where Signum__c IN:empSignumIDs and isActive = TRUE Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }
                // To Insert Team Members
                if(userDetails.size()>0){
                    for(Opportunity_Sales_Team__c oppSalesTeam2:oppSalesTeamList){
                        for(User usr:userDetails){
                            if(oppSalesTeam2.Employee_Signum__c == usr.Signum__c){
                                OpportunityTeamMember otm = new OpportunityTeamMember();
                                otm.OpportunityId = oppSalesTeam2.Opportunity__c;
                                otm.UserId = usr.id;
                                //U-1903
                                otm.TeamMemberRole = oppSalesTeam2.Role__c;
                                otm.OpportunityAccessLevel = GlobalConstants.EDIT;
                                oppTeamMemberList.add(otm);
                            }
                        }
                    }
                }
            }
            if(oppTeamMemberList.size()>0){
                for(OpportunityTeamMember otminsert:oppTeamMemberList){
                    oppTeamMemberInsertList.add(otminsert);
                }
                insert oppTeamMemberInsertList;
            }
        }
            }catch(Exception e){	}
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 2019-07-16
* @param: oppSalesteamList
* @description: This method will restrict addition and updation of sales team on closed oppty.(D-1729), Bypassed oppty owner and Sales Operaions profile (U-1306)
*****************************************************************/
    public static void restrictSalesTeamOnClosedOppty(List<Opportunity_Sales_Team__c> oppSalesteamList)
    {
        Set<Id> oppIdsSet = new Set<Id>();
        Set<Id> closedOppIdSet = new Set<Id>();
        List<String> oppClosedStageList = new List<String>();
        try{ 
            for(Opportunity_Sales_Team__c oppSalesteam: oppSalesteamList){
                oppIdsSet.add(oppSalesteam.Opportunity__c);
            }
            if(!oppIdsSet.isEmpty())
            {	//U-1903
                oppClosedStageList.add(GlobalConstants.oppStageClosedLost);
                oppClosedStageList.add(GlobalConstants.oppStageClosedDuplicate);
                oppClosedStageList.add(GlobalConstants.oppStageClosedWithdrawn);
                oppClosedStageList.add(GlobalConstants.oppStageClosedWon);
                for(Opportunity opp:[Select id,StageName,ownerId from Opportunity where id in : oppIdsSet and 
                                     StageName in: oppClosedStageList
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    //U-1991
                    if(userInfo.getUserId() != opp.OwnerId && !AccessSettings__c.getInstance().CanAddOrUpdateSalesTeamOnClosedOpp__c)
                    	closedOppIdSet.add(opp.id);
                }
            }
            if(!closedOppIdSet.isEmpty())
            {
                for(Opportunity_Sales_Team__c oppSalesteam: oppSalesteamList)
                {
                    if(closedOppIdSet.contains(oppSalesteam.Opportunity__c))
                        //U-1903
                        oppSalesteam.addError(GlobalConstants.SalesTeamError);
                }  
            }   
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OPPORTUNITYSALESTEAMHELPER, 
                                                                       GlobalConstants.RESTRICTSALESTEAMONCLOSEDOPPTY, GlobalConstants.OPPORTUNITYSALESTEAMHELPER, true, e)));
        }
    }   
    
    /****************************************************************
* @author: Aditya Mohapatra		
* @date: 2019-07-18
* @param: oppSalesteamList
* @description: This method will remove Employees and updation of Opportunity team.
*****************************************************************/
    public static void removeEmployeeFromOpptyTeam(List<Opportunity_Sales_Team__c> oppSalesteamList)
    { 
        Set<id> opptyIdSet = new Set<id>();
        Set<id> opptyIdsSet = new Set<id>();
																																				  
        Map<id, List<id>> opptyIdWithEmployeeMap = new Map<id, List<id>>();
        List<Id> EmployeeSet;
        Map<Id,String> employeeIdWithSignumMap = new  Map<Id,String> ();
        Map<Id,String> empIdWithSignumMap = new  Map<Id,String> ();
        Map<Id,integer> EmployeeIdWithcountMap = new Map<Id,Integer> ();
        List<OpportunityTeamMember> OpportunityTeamMemberList = new  List<OpportunityTeamMember>();
        Map<id,User> userMap;
        integer count = 0;
        try{
            for(Opportunity_Sales_Team__c oppSalesteam: oppSalesteamList){
                opptyIdSet.add(oppSalesteam.Opportunity__c);
            }
            if(opptyIdSet!= NULL){
            For(Opportunity_Sales_Team__c oppSalesteam: [Select id,Opportunity__c, Employee__c,Employee__r.Signum__c from Opportunity_Sales_Team__c 
                                                         where Opportunity__c in : opptyIdSet 
                                                        Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                
            {
                if(opptyIdWithEmployeeMap.containsKey(oppSalesteam.Opportunity__c))
                {
                    EmployeeSet = opptyIdWithEmployeeMap.get(oppSalesteam.Opportunity__c);
                    EmployeeSet.add(oppSalesteam.Employee__c);
                    opptyIdWithEmployeeMap.put(oppSalesteam.Opportunity__c,EmployeeSet);
                }
                else
                {
                    EmployeeSet = new List<Id>();
                    EmployeeSet.add(oppSalesteam.Employee__c);
                    opptyIdWithEmployeeMap.put(oppSalesteam.Opportunity__c,EmployeeSet);
                }
                employeeIdWithSignumMap.put(oppSalesteam.Employee__c,oppSalesteam.Employee__r.Signum__c);
            }   
            }
            for(Opportunity_Sales_Team__c oppSalesteam: oppSalesteamList){
                List<id> idList = opptyIdWithEmployeeMap.get(oppSalesteam.Opportunity__c);
                if(idList.contains(oppSalesteam.Employee__c))
                {
                    idList.remove(idList.indexOf(oppSalesteam.Employee__c));
                    if(idList.contains(oppSalesteam.Employee__c))
                    {
                        count = 1;
                        break;
                    }       
                }
                if(count != 1)
                {
                    opptyIdsSet.add(oppSalesteam.Opportunity__c);
                    empIdWithSignumMap.put(oppSalesteam.Employee__c,employeeIdWithSignumMap.get(oppSalesteam.Employee__c));
                } 
            } 
            if(!empIdWithSignumMap.isEmpty())
            {
                userMap = new Map<id,User>([Select id, Signum__c from User
                                            where Signum__c in : empIdWithSignumMap.values()
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            }
            if(!opptyIdsSet.isEmpty() && !userMap.isEmpty())
            {
                for(OpportunityTeamMember OpportunityTeamMember : [Select Opportunityid,UserId from OpportunityTeamMember 
                                                                   where Opportunityid in: opptyIdsSet
                                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(userMap.keySet().contains(OpportunityTeamMember.UserId))
                        OpportunityTeamMemberList.add(OpportunityTeamMember);
                }
                if(!OpportunityTeamMemberList.isEmpty())
                    database.delete(OpportunityTeamMemberList);
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OPPORTUNITYSALESTEAMHELPER, 
                                                                       GlobalConstants.RESTRICTSALESTEAMONCLOSEDOPPTY, GlobalConstants.OPPORTUNITYSALESTEAMHELPER, true, e)));
        }  
    }
     /****************************************************************
* @author: Aditya Mohapatra		
* @date: 2019-07-19
* @param: oppSalesteamList
* @description: This method will clear Sales Team Assignment Field On Oppty.
*****************************************************************/
    public static void clearSalesTeamAssignmentOnOppty(List<Opportunity_Sales_Team__c> oppSalesteamList)
    { 
        Try{
		Set<Id> oppToUpdateSet = new Set<Id>();
		Set<Id> oppToUpdateSet2 = new Set<Id>();
        List<Id> EmployeeSet;
		List<id> salesOppTeamList = new List <id>();
		Map<id, List<id>> opptyIdWithEmployeeMap = new Map<id, List<id>>();
        List<Opportunity> opptyList = new List<Opportunity>();
		for (Opportunity_Sales_Team__c oppSalesteam : oppSalesteamList) 
			{
				oppToUpdateSet.add(oppSalesteam.Opportunity__c);
			}
		Map<Id, Opportunity> oppToUpdateMap = New Map<Id, Opportunity>([Select Id, Team_Assignment__c from Opportunity where Id in :oppToUpdateSet]);
		for(Opportunity_Sales_Team__c oppSalesteam : [Select id,Opportunity__c,Employee__c from Opportunity_Sales_Team__c 
                                                         where Opportunity__c in : oppToUpdateSet  ])
            {
				if(opptyIdWithEmployeeMap.containsKey(oppSalesteam.Opportunity__c))
                {
                    EmployeeSet = opptyIdWithEmployeeMap.get(oppSalesteam.Opportunity__c);
                    EmployeeSet.add(oppSalesteam.Employee__c);
                    opptyIdWithEmployeeMap.put(oppSalesteam.Opportunity__c,EmployeeSet);
                }
                else
                {
                    EmployeeSet = new List<Id>();
                    EmployeeSet.add(oppSalesteam.Employee__c);
                    opptyIdWithEmployeeMap.put(oppSalesteam.Opportunity__c,EmployeeSet);
                }	
			}
        for(Opportunity_Sales_Team__c oppSalesteam: oppSalesteamList)
        {
            if(!opptyIdWithEmployeeMap.keySet().contains(oppSalesteam.Opportunity__c))
            {
                oppToUpdateMap.get(oppSalesteam.Opportunity__c).Team_Assignment__c = null;
                opptyList.add(oppToUpdateMap.get(oppSalesteam.Opportunity__c));
            }
        }
        if(!opptyList.isEmpty())
            database.update(opptyList);
		}catch(Exception e){	}
    }
/****************************************************************
* @author: Amit Ojha		
* @date: 2020-09-14
* @param: oppSalesteamList
* @description: U-1938
*****************************************************************/
    public static void updatePrimaryCore3OnSDR(List<Opportunity_Sales_Team__c> oppSalesteamList)
    { 
        Try{
            List<Sales_Decision_Record__c> sdrToUpdate = new List<Sales_Decision_Record__c>();
            Map<Id, List<Opportunity_Sales_Team__c>> oppToOstMap = new Map<Id, List<Opportunity_Sales_Team__c>>();  
        	for (Opportunity_Sales_Team__c oppSalesteam : oppSalesteamList) 
				{
                    if((oppSalesteam.Role__c==GlobalConstants.ACR || oppSalesteam.Role__c==GlobalConstants.CSR ||
                        oppSalesteam.Role__c==GlobalConstants.CFR) && oppSalesteam.Primary__c ){
                            if(!oppToOstMap.containsKey(oppSalesteam.opportunity__c)) {
                                oppToOstMap.put(oppSalesteam.opportunity__c, new List<Opportunity_Sales_Team__c>()); 
                            }
                            oppToOstMap.get(oppSalesteam.opportunity__c).add(oppSalesteam);
                        }
                }
            if(!oppToOstMap.isEmpty()){ 
                for(Sales_Decision_Record__c sdriterator : [select Opportunity__c, id , name, CSR__c, CFR__c, ACR__c, CSR_Email__c, CFR_Email__c, ACR_Email__c  
                                                               from Sales_Decision_Record__c where Opportunity__c in: oppToOstMap.keySet()
                                                               and Sales_Decision_Approval_Status__c =: GlobalConstants.In_Progress                                                             
                                                              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){ 
                    for(Opportunity_Sales_Team__c salesTeam: oppToOstMap.get(sdriterator.Opportunity__c)){
                        if(salesTeam.Role__c ==GlobalConstants.ACR){
                            sdriterator.ACR__c = salesTeam.Employee__c;
                            sdriterator.ACR_Email__c = salesTeam.Employee__r.Email__c;
                        }
                        if(salesTeam.Role__c ==GlobalConstants.CSR){
                            sdriterator.CSR__c = salesTeam.Employee__c;
                            sdriterator.CSR_Email__c = salesTeam.Employee__r.Email__c;
                        }
                        if(salesTeam.Role__c ==GlobalConstants.CFR){
                            sdriterator.CFR__c = salesTeam.Employee__c;
                            sdriterator.CFR_Email__c = salesTeam.Employee__r.Email__c;
                        }
                        //sdrToUpdate.add(sdriterator);
                    }	
					sdrToUpdate.add(sdriterator);
                }
            }

            if(!sdrToUpdate.isEmpty()){
                database.update(sdrToUpdate); 
            }
		}catch(Exception e){	}
    }	
	}