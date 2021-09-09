public class VisualizeDeviation {
    @AuraEnabled
    public static Proposal__c getPropData(Id recordId){
        Schema.SObjectType objType=recordId.getSobjectType();
        if(objType.getDescribe().getName().contains(GlobalConstants.Opportunity)) {
            List<Proposal__c> propoList = [SELECT Id,Cash_Flow_Status__c,Contract_Evaluation_Status__c,NonDelAndComplexAndNewTechStatus__c,
                                               PD_Proposal_Link__c,Primary__c
                                       	   FROM Proposal__c WHERE Opportunity__c =: recordId AND Primary__c=true
                                          Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(propoList.size()>0) {
                return propoList.get(0);
            }else {
                return new Proposal__c();
            }
         }else {
            List<Proposal__c> propoList = [SELECT Id,Cash_Flow_Status__c,Contract_Evaluation_Status__c,NonDelAndComplexAndNewTechStatus__c,
                                               PD_Proposal_Link__c
                                       	   FROM Proposal__c 
                                           WHERE Id =: recordId
                                          Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            return propoList.get(0);
         }
	}
    
    @AuraEnabled
    public static List<DeviationWraper> getDeviationData(Id recordId){
        List<DeviationWraper> wrapList = new List<DeviationWraper>();
		List<Deviation__c> devList = new List<Deviation__c>();
		List<Deviation__c> devList2 = new List<Deviation__c>();
		Boolean nctFlagForT34 = false;
        Map<String, Set<String>> entityToDevTypeMap = new Map<String, Set<String>>();
        Map<String, String> devTypeToCategoryMap = new Map<String, String>();
        Set<String> productBA = new Set<String>();
        String oppMA=GlobalConstants.BLANK;Id proposalId;
        Schema.SObjectType objType=recordId.getSobjectType();
        Try{
        if(objType.getDescribe().getName().contains(GlobalConstants.Opportunity)) {
            Opportunity opp = [SELECT Id, Primary_Proposal__c from Opportunity where id =: recordId
                              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(opp.Primary_Proposal__c != null) {
                proposalId = opp.Primary_Proposal__c;
            }
        }else {
            proposalId=recordId;
        }
        for(Product__c propProd : [SELECT Id, Business_Area__c, Proposal__c, Proposal__r.Cash_Flow_Status__c, 
                                   Proposal__r.Contract_Evaluation_Status__c, Proposal__r.NonDelAndComplexAndNewTechStatus__c
                                   FROM Product__c 
                                   WHERE Proposal__c =: proposalId
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            productBA.add(propProd.Business_Area__c);                             
        }
        /*devList = [SELECT ID, ApprovingUnit__c,Proposal__r.CountOfNCTDeviations__c,Product_Group__c,Tier__c, DeviationSubcategory__c, toLabel(DeviationType__c), Proposal__r.CountPassiveAntenna__c, Proposal__r.Opportunity__r.MarketArea__c
                                FROM Deviation__c WHERE Proposal__c =: proposalId
                               AND ApprovingUnit__c != null AND DeviationType__c != null order by ApprovingUnit__c,DeviationSubcategory__c ];*/
        
        for(Deviation__c dev : [SELECT ID, ApprovingUnit__c,Proposal__r.CountOfNCTDeviations__c,Product_Group__c,Tier__c, DeviationSubcategory__c, 
                                toLabel(DeviationType__c), Proposal__r.CountPassiveAntenna__c, Proposal__r.Opportunity__r.MarketArea__c 
                                FROM Deviation__c 
                                WHERE Proposal__c =: proposalId AND ApprovingUnit__c != null AND DeviationType__c != null 
                                order by ApprovingUnit__c,DeviationSubcategory__c 
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())	]){
            if(dev.Proposal__r.CountOfNCTDeviations__c ==0){
                if((dev.Proposal__r.CountPassiveAntenna__c == 0) &&
                   (dev.Tier__c == GlobalConstants.Tier_3 || dev.Tier__c == GlobalConstants.Tier_4))
            {
			nctFlagForT34 = true;    
            }
            }
            
        }
			for(Deviation__c dev : devList){				   
            devTypeToCategoryMap.put(dev.DeviationType__c, dev.DeviationSubcategory__c);                     
            if(!entityToDevTypeMap.containsKey(dev.ApprovingUnit__c)) {
                entityToDevTypeMap.put(dev.ApprovingUnit__c, new Set<String>());                    
            }
            entityToDevTypeMap.get(dev.ApprovingUnit__c).add(dev.DeviationType__c);   
            oppMA=dev.Proposal__r.Opportunity__r.MarketArea__c;
        }
        for(String entity : entityToDevTypeMap.keySet()) {
            for(String devtype : entityToDevTypeMap.get(entity)) {
               DeviationWraper wrap = new DeviationWraper();
                wrap.deviationType = devtype;
                wrap.entity=entity;
                wrap.deviationSubCategory = devTypeToCategoryMap.get(devtype);
                wrapList.add(wrap);
                /* wrapList.add(new DeviationWraper(
                deviationType = devtype,
                entity=entity,
                deviationSubCategory = devTypeToCategoryMap.get(devtype)));*/
            }
        }
        if(!entityToDevTypeMap.containsKey(GlobalConstants.BNEW) || nctFlagForT34) {
            DeviationWraper wrap = new DeviationWraper();
            if(productBA.contains(GlobalConstants.BNEW)) {
                wrap.deviationType = GlobalConstants.NODEVIATION;
            }else {
                wrap.deviationType = GlobalConstants.NOTAPPLICABLE;
            }
            wrap.entity=GlobalConstants.BNEW;
            wrapList.add(wrap);
        }
        if(!entityToDevTypeMap.containsKey(GlobalConstants.BMAS) || nctFlagForT34) {
            DeviationWraper wrap = new DeviationWraper();
            if(productBA.contains(GlobalConstants.BMAS)) {
                wrap.deviationType = GlobalConstants.NODEVIATION;
            }else {
                wrap.deviationType = GlobalConstants.NOTAPPLICABLE;
            }
            wrap.entity=GlobalConstants.BMAS;
            wrapList.add(wrap);
        }
        if(!entityToDevTypeMap.containsKey(GlobalConstants.BDGS) || nctFlagForT34) {
            DeviationWraper wrap = new DeviationWraper();
            if(productBA.contains(GlobalConstants.BDGS)) {
                wrap.deviationType = GlobalConstants.NODEVIATION;
            }else {
                wrap.deviationType = GlobalConstants.NOTAPPLICABLE;
            }
            wrap.entity=GlobalConstants.BDGS;
            wrapList.add(wrap);
        }
        if(!entityToDevTypeMap.containsKey(GlobalConstants.BTEB) || nctFlagForT34) {
            DeviationWraper wrap = new DeviationWraper();
            if(productBA.contains(GlobalConstants.BTEB)) {
                wrap.deviationType = GlobalConstants.NODEVIATION;
            }else {
                wrap.deviationType = GlobalConstants.NOTAPPLICABLE;
            }
            wrap.entity=GlobalConstants.BTEB;
            wrapList.add(wrap);
        }
        if(oppMA!=GlobalConstants.BLANK && oppMA!=null && !entityToDevTypeMap.containsKey(oppMA)) {
            DeviationWraper wrap = new DeviationWraper();
            if(productBA.contains(oppMA)) {
                wrap.deviationType = GlobalConstants.NODEVIATION;
            }else {
                wrap.deviationType = GlobalConstants.NOTAPPLICABLE;
            }
            wrap.entity=oppMA;
            wrapList.add(wrap);
        }
        if((oppMA==GlobalConstants.BLANK || oppMA==null) && !entityToDevTypeMap.containsKey(GlobalConstants.GCU)) {
            DeviationWraper wrap = new DeviationWraper();
            if(productBA.contains(GlobalConstants.GCU)) {
                wrap.deviationType = GlobalConstants.NODEVIATION;
            }else {
                wrap.deviationType = GlobalConstants.NOTAPPLICABLE;
            }
            wrap.entity=GlobalConstants.GCU;
            wrapList.add(wrap);
        }
		if(!nctFlagForT34)
        {return wrapList;}
        else for(Integer i = wrapList.size() - 1; i >= 0; --i){
            DeviationWraper wrap = wrapList[i];
            if((wrap.entity == GlobalConstants.BDGS || wrap.entity == GlobalConstants.BMAS || wrap.entity == GlobalConstants.BNEW) && (wrap.deviationType != GlobalConstants.NODEVIATION && wrap.deviationType != GlobalConstants.NOTAPPLICABLE )) {
                wraplist.remove(i);
            }
        }
        }
        catch(Exception e){	 }
        return wrapList;
    }
    
    // wrapper class  
    public class DeviationWraper{
        @AuraEnabled public String entity{get;set;}
        @AuraEnabled public String deviationType{get;set;}
        @AuraEnabled public String deviationSubCategory{get;set;}
    }
    public static Deviation__c createMARecord(Proposal__c inbProposal, Opportunity existingSFOpp, 
                                              String pdGrpName, String pdGrpBusinessArea, String pdGrpEscalationLevel, String deviationType) {
                                                  Deviation__c deviation = new Deviation__c();
                                                  Try{ deviation.Proposal__c = inbProposal.Id;
                                                      deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                      deviation.DeviationType__c = deviationType;
													  deviation.CreatedBySalesforce__c = true;
                                                      if(!String.isBlank(pdGrpName))deviation.Product_Group__c = pdGrpName;
                                                      if(!String.isBlank(pdGrpBusinessArea))deviation.BusinessArea__c = pdGrpBusinessArea;
                                                      if(!String.isBlank(pdGrpEscalationLevel))deviation.EscalationLevel__c = pdGrpEscalationLevel;
                                                      if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                                                                     }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                     }
                                                  catch(Exception e){		}
                                                  return deviation;
                                              }
}