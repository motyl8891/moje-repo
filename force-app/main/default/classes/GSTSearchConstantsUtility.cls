/**
* @File Name          : GSTSearchConstantsUtility.cls
* @Description        : U-1146,1147,1278 constants Utility Class
* @Author             : Ankit Jain
* @Group              :
* @Last Modified By   : Ankit Jain
* @Last Modified On   :
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-18 16:02:32       Ankit Jain           Initial Version
* 2.0    2020-04-14               Nikita Sachdeva	   R2005, U-1663 Adding Addititonal Header Parameter
* 3.0    2020-4-14                Nikita Sachdeva      R2005, U-1750 To send a static parameter as part of the search URL
* 4.0    2021-02-15               Sandeep Singh       U-2473 To send additional static date filter to GST.
* 5.0    2021-02-22          	  Sandeep Singh       U-2474  Added additional parameter for GST format filter.
* 6.0    2021-02-23               Subashini Arulalan  U-2470 Added addtional parameter as part of clicklogs
* 7.0    2021-04-09          	  Sandeep Singh       U-2478  Added additional parameter for GST SaerchHit filters.
* 8.0    2021-06-08               Sandeep Singh       U-2808  Added additional Static parameter as part of the search URL.
**/
public without sharing class GSTSearchConstantsUtility {
    public static string CS_BASE_URL = 'Base_URL';
    public static string TOKEN_PARAM = '&token=';
    public static string CS_TOKEN_PARAM = 'Token';
    public static string GET = 'GET';
    public static string MISC_INITIAL = '&misc=%7B%7D';
    public static string MISC_REPLACE = '&misc={%22feedback%22:[%22';
    public static string MISC_REPLACE_REMAINING = '%22]}';
    public static string POSITIVE = 'positive';
    public static string NEGATIVE = 'negative';
    public static string CS_EXTERNAL_PROFILE = 'External_Profile';
    public static string CS_INTERNAL_USER_SIGNUM = 'Internal_User_Signum';
    public static string QUERY_PARAM = '?q=';
    public static string HITS_PARAM = '&hits=';
    public static string OFFSET_PARAM = '&offset=';
    public static string USER_PARAM = '&user=';
    public static string FACET_PARAM = '&facet_source=';
    public static string CS_FACET_SOURCE = 'Facet_source';
    public static string SEARCH_APP_SESSION_ID_PARAM = '&searchapp=salesforce&sessionid=';
    public static string REALUSER_PARAM = '&realuser=';
    public static string NODETYPE_PARAM = '&node_type=';
    public static string PLATFORM_PARAM = '&platform=';
    public static string TECHNOLOGY_PARAM = '&technology=';
    public static string GST_CONNECTIVITY_ISSUE = System.label.GST_Search_Connectivity_Issue;
    public static string EXCEPTION_MESSAGE = System.label.GST_Search_Exception;
    public static string RECENTSEARCH = 'RecentSearch';
    public static string RECENTSEARCHRESULT = 'recentsearchresult';
    public static string CustomSearchController = 'CustomSearchController';
    public static string searchForIds = 'searchForIds';
    public static string CustomSearchResultsListController = 'CustomSearchResultsListController';
    public static string updateLikeClick = 'updateLikeClick';
    public static string updateClick = 'updateClick';
    public static string JSON2Apex = 'JSON2Apex';
    public static string parse = 'parse';
    public static string consumeObject = 'consumeObject';
    public static string AND_SIGN = '&';
    public static string AND_SIGN_REPLACEMEENT = '%2526';
    public static string Select_Product = '----Select Product----';
    public static string ZERO = '0';
    public static Integer TWO_HUNDRED = 200;
    public static string fetchUniqueProduct = 'fetchUniqueProduct';
    public static string Exclamation_SIGN = '!';
    public static string Exclamation_SIGN_REPLACEMEENT = '%5C%21';
    public static string CS_Click_Base_URL = 'Click_Base_URL';
    public static string QUESTION_MARK = '?';
    public static string AUTHORIZATION = 'Authorization';
    public static string BASIC = 'BASIC ';
    public static string CS_Click_Base_URL_USR = 'Click_Base_URL_USR';
    public static string CS_Click_Base_URL_PWD = 'Click_Base_URL_PWD';
    public static string COLON = ':';
    public static string URI_TREE_START = '%22uri_tree%22';
    public static string URI_TREE_END = '%22%7D';
    public static string UTF_ENCODE = 'UTF-8';
    public static string HASH = '#';
    public static string SUCCESS = 'Success';
    public static string FAILED = 'Failed';
    public static string Max_Search_Results = 'Max_Search_Results';
    public static string Space_Char = ' ';
    public static string Space_Char_REPLACEMEENT = '%20';
    public static string updateForumClick = 'updateForumClick';
    public static string QuestionPost = 'QuestionPost';
    public static string LIVE = 'LIVE';
    public static string POST_URL = 'POST_URL';
    public static string searchForForum = 'searchForForum';
    public static String BLANK = '';
    public static string Forum_EXCEPTION_MESSAGE = System.label.Forum_Search_Exception;
    public static string HEADER_TOKEN_PARAM = 'token';
    public static string CS_HEADER_TOKEN_PARAM = 'HeaderToken';
    //R2005, U-1663 , 2020-04-13 Nikita Sachdeva Addititonal Header Parameter to be sent while hitting GST API
    public static string REFERRER_HEADER = 'Referrer_Header';
    public static string REFERRER_CONSOLE = 'Referrer_Console';
    public static string REFERRER_COMMUNITY = 'Referrer_Community';
    //R2005, U-1750 , 2020-04-13 Nikita Sachdeva To send a additional static parameter as part of the search URL.
    public static string CPI_DOC_NUMBER_PARAM = 'Cpi_Doc_Number_Param';
    public static string CPI_DOC_NUMBER_PARAM_VALUE = 'Cpi_Doc_Number_Param_Value';
    public static string EQUAL_SIGN = '=';
    public static string Word_Format_Start = '<em>';
    public static string Word_Format_Start_Replacement = '<b><em>';
    public static string Word_Format_End = '</em>';
    public static string Word_Format_End_Replacement = '</em></b>';
    //U-2473 Sandeep Singh To send a additional static date filter to GST.
    public static string Date_Filter = '&date=';
    //U-2474 Sandeep Singh To send a additional format filter to GST.
    public static string Format_Filter = '&facet_format=';
    // Added by Sandeep
    public static string Product_Filter = '&facet_product=';
    public static string getclickurl_Index = '%22&misc'; 
    public static string clickurl_realuser = '%26realuser';
    public static string clickurl_user = '%26user';
    public static string EQUAL_SIGN_REPLACEMENT = '%3D';
    //public static Map<String, List<string>> Filters = null;
    // U-2478 added by Sandeep for GST SearchHit filter start
    public static string Category_Filter = '&filter_displaycategory=';
    public static string Status_Filter = '&filter_status=';
    public static string OperationalUnit_Filter = '&filter_operational_unit=';
    public static string Wildcard1_Filter = '&filter_displaywildcard1=';
    public static string Wildcard2_Filter = '&filter_displaywildcard2=';
    //U-2808 added by Sandeep for GST SearchHit Product version filter
    public static string Product_Version = '&filter_filterproduct_version=';
}