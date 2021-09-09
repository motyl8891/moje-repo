/**
 * @File Name          : OC_AN_MC_CreateEmail_JSONTest
 * @Description        : Test class for OC_AN_MC_CreateEmail_JSON.
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
public class OC_AN_MC_CreateEmail_JSONTest {
        
    public static final String JSON_TO_PARSE_REQUEST = '{"id": 3158,"customerKey": "808c7c8f-9554-4021-82c7-ecb4f6b3f421","objectID": "9c03a728-291a-4a59-90ca-d68ea5b409f1","contentType": "application/vnd.etmc.email.Message; kind=paste","assetType": {"id": 208,"name": "htmlemail","displayName": "HTML Email"},"name": "Test73_a0g1l000002qcDEAAY","owner": {"id": 710162564,"email": "","name": "Test API app user","userId": "710162564"},"createdDate": "2021-05-17T06:18:05.47-06:00","createdBy": {"id": 710162564,"email": "","name": "Test API app user","userId": "710162564"},"modifiedDate": "2021-05-17T06:18:05.47-06:00","modifiedBy": {"id": 710162564,"email": "","name": "Test API app user","userId": "710162564"},"enterpriseId": 510003459,"memberId": 510003459,"status": {"id": 1,"name": "Draft"},"thumbnail": {"thumbnailUrl": "thumbnail"},"category": {"id": 691,"name": "Content Builder","parentId": 0},"views": {"text": {"thumbnail": {},"modelVersion": 2},"subjectline": {"thumbnail": {},"content": "Test73","modelVersion": 2},"preheader": {"thumbnail": {},"modelVersion": 2},"html": {"thumbnail": {},"content": "content","modelVersion": 2}},"availableViews": ["text","subjectline","preheader","html"],"channels": {"web": false,"email": true},"data": {"email": {"options": {"characterEncoding": "us-ascii"},"legacy": {"legacyId": 1233,"legacyKey": "808c7c8f-9554-4021-82c7-ecb4f6b3f421","legacyType": "email","legacyCategoryId": 584}}},"legacyData": {"legacyId": 1233,"legacyKey": "808c7c8f-9554-4021-82c7-ecb4f6b3f421","legacyType": "email","legacyCategoryId": 584},"modelVersion": 2}';

    static testMethod void testParsing() {
      	OC_AN_MC_CreateEmail_JSON.parse(JSON_TO_PARSE_REQUEST);
        System.assertNotEquals(null, 'Unable to parse the JSON');
    }
}