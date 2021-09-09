/**
* @File Name          : OC_AN_MC_Utils
* @Description        : Utility class for the MC.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2106
* @Created Date       : 20th May 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-20                 IBM                   Initial Version
**/
public with sharing class OC_AN_MC_Utils {

    public static final String MARKETING_CLOUD_INSTANCE = OC_AN_Constants.MC_INSTANCE;
    public static final String MARKETING_CLOUD_INSTANCE_SOAP_URL = OC_AN_Constants.HTTPS+MARKETING_CLOUD_INSTANCE+OC_AN_Constants.MC_SOAP_URL;
    public static final String MARKETING_CLOUD_INSTANCE_BASE_URL = OC_AN_Constants.HTTPS+MARKETING_CLOUD_INSTANCE+OC_AN_Constants.MC_BASE_URL; 
    public static final String MARKETING_CLOUD_INSTANCE_REST_URL = OC_AN_Constants.HTTPS+MARKETING_CLOUD_INSTANCE+OC_AN_Constants.MC_REST_URL;
    public static final String MARKETING_CLOUD_INSTANCE_INTERACTIONS_REST_URL = OC_AN_Constants.HTTPS+MARKETING_CLOUD_INSTANCE+OC_AN_Constants.MC_INTERACTION_REST_URL;
    public static final String MARKETING_CLOUD_INSTANCE_ACCESS_URL = OC_AN_Constants.V2_TOKEN; 
    public static final String MARKETING_CLOUD_INSTANCE_REST_EMAIL = OC_AN_Constants.CONTENT_ASSETS; 
    public static final String CONTENT = OC_AN_Constants.Content;
    public static final String POST_METHOD_TYPE = OC_AN_Constants.httpMethodPOST;
    public static final String MC_ID_END_POINT = OC_AN_Constants.Mc_Id_End_Point;
    public static String MC_END_POINT_DE = OC_AN_Constants.HTTPS+MARKETING_CLOUD_INSTANCE+OC_AN_Constants.Mc_End_Point_De;
    
}