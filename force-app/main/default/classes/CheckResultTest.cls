@isTest
public class CheckResultTest {
	@isTest
	static void setCheckResultOK() {
		CheckResult chResTest = new CheckResult();
		Boolean CheckRes = true;

		chResTest.setcheckResult(true);
		System.assertEquals(CheckRes, chResTest.getcheckResult());
	}

	@isTest
	static void setCheckResultOKString() {
		CheckResult chResTest = new CheckResult();
		String CheckRes = 'Ok';

		chResTest.setokResult('Ok');
		System.assertEquals(CheckRes, chResTest.getokResult());
	}

	@isTest
	static void setCheckResulttoError() {
		CheckResult chResTest = new CheckResult();
		Boolean CheckRes = true;

		chResTest.setisError(true);
		System.assertEquals(CheckRes, chResTest.getisError());
	}

	@isTest
	static void setCheckResulttoErrorString() {
		CheckResult chResTest = new CheckResult();
		String CheckRes = 'Ok';

		chResTest.seterrResult('Ok');
		System.assertEquals(CheckRes, chResTest.geterrResult());
	}
}