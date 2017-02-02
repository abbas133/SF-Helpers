public class GenericSObjectUpsert {

    //
    // Use to upsert list of generic sObjects.
    //
    public static Database.UpsertResult[] dynamicUpsert(
        List<SObject> recordsForDml, Schema.SObjectType sObjectType, Schema.SObjectField sobjectFieldType
    ) {
        Database.UpsertResult[] upsertResults = new Database.UpsertResult[]{};

        String listType = 'List<' + sObjectType + '>';
        List<SObject> castRecords = (List<SObject>) Type.forName(listType).newInstance();
        castRecords.addAll(recordsForDml);

        if(null != sobjectFieldType) {
            upsertResults = Database.upsert(castRecords, sobjectFieldType);
        } else {
            upsertResults = Database.upsert(castRecords);
        }

        return upsertResults;
    }

}
