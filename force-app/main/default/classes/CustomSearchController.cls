/**
* @File Name          : CustomSearchController.cls
* @Description        : 
* @Author             : Ankit Jain
* @Group              : 
* @Last Modified By   : Ankit Jain
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-16 16:02:32          Ankit Jain               Initial Version
2020-03-19                  Rohit Gaba               To add the support of external Search to Internal User
* 2.0    2020-04-14                  Nikita Sachdeva          R2005, U-1663 Adding Addititonal Header Parameter
* 3.0    2020-04-14                  Nikita Sachdeva          R2005, U-1750 To send a static parameter as part of the search URL
* 4.0    2020-11-12                  Rohit Gaba               R2012, U-1706 Controlling forum results based on the Account.
* 5.0    2020-12-03                  Subashini Arulalan       LPAS-118 To remove the hard coded filter on source sent in the search URL
* 6.0    2021-01-03                  Sandeep Singh            LPAS-58 Added additional parameter for GST Source Filter
* 7.0    2021-02-15                  Sandeep Singh            U-2473  Added additional parameter for GST static date filter.
* 8.0    2021-02-18                  Sandeep Singh            U-2474  Added additional parameter for GST format filter.
* 6.0    2021-03-15                  Sandeep Singh            U-2472  Added additional parameter for GST product filter in searchForIds method.
* 7.0    2021-03-18                  Subashini Arulalan       U-2477 - new UI design with having new document fields
* 9.0    2021-04-09                  Sandeep Singh            U-2478  Added additional parameter for GST SearchHit filter in searchForIds method.
* 10.0   2021-05-12                  Pravin Shendge           R2106, US-2741 added source pills filter changes
* 11.0   2021-06-08                  Sandeep Singh            U-2808  Added additional parameter for GST SearchHit Product Version filter in searchForIds method.
**/
public without sharing class CustomSearchController {
    /****************************************************************
* @author: Ankit Jain
* @date: 2019-09-16
* @param: searchText,hits,offset,paggination
* @description: This method fetches the results from GST API with respect to SearchText 

* @Modification: Rohit Gaba
* @date: 2020-03-19
* @param added: searchAs, chatTranscriptId
* @description: R2004, US-1617 To add the support of external Search to Internal User

* @Modification: Sandeep Singh
* @date: 2021-04-09
* @param added: productfilterList, category, status, operationalUnit, wildcard1, wildcard2
* @description: R2105,U-2478 Added additional parameter for GST SearchHit filter

*****************************************************************/
    @AuraEnabled
    public static List<SearchResultWrapper> searchForIds(
        String searchText,
        Integer hits,
        Integer offset,
        Boolean paggination,
        String productId,
        String searchAs,
        String chatTranscriptId,
        String sourceFilter,
        String dateFilter,
        String formattype,
        String products,
        List<String> productfilterList,
        String category,
        String status,
        String operationalUnit,
        String wildcard1,
        String wildcard2,
        String productVersion
    ) {
        try {
            List<SearchResultWrapper> searchResultWrapperList = new List<SearchResultWrapper>();
            String headerVal = '';
            if (!String.isBlank(searchText)) {
                Map<String, GST_API_Details__c> mapGSTCS = GST_API_Details__c.getAll();
                String sessionId = UserInfo.getSessionId();
                String profileId = UserInfo.getProfileId();
                String siteId = Site.getSiteId();
                String gstUserSignum = null;
                User usr = [
                    SELECT id, FederationIdentifier
                    FROM user
                    WHERE id = :UserInfo.getUserId()
                    LIMIT 1
                ];
                String realUser = usr.FederationIdentifier.replace(
                    GSTSearchConstantsUtility.AND_SIGN,
                    GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT
                );
                
                //R2004, US-1617, 2020-03-19 Rohit Gaba To add the support of external Search to Internal User
                /*Security: Check first if user is external. If not, then only consider searchAs scenario.*/
                //R2005, U-1663 , 2020-04-13 Nikita Sachdeva Addititonal Header Parameter to be sent while hitting GST API
                //External User Search
                if (
                    profileId.startsWith(
                        mapGSTCS.get(GSTSearchConstantsUtility.CS_EXTERNAL_PROFILE).Value__c
                    )
                ) {
                    gstUserSignum = realUser;
                    headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Community)
                        .Value__c;
                } else if (!String.isBlank(searchAs) && searchAs == 'External') {
                    //Internal User Search As External
                    //NoRowException will be captured by catch block and will be logged.
                    usr = [
                        SELECT id, FederationIdentifier
                        FROM user
                        WHERE
                        contactid = :[
                            SELECT ContactId
                            FROM LiveChatTranscript
                            WHERE Id = :chatTranscriptId
                            LIMIT 1
                        ]
                        .ContactId
                        LIMIT 1
                    ];
                    realUser = usr.FederationIdentifier.replace(
                        GSTSearchConstantsUtility.AND_SIGN,
                        GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT
                    );
                    gstUserSignum = realUser;
                    headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Console)
                        .Value__c;
                } else {
                    //R2005, U-1663 , 2020-04-13 Nikita Sachdeva Addititonal Header Parameter to be sent while hitting GST API
                    /*siteId : Check first if user is inConsole or Community */
                    //Internal User Search
                    gstUserSignum = mapGSTCS.get(
                        GSTSearchConstantsUtility.CS_INTERNAL_USER_SIGNUM
                    )
                        .Value__c;
                    if (siteId != null) {
                        headerVal = mapGSTCS.get(
                            GSTSearchConstantsUtility.Referrer_Community
                        )
                            .Value__c;
                    } else {
                        headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Console)
                            .Value__c;
                    }
                }
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String gsturl;
                if (!String.isBlank(sourceFilter)) {
                    gsturl =
                        mapGSTCS.get(GSTSearchConstantsUtility.CS_BASE_URL).Value__c +
                        GSTSearchConstantsUtility.QUERY_PARAM +
                        EncodingUtil.urlEncode(
                            searchText,
                            GSTSearchConstantsUtility.UTF_ENCODE
                        ) +
                        GSTSearchConstantsUtility.HITS_PARAM +
                        hits +
                        GSTSearchConstantsUtility.OFFSET_PARAM +
                        offset +
                        GSTSearchConstantsUtility.USER_PARAM +
                        gstUserSignum +
                        GSTSearchConstantsUtility.TOKEN_PARAM +
                        mapGSTCS.get(GSTSearchConstantsUtility.CS_TOKEN_PARAM).Value__c +
                        GSTSearchConstantsUtility.FACET_PARAM +sourceFilter +
                        GSTSearchConstantsUtility.SEARCH_APP_SESSION_ID_PARAM +
                        sessionId.substring(0, sessionId.length()) +
                        GSTSearchConstantsUtility.REALUSER_PARAM +
                        realUser;   
                }
                else{
                    gsturl=
                        mapGSTCS.get(GSTSearchConstantsUtility.CS_BASE_URL).Value__c +
                        GSTSearchConstantsUtility.QUERY_PARAM +
                        EncodingUtil.urlEncode(
                            searchText,
                            GSTSearchConstantsUtility.UTF_ENCODE
                        ) +
                        GSTSearchConstantsUtility.HITS_PARAM +
                        hits +
                        GSTSearchConstantsUtility.OFFSET_PARAM +
                        offset +
                        GSTSearchConstantsUtility.USER_PARAM +
                        gstUserSignum +
                        GSTSearchConstantsUtility.TOKEN_PARAM +
                        mapGSTCS.get(GSTSearchConstantsUtility.CS_TOKEN_PARAM).Value__c +
                        // LPAS-118 commented the below hard coded filter on source sent in the search URL
                        /*GSTSearchConstantsUtility.FACET_PARAM +
mapGSTCS.get(GSTSearchConstantsUtility.CS_FACET_SOURCE).Value__c + */
                        GSTSearchConstantsUtility.SEARCH_APP_SESSION_ID_PARAM +
                        sessionId.substring(0, sessionId.length()) +
                        GSTSearchConstantsUtility.REALUSER_PARAM +
                        realUser;
                }
                if (!productId.equals(GSTSearchConstantsUtility.ZERO)) {
                    Product2 prod = [
                        SELECT id, Node_Type__c, Platform__c, Technology__c
                        FROM product2
                        WHERE id = :productId
                        LIMIT 1
                    ];
                    gsturl =
                        gsturl +
                        GSTSearchConstantsUtility.NODETYPE_PARAM +
                        prod.Node_Type__c.replace(
                            GSTSearchConstantsUtility.AND_SIGN,
                            GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT
                        ) +
                        GSTSearchConstantsUtility.PLATFORM_PARAM +
                        prod.Platform__c.replace(
                            GSTSearchConstantsUtility.AND_SIGN,
                            GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT
                        ) +
                        GSTSearchConstantsUtility.TECHNOLOGY_PARAM +
                        prod.Technology__c.replace(
                            GSTSearchConstantsUtility.AND_SIGN,
                            GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT
                        );
                }
                //R2005, U-1750 , 2020-04-13 Nikita Sachdeva To send a additional static parameter as part of the search URL.
                gsturl =
                    gsturl +
                    GSTSearchConstantsUtility.AND_SIGN +
                    mapGSTCS.get(GSTSearchConstantsUtility.CPI_DOC_NUMBER_PARAM)
                    .Value__c +
                    GSTSearchConstantsUtility.EQUAL_SIGN +
                    mapGSTCS.get(GSTSearchConstantsUtility.CPI_DOC_NUMBER_PARAM_VALUE)
                    .Value__c;
                //U-2473 Sandeep Singh To send additional static date filter to GST.
                if (!String.isBlank(dateFilter)) {
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Date_Filter+dateFilter;
                }
                //U-2474 Sandeep Singh To send additional format filter to GST.
                if(!String.isBlank(formattype)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Format_Filter+formattype; 
                }
                // U-2472 added by Sandeep for GST product filter start
                if(!String.isBlank(products)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Product_Filter+products; 
                }
                // U-2472 end
                
                // U-2478 added by Sandeep for GST SearchHit filter start
                if(!String.isBlank(category)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Category_Filter+category; 
                }
                if(!String.isBlank(status)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Status_Filter+status; 
                }
                if(!String.isBlank(operationalUnit)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.OperationalUnit_Filter+operationalUnit; 
                }
                if(!String.isBlank(wildcard1)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Wildcard1_Filter+wildcard1; 
                }
                if(!String.isBlank(wildcard2)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Wildcard2_Filter+wildcard2; 
                }
                // U-2478 end 
                // U-2808 added by Sandeep for GST SearchHit Product Version filter start
                if(!String.isBlank(productVersion)){
                    gsturl =
                        gsturl + GSTSearchConstantsUtility.Product_Version+productVersion; 
                }
                //U-2808 end
                request.setEndpoint(gsturl);
                request.setHeader(
                    GSTSearchConstantsUtility.HEADER_TOKEN_PARAM,
                    mapGSTCS.get(GSTSearchConstantsUtility.CS_HEADER_TOKEN_PARAM).Value__c
                );
                //R2005, U-1663 , 2020-04-13 Nikita Sachdeva Addititonal Header Parameter to be sent while hitting GST API
                request.setHeader(
                    mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Header).Value__c,
                    headerVal
                );
                request.setMethod(GSTSearchConstantsUtility.GET);
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == GSTSearchConstantsUtility.TWO_HUNDRED) {
                    String responseText = response.getBody();
                    JSON2Apex obj = JSON2Apex.parse(responseText);
                    Integer totalsHits = obj.DocumentList.numberOfHits;
                    Integer maxSearchResults = Integer.valueOf(
                        mapGSTCS.get(GSTSearchConstantsUtility.Max_Search_Results).Value__c
                    );
                    if (totalsHits > maxSearchResults) {
                        totalsHits = maxSearchResults;
                    }
                    List<GstCustomSearch__c> gstCustomSearchList = new List<GstCustomSearch__c>();
                    String displayTitle = null;
                    String displayabstract_z = null;
                    SearchResultWrapper searchResultWrapper = new SearchResultWrapper();
                    Map<String, List<string>> wrapper = new Map<String, List<string>>();
                    for(JSON2Apex.facets ft :  obj.facets){
                        List<String> face = new List<String>();
                        for(JSON2Apex.Filters flt :  ft.Filters){
                            face.add(flt.displayName);
                        }	
                        wrapper.put(ft.id,face);
                    }
                    searchResultWrapper.Filters = wrapper;                  
                    // U-2741 added by Pravin for GST SearchHit source filter 
                    Map<String, Boolean> sourcefilterdisplaymap = new Map<String, Boolean>();                  
                    if(sourceFilter != null && sourceFilter != '') {
                        for (String  src : wrapper.get('facet_source')){ 
                            for(String srcfilter : sourceFilter.split('&facet_source=')){
                                if(src == EncodingUtil.urlDecode(srcfilter, GSTSearchConstantsUtility.UTF_ENCODE) ){
                                    sourcefilterdisplaymap.put(src, true);
                                }else{
                                    if(!sourcefilterdisplaymap.containsKey(src))
                                        sourcefilterdisplaymap.put(src, false); 
                                }                                   
                            }
                        }
                    }
                    for (JSON2Apex.Documents dd : obj.DocumentList.documents) {
                        displayTitle = dd.title;
                        if (displayTitle != null) {
                            displayTitle = displayTitle.replace(
                                GSTSearchConstantsUtility.Word_Format_Start,
                                GSTSearchConstantsUtility.Word_Format_Start_Replacement
                            );
                            displayTitle = displayTitle.replace(
                                GSTSearchConstantsUtility.Word_Format_End,
                                GSTSearchConstantsUtility.Word_Format_End_Replacement
                            );
                        }
                        displayabstract_z = dd.abstract_z;
                        if (displayabstract_z != null) {
                            displayabstract_z = displayabstract_z.replace(
                                GSTSearchConstantsUtility.Word_Format_Start,
                                GSTSearchConstantsUtility.Word_Format_Start_Replacement
                            );
                            displayabstract_z = displayabstract_z.replace(
                                GSTSearchConstantsUtility.Word_Format_End,
                                GSTSearchConstantsUtility.Word_Format_End_Replacement
                            );
                        }
                        // U-2478 added by Sandeep for GST SearchHit filter 
                        Map<String, Boolean> productfilterdisplaymap = new Map<String, Boolean>();
                        
                        if(productfilterList != null && !productfilterList.isempty()){
                            for (String  prod : dd.filterproduct_version){                            
                                for(String prodfilter : productfilterList){
                                    if(prodfilter == prod ){
                                        productfilterdisplaymap.put(prod, true);
                                    }else{
                                        if(!productfilterdisplaymap.containsKey(prod))
                                            productfilterdisplaymap.put(prod, false); 
                                    }                                   
                                }
                            }
                        }
                        
                        SearchHitsFilterWrapper searchwrap = new SearchHitsFilterWrapper();
                        searchwrap.ProductFilterMap = productfilterdisplaymap;
                        searchwrap.sourceFilterMap = sourcefilterdisplaymap;
                        searchwrap.isCategoryFilter = category != null && !String.isBlank(category) && category.containsAny(dd.displaycategory) ? true: false;
                        searchwrap.isSourceFilter =  sourceFilter != null && !String.isBlank(sourceFilter) && sourceFilter.containsAny(dd.source) ? true: false;
                        searchwrap.isFormatFilter =  formattype != null && !String.isBlank(formattype) && formattype.containsAny(dd.format) ? true: false;
                        searchwrap.isStatusFilter =  status != null && !String.isBlank(status) && status.containsAny(dd.status) ? true: false;
                        searchwrap.isOperationalUnitFilter =  operationalUnit != null && !String.isBlank(operationalUnit) && operationalUnit.containsAny(dd.operational_unit) ? true: false;
                        searchwrap.isWildcard1Filter =  wildcard1 != null && !String.isBlank(wildcard1) && wildcard1.containsAny(dd.displaywildcard1) ? true: false;
                        searchwrap.isWildcard2Filter =  wildcard2 != null && !String.isBlank(wildcard2) && wildcard2.containsAny(dd.displaywildcard2) ? true: false;
                        
                        searchResultWrapper = new SearchResultWrapper(
                            displayTitle,
                            displayabstract_z,
                            dd.dater,
                            null,
                            dd.uri_tree,
                            dd.format,
                            dd.x_clickurl,
                            totalsHits,
                            dd.uri,
                            dd.source,
                            searchResultWrapper.Filters,
                            dd.displaycategory,
                            dd.status,
                            dd.operational_unit,
                            dd.displaywildcard1,
                            dd.displaywildcard2,
                            dd.positive_count,
                            dd.reply_count,
                            dd.filterproduct_version,
                            searchwrap
                        );
                        searchResultWrapperList.add(searchResultWrapper);
                    }
                    if (!paggination) {
                        GstCustomSearch__c gstCustomSearch = new GstCustomSearch__c();
                        gstCustomSearch.Search_String__c = searchText;
                        gstCustomSearch.Session_ID__c = sessionId.substring(
                            0,
                            sessionId.length()
                        );
                        Database.insert(gstCustomSearch);
                    }
                    // return searchResultWrapperList;
                } else {
                    throw new AuraHandledException(
                        GSTSearchConstantsUtility.GST_CONNECTIVITY_ISSUE
                    );
                }
            }
            return searchResultWrapperList;
        } catch (Exception e) {
            EventLog.createLogFuture(
                Json.serialize(
                    new EventLog.Error(
                        GSTSearchConstantsUtility.CustomSearchController,
                        GSTSearchConstantsUtility.searchForIds,
                        GSTSearchConstantsUtility.CustomSearchController,
                        true,
                        e
                    )
                )
            );
            if (e instanceof AuraHandledException) {
                throw new AuraHandledException(
                    GSTSearchConstantsUtility.GST_CONNECTIVITY_ISSUE
                );
            } else {
                throw new AuraHandledException(
                    GSTSearchConstantsUtility.EXCEPTION_MESSAGE
                );
            }
        }
    }
    
    /****************************************************************
* @author: Ankit Jain
* @date: 2019-12-5
* @param: searchText,hits,offset,paggination
* @description: This method fetches the results from FeedItem with respect to SearchText
*****************************************************************/
    @AuraEnabled
    public static List<SearchResultWrapper> searchForForum(String searchText) {
        //4.0 2020-11-12 Rohit Gaba R2012, U-1706 Controlling forum results based on the Account.
        if(!FeatureManagement.checkPermission('OC_UAM_Forum_Accessibility') && UserInfo.getUserType() != 'Standard'){
            return new List<SearchResultWrapper>();
        }
        
        try {
            List<SearchResultWrapper> searchResultWrapperList = new List<SearchResultWrapper>();
            if (!String.isBlank(searchText)) {
                Map<String, GST_API_Details__c> mapGSTCS = GST_API_Details__c.getAll();
                String profileId = UserInfo.getProfileId();
                List<List<sObject>> searchList = new List<List<sObject>>();
                String postType = GSTSearchConstantsUtility.QuestionPost;
                if (
                    profileId.startsWith(
                        mapGSTCS.get(GSTSearchConstantsUtility.CS_EXTERNAL_PROFILE).Value__c
                    )
                ) {
                    String userId = UserInfo.getUserId();
                    String networkStatus = GSTSearchConstantsUtility.LIVE;
                    NetworkMember networkMemberOnj = [
                        SELECT NetworkId
                        FROM NetworkMember
                        WHERE MemberId = :userId AND Network.Status = :networkStatus
                        LIMIT 1
                    ];
                    searchList = [
                        FIND :searchText
                        IN ALL FIELDS
                        RETURNING
                        FeedItem(
                            Id,
                            Title,
                            Body,
                            createdDate
                            WHERE
                            type = :postType
                            AND NetworkScope = :networkMemberOnj.NetworkId
                            ORDER BY CreatedDate DESC)
                        LIMIT 2000
                    ];
                } else {
                    searchList = [
                        FIND :searchText
                        IN ALL FIELDS
                        RETURNING
                        FeedItem(
                            Id,
                            Title,
                            Body,
                            createdDate
                            WHERE type = :postType
                            ORDER BY CreatedDate DESC)
                        LIMIT 2000
                    ];
                }
                List<FeedItem> searchFeedItems = new List<FeedItem>();
                searchFeedItems = (FeedItem[]) searchList[0];
                SearchResultWrapper searchResultWrapper = new SearchResultWrapper();
                String displayTitle = null;
                String displayBody = null;
                String aLower = searchText.toLowerCase();
                String bLower = null;
                Integer index = null;
                String aActual = null;
                for (FeedItem fi : searchFeedItems) {
                    Boolean flag = false;
                    displayTitle = fi.Title;
                    if (displayTitle != null) {
                        bLower = displayTitle.toLowerCase();
                        index = bLower.indexOf(aLower);
                        if (index >= 0) {
                            flag = false;
                            aActual = displayTitle.substring(
                                index,
                                index + searchText.length()
                            );
                            //displayTitle= displayTitle.replace(aActual, GSTSearchConstantsUtility.Word_Format_Start_Replacement+aActual+GSTSearchConstantsUtility.Word_Format_End_Replacement);
                        } else {
                            flag = true;
                        }
                    }
                    displayBody = fi.Body;
                    if (displayBody != null) {
                        bLower = displayBody.toLowerCase();
                        index = bLower.indexOf(aLower);
                        if (index >= 0) {
                            flag = false;
                            aActual = displayBody.substring(
                                index,
                                index + searchText.length()
                            );
                            displayBody = displayBody.replace(
                                aActual,
                                GSTSearchConstantsUtility.Word_Format_Start_Replacement +
                                aActual +
                                GSTSearchConstantsUtility.Word_Format_End_Replacement
                            );
                        } else {
                            if (flag) {
                                flag = true;
                            }
                        }
                    }
                    if (flag) {
                        continue;
                    }
                    searchResultWrapper = new SearchResultWrapper(
                        displayTitle,
                        displayBody,
                        String.valueOf(fi.CreatedDate),
                        GSTSearchConstantsUtility.BLANK,
                        mapGSTCS.get(GSTSearchConstantsUtility.POST_URL).Value__c + fi.Id,
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        searchFeedItems.size(),
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        null,
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        GSTSearchConstantsUtility.BLANK,
                        null,
                        // U-2478 added by Sandeep for GST SearchHit filter 
                        new SearchHitsFilterWrapper()
                    );
                    searchResultWrapperList.add(searchResultWrapper);
                }
            }
            return searchResultWrapperList;
        } catch (Exception e) {
            EventLog.createLogFuture(
                Json.serialize(
                    new EventLog.Error(
                        GSTSearchConstantsUtility.CustomSearchController,
                        GSTSearchConstantsUtility.searchForForum,
                        GSTSearchConstantsUtility.CustomSearchController,
                        true,
                        e
                    )
                )
            );
            //throw new AuraHandledException(GSTSearchConstantsUtility.Forum_EXCEPTION_MESSAGE);
            return new List<SearchResultWrapper>();
        }
    }
    /****************************************************************
* @author: Ankit Jain
* @date: 2019-10-07
* @param: void
* @description: This method fetches the unique product with respect to account
*****************************************************************/
    @AuraEnabled
    public static List<UniqueProductWrapper> fetchUniqueProduct() {
        List<UniqueProductWrapper> uniqueProductWrapperList = new List<UniqueProductWrapper>();
        uniqueProductWrapperList.add(
            new UniqueProductWrapper(
                GSTSearchConstantsUtility.ZERO,
                GSTSearchConstantsUtility.Select_Product
            )
        );
        try {
            UniqueProductWrapper uniqueProductWrapper = new UniqueProductWrapper();
            User user = [
                SELECT u.ContactId
                FROM User u
                WHERE u.Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            Contact contact = [
                SELECT c.AccountId
                FROM contact c
                WHERE c.id = :user.contactID
                LIMIT 1
            ];
            Set<Id> prdctIdSet = new Set<Id>();
            for (Asset ast : [
                SELECT id, Product2Id
                FROM Asset
                WHERE AccountId = :contact.AccountId
            ]) {
                prdctIdSet.add(ast.Product2Id);
            }
            for (Product2 p : [
                SELECT id, Name
                FROM Product2
                WHERE Id = :prdctIdSet
                LIMIT :prdctIdSet.Size()
            ]) {
                uniqueProductWrapper = new UniqueProductWrapper(p.Id, p.Name);
                uniqueProductWrapperList.add(uniqueProductWrapper);
            }
            //return uniqueProductWrapperList;
        } catch (Exception e) {
            EventLog.createLogFuture(
                Json.serialize(
                    new EventLog.Error(
                        GSTSearchConstantsUtility.CustomSearchController,
                        GSTSearchConstantsUtility.fetchUniqueProduct,
                        GSTSearchConstantsUtility.CustomSearchController,
                        true,
                        e
                    )
                )
            );
            //return uniqueProductWrapperList;
        }
        return uniqueProductWrapperList;
    }
    /**
* @Description        :
* @Author             : Ankit Jain
* @Group              :
* @Last Modified By   : Ankit Jain
* @Last Modified On   :
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-16 16:02:32         Ankit Jain               Initial Version
**/
    public without sharing class SearchResultWrapper {
        @AuraEnabled
        public String title { public get; public set; }
        @AuraEnabled
        public String abstract_z { public get; public set; }
        @AuraEnabled
        public String dater { public get; public set; }
        @AuraEnabled
        public String container_uri { public get; public set; }
        @AuraEnabled
        public String uri_tree { public get; public set; }
        @AuraEnabled
        public String format { public get; public set; }
        @AuraEnabled
        public String x_clickurl { public get; public set; }
        @AuraEnabled
        public Integer totalsHits { public get; public set; }
        @AuraEnabled
        public String uri { public get; public set; }
        @AuraEnabled
        public String source { public get; public set; }
        @AuraEnabled
        public Map<String, List<string>> Filters { public get; public set; }
        // Added below part as part of US-2477
        @AuraEnabled
        public String displaycategory { public get; public set; }
        @AuraEnabled
        public String status { public get; public set; }
        @AuraEnabled
        public String operational_unit { public get; public set; }
        @AuraEnabled
        public String displaywildcard1 { public get; public set; }
        @AuraEnabled
        public String displaywildcard2 { public get; public set; }
        @AuraEnabled
        public String positive_count { public get; public set; }
        @AuraEnabled
        public String reply_count { public get; public set; }
        @AuraEnabled
        public List<String> filterproduct_version { public get; public set; }
        // U-2478 added by Sandeep for GST SearchHit filter 
        @AuraEnabled
        Public SearchHitsFilterWrapper searchfilterwrap { public get; public set; }
        /****************************************************************
* @author: Ankit Jain
* @date: 2019-09-16
* @param: title,abstract_z,dater,container_uri,uri_tree,format,x_clickurl
* @description: This Constructor sets the SearchResultWrapper related values
*****************************************************************/
        public SearchResultWrapper(
            String title,
            String abstract_z,
            String dater,
            String container_uri,
            String uri_tree,
            String format,
            String x_clickurl,
            Integer totalsHits,
            String uri,
            String source,
            Map<String, List<string>> Filters,
            // Added below part as part of US-2477
            String displaycategory,
            String status,
            String operational_unit,
            String displaywildcard1,
            String displaywildcard2, 
            String positive_count,
            String reply_count,
            List<String> filterproduct_version,
            // U-2478 added by Sandeep for GST SearchHit filter 
            SearchHitsFilterWrapper searchfilterwrap
        ) {
            this.title = title;
            this.abstract_z = abstract_z;
            this.dater = dater;
            this.container_uri = container_uri;
            this.uri_tree = uri_tree;
            this.format = format;
            this.x_clickurl = x_clickurl;
            this.totalsHits = totalsHits;
            this.uri = uri;
            this.source = source;
            this.Filters = Filters;
            // Added below part as part of US-2477
            this.displaycategory = displaycategory;
            this.status = status;
            this.operational_unit = operational_unit;
            this.displaywildcard1 = displaywildcard1;
            this.displaywildcard2 = displaywildcard2;
            this.positive_count = positive_count;
            this.reply_count = reply_count;
            this.filterproduct_version = filterproduct_version;
            // U-2478 added by Sandeep for GST SearchHit filter 
            this.searchfilterwrap =  searchfilterwrap;
        }
        /****************************************************************
* @author: Ankita Mahobia
* @date: 2020-01-06
* @param:
* @description: This Constructor sets the SearchResultWrapper related values to null
*****************************************************************/
        public SearchResultWrapper() {
            this.title = null;
            this.abstract_z = null;
            this.dater = null;
            this.container_uri = null;
            this.uri_tree = null;
            this.format = null;
            this.x_clickurl = null;
            this.totalsHits = null;
            this.uri = null;
            this.source = null;
            this.Filters = null;
            // Added below part as part of US-2477
            this.displaycategory = null;
            this.status = null;
            this.operational_unit = null;
            this.displaywildcard1 = null;
            this.displaywildcard2 = null;
            this.positive_count = null;
            this.reply_count = null;
            this.filterproduct_version = null;
            // U-2478 added by Sandeep for GST SearchHit filter 
            this.searchfilterwrap = new SearchHitsFilterWrapper();
        }
    }
    /**
* @Description        :
* @Author             : Ankit Jain
* @Group              :
* @Last Modified By   : Ankit Jain
* @Last Modified On   :
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-16 16:02:32         Ankit Jain               Initial Version
**/
    public without sharing class UniqueProductWrapper {
        @AuraEnabled
        public String productName { public get; public set; }
        @AuraEnabled
        public String productId { public get; public set; }
        
        /****************************************************************
* @author: Ankit Jain
* @date: 2019-09-16
* @param: productId, productName
* @description: This Constructor sets the UniqueProductWrapper related values
*****************************************************************/
        public UniqueProductWrapper(String productId, String productName) {
            this.productName = productName;
            this.productId = productId;
        }
        /****************************************************************
* @author: Ankita Mahobia
* @date: 2020-01-06
* @param:
* @description: This Constructor sets the UniqueProductWrapper related values to null
*****************************************************************/
        public UniqueProductWrapper() {
            this.productName = null;
            this.productId = null;
        }
    }
    /****************************************************************
* @author: Sandeep Singh
* @date: 2021-04-09
* @param: ProductFilterMap,sourceFilterMap,isCategoryFilter,isSourceFilter,isFormatFilter,isStatusFilter,isOperationalUnitFilter,isWildcard1Filter,isWildcard2Filter
* @description: This Constructor sets the SearchHitsFilterWrapper related values
*****************************************************************/    
    public without sharing class SearchHitsFilterWrapper {
        @AuraEnabled
        Public Map<String ,Boolean> ProductFilterMap { public get; public set; }
        @AuraEnabled
        Public Map<String ,Boolean> sourceFilterMap { public get; public set; }
        @AuraEnabled
        Public Boolean isCategoryFilter { public get; public set; }
        @AuraEnabled
        Public Boolean isSourceFilter { public get; public set; }
        @AuraEnabled
        Public Boolean isFormatFilter { public get; public set; }
        @AuraEnabled
        Public Boolean isStatusFilter { public get; public set; }
        @AuraEnabled
        Public Boolean isOperationalUnitFilter { public get; public set; }
        @AuraEnabled
        Public Boolean isWildcard1Filter { public get; public set; }
        @AuraEnabled
        Public Boolean isWildcard2Filter { public get; public set; }       
        
        public SearchHitsFilterWrapper() {
            this.ProductFilterMap = new  Map<String ,Boolean>();
            this.sourceFilterMap = new  Map<String ,Boolean>();
            this.isCategoryFilter = false;
            this.isSourceFilter = false;
            this.isFormatFilter = false;
            this.isStatusFilter = false;
            this.isOperationalUnitFilter = false;
            this.isWildcard1Filter = false;
            this.isWildcard2Filter = false;
        }
    }
}