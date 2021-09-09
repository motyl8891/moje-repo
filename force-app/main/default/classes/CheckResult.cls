/********************************************************************************
* @author:  Andrejs Veliks
* @date:  2017-10-18
* @description: This is the general class for returning complex result for binary
				checking result (true or false + error msg or/and OkResult String)
*********************************************************************************/
public with sharing class CheckResult {
	private boolean checkResult;
	private boolean isError;
	private string errResult;
	private string okResult;

	public checkResult() {
		this.checkResult = false;
		this.isError = false;
		this.errResult = '';
		this.okResult = '';
	}

	public void setcheckResult(boolean res) {
		this.checkResult = res;
	}

	public boolean getcheckResult() {
		return this.checkResult;
	}

	public void setisError(boolean res) {
		this.isError = res;
	}

	public boolean getisError() {
		return this.isError;
	}

	public void seterrResult(String sres) {
		this.errResult = sres;
	}

	public String geterrResult() {
		return this.errResult;
	}

	public void setokResult(String sres) {
		this.okResult = sres;
	}

	public String getokResult() {
		return this.okResult;
	}
}