/*******************************************************************
 * @author: Nikolajs Jurickis, Ahmad Amiri
 * @date: 2018-01-18
 * @description: Class to easily consume an external REST web service
 ********************************************************************/

public with sharing class GenericRestClient {
	// Http objects used in this class
	private HttpRequest httpRequest = new HttpRequest();
	private Http http = new Http();
	private HTTPResponse httpResponse;

	private String serviceURL; // The base URL to the web server
	private String service; // The service to use. I.e., "function" or "method"
	private String btCharset = GlobalConstants.URL_ENCODING_SCHEME_DEFAULT;
	private String request; // Request to send
	private String lastResponse; // Last response given
	private String namedCredential; //Named Credential stored in SF

	public GenericRestClient(String serviceURL) {
		this.serviceURL = serviceURL;
		httpRequest.setMethod(GlobalConstants.HTTP_METHOD_POST);
	}

	public GenericRestClient() {
	}

	public String getRequest() {
		return request;
	}

	public void setHeader(String header, String value) {
		httpRequest.setHeader(header, value);
	}

	public String getHeader(String key) {
		return httpRequest.getHeader(key);
	}

	public void startNewRequest(String service) {
		this.service = service;
		request = '';
	}

	public void addParam(String attribute, String value) {
		request += generateKeyValuePair(request, attribute, value);
	}

	public void setJSONBody(String s) {
		request = s;
	}

	public String getJSONBody() {
		return request;
	}

	public void setBinaryBody(Blob body) {
		httpRequest.setBodyAsBlob(body);
	}

	//
	public void setBody(String body) {
		httpRequest.setBody(body);
	}

	public void setResponse(HttpResponse response) {
		this.httpResponse = response;
	}
	public void setMethod(String method) {
		if (method.equals('GET') || method.equals('POST')) {
			httpRequest.setMethod(method);
		}
	}

	public void setTimeout(Integer seconds) {
		httpRequest.setTimeout(seconds * 1000);
	}

	/****************************************************************
	 * @author: Nikolajs Jurickis, Ahmad Amiri
	 * @date: 2018-01-18
	 * @param: currentQueryStr<br>
	 * @param: key<br>
	 * @param: value<br>
	 * @return: String Key = Value<br>
	 * @description: Generates a key value pair string.If the current query string is non-empty, include separator<br>
	 *****************************************************************/
	public String generateKeyValuePair(
		String currentQueryStr,
		String key,
		String value
	) {
		system.debug('generateKeyValuePair> key=' + key + ', value=' + value);

		// Ensure that everything has content
		if (currentQueryStr == null || key == null || value == null)
			return '';

		key = Encodingutil.urlEncode(key, btCharset);
		value = Encodingutil.urlEncode(value, btCharset).replaceAll('\\+', '%20');

		System.debug(
			'generateKeyValuePair: encoded: key=' +
			key +
			', value=' +
			value
		);

		// Create
		if (currentQueryStr.length() > 0) {
			return '&' + key + '=' + value;
		} else {
			return key + '=' + value;
		}
	}

	/****************************************************************
	 * @author: Nikolajs Jurickis, Ahmad Amiri
	 * @date: 2018-01-18
	 * @param: N/A<br>
	 * @return: Void<br>
	 * @description: Send a http request to the web service<br>
	 *****************************************************************/
	public HttpRequest createPostRequest() {
		system.debug('sendRequest> endpoint=' + serviceURL + service);

		// Set which service to use
		httpRequest.setEndpoint(serviceURL + service);

		// Set the request contents
		if (httpRequest.getMethod().equalsIgnoreCase('POST')) {
			if (String.isBlank(httpRequest.getBody())) {
				httpRequest.setBody(request);
			}
			system.debug('sendRequest> POST request=' + request);
		}
		system.debug('sendRequest> request=' + request);

		return httpRequest;
	}

	/****************************************************************
	 * @author: Nikolajs Jurickis, Ahmad Amiri
	 * @date: 2018-01-18
	 * @param: N/A<br>
	 * @return: Integer status code<br>
	 * @description: The method return response status code<br>
	 *****************************************************************/
	public Integer getResponseStatus() {
		if (httpResponse != null) {
			return httpResponse.getStatusCode();
		} else {
			return -1;
		}
	}

	/****************************************************************
	 * @author: Nikolajs Jurickis, Ahmad Amiri
	 * @date: 2018-01-18
	 * @param: N/A
	 * @return: Dom.Document <br>
	 * @description: The method return response get body dokument <br>
	 *****************************************************************/
	public Dom.Document getResponseDocument() {
		if (httpResponse != null) {
			return httpResponse.getBodyDocument();
		} else {
			return null;
		}
	}

	/****************************************************************
	 * @author: Nikolajs Jurickis, Ahmad Amiri
	 * @date: 2018-01-18
	 * @param: N/A <br>
	 * @return: String responsebody <br>
	 * @description: The method return response get body<br>
	 *****************************************************************/
	public String getResponseBody() {
		if (httpResponse != null) {
			return httpResponse.getBody();
		} else {
			return '';
		}
	}

	public Blob getBinaryBody() {
		if (httpResponse != null) {
			return httpResponse.getBodyAsBlob();
		} else {
			return Blob.valueOf('');
		}
	}

	public HTTPResponse getResponse() {
		return httpResponse;
	}

	/****************************************************************
	 * @author: Nikolajs Jurickis, Ahmad Amiri
	 * @date: 2018-01-18
	 * @param: Url end point<br>
	 * @param: Access token<br>
	 * @return: HttpRequest <br>
	 * @description: The method create Get httpRequest <br>
	 *****************************************************************/
	public HttpRequest createRequestBearerGet(
		String service,
		String accessToken
	) {
		httpRequest.setMethod(GlobalConstants.HTTP_METHOD_GET);
		httpRequest.setHeader(
			GlobalConstants.HTTP_HEADER_FIELD_NAME_AUTHORIZATION,
			GlobalConstants.HTTP_HEADER_FIELD_AUTHORIZATION_VALUE_BEARER + accessToken
		);
		httpRequest.setEndpoint(serviceURL + service);
		return httpRequest;
	}

	/****************************************************************
	 * @author: Linda Pavare
	 * @date: 2018-01-19
	 * @param: namedCredential
	 * @return: HttpRequest <br>
	 * @description: The method creates Get httpRequest with Named Credential <br>
	 *****************************************************************/
	public HttpRequest createReqWithNamedCredGet(String namedCredential) {
		httpRequest.setHeader('Content-Type', 'text/xml');
		httpRequest.setHeader(
			'Soapaction',
			'I170607OpportunityUpdate_imp_p1_ws_OpportunityUpdateWebSrvc_Binder_OpportunityUpdate'
		);

		httpRequest.setMethod(GlobalConstants.HTTP_METHOD_POST);
		httpRequest.setEndpoint(namedCredential);
		return httpRequest;
	}
}