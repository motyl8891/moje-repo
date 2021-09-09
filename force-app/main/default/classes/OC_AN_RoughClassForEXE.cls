public with sharing class OC_AN_RoughClassForEXE {
    public static void execute() {

        OC_AN_MC_SOAP.ContentArea contentArea = new OC_AN_MC_SOAP.ContentArea();
        contentArea.Key = 'cell1';
        contentArea.Content = (' Test Email');

        OC_AN_MC_SOAP.Email email = new OC_AN_MC_SOAP.Email();
        email.Status = 'Test Email with Content Areas';
        email.Name = 'Test Email with Content Areas';
        email.Subject = 'email subject line';
        email.CharacterSet = 'UTF-8';
        email.HTMLBody = 'Test Body';       
        email.ContentAreas = (new OC_AN_MC_SOAP.ContentArea[]{contentArea});


        OC_AN_MC_SOAP.Soap stub = new OC_AN_MC_SOAP.Soap();
		stub.inputHttpHeaders_x.put('Authorization', 'Basic eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJYQmhRZjNYU3FNSW1HUW0xdG9QUXFndTUiLCJjbGllbnRfaWQiOiJsc3RlZ3Z1dnk4cWFqNmxhNGp6eXcwdjMiLCJlaWQiOjUxMDAwMzQ1OSwic3RhY2tfa2V5IjoiUzUwIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciJ9.NBB7LxahCcRHu_5ZfW5bpYCANe4WNMx0RR1EgJN6sN8.-rGIaVw31ih2_YShJTz_J7NMQiD1onzYIGGz682pfHsXqZlGgEDO3ueWNCXy6vBCCf4nR45EcVc1sEj7hOtbzIAJinuiuKZyfWQ5X21W5TZwceHOgTXs0jdCEc_40ln7O2el6V90n1BYtckqCxLq38oRihMKjEpLHLhEYKfXeqsKPSQFsfz');
        
        
        OC_AN_MC_SOAP.CreateRequest_element createRequest = new OC_AN_MC_SOAP.CreateRequest_element();
        createRequest.EmailObjects = new OC_AN_MC_SOAP.Email[]{email};
        createRequest.Options = new OC_AN_MC_SOAP.CreateOptions();
        OC_AN_MC_SOAP.CreateResponse_element results = stub.create(createRequest.Options,createRequest.Objects);
        System.debug('results :: ' + results.OverallStatus);
        
    }
}