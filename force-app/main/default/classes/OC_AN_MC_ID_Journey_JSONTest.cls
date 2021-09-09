/**
 * @File Name          : OC_AN_MC_ID_Journey_JSONTest
 * @Description        : Test class for OC_AN_MC_ID_Journey_JSON.
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/

@IsTest
public class OC_AN_MC_ID_Journey_JSONTest {
        
    public static final String JSON_TO_PARSE_REQUEST = '{'+
    '    "key": "Internal_{{bulletinId}}",'+
    '    "name": "Internal_{{bulletinId}}",'+
    '    "description": "Generated from Service cloud with bulletin  id: {{bulletinId}}",'+
    '    "version": 1,'+
    '    "workflowApiVersion": 1.0,'+
    '    "activities": ['+
    '        {'+
    '            "key": "EMAILV2-1",'+
    '            "name": "SampleEmailUnsubscribelinkcheck",'+
    '            "description": "",'+
    '            "type": "EMAILV2",'+
    '            "outcomes": ['+
    '                {'+
    '                    "key": "409a390b-40c6-4942-8039-3862e50dc124",'+
    '                    "next": "WAITBYDURATION-1",'+
    '                    "arguments": {},'+
    '                    "metaData": {'+
    '                        "invalid": false'+
    '                    }'+
    '                }'+
    '            ],'+
    '            "arguments": {},'+
    '            "configurationArguments": {'+
    '                "isModified": true,'+
    '                "triggeredSend": {'+
    '                    "autoAddSubscribers": true,'+
    '                    "autoUpdateSubscribers": true,'+
    '                    "bccEmail": "",'+
    '                    "ccEmail": "",'+
    '                    "created": {'+
    '                        "name": "",'+
    '                        "date": ""'+
    '                    },'+
    '                    "domainExclusions": [],'+
    '                    "dynamicEmailSubject": "SampleUnsubscribeCheck",'+
    '                    "emailId": 100,'+
    '                    "emailSubject": "SampleUnsubscribeCheck",'+
    '                    "exclusionFilter": "",'+
    '                    "isSalesforceTracking": true,'+
    '                    "isMultipart": true,'+
    '                    "isSendLogging": true,'+
    '                    "isStoppedOnJobError": false,'+
    '                    "modified": {'+
    '                        "name": "",'+
    '                        "date": ""'+
    '                    },'+
    '                    "preHeader": "",'+
    '                    "priority": 4,'+
    '                    "sendClassificationId": "ef074fed-3564-eb11-b82f-f40343c954f0",'+
    '                    "deliveryProfileId": "ee074fed-3564-eb11-b82f-f40343c954f0",'+
    '                    "senderProfileId": "61a06939-8176-eb11-b82c-f40343c996b0",'+
    '                    "isTrackingClicks": true'+
    '                },'+
    '                "applicationExtensionKey": "jb-email-activity"'+
    '            },'+
    '            "metaData": {'+
    '                "isConfigured": true,'+
    '                "sections": {}'+
    '            }            '+
    '        },'+
    '        {'+
    '            "id": "8415ae50-7670-4842-8302-aa16f8277ff1",'+
    '            "key": "WAITBYDURATION-1",'+
    '            "name": "1 minute",'+
    '            "description": "",'+
    '            "type": "WAIT",'+
    '            "outcomes": ['+
    '                {'+
    '                    "key": "d2117c97-5df3-4967-b59a-91ede939be0b",'+
    '                    "next": "UPDATECONTACTDATAV2-1",'+
    '                    "arguments": {},'+
    '                    "metaData": {'+
    '                        "invalid": false'+
    '                    }'+
    '                }'+
    '            ],'+
    '            "arguments": {},'+
    '            "configurationArguments": {'+
    '                "waitDuration": 1,'+
    '                "waitUnit": "MINUTES",'+
    '                "timeZone": "India Standard Time",'+
    '                "specifiedTime": "00:00"'+
    '            },'+
    '            "metaData": {'+
    '                "isConfigured": true,'+
    '                "isExtended": false,'+
    '                "waitType": "duration",'+
    '                "guidanceCardKey": null,'+
    '                "uiType": "WAITBYDURATION"'+
    '            }            '+
    '        },'+
    '        {'+
    '            "key": "UPDATECONTACTDATAV2-1",'+
    '            "name": "Update Contact - InternalUser_123",'+
    '            "description": "",'+
    '            "type": "UPDATECONTACTDATA",'+
    '            "outcomes": ['+
    '                {'+
    '                    "key": "6dbc73a0-f84f-4ec8-aaa6-f93a8d3fd779",'+
    '                    "next": "WAITBYDURATION-2",'+
    '                    "arguments": {},'+
    '                    "metaData": {'+
    '                        "invalid": false'+
    '                    }'+
    '                }'+
    '            ],'+
    '            "arguments": {'+
    '                "activityData": {'+
    '                    "updateContactFields": ['+
    '                        {'+
    '                            "dataExtensionId": "a16a05f0-10ac-eb11-b834-f40343c954f8",'+
    '                            "field": "7790647f-6a72-4fc4-9ad0-bc1b838dfccf",'+
    '                            "value": "{{DateTime.Now}}"'+
    '                        }'+
    '                    ]'+
    '                }'+
    '            },'+
    '            "configurationArguments": {},'+
    '            "metaData": {'+
    '                "isConfigured": true'+
    '            },'+
    '            "schema": {'+
    '                "arguments": {'+
    '                    "activityData": {'+
    '                        "dataType": "Text",'+
    '                        "isNullable": false,'+
    '                        "direction": "In",'+
    '                        "readOnly": false,'+
    '                        "access": "Hidden"'+
    '                    },'+
    '                    "contactKey": {'+
    '                        "dataType": "Text",'+
    '                        "isNullable": false,'+
    '                        "direction": "In",'+
    '                        "readOnly": false,'+
    '                        "access": "Hidden"'+
    '                    }'+
    '                }'+
    '            },'+
    '            "arguments": {'+
    '                "execute": {'+
    '                   "inArguments":['+
    '                        {'+
    '                            "firstName": "{{Contact.Attribute.SN_New_test_check.FirstName}}"'+
    '                        }'+
    '                    ],'+
    '                  "outArguments": [],'+
    '                  "url": "https://{HostName}.herokuapp.com/journeybuilder/execute",'+
    '                   "verb": "POST",'+
    '                    "body": "",'+
    '                    "header": "",'+
    '                    "format": "json",'+
    '                    "useJwt": true,'+
    '                    "timeout": 10000'+
    '                }'+
    '            }'+
    '        },'+
    '        {'+
    '            "id": "d7476ced-3e84-49fa-9671-fb7ddd10ce6e",'+
    '            "key": "WAITBYDURATION-2",'+
    '            "name": "1 minute",'+
    '            "description": "",'+
    '            "type": "WAIT",'+
    '            "outcomes": ['+
    '                {'+
    '                    "key": "11d053ef-7bb6-4c26-965a-e245fef4842a",'+
    '                    "arguments": {},'+
    '                    "metaData": {'+
    '                        "invalid": false'+
    '                    }'+
    '                }'+
    '            ],'+
    '            "arguments": {},'+
    '            "configurationArguments": {'+
    '                "waitDuration": 1,'+
    '                "waitUnit": "MINUTES",'+
    '                "timeZone": "India Standard Time",'+
    '                "specifiedTime": "00:00"'+
    '            },'+
    '            "metaData": {'+
    '                "isConfigured": true,'+
    '                "isExtended": false,'+
    '                "waitType": "duration",'+
    '                "guidanceCardKey": null,'+
    '                "uiType": "WAITBYDURATION"'+
    '            }            '+
    '        }'+
    '    ],'+
    '    "triggers": ['+
    '        {'+
    '            "key": "TRIGGER",'+
    '            "name": "TRIGGER",'+
    '            "description": "",'+
    '            "type": "EmailAudience",'+
    '            "outcomes": [],'+
    '            "arguments": {},'+
    '            "configurationArguments": {},'+
    '            "metaData": {'+
    '                "sourceInteractionId": "00000000-0000-0000-0000-000000000000",'+
    '                "eventDefinitionId": "{{dataExtensionId}}",'+
    '                "eventDefinitionKey": "DEAudience-8a65a80e-d226-0c62-388f-8dc367448d07",'+
    '                "chainType": "None",'+
    '                "configurationRequired": false,'+
    '                "iconUrl": "/images/icon-data-extension.svg",'+
    '                "title": "Data Extension",'+
    '                "entrySourceGroupConfigUrl": "jb:///data/entry/audience/entrysourcegroupconfig.json"'+
    '            }'+
    '        }'+
    '    ],'+
    '    "goals": [],'+
    '    "exits": [],'+
    '    "stats": {'+
    '        "currentPopulation": 0,'+
    '        "cumulativePopulation": 0,'+
    '        "metGoal": 0,'+
    '        "metExitCriteria": 0,'+
    '        "goalPerformance": 0.0'+
    '    },'+
    '    "defaults": {'+
    '        "email": ['+
    '            "khj"'+
    '        ],'+
    '        "properties": {'+
    '            "analyticsTracking": {'+
    '                "enabled": false,'+
    '                "analyticsType": "google",'+
    '                "urlDomainsToTrack": []'+
    '            }'+
    '        }'+
    '    },'+
    '    "entryMode": "MultipleEntries",'+
    '    "definitionType": "Multistep",'+
    '    "channel": "",'+
    '    "metaData": {},'+
    '    "executionMode": "Production",'+
    '    "categoryId": 687,'+
    '    "status": "Draft",'+
    '    "definitionId": "e1333786-9641-490f-9df4-4bc024db19ed",'+
    '    "scheduledStatus": "Draft"'+
    '}';

    static testMethod void testParsing() {
        JSONParser parser = System.JSON.createParser(JSON_TO_PARSE_REQUEST);
        OC_AN_MC_ID_Journey_JSON json = new OC_AN_MC_ID_Journey_JSON(parser);
        System.assertNotEquals(null, json, 'Unable to parse the JSON');
    }

    static testMethod void testCreation() {
        Map<String,String> arguments = new Map<String,String>();
        arguments.put('','');
        String result = OC_AN_MC_ID_Journey_Util.getInternalJourneyRestBody('bulletinId', 'bulletinName', 1, 'dataExtensionId', arguments, 'FlowType' );
        System.assertNotEquals(null, result, 'The resulting JSON data should not be null');
        JSONParser parser = System.JSON.createParser(result);
        OC_AN_MC_ID_Journey_JSON json = new OC_AN_MC_ID_Journey_JSON(parser);
        System.assertNotEquals(null, json, 'Unable to parse the JSON');        
    }

}