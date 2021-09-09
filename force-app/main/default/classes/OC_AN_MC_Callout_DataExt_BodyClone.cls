public class OC_AN_MC_Callout_DataExt_BodyClone {
    public static string dataExtensionJson(String bulletinId){
        List<User> Userdata = new List<User>();
        //OC_AN_FetchUsersFromPG.getInternalUsersForBulletin(bulletinId);
        List<OC_AN_UserAndContactsWrapper> Userdata2 = OC_AN_FetchUsersFromPG.getInternalUsersForBulletin(bulletinId);
        system.debug('---->'+Userdata2);
        List<OC_AN_MC_Internal_Dist_Json> wrapper = new List<OC_AN_MC_Internal_Dist_Json>();
        for (OC_AN_UserAndContactsWrapper IDUser : Userdata2){
            OC_AN_MC_Internal_Dist_Json wrap = new OC_AN_MC_Internal_Dist_Json();
            wrap.keys = new OC_AN_MC_Internal_Dist_Json.Keys();
            wrap.keys.EmailWithBulletinId = IDUser.email + bulletinId;
            
            OC_AN_MC_Internal_Dist_Json.Values userValue = new OC_AN_MC_Internal_Dist_Json.Values();
            userValue.First_Name = IDUser.firstName;
            userValue.User_Id = IDUser.Id;
            userValue.Last_Name = IDUser.lastName;
            userValue.Name = IDUser.Name;
            userValue.Bulletin_Id = bulletinId;
            userValue.Email = IDUser.email;
            wrap.values = userValue;
            wrapper.add(wrap);
        }
        String jsonBody = JSON.serialize(wrapper);
        system.debug('---->'+jsonBody);
        return jsonBody;
    }
}