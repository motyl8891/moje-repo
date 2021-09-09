/* Class Name : OC_TH_CaseTeamMember
* Description : This class is used to add/update the case owners in case teamMember with respective roles for the task and case .
* Author      : Subashini Arulalan
*
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0      2021-03-16         Subashini Arulalan       Initial Version as part of U-2585
*/

public class OC_TH_CaseTeamMember {
    
    Public static Map<String,OC_TH_Case_TeamRole__mdt> mapRoleId = OC_TH_Case_TeamRole__mdt.getAll();
    
    /****************************************************************
* @author: Subashini Arulalan
* @date: 2021-03-16
* @param: List - standard CSR case
* @description: This method is called in insert of standardCSR case to add the caseowner in caseteammember with Investigation leader role. 
*****************************************************************/
    
    public static void standardCSRInsertCheck (list<Case> stdCaseRecords)
    {
        List<CaseTeamMember> recordsToInsert = new list<CaseTeamMember>();
        try
        {
            for(Case stdCase: stdCaseRecords){
                CaseTeamMember csTeam = new CaseTeamMember();
                csTeam.MemberId = stdCase.OwnerId;
                csTeam.TeamRoleId = mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c;
                csTeam.ParentId = stdCase.id;
                recordsToInsert.add(csTeam);
            }
            insert recordsToInsert;
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseTeamMember,OC_TH_Constants.method_standardCSRInsertCheck,null, false, e));
        }  
    }
    /****************************************************************
* @author: Subashini Arulalan
* @date: 2021-03-16
* @param: List - collaboration CSR case,Set- case parentId
* @description: This method is called in insert of collaorationCSR case to add/update the caseowner in caseteammember with respective role. 
*****************************************************************/    
    public static void CollaborationCSRInsertCheck (List<Case> colabCaseRecords, Set<id> parentId)
    {
        List<CaseTeamMember> recordsToInsert = new list<CaseTeamMember>();
        List<CaseTeamMember> recordsToUpdate = new list<CaseTeamMember>();
        Map<id,List<CaseTeamMember>> csteamMap = new Map<id,List<CaseTeamMember>>();
        try
        {
            for(CaseTeamMember csTeam:[select id,MemberId,TeamRole.name,TeamRoleId,ParentId from CaseTeamMember where ParentId IN: parentId]){
                if(csteamMap.containsKey(csTeam.ParentId)){
                    List<CaseTeamMember> existingTeam = csteamMap.get(csTeam.ParentId);
                    existingTeam.add(csTeam);
                    csteamMap.put(csTeam.ParentId,existingTeam);}
                else{
                    List<CaseTeamMember> teamMem = new List<CaseTeamMember>();
                    teamMem.add(csTeam);
                    csteamMap.put(csTeam.ParentId,teamMem);}
            }
            for(case cs:colabCaseRecords)
            {
                Boolean IsTeamMem = False;
                if(csteamMap.size()>0 && csteamMap.containsKey(cs.parentId))
                {
                    List<CaseTeamMember> teamMem = csteamMap.get(cs.parentId);                                            
                    for(CaseTeamMember ct: teamMem){
                        if(ct.MemberId == cs.OwnerId){
                            IsTeamMem = true;
                            if(ct.TeamRole.name.startsWith(OC_TH_Constants.containsFormer)){
                                ct.TeamRoleId = mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                                recordsToUpdate.add(ct);}}
                    }}
                if(!IsTeamMem)
                {
                    CaseTeamMember csTeam = new CaseTeamMember();
                    csTeam.MemberId = cs.OwnerId;
                    csTeam.TeamRoleId = mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                    csTeam.ParentId = cs.parentId;
                    recordsToInsert.add(csTeam);}
            }
            if(recordsToInsert.size() > 0){
                insert recordsToInsert;
            }
            if(recordsToUpdate.size() > 0){
                update recordsToUpdate;
            }}
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseTeamMember,OC_TH_Constants.method_CollaborationCSRInsertCheck,null, false, e));
        }  
    }
    /****************************************************************
* @author: Subashini Arulalan
* @date: 2021-03-16
* @param: List -case ,Set- parentId,Map -old Map 
* @description: This method is called in update ofcollaorationCSR/stadard CSR when owner is changed/case is closed to add/update the caseowner in caseteammember with respective role.

*****************************************************************/ 
    public static void caseUpdateCheck (List<Case> CaseRecords, Map<id,case> oldCase, set<id> parentId)
    {
        List<CaseTeamMember> recordsToInsert = new list<CaseTeamMember>();
        List<CaseTeamMember> recordsToUpdate = new list<CaseTeamMember>();
        Map<id,List<Task>> taskMap = new Map<id,List<Task>>();
        Map<id,List<Case>> collaborationMap = new Map<id,List<Case>>();
        boolean licsrFlag = false;
        Map<id,List<CaseTeamMember>> csteamMap = new Map<id,List<CaseTeamMember>>();
        Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        Id collaborationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getCollaborationCsrRecordType).getRecordTypeId();
        try
        {
            for(Task tsk:[select id,OwnerId,WhatId,IsClosed from Task where WhatId IN:parentId]){ 
                if(taskMap.containsKey(tsk.WhatId)){
                    List<Task> exisitingTask = taskMap.get(tsk.WhatId);
                    exisitingTask.add(tsk);
                    taskMap.put(tsk.WhatId,exisitingTask);
                }
                else{List<Task> t = new List<Task>();
                     t.add(tsk);
                     taskMap.put(tsk.WhatId,t);
                    }}
            for(Case cas:[select id,OwnerId,ParentId,IsClosed from Case where ParentId IN:parentId]){ 
                if(collaborationMap.containsKey(cas.ParentId)){
                    List<Case> exisitingCase = collaborationMap.get(cas.ParentId);
                    exisitingCase.add(cas);
                    collaborationMap.put(cas.ParentId,exisitingCase);}
                else{
                    List<Case> c = new List<Case>();
                    c.add(cas);
                    collaborationMap.put(cas.ParentId,c);}
            } 
            for(CaseTeamMember csTeam:[select id,MemberId,TeamRoleId,TeamRole.name,ParentId from CaseTeamMember where ParentId IN:parentId]){
                if(csteamMap.containsKey(csTeam.ParentId)){
                    List<CaseTeamMember> existingTeam = csteamMap.get(csTeam.ParentId);
                    existingTeam.add(csTeam);
                    csteamMap.put(csTeam.ParentId,existingTeam);}
                else{
                    List<CaseTeamMember> teamMem = new List<CaseTeamMember>();
                    teamMem.add(csTeam);
                    csteamMap.put(csTeam.ParentId,teamMem);
                }
            }
            for(Case stdcase: CaseRecords){
                if(stdcase.OC_TH_LI_CSR__c){
                    licsrFlag = true;
                }
                
                Id oldOwner = oldCase.get(stdcase.id).OwnerId;
                Case oldCaseRec = oldCase.get(stdcase.id);
                Boolean hasTask = false;
                Boolean hasCollabCase = false;
                Boolean newOwnerhasTask = false;
                Boolean newOwnerhasCollabCase = false;
                List<CaseTeamMember> getoldCaseMember = new List<CaseTeamMember>();
                List<CaseTeamMember> getnewCaseMember = new List<CaseTeamMember>();
                
                if(csteamMap.size()> 0 && csteamMap.containsKey(stdcase.id) && stdcase.RecordTypeId == standardRecordType)
                {
                    List<CaseTeamMember> teamMem = csteamMap.get(stdcase.id);
                    for(CaseTeamMember ct: teamMem){
                        if(oldOwner!=null && ct.MemberId == oldOwner){
                            getoldCaseMember.add(ct);
                        }
                        if(ct.MemberId == stdcase.ownerId){
                            getnewCaseMember.add(ct);
                        }
                    }
                }
                if(csteamMap.size()> 0 && stdcase.RecordTypeId == collaborationRecordType && csteamMap.containsKey(stdcase.parentId))
                {
                    List<CaseTeamMember> teamMem = csteamMap.get(stdcase.parentId);                                            
                    for(CaseTeamMember ct: teamMem){
                        if(oldOwner!=null && ct.MemberId == oldOwner){
                            getoldCaseMember.add(ct);
                        }
                        if(ct.MemberId == stdcase.ownerId){
                            getnewCaseMember.add(ct);
                        }
                    }
                }
                if(!getnewCaseMember.isempty())
                {
                    if(stdcase.RecordTypeId == standardRecordType){
                        getnewCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c;
                        recordsToUpdate.add(getnewCaseMember[0]);
                    }
                    else if(stdcase.RecordTypeId == collaborationRecordType && !licsrFlag){
                        if(oldOwner != stdcase.OwnerId && !stdcase.IsClosed && getnewCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer)){
                            getnewCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                            recordsToUpdate.add(getnewCaseMember[0]);}
                        if(stdcase.IsClosed)
                        {
                            if(taskMap.size()> 0 && taskMap.containskey(stdcase.parentId)){
                                List<task> ts = taskMap.get(stdcase.parentId);
                                for(Task t: ts){
                                    if(t.OwnerId == stdcase.OwnerId  && !t.IsClosed)
                                        newOwnerhasTask = true;}
                            }                          
                            if(collaborationMap.size()> 0 && collaborationMap.containskey(stdcase.parentId)){
                                List<Case> cas = collaborationMap.get(stdcase.parentId);
                                for(Case c: cas){
                                    if(c.OwnerId == stdcase.OwnerId && !c.IsClosed)
                                        newOwnerhasCollabCase = true;
                                }
                            }
                            if(!newOwnerhasTask && !newOwnerhasCollabCase && !getnewCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer) && getnewCaseMember[0].TeamRoleId != mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c){
                                getnewCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getFormerTeamMemberId).RoleId__c;
                                recordsToUpdate.add(getnewCaseMember[0]);}
                            
                        }
                    }
                }
                else{
                    CaseTeamMember csTeam = new CaseTeamMember();
                    csTeam.MemberId = stdCase.OwnerId;
                    if(stdcase.RecordTypeId == standardRecordType){
                        csTeam.ParentId = stdcase.Id;
                        csTeam.TeamRoleId =mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c;
                        recordsToInsert.add(csTeam);
                    }
                    else if(stdcase.RecordTypeId == collaborationRecordType && !licsrFlag){
                        csTeam.ParentId = stdcase.parentId;
                        csTeam.TeamRoleId =mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                        recordsToInsert.add(csTeam);}
                }               
                
                if(oldOwner != null && oldOwner != stdcase.OwnerId){
                    if(taskMap.size()> 0){
                        if(stdcase.RecordTypeId == standardRecordType && taskMap.containskey(stdcase.id)){
                            List<task> ts = taskMap.get(stdcase.id);
                            for(Task t: ts){
                                if(t.OwnerId == oldOwner && !t.IsClosed)
                                    hasTask = true;
                            }}
                        else if(stdcase.RecordTypeId == collaborationRecordType && taskMap.containskey(stdcase.parentId)){
                            List<task> ts = taskMap.get(stdcase.parentId);
                            for(Task t: ts){
                                if(t.OwnerId == oldOwner && !t.IsClosed)
                                    hasTask = true;
                            }}
                        
                    }
                    if(collaborationMap.size()> 0){
                        if(stdcase.RecordTypeId == standardRecordType && collaborationMap.containskey(stdcase.id)){
                            List<Case> cas = collaborationMap.get(stdcase.id);
                            for(Case c: cas){
                                if(c.OwnerId == oldOwner && !c.IsClosed){
                                    hasCollabCase = true;
                                }
                                    
                            }
                        }
                        else if(stdcase.RecordTypeId == collaborationRecordType && collaborationMap.containskey(stdcase.parentId)){
                            List<Case> cas = collaborationMap.get(stdcase.parentId);
                            for(Case c: cas){
                                if(c.OwnerId == oldOwner && !c.IsClosed)
                                    hasCollabCase = true;
                            }}
                        
                    }
                    if(getoldCaseMember.size()>0){
                        if(licsrFlag){
                            if(stdcase.RecordTypeId == standardRecordType){
                                    getoldCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getFormerInvestigationLeaderId).RoleId__c;
                                    recordsToUpdate.add(getoldCaseMember[0]);
                            }
                            else if(stdcase.RecordTypeId == collaborationRecordType && !getoldCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer) && !getoldCaseMember[0].TeamRoleId.equals(mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c)){    
                                getoldCaseMember[0].TeamRoleId = '';
                                    recordsToUpdate.add(getoldCaseMember[0]);
                            }
                        }else{
                            if(hasTask || hasCollabCase){
                                if(stdcase.RecordTypeId == standardRecordType){
                                    getoldCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                                    recordsToUpdate.add(getoldCaseMember[0]);}
                                else if(stdcase.RecordTypeId == collaborationRecordType && getoldCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer)){
                                    getoldCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                                    recordsToUpdate.add(getoldCaseMember[0]);}                            
                            }
                            else{
                                if(stdcase.RecordTypeId == standardRecordType){
                                    getoldCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getFormerInvestigationLeaderId).RoleId__c;
                                    recordsToUpdate.add(getoldCaseMember[0]);}
                                else if(stdcase.RecordTypeId == collaborationRecordType && !getoldCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer) && !getoldCaseMember[0].TeamRoleId.equals(mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c)){
                                    getoldCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getFormerTeamMemberId).RoleId__c;
                                    recordsToUpdate.add(getoldCaseMember[0]);}
                            }
                        }
                    } 
                }
            }
            if(recordsToInsert.size() > 0){
                insert recordsToInsert;
            }
            if(recordsToUpdate.size() > 0){
                update recordsToUpdate;
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseTeamMember,OC_TH_Constants.method_caseUpdateCheck,null, false, e));
        }  
    }
    
    /****************************************************************
* @author: Subashini Arulalan
* @date: 2021-03-16
* @param: List -case ,Set- parentId,Map -old Map 
* @description: This method is called in insert of Task to add/update the taskowner in caseteammember with respective role.

*****************************************************************/ 
    public static void taskInsertCheck (List<Task> taskRecords, set<Id> caseId)
    {
        List<CaseTeamMember> recordsToInsert = new list<CaseTeamMember>();
        List<CaseTeamMember> recordsToUpdate = new list<CaseTeamMember>();
        Map<id,List<CaseTeamMember>> csteamMap = new Map<id,List<CaseTeamMember>>();
        try
        {
            for(CaseTeamMember csTeam:[select id,MemberId,TeamRole.name,TeamRoleId,ParentId from CaseTeamMember where ParentId IN:caseId]){
                if(csteamMap.containsKey(csTeam.ParentId)){
                    List<CaseTeamMember> existingTeam = csteamMap.get(csTeam.ParentId);
                    existingTeam.add(csTeam);
                    csteamMap.put(csTeam.ParentId,existingTeam);}
                else{
                    List<CaseTeamMember> teamMem = new List<CaseTeamMember>();
                    teamMem.add(csTeam);
                    csteamMap.put(csTeam.ParentId,teamMem);}
            }
            for(Task ts:taskRecords)
            {
                Boolean IsTeamMem = False;
                if(csteamMap.size()>0 && csteamMap.containsKey(ts.WhatId))
                {
                    List<CaseTeamMember> teamMem = csteamMap.get(ts.WhatId);                                            
                    for(CaseTeamMember ct: teamMem){
                        if(ct.MemberId == ts.OwnerId){
                            IsTeamMem = true;
                            if(ct.TeamRole.name.startsWith(OC_TH_Constants.containsFormer)){
                                ct.TeamRoleId = mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                                recordsToUpdate.add(ct);
                            }}
                    }}
                if(!IsTeamMem)
                {
                    CaseTeamMember csTeam = new CaseTeamMember();
                    csTeam.MemberId = ts.OwnerId;
                    csTeam.TeamRoleId = mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                    csTeam.ParentId = ts.WhatId;
                    recordsToInsert.add(csTeam);                     
                }
                
            }
            if(recordsToInsert.size() > 0){
                insert recordsToInsert;
            }
            if(recordsToUpdate.size() > 0){
                update recordsToUpdate;
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseTeamMember,OC_TH_Constants.method_taskInsertCheck,null, false, e));
        }  
    }
    /****************************************************************
* @author: Subashini Arulalan
* @date: 2021-03-16
* @param: List -case ,Set- parentId,Map -old Map 
* @description: This method is called in update of task when owner ischanged/task is closed to add/update the owner in caseteammember with respective role.

*****************************************************************/ 
    public static void taskUpdateCheck (List<Task> taskRecords, set<id> caseId, Map<id,Task> oldTask)
    {
        List<CaseTeamMember> recordsToInsert = new list<CaseTeamMember>();
        List<CaseTeamMember> recordsToUpdate = new list<CaseTeamMember>();
        Map<id,List<Task>> taskMap = new Map<id,List<Task>>();
        Map<id,List<Case>> collaborationMap = new Map<id,List<Case>>();
        Map<id,List<CaseTeamMember>> csteamMap = new Map<id,List<CaseTeamMember>>();
        
        try
        {
            for(Task tsk:[select id,OwnerId,WhatId,IsClosed from Task where WhatId IN:caseId]){ 
                if(taskMap.containsKey(tsk.WhatId)){
                    List<Task> exisitingTask = taskMap.get(tsk.WhatId);
                    exisitingTask.add(tsk);
                    taskMap.put(tsk.WhatId,exisitingTask);
                }
                else{List<Task> t = new List<Task>();
                     t.add(tsk);
                     taskMap.put(tsk.WhatId,t);
                    }}
            for(Case cas:[select id,OwnerId,ParentId,IsClosed from Case where ParentId IN:caseId]){ 
                if(collaborationMap.containsKey(cas.ParentId)){
                    List<Case> exisitingCase = collaborationMap.get(cas.ParentId);
                    exisitingCase.add(cas);
                    collaborationMap.put(cas.ParentId,exisitingCase);}
                else{
                    List<Case> c = new List<Case>();
                    c.add(cas);
                    collaborationMap.put(cas.ParentId,c);}
            }
            for(CaseTeamMember csTeam:[select id,MemberId,TeamRoleId,TeamRole.name,ParentId from CaseTeamMember where ParentId IN:caseId]){
                if(csteamMap.containsKey(csTeam.ParentId)){
                    List<CaseTeamMember> existingTeam = csteamMap.get(csTeam.ParentId);
                    existingTeam.add(csTeam);
                    csteamMap.put(csTeam.ParentId,existingTeam);}
                else{
                    List<CaseTeamMember> teamMem = new List<CaseTeamMember>();
                    teamMem.add(csTeam);
                    csteamMap.put(csTeam.ParentId,teamMem);}
            }
            for(Task tas: taskRecords){
                Id oldOwner = oldTask.get(tas.id).OwnerId;
                Boolean oldOwnerhasTask = false;
                Boolean oldOwnerhasCollabCase = false;
                Boolean newOwnerhasTask = false;
                Boolean newOwnerhasCollabCase = false;
                List<CaseTeamMember> getoldCaseMember = new List<CaseTeamMember>();
                List<CaseTeamMember> getnewCaseMember = new List<CaseTeamMember>();
                
                if(csteamMap.size()> 0 && csteamMap.containsKey(tas.WhatId))
                {
                    List<CaseTeamMember> teamMem = csteamMap.get(tas.WhatId);                                            
                    for(CaseTeamMember ct: teamMem){
                        if(oldOwner!=null && ct.MemberId == oldOwner){
                            getoldCaseMember.add(ct);
                        }
                        if(ct.MemberId == tas.ownerId){
                            getnewCaseMember.add(ct);
                        }
                    }
                }
                if(!getnewCaseMember.isempty())
                {
                    if( tas.ownerId != oldOwner && getnewCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer)){
                        getnewCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                        recordsToUpdate.add(getnewCaseMember[0]);
                    }
                    if(tas.IsClosed){
                        if(taskMap.size()> 0 && taskMap.containskey(tas.WhatId)){
                            List<task> ts = taskMap.get(tas.WhatId);
                            for(Task t: ts){
                                if(t.OwnerId == tas.OwnerId  && !t.IsClosed)
                                    newOwnerhasTask = true;
                            }}
                        if(collaborationMap.size()> 0 && collaborationMap.containskey(tas.WhatId)){
                            List<Case> cas = collaborationMap.get(tas.WhatId);
                            for(Case c: cas){
                                if(c.OwnerId == tas.OwnerId && !c.IsClosed)
                                    newOwnerhasCollabCase = true;
                            }}
                        if(!newOwnerhasTask && !newOwnerhasCollabCase && !getnewCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer) && getnewCaseMember[0].TeamRoleId != mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c){
                            getnewCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getFormerTeamMemberId).RoleId__c;
                            recordsToUpdate.add(getnewCaseMember[0]);}
                    }                    
                }
                else{
                    CaseTeamMember csTeam = new CaseTeamMember();
                    csTeam.MemberId = tas.OwnerId;
                    csTeam.ParentId = tas.WhatId;
                    csTeam.TeamRoleId =mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                    recordsToInsert.add(csTeam); 
                }
                if(oldOwner != null && tas.ownerId != oldOwner){
                    if(taskMap.size()> 0 && taskMap.containskey(tas.WhatId)){
                        List<task> ts = taskMap.get(tas.WhatId);
                        for(Task t: ts){
                            if(t.OwnerId == oldOwner && !t.IsClosed)
                                oldOwnerhasTask = true;
                        }}
                    if(collaborationMap.size()> 0 && collaborationMap.containskey(tas.WhatId)){
                        List<Case> cas = collaborationMap.get(tas.WhatId);
                        for(Case c: cas){
                            if(c.OwnerId == oldOwner && !c.IsClosed)
                                oldOwnerhasCollabCase = true;
                        }}
                    if(getoldCaseMember.size()>0){
                        if(oldOwnerhasTask || oldOwnerhasCollabCase){
                            if( getoldCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer)){
                                getoldCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getTeamMemberId).RoleId__c;
                                recordsToUpdate.add(getoldCaseMember[0]);}}
                        else{
                            if(!getoldCaseMember[0].TeamRole.name.startsWith(OC_TH_Constants.containsFormer) && !getoldCaseMember[0].TeamRoleId.equals(mapRoleId.get(OC_TH_Constants.getInvestigationLeaderId).RoleId__c)){
                                getoldCaseMember[0].TeamRoleId =mapRoleId.get(OC_TH_Constants.getFormerTeamMemberId).RoleId__c;
                                recordsToUpdate.add(getoldCaseMember[0]);}
                        }}
                }
            }
            if(recordsToInsert.size() > 0){
                insert recordsToInsert;
            }
            if(recordsToUpdate.size() > 0){
                update recordsToUpdate;
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseTeamMember,OC_TH_Constants.method_taskUpdateCheck,null, false, e));
        }  
    }
}