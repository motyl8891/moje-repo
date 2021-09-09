/**
* @File Name          : OC_AN_UserPreferencesController 
(Controller class for oc_an_userPreferences LWC) 
* @Description        : Process User Preferences for currently logged in user
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th May
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-10                 IBM               Initial Version
* 1.1        2021-05-16                 IBM               2nd Version
* 1.2        2021-08-19                 IBM               3rd Version
**/
public without sharing class OC_AN_UserPreferencesController {
    

    @AuraEnabled
    public static ProductListWrapper getsearchproduct(String searchKeyword){
        String searchWord = searchKeyword+'%';
        system.debug('searchWord'+searchWord);
        Boolean isRelease=false;
        Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.UserPreference_Product_RT_Node).getRecordTypeId();
        ProductListWrapper productsListWrapper = new ProductListWrapper();
        //Set<ProductWrapper> products = new Set<ProductWrapper>();
           
            list<ProductWrapper> products = new list<ProductWrapper>();
            productsListWrapper.products = products;
			
            Map<Id, OC_MD_ProductAttributes__c> productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
          Boolean isCommunityUser = false;
            Map<Id, Product2> productMap = new Map<Id, Product2>();
            Map<Id, List<OC_MD_ProductAttributes__c>> releaseMap = new Map<Id, List<OC_MD_ProductAttributes__c>>();
            Map<Id, List<OC_MD_ProductAttributes__c>> versionMap = new Map<Id, List<OC_MD_ProductAttributes__c>>();
			  Set<Id> mapid = new Set<Id>(); 
            
            
            // Check if user is external user
            User commUser;
            Map<Id, AccountContactRelation> accountIdsCustomer;
            if(UserInfo.getUserId() != null){
                commUser = [SELECT Id, IsPortalEnabled, ContactId, Contact.AccountId from User WHERE Id = :UserInfo.getUserId()];            
                accountIdsCustomer = new Map<Id, AccountContactRelation>();
                for(AccountContactRelation acr : [SELECT AccountId, Id FROM AccountContactRelation WHERE ContactId = :commUser.ContactId]){
                    accountIdsCustomer.put(acr.AccountId, acr);
                }
                if(commUser != null && commUser.Id != null && commUser.IsPortalEnabled ==true 
                   && commUser.ContactId!= null && commUser.Contact.AccountId!= null)
                    isCommunityUser = true;            
            }
            
            List<Product2> productsListGrid = new List<Product2> ();
            /*if(isCommunityUser){
                // Get external user products
                if((wrapper.productCount == null || wrapper.productCount ==0) 
                   && accountIdsCustomer != null && productsListWrapper != null && !productsListWrapper.isCompleted){
                       List<AggregateResult> userAccountProductIds = [SELECT Product2Id FROM Asset WHERE AccountId != null AND Account.ParentId != null AND
                                                                      Account.Parent.Account_Type__c = 'Sales' AND AccountId IN : accountIdsCustomer.KeySet() Group By Product2Id];
                       wrapper.productCount = userAccountProductIds != null ? userAccountProductIds.size() : 0;
                   }
                List<AggregateResult> assets;
                if(!productsListWrapper.isCompleted && wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < wrapper.productCount)
                    assets = [SELECT Product2Id FROM Asset WHERE Account.Parent.Account_Type__c = 'Sales' AND AccountId IN : accountIdsCustomer.KeySet()  Group By Product2Id LIMIT 15 OFFSET :wrapper.offsetCount];
                else if(!productsListWrapper.isCompleted && (wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0)))
                    assets = [SELECT Product2Id FROM Asset  WHERE Account.Parent.Account_Type__c = 'Sales' AND AccountId IN : accountIdsCustomer.KeySet()  Group By Product2Id LIMIT 15];
                else if(wrapper.productCount == wrapper.offsetCount){
                    productsListWrapper.isCompleted = true;
                }
                if(assets != null && !productsListWrapper.isCompleted){
                    Set<Id> commProductIds = new Set<Id>();
                    for(AggregateResult ast : assets){
                        if(ast.get('Product2Id') != null)
                            commProductIds.add(String.valueOf(ast.get('Product2Id')));
                    }
                    productsListGrid = [Select Id, Name From Product2 WHERE Id != null 
                                        AND Id IN :commProductIds AND RecordTypeId = :productNodeRTId ORDER BY Name ASC];
                }
            }*/
			
			
			
                if(!isCommunityUser){
                // Get all products
                
                    productsListGrid = [Select Id, Name From Product2 
										WHERE Id != null AND RecordTypeId = :productNodeRTId 
										ORDER BY Name ];
                
                }
            
            for(Product2 p : productsListGrid){
                productMap.put(p.Id,p);
            }
            
            // get releases & versions
            productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
			
            for(OC_MD_ProductAttributes__c pa : [
                SELECT Id, Name, RecordTypeId, RecordType.Name,
                 RecordType.DeveloperName,
                  OC_MD_Product__c, 
                  OC_MD_Parent__c,
                  OC_MD_Parent__r.OC_MD_Product__c,
                 
                OC_MD_Parent__r.name
                FROM OC_MD_ProductAttributes__c  
                WHERE RecordTypeId != null AND 
                (
                    (OC_MD_Product__c != null AND OC_MD_Product__c IN :productMap.KeySet())
                     OR
                    OC_MD_Parent__c != null
                )
                AND
                Name like :searchWord
                ]){
                    productAttributesMap.put(pa.Id, pa);
                }

                system.debug
                ('productAttributesMap---'+productAttributesMap);
				
            
            for(OC_MD_ProductAttributes__c p : productAttributesMap.values()){
                if(p.RecordTypeId != null){
                    List<OC_MD_ProductAttributes__c> releaseList = releaseMap.get(p.OC_MD_Product__c);
                    List<OC_MD_ProductAttributes__c> versionList = versionMap.get(p.OC_MD_Parent__c);
                    if(releaseList == null)
                        releaseList = new List<OC_MD_ProductAttributes__c>();
                    if(versionList == null)
                        versionList = new List<OC_MD_ProductAttributes__c>();
                    if(p.RecordType.DeveloperName == OC_AN_Constants.const_Release && p.OC_MD_Product__c != null){
                        releaseList.add(p);
                        releaseMap.put(p.OC_MD_Product__c, releaseList);
						 mapid.add(p.id);
                         isRelease=true;
                    }
                    if(p.RecordType.DeveloperName == OC_AN_Constants.const_Version && p.OC_MD_Parent__c != null){
                        versionList.add(p);
                        versionMap.put(p.OC_MD_Parent__c, versionList);
						 mapid.add(p.id);
                    }
                }
            }
			
			//release searchKeyword
			List<OC_MD_ProductAttributes__c> versions1;
			
	if(!releaseMap.isEmpty()){
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
                                        versions1 = new list<OC_MD_ProductAttributes__c>();
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

    ////version search starts
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
                            /*version search starts*/
                            if(!releaseMap.containskey(ver.OC_MD_Parent__r.OC_MD_Product__c))
                            {
                                versions1 = new list<OC_MD_ProductAttributes__c>();
                                versions1.add(ver);
                                
                                }
                            else{
                                versions1.add(ver);
                            }
                            releaseMap.put(ver.OC_MD_Parent__r.OC_MD_Product__c,versions1);
                    
                }
                /** version search ends*/
                system.debug('versionMap: ' +releaseMap); 
    }
    }
    
    


    for(Product2 product : productMap.values()){
        ProductWrapper pw = new ProductWrapper(); 
        pw.Id = product.Id;
        pw.Name = product.Name;
        List<ReleaseWrapper> releases = new List<ReleaseWrapper>();
        if(releaseMap.containsKey(product.Id) &&  isRelease==true ){
            for(OC_MD_ProductAttributes__c release :releaseMap.get(product.Id)){
                ReleaseWrapper rw = new ReleaseWrapper();
                rw.Id = release.Id;
                rw.Name = release.Name;
                system.debug('rw.Id'+rw.Id);
                rw.OC_MD_Product = release.OC_MD_Product__c;
                List<OC_MD_ProductAttributes__c> versions = versionMap.get(release.Id);
                if(versions != null && versions.size() >0){
                    rw.versions = versions;
                    rw.children = versions; //To support new version - Rohit
                }
                releases.add(rw); 
            }
            system.debug('releases'+releases);
        }

        /**version search */
        if(releaseMap.containsKey(product.Id) && isRelease==false ){
            for(OC_MD_ProductAttributes__c release :releaseMap.get(product.Id)){
                ReleaseWrapper rw = new ReleaseWrapper();
                       rw.Id = release.OC_MD_Parent__c;
                       system.debug('rw.Id');
                       rw.Name = release.OC_MD_Parent__r.name;
                       rw.OC_MD_Product =release.OC_MD_Parent__r.OC_MD_Product__c;
                       list<OC_MD_ProductAttributes__c> versions=versionMap.get(rw.Id);
                        if(versions != null && versions.size() >0
                             ){
                               rw.children = versions; 
                               rw.versions = versions;
                               system.debug('verions: rw.children1  ' +rw.children );
                           }
                          
                               releases.add(rw); 
               }

        }


        if(releases != null && releases.size() > 0){
            pw.releases = releases;
            pw.children = releases; //To support new version - Rohit
            system.debug('pw:'+pw);
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



    /**
* Get all products on load - Internal users
* Get the products purchased by the customer - External users
* Get all releases & versions of the product
*/
    






    @AuraEnabled
    public static ProductListWrapper getProducts(UserPreferenceWrapper wrapper){
        Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.UserPreference_Product_RT_Node).getRecordTypeId();
        ProductListWrapper productsListWrapper = new ProductListWrapper();
        system.debug('wrapper====>'+wrapper);
        if(wrapper != null){
            productsListWrapper.isCompleted = wrapper.isCompleted;
            List<ProductWrapper> products = new List<ProductWrapper>();
            productsListWrapper.products = products;
            Map<Id, OC_MD_ProductAttributes__c> productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
            Boolean isCommunityUser = false;
            Map<Id, Product2> productMap = new Map<Id, Product2>();
            Map<Id, List<OC_MD_ProductAttributes__c>> releaseMap = new Map<Id, List<OC_MD_ProductAttributes__c>>();
            Map<Id, List<OC_MD_ProductAttributes__c>> versionMap = new Map<Id, List<OC_MD_ProductAttributes__c>>();
            
            
            // Check if user is external user
            User commUser;
            Map<Id, AccountContactRelation> accountIdsCustomer;
            if(UserInfo.getUserId() != null){
                commUser = [SELECT Id, IsPortalEnabled, ContactId, Contact.AccountId from User WHERE Id = :UserInfo.getUserId()];            
                accountIdsCustomer = new Map<Id, AccountContactRelation>();
                for(AccountContactRelation acr : [SELECT AccountId, Id FROM AccountContactRelation WHERE ContactId = :commUser.ContactId]){
                    accountIdsCustomer.put(acr.AccountId, acr);
                    system.debug('accountIdsCustomer====>'+accountIdsCustomer.keySet());
                }
                if(commUser != null && commUser.Id != null && commUser.IsPortalEnabled ==true 
                   && commUser.ContactId!= null && commUser.Contact.AccountId!= null)
                    isCommunityUser = true;            
            }
            
            List<Product2> productsListGrid = new List<Product2> ();
            if(isCommunityUser){
                // Get external user products
                if((wrapper.productCount == null || wrapper.productCount ==0) 
                   && accountIdsCustomer != null && productsListWrapper != null && !productsListWrapper.isCompleted){
                       List<AggregateResult> userAccountProductIds = [SELECT Product2Id FROM Asset WHERE AccountId != null AND Account.ParentId != null AND
                                                                      Account.Parent.Account_Type__c = 'Sales' AND AccountId IN : accountIdsCustomer.KeySet() Group By Product2Id];
                       wrapper.productCount = userAccountProductIds != null ? userAccountProductIds.size() : 0;
                   }
                List<AggregateResult> assets;
                if(!productsListWrapper.isCompleted && wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < wrapper.productCount)
                    assets = [SELECT Product2Id FROM Asset WHERE Account.Parent.Account_Type__c = 'Sales' AND AccountId IN : accountIdsCustomer.KeySet() AND OC_IB_IsActive__c = true  Group By Product2Id LIMIT 15 OFFSET :wrapper.offsetCount];
                else if(!productsListWrapper.isCompleted && (wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0)))
                    assets = [SELECT Product2Id FROM Asset  WHERE Account.Parent.Account_Type__c = 'Sales' AND AccountId IN : accountIdsCustomer.KeySet() AND OC_IB_IsActive__c = true Group By Product2Id LIMIT 15];
                else if(wrapper.productCount == wrapper.offsetCount){
                    productsListWrapper.isCompleted = true;
                }
                if(assets != null && !productsListWrapper.isCompleted){
                    Set<Id> commProductIds = new Set<Id>();
                    for(AggregateResult ast : assets){
                        if(ast.get('Product2Id') != null)
                            commProductIds.add(String.valueOf(ast.get('Product2Id')));
                    }
                    productsListGrid = [Select Id, Name From Product2 WHERE Id != null 
                                        AND Id IN :commProductIds AND RecordTypeId = :productNodeRTId ORDER BY Name ASC];
                    system.debug('productsListGrid====>'+productsListGrid);
                    system.debug('productsListGrid.SIZE====>'+productsListGrid.Size());
                }
            }
            else if(!isCommunityUser){
                // Get all products
                if(wrapper.productCount == null || (wrapper.productCount != null && wrapper.productCount ==0)){
                    AggregateResult ar = [SELECT count(Id) FROM Product2 WHERE RecordTypeId = :productNodeRTId];
                    wrapper.productCount = Integer.valueOf(ar.get('expr0'));
                }
                if(wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < wrapper.productCount)
                    productsListGrid = [Select Id, Name From Product2 WHERE Id != null AND RecordTypeId = :productNodeRTId  ORDER BY Name ASC LIMIT 50 OFFSET :wrapper.offsetCount];
                else if(wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0))
                    productsListGrid = [Select Id, Name From Product2 WHERE Id != null AND RecordTypeId = :productNodeRTId ORDER BY Name ASC LIMIT 50];
                else if(wrapper.productCount == wrapper.offsetCount){
                    productsListWrapper.isCompleted = true;
                }
                
            }
            
            for(Product2 p : productsListGrid){
                productMap.put(p.Id,p);
            }
            
            // get releases & versions
            productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
            for(OC_MD_ProductAttributes__c pa : [
                SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, OC_MD_Product__c, OC_MD_Parent__c
                FROM OC_MD_ProductAttributes__c  
                WHERE RecordTypeId != null AND ((OC_MD_Product__c != null AND OC_MD_Product__c IN :productMap.KeySet()) OR OC_MD_Parent__c != null)]){
                    productAttributesMap.put(pa.Id, pa);
                }
            
            for(OC_MD_ProductAttributes__c p : productAttributesMap.values()){
                if(p.RecordTypeId != null){
                    List<OC_MD_ProductAttributes__c> releaseList = releaseMap.get(p.OC_MD_Product__c);
                    List<OC_MD_ProductAttributes__c> versionList = versionMap.get(p.OC_MD_Parent__c);
                    if(releaseList == null)
                        releaseList = new List<OC_MD_ProductAttributes__c>();
                    if(versionList == null)
                        versionList = new List<OC_MD_ProductAttributes__c>();
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
                List<ReleaseWrapper> releases = new List<ReleaseWrapper>();
                if(releaseMap.containsKey(product.Id)){
                    for(OC_MD_ProductAttributes__c release :releaseMap.get(product.Id)){
                        ReleaseWrapper rw = new ReleaseWrapper();
                        rw.Id = release.Id;
                        rw.Name = release.Name;
                        rw.OC_MD_Product = release.OC_MD_Product__c;
                        List<OC_MD_ProductAttributes__c> versions = versionMap.get(release.Id);
                        if(versions != null && versions.size() >0){
                            rw.versions = versions;
                            rw.children = versions; //To support new version - Rohit
                        }
                        releases.add(rw); 
                    }
                }
                if(releases != null && releases.size() > 0){
                    pw.releases = releases;
                    pw.children = releases; //To support new version - Rohit
                }
                products.add(pw);
            }
            
            productsListWrapper.products = products;
        }
        return productsListWrapper;
    }
    
    /**
* Save users A&N preferences
*/
    @AuraEnabled
    public static string saveUserPreference(PreferenceWrapper inputJson){
        String bulletinPrefix = 'bulletin';
        //PreferenceWrapper inputJson = (PreferenceWrapper) JSON.deserialize(preferencesStr, PreferenceWrapper.class);
        List<OC_AN_User_Preferences__c> preferences = new List<OC_AN_User_Preferences__c>();
        List<OC_AN_User_Preferences__c> preferencesToBeDeleted = new List<OC_AN_User_Preferences__c>();
        
        Id userId = UserInfo.getUserId();
        Id recTypeId_bulletinSetting = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.UserPreference_RT_Bulletin).getRecordTypeId();
        Id recTypeId_productSetting = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.UserPreference_RT_Product).getRecordTypeId();    
        List<OC_AN_User_Preferences__c> existingPreferences = [SELECT id, Name, OC_AN_Account__c, OC_AN_Contact__c
                                                               , OC_AN_Email__c, OC_AN_Notification_Panel__c, OC_AN_Version__c, OC_AN_Product__c, OC_AN_ProductAttribute__c, RecordTypeId, RecordType.Id
                                                               , RecordType.DeveloperName, OC_AN_User__c From OC_AN_User_Preferences__c where OC_AN_User__c = :UserInfo.getUserId()  
                                                               AND RecordTypeId != null];
        
        User currentUser;
        if(userId != null)
            currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        
        Map<String, OC_AN_User_Preferences__c> existingPreferenceMap = new Map<String, OC_AN_User_Preferences__c>();
        
        for(OC_AN_User_Preferences__c pref : existingPreferences){
            if(pref.RecordType.DeveloperName == OC_AN_Constants.UserPreference_RT_Bulletin)
                existingPreferenceMap.put(bulletinPrefix+pref.Name, pref);
            else  if(pref.RecordType.DeveloperName == OC_AN_Constants.UserPreference_RT_Product){
                if(pref.OC_AN_Version__c != null)
                    existingPreferenceMap.put(''+pref.OC_AN_Product__c + pref.OC_AN_ProductAttribute__c + pref.OC_AN_Version__c, pref);
                else if(pref.OC_AN_ProductAttribute__c != null)
                    existingPreferenceMap.put(''+pref.OC_AN_Product__c + pref.OC_AN_ProductAttribute__c, pref);
                else if(pref.OC_AN_Product__c != null)
                    existingPreferenceMap.put(''+pref.OC_AN_Product__c, pref);
            }                
        }
        // Process bulletin settings
        try {
            if(inputJson != null){
                if(inputJson.bulletin != null){
                    for(String s: inputJson.bulletin.keySet()){
                        if(s != OC_AN_Constants.UserPreference_Key_recordType){
                            OC_AN_User_Preferences__c pref = new OC_AN_User_Preferences__c();
                            pref.RecordTypeId = recTypeId_bulletinSetting;
                            pref.OC_AN_User__c = userId;
                            pref.Name = s;
                            if(currentUser != null && currentUser.ContactId != null)
                                pref.OC_AN_Contact__c = currentUser.ContactId;
                            if(existingPreferenceMap.containsKey(bulletinPrefix+s))
                                pref.Id = existingPreferenceMap.get(bulletinPrefix+s).Id;
                            
                            Map<String, Object> setting =  inputJson.bulletin.get(s);
                            pref.OC_AN_Email__c = Boolean.valueOf(setting.get(OC_AN_Constants.UserPreference_Key_email));
                            pref.OC_AN_Notification_Panel__c = Boolean.valueOf(setting.get(OC_AN_Constants.UserPreference_Key_notification));
                            preferences.add(pref);
                        }
                    }
                } 
                // Process product settings
                if(inputJson.product != null){
                    Map<String,Object> selectedProductsMap = inputJson.product.get(OC_AN_Constants.UserPreference_Key_selectedProducts);
                    Map<String,Object> deselectedProductsMap = inputJson.product.get(OC_AN_Constants.UserPreference_Key_deselectedProducts);
                    
                    Set<String> keys = new Set<String>();
                    Map<String, OC_AN_User_Preferences__c> keyUpMap = new Map<String, OC_AN_User_Preferences__c>();
                    
                    if(selectedProductsMap != null){
                        for(String selectedRowId: selectedProductsMap.keyset()){
                            OC_AN_User_Preferences__c pref = new OC_AN_User_Preferences__c();
                            pref.RecordTypeId = recTypeId_productSetting;
                            pref.OC_AN_User__c = userId;
                            if(currentUser != null && currentUser.ContactId != null)
                                pref.OC_AN_Contact__c = currentUser.ContactId;
                            
                            Map<Object,Object> mp =  (Map<Object,Object>) selectedProductsMap.get(selectedRowId);
                            
                            String versionRecId = '';
                            String releaseRecId = '';
                            String productRecId = '';
                            String key = '';
                            
                            String pName = String.valueOf(mp.get(OC_AN_Constants.UserPreference_Key_Name));
                            pref.Name = pName;
                            pref.OC_AN_Email__c = true;
                            // If Version
                            if(!mp.containsKey('OC_MD_Product') && mp.containsKey('OC_MD_Parent__c')){
                                String parentId = String.valueOf(mp.get('OC_MD_Parent__c'));
                                Map<Object,Object> mpParent = (Map<Object,Object>) selectedProductsMap.get(parentId);
                                
                                versionRecId = selectedRowId;
                                releaseRecId = parentId;
                                productRecId = String.valueOf(mpParent.get('OC_MD_Product'));
                                key = productRecId+releaseRecId;
                                if(keyUpMap.get(key)!=null){
                                    pref = keyUpMap.get(key);
                                }
                                
                                pref.OC_AN_Product__c = productRecId;
                                pref.OC_AN_ProductAttribute__c = releaseRecId;
                                pref.OC_AN_Version__c = versionRecId;
                                
                                keys.add(key);
                                key += versionRecId;
                                keyUpMap.put(key,pref);
                            }else
                                // If Release
                                if(mp.containsKey('OC_MD_Product') && !mp.containsKey('OC_MD_Parent__c')){
                                    releaseRecId = selectedRowId;
                                    productRecId = String.valueOf(mp.get('OC_MD_Product'));
                                    
                                    key = productRecId;
                                    if(keyUpMap.get(key) != null){
                                        pref = keyUpMap.get(key);
                                    }
                                    
                                    pref.OC_AN_Product__c = productRecId;
                                    pref.OC_AN_ProductAttribute__c = releaseRecId;
                                    
                                    keys.add(key);
                                    
                                    key += releaseRecId;
                                    if(!keys.contains(key)){
                                        keyUpMap.put(key,pref);
                                    }
                                }else
                                    // If Product
                                    if(!mp.containsKey('OC_MD_Product') && !mp.containsKey('OC_MD_Parent__c')){
                                        productRecId = selectedRowId;
                                        pref.OC_AN_Product__c = productRecId;
                                        key = productRecId;
                                        if(keyUpMap.get(key) != null){
                                            pref = keyUpMap.get(key);
                                        }
                                        if(keyUpMap.get(productRecId) == null && !keys.contains(productRecId)){
                                            keyUpMap.put(productRecId,pref);
                                        }
                                    }
                            
                            if(existingPreferenceMap.containsKey(key)){
                                OC_AN_User_Preferences__c productPref = existingPreferenceMap.get(key);
                                pref.Id = productPref.Id;
                            }
                        }
                        
                        system.debug(JSON.serialize(keyUpMap));
                        preferences.addAll(keyUpMap.values());
                    }
                    
                    // Remove unneeded product preferences
                    for(String existingKey: existingPreferenceMap.keyset()){
                        if(!existingKey.startsWith(bulletinPrefix) && !keyUpMap.keySet().contains(existingKey)){
                            preferencesToBeDeleted.add(existingPreferenceMap.get(existingKey));
                            
                        }
                    }
                    
                }
                if(preferences != null && preferences.size()>0){
                    upsert preferences;
                }
                if(preferencesToBeDeleted != null && preferencesToBeDeleted.size()>0){
                    system.debug(JSON.serialize(preferencesToBeDeleted));
                    delete preferencesToBeDeleted;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return 'success';
    }
    
    /**
* get user preferences if available in system already
*/
    @AuraEnabled
    public static UserPreferenceWrapper getCurrentUserPreference(){
        List<OC_AN_User_Preferences__c> userPreferences = [
            SELECT Id, Name, OC_AN_Account__c, OC_AN_Contact__c
            , OC_AN_Email__c, OC_AN_Notification_Panel__c, OC_AN_Product__c, OC_AN_ProductAttribute__c, OC_AN_Version__c
            , OC_AN_Version__r.OC_MD_Parent__c
            , OC_AN_ProductAttribute__r.OC_MD_Product__c, RecordTypeId, RecordType.Id
            , OC_AN_User__c 
            FROM OC_AN_User_Preferences__c
            WHERE OC_AN_User__c = :UserInfo.getUserId()];
        
        List<RecordType>  recordTypes = [
            SELECT DeveloperName, Id 
            FROM RecordType 
            WHERE DeveloperName = :OC_AN_Constants.UserPreference_RT_Bulletin 
            OR DeveloperName = :OC_AN_Constants.UserPreference_RT_Product];
        
        UserPreferenceWrapper wrapper = new UserPreferenceWrapper();
        wrapper.bulletin = new Map<String, Map<String, Object>>();
        wrapper.product = new Map<String, Map<String, Object>>();
        
        User u = [Select Id, IsPortalEnabled, ContactId from User WHERE  Id = :UserInfo.getUserId()];
        if(u.IsPortalEnabled && u.ContactId != null)
            wrapper.isCommunityUser = true;
        else
            wrapper.isCommunityUser = false;
        
        for(RecordType rt : recordTypes){
            if(rt.DeveloperName == OC_AN_Constants.UserPreference_RT_Product )
                wrapper.product.put(OC_AN_Constants.UserPreference_Key_recordType, new Map<String, Object>{OC_AN_Constants.UserPreference_Key_Id => rt.Id, OC_AN_Constants.UserPreference_Field_DeveloperName => rt.DeveloperName});
            if(rt.DeveloperName == OC_AN_Constants.UserPreference_RT_Bulletin )
                wrapper.bulletin.put(OC_AN_Constants.UserPreference_Key_recordType, new Map<String, Object>{OC_AN_Constants.UserPreference_Key_Id => rt.Id, OC_AN_Constants.UserPreference_Field_DeveloperName => rt.DeveloperName});
        }
        if(userPreferences != null && userPreferences.size() > 0) {
            for(OC_AN_User_Preferences__c pref : userPreferences){
                if(pref.recordTypeId == String.valueOf(wrapper.bulletin.get(OC_AN_Constants.UserPreference_Key_recordType).get(OC_AN_Constants.UserPreference_Key_Id)))
                    wrapper.bulletin.put(pref.Name, new Map<String, Object>{OC_AN_Constants.UserPreference_Key_email => pref.OC_AN_Email__c
                        , OC_AN_Constants.UserPreference_Key_notification => pref.OC_AN_Notification_Panel__c});
                
                if(pref.recordTypeId == String.valueOf(wrapper.product.get(OC_AN_Constants.UserPreference_Key_recordType).get(OC_AN_Constants.UserPreference_Key_Id))){
                    // Get Version
                    if(pref.OC_AN_Version__c != null ){
                        wrapper.product.put(String.valueOf(pref.OC_AN_Version__c), new Map<String, Object>{OC_AN_Constants.UserPreference_Key_email => pref.OC_AN_Email__c
                            , OC_AN_Constants.UserPreference_Key_notification => pref.OC_AN_Notification_Panel__c, OC_AN_Constants.UserPreference_Key_Name => pref.Name});
                    }else
                        // Get Release
                        if(pref.OC_AN_ProductAttribute__c != null ){
                            wrapper.product.put(String.valueOf(pref.OC_AN_ProductAttribute__c), new Map<String, Object>{OC_AN_Constants.UserPreference_Key_email => pref.OC_AN_Email__c
                                , OC_AN_Constants.UserPreference_Key_notification => pref.OC_AN_Notification_Panel__c, OC_AN_Constants.UserPreference_Key_Name => pref.Name});
                        }else
                            // Get Product
                            if(pref.OC_AN_Product__c != null ){
                                wrapper.product.put(String.valueOf(pref.OC_AN_Product__c), new Map<String, Object>{
                                    OC_AN_Constants.UserPreference_Key_email => pref.OC_AN_Email__c
                                        , OC_AN_Constants.UserPreference_Key_notification => pref.OC_AN_Notification_Panel__c, 
                                        OC_AN_Constants.UserPreference_Key_Name => pref.Name});
                            }
                } 
            }
        }else{
            Schema.SObjectType s = Schema.getGlobalDescribe().get('OC_AN_Bulletin__c') ;
            Schema.DescribeSObjectResult r = s.getDescribe() ;
            Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get('OC_AN_Type__c').getDescribe();
            for(Schema.PicklistEntry pref : fieldResult.getPicklistValues()){
                wrapper.bulletin.put(pref.getValue(), new Map<String, Object>{OC_AN_Constants.UserPreference_Key_email => false
                    , OC_AN_Constants.UserPreference_Key_notification => false});
            }
        }
        return wrapper;
    }
    
    public class ProductWrapper{
        @AuraEnabled
        public String Name{get; set;}
        @AuraEnabled
        public String Id{get; set;}
        @AuraEnabled
        public List<ReleaseWrapper> releases{get; set;}  
        @AuraEnabled
        public List<ReleaseWrapper> children{get; set;}  //To support new version - Rohit
    }
    
    public class ProductListWrapper{
        @AuraEnabled
        public List<ProductWrapper> products{get; set;}  
        @AuraEnabled 
        public Boolean isCompleted{get; set;}    
    }
    
    public class ReleaseWrapper{
        @AuraEnabled
        public String Name{get; set;}
        @AuraEnabled
        public String Id{get; set;}
        @AuraEnabled
        public String OC_MD_Product{get; set;}
        @AuraEnabled
        public List<OC_MD_ProductAttributes__c> versions{get; set;}
        @AuraEnabled
        public List<OC_MD_ProductAttributes__c> children{get; set;}  //To support new version - Rohit
    }
    
    
    public class UserPreferenceWrapper{
        @AuraEnabled 
        public Boolean isCompleted{get; set;}
        @AuraEnabled 
        public Integer offsetCount{get; set;}
        @AuraEnabled 
        public Integer productCount{get; set;}
        @AuraEnabled
        public Map<String,Map<String,Object>> bulletin{get; set;}
        @AuraEnabled
        public Map<String,Map<String,Object>> product{get; set;}
        @AuraEnabled
        public Boolean isCommunityUser{get;set;}
    }
    
    public class PreferenceWrapper{
        @AuraEnabled
        public Map<String,Map<String,Object>> bulletin{get; set;}
        @AuraEnabled
        public Map<String,Map<String,Object>> product{get; set;}
    }
    
    @AuraEnabled(cacheable=true)
    public static List<NetworkMember> getEmailSettings(){
        id userId = UserInfo.getUserId();
        List<NetworkMember> emailSetting = [SELECT Id, PreferencesDisableAllFeedsEmail,PreferencesDisableFollowersEmail,PreferencesDisableProfilePostEmail,
                                            PreferencesDisableSharePostEmail,PreferencesDisableLikeEmail,
                                            PreferencesDisableMentionsPostEmail,PreferencesDisMentionsCommentEmail,
                                            PreferencesDisableMessageEmail,PreferencesDisableEndorsementEmail,
                                            PreferencesDisableChangeCommentEmail,PreferencesDisProfPostCommentEmail,
                                            PreferencesDisableLaterCommentEmail,PreferencesDisableBookmarkEmail,
                                            PreferencesDisCommentAfterLikeEmail,PreferencesDisableItemFlaggedEmail,MemberId from NetworkMember where MemberId =: userId];
        system.debug('EmailSetting-->'+ emailSetting);
        try{
            for(NetworkMember setting: emailSetting){
                setting.PreferencesDisableAllFeedsEmail= !setting.PreferencesDisableAllFeedsEmail;
                setting.PreferencesDisableFollowersEmail =!setting.PreferencesDisableFollowersEmail;
                setting.PreferencesDisableProfilePostEmail =!setting.PreferencesDisableProfilePostEmail;
                setting.PreferencesDisableSharePostEmail =!setting.PreferencesDisableSharePostEmail;
                setting.PreferencesDisableLikeEmail = !setting.PreferencesDisableLikeEmail;
                setting.PreferencesDisableMentionsPostEmail = !setting.PreferencesDisableMentionsPostEmail;
                setting.PreferencesDisMentionsCommentEmail =!setting.PreferencesDisMentionsCommentEmail;
                setting.PreferencesDisableMessageEmail= !setting.PreferencesDisableMessageEmail;
                setting.PreferencesDisableEndorsementEmail =!setting.PreferencesDisableEndorsementEmail;
                setting.PreferencesDisableChangeCommentEmail =!setting.PreferencesDisableChangeCommentEmail;
                setting.PreferencesDisProfPostCommentEmail =!setting.PreferencesDisProfPostCommentEmail;
                setting.PreferencesDisableLaterCommentEmail=!setting.PreferencesDisableLaterCommentEmail;
                setting.PreferencesDisableBookmarkEmail= !setting.PreferencesDisableBookmarkEmail;
                setting.PreferencesDisCommentAfterLikeEmail= !setting.PreferencesDisCommentAfterLikeEmail;
                setting.PreferencesDisableItemFlaggedEmail = !setting.PreferencesDisableItemFlaggedEmail;
            }
            system.debug('EmailSetting-->'+ emailSetting);
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_UserPreferencesController,OC_TH_Constants.method_getEmailSettings,null, false, e));
        }
        return emailSetting ;
        
    }
    
    @AuraEnabled
    public static void getEmailSettingsupdates(NetworkMember u){
        System.debug('Check for User Field Value =>'+ u);
        try{
            update u;
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_UserPreferencesController,OC_TH_Constants.method_getEmailSettingsupdates,null, false, e));
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EmailAlertsWrapper> getEmailAlertSettings(){
        id userId = UserInfo.getUserId();
        User userRec;
        userRec = [Select id, ContactId from User where Id=:userId LIMIT 1];
        EmailAlertsWrapper alertsWrapper = new EmailAlertsWrapper();
        List<EmailAlertsWrapper> alertsWrapperList = new List<EmailAlertsWrapper>();
        try{
            for(Contact alert : [Select Id,OC_TH_Ticket_Notifications__c from Contact where id =: userRec.ContactId LIMIT 1]){
                if(alert.OC_TH_Ticket_Notifications__c!= null){
                    if(alert.OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getTicketCreated)){
                        alertsWrapper.isTicketCreated = true;
                    }
                    else{
                        alertsWrapper.isTicketCreated = false;
                    }
                    if(alert.OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getTicketFinished)){
                        alertsWrapper.isTicketFinished = true;
                    }
                    else{
                        alertsWrapper.isTicketFinished = false;
                    }
                    if(alert.OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getTicketCancelled)){
                        alertsWrapper.isTicketCancelled = true;
                    }
                    else {
                        alertsWrapper.isTicketCancelled = false;
                    }
                    if(alert.OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getRFICRequested)){
                        alertsWrapper.isRFICRequested = true;
                    }
                    else{
                        alertsWrapper.isRFICRequested = false;
                    }
                    
                    if(alert.OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getAnswerProvided)){
                        alertsWrapper.isAnswerProvided = true;
                    }
                    else{
                        alertsWrapper.isAnswerProvided = false;
                    }
                    if(alert.OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getRemedyProvided)){
                        alertsWrapper.isRemedyProvided = true;
                    }
                    else{
                        alertsWrapper.isRemedyProvided = false;
                    }
                    if(alert.OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getEmailNotificationsEnabled)){
                        alertsWrapper.isEmailNotificationEnabled = true;
                    }
                    else{
                        alertsWrapper.isEmailNotificationEnabled = false;
                    }
                    
                    
                }
                else{
                    system.debug('emailAlerts-->'+ alertsWrapper);
                    alertsWrapper.isTicketCreated = false;
                    alertsWrapper.isTicketFinished = false;
                    alertsWrapper.isTicketCancelled = false;
                    alertsWrapper.isRFICRequested = false;
                    alertsWrapper.isRemedyProvided = false;
                    alertsWrapper.isAnswerProvided = false;
                    alertsWrapper.isEmailNotificationEnabled = false;
                }
            }
            system.debug('emailAlerts-->'+ alertsWrapper);
            alertsWrapperList.add(alertsWrapper);
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_UserPreferencesController,OC_TH_Constants.method_getEmailAlertSettings,null, false, e));
        }
        
        return alertsWrapperList ;  
    }
    /*********************************************************************************
* @Description : This method is used to deserialize the User Preference data from Email 
Notifications LWC component.
* @Params      : jsonInput - Passing User Preferences in JSON format.
* @Params      : contactId - Passing contact Id.
**********************************************************************************/        
    @AuraEnabled
    public static void submitUserPreferences(String jsonInput,String contactId){
        Map <String,Object> records   = (Map <String,Object>)JSON.deserializeuntyped(jsonInput);
        Map <String,Boolean> booleanMap   = new Map<String,Boolean>();
        system.debug('Json>>>' +jsonInput);
        try{
            for(String str : records.keySet()){
                booleanMap.put(str,boolean.valueOf(records.get(str)));
            }
            System.debug('Alerts:--'+booleanMap);
            for(String str : booleanMap.keySet()){
                if(booleanMap.get(str)){
                    
                    checkSelectedState(str,OC_TH_Constants.getChecked,contactId);
                    
                }
                else{
                    
                    checkSelectedState(str,OC_TH_Constants.getUnchecked,contactId);
                }
                
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_UserPreferencesController,OC_TH_Constants.method_submitUserPreferences,null, false, e));
        }
    }
    
    /**************************************************************************************************
* @Description : This method stamps the alert names to Ticket Notifications technical field on Contact. 
* Params       : alerts - pass alert name from submitUserPreferences method
* Params       : selectedState - pass selected status from submitUserPreferences method
* Params       : contactId - pass Contact ID from from submitUserPreferences method
*******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    Public static void checkSelectedState(String alerts, String selectedState,Id contactId){
        String delimiter = OC_TH_Constants.getHashTagDelimiter;
        String alertsVl = '';
        String addAlert = '';
        Set<String> alertsSet = new Set<String>();
        Contact conRec = [SELECT Id,OC_TH_Ticket_Notifications__c From Contact Where ID =: contactId];
        system.debug('condition--'+(conRec.OC_TH_Ticket_Notifications__c != Null));
        try{
            /*Split the Alert Names from text field and add it to Set */
            if(conRec.OC_TH_Ticket_Notifications__c != Null ){
                alertsVl =  conRec.OC_TH_Ticket_Notifications__c;
                String [] splitIdText = conRec.OC_TH_Ticket_Notifications__c.split(OC_TH_Constants.getHashTagDelimiter);
                alertsSet.addAll(splitIdText);    
                system.debug('alertsSet' + alertsSet);
            }
            system.debug('Alerts' + alerts);
            /*If Status is "Checked" then pass an Alert Name with delimiter to Custom field */
            if(selectedState != Null && selectedState == OC_TH_Constants.getChecked && alertsSet != Null && !alertsSet.contains(alerts)){
                alertsVl =  alerts + delimiter + alertsVl;
                system.debug('alertsVl' + alertsVl);
                String alertName = alertsVl.removeEnd(OC_TH_Constants.getHashTagDelimiter);
                system.debug('alertName' + alertName);
                system.debug('conRecID' + conRec.Id);
                alertInsertion(conRec.Id,alertName);
                
            }
            /*If Status is "UnChecked" then remove an Alert Name from Custom field */
            if(selectedState != Null && selectedState == OC_TH_Constants.getUnchecked && alertsSet != Null){
                alertsSet.remove(alerts);
                system.debug('alertsSet' + alertsSet);                    
                
                /*Add remaining Alert names that are in alertsSet */
                if(!alertsSet.isEmpty() && !alertsSet.contains(alerts)){
                    for(String currAlert : alertsSet){
                        addAlert =  currAlert + delimiter + addAlert;
                        String alertName = addAlert.removeEnd(OC_TH_Constants.getHashTagDelimiter);
                        alertInsertion(conRec.Id,alertName);
                    }
                }
                else{
                    alertInsertion(conRec.Id,null);
                }
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_UserPreferencesController,OC_TH_Constants.method_checkSelectedState,null, false, e));
        }
    }
    /**************************************************************************************************
* @Description : This method handles Alert insertion and deletion of field update.
* @Params       : alertName - pass Alert name from "checkSelectedState" method to Insert record
* @Params       : contactId - pass contact ID from "checkSelectedState" method to Insert record
* @Return       : return sucess status once Alert is inserted or Removed
*******************************************************************************************************/
    public static String alertInsertion(String contactId,String alertName){
        
        List<Contact> contactList = new List<Contact>();
        map<id,Contact> contactMap = new map<id,Contact>();
        map<id,Contact> mapAlertsToContact = new map<id,Contact>();  
        
        try{ /*Stamp alertName Value in custom field */
            if(String.isNotBlank(alertName)){
                Contact currContact = new Contact();
                currContact.Id = contactId;
                currContact.OC_TH_Ticket_Notifications__c = alertName;
                contactList.add(currContact);
                contactMap.putAll(contactList);
            }
            /*Reset custom field when alertName is Null or Empty */
            else if(String.isBlank(alertName)){
                Contact currContact = new Contact();
                currContact.Id = contactId;
                currContact.OC_TH_Ticket_Notifications__c = '';
                contactList.add(currContact);
                mapAlertsToContact.putAll(contactList); 
            }
            if(contactMap.size()>0){
                Database.update(contactMap.values());
            }
            if(mapAlertsToContact.size()>0){
                Database.update(mapAlertsToContact.values());
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_UserPreferencesController,OC_TH_Constants.method_alertInsertion,null, false, e));
        }
        return OC_TH_Constants.getSuccess;
    }
    public class EmailAlertsWrapper {
        @AuraEnabled
        public Boolean isTicketCreated{get; set;}
        @AuraEnabled
        public Boolean isTicketFinished{get; set;}
        @AuraEnabled
        public Boolean isTicketCancelled{get; set;}
        @AuraEnabled
        public Boolean isRFICRequested{get; set;}
        @AuraEnabled
        public Boolean isRemedyProvided{get; set;}
        @AuraEnabled
        public Boolean isAnswerProvided{get; set;}
        @AuraEnabled
        public Boolean isEmailNotificationEnabled{get; set;}
    }
    
    
}