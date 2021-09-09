/**
* @File Name          : OmniChannelThemeAccessController
* @Description        : This class will be used to control the access of request coming to class OmniChannelThemeContentController
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 08th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-04-08              Rohit Gaba               Initial Version
* 2.0        2020-08-17                 IBM                   R20_09 U-2013 Limiting Forum Results after Fourth Quadrant on MyWorkspace to show Recent Tickets
* 3.0        2020-08-20                 IBM                   R20_09 U-2008,2009,2010 Added access permission to allow task update
* 4.0        2020-11-15					IBM     		      R2012, U-1706 Controlling forum results based on the Account.
**/
public with sharing class OmniChannelThemeAccessController {
    
    public static Boolean OCReuqestAccessCheck(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        
        switch on request.requestType.toLowerCase() {
            when 'search' {
                return true; 
            }
            when 'profile_menu'{
                return true;
            }
            when 'list_documents'{
                if(UserInfo.getUserType() == 'Standard' || UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
                    return true;
                }else{
                    return false;
                }
            }
            when 'recent_documents'{
                //OC_AccessControllerSub
                /////////////////////////////Access mechanism to be added whilst document hub functionality lift-up
                return true;
            }
            when 'recent_forums'{
                //4.0 2020-11-15 IBM R2012, U-1706 Controlling forum results based on the Account.
                if(!FeatureManagement.checkPermission('OC_UAM_Forum_Accessibility') && UserInfo.getUserType() != 'Standard'){
                    return false;
                }
                else{
                    return true;
                }
            }
            //2.0 2020-08-17 IBM
            //R20_09 U-2013 Fourth Quadrant on MyWorkspace to show Recent Tickets
            when 'recent_tickets'{
                return true;
            }
            when 'landing_modules'{
                return true;
            }
            when 'navigations'{
                return true;
            }
            //added for TH
            when 'list_tickets','filter_tickets'{
                //system.debug('Ticket Handling Access check ===>');
                return true;
            }
            when 'ticket_detail'{
                return true;
            }
            when 'other'{
                switch on request.requestSubType.toLowerCase() {
                    when 'add_case_comment'{
                        return true;
                    }
                    //Allow task update
                    when 'add_rfi_response'{
                        return true;
                    }
                    when 'update_task_status'{
                        return true;
                    }
                    //Till here
                    when 'breadcrumbs'{
                        return true;
                    }
                    when 'click_search'{
                        return true;
                    }
                    when else {
                        return false;
                    }
                }
            }
            when else {
                return false;
            }
        }
    }
}