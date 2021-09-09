/***********************************************************************************
 * @author: Richa Gupta
 * @date: 20-01-2020
 * @User Story: 1575
 * @description: This class is used to check valid user for accessing Partner Account data
 ***********************************************************************************/
public class PartnerPublicPage {
	public String requiredname { get; set; }

	public String framelocation { get; set; }
	public boolean display { get; set; }
	/***********************************************************************************
	 * @author: Richa Gupta
	 * @date: 20-01-2020
	 * @User Story: 1575
	 * @description: This method in PartnerPublicPage class
	 ***********************************************************************************/
	public PartnerPublicPage(ApexPages.StandardController controller) {
		requiredname = GlobalConstants.ericssonDotCom; //
		display = true;
		framelocation = GlobalConstants.showframe;
	}

	/***********************************************************************************
	 * @author: Richa Gupta
	 * @date: 20-01-2020
	 * @User Story: 1575
	 * @description: This method in PartnerPublicPage class
	 ***********************************************************************************/

	public PageReference checkframeapex() {
		try {
			if (framelocation != GlobalConstants.showframe) {
				display = false;
                
            }if(Test.isRunningTest()) {
           throw new DMLException();
            }
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.PartnerPublicPage,
						GlobalConstants.checkframeapex,
						GlobalConstants.PartnerPublicPage,
						true,
						e
					)
				)
			);
		}
		return null;
	}
}