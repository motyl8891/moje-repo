/**
* @File Name          : OC_Product_UploadDataController
* @Description        : Provide controller for component c:OC_Product_UploadData to upload products node type data
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 20th July 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
**/
public with sharing class OC_Product_UploadDataController {
    private static final Constants constants = new Constants();
    
    @AuraEnabled
    public static Integer getMaxRecordCount(){
        return Integer.valueOf(OC_Org_Defaults__c.getOrgDefaults().OC_ProductUploadScriptMaxRecords__c);
    }
    
    /*@params dataString - JSON of CSV*/
    /*Transfrom data from CSV File into SF Objects Instances*/
    @AuraEnabled
    public static List<String> processData(String dataString){
        List<ProductWrapper> datalist = (List<ProductWrapper>)JSON.deserialize(dataString, List<ProductWrapper>.class);
        Map<String, ProductWrapper> mapOfProductWrappers = new Map<String, ProductWrapper>();
        Map<Id, String> returnMsgs = new Map<Id, String>();
        Map<String, String> mapOfReleaseAndProducts = new Map<String, String>();
        Map<String, String> mapOfVersionReleaseAndProducts = new Map<String, String>();
        Map<String, ProductWrapper> mapOfProductWrappersWithRV = new Map<String, ProductWrapper>();
        
        Map<String, Product2> mapOfProductsInSF = new Map<String, Product2>();
        Map<String, OC_MD_ProductAttributes__c> mapOfReleasesInSF = new Map<String, OC_MD_ProductAttributes__c>();
        Map<String, OC_MD_ProductAttributes__c> mapOfVersionsInSF = new Map<String, OC_MD_ProductAttributes__c>();
        
        Map<String, Product2> mapOfProductsToBeModified = new Map<String, Product2>();
        Map<String, OC_MD_ProductAttributes__c> mapOfReleasesToBeModified = new Map<String, OC_MD_ProductAttributes__c>();
        Map<String, OC_MD_ProductAttributes__c> mapOfVersionsToBeModified = new Map<String, OC_MD_ProductAttributes__c>();
        
        Map<String, Set<String>> serviceModelMap = new Map<String, Set<String>>();
        Map<String, Set<String>> hwPlatformMap = new Map<String, Set<String>>();
        Map<String, Set<String>> technologyStdMap = new Map<String, Set<String>>();
        Map<String, Set<String>> errorsMap = new Map<String, Set<String>>();
        Map<String, Pricebook2> priceBooks = new Map<String, Pricebook2>();
        
        for(Pricebook2 pb : [SELECT Id, Name  From Pricebook2 WHERE Name = :constants.PC_NAME_SERVICE_CATALOG OR Name = :constants.PC_NAME_STANDARD_PRICE_BOOK]){
            priceBooks.put(pb.Name, pb);
        }
        
        for(ProductWrapper pW : datalist){
            if(pW.Name != null && !String.isEmpty(pW.Name)){
                mapOfProductWrappers.put(pW.Name, pW);
                mapOfReleaseAndProducts.put(getPatternKeyFor(pW.Name, pW.ProductRelease, null), pW.ProductRelease);
                mapOfVersionReleaseAndProducts.put(getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion), pW.ProductVersion);
                mapOfProductWrappersWithRV.put(pW.Name, pW);
                mapOfProductWrappersWithRV.put(getPatternKeyFor(pW.Name, pW.ProductRelease, null), pW);
                mapOfProductWrappersWithRV.put(getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion), pW);
            }
        }
        
        for(Product2 productItem : [SELECT Id, isActive, Product_Code_Number__c, Name, OC_MD_Product_Service_Model__c, OC_MD_Platform__c, OC_MD_Technology_Standard__c FROM Product2 WHERE Name IN :mapOfProductWrappers.keySet() and RecordTypeId = :constants.PRODUCT_RCTYPE_ID_NODETYPE]){
            if(productItem.isActive){
                mapOfProductsInSF.put(productItem.Name, productItem);                
                serviceModelMap.put(productItem.Name, getPicklistSetFromString(productItem.OC_MD_Product_Service_Model__c));
                hwPlatformMap.put(productItem.Name, getPicklistSetFromString(productItem.OC_MD_Platform__c));
                technologyStdMap.put(productItem.Name, getPicklistSetFromString(productItem.OC_MD_Technology_Standard__c));
            }
        }
        
        for(ProductWrapper pW : datalist){
            // Get the product from the System if already exists
            Product2 product = mapOfProductsInSF.get(pW.Name);
            // Create the Product newly if not exixts in System
            if(product == null && pW.Name != null && !String.isEmpty(pW.Name)){
                product = new Product2();
                product.Name = pW.Name;
                product.isActive = True;
                product.RecordTypeId = constants.PRODUCT_RCTYPE_ID_NODETYPE;
                //product.Product_Code_Number__c = generateRandomString(4);
            }
            // Check if Product is active before updating the values
            if(product != null && product.IsActive){
                // Check the Service Model in system. If not exists append it with the string seperated by ;
                serviceModelMap = processMultiPicklist(serviceModelMap, pW.Name, pW.ProductModel);
                product.OC_MD_Product_Service_Model__c = formatPicklist(serviceModelMap.get(pW.Name));
                serviceModelMap = processMultiPicklist(serviceModelMap, getPatternKeyFor(pW.Name, pW.ProductRelease, null), pW.ProductModel);
                serviceModelMap = processMultiPicklist(serviceModelMap, getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion), pW.ProductModel);              
                
                // Check the Hardware platform. If not exists append it with the String seperated by ; 
                hwPlatformMap = processMultiPicklist(hwPlatformMap, pW.Name, pW.HardwarePlatform);
                product.OC_MD_Platform__c  = formatPicklist(hwPlatformMap.get(pW.Name));
                hwPlatformMap = processMultiPicklist(hwPlatformMap, getPatternKeyFor(pW.Name, pW.ProductRelease, null), pW.HardwarePlatform);
                hwPlatformMap = processMultiPicklist(hwPlatformMap, getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion), pW.HardwarePlatform);              
                
                // Check the Technology Standard. If not exists append it with the String seperated by ;
                technologyStdMap = processMultiPicklist(technologyStdMap, pW.Name, pW.TechnologyStandard);
                product.OC_MD_Technology_Standard__c = formatPicklist(processTechnologyStds(technologyStdMap.get(pW.Name)));
                technologyStdMap = processMultiPicklist(technologyStdMap, getPatternKeyFor(pW.Name, pW.ProductRelease, null), pW.TechnologyStandard);
                technologyStdMap = processMultiPicklist(technologyStdMap, getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion), pW.TechnologyStandard);              
                // add to the map to update / insert the Product
                mapOfProductsToBeModified.put(pW.Name, product);
            }
        }
        DatabaseHandler db = new DatabaseHandler(constants.KEY_PRODUCT, mapOfProductWrappersWithRV,mapOfProductsToBeModified,mapOfProductsInSF, errorsMap);
        db.execute();
        mapOfProductWrappersWithRV = (Map<String, ProductWrapper>) db.mapOfProductWrappersWithRV;
        mapOfProductsToBeModified = (Map<String, Product2>) db.recordsToBeModified;
        mapOfProductsInSF = (Map<String, Product2>) db.recordsInSF;
        errorsMap = db.errorsMap;
        
        /** PROCESS Price Books */
        Map<Id, String> productIds = new Map<Id, String>();
        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 p: mapOfProductsToBeModified.values()){
            if(p.Id != null){
                productIds.put(p.Id, p.Name);
            }
            productMap.put(p.Name,p);
        }
        
        Map<String, PricebookEntry> mapOfPriceBooksInSF = new Map<String, PricebookEntry>();
        for(PricebookEntry pb: [Select Id, Name, UnitPrice, IsActive, Product2Id, Pricebook2Id From PricebookEntry WHERE Pricebook2.Name IN :priceBooks.keySet() AND Product2Id IN :productIds.keySet()]){
            mapOfPriceBooksInSF.put(pb.Name + constants.PATTERN_SEP_PRICEBOOK+ pb.Pricebook2Id, pb);
        }
        Map<String, PricebookEntry> mapOfPriceBooksToBeModified = new Map<String, PricebookEntry>();
        
        if(productIds != null){
            for(String prName : productIds.values()){
                PricebookEntry priceBookStd = mapOfPriceBooksInSF.get(getPatternKeyFor(prName, constants.PC_NAME_STANDARD_PRICE_BOOK));
                if(priceBookStd == null && productMap.get(prName) != null && priceBooks.get(constants.PC_NAME_STANDARD_PRICE_BOOK) != null){
                    priceBookStd = new PricebookEntry();
                    priceBookStd.UnitPrice = 0.0;
                    priceBookStd.IsActive = true;
                    priceBookStd.Product2Id = productMap.get(prName).Id;
                    priceBookStd.Pricebook2Id = priceBooks.get(constants.PC_NAME_STANDARD_PRICE_BOOK).Id;
                    mapOfPriceBooksToBeModified.put(getPatternKeyFor(prName, constants.PC_NAME_STANDARD_PRICE_BOOK), priceBookStd);
                }
                
                PricebookEntry priceBookSer = mapOfPriceBooksInSF.get(getPatternKeyFor(prName, constants.PC_NAME_SERVICE_CATALOG));
                if(priceBookSer == null && productMap.get(prName) != null && priceBooks.get(constants.PC_NAME_SERVICE_CATALOG) != null){
                    priceBookSer = new PricebookEntry();
                    priceBookSer.UnitPrice = 0;
                    priceBookSer.IsActive = true;
                    priceBookSer.Product2Id = productMap.get(prName).Id;
                    priceBookSer.Pricebook2Id = priceBooks.get(constants.PC_NAME_SERVICE_CATALOG).Id;
                    mapOfPriceBooksToBeModified.put(getPatternKeyFor(prName, constants.PC_NAME_SERVICE_CATALOG), priceBookSer);
                }
            }
        }
        
        DatabaseHandler dbpb = new DatabaseHandler(priceBooks,mapOfPriceBooksToBeModified, mapOfPriceBooksInSF, errorsMap);
        dbpb.executePriceBooks();
        mapOfPriceBooksToBeModified = (Map<String, PricebookEntry>) dbpb.recordsToBeModified;
        mapOfPriceBooksInSF = (Map<String, PricebookEntry>) dbpb.recordsInSF;
        errorsMap = dbpb.errorsMap;
        
        List<RecordType> recordTypes = [SELECT id, Name From RecordType WHERE SObjectType =: constants.OBJECT_NAME_RELEASEVERSION];
        Map<String, Id> mapOfRecordTypes = new Map<String, Id>();
        
        // Set Record Types of Release
        for(RecordType rt: recordTypes){
            mapOfRecordTypes.put(rt.Name, rt.Id);
        }
        for(OC_MD_ProductAttributes__c rItem : [SELECT Id, Name, RecordType.Name, OC_MD_GA__c, OC_MD_EoM__c, OC_MD_EOS__c, OC_MD_Product__c, OC_MD_Product__r.Name FROM OC_MD_ProductAttributes__c WHERE Name IN :mapOfReleaseAndProducts.values() AND  OC_MD_Product__r.Name IN :mapOfProductWrappers.keySet() AND RecordType.Name = :constants.RECORD_TYPE_RELEASE]){
            mapOfReleasesInSF.put(getPatternKeyFor(rItem.OC_MD_Product__r.Name, rItem.Name, null), rItem);
        }
        for(ProductWrapper pW : datalist){
            OC_MD_ProductAttributes__c release = mapOfReleasesInSF.get(getPatternKeyFor(pW.Name, pW.ProductRelease, null));
            if(release == null){
                release = mapOfReleasesToBeModified.get(getPatternKeyFor(pW.Name, pW.ProductRelease, null));
            }
            if(release == null && pW.ProductRelease != null && !String.isEmpty(pW.ProductRelease) && pW.Name != null && !String.isEmpty(pW.Name)){
                release = new OC_MD_ProductAttributes__c();
                release.Name = pW.ProductRelease;
                release.RecordTypeId = mapOfRecordTypes.get(constants.RECORD_TYPE_RELEASE);
                if(mapOfProductsInSF.get(pW.Name) != null && mapOfReleaseAndProducts.get(getPatternKeyFor(pW.Name, pW.ProductRelease, null)) == pW.ProductRelease)
                {
                    release.OC_MD_Product__c = mapOfProductsInSF.get(pW.Name).Id;
                    release.OC_MD_Product__r = mapOfProductsInSF.get(pW.Name);
                }
            }
            if(release != null)
            {
                if(pW.GA != null && !String.isEmpty(pW.GA)){
                    release.OC_MD_GA__c = Date.parse(pW.GA);
                }
                if(pW.EOM != null && !String.isEmpty(pW.EOM)){
                    release.OC_MD_EoM__c = Date.parse(pW.EOM);
                }
                if(pW.EOS != null && !String.isEmpty(pW.EOS)){
                    release.OC_MD_EOS__c = Date.parse(pW.EOS);
                }
                mapOfReleasesToBeModified.put(getPatternKeyFor(pW.Name, pW.ProductRelease, null), release);
            }
        }
        DatabaseHandler dbRel = new DatabaseHandler(constants.KEY_RELEASE,mapOfProductWrappersWithRV,mapOfReleasesToBeModified,mapOfReleasesInSF, errorsMap);
        dbRel.execute();
        mapOfProductWrappersWithRV = (Map<String, ProductWrapper>) dbRel.mapOfProductWrappersWithRV;
        mapOfReleasesToBeModified = (Map<String, OC_MD_ProductAttributes__c>) dbRel.recordsToBeModified;
        mapOfReleasesInSF = (Map<String, OC_MD_ProductAttributes__c>) dbRel.recordsInSF;
        errorsMap = dbRel.errorsMap;
        
        for(OC_MD_ProductAttributes__c rItem : [SELECT Id, Name, RecordType.Name, OC_MD_PRIM_No__c, 
                                                OC_MD_Parent__c, OC_MD_Parent__r.Name, 
                                                OC_MD_Parent__r.OC_MD_Product__c,
                                                OC_MD_Parent__r.OC_MD_Product__r.Name 
                                                FROM OC_MD_ProductAttributes__c 
                                                WHERE Name IN :mapOfVersionReleaseAndProducts.values()
                                                AND OC_MD_Parent__r.Name IN :mapOfReleaseAndProducts.values()
                                                AND  OC_MD_Parent__r.OC_MD_Product__r.Name IN :mapOfProductWrappers.keySet()
                                                AND RecordType.Name = :constants.RECORD_TYPE_VERSION]){
                                                    mapOfVersionsInSF.put(getPatternKeyFor(rItem.OC_MD_Parent__r.OC_MD_Product__r.Name, rItem.OC_MD_Parent__r.Name, rItem.Name), rItem);
                                                }
        for(ProductWrapper pW : datalist){
            OC_MD_ProductAttributes__c version = mapOfVersionsInSF.get(getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion));
            if(version == null){
                version = mapOfVersionsToBeModified.get(getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion));
            }
            if(version == null && pW.ProductVersion != null && !String.isEmpty(pW.ProductVersion) && pW.ProductRelease != null && !String.isEmpty(pW.ProductRelease) && pW.Name != null && !String.isEmpty(pW.Name)){
                version = new OC_MD_ProductAttributes__c();
                version.Name = pW.ProductVersion;
                version.RecordTypeId = mapOfRecordTypes.get(constants.RECORD_TYPE_VERSION);
                if(mapOfReleasesInSF.get(getPatternKeyFor(pW.Name, pW.ProductRelease, null)) != null 
                   && mapOfReleaseAndProducts.get(getPatternKeyFor(pW.Name, pW.ProductRelease, null)) == pW.ProductRelease && mapOfVersionReleaseAndProducts.get(getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion)) == pW.ProductVersion){
                       version.OC_MD_Parent__c = mapOfReleasesInSF.get(getPatternKeyFor(pW.Name, pW.ProductRelease, null)).Id;
                       version.OC_MD_Parent__r = mapOfReleasesInSF.get(getPatternKeyFor(pW.Name, pW.ProductRelease, null));
                   }
            }
            if(version != null){
                if(pW.PrimNo != null && !String.isEmpty(pW.PrimNo)){
                    version.OC_MD_PRIM_No__c = pW.PrimNo;
                }
                mapOfVersionsToBeModified.put(getPatternKeyFor(pW.Name, pW.ProductRelease, pW.ProductVersion), version);
            }
        }
        DatabaseHandler dbVer = new DatabaseHandler(constants.KEY_VERSION,mapOfProductWrappersWithRV,mapOfVersionsToBeModified,mapOfVersionsInSF, errorsMap);
        dbVer.execute();
        mapOfProductWrappersWithRV = (Map<String, ProductWrapper>) dbVer.mapOfProductWrappersWithRV;
        mapOfVersionsToBeModified = (Map<String, OC_MD_ProductAttributes__c>) dbVer.recordsToBeModified;
        mapOfVersionsInSF = (Map<String, OC_MD_ProductAttributes__c>) dbVer.recordsInSF;
        errorsMap = dbVer.errorsMap;
        
        Map<String, String> returnMap = new Map<String, String>();
        List<String> ls= new List<String>();
        for(ProductWrapper pw: mapOfProductWrappersWithRV.values()){
            ProductWrapper pWrapper = mapOfProductWrappersWithRV.get(getPatternKeyFor(pw.Name, pw.ProductRelease, pw.ProductVersion));
            pWrapper.HardwarePlatform = formatPicklist(hwPlatformMap.get(pw.Name));
            pWrapper.TechnologyStandard = formatPicklist(technologyStdMap.get(pw.Name));
            pWrapper.ProductModel = formatPicklist(serviceModelMap.get(pw.Name));
            if(pWrapper.EOS == null || pWrapper.EOS == 'null'){
                pWrapper.EOS = '';
            }
            if(pWrapper.EOM == null || pWrapper.EOM == 'null'){
                pWrapper.EOM = '';
            }
            if(pWrapper.GA == null || pWrapper.GA == 'null'){
                pWrapper.GA = '';
            }
            if(pWrapper.PrimNo == null || pWrapper.PrimNo == 'null'){
                pWrapper.PrimNo = '';
            }
            
            pWrapper.errorsForCSV = '';
            /* PRODUCT Errors */
            if(pWrapper.errorsForCSV != null && pWrapper.errorsForCSV != 'null' && errorsMap.get(pw.Name) != null){
                pWrapper.errorsForCSV = pWrapper.errorsForCSV + formatPicklist(errorsMap.get(pw.Name)); // Get System Errors for Product
            }
            if(pWrapper.errorsForCSV == null || pWrapper.errorsForCSV == 'null'){
                pWrapper.errorsForCSV = '';
            }
            
            /* PRICE BOOK Errors */
            if(pWrapper.errorsForCSV != null && pWrapper.errorsForCSV != 'null'){
                if(errorsMap.get(getPatternKeyFor(pw.Name, constants.PC_NAME_SERVICE_CATALOG)) != null){
                    pWrapper.errorsForCSV = pWrapper.errorsForCSV + formatPicklist(errorsMap.get(getPatternKeyFor(pw.Name, constants.PC_NAME_SERVICE_CATALOG)));
                }
                if(errorsMap.get(getPatternKeyFor(pw.Name, constants.PC_NAME_STANDARD_PRICE_BOOK)) != null){
                    pWrapper.errorsForCSV = pWrapper.errorsForCSV + formatPicklist(errorsMap.get(getPatternKeyFor(pw.Name, constants.PC_NAME_STANDARD_PRICE_BOOK)));
                }
            }
            
            if(pWrapper.errorsForCSV == null || pWrapper.errorsForCSV == 'null'){
                pWrapper.errorsForCSV = '';
            }
            /* RELEASE Errors */
            if(pWrapper.errorsForCSV != null && pWrapper.errorsForCSV != 'null' && errorsMap.get(getPatternKeyFor(pw.Name, pw.ProductRelease, null)) != null){
                pWrapper.errorsForCSV = pWrapper.errorsForCSV + formatPicklist(errorsMap.get(getPatternKeyFor(pw.Name, pw.ProductRelease, null))); // Get System Errors for Product
            }
            if(pWrapper.errorsForCSV == null || pWrapper.errorsForCSV == 'null'){
                pWrapper.errorsForCSV = '';
            }
            if(String.isEmpty(pWrapper.ProductRelease) && !String.isEmpty(pWrapper.ProductVersion) && !pWrapper.errorsForCSV.contains(constants.ERROR_RELEASE)){
                pWrapper.errorsForCSV = pWrapper.errorsForCSV + constants.ERROR_RELEASE;
            }
            /* VERSION VALUES */           
            if(pWrapper.errorsForCSV != null && pWrapper.errorsForCSV != 'null' && errorsMap.get(getPatternKeyFor(pw.Name, pw.ProductRelease, pw.ProductVersion)) != null){
                pWrapper.errorsForCSV = pWrapper.errorsForCSV + formatPicklist(errorsMap.get(getPatternKeyFor(pw.Name, pw.ProductRelease, pw.ProductVersion))); // Get System Errors for Product
            }
            if(pWrapper.errorsForCSV == null || pWrapper.errorsForCSV == 'null'){
                pWrapper.errorsForCSV = '';
            }
            if(String.isEmpty(pWrapper.ProductVersion) && !String.isEmpty(pWrapper.PrimNo) && !pWrapper.errorsForCSV.contains(constants.ERROR_VERSION)){
                pWrapper.errorsForCSV = pWrapper.errorsForCSV + constants.ERROR_VERSION;
            }
            returnMap.put(getPatternKeyFor(pw.Name, pw.ProductRelease, pw.ProductVersion), JSON.serialize(pWrapper));
        }
        
        for(ProductWrapper pw : datalist){
            if(pw.Name == null || (pw.Name != null && String.isEmpty(pw.Name ))){
                pw.errorsForCSV = constants.ERROR_PRODUCT;
                ls.add(JSON.serialize(pw));
            }
        }
        ls.addAll(returnMap.values());
        return ls;
    }
    
    /*Get list of values of picklist provided the String Reverse of formatPicklist method*/
    private static Set<String> getPicklistSetFromString(String str){
        Set<String> rrr = new Set<String>();
        if(str != null && str.contains(constants.DELIMITER)){
            rrr.addAll(str.split(constants.DELIMITER));
        }
        else if(str != null && str.contains(',')){
            rrr.addAll(str.split(','));
        }
        else if(str != null){
            rrr.add(str);
        }
        return rrr;
    }
    
    /* Check if provided value is already in the system and update if not exists */
    private static Map<String, Set<String>> processMultiPicklist(Map<String, Set<String>> mapOfPickList, String key, String value){
        Set<String> s = mapOfPickList.get(key);
        if(value != null && !String.isEmpty(value)){
            if(s != null && !s.contains(value)){
                s.add(value);
            }
            else if(s == null){
                s = new Set<String>();
                s.add(value);
            }
        }
        mapOfPickList.put(key, s);
        return mapOfPickList;
    }
    
    /*Format recived value of technology stanadards to field specific*/
    private static Set<String> processTechnologyStds(Set<String> setRawTechStds){
        Set<String> setTechStds = new Set<String>();
        if(setRawTechStds != NULL){
            for(String temp :setRawTechStds){
                setTechStds.addAll(temp.trim().split(''));
            }
        }
        return setTechStds;
    }
    
    /* Generate String separated by ; for multipicklists and Service Model */ 
    private static String formatPicklist(Set<String> StrSet){
        String returnStr = '';
        if(StrSet != null){
            for(String s: StrSet)
            {
                if(s != null && !String.isEmpty(s) && !String.isBlank(s) && !String.isEmpty(returnStr) && !String.isBlank(returnStr)){
                    returnStr = returnStr + constants.DELIMITER + s;
                }
                else if(s != null && !String.isEmpty(s) && !String.isBlank(s)){
                    returnStr = s;
                }
            }
        }
        return (returnStr != null && !String.isEmpty(returnStr) && !String.isBlank(returnStr))? returnStr: '';
    }
    
    /* Pattern is unique for Product, Product + Release, Product + Release + Version */
    private static String getPatternKeyFor(String ProductName, String ProductCatalogName){
        if(ProductName != null && ProductCatalogName != null){
            return ProductName + constants.PATTERN_SEP_PRICEBOOK+ ProductCatalogName;
        }
        else{
            return '';
        }
    }
    private static String getPatternKeyFor(String ProductName, String ReleaseName, String VersionName){
        String patternType;
        if(ProductName != null && ReleaseName != null && VersionName != null){
            patternType = ProductName + constants.PATTERN_SEP_RELEASE + ReleaseName + constants.PATTERN_SEP_VERSION + VersionName;
        }
        if(ProductName != null && ReleaseName != null && VersionName == null){
            patternType = ProductName + constants.PATTERN_SEP_RELEASE + ReleaseName;
        }
        return patternType;
    }
    
    
    /* Return error as string from Database.Error list returned by DML */
    private static String getErrorMsg(List<Database.Error> errors){
        String msg = '';
        if(errors != null && errors.size()>=1 && errors.get(0).getMessage() != null &&  errors.get(0).getMessage() != 'null'){
            msg = errors.get(0).getMessage() +'; ';
        }
        return msg;
    }
    
    /* Inner class to handle Database operations - Partial Save */
    public class DatabaseHandler {
        public Map<String, Object> mapOfProductWrappersWithRV;
        public Map<String, SObject> recordsToBeModified;
        public Map<String, SObject> recordsInSF;
        public Map<String, Set<String>> errorsMap;
        public String typesName;
        public Map<String, Pricebook2> priceBooks;
        public DatabaseHandler(String typesName, Map<String, Object> mapOfProductWrappersWithRV, Map<String, SObject> recordsToBeModified, Map<String, SObject> recordsInSF, Map<String, Set<String>> errorsMap){
            this.typesName = typesName;
            this.mapOfProductWrappersWithRV = mapOfProductWrappersWithRV;
            this.recordsToBeModified = recordsToBeModified;
            this.recordsInSF = recordsInSF;
            this.errorsMap = errorsMap;
        }
        
        public DatabaseHandler(Map<String, Pricebook2> priceBooks, Map<String, SObject> recordsToBeModified, Map<String, SObject> recordsInSF, Map<String, Set<String>> errorsMap){
            this.recordsToBeModified = recordsToBeModified;
            this.priceBooks = priceBooks;
            this.recordsInSF = recordsInSF;
            this.errorsMap = errorsMap;
        }
        
        /*Execute upsert for PriceBookEntries from the prepared data*/
        public void executePriceBooks(){
            //productIds
            List<Database.UpsertResult> results = Database.upsert(recordsToBeModified.values(), false);
            for(integer i = 0; i<results.size();i++){  
                PricebookEntry pbe = (PricebookEntry) recordsToBeModified.values().get(i);
                String key = '';
                if(priceBooks.get(constants.PC_NAME_STANDARD_PRICE_BOOK) != null && priceBooks.get(constants.PC_NAME_STANDARD_PRICE_BOOK).Id == pbe.Pricebook2Id){
                    key = getPatternKeyFor(pbe.Name, constants.PC_NAME_STANDARD_PRICE_BOOK);
                }
                if(priceBooks.get(constants.PC_NAME_SERVICE_CATALOG) != null && priceBooks.get(constants.PC_NAME_SERVICE_CATALOG).Id == pbe.Pricebook2Id){
                    key = getPatternKeyFor(pbe.Name, constants.PC_NAME_SERVICE_CATALOG);
                }
                Set<String> strSet = errorsMap.get(key);
                if(strSet == null){
                    strSet = new Set<String>();
                }
                strSet.add(getErrorMsg(results[i].getErrors()));
                errorsMap.put(key, strSet);
            }
        }
        
        /*Execute upsert for Products from the prepared data*/
        public void execute(){
            List<Database.UpsertResult> results = Database.upsert(recordsToBeModified.values(), false);
            for(integer i = 0; i<results.size();i++){   
                String key;
                String pattern;
                if(typesName ==constants.KEY_PRODUCT){
                    key = ((Product2) recordsToBeModified.values()[i]).Name; // PRODUCT NAME
                }
                OC_MD_ProductAttributes__c rv;
                ProductWrapper pW = (ProductWrapper) mapOfProductWrappersWithRV.get(key);
                if(typesName ==constants.KEY_RELEASE){
                    rv = (OC_MD_ProductAttributes__c) recordsToBeModified.values()[i];
                    key = getPatternKeyFor(rv.OC_MD_Product__r.Name, rv.Name, null);
                    pattern = getPatternKeyFor(rv.OC_MD_Product__r.Name, rv.Name, null);
                    rv = (OC_MD_ProductAttributes__c) recordsToBeModified.get(pattern);
                }
                if(typesName ==constants.KEY_VERSION){
                    rv  = (OC_MD_ProductAttributes__c) recordsToBeModified.values()[i];
                    key = getPatternKeyFor(rv.OC_MD_Parent__r.OC_MD_Product__r.Name, rv.OC_MD_Parent__r.Name, rv.Name);
                    pattern = getPatternKeyFor(rv.OC_MD_Parent__r.OC_MD_Product__r.Name, rv.OC_MD_Parent__r.Name, rv.Name);                
                    rv = (OC_MD_ProductAttributes__c) recordsToBeModified.get(pattern);
                }
                if(typesName == constants.KEY_PRODUCT){
                    Product2 product = (Product2) recordsToBeModified.get(((Product2) recordsToBeModified.values()[i]).Name);
                    if(results[i].isSuccess() &&  product != null){
                        product.Id = results[i].getId();
                        if(pW != null){
                            pW.recordId = results[i].getId();
                        }
                        recordsInSF.put(key, product);
                        mapOfProductWrappersWithRV.put(key, pW);
                    }
                }
                pW = (ProductWrapper) mapOfProductWrappersWithRV.get(key);
                if(typesName == constants.KEY_RELEASE || typesName == constants.KEY_VERSION){
                    if(results[i].isSuccess() &&  rv != null){
                        rv.Id = results[i].getId();
                        if(pW != null && typesName == constants.KEY_RELEASE){
                            pW.recordId = rv.OC_MD_Product__c;
                            pW.ReleaseId = results[i].getId();
                        }
                        
                        if(pW != null && typesName == constants.KEY_VERSION){
                            pW.recordId = rv.OC_MD_Parent__r.OC_MD_Product__c;
                            pW.ReleaseId = rv.OC_MD_Parent__c;
                            pW.VersionId = results[i].getId();
                        }
                        
                        recordsInSF.put(key, rv);
                    }
                }
                if(pW != null){
                    Set<String> strSet = errorsMap.get(key);
                    if(strSet == null){
                        strSet = new Set<String>();
                    }
                    strSet.add(getErrorMsg(results[i].getErrors()));
                    errorsMap.put(key, strSet);
                    pW.errorsForCSV = formatPicklist(strSet);
                    mapOfProductWrappersWithRV.put(key, pW);
                }
            }
        }
    }
    
    /*Constants for the parent class*/
    public class Constants{ 
        public final String PC_NAME_STANDARD_PRICE_BOOK = 'Standard Price Book';
        public String PC_NAME_SERVICE_CATALOG = 'Service Catalog';
        public final String KEY_PRODUCT = 'PRODUCT';
        public final String PATTERN_SEP_PRICEBOOK = '___PB_ENTRY___';
        public final String RECORD_TYPE_RELEASE = 'Release';
        public final String KEY_RELEASE = 'RELEASE';
        public final String RECORD_TYPE_VERSION = 'Version';
        public final String KEY_VERSION = 'VERSION';
        public final String DELIMITER = ';';
        public final String ERROR_RELEASE = 'Release name cannot be empty'+ DELIMITER;
        public final String ERROR_VERSION = 'Version name cannot be empty'+ DELIMITER;
        public final String ERROR_PRODUCT = 'Product name cannot be empty'+ DELIMITER;
        public final String PATTERN_SEP_RELEASE = '___RELEASE___';
        public final String PATTERN_SEP_VERSION ='___VERSION___';
        public final String OBJECT_NAME_ReleaseVersion = 'OC_MD_ProductAttributes__c';
        public final String OBJECT_NAME_PRODUCT = 'Product2';
        public final String PRODUCT_RCTYPE_NAME_NODETYPE = 'OC_MD_Node_Type';
        public final Id PRODUCT_RCTYPE_ID_NODETYPE = NULL;
        public Constants(){
            OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
            PC_NAME_SERVICE_CATALOG = mc.OC_PriceBookEntryForProduct__c;
            
            RecordType tempRecordType = [SELECT Id From RecordType WHERE SObjectType = :OBJECT_NAME_PRODUCT and DeveloperName = :PRODUCT_RCTYPE_NAME_NODETYPE];
            if(tempRecordType != NULL){
                PRODUCT_RCTYPE_ID_NODETYPE = tempRecordType.Id;
            }
        }
    }
    
    /* Format of Raw data from csv */
    public class ProductWrapper{ 
        public String recordId;
        public String Name;        
        public String ProductModel; 
        public String ReleaseId;
        public String ProductRelease;
        public String VersionId;
        public String ProductVersion;
        public String TechnologyStandard; 
        public String HardwarePlatform;  
        public String PrimNo;
        public String GA;        
        public String EOM; 
        public String EOS;
        public String errorsForCSV;
        public ProductWrapper(){}
        public ProductWrapper(String Name, String ProductModel, String ProductRelease, String ProductVersion, String TechnologyStandard, String HardwarePlatform, String PrimNo, String GA, String EOM, String EOS){
            this.Name = Name;
            this.ProductModel = ProductModel;
            this.ProductRelease = ProductRelease;
            this.ProductVersion = ProductVersion;
            this.TechnologyStandard = TechnologyStandard;
            this.HardwarePlatform = HardwarePlatform;
            this.PrimNo = PrimNo;
            this.GA = GA;
            this.EOM = EOM;
            this.EOS = EOS;
        }
    }
}