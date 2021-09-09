/**
* @File Name          : OC_AN_MC_Internal_Dist_Json
* @Description        : Json to Apex Class for Internal Distribution of Internal Users
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
public class OC_AN_MC_Internal_Dist_Json{

	public Keys keys;
	public Values values;

	public class Keys {
		public String EmailWithBulletinId;
	}

	public class Values {
		public String First_Name;
		public String User_Id;
		public String Last_Name;
        public String Name;	
		public String Bulletin_Id;
		public String Email;
        public String BulletinType;
		public String BulletinStatus;
	}
	
	public static List<OC_AN_MC_Internal_Dist_Json> parse(String json) {
		return (List<OC_AN_MC_Internal_Dist_Json>) System.JSON.deserialize(json, List<OC_AN_MC_Internal_Dist_Json>.class);
	}
}