public with sharing class CsvUploaderController {
    @AuraEnabled
    public static List<Account> saveFile(String base64Data,String fileName) {
		system.debug('line no 4');
        String data = (String)JSON.deserializeUntyped(base64Data);
        List<Document> doccheck=[Select id,name from document where Name=:fileName limit 1];
        Document doc=new Document();
        doc.FolderId=UserInfo.getUserId();
        doc.Body=Blob.valueOf(data);
        if(doccheck.size()>0){
            fileName=fileName+'_'+System.today();
            doc.Name=fileName;
        }else{
           doc.Name=fileName; 
        }
        insert doc;
        system.debug('doc---->'+doc);
        ImportCSVJob shn = new ImportCSVJob(fileName); 
        database.executeBatch(shn); 
        return Null;
    }

}