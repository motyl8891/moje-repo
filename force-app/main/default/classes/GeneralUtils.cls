/*******************************************************************************
* @author:  Andrejs Veliks
* @date:    2017-10-20
* @description: This is the general class with common functions for general 
purposes working with integration project 
********************************************************************************/
public with sharing class GeneralUtils { 
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        Try{
            while (randStr.length() < len) {
                Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                randStr += chars.substring(idx, idx+1);
            }
        }catch(Exception e){	}
        return randStr; 
    }    
    
    
    //private static Pricebook2 stdPriceBook;
    
    /****************************************************************
* @author:  Linda Pavare
* @date:    2017-10-20
* @return   ID
* @description: This method returns Id for Price Book from SF
*****************************************************************/
    /* public static ID getStdPricebookId() {
if (Test.isRunningTest())   return Test.getStandardPricebookId();
return getStdPricebook().id;    
} */
    
    /****************************************************************
* @author:  Linda Pavare
* @date:    2017-10-20    
* @return   stdPriceBook 
* @description: This method returns standart Price Book from SF
*****************************************************************/
    /*public static Pricebook2 getStdPriceBook () {
if (stdPriceBook == null) {
stdPriceBook    = [select id, name from Pricebook2 where isStandard = true limit 1];}
return stdPriceBook;    
}*/
    
    /****************************************************************
* @author:  Andrejs Veliks
* @date:    2017-10-20
* @param:   inputString
* @param:   charcount 
* @return   result
* @description: This method return string with length not more 
than charcount symbols  
*****************************************************************/
    public static String checkInputString(String inputString, Integer charcount){
        String result='';
        Try{
            if (inputString!=''){
                if (inputString.length()>charcount) {            
                    result=inputString.substring(0, charcount-1);            
                }
                else{
                    
                    result=inputString;
                } 
            } 
        }catch(Exception e){	}
        return result;
    }
    
    /****************************************************************
* @author:  Andrejs Veliks
* @date:    2017-10-20
* @param:   srcClass
* @param:   errCode 
* @param:   errMessage 
* @param:   srcMethod 
* @param:   srcObjectName 
* @param:   userID 
* @return   ch_res
* @description: This method save single error in Exception__C 
custom object. IF attempt fail error save in 
System.debug()  

public static CheckResult singleSaveException(String srcClass, 
String errCode, 
String errMessage,
String srcMethod,
String srcObjectName,
String userID ){

CheckResult chRes = new CheckResult();

Exception__c exc = new Exception__c();

exc.Class__c        = srcClass;
exc.ErrorCode__c    = errCode;
exc.ErrorMessage__c = errMessage;
exc.Method__c       = srcMethod;
exc.ObjectName__c   = srcObjectName;
exc.User__c         = userID;

try {
insert exc;
chRes.setcheckResult(true);
}
catch(Exception e){
chRes.setcheckResult(false);
chRes.setisError(true);
chRes.seterrResult('[EXCEPTION OBJECT] Exception in attempt to save Exception Object: ' + e.getMessage() );

System.debug('[EXCEPTION OBJECT] Exception in attempt to save Exception Object: ' + e.getMessage());
}

return chRes;
}
*****************************************************************/
    
    
    /****************************************************************
* @author:  Andrejs Veliks
* @date:    2017-10-20
* @param:   srcClass
* @param:   errCode 
* @param:   errMessage 
* @param:   srcMethod 
* @param:   srcObjectName 
* @param:   userID 
* @return   exc
* @description: This method save error in Exception__c object
*****************************************************************/
    public static Exception__c createException(String srcClass, 
                                               String errCode, 
                                               String errMessage,
                                               String srcMethod,
                                               String srcObjectName,
                                               String userID ){
                                                   
                                                   Exception__c exc = new Exception__c();
                                                   Try{
                                                       exc.Class__c        = srcClass;
                                                       exc.ErrorCode__c    = errCode;
                                                       exc.ErrorMessage__c = errMessage;
                                                       exc.Method__c       = srcMethod;
                                                       exc.ObjectName__c   = srcObjectName;
                                                       exc.User__c         = userID;
                                                   }catch(Exception e){	}
                                                   return exc;    
                                               }                                            
    
    public static Exception__c[] excLst = new List<Exception__c>();
    
    /****************************************************************
* @author:  Andrejs Veliks
* @date:    2017-10-20
* @param:   fld
* @param:   fldname 
* @param:   fld_length 
* @param:   fnName 
* @return   ch_res
* @description: This method compare Field message length with 
field type length. If message is larger, function 
return substring with allowed length and save 
original message in Exception object. Exception 
object added to exception's list. 
*****************************************************************/
    public static CheckResult checkFieldMsg(String fld,
                                            String fldname, 
                                            Integer fldLength,
                                            String  className,
                                            String  fnName){
                                                
                                                CheckResult chRes = new CheckResult(); 
                                                String strresult='';
                                                String errString='';
                                                
                                                Exception__c excpt;
                                                Try{
                                                    if ( fld != null ){
                                                        
                                                        strresult=checkInputString(fld, fldLength);
                                                        
                                                        if (strresult.length()!=fld.length()) {
                                                            chRes.setokResult(strresult);
                                                            chRes.setisError(true);
                                                            errString=errString+' //Error Length '+ fldname +': ' + fld;
                                                            chRes.seterrResult(errString);
                                                            
                                                            excpt = createException(
                                                                className, 
                                                                'Field Message Length Compare', 
                                                                chRes.geterrResult(),
                                                                fnName,
                                                                fldname,
                                                                UserInfo.getUserId()
                                                                
                                                            );
                                                            excLst.add(excpt);              
                                                        }
                                                        else {
                                                            chRes.setokResult(strresult);
                                                        }
                                                    }
                                                    else{             
                                                        strresult='';
                                                        
                                                        chRes.setokResult(strresult);            
                                                    } 
                                                }catch(Exception e){	}
                                                return chRes;
                                            } 
    
    /****************************************************************
* @author:  Andrejs Veliks
* @date:    2017-10-20   
* @return   result
* @description: This method save all eception's objects in SF  
Exception__c custom object. In case of error(s)
error message save in System.debug()                    
*****************************************************************/
    public static boolean saveExceptions(){
        boolean result = true;
        Try{
        if (excLst.size() > 0) {
            
            Database.SaveResult[] srList = Database.insert(excLst, false);
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    result = false;              
                    for(Database.Error err : sr.getErrors()) {                  
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());                            
                    }
                } 
            } 
        }        
        }catch(Exception e){	}
        return result;
    }
    
    /****************************************************************
* @author:  Linda Pavare
* @date:    2018-01-22   
* @return   result
* @description: This method generates the xml response body for Opportunity Outbound class testing purposes                    
*****************************************************************/    
    public static String outboundOppXMLresposeBody(){
        
        String body = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ser-root:OpportunityUpdateResponse xmlns:ser-root="http://webservice.oasis.ericsson.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><tns:OpportunityUpdateResult xmlns:tns="http://webservice.oasis.ericsson.com/">true</tns:OpportunityUpdateResult></ser-root:OpportunityUpdateResponse></soapenv:Body></soapenv:Envelope>';
        return body;
    }
    
    /*****************************************************************
* @author: Linda Pavare
* @date: 2018-02-06
* @return isoCodeToConvRate
* @description: This method creates the mapping IsoCode : ConversionRate fromCurrencyType object
******************************************************************/
    public static Map<String,Double> getIsoCodeAndConvRateMap(){
        //NS
        //List<CurrencyType> currType = [SELECT ConversionRate, IsoCode from CurrencyType];
        Map<String,Double> isoCodeToConvRate = new Map<String,Double>();
        Try{
        for(CurrencyType ct: [SELECT ConversionRate, IsoCode from CurrencyType]){
            isoCodeToConvRate.put(ct.IsoCode,ct.ConversionRate);
            
        }
            }catch(Exception e){	}
        return isoCodeToConvRate;
    } 
    
    /*****************************************************************
* @author: Linda Pavare
* @date: 2018-02-13
* @param: String str
* @return: String tmp
* @description: This method escapes the special characters(<, >, &, ', ") in the XML file
******************************************************************/
    public static String escapeSpecialXMLChararcters(String str){
        String tmp = str;
        Try{
        if(tmp.contains('&')||tmp.contains('>')||tmp.contains('<')||tmp.contains('\'')||tmp.contains('\"')){
            
            if(tmp.contains('&')){
                tmp = tmp.replace('&','&amp;');                           
            }
            if(tmp.contains('>')){
                tmp = tmp.replace('>','&gt;');
            }
            if(tmp.contains('<')){
                tmp = tmp.replace('<','&lt;');                           
            }
            if(tmp.contains('\'')){
                tmp = tmp.replace('\'','&apos;');
            }
            if(tmp.contains('\"')){
                tmp = tmp.replace('\"','&quot;');
            }
            
            
        }
            }catch(Exception e){	}
        return tmp;
    }
    
    /*****************************************************************
* @author: Linda Pavare
* @date: 2018-02-22
* @param: parentContractIds
* @return: returnContractsList
* @description: This method finds all Contracts by Contract_ID__c field which are in the @param List
******************************************************************/
    public static List<Contract> getContractInfoByExternalID(List<String>parentContractIds)
    {
        List<Contract> returnContractsList = [SELECT Id, Contract_ID__c FROM Contract WHERE Contract_ID__c in: parentContractIds];
        return returnContractsList;
    }
    
}