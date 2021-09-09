/**
* @File Name          : OmniChannelThemeContentControllerSub
* @Description        : This class will act as a delegator to assign requests coming from class OmniChannelThemeContentController to specific functionality classes
*						
*						*****   OmniChannelThemeContentController.cls   <==>   OmniChannelThemeContentControllerSub.cls   *****
*
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 08th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-04-08              Rohit Gaba               Initial Version
* 2.0        2020-08-17                 IBM                   R20_09 U-2013 Limiting Forum Results after Fourth Quadrant on MyWorkspace to show Recent Tickets
* 3.0        2020-08-20                 IBM                   R20_09 U-2008,2009,2010 Call methods to update task with customer response
**/
public with sharing class OmniChannelThemeContentControllerSub {
    
    public static OmniChannelThemeRequestReponseWrappers.OmniChannelThemeResponse processOmniChannelThemeRequest(OmniChannelThemeRequestReponseWrappers.OmniChannelThemeRequest request){
        
        switch on request.requestType.toLowerCase() {
            when 'search' {
                return OC_ContentControllerSubGST.processOmniChannelThemeRequestSearch(request);
            }
            when 'profile_menu'{
                return OC_ContentControllerSubProfile.processOmniChannelThemeRequest(request);
            }
            //below directs to Document Hub method
            when 'list_documents'{
                return OC_ContentControllerSubDocuments.processOmniChannelThemeRequestDocumentHub(request);
            }
            when 'recent_documents'{
                return OC_ContentControllerSubDocuments.processOmniChannelThemeRequestRecentDocuments(request);
            }
            when 'recent_forums'{
                return OC_ContentControllerSubForum.processOmniChannelThemeRequestRecentPosts(request);
            }
            //2.0 2020-08-17 IBM
            //R20_09 U-2013 Fourth Quadrant on MyWorkspace to show Recent Tickets
            when 'recent_tickets'{
                return OC_ContentControllerTicketHandling.processOmniChannelThemeRequestRecentTickets(request);
            }
            when 'landing_modules'{
                return OC_ContentControllerSubLandingModules.processOmniChannelThemeRequestRetrieveLandingModules(request);
            }
            when 'navigations'{
                return OC_ContentControllerSubNavigation.processOmniChannelThemeRequestRetrieveNavigations(request);
            }
            //added for TH ticket_handling
            when 'list_tickets','filter_tickets'{
                //system.debug('Inside Ticket Handling ======>');
                return OC_ContentControllerTicketHandling.processOmniChannelThemeRequestTicketHandling(request);
            }
            when 'ticket_detail'{
                return OC_ContentControllerTicketHandling.processOmniChannelThemeRequestTicketDetail(request);
            }
          /*  when 'picklist_values'{
                return OC_ContentControllerTicketHandling.getPicklistValues(request);
            }*/
            when 'other'{
                switch on request.requestSubType.toLowerCase() {
                   /* when 'add_case_comment'{
                        return OC_ContentControllerTicketHandling.processOmniChannelThemeRequestAddTicketComment(request);
                    }*/
                    //call method to update task with customer response
                    when 'update_task_status'{
                        return OC_ContentControllerTicketHandling.processOmniChannelThemeRequestUpdateTaskStatus(request);
                    }
                    when 'add_rfi_response'{
                        return OC_ContentControllerTicketHandling.processOmniChannelThemeRequestUpdateRFI(request);
                    }
                    //Till here
                    when 'breadcrumbs'{
                        return  OC_ContentControllerSubBreadcrumbs.processOmniChannelThemeRequestRetrieveBreadcrumbs(request);
                    }
                    when 'click_search'{
                        return OC_ContentControllerSubGST.processOmniChannelThemeRequestSearchClick(request);
                    }
                    when else {
                        //System.debug('default');
                        throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);
                    }
                }
                
            }
            when else {
                //System.debug('default');
                throw new AuraHandledException(System.Label.OC_Generic_Exception_Message);
            }
            
        }
    }
}