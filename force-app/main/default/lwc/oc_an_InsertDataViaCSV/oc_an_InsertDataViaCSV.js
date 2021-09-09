import { LightningElement, track, api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// importing Apex Methods
import createUsrPrefRecord from '@salesforce/apex/OC_AN_Insert_UserPrefrences.createUsrPrefRecord';
import get_MetaDataOfAN from '@salesforce/apex/OC_AN_Insert_UserPrefrences.get_MetaDataOfAN';
import get_RecordTypeIds from '@salesforce/apex/OC_AN_Insert_UserPrefrences.get_RecordTypeIds';
import getUserIdsRecs from '@salesforce/apex/OC_AN_Insert_UserPrefrences.getUserIdsRecs';
import getcontactIdsRecs from '@salesforce/apex/OC_AN_Insert_UserPrefrences.getcontactIdsRecs';
import sendEmailToController from '@salesforce/apex/OC_AN_Insert_UserPrefrences.sendEmailToController';
// importing Custom Label
import title from '@salesforce/label/c.OC_AN_Success_Failure_Message';
import message from '@salesforce/label/c.OC_AN_File_Uploaded_Successfully';
import fileSizeErrorMessage from '@salesforce/label/c.OC_AN_File_Size_long';
import userPrefCSVHeaders from '@salesforce/label/c.OC_AN_UserPref_CSV_Headers';
import OC_AN_User_Preference_Uploader from '@salesforce/label/c.OC_AN_User_Preference_Uploader';
import OC_AN_Choose_File from '@salesforce/label/c.OC_AN_Choose_File';
import OC_AN_Insert_Data from '@salesforce/label/c.OC_AN_Insert_Data';
import OC_AN_Download_Sample_CSV from '@salesforce/label/c.OC_AN_Download_Sample_CSV';
import downloadUrl from '@salesforce/label/c.OC_AN_UserPrefrencesSampleFile';

export default class oc_an_InsertDataViaCSvCls extends NavigationMixin(LightningElement) {
    label = {
        OC_AN_Choose_File,
        OC_AN_User_Preference_Uploader,
        OC_AN_Insert_Data,
        OC_AN_Download_Sample_CSV

    };
    @track data;
    @track cleanData;
    @track duplicateData=[];
    buttondisabled=true;
    @track usernameData=[];
     usernameMap;
    @track contactData=[];
     contactDataMap;
    @track prdData=[];
     recordTypeIdsMap;
     metadata_AN;
     error;
     recordsStatusString;
     showLoadingSpinner = false;
     chunks = 2000;
     count=0;
     counter=0;
    @track prdResult = [];

    connectedCallback(){
        this.showLoadingSpinner = true;
        get_MetaDataOfAN()
        .then(result => {
            this.metadata_AN = JSON.parse(JSON.stringify(result));

             this.error = undefined;
             this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.metadata_AN = undefined;
            this.showLoadingSpinner = false;
        });
        get_RecordTypeIds()
        .then(result => {
            this.recordTypeIdsMap = JSON.parse(JSON.stringify(result));
            this.error = undefined;
             this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.recordTypeIdsMap = undefined;
            this.showLoadingSpinner = false;
        });

    }
    MAX_FILE_SIZE = 2000000; //Max file size 2.0 MB
    filesUploaded = [];
    filename;
    importcsv(event){
        this.showLoadingSpinner = true;
        this.counter=0;
        this.recordsStatusString=null;
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.filename = event.target.files[0].name;
            if (this.filesUploaded.size > this.MAX_FILE_SIZE) {
                this.filename = fileSizeErrorMessage;
                this.showLoadingSpinner = false;
            }else{
                this.readFiles();
                this.buttondisabled=false;
            }
        }
    }
    readFiles() {
        this.showLoadingSpinner = true;
        [...this.template
            .querySelector('lightning-input')
            .files].forEach(async file => {
                try {
                    const result = await this.load(file);
                    this.data=JSON.parse(this.csvJSON(result));
                    var actualdata=this.data;
                    if(actualdata.length>0){
                        this.cleanData=actualdata;
                        var usernameData=this.usernameData;
                        var contactData=this.contactData;
                        this.count=Math.ceil((this.cleanData.length)/(this.chunks));
                        if(usernameData.length>0){
                            this.getUserIds(usernameData);
                        }
                        if(contactData.length>0){
                            this.getcontactIds(contactData);
                        }
                  
                }

               } catch(e) {
                    // handle file load exception
                    console.log('exception....'+e);
                    this.showLoadingSpinner = false;
                }
            });
    }
    async load(file) {
        return new Promise((resolve, reject) => {
        this.showLoadingSpinner = true;
            const reader = new FileReader();
            // Read file into memory as UTF-8
            //reader.readAsText(file);
            reader.onload = function() {
                resolve(reader.result);
            };
            reader.onerror = function() {
                reject(reader.error);
            };
            reader.readAsText(file);
        });
    }

    //process CSV input to JSON

    csvJSON(csv){
		var lines=csv.split(/\r\n|\n/);

    var result = [];

    var headers=lines[0].split(",");
    for(var i=1;i<lines.length-1;i++){

        var obj = {};
        var currentline=lines[i].split(",");
        var prdObj = {};
            for(var j=0;j<headers.length;j++){

                var tempval=headers[j];
                let labelName=this.metadata_AN[tempval];
                if(currentline[j]!=''&& currentline[j]!=undefined){
                    if(labelName=='OC_AN_User__c'){
                        this.usernameData.push(currentline[j]);
                    }
                    else if(labelName=='OC_AN_Contact__c'){
                        this.contactData.push(currentline[j]);
                    }
                    obj[labelName] = currentline[j];
                }
                obj['sobjectType'] = 'OC_AN_User_Preferences__c';
            }
        result.push(obj);

    }
    this.showLoadingSpinner = false;

    //return result; //JavaScript object
    return JSON.stringify(result); //JSON
    }
    getUserIds(usrNames) {
        getUserIdsRecs({usrNames: usrNames})
        .then(result => {
            this.usernameMap = JSON.parse(JSON.stringify(result));

            this.showLoadingSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.showLoadingSpinner = false;
        });
    }
    getcontactIds(contactData) {

        getcontactIdsRecs({contactData: contactData})
        .then(result => {
            this.contactDataMap = JSON.parse(JSON.stringify(result));
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.error = error;
            this.showLoadingSpinner = false;
        });
    }
   
    processRecords() {
        this.showLoadingSpinner = true;
        var dataToProcess=this.cleanData;
        var actualdata=this.processDataToInsert(dataToProcess);

        if(actualdata && actualdata.length>0){

             var chunks = this.chunks;
            if(actualdata.length>chunks){

                this.splitIntoChunk(actualdata,chunks)
            }else{

                this.createUsrPrefRecordFn(actualdata);
            }

        }else{
            this.showLoadingSpinner = false;
        }
    }
   processDataToInsert(finalData) {
       var result = [];
       this.showLoadingSpinner = true;
        var listLength = finalData.length;
     try{
        for (var i=0; i < listLength; i++) {
            var username=finalData[i].OC_AN_User__c;
            var contactEmail=finalData[i].OC_AN_Contact__c;
            if(finalData[i].RecordTypeId){
                finalData[i].RecordTypeId= this.recordTypeIdsMap[finalData[i].RecordTypeId];
            }

            if(finalData[i].OC_AN_User__c!=undefined && finalData[i].OC_AN_User__c!=''){
                var userId=this.usernameMap[username];
                if(userId)
                    finalData[i].OC_AN_User__c= userId;
                finalData[i].OC_AN_Contact__c= null;

            }else{
                var contactId=this.contactDataMap[contactEmail];
                if(contactId){
                    finalData[i].OC_AN_Contact__c= contactId;
                }
            }
            
        }
     return finalData;
    } catch(e) {
        // handle file load exception
        console.log('exception....'+e);
        this.showLoadingSpinner = false;
    }
    }
    splitIntoChunk(arr, chunk) {

        var i,j,temparray;
        for (i=0,j=arr.length; i<j; i+=chunk) {
            temparray = arr.slice(i,i+chunk);
        // do whatever
             this.createUsrPrefRecordFn(temparray);
        }


    }
    createUsrPrefRecordFn(actualdata){

        createUsrPrefRecord({newRecords: actualdata})
                    .then(result => {
                        this.counter=this.counter+1;

                        var recordsStatusString=this.recordsStatusString;

                        if(recordsStatusString!=null && recordsStatusString!='' && recordsStatusString!=undefined){
                            this.recordsStatusString=recordsStatusString+result;
                        }else{
                            this.recordsStatusString=result;
                        }
                        if(this.counter==this.count){
                            var header = userPrefCSVHeaders+' \n';
                            this.recordsStatusString=header+this.recordsStatusString;
                            this.sendEmailAfterEvent();
                            const event = new ShowToastEvent({
                                "title": message,
                                "message": title,
                                "variant" :"success"
                            });
                            this.dispatchEvent(event);
                            this.filename = null;
                            this.data=null;
                            this.cleanData=null;
                            this.buttondisabled=true;
                            this.showLoadingSpinner = false;
                        }
                    })
                    .catch(error => {
                        console.log(error);
                        this.error = error;
                        this.filename = null;
                        this.data=null;
                        this.cleanData=null;
                        this.showLoadingSpinner = false;
                    });

    }
    sendEmailAfterEvent(){
        sendEmailToController({recordsStatusString: this.recordsStatusString})
        .then( () => {
            //If response is ok
        }).catch( error => {
            //If there is an error on response
        })

    }
    retrieveCSVSample(){

        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url":downloadUrl
            }
        });
    }
}