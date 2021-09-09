/**
* @File Name          : OC_ContentControllerSubContentFormatter
* @Description        : This will provide necessary formatting for OmniChannel Community Data
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 14th May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-14              Rohit Gaba               Initial Version
**/
public class OC_ContentControllerSubContentFormatter{
    
    //Document Size data formatter from Integer to Bytes, KB, MB, GB
    public static String BytesToSize(Integer sizeValue){       
        if(sizeValue < 1024){
            //BYTES
            return string.valueOf(sizeValue) + ' Bytes';
        }
        else if(sizeValue >= 1024 && sizeValue < (1024*1024)){
            //KB
            Decimal kb = Decimal.valueOf(sizeValue);
            kb = kb.divide(1024,2);
            return string.valueOf(kb) + ' KB';
        }
        else if(sizeValue >= (1024*1024) && sizeValue < (1024*1024*1024)){
            //MB
            Decimal mb = Decimal.valueOf(sizeValue);
            mb = mb.divide((1024*1024),2);
            return string.valueOf(mb) + ' MB';
        }
        else{
            //GB
            Decimal gb = Decimal.valueOf(sizeValue);
            gb = gb.divide((1024*1024*1024),2);
            return string.valueOf(gb) + ' GB';
        }
    }
}