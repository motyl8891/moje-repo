/****************************************************************
* @author: Anukriti Agrawal
* @date: 04-03-2020
* @User Story: 1581
* @description: This class will set Deviation Types based on Proposal's Deviation Values.
*****************************************************************/
public class DeviationTypeUtility {
    /****************************************************************
* @author: Anukriti Agrawal/Pallavi Patil/Biswajit Sahoo
* @date: 13-08-2020
* @User Story: 1581/1741
* @description: This method will set Deviation Types based on Proposal's Deviation Values.
*****************************************************************/
    @future
    public static void createDevTypes (ID propID, Boolean isPilot){
        try{
            Map<String, Set<String>> entityToDevTypeMap = new Map<String, Set<String>>();
            Map<String, Deviation_Approval_Data__c> devApproval = Deviation_Approval_Data__c.getAll();
            Map<String, List<Deviation_Approval_Data__c>> keyToDevListMap = new Map<String, List<Deviation_Approval_Data__c>>();
            List<Deviation__c> devList = new List<Deviation__c>();
            Set<String> productBA = new Set<String>();
            String oppMA = GlobalConstants.BLANK;
            String oppLeadDomain = GlobalConstants.BLANK;
            Integer overAllEBDPropStatusCount= 0;
            List<DeviationTypeGroup__c> threshold2Dev = new List<DeviationTypeGroup__c>();
            List<DeviationTypeGroup__c> threshold1Dev = new List<DeviationTypeGroup__c>();
            Set<String> productList = new Set<String>();
            Set<String> bmasProductSet = new Set<String>();
           	Set<String> devProductSet = new Set<String>();
            Integer countBMASProd = 0;
            Integer countAllProd = 0;
            Integer countAllDevProd = 0;
            Boolean IsSSPCheck =false;
            Boolean IsNetCheck =false;
            Boolean IsEffectiveNetCheck =false;
            Boolean IsAAPCheck =false;
            /*if(test.isRunningTest())
            {
                isPilot = true;
            }*/
            if(isPilot )
            { /*U-2173  START */
                For(Product__c pd : [SELECT Id,Business_Area__c,name,Product_Group__c FROM Product__c 
                                     WHERE Proposal__c =: propID and Product_Group__c != ''])
                {                    
                    if(pd.Business_Area__c.equalsIgnoreCase(GlobalConstants.BMAS) && !bmasProductSet.contains(pd.Product_Group__c))
                    {
                        countBMASProd = countBMASProd +1;
                        bmasProductSet.add(pd.Product_Group__c);
                    }
                    if(!productList.contains(pd.Product_Group__c))
                    {
                        countAllProd = countAllProd + 1;
                        productList.add(pd.Product_Group__c);
                    }
                    
                }   
                /* FINISH*/
                For(Deviation__c dev : [Select Name,ApprovingUnit__c,BusinessArea__c,DeviationCategory__c,Proposal__r.Opportunity__r.MarketArea__c,DeviationSubcategory__c,DeviationType__c,
                                        Proposal__r.Opportunity__r.Lead_Domain__c,Tier__c,EscalationLevel__c, AAPriceObjectEscalationLevel__c, EffectiveNetDeviationEscalationLevel__c,
                                        NetDeviationEscalationLevel__c,SSPSEscalationLevel__c,DeviationTypeGroup__r.BADeviationType__c, Product_Group__c, IsdeviationfromEBD__c,Proposal__r.Overall_EBD_Approval_Status__c
                                        ,CreatedBySalesforce__c
                                        FROM Deviation__c
                                        WHERE Proposal__c =: propID Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                    
                {
                    
                    if(!entityToDevTypeMap.containsKey(dev.ApprovingUnit__c)) {
                        entityToDevTypeMap.put(dev.ApprovingUnit__c, new Set<String>());
                    }
                    entityToDevTypeMap.get(dev.ApprovingUnit__c).add(dev.DeviationType__c);
                    if(dev.DeviationType__c != NULL && dev.BusinessArea__c != NULL&& (dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.DEVIATIONTYPE_ProfitabilityUM) || dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.UMAR)) &&
                      dev.BusinessArea__c.containsIgnoreCase(GlobalConstants.BMAS) && 
          			 !devProductSet.contains(dev.Product_Group__c))
                    {
                        countAllDevProd = countAllDevProd+1;
                        devProductSet.add(dev.Product_Group__c);
                    }
                    devList.add(dev);
                    
                    oppMA=dev.Proposal__r.Opportunity__r.MarketArea__c;
                    oppLeadDomain = dev.Proposal__r.Opportunity__r.Lead_Domain__c;
                }
                for(Deviation_Approval_Data__c ApprovalData : devApproval.values())
                {
                    if(!keyToDevListMap.containsKey(ApprovalData.Matching_Key__c))
                    {
                        keyToDevListMap.put(ApprovalData.Matching_Key__c, new List<Deviation_Approval_Data__c>());
                    }
                    keyToDevListMap.get(ApprovalData.Matching_Key__c).add(ApprovalData);
                }
                boolean isValid=false;
                boolean isDevTypeExists=true;
                boolean isProductGroupExists=false;
                Map<String, DeviationTypeGroup__c> uniqueDevMap = new Map<String, DeviationTypeGroup__c>();
                Map<String,DeviationTypeGroup__c> keydevTypeMap = new Map<String,DeviationTypeGroup__c>();
                Map<String,DeviationTypeGroup__c> key2devTypeMap = new Map<String,DeviationTypeGroup__c>();
                For(Deviation__c dev : devList)
                {
                    isValid=false;
                    DeviationTypeGroup__c devType = new DeviationTypeGroup__c();
                    devType.ApprovingUnit__c = oppMA;
                    //devType.ProductGroup__c = dev.Product_Group__c;
                    devType.Proposal__c = dev.Proposal__c;
                    devType.BusinessArea__c = dev.BusinessArea__c;
                    devType.DeviationType__c = dev.DeviationType__c;
                    devType.EscalationLevel__c = dev.EscalationLevel__c;
                    devType.AAPriceObjectEscalationLevel__c = dev.AAPriceObjectEscalationLevel__c;
                    devType.EffectiveNetDeviationEscalationLevel__c = dev.EffectiveNetDeviationEscalationLevel__c;
                    devType.NetDeviationEscalationLevel__c = dev.NetDeviationEscalationLevel__c;
                    devType.SSPSEscalationLevel__c = dev.SSPSEscalationLevel__c;
                    devType.IsdeviationfromEBD__c = dev.IsdeviationfromEBD__c;
                    String key2= GlobalConstants.BLANK;
                    String key3= GlobalConstants.BLANK;
                    String key4= GlobalConstants.BLANK;
                    DeviationTypeGroup__c devTypes = new DeviationTypeGroup__c();
                    if(dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_1) ||
                       dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_2) ||
                       (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_3)) ||
                       (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_4))) {
                           String key=GlobalConstants.BLANK;
                           if(!String.IsBlank(dev.DeviationType__c) && String.IsBlank(dev.BusinessArea__c)) {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.HASH+dev.Tier__c;
                           }
                           if( !String.IsBlank(dev.DeviationType__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && !String.IsBlank(dev.IsdeviationfromEBD__c) && dev.IsdeviationfromEBD__c.equalsIgnoreCase(GlobalConstants.UpperCase_TRUE))  {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.TRUEHASH+dev.Tier__c;
                           }
                           //U-2173 Start
                           if( !String.IsBlank(dev.DeviationType__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTCMS) && oppMA.equalsIgnoreCase(GlobalConstants.MELA) &&productList.contains(GlobalConstants.IT_MS_ADM) && countBMASProd == 1  && dev.IsdeviationfromEBD__c == NULL)  {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.IT + GlobalConstants.HASH+dev.Tier__c;
                           }
                           if( !String.IsBlank(dev.DeviationType__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTCMS) && oppMA.equalsIgnoreCase(GlobalConstants.MELA) &&productList.contains(GlobalConstants.IT_MS_ADM)&& countBMASProd > 1  && dev.IsdeviationfromEBD__c == NULL)  {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.ITS + GlobalConstants.HASH+dev.Tier__c;
                           }
                           System.debug('##'+dev.DeviationType__c+oppMA+productList+oppLeadDomain+ dev.IsdeviationfromEBD__c);
                           if(!String.IsBlank(dev.DeviationType__c) && oppMA.equalsIgnoreCase(GlobalConstants.MELA) && !productList.contains(GlobalConstants.IT_MS_ADM) && oppLeadDomain.equalsIgnoreCase(GlobalConstants.BDGS) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && dev.IsdeviationfromEBD__c == NULL )
                           {
                               key  = oppMA+GlobalConstants.HASH+dev.DeviationType__c+ GlobalConstants.BDGSHASH + dev.Tier__c;
                           }
                           if(!String.IsBlank(dev.DeviationType__c) && oppMA.equalsIgnoreCase(GlobalConstants.MELA) && !productList.contains(GlobalConstants.IT_MS_ADM) && oppLeadDomain.equalsIgnoreCase(GlobalConstants.BNEW) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && dev.IsdeviationfromEBD__c == NULL)
                           {
                               key  = oppMA+GlobalConstants.HASH+dev.DeviationType__c+ GlobalConstants.BNEWHASH + dev.Tier__c;
                           }
                           if(!String.IsBlank(dev.DeviationType__c) && oppMA.equalsIgnoreCase(GlobalConstants.MELA) && !productList.contains(GlobalConstants.IT_MS_ADM) && oppLeadDomain.equalsIgnoreCase(GlobalConstants.BMAS) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && dev.IsdeviationfromEBD__c == NULL)
                           {
                               key  = oppMA+GlobalConstants.HASH+dev.DeviationType__c+ GlobalConstants.BMASHASH + dev.Tier__c;
                           }
                           if( !String.IsBlank(dev.DeviationType__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) &&oppMA.equalsIgnoreCase(GlobalConstants.MELA) && productList.contains(GlobalConstants.IT_MS_ADM) && countAllProd == 1 && String.IsBlank(dev.BusinessArea__c) && dev.IsdeviationfromEBD__c == NULL)  {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.IT + GlobalConstants.HASH+dev.Tier__c;
                           }
                           if( !String.IsBlank(dev.DeviationType__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && oppMA.equalsIgnoreCase(GlobalConstants.MELA) && productList.contains(GlobalConstants.IT_MS_ADM) && countAllProd > 1 && String.IsBlank(dev.BusinessArea__c) && dev.IsdeviationfromEBD__c == NULL)  {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.ITS + GlobalConstants.HASH+dev.Tier__c;
                           }
                           // FINISH
                           
                           if(!String.IsBlank(dev.DeviationType__c) && !String.IsBlank(dev.BusinessArea__c)) {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.HASH+dev.BusinessArea__c+GlobalConstants.HASH+dev.Tier__c;
                           }
                           if(!String.IsBlank(dev.DeviationType__c) && !String.IsBlank(dev.BusinessArea__c) && dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BDGS) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.Comparison_Price) &&  dev.SSPSEscalationLevel__c!= NULL && (dev.SSPSEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_1) || dev.SSPSEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_2)))
                           {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.HASHSSP+ dev.BusinessArea__c+GlobalConstants.HASH+dev.Tier__c;
                                 IsSSPCheck =true;

                           }
                           //D-3425 Changes
                           if(!String.IsBlank(dev.DeviationType__c) &&  !String.IsBlank(dev.BusinessArea__c) &&  oppMA.equalsIgnoreCase(GlobalConstants.MELA) &&  devProductSet.contains(GlobalConstants.IT_MS_ADM) && countAllDevProd == 1 &&dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BMAS) && (dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.UMAR) ||dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.DEVIATIONTYPE_ProfitabilityUM)) )
                           {
                               key = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.HASH + dev.BusinessArea__c+ GlobalConstants.IT+GlobalConstants.HASH+dev.Tier__c;
                           }
                           // D-3425 Done
                           if(keyToDevListMap.containsKey(key))
                           {
                               list<Deviation_Approval_Data__c> applist = keyToDevListMap.get(key);
                               applist.sort();
                               
                               devTypes = createDevType(applist,devType,dev,isValid,isProductGroupExists, oppMA,productList,propId,overAllEBDPropStatusCount,devProductSet);
                           }
                       }
                    
                    if(devTypes.DeviationType__c != null && !String.IsBlank(devTypes.BusinessArea__c) && !devTypes.DeviationType__c.equalsIgnoreCase(GlobalConstants.BCTC) && !devTypes.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && (devTypes.AAPriceObjectEscalationLevel__c != null || devTypes.EffectiveNetDeviationEscalationLevel__c != null ||devTypes.NetDeviationEscalationLevel__c != null || devTypes.SSPSEscalationLevel__c != null || devTypes.EscalationLevel__c != null)) {
                        String uniqueKey = devTypes.ApprovingUnit__c+GlobalConstants.ampersand+devTypes.BADeviationType__c+GlobalConstants.ampersand+devTypes.ApproverGroup1__c+GlobalConstants.ampersand+devTypes.ApproverGroup2__c;
                        if(devTypes.BADeviationType__c != null && !keydevTypeMap.containsKey(uniqueKey) && !uniqueDevMap.containsKey(uniqueKey))
                            uniqueDevMap.put(uniqueKey, devTypes);
                        if(devTypes.ApprovingUnit__c.contains(GlobalConstants.SLASH) ) {
                            threshold2Dev.add(devTypes);
                        }
                    }
                    if(devTypes.DeviationType__c != null  && (dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.BCTC) || dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) || dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.ND)|| dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.NCT) || dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.DEVIATIONTYPE_ProfitabilityUM) || dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTCMS))) {
                        String uniqueKey = devTypes.ApprovingUnit__c+GlobalConstants.ampersand+devTypes.BADeviationType__c+GlobalConstants.ampersand+devTypes.ApproverGroup1__c+GlobalConstants.ampersand+devTypes.ApproverGroup2__c;
                        if(devTypes.BADeviationType__c != null && !keydevTypeMap.containsKey(uniqueKey) && !uniqueDevMap.containsKey(uniqueKey))
                            uniqueDevMap.put(uniqueKey, devTypes);
                        if(devTypes.ApprovingUnit__c.contains(GlobalConstants.SLASH) ) {
                            threshold2Dev.add(devTypes);
                        }}
                    if(dev.DeviationType__c != null && !String.IsBlank(dev.BusinessArea__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.Comparison_Price) && ((dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_3)) ||(dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_4)) ||(dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_1)) || (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_2))) && dev.NetDeviationEscalationLevel__c!= NULL && (dev.NetDeviationEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_1) || dev.NetDeviationEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_2)) && (dev.EffectiveNetDeviationEscalationLevel__c!= NULL || dev.SSPSEscalationLevel__c != NULL || dev.AAPriceObjectEscalationLevel__c != NULL)
                      )
                    {
                        IsNetCheck = true;
                        key2 = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.HASHNet+ dev.BusinessArea__c+GlobalConstants.HASH+dev.Tier__c;
                        isValid=false;
                        DeviationTypeGroup__c devType1 = new DeviationTypeGroup__c();
                        devType1.ApprovingUnit__c = oppMA;
                        devType1.Proposal__c = dev.Proposal__c;
                        devType1.BusinessArea__c = dev.BusinessArea__c;
                        devType1.DeviationType__c = dev.DeviationType__c;
                        //devType1.ProductGroup__c = dev.Product_Group__c;
                        devType1.EscalationLevel__c = dev.EscalationLevel__c;
                        devType1.AAPriceObjectEscalationLevel__c = dev.AAPriceObjectEscalationLevel__c;
                        devType1.EffectiveNetDeviationEscalationLevel__c = dev.EffectiveNetDeviationEscalationLevel__c;
                        devType1.NetDeviationEscalationLevel__c = dev.NetDeviationEscalationLevel__c;
                        devType1.SSPSEscalationLevel__c = dev.SSPSEscalationLevel__c;
                        devType1.IsdeviationfromEBD__c = dev.IsdeviationfromEBD__c;
                        
                        DeviationTypeGroup__c devTypes1 = createDevType(keyToDevListMap.get(key2),devType1,dev,isValid,isProductGroupExists, oppMA,productList,propId,overAllEBDPropStatusCount,devProductSet);
                        if(devTypes1.DeviationType__c != null  && devTypes1.BusinessArea__c != NULL && !devTypes1.DeviationType__c.equalsIgnoreCase(GlobalConstants.BCTC) && !devTypes1.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && (devTypes1.AAPriceObjectEscalationLevel__c != null || devTypes1.EffectiveNetDeviationEscalationLevel__c != null ||devTypes1.NetDeviationEscalationLevel__c != null || devTypes1.SSPSEscalationLevel__c != null || devTypes1.EscalationLevel__c != null)) {
                            String uniqueKey = devTypes1.ApprovingUnit__c+GlobalConstants.ampersand+devTypes1.BADeviationType__c+GlobalConstants.ampersand+devTypes1.ApproverGroup1__c+GlobalConstants.ampersand+devTypes1.ApproverGroup2__c;
                            if(devTypes1.BADeviationType__c != null && !keydevTypeMap.containsKey(uniqueKey) && !uniqueDevMap.containsKey(uniqueKey))
                                keydevTypeMap.put(uniqueKey,devTypes1);
                        }
                        if(devTypes1.ApprovingUnit__c.contains(GlobalConstants.SLASH) ) {
                            threshold2Dev.add(devTypes1);
                        }
                    }
                    if(dev.DeviationType__c != null && !String.IsBlank(dev.BusinessArea__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.Comparison_Price) && ((dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_3)) ||(dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_4)) ||(dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_1)) || (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_2)) ) && dev.EffectiveNetDeviationEscalationLevel__c!= NULL && (dev.EffectiveNetDeviationEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_1) || dev.EffectiveNetDeviationEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_2))&& (dev.SSPSEscalationLevel__c != NULL || dev.AAPriceObjectEscalationLevel__c != NULL))
                    {
                        IsEffectiveNetCheck = true;
                        key3 = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.HASHEffective+ dev.BusinessArea__c+GlobalConstants.HASH+dev.Tier__c;
                        isValid=false;
                        DeviationTypeGroup__c devType2 = new DeviationTypeGroup__c();
                        devType2.ApprovingUnit__c = oppMA;
                        devType2.Proposal__c = dev.Proposal__c;
                        devType2.BusinessArea__c = dev.BusinessArea__c;
                        devType2.DeviationType__c = dev.DeviationType__c;
                        //devType2.ProductGroup__c = dev.Product_Group__c;
                        devType2.EscalationLevel__c = dev.EscalationLevel__c;
                        devType2.AAPriceObjectEscalationLevel__c = dev.AAPriceObjectEscalationLevel__c;
                        devType2.EffectiveNetDeviationEscalationLevel__c = dev.EffectiveNetDeviationEscalationLevel__c;
                        devType2.NetDeviationEscalationLevel__c = dev.NetDeviationEscalationLevel__c;
                        devType2.SSPSEscalationLevel__c = dev.SSPSEscalationLevel__c;
                        devType2.IsdeviationfromEBD__c = dev.IsdeviationfromEBD__c;
                        DeviationTypeGroup__c devTypes2 = createDevType(keyToDevListMap.get(key3),devType2,dev,isValid,isProductGroupExists, oppMA,productList,propId,overAllEBDPropStatusCount,devProductSet);
                        if(devTypes2.DeviationType__c != null  && devTypes2.BusinessArea__c != NULL && !devType2.DeviationType__c.equalsIgnoreCase(GlobalConstants.BCTC) && !devType2.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && (devTypes2.AAPriceObjectEscalationLevel__c != null || devTypes2.EffectiveNetDeviationEscalationLevel__c != null || devTypes2.NetDeviationEscalationLevel__c != null || devTypes2.SSPSEscalationLevel__c != null || devTypes2.EscalationLevel__c != null)) {
                            String uniqueKey = devTypes2.ApprovingUnit__c+GlobalConstants.ampersand+devTypes2.BADeviationType__c+GlobalConstants.ampersand+devTypes2.ApproverGroup1__c+GlobalConstants.ampersand+devTypes2.ApproverGroup2__c;
                            if(devTypes2.BADeviationType__c != null && !keydevTypeMap.containsKey(uniqueKey) && !uniqueDevMap.containsKey(uniqueKey))
                                keydevTypeMap.put(uniqueKey,devTypes2);
                        }
                        if(devTypes2.ApprovingUnit__c.contains(GlobalConstants.SLASH) ) {
                            threshold2Dev.add(devTypes2);
                        }
                        
                    }
                    if(dev.DeviationType__c != null && !String.IsBlank(dev.BusinessArea__c) && dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.Comparison_Price) && (dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BNEW) || dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BMAS)) &&((dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_3)) ||(dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_4)) ||(dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_1)) || (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_2))) &&dev.AAPriceObjectEscalationLevel__c!= NULL && (dev.AAPriceObjectEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_1) || dev.AAPriceObjectEscalationLevel__c.equalsIgnoreCase(GlobalConstants.Threshold_2)) &&dev.SSPSEscalationLevel__c != NULL)
                    {
                        IsAAPCheck = true;
                        key4 = oppMA+GlobalConstants.HASH+dev.DeviationType__c+GlobalConstants.HASHAAP+ dev.BusinessArea__c+GlobalConstants.HASH+dev.Tier__c;
                        isValid=false;
                        DeviationTypeGroup__c devType3 = new DeviationTypeGroup__c();
                        devType3.ApprovingUnit__c = oppMA;
                        devType3.Proposal__c = dev.Proposal__c;
                        devType3.BusinessArea__c = dev.BusinessArea__c;
                        devType3.DeviationType__c = dev.DeviationType__c;
                        //devType3.ProductGroup__c = dev.Product_Group__c;
                        devType3.EscalationLevel__c = dev.EscalationLevel__c;
                        devType3.AAPriceObjectEscalationLevel__c = dev.AAPriceObjectEscalationLevel__c;
                        devType3.EffectiveNetDeviationEscalationLevel__c = dev.EffectiveNetDeviationEscalationLevel__c;
                        devType3.NetDeviationEscalationLevel__c = dev.NetDeviationEscalationLevel__c;
                        devType3.SSPSEscalationLevel__c = dev.SSPSEscalationLevel__c;
                        devType3.IsdeviationfromEBD__c = dev.IsdeviationfromEBD__c;
                        
                        DeviationTypeGroup__c devTypes3 = createDevType(keyToDevListMap.get(key2),devType3,dev,isValid,isProductGroupExists, oppMA,productList,propId,overAllEBDPropStatusCount,devProductSet);
                        if(devTypes3.DeviationType__c != null && devTypes3.BusinessArea__c != NULL && !devType3.DeviationType__c.equalsIgnoreCase(GlobalConstants.BCTC) && !devType3.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC) && (devTypes3.AAPriceObjectEscalationLevel__c != null || devTypes3.EffectiveNetDeviationEscalationLevel__c != null || devTypes3.NetDeviationEscalationLevel__c != null || devTypes3.SSPSEscalationLevel__c != null || devTypes3.EscalationLevel__c != null)) {
                            String uniqueKey = devTypes3.ApprovingUnit__c+GlobalConstants.ampersand+devTypes3.BADeviationType__c+GlobalConstants.ampersand+devTypes3.ApproverGroup1__c+GlobalConstants.ampersand+devTypes3.ApproverGroup2__c;
                            if(devTypes3.BADeviationType__c != null && !keydevTypeMap.containsKey(uniqueKey) && !uniqueDevMap.containsKey(uniqueKey))
                                keydevTypeMap.put(uniqueKey,devTypes3);
                        }
                        if(devTypes3.ApprovingUnit__c.contains(GlobalConstants.SLASH) ) {
                            threshold2Dev.add(devTypes3);
                        }
                    }
                }
                List<DeviationTypeGroup__c> devTypeList = new List<DeviationTypeGroup__c>();
                if(!uniqueDevMap.isEmpty())
                    database.insert(uniqueDevMap.values());
                
                if(!keydevTypeMap.IsEmpty())
                    database.insert(keydevTypeMap.values());
                
                devTypeList.addAll(uniqueDevMap.values());
                 devTypeList.addAll(keydevTypeMap.values());
                    
                for(DeviationTypeGroup__c dev:devTypeList) {
                    if(!dev.ApprovingUnit__c.containsIgnoreCase(GlobalConstants.SLASH)) {
                        threshold1Dev.add(dev);  }
                }
                //U-2120
                List<DeviationTypeGroup__c> finalDevTypeList = new List<DeviationTypeGroup__c>();
				List<DeviationTypeGroup__c> finalkeyDevTypeList = new List<DeviationTypeGroup__c>();
                List<Deviation__c> devToUpdateList = new List<Deviation__c>();
				Map<Id,Deviation__c> devToUpdateBDGSMap = new Map<Id,Deviation__c>();
                finalDevTypeList.addAll(uniqueDevMap.values());
                finalDevTypeList.addAll(devTypeList);
                finalkeyDevTypeList.addAll(keydevTypeMap.values());
                Set<DeviationTypeGroup__c> toDeleteDevGrpSet = new Set<DeviationTypeGroup__c>();
                for(DeviationTypeGroup__c dev2 : threshold2Dev) {
                    for(DeviationTypeGroup__c dev1 : threshold1Dev) {
                        if(dev1.DeviationType__c == dev2.DeviationType__c && dev1.BusinessArea__c == dev2.BusinessArea__c ) {
                            toDeleteDevGrpSet.add(dev1); 
                            if(finalDevTypeList.indexOf(dev1) != -1){
                           	Integer result = finalDevTypeList.indexOf(dev1);
                        	finalDevTypeList.remove(result);
							if(finalkeyDevTypeList.indexOf(dev1) != -1){
                           	Integer result1 = finalkeyDevTypeList.indexOf(dev1);
                        	finalkeyDevTypeList.remove(result1);}
                             }}}
                }
				
                for(Deviation__c dev : devList)
                {   if (!dev.CreatedBySalesforce__c){
                    for(DeviationTypeGroup__c devType : finalDevTypeList)
                         {
                        if(dev.DeviationType__c == devType.DeviationType__c && dev.BusinessArea__c == devType.BusinessArea__c && dev.DeviationType__c != 'EBDTC' && devType.BADeviationType__c != 'BDGS - Software Subscription' && devType.BADeviationType__c != 'BDGS - Comparison Price' && devType.BADeviationType__c != 'BDGS-Comparison Price - MELA Effective Net Price')
                        {
                            if(devType.Id != null) {
                                dev.DeviationTypeGroup__c = devType.Id;
                            }                            
                            devToUpdateList.add(dev); 
                            break;
                        }
                             if(devType.Id != null && dev.DeviationType__c == 'EBDTC' && devType.BADeviationType__c == 'EBD T&C')
                             {
                                 dev.DeviationTypeGroup__c = devType.Id;
                                 system.debug('dev.DeviationTypeGroup__c305***'+devType.BADeviationType__c);
                                 devToUpdateList.add(dev);
                                 break;
                             }
                             else if(devType.Id != null && dev.DeviationType__c == 'EBDTC' && devType.BADeviationType__c.contains('Cashflow') && dev.IsdeviationfromEBD__c == 'true' && devType.IsdeviationfromEBD__c == 'true')
                             {
                                 dev.DeviationTypeGroup__c = devType.Id;
                                 system.debug('dev.DeviationTypeGroup__c305***'+devType.BADeviationType__c);
                                 devToUpdateList.add(dev);
                                 break;
                             }
                             if(devType.Id != null  && dev.SSPSEscalationLevel__c!= NULL &&( dev.EffectiveNetDeviationEscalationLevel__c== NULL || dev.NetDeviationEscalationLevel__c== NULL || dev.AAPriceObjectEscalationLevel__c== NULL)
                            && dev.BusinessArea__c == devType.BusinessArea__c && dev.DeviationType__c == 'Comparison Price' && dev.BusinessArea__c == 'BDGS')
                        {
                             if(devType.BADeviationType__c == 'BDGS - Software Subscription' ){
                            dev.DeviationTypeGroup__c = devType.Id;
                            }
							devToUpdateList.add(dev);
                            break;
                        } }  }  }
						for(Deviation__c dev1 : devList)
                {
                    if (!dev1.CreatedBySalesforce__c){
                        for(DeviationTypeGroup__c devType : finalkeyDevTypeList)
                         {
                             system.debug('devType.BADEVIATION' + devType.BADeviationType__c);
                             if(devType.Id != null && (dev1.EffectiveNetDeviationEscalationLevel__c!= NULL || dev1.NetDeviationEscalationLevel__c!= NULL|| dev1.AAPriceObjectEscalationLevel__c != NULL) &&
                               dev1.DeviationType__c.equalsIgnoreCase(GlobalConstants.Comparison_Price) && dev1.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BDGS))
                             {
                                 if(devType.BADeviationType__c.equalsIgnoreCase(GlobalConstants.BDGS_Comparison)){
								dev1.BDGSComparisonPriceDTG__c = devType.Id;	
                                 }
                                 if(devType.BADeviationType__c.equalsIgnoreCase(GlobalConstants.BDGS_Comparison_MELA_Effective_Net_Price)){
                                     dev1.MELANetEffectiveDeviationTypeGroup__c = devType.Id;
                                 }
                                devToUpdateBDGSMap.put(dev1.Id,dev1); 
                                 
                             }}}}
                        
                 if(!devToUpdateList.isEmpty()){
                    database.update(devToUpdateList);
                }
				if(!devToUpdateBDGSMap.isEmpty()){
                    database.update(devToUpdateBDGSMap.values());
                }
                
                Proposal__c  prop = [select id, Overall_EBD_Approval_Status__c from proposal__c where id =: propId];
                if(finalDevTypeList.isEmpty()) {
                    prop.Overall_EBD_Approval_Status__c = GlobalConstants.NoDeviationsIdentified;
                }
             
                if(prop!=null){
                    database.update(prop);
                }
                 List<DeviationTypeGroup__c> toDeleteDevGrpList = new List<DeviationTypeGroup__c>();
                toDeleteDevGrpList.addAll(toDeleteDevGrpSet);
                Database.delete(toDeleteDevGrpList);
                
                /*if(Test.isRunningTest())
                {
                    Integer i = 5/0;
                }*/
            }
            
        }
        catch(Exception e) {
            system.debug('*******************Exception********************'+e);
            EventLog.createLog(new EventLog.Error(GlobalConstants.DeviationTypeUtility,
                                                  GlobalConstants.createDevTypes, GlobalConstants.DeviationTypeUtility, true, e));
        }
    }
    public static DeviationTypeGroup__c createDevType (List<Deviation_Approval_Data__c> applist,DeviationTypeGroup__c devType,Deviation__c dev, Boolean isValid,Boolean isProductGroupExists, String oppMA, Set<String> productList,String propId, Integer overAllEBDPropStatusCount,Set<String> devProductSet){
        try{
            
            for(Deviation_Approval_Data__c devData:applist){
                if(devType.get(devData.Salesforce_Field__c)!=null && devType.get(devData.Salesforce_Field__c)==devData.Field_Value__c) {
                    if(dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.DEVIATIONTYPE_COMPARISONPRICE)) {
                        if(dev.Product_Group__c!=null && (dev.Product_Group__c.containsIgnoreCase(GlobalConstants.ProductGroup_PassiveAntennaSystems) && (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_3) || dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_4)) && dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BNEW) ) ||   (dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BNEW)  && ((dev.Product_Group__c.containsIgnoreCase(GlobalConstants.TwoG_ThreeG_RAN_SW) ||dev.Product_Group__c.containsIgnoreCase(GlobalConstants.RAN_HW_AND_HWAC) ||dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Indoor)) && (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_1) || dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_2))))
                           ||(oppMA.equalsIgnoreCase(GlobalConstants.MELA)  && dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BDGS) && ( devType.get(devData.Salesforce_Field__c).equals(GlobalConstants.Threshold_2) )
                              && !devData.BADeviationType__c.equalsIgnoreCase(GlobalConstants.BDGS_Software_Subscription) &&  ((dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Communication_Services)||dev.Product_Group__c.containsIgnoreCase(GlobalConstants.User_Management)||dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Evolved_Pack_Core)) && (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_1) || dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_2)))))
                        {
                            isProductGroupExists = true;
                        }else {
                            isProductGroupExists = false;
                        }
                        
                    }else if(  dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.DEVIATIONTYPE_ProfitabilityUM) || dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.UMAR)) {
                        if(dev.Product_Group__c!=null && (dev.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BNEW) && (dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_3) || dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_4)) && 
                                                          (dev.Product_Group__c.containsIgnoreCase(GlobalConstants.ProductGroup_PassiveAntennaSystems) ||
                                                           dev.Product_Group__c.containsIgnoreCase(GlobalConstants.ThreePP_Passive_Antenna_Systems))) ||
                           (dev.BusinessArea__c.containsIgnoreCase(GlobalConstants.BNEW) &&
                            (dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_1) || dev.Tier__c.equalsIgnoreCase(GlobalConstants.Tier_2)) &&
                            (dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Other_RAN_HW) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Radio_Site) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Spare_Parts_Sales) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.WL_switching) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.CDMA_HW_SW) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.ThreePP_Support) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.NRO_Installation) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.NRO_In_house) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.NRO_SA_CW) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Network_Rollout_CISCO) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.NRO_CDMA) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.NRO_Fiber))) ||
                           (dev.BusinessArea__c.containsIgnoreCase(GlobalConstants.BDGS) &&  (dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_1)|| dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_2)) && ( dev.Product_Group__c.containsIgnoreCase(GlobalConstants.Consulting) ||
                             dev.Product_Group__c.containsIgnoreCase(GlobalConstants.System_Integration) ||dev.Product_Group__c.containsIgnoreCase(GlobalConstants.BDGS_Other))) ||
                           (dev.BusinessArea__c.containsIgnoreCase(GlobalConstants.BMAS) && (dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_1)|| dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_2) ||
                             dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_3)|| dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_4)) && devProductSet.contains(GlobalConstants.IT_MS_ADM) && oppMA.containsIgnoreCase(GlobalConstants.MELA))
                          ) {  isProductGroupExists = true;
                          }else {
                              isProductGroupExists = false;
                          } }
                    else if(dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTCMS))
                    {
                        if(!productList.IsEmpty() &&(dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_1)|| dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_2) ||
                            dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_3)|| dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_4)) && oppMA.containsIgnoreCase(GlobalConstants.MELA) && productList.contains(GlobalConstants.IT_MS_ADM))
                        {
                            isProductGroupExists = true;
                        }else {
                            isProductGroupExists = false;
                        }
                    }
                    else if(dev.DeviationType__c.equalsIgnoreCase(GlobalConstants.EBDTC))
                    {
                        if(!productList.IsEmpty() && (dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_1)|| dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_2) ||
                            dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_3)|| dev.Tier__c.containsIgnoreCase(GlobalConstants.Tier_4)) && oppMA.containsIgnoreCase(GlobalConstants.MELA) && productList.contains(GlobalConstants.IT_MS_ADM) && dev.IsdeviationfromEBD__c == NULL)
                        {
                            isProductGroupExists = true;
                        }else {
                            isProductGroupExists = false;
                        }
                    }
                    if(devdata.Include_Product_Groups__c==GlobalConstants.YES && isProductGroupExists){
                        isValid=true;
                    }
                    if(devdata.Include_Product_Groups__c== NULL && !isProductGroupExists) {
                        isValid=true;
                    }
                    if(isValid) {
                        devType.ApprovingUnit__c = devData.ApprovingUnit__c;
                        devType.BADeviationType__c = devData.BADeviationType__c;
                        if(devData.Active__c) {
                            devType.BA_Approver__c = devData.Approver_2_Name__c;
                            devType.MA_Approver__c = devData.Approver_1_Name__c;
                            If(!String.isBlank(devData.Approver_1_Name__c))
                                devType.MAStatus__c = GlobalConstants.To_be_Requested;
                            If(!String.isBlank(devData.Approver_2_Name__c))
                                devType.BAStatus__c = GlobalConstants.To_be_Requested;
                        }
                        break;
                    }
                }
            }
            
        }
        catch(Exception e) {EventLog.createLog(new EventLog.Error(GlobalConstants.DeviationTypeUtility,
                                                                  GlobalConstants.createDevType, GlobalConstants.DeviationTypeUtility, true, e));
                           }
        return devType;
    }
}