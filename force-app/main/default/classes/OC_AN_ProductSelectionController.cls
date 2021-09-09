/**
* @File Name          : OC_AN_ProductSelectionController (Controller class for lwc component oc_an_productselection)
* @Description        : Handles the wrapper structure for bulletin product attribute selection UI and 
                	    addition of selected product attribute records to bulletin.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10                 IBM               Initial Version
* 1.0        2021-06-09                 IBM               Improvements to Product Selection Refer: US-
**/

public with sharing class OC_AN_ProductSelectionController {

   






    @AuraEnabled
    public static ProductListWrapper fetchAccountsFrmFilter ( String searchKeyword) {
        try{
            Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.UserPreference_Product_RT_Node).getRecordTypeId();
            String searchWord = searchKeyword+'%';
            system.debug('searchWord'+searchWord);
            Boolean isRelease=false;
            ProductListWrapper productsListWrapper = new ProductListWrapper();
            Set<ProductWrapper> products = new Set<ProductWrapper>();
            productsListWrapper.products = products;
            Set<OC_MD_ProductAttributes__c> releaseList1=  new set<OC_MD_ProductAttributes__c>();
            

            Map<Id, Product2> productMap = new Map<Id, Product2>();
           
            
            List<OC_MD_ProductAttributes__c> palist = [ SELECT Id, Name, RecordTypeId,
                                     RecordType.Name, RecordType.DeveloperName,
                                    OC_MD_Product__c, OC_MD_Parent__c,
                                    OC_MD_Parent__r.OC_MD_Product__c,
                                    OC_MD_Parent__r.OC_MD_Product__r.name,
                                    OC_MD_Parent__r.name
                                    FROM OC_MD_ProductAttributes__c  
            WHERE RecordTypeId != null AND (OC_MD_Product__c != null OR OC_MD_Parent__c != null)
            AND (Name like :searchWord )
            ];
            system.debug('palist'+palist);
            

            List<Product2> productsListGrid = [Select Id, Name From Product2 
            WHERE Id != null AND RecordTypeId = :productNodeRTId  
            ORDER BY Name];
                for(Product2 p : productsListGrid){
                    productMap.put(p.Id,p);
                }
                
            Map<Id, OC_MD_ProductAttributes__c> productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
            productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
                for(OC_MD_ProductAttributes__c pa :palist ){
                        productAttributesMap.put(pa.Id, pa);
                }
            Map<Id, set<OC_MD_ProductAttributes__c>> releaseMap = new Map<Id, set<OC_MD_ProductAttributes__c>>();
            set<OC_MD_ProductAttributes__c> releaseList; 
            Set<OC_MD_ProductAttributes__c> versionList;
            Set<Id> mapid = new Set<Id>(); 
            Map<Id, Set<OC_MD_ProductAttributes__c>> versionMap = new Map<Id, Set<OC_MD_ProductAttributes__c>>();	
            for(OC_MD_ProductAttributes__c p : productAttributesMap.values()){
               
      
                     releaseList = releaseMap.get(p.OC_MD_Product__c);
                     versionList = versionMap.get(p.OC_MD_Parent__c);
                    if(releaseList == null)
                    
                        releaseList = new set<OC_MD_ProductAttributes__c>();
                        system.debug('releaseListNULL'+releaseList);
                    
                    if(versionList == null)
                    
                        versionList = new Set<OC_MD_ProductAttributes__c>();
                        system.debug('versionListNULL'+versionList);
                    
                    if(p.RecordType.DeveloperName == OC_AN_Constants.const_Release && p.OC_MD_Product__c != null){
                        system.debug('under Release');
                        releaseList.add(p);
                        system.debug('releaseList' +releaseList);
                        releaseMap.put(p.OC_MD_Product__c, releaseList);
                        system.debug('releaseMap' +releaseMap);
                        mapid.add(p.id);
                        isRelease=true;
                        //releaseList1.add(p);
                    }
                    if(p.RecordType.DeveloperName == OC_AN_Constants.const_Version && p.OC_MD_Parent__c != null){
                        versionList.add(p);
                        versionMap.put(p.OC_MD_Parent__c, versionList);
                        system.debug('versionListadded' +versionList);
                        system.debug('versionMapadded' +versionMap);
                       // releaseList1.add(p);
                       mapid.add(p.id);
                    }
                    
                
            }
            
            //if user search for release
            Set<OC_MD_ProductAttributes__c> versions1;
            // Set<OC_MD_ProductAttributes__c> versions1 = new Set<OC_MD_ProductAttributes__c>();
            
            if(!releaseMap.isEmpty())
            {
            List<OC_MD_ProductAttributes__c> releasechild = [ SELECT Id, Name, RecordTypeId,
                                                RecordType.Name, RecordType.DeveloperName,
                                                OC_MD_Product__c, OC_MD_Parent__c,
                                                OC_MD_Parent__r.OC_MD_Product__c,
                                                OC_MD_Parent__r.OC_MD_Product__r.name,
                                                OC_MD_Parent__r.name
                                                FROM OC_MD_ProductAttributes__c  
                        where OC_MD_Parent__c in :mapid 
                        ];

                        system.debug('releasechildlist' +releasechild);          
                      
        if(!releasechild.isEmpty())
        {
            for(OC_MD_ProductAttributes__c ver :releasechild)
                        {
                                    /*release search starts*/
                                    if(!versionMap.containskey(ver.OC_MD_Parent__c))
                                    {
                                        versions1 = new Set<OC_MD_ProductAttributes__c>();
                                        versions1.add(ver);
                                        
                                        }
                                    else{
                                        versions1.add(ver);
                                    }
                                versionMap.put(ver.OC_MD_Parent__c,versions1);
                            
                        }
                        /** release search ends*/
                        system.debug('versionMap: ' +versionMap); 
        }
    }
        

///version
if(!versionMap.isEmpty())
{
List<OC_MD_ProductAttributes__c> releasechild = [ SELECT Id, Name, RecordTypeId,
                                    RecordType.Name, RecordType.DeveloperName,
                                    OC_MD_Product__c, OC_MD_Parent__c,
                                    OC_MD_Parent__r.OC_MD_Product__c,
                                    OC_MD_Parent__r.OC_MD_Product__r.name,
                                    OC_MD_Parent__r.name
                                    FROM OC_MD_ProductAttributes__c  
            where id in :mapid 
            ];

            system.debug('releasechildlist' +releasechild);          
          
if(!releasechild.isEmpty())
{
for(OC_MD_ProductAttributes__c ver :releasechild)
            {
                        /*release search starts*/
                        if(!releaseMap.containskey(ver.OC_MD_Parent__r.OC_MD_Product__c))
                        {
                            versions1 = new Set<OC_MD_ProductAttributes__c>();
                            versions1.add(ver);
                            
                            }
                        else{
                            versions1.add(ver);
                        }
                        releaseMap.put(ver.OC_MD_Parent__r.OC_MD_Product__c,versions1);
                
            }
            /** release search ends*/
            system.debug('versionMap: ' +releaseMap); 
}
}



        for(Product2 product : productMap.values()){
                        ProductWrapper pw = new ProductWrapper(); 
                        pw.Id = product.Id;
                        pw.Name = product.Name;
                        Set<ReleaseWrapper> releases = new Set<ReleaseWrapper>();
                        /**searching for releases directly */
                        if(releaseMap.containsKey(product.Id) && isRelease==true ){
                         for(OC_MD_ProductAttributes__c release :releaseMap.get(product.Id)){
                             ReleaseWrapper rw = new ReleaseWrapper();
                                    rw.Id = release.id;
                                    system.debug('rw.Id');
                                    rw.Name = release.name;
                                    rw.OC_MD_Product =release.OC_MD_Product__c;
                                    set<OC_MD_ProductAttributes__c> versions=versionMap.get(rw.Id);
                                     if(versions != null && versions.size() >0
                                          ){
                                            rw.children = versions; 
                                            system.debug('verions: rw.children1  ' +rw.children );
                                        }
                                       
                                            releases.add(rw); 
                            }
                        }
                        /**searching for version directly */
                        if(releaseMap.containsKey(product.Id) && isRelease==false ){
                            for(OC_MD_ProductAttributes__c release :releaseMap.get(product.Id)){
                                ReleaseWrapper rw = new ReleaseWrapper();
                                       rw.Id = release.OC_MD_Parent__c;
                                       system.debug('rw.Id');
                                       rw.Name = release.OC_MD_Parent__r.name;
                                       rw.OC_MD_Product =release.OC_MD_Parent__r.OC_MD_Product__c;
                                       set<OC_MD_ProductAttributes__c> versions=versionMap.get(rw.Id);
                                        if(versions != null && versions.size() >0
                                             ){
                                               rw.children = versions; 
                                               system.debug('verions: rw.children1  ' +rw.children );
                                           }
                                          
                                               releases.add(rw); 
                               }

                        }
                         
                            /**veriosn record ends */
                            if(releases != null && releases.size() > 0){
                                system.debug('releases not empty  ' );

                                pw.children = releases; //To support new version - Rohit
                                system.debug(' pw.children  '+ pw.children );
                            }
                            if(pw.children!=null)
                            {
                            products.add(pw);
                            }
                        }

                        productsListWrapper.products = products;
                        system.debug('products'+products);
                    system.debug('productsListWrapper'+productsListWrapper);   
                    return productsListWrapper;
                }


            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }

    }




    @AuraEnabled
    public static ProductListWrapper getProducts(ProductSelectionWrapper wrapper){
        ProductListWrapper productsListWrapper = new ProductListWrapper();
        productsListWrapper.isCompleted = wrapper.isCompleted;
        Set<ProductWrapper> products = new Set<ProductWrapper>();
        productsListWrapper.products = products;
        Map<Id, OC_MD_ProductAttributes__c> productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
		
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        Map<Id, Set<OC_MD_ProductAttributes__c>> releaseMap = new Map<Id, Set<OC_MD_ProductAttributes__c>>();
        Map<Id, Set<OC_MD_ProductAttributes__c>> versionMap = new Map<Id, Set<OC_MD_ProductAttributes__c>>();
			
       try{        
            Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.UserPreference_Product_RT_Node).getRecordTypeId();

            // Get all products
            List<Product2> productsListGrid = new List<Product2> ();
            
            AggregateResult ar = [SELECT count(Id) FROM Product2 WHERE Id != null AND RecordTypeId = :productNodeRTId];
            Integer productCount = Integer.valueOf(ar.get('expr0'));

            if(wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < productCount)
                 productsListGrid = [Select Id, Name From Product2 
                                    WHERE Id != null AND RecordTypeId = :productNodeRTId  
                                    ORDER BY Name ASC LIMIT 50 OFFSET :wrapper.offsetCount];
            else if(wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0))
                 productsListGrid = [Select Id, Name From Product2 
                                    WHERE Id != null AND RecordTypeId = :productNodeRTId 
                                    ORDER BY Name ASC LIMIT 50];
            else if(productCount == wrapper.offsetCount){
                 productsListWrapper.isCompleted = true;
            }
        
            for(Product2 p : productsListGrid){
                productMap.put(p.Id,p);
            }

            // get releases & versions
            productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
            for(OC_MD_ProductAttributes__c pa : [
                SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, OC_MD_Product__c, OC_MD_Parent__c, OC_MD_Parent__r.OC_MD_Product__c FROM OC_MD_ProductAttributes__c  
                WHERE RecordTypeId != null AND (OC_MD_Product__c != null OR OC_MD_Parent__c != null)]){
                    productAttributesMap.put(pa.Id, pa);
            }

            for(OC_MD_ProductAttributes__c p : productAttributesMap.values()){
                if(p.RecordTypeId != null){
                    Set<OC_MD_ProductAttributes__c> releaseList = releaseMap.get(p.OC_MD_Product__c);
                    Set<OC_MD_ProductAttributes__c> versionList = versionMap.get(p.OC_MD_Parent__c);
                    if(releaseList == null)
                        releaseList = new Set<OC_MD_ProductAttributes__c>();
                    if(versionList == null)
                        versionList = new Set<OC_MD_ProductAttributes__c>();
                    if(p.RecordType.DeveloperName == OC_AN_Constants.const_Release && p.OC_MD_Product__c != null){
                        releaseList.add(p);
                        releaseMap.put(p.OC_MD_Product__c, releaseList);
                    }
                    if(p.RecordType.DeveloperName == OC_AN_Constants.const_Version && p.OC_MD_Parent__c != null){
                        versionList.add(p);
                        versionMap.put(p.OC_MD_Parent__c, versionList);
                    }
                }
            }

            for(Product2 product : productMap.values()){
                ProductWrapper pw = new ProductWrapper(); 
                pw.Id = product.Id;
                pw.Name = product.Name;
                Set<ReleaseWrapper> releases = new Set<ReleaseWrapper>();
                if(releaseMap.containsKey(product.Id)){
                    for(OC_MD_ProductAttributes__c release :releaseMap.get(product.Id)){
                        ReleaseWrapper rw = new ReleaseWrapper();
                        rw.Id = release.Id;
                        rw.Name = release.Name;
                        rw.OC_MD_Product = release.OC_MD_Product__c;
                        Set<OC_MD_ProductAttributes__c> versions = versionMap.get(release.Id);
                        if(versions != null && versions.size() >0){
                            rw.children = versions; //To support new version - Rohit
                        }
                        releases.add(rw); 
                    }
                }
                if(releases != null && releases.size() > 0){
                    pw.children = releases; //To support new version - Rohit
                }
                products.add(pw);
            }
            productsListWrapper.products = products;
        }
       
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('sendingproductsListWrapper' +productsListWrapper);
        return productsListWrapper;
    }

    /** Save Products to Bulletin Product Account **/
    @AuraEnabled
    public static String saveProductSelection(string jsoninput,Id bulletinRecId){
        List<OC_AN_Bulletin_Account_Product__c> listBAPToBeAdded = new List<OC_AN_Bulletin_Account_Product__c> ();
        List<OC_AN_Bulletin_Account_Product__c> listBAPToBeDeleted ;
        try{
            Id productRTId = Schema.SObjectType.OC_AN_Bulletin_Account_Product__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Product_Record').getRecordTypeId();
            Map <String, Object> records   = (Map<String, Object>)json.deserializeUntyped(jsoninput);
            Map <String, Object> selectedRecords =  (Map<String, Object>) records.get('selected');
            system.debug('selected' +selectedRecords);
            Map <String, Object> deSelectedRecords =  (Map<String, Object>) records.get('deselected');
            system.debug('deselected' +deSelectedRecords);
            Set<String> productIds = new Set<String>();
            Set<String> releaseIds = new Set<String>();
            Set<String> versionIds = new Set<String>();
            
            // query existing bap records for this bulletin for the selected Product, Release or Version
            List<OC_AN_Bulletin_Account_Product__c> listBAP = [SELECT OC_AN_Product__c, OC_AN_Release__c
            , OC_AN_Verison__c, OC_AN_Bulletin__c, Id FROM OC_AN_Bulletin_Account_Product__c
            WHERE OC_AN_Bulletin__c = :bulletinRecId AND (OC_AN_Product__c IN :selectedRecords.keySet() 
            OR OC_AN_Release__c IN :selectedRecords.keySet() OR OC_AN_Verison__c  IN :selectedRecords.keySet())];

            system.debug('listBAP' +listBAP);

            listBAPToBeDeleted = [SELECT Id FROM OC_AN_Bulletin_Account_Product__c
            WHERE OC_AN_Bulletin__c = :bulletinRecId AND (OC_AN_Product__c IN :deSelectedRecords.keySet() 
            OR OC_AN_Release__c IN :deSelectedRecords.keySet() OR OC_AN_Verison__c  IN :deSelectedRecords.keySet())];


            Map<String, Id> pRVWithRecordId = new Map<String, Id>();
            for(OC_AN_Bulletin_Account_Product__c itemBAP : listBAP){
                String itemId = '';
                if(itemBAP.OC_AN_Verison__c != null)
                    itemId = itemBAP.OC_AN_Verison__c+ OC_AN_Constants.VERSION;
                if(itemBAP.OC_AN_Release__c != null)
                    itemId += itemBAP.OC_AN_Release__c+ OC_AN_Constants.RELEASE;
                if(itemBAP.OC_AN_Product__c != null)
                    itemId += itemBAP.OC_AN_Product__c;
                if(String.isNotBlank(itemId))
                    pRVWithRecordId.put(itemId, itemBAP.Id);
            }
            system.debug('pRVWithRecordId' +pRVWithRecordId);
            Map<String, OC_AN_Bulletin_Account_Product__c> bapMap = new Map<String, OC_AN_Bulletin_Account_Product__c>();
            for(String selectedRowId : selectedRecords.keyset()) {
                Map<String,Object> mp =  (Map<String,Object>)selectedRecords.get(selectedRowId);
                String versionRecId = ''; 
                String releaseRecId = '';
                String productRecId = '';   
                String mapKey = '';
                if(mp.containsKey(OC_AN_Constants.OC_MD_ParentC) && mp.containsKey(OC_AN_Constants.OC_MD_ParentR)){
                    Map<String,Object> versionMap =  (Map<String,Object>)mp.get(OC_AN_Constants.OC_MD_ParentR);
                    versionRecId = selectedRowId;
                    system.debug('versionRecId' +versionRecId);
                    releaseRecId = String.valueOf(versionMap.get('Id'));
                    productRecId = String.valueOf(versionMap.get(OC_AN_Constants.OC_MD_ProductC));
                    mapKey = versionRecId + OC_AN_Constants.VERSION +releaseRecId  + OC_AN_Constants.RELEASE + productRecId;
                    system.debug('mapKey' +mapKey);
                    productIds.add(productRecId);
                    releaseIds.add(releaseRecId);
                    versionIds.add(versionRecId);
                }
                else if(mp.containsKey(OC_AN_Constants.OC_MD_Product) && !releaseIds.contains(selectedRowId)){
                    releaseRecId = selectedRowId;
                   
                    productRecId = String.valueOf(mp.get(OC_AN_Constants.OC_MD_Product));
                    mapKey = releaseRecId  + OC_AN_Constants.RELEASE + productRecId;
                    productIds.add(productRecId);
                    releaseIds.add(releaseRecId);
                }
                else if(!mp.containsKey(OC_AN_Constants.OC_MD_ParentC) && !mp.containsKey(OC_AN_Constants.OC_MD_ParentR) && !mp.containsKey(OC_AN_Constants.OC_MD_Product)  && !productIds.contains(selectedRowId)) {
                    productRecId=selectedRowId;
                    mapKey = selectedRowId;
                }
                OC_AN_Bulletin_Account_Product__c itemBAP = bapMap.get(mapKey);
                if(itemBAP == null)
                    itemBAP = new OC_AN_Bulletin_Account_Product__c(OC_AN_Bulletin__c = bulletinRecId,  RecordTypeId=productRTId); 
                if(!pRVWithRecordId.containsKey(mapKey)){
                    if(String.isNotEmpty(productRecId))
                        itemBAP.OC_AN_Product__c= productRecId;
                    if(String.isNotEmpty(releaseRecId))
                        itemBAP.OC_AN_Release__c= releaseRecId;
                    if(String.isNotEmpty(versionRecId))
                        itemBAP.OC_AN_Verison__c= versionRecId;
                        system.debug('  itemBAP.OC_AN_Verison__c' +  itemBAP.OC_AN_Verison__c);
                }
                if(pRVWithRecordId.containsKey(mapKey))
                 itemBAP.Id = pRVWithRecordId.get(mapKey);
                bapMap.put(mapKey, itemBAP);
                system.debug('bapMap' +bapMap);
            }
            listBAPToBeAdded.addAll(bapMap.values());
            if(listBAPToBeAdded != null && listBAPToBeAdded.size()>0)
            system.debug('listBAPToBeAdded' +listBAPToBeAdded);
                upsert listBAPToBeAdded;
            if(listBAPToBeDeleted != null && listBAPToBeDeleted.size()>0)
                delete listBAPToBeDeleted;
        }
         catch(Exception e){       
            throw new AuraHandledException(e.getMessage() + 'listBAPToBeAdded: ' + listBAPToBeAdded + '\nlistBAPToBeDeleted: ' + listBAPToBeDeleted);
        }
        return 'success';
    }


    @AuraEnabled
    public static ProductSelectionWrapper getCurrentBulletinProducts(Id bulletinId){
        ProductSelectionWrapper wrapper;
        try{
            wrapper = new ProductSelectionWrapper();
            wrapper.product = new Set<Id>();
            Map<Id, ProductWrapper> productsMap = new  Map<Id, ProductWrapper>();
	        List<OC_AN_Bulletin_Account_Product__c> listBAP = [SELECt OC_AN_Product__c, OC_AN_Release__c
            , OC_AN_Verison__c, OC_AN_Bulletin__c, OC_AN_Release__r.OC_MD_Product__c
            , OC_AN_Verison__r.OC_MD_Parent__c, OC_AN_Verison__r.OC_MD_Parent__r.OC_MD_Product__c,  Id 
            FROM OC_AN_Bulletin_Account_Product__c
            WHERE OC_AN_Bulletin__c = :bulletinId]; 

			 for(OC_AN_Bulletin_Account_Product__c itemBAP : listBAP){
                 if(itemBAP.OC_AN_Verison__c != null)
                     wrapper.product.add(itemBAP.OC_AN_Verison__c);
                else if(itemBAP.OC_AN_Release__c != null)
                    wrapper.product.add(itemBAP.OC_AN_Release__c);
                else
                    wrapper.product.add(itemBAP.OC_AN_Product__c);
             }
        }
        catch(Exception e){
            throw new AuraHandledException( e.getMessage());
        }
        system.debug('productselectionwrapper--' +wrapper);
        return wrapper;
	}
    
    public class ProductSelectionWrapper{
        @AuraEnabled 
        public Boolean isCompleted{public get; public set;}
        @AuraEnabled 
        public Integer offsetCount{public get; public set;}
        @AuraEnabled
        public Set<Id> product{public get; public set;}
    }

    public class ProductListWrapper{
        @AuraEnabled
        public Set<ProductWrapper> products{public get; public set;}  
        @AuraEnabled 
        public Boolean isCompleted{public get; public set;}    
    }

    public class ProductWrapper{
        @AuraEnabled
        public String Name{public get; public set;}
        @AuraEnabled
        public String Id{public get; public set;}
        @AuraEnabled
        public Set<ReleaseWrapper> children{public get; public set;}  //To support new version - Rohit
    }

    public class ReleaseWrapper{
        @AuraEnabled
        public String Name{public get; public set;}
        @AuraEnabled
        public String Id{public get; public set;}
        @AuraEnabled
        public String OC_MD_Product{public get; public set;}
        @AuraEnabled
        public Set<OC_MD_ProductAttributes__c> children{public get; public set;}  //To support new version - Rohit
    } 
}