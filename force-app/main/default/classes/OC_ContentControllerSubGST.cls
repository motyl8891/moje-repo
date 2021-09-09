/**
* @File Name          : OC_ContentControllerSubGST
* @Description        : On Global search from OmniChannel Community, this method will serve as medium to get the results from CustomSearchController which furhter calling GST APIs
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 10th April 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-04-10              Rohit Gaba               Initial Version
* 3.0        2020-02-15              Sandeep Singh            U-2496 Added additional parameter for GST Source Filter
* 4.0        2021-02-15              Sandeep Singh            U-2473 Added additional parameter for GST static date filter.
* 5.0        2021-02-22              Subashini Arulalan       U-2474 Added additional parameter for GST format filter.
* 6.0        2021-03-15              Sandeep Singh            U-2472 Added additional parameter for GST product filter in searchForIds method.
* 7.0        2021-04-09              Sandeep Singh            U-2478 Added additional parameter for GST SearchHit filter in searchForIds method.
* 8.0        2021-05-10              Sandeep Singh            U-2728 Added additional parameter for date filter in getSearchData method.
* 9.0        2021-06-08              Sandeep Singh            U-2808  Added additional parameter for GST SearchHit Product Version filter in searchForIds method.
* 10.0       2021-07-05              Sandeep Singh            U-2729 Added additional parameter for customer portal Format filter in getSearchData method.
* 11.0       2021-08-18              Sandeep Singh            U-2730 Added additional parameter for customer portal GST Search Hits Design in getSearchData method.
**/
public class OC_ContentControllerSubGST {
    
    //Get the results for global search
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestSearch(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OCResponseGSTSearch response = new OmniChannelThemeRequestReponseWrappers.OCResponseGSTSearch();
        OmniChannelThemeRequestReponseWrappers.OCResponseGSTSourceItemsCount searchItemsCount = new OmniChannelThemeRequestReponseWrappers.OCResponseGSTSourceItemsCount();
        OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch.class) ;
        //OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch) request.requestBody;
        response.requestType = request.requestType;
        response.requestSubType = request.requestSubType;
        List<Object> tempResponse = getSearchData(String.valueOf(requestBody.searchText),
                                                  Integer.valueOf(requestBody.maxHits),
                                                  Integer.valueOf(requestBody.offset),
                                                  Boolean.valueOf(requestBody.paggination),
                                                  String.valueOf(requestBody.dateFilter),
                                                  String.valueOf(requestBody.formattype),
                                                  String.valueOf(requestBody.selectedSource),
                                                  String.valueOf(requestBody.selectedCategory),
                                                  String.valueOf(requestBody.selectedStatus),
                                                  String.valueOf(requestBody.selectedOpUnit),
                                                  String.valueOf(requestBody.selectedProdtVer),
                                                  requestBody.prodtVerFilterArray,
                                                  String.valueOf(requestBody.selectedWC1),
                                                  String.valueOf(requestBody.selectedWC2)
                                                 );
        response.requestedData = tempResponse;
        response.currentPageNumber = Integer.valueOf(requestBody.offset)/Integer.valueOf(requestBody.maxHits)+1;
        response.searchItemsCount = searchItemsCount;
        if(tempResponse != null && !tempResponse.isEmpty()){
            response.searchItemsCount.elex = getSearchCount(tempResponse);
        }
        else{
            response.searchItemsCount.elex = 0;
        }
        
        
        if(request.requestSubType != null && request.requestSubType.toLowerCase() == 'forum'){
            tempResponse = getForumsData(String.valueOf(requestBody.searchText));
            response.requestedData = tempResponse;
            response.currentPageNumber = 1;
            response.searchItemsCount.forum = tempResponse.size();
        }
        else{
            response.searchItemsCount.forum = getForumsCount(requestBody.searchText);
        }
        
        return response;
    }
    
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequestSearchClick(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse response = new OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse();	
        OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearchItemClick requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearchItemClick) JSON.deserialize(JSON.serialize(request.requestBody), OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearchItemClick.class) ;
        //OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch requestBody = (OmniChannelThemeRequestReponseWrappers.OCRequestGSTSearch) request.requestBody;
        response.requestType = request.requestType;
        response.requestSubType = request.requestSubType;
        //GST Calling will be optimized with new sources in place
        //LPAS-65 Subashini Arulalan - Added params 'gstclickurl' for updateclick method
        response.requestedData = OC_ContentControllerSubGSTClickTemp.updateClick(requestBody.searchItemUrl,'','',null,requestBody.GSTclickURL);
        return response;
    }
    
    private static List<Object> getSearchData(String searchText, Integer hits, Integer offset, Boolean paggination, String dateFilter, String formattype, String selectedSource, String selectedCategory, String selectedStatus, String selectedOpUnit, String selectedProdtVer, List <String> prodtVerFilterArray, String selectedWC1, String selectedWC2) {        
        //GST Calling will be optimized with new sources in place
        return CustomSearchController.searchForIds(searchText, hits, offset, paggination, '0', '', null, selectedSource, dateFilter, formattype, null, prodtVerFilterArray, selectedCategory, selectedStatus, selectedOpUnit, selectedWC1, selectedWC2, selectedProdtVer);
    }
    private static Integer getSearchCount(List<Object> tempResponse) {        
        //GST Calling will be optimized with new sources in place
        return ((CustomSearchController.SearchResultWrapper)tempResponse.get(0)).totalsHits;
    }
    private static List<Object> getForumsData(String searchText) {        
        //GST Calling will be optimized with new sources in place
        return CustomSearchController.searchForForum(searchText);
    }
    private static Integer getForumsCount(String searchText) {        
        //GST Calling will be optimized with new sources in place
        return CustomSearchController.searchForForum(searchText).size();
    }
}