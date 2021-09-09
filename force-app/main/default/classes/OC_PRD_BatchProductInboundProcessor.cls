/**
* @File Name          : OC_PRD_BatchProductInboundProcessor
* @Description        : Batch class for Product inbound data processing which is called from OC_PRD_DesrializeInboundRequest and calls OC_PRD_InboundRequestHandler.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 26th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-26                 IBM                  U-2817 Initial Version
* 1.1        2021-07-09                 IBM                  U-3066 PRD SolutionNode Process
* 1.2        2021-07-14                 IBM                  U-3068 PRD NodeComponent Process
**/
public class OC_PRD_BatchProductInboundProcessor implements Database.batchable<Object>,Database.Stateful{ 
    String integrationIdentifier;
    Map<String,Object> productObjMapData=new Map<String,Object> ();
    String productType;
    List<Object> productDatalist=new List<Object>();
    String nextSequenceNode; 
    
    public OC_PRD_BatchProductInboundProcessor(String intIdentifier,Map<String,Object> productObjMap,String prdType,String nxtSeqNode){
        integrationIdentifier = intIdentifier; 
        productObjMapData=productObjMap;
        productType=prdType;
        nextSequenceNode=nxtSeqNode; 
    }
    public Iterable<Object> start(Database.BatchableContext BC){ 
        
        if(productObjMapData!=null && !productObjMapData.isEmpty() && String.isNotBlank(productType)){
            if(productType.equalsIgnoreCase(OC_IB_Constants.productNodeType) && productObjMapData.containsKey(OC_IB_Constants.extNodeTypes)) {
                productDatalist=(List<Object>)productObjMapData.get(OC_IB_Constants.extNodeTypes);
            }
            //U-3066 
            else if(productType.equalsIgnoreCase(OC_IB_Constants.productSolutionType) && productObjMapData.containsKey(OC_IB_Constants.extSolutions)){
                productDatalist=(List<Object>)productObjMapData.get(OC_IB_Constants.extSolutions);
            }
            //U-3068 
            else if(productType.equalsIgnoreCase(OC_IB_Constants.productNodeComponentType) && productObjMapData.containsKey(OC_IB_Constants.extNodeComponents)){
                productDatalist=(List<Object>)productObjMapData.get(OC_IB_Constants.extNodeComponents);
            }
            //U-3066 
            else if(productType.equalsIgnoreCase(OC_IB_Constants.nodeTypeSolution) && productObjMapData.containsKey(OC_IB_Constants.extNodeTypeSolution)){
                productDatalist=(List<Object>)productObjMapData.get(OC_IB_Constants.extNodeTypeSolution);
            }
            //U-3068 
            else if(productType.equalsIgnoreCase(OC_IB_Constants.nodeTypeNodeComponent) && productObjMapData.containsKey(OC_IB_Constants.extNodeTypeNodeComponent)){
                productDatalist=(List<Object>)productObjMapData.get(OC_IB_Constants.extNodeTypeNodeComponent);
            }
           
        }
        return productDatalist;
        
    }
    public void execute(Database.BatchableContext BC, List<Object> prdObjList){
        if(prdObjList!=null && !prdObjList.isEmpty() && String.isNotBlank(productType)){
            if(productType.equalsIgnoreCase(OC_IB_Constants.productNodeType)){
                OC_PRD_InboundRequestHandler.processProductRequestData(integrationIdentifier,prdObjList,productType);   
            }
             //U-3066 
            else if(productType.equalsIgnoreCase(OC_IB_Constants.productSolutionType)){
                OC_PRD_InboundRequestHandler.processProductRequestData(integrationIdentifier,prdObjList,productType);   
            }
            //U-3068 
            else if(productType.equalsIgnoreCase(OC_IB_Constants.productNodeComponentType)){
                OC_PRD_InboundRequestHandler.processProductRequestData(integrationIdentifier,prdObjList,productType);   
            }
             //U-3066 
            else if(productType.equalsIgnoreCase(OC_IB_constants.nodeTypeSolution)){
                OC_PRD_InboundRequestHandler.processProductRequestData(integrationIdentifier,prdObjList,productType);   
            }
            //U-3068 
            else if(productType.equalsIgnoreCase(OC_IB_constants.nodeTypeNodeComponent)){
                OC_PRD_InboundRequestHandler.processProductRequestData(integrationIdentifier,prdObjList,productType);   
            }
        }
    }     
    public void finish(Database.BatchableContext BC){ 
        
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
        integer batchJobSize=Integer.valueof(mc.OC_PRD_CsdpToStagingObjBatchSize__c);
        
        List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
        if(String.isNotBlank(productType) && (productDatalist==null||productDatalist.isEmpty())){
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.batchProductInboundProcessorCls,OC_IB_Constants.finishMethod,null, true, null,OC_IB_Constants.Sfdc_Ebip_PRD_inApi,null,false,true,true,false,false,null,OC_IB_Constants.noRecordsErrorMessage+':'+productType,false,null,null));
            if(!integEventLogInsertList.isEmpty()){
                EventLog.createIntegrationLog(integEventLogInsertList);
            } 
        }
        //U-3066
        if(String.isNotBlank(nextSequenceNode)){
            if(nextSequenceNode.equalsIgnoreCase(OC_IB_Constants.productSolutionType)){ 
                Database.executeBatch(new OC_PRD_BatchProductInboundProcessor(OC_IB_constants.Sfdc_Ebip_PRD_inApi,productObjMapData,OC_IB_Constants.productSolutionType, OC_IB_Constants.productNodeComponentType),batchJobSize);
            }
            //U-3068 
           else if(nextSequenceNode.equalsIgnoreCase(OC_IB_Constants.productNodeComponentType)){
                Database.executeBatch(new OC_PRD_BatchProductInboundProcessor(OC_IB_constants.Sfdc_Ebip_PRD_inApi,productObjMapData,OC_IB_Constants.productNodeComponentType,OC_IB_constants.nodeTypeSolution),batchJobSize);
            }
            //U-3066
            else if(nextSequenceNode.equalsIgnoreCase(OC_IB_constants.nodeTypeSolution)){
                Database.executeBatch(new OC_PRD_BatchProductInboundProcessor(OC_IB_constants.Sfdc_Ebip_PRD_NtSolnComp_InApi,productObjMapData,OC_IB_constants.nodeTypeSolution, OC_IB_constants.nodeTypeNodeComponent),batchJobSize);
            }
            //U-3068 
            else if(nextSequenceNode.equalsIgnoreCase(OC_IB_constants.nodeTypeNodeComponent)){
                Database.executeBatch(new OC_PRD_BatchProductInboundProcessor(OC_IB_constants.Sfdc_Ebip_PRD_NtSolnComp_InApi,productObjMapData,OC_IB_constants.nodeTypeNodeComponent, ''),batchJobSize);
            }
        }
     } 
}