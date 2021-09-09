@isTest
private class GenericRestClientTest {
	static testMethod void test_setHeader() {
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.setHeader('header', 'value');
	}
	static testMethod void testGetHeader() {
		Test.startTest();
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.setHeader('header', 'value');
		Test.stopTest();
		System.assertEquals('value', websrv.getHeader('header'));
	}
	static testMethod void setJSONBody() {
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.setJSONBody('header');
	}
	static testMethod void setBinaryBody() {
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.setBinaryBody(Blob.valueOf('header'));
	}
	static testMethod void setMethod() {
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.setMethod('POST');
	}
	static testMethod void setTimeout() {
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.setTimeout(10);
	}
	static testMethod void test_buildRequest() {
		Test.startTest();
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.startNewRequest('Service');
		websrv.addParam('TestString', 'TEST');
		websrv.addParam('SpecialString', 'Welcome');
		Test.stopTest();
		System.assertEquals(
			'TestString=TEST&SpecialString=Welcome',
			websrv.getRequest()
		);
	}
	static testMethod void test_sendRequest() {
		GenericRestClient websrv = new GenericRestClient('URL');
		websrv.startNewRequest('Service');
		websrv.addParam('Test String', 'TEST');
		websrv.addParam('SpecialString', 'Welcome');
		Test.startTest();
		try {
			websrv.createPostRequest();
		} catch (System.CalloutException ce) {
		}
		Test.stopTest();
	}

	/**
      Positive test. Get response body when no request has been made.
     **/
	static testMethod void test_getResponseBodyNull() {
		GenericRestClient websrv = new GenericRestClient('URL');
		System.assertEquals('', websrv.getResponseBody());
	}
	/**
      Positive test. Get response body when no request has been made.
     **/
	static testMethod void test_getResponseStatusNull() {
		GenericRestClient websrv = new GenericRestClient('URL');
		System.assertEquals(-1, websrv.getResponseStatus());
	}
	/**
      Positive test. Get response body when no request has been made.
     **/
	static testMethod void test_getResponseBinaryBody() {
		GenericRestClient websrv = new GenericRestClient('URL');
		System.assertEquals(Blob.valueOf(''), websrv.getBinaryBody());
	}
	static testMethod void test_getResponseJsonBodyBodyNull() {
		GenericRestClient websrv = new GenericRestClient('URL');

		System.assertEquals(null, websrv.getJSONBody());
	}

	static testMethod void test_getResponseDocumentNull() {
		GenericRestClient websrv = new GenericRestClient('URL');
		System.assertEquals(null, websrv.getResponseDocument());
	}

	static testMethod void test_getResponseNull() {
		GenericRestClient websrv = new GenericRestClient('URL');
		System.assertEquals(null, websrv.getResponse());
	}
}