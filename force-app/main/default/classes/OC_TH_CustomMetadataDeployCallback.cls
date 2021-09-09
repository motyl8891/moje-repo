public class OC_TH_CustomMetadataDeployCallback implements Metadata.DeployCallback {
public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('Success===>'+ result);
            List<Metadata.DeployMessage> successlist = result.details.componentsuccesses;
            List<String>fullnames = new List<String>();
            for(Metadata.DeployMessage listiterate:successlist){
                if(listiterate.fullName != OC_TH_createcustommetadataconstants.packagexml){
                String editname = listiterate.fullName;
                editname = editname.replace(OC_TH_createcustommetadataconstants.compare,'');
                fullnames.add(editname);
            }
            }
            System.debug(fullnames);
            OC_TH_createcustommetadatahelper.updatestatus(fullnames);
        } else {
            // Deployment was not successful
            System.debug('Fail===>'+ result);
        }                         
}
}