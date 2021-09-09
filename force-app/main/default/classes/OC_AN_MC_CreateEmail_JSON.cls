/**
* @File Name          : OC_AN_MC_CreateEmail_JSON
* @Description        : Json to Apex Class Variables Defined
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : U-2763, U-2782
* @Created Date       : 07th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-07                 IBM                   Initial Version
**/
public class OC_AN_MC_CreateEmail_JSON {

    public class AssetType {
        public String name;
        public Integer id;
    }
    
    public class Views {
        public Html html;
        public Text text;
        public Text subjectline;
        public Text preheader;
    }
    
    public String name;
    public Channels channels;
    public Views views;
    public AssetType assetType;
    public String content;

    
    public class Html {
        public String content;
    }
    
    public class Text {
        public String content;
    }
    
    public class Channels {
        public Boolean email;
        public Boolean web;
    }
    
    
    public static OC_AN_MC_CreateEmail_JSON parse(String json) {
        return (OC_AN_MC_CreateEmail_JSON) System.JSON.deserialize(json, OC_AN_MC_CreateEmail_JSON.class);
    }
}