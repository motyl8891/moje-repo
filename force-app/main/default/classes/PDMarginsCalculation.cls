public class PDMarginsCalculation{

    public static Proposal__c calculateProposalPdMargins(Proposal__c prop, List<Product__c> prodList){
        try{
            
            // Instantiate Commodity Variables           
            
            Decimal hwSumUmar = 0;
            Decimal swSumUmar = 0;
            Decimal svcsSumUmar = 0;

            Decimal hwSumComVal = 0;
            Decimal swComVal = 0;
            Decimal svcsComVal = 0;
            
            // For each Product Area in List, check against map and assign to Commodity Margin
            for(Product__c prod: prodList){
                
                // Check that Commodity is populated
                if(prod.Commodity__c != null)
                {
                     // Compare to either HW, SW, or CS
                    if(prod.Commodity__c.equals(GlobalConstants.HARDWARE_PRODUCT)){
                        hwSumUmar+=prod.UMAR__c;
                        hwSumComVal+=prod.Commodity_Value__c;
                    }else if(prod.Commodity__c.equals(GlobalConstants.SOFTWARE_PRODUCT)){
                        swSumUmar+=prod.UMAR__c;
                        swComVal+=prod.Commodity_Value__c;
                    }else if(prod.Commodity__c.equals(GlobalConstants.SERVICES_PRODUCT)){
                        svcsSumUmar+=prod.UMAR__c;
                        svcsComVal+=prod.Commodity_Value__c;
                    } 
                } 
            }

            Decimal hwMargin = 0;
            Decimal swMargin = 0;
            Decimal svcsMargin = 0;
            if(hwSumComVal>0){
                hwMargin = hwSumUmar/hwSumComVal;
            }
            if(swComVal>0){
                swMargin = swSumUmar/swComVal;
            }
            if(svcsSumUmar>0){
                svcsMargin = svcsSumUmar/svcsComVal;
            }

            prop.PD_Hardware_Margin__c = hwMargin;
            prop.PD_Software_Margin__c = swMargin;
            prop.PD_Services_Margin__c = svcsMargin;

            return prop;
        }catch(NullPointerException npe){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error('PDMarginsCalculation', 'calculateProposalPdMargins', 'PDMarginsCalculation', true, npe)));
            System.debug(LoggingLevel.ERROR, 'PDMarginsCalculation Get error = ' + npe.getMessage());
            return null;
        }
    }

}