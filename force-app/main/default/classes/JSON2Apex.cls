/**
* @File Name          : JSON2Apex.cls
* @Description        : U-1146 & U-1147 (GST API Result Parsing)
* @Author             : Ankit Jain
* @Group              :
* @Last Modified By   : Ankit Jain
* @Last Modified On   :
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-16 16:02:32  		 Ankit Jain   			  Initial Version
* 2.0    2021-03-18              Subashini Arulalan         U-2477 - new UI design with having new document fields
* 3.0    2021-04-16              Sandeep Singh              U-2478 updated the status mapping for GST SearchHit filter
**/
public without sharing class JSON2Apex {
    public without sharing class DocumentList {
        public String id { get; set; }
        public String displayName { get; set; }
        public Integer numberOfHits { get; set; }
        public List<Documents> documents { get; set; }
        public Pagination pagination { get; set; }
        public List<FirstPage> sortOptions { get; set; }
        
        public DocumentList(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('id')) {
                            id = parser.getText();
                        } else if (text.equals('displayName')) {
                            displayName = parser.getText();
                        } else if (text.equals('numberOfHits')) {
                            numberOfHits = parser.getIntegerValue();
                        } else if (text.equals('documents')) {
                            documents = arrayOfDocuments(parser);
                        } else if (text.equals('pagination')) {
                            pagination = new Pagination(parser);
                        } else if (text.equals('sortOptions')) {
                            sortOptions = arrayOfFirstPage(parser);
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'DocumentList consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class FirstPage {
        public String displayName { get; set; }
        public Boolean selected { get; set; }
        public String query { get; set; }
        
        public FirstPage(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('displayName')) {
                            displayName = parser.getText();
                        } else if (text.equals('selected')) {
                            selected = parser.getBooleanValue();
                        } else if (text.equals('query')) {
                            query = parser.getText();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'FirstPage consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public Stats stats { get; set; }
    public Object query { get; set; }
    public DocumentList documentList { get; set; }
    public List<Facets> facets { get; set; }
    public Spell spell { get; set; }
    public Quicklinks quicklinks { get; set; }
    public Object feedback { get; set; }
    public List<Children> errorMessages { get; set; }
    
    public JSON2Apex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text.equals('stats')) {
                        stats = new Stats(parser);
                    } else if (text.equals('query')) {
                        query = parser.readValueAs(Object.class);
                    } else if (text.equals('documentList')) {
                        documentList = new DocumentList(parser);
                    } else if (text.equals('facets')) {
                        facets = arrayOfFacets(parser);
                    } else if (text.equals('spell')) {
                        spell = new Spell(parser);
                    } else if (text.equals('quicklinks')) {
                        quicklinks = new Quicklinks(parser);
                    } else if (text.equals('feedback')) {
                        feedback = parser.readValueAs(Object.class);
                    } else if (text.equals('errorMessages')) {
                        errorMessages = arrayOfChildren(parser);
                    } else {
                        System.debug(
                            LoggingLevel.WARN,
                            'JSON2Apex consuming unrecognized property: ' + text
                        );
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public without sharing class Facets {
        public String id { get; set; }
        public String displayName { get; set; }
        public String selectionType { get; set; }
        public Boolean multipleLevels { get; set; }
        public List<Filters> filters { get; set; }
        
        public Facets(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('id')) {
                            id = parser.getText();
                        } else if (text.equals('displayName')) {
                            displayName = parser.getText();
                        } else if (text.equals('selectionType')) {
                            selectionType = parser.getText();
                        } else if (text.equals('multipleLevels')) {
                            multipleLevels = parser.getBooleanValue();
                        } else if (text.equals('filters')) {
                            filters = arrayOfFilters(parser);
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Facets consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Abc_class {
        public String query { get; set; }
        public String value { get; set; }
        
        public Abc_class(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('query')) {
                            query = parser.getText();
                        } else if (text.equals('value')) {
                            value = parser.getText();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Abc_class consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Quicklinks {
        public String id { get; set; }
        public String displayName { get; set; }
        public Integer numberOfHits { get; set; }
        public List<Children> documents { get; set; }
        public Object pagination { get; set; }
        public List<Children> sortOptions { get; set; }
        
        public Quicklinks(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('id')) {
                            id = parser.getText();
                        } else if (text.equals('displayName')) {
                            displayName = parser.getText();
                        } else if (text.equals('numberOfHits')) {
                            numberOfHits = parser.getIntegerValue();
                        } else if (text.equals('documents')) {
                            documents = arrayOfChildren(parser);
                        } else if (text.equals('pagination')) {
                            pagination = parser.readValueAs(Object.class);
                        } else if (text.equals('sortOptions')) {
                            sortOptions = arrayOfChildren(parser);
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Quicklinks consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Spell {
        public String id { get; set; }
        public String displayName { get; set; }
        public List<Children> suggestions { get; set; }
        
        public Spell(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('id')) {
                            id = parser.getText();
                        } else if (text.equals('displayName')) {
                            displayName = parser.getText();
                        } else if (text.equals('suggestions')) {
                            suggestions = arrayOfChildren(parser);
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Spell consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Pagination {
        public Integer offset { get; set; }
        public Integer hitsPerPage { get; set; }
        public FirstPage firstPage { get; set; }
        public FirstPage previousPage { get; set; }
        public FirstPage nextPage { get; set; }
        public FirstPage lastPage { get; set; }
        public List<FirstPage> pages { get; set; }
        
        public Pagination(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('offset')) {
                            offset = parser.getIntegerValue();
                        } else if (text.equals('hitsPerPage')) {
                            hitsPerPage = parser.getIntegerValue();
                        } else if (text.equals('firstPage')) {
                            firstPage = new FirstPage(parser);
                        } else if (text.equals('previousPage')) {
                            previousPage = new FirstPage(parser);
                        } else if (text.equals('nextPage')) {
                            nextPage = new FirstPage(parser);
                        } else if (text.equals('lastPage')) {
                            lastPage = new FirstPage(parser);
                        } else if (text.equals('pages')) {
                            pages = arrayOfFirstPage(parser);
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Pagination consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Filters {
        public String displayName { get; set; }
        public Boolean selected { get; set; }
        public String query { get; set; }
        public Integer count { get; set; }
        public List<Children> children { get; set; }
        
        public Filters(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('displayName')) {
                            displayName = parser.getText();
                        } else if (text.equals('selected')) {
                            selected = parser.getBooleanValue();
                        } else if (text.equals('query')) {
                            query = parser.getText();
                        } else if (text.equals('count')) {
                            count = parser.getIntegerValue();
                        } else if (text.equals('children')) {
                            children = arrayOfChildren(parser);
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Filters consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Clickable {
        public Abc_class abc_class { get; set; }
        public Abc_class abc_type { get; set; }
        public Abc_class container_name { get; set; }
        public Abc_class decimal_class { get; set; }
        public Abc_class format { get; set; }
        public Abc_class product_number_base { get; set; }
        public Abc_class source { get; set; }
        public Abc_class type_Z { get; set; } // in json: type
        
        public Clickable(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('abc_class')) {
                            abc_class = new Abc_class(parser);
                        } else if (text.equals('abc_type')) {
                            abc_type = new Abc_class(parser);
                        } else if (text.equals('container_name')) {
                            container_name = new Abc_class(parser);
                        } else if (text.equals('decimal_class')) {
                            decimal_class = new Abc_class(parser);
                        } else if (text.equals('format')) {
                            format = new Abc_class(parser);
                        } else if (text.equals('product_number_base')) {
                            product_number_base = new Abc_class(parser);
                        } else if (text.equals('source')) {
                            source = new Abc_class(parser);
                        } else if (text.equals('type')) {
                            type_Z = new Abc_class(parser);
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Clickable consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Documents {
        public Clickable x_clickable { get; set; } // in json: _clickable
        public String x_clickurl { get; set; } // in json: _clickurl
        public String x_id { get; set; } // in json: _id
        public String x_type { get; set; } // in json: _type
        public String abc_class { get; set; }
        public String abc_type { get; set; }
        public String abstract_Z { get; set; } // in json: abstract
        public List<String> boosted_keywords { get; set; }
        public String container_id { get; set; }
        public String container_name { get; set; }
        public String cpi_libid { get; set; }
        public String dater { get; set; }
        public String date_modified { get; set; }
        public String decimal_class { get; set; }
        public String deduplication_id { get; set; }
        public String document_number_base { get; set; }
        public String document_number_other { get; set; }
        public String document_priority { get; set; }
        public String document_revision { get; set; }
        public String extra_content { get; set; }
        public String filtersource { get; set; }
        public String format { get; set; }
        public String language { get; set; }
        public String product_number_base { get; set; }
        public String product_number_other { get; set; }
        public String source { get; set; }
        public String title { get; set; }
        public String type_Z { get; set; } // in json: type
        public String uri { get; set; }
        public String uri_tree { get; set; }
        // U-2477- Subashini Arulalan Added the new fields
        public String displaycategory { get; set; }
        public String status { get; set; }
        public String operational_unit { get; set; }
        public String displaywildcard1 { get; set; }
        public String displaywildcard2 { get; set; }
        public String positive_count { get; set; }
        public String reply_count { get; set; }
        public List<String> filterproduct_version { get; set; }
        
        public Documents(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('_clickable')) {
                            x_clickable = new Clickable(parser);
                        } else if (text.equals('_clickurl')) {
                            x_clickurl = parser.getText();
                        } else if (text.equals('_id')) {
                            x_id = parser.getText();
                        } else if (text.equals('_type')) {
                            x_type = parser.getText();
                        } else if (text.equals('abc_class')) {
                            abc_class = parser.getText();
                        } else if (text.equals('abc_type')) {
                            abc_type = parser.getText();
                        } else if (text.equals('abstract')) {
                            abstract_Z = parser.getText();
                        } else if (text.equals('boosted_keywords')) {
                            boosted_keywords = arrayOfString(parser);
                        } else if (text.equals('container_id')) {
                            container_id = parser.getText();
                        } else if (text.equals('container_name')) {
                            container_name = parser.getText();
                        } else if (text.equals('cpi_libid')) {
                            cpi_libid = parser.getText();
                        } else if (text.equals('date')) {
                            dater = parser.getText();
                        } else if (text.equals('date_modified')) {
                            date_modified = parser.getText();
                        } else if (text.equals('decimal_class')) {
                            decimal_class = parser.getText();
                        } else if (text.equals('deduplication_id')) {
                            deduplication_id = parser.getText();
                        } else if (text.equals('document_number_base')) {
                            document_number_base = parser.getText();
                        } else if (text.equals('document_number_other')) {
                            document_number_other = parser.getText();
                        } else if (text.equals('document_priority')) {
                            document_priority = parser.getText();
                        } else if (text.equals('document_revision')) {
                            document_revision = parser.getText();
                        } else if (text.equals('extra_content')) {
                            extra_content = parser.getText();
                        } else if (text.equals('filtersource')) {
                            filtersource = parser.getText();
                        } else if (text.equals('format')) {
                            format = parser.getText();
                        } else if (text.equals('language')) {
                            language = parser.getText();
                        } else if (text.equals('product_number_base')) {
                            product_number_base = parser.getText();
                        } else if (text.equals('product_number_other')) {
                            product_number_other = parser.getText();
                        } else if (text.equals('source')) {
                            source = parser.getText();
                        } else if (text.equals('title')) {
                            title = parser.getText();
                        } else if (text.equals('type')) {
                            type_Z = parser.getText();
                        } else if (text.equals('uri')) {
                            uri = parser.getText();
                        } else if (text.equals('uri_tree')) {
                            uri_tree = parser.getText();
                        }
                        //Added the below conditions
                        else if (text.equals('displaycategory')) {
                            displaycategory = parser.getText();
                        } else if (text.equals('status')) {
                            status = parser.getText();
                        } else if (text.equals('operational_unit')) {
                            operational_unit = parser.getText();
                        } else if (text.equals('displaywildcard1')) {
                            displaywildcard1 = parser.getText();
                        } else if (text.equals('displaywildcard2')) {
                            displaywildcard2 = parser.getText();
                        } else if (text.equals('positive_count')) {
                            positive_count = parser.getText();
                        } else if (text.equals('reply_count')) {
                            reply_count = parser.getText();
                        } else if (text.equals('filterproduct_version')) {
                            filterproduct_version = arrayOfProducts(parser);
                        } 
                        
                        else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Documents consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Stats {
        public Integer totalHits { get; set; }
        public Integer searchEngineTimeInMillis { get; set; }
        public Integer searchEngineRoundTripTimeInMillis { get; set; }
        public Integer searchProcessingTimeInMillis { get; set; }
        
        public Stats(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text.equals('totalHits')) {
                            totalHits = parser.getIntegerValue();
                        } else if (text.equals('searchEngineTimeInMillis')) {
                            searchEngineTimeInMillis = parser.getIntegerValue();
                        } else if (text.equals('searchEngineRoundTripTimeInMillis')) {
                            searchEngineRoundTripTimeInMillis = parser.getIntegerValue();
                        } else if (text.equals('searchProcessingTimeInMillis')) {
                            searchProcessingTimeInMillis = parser.getIntegerValue();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'Stats consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public without sharing class Children {
        public Children(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken().equals(System.JSONToken.FIELD_NAME)) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            System.debug(
                                LoggingLevel.WARN,
                                'Children consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public static JSON2Apex parse(String json) {
        try {
            System.JSONParser parser = System.JSON.createParser(json);
            return new JSON2Apex(parser);
        } catch (Exception e) {
            //EventLog.createLogFuture(Json.serialize(new EventLog.Error(GSTSearchConstantsUtility.JSON2Apex,GSTSearchConstantsUtility.parse, GSTSearchConstantsUtility.JSON2Apex, true, e)));
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void consumeObject(System.JSONParser parser) {
        try {
            Integer depth = 0;
            do {
                System.JSONToken curr = parser.getCurrentToken();
                if (
                    curr.equals(System.JSONToken.START_OBJECT) ||
                    curr.equals(System.JSONToken.START_ARRAY)
                ) {
                    depth++;
                } else if (
                    curr.equals(System.JSONToken.END_OBJECT) ||
                    curr.equals(System.JSONToken.END_ARRAY)
                ) {
                    depth--;
                }
            } while (depth > 0 && parser.nextToken() != null);
        } catch (Exception e) {
            EventLog.createLogFuture(
                Json.serialize(
                    new EventLog.Error(
                        GSTSearchConstantsUtility.JSON2Apex,
                        GSTSearchConstantsUtility.consumeObject,
                        GSTSearchConstantsUtility.JSON2Apex,
                        true,
                        e
                    )
                )
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static List<Facets> arrayOfFacets(System.JSONParser p) {
        List<Facets> res = new List<Facets>();
        if (p.getCurrentToken().equals(null))
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Facets(p));
        }
        return res;
    }
    
    private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken().equals(null))
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }
    
    private static List<FirstPage> arrayOfFirstPage(System.JSONParser p) {
        List<FirstPage> res = new List<FirstPage>();
        if (p.getCurrentToken().equals(null))
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FirstPage(p));
        }
        return res;
    }
    
    private static List<Documents> arrayOfDocuments(System.JSONParser p) {
        List<Documents> res = new List<Documents>();
        if (p.getCurrentToken().equals(null))
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Documents(p));
        }
        return res;
    }
    
    private static List<Children> arrayOfChildren(System.JSONParser p) {
        List<Children> res = new List<Children>();
        if (p.getCurrentToken().equals(null))
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Children(p));
        }
        return res;
    }
    
    private static List<Filters> arrayOfFilters(System.JSONParser p) {
        List<Filters> res = new List<Filters>();
        if (p.getCurrentToken().equals(null))
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Filters(p));
        }
        return res;
    }
    /*** U-2477 - Subashini Arulalan- New method for Itterating the products ***/
    private static List<String> arrayOfProducts(System.JSONParser p) {
        List<String> res = new List<String>();
        if(p.getCurrentToken().equals(System.JSONToken.VALUE_STRING) && !p.getText().equals('null')){
            res.add(p.getText());
        }
        else if (p.getCurrentToken().equals(System.JSONToken.START_ARRAY))
        {
            while (p.nextToken() != System.JSONToken.END_ARRAY ) {
                if (!p.getText().equals('null'))
                    res.add(p.getText());
            }
        }
        return res;
    }
    
}