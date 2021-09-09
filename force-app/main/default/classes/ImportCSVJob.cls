global class ImportCSVJob implements Database.Batchable<SObject>, Schedulable {

    /*
     * Delimiter used for splitting a given filename's short name (without
     * the file extension)
     */
    global static final String FILENAME_PART_DELIMITER = '-';
    private String m_csvFile;
    public static final String crlf = Parser.CRLF;
    /*
     * Delimiter used for splitting a given filename's extension from the
     * simple name, specified with the expectation of using this delimiter
     * with String.split()
     */
    global static final String FILENAME_EXTENSION_DELIMITER = '\\.';
	private String strParameter='';
    /*
     * Default constructor
     */
    global ImportCSVJob(String strParam) {
        strParameter = strParam;
        System.debug('line 20: '+strParameter);
    }
   /*
     * @return the String query that will be executed to retrieve
     *         Document records that need to be processed
     */
    global static String getDocumentQuery() {
        return 'SELECT Id, Name, Body FROM Document ' +
            'WHERE Name = :strParameter';
    }

    /*
     * @param  context The batch context
     * @return the QueryLocator that will go through all of the documents
     *         that need to be processed as CSV files
     */
    global Database.QueryLocator start(Database.BatchableContext context) {
         System.debug('line 37: '+Blob.valueOf(strParameter));
       	return Database.getQueryLocator(getDocumentQuery());
    }
    /*
     * Parse the first file in the list of what are assumed to be Document
     * records.
     *
     * @param context The batch context
     * @param records The list of records to be processed in this batch
     */
    global void execute(Database.BatchableContext context, List<SObject> records) {

       System.debug('line 51: '+records);
        // Read the document's body as CSV records
        Document theDocument = (Document)records.get(0);
         System.debug('line 54: '+theDocument.Body);
        List<List<String>> csvRecords =
            CSVReader.readIETFRFC4180CSVFile(theDocument.Body);
        System.debug('csvRecords: ' + csvRecords);
        
        String objectName ='OC_AN_User_Preferences__c';

        // Import the given data into the object using the parser
        import(csvRecords, objectName);
    }

    /*
     * Execute this scheduled job as a batch job
     *
     * @param context The schedule context
     */
    global void execute(SchedulableContext context) {
        Database.executeBatch(this, 1);
    }

    /*
     * Do something cool now that the job is finished
     *
     * @param context The batch context
     */
    global void finish(Database.BatchableContext context) {

    }
	/*
     * Import CSV rows as records into a given object
     *
     * @param records a list of CSV records, each of which is expected
     *                to be a list of String values. The first record
     *                should be the list of field names.
     * @param objectName
     */
    global static void import(List<List<String>> csvRecords, String objectName) {
		//system.debug('line 91'+csvRecords[0]);
        system.debug('line 91'+csvRecords.size());// This should output foo
        //System.debug('line 92'+csvRecords[0][1]);// This should output bar
        //System.debug('line 93'+csvRecords[1][0]);// This should output Hello
        //System.debug('line 94'+csvRecords[1][1]);
        system.debug('line 94'+objectName);
        // Read the first row as field names
        
        List<String> fieldNames = csvRecords.remove(0);
        system.debug('line 95'+fieldNames);
         system.debug('line 96'+csvRecords);
        // Continue with the import
        import(csvRecords, objectName, fieldNames);
    }

    /*
     * Import CSV rows as records into a given object
     *
     * @param records a list of CSV records, each of which is expected
     *                to be a list of String values
     * @param objectType
     * @param fieldNames
     */
    global static void import(List<List<String>> csvRecords, SObjectType objectType, List<String> fieldNames) {
        System.debug('csvRecords: 109 ' + csvRecords);
        System.debug('objectType: 110 ' + objectType);
        System.debug('fieldNames: 111' + fieldNames);
        
        // Initialize the list of records to insert
        List<SObject> newRecords = new List<SObject>();

        // Read each row and parse the row as value to insert
        while (csvRecords.size() > 0) {

            // Initialize the new record
            SObject newRecord = objectType.newSObject();

            // Read the CSV values
            List<String> values = csvRecords.remove(0);

            // Read each value, matching it up to the correct field
            // based on the position of the value in the row
            if (values.size() > 0) {
                for (Integer i = 0; i < fieldNames.size(); i++) {
                    String fieldName = fieldNames.get(i);
                    String fieldValue = values.get(i);
                    newRecord.put(fieldName, fieldValue);
                }
                
                // Enqueue the record to be created
                newRecords.add(newRecord);
            }
        }

        // Insert the list of records
        insert newRecords;
    }

    /*
     * Import CSV rows as records into a given object
     *
     * @param records a list of CSV records, each of which is expected
     *                to be a list of String values
     * @param objectName
     * @param fieldNames
     */
    global static void import(List<List<String>> csvRecords, String objectName, List<String> fieldNames) {
		System.debug('csvRecords: 153 '+csvRecords);
        System.debug('csvRecords: 154 '+objectName);
        System.debug('csvRecords: 155 '+fieldNames);
        // Figure out the object type to use for intantiating new records
        SObjectType objectType =
            Schema.getGlobalDescribe().get(objectName);

        // Continue with the import
        import(csvRecords, objectType, fieldNames);
    }

}