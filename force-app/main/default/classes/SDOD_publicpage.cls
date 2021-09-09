public class SDOD_publicpage {
        public String requiredname {get;set;}

    public String framelocation {get;set;}
    public boolean display {get;set;}
	public SDOD_Lead__c slead {get; set;}         
    public SDOD_publicpage(ApexPages.StandardController controller) {
        Try{
 		requiredname ='ericsson.com';//
         		//requiredname ='vasa_tcs_com';//

        display = true;
        framelocation='';
        slead = new SDOD_Lead__c();
        }catch(Exception e){	}
        }
    public PageReference checkframeapex() {
        if (framelocation!='showframe'){display = false;}
        return null;}
    public PageReference save(){   
      try{	
    	insert slead;        
		PageReference location = new PageReference(GlobalConstants.SLASH+ slead.id);
		location.setRedirect(true);        
		return location;}
     catch (Exception ex) {
		 ApexPages.addMessages(ex);
		 return null;}}}