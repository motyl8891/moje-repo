/**
 * @File Name          : OC_AN_MC_Callout_DataExt_Body
 * @Description        : Data Extension Internal User Body
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
public class OC_AN_MC_Callout_DataExt_Body{
	public static string dataExtensionJson(String bulletinId,String BULLETIN_Type, String BulletinStatus){
		List<OC_AN_UserAndContactsWrapper> Userdata = OC_AN_FetchUsersFromPG.getInternalUsersForBulletin(bulletinId);
		List<OC_AN_MC_Internal_Dist_Json> wrapper = new List<OC_AN_MC_Internal_Dist_Json>();
		for (OC_AN_UserAndContactsWrapper IDUser : Userdata){
			OC_AN_MC_Internal_Dist_Json wrap = new OC_AN_MC_Internal_Dist_Json();
			wrap.keys = new OC_AN_MC_Internal_Dist_Json.Keys();
			wrap.keys.EmailWithBulletinId = IDUser.Email + bulletinId;

			OC_AN_MC_Internal_Dist_Json.Values userValue = new OC_AN_MC_Internal_Dist_Json.Values();
			userValue.First_Name = IDUser.FirstName;
			userValue.User_Id = IDUser.Id;
			userValue.Last_Name = IDUser.LastName;
			userValue.Name = IDUser.Name;
			userValue.Bulletin_Id = bulletinId;
			userValue.Email = IDUser.Email;
            userValue.BulletinType = BULLETIN_Type;
			userValue.BulletinStatus = BulletinStatus;
			wrap.values = userValue;
			System.debug(wrap);
            wrapper.add(wrap);
		}
		String jsonBody = JSON.serialize(wrapper);
        system.debug('OC_AN_MC_Callout_DataExt_Body:'+JSON.serializePretty(wrapper));
		return jsonBody;
	}
}