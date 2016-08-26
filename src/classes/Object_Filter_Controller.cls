public with sharing class Object_Filter_Controller {

    public String filterType { Set; get; }
    public SelectOption[] pageSizeOptionList { Set; get; }
    public String filterLogicString { Set; get; }
    public Boolean isAdvancedFilterLogicOn { Set; get; }
    public String filterLogicError { Set; get; }
    public Boolean isFilterError { Set; get; }
    public Boolean sponsorshipCreatable { Set; get; }
    public String url = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());

    public String selectedSObject { get; set; }
    public ObjectCriteria[] objectCriteriaList { Set; get; }
    public SelectOption[] objectFieldSelectOptionList { Set; get; }

    public Map<String, Schema.Sobjecttype> globalDescribeMap;
    public Map<String, Schema.SObjectField> objectFieldsMap;
    public ObjectToShow[] objectToShowList { Set; get; }
    public Map<String, String> objectLabelToObjectNameMap;
    
    public List<String> selectedFieldList { get; set; }
    public String FILTER_CRITERIA_STANDARD = 'standard';
    public String FILTER_CRITERIA_CUSTOM   = 'custom';
    public String FILTER_CRITERIA_STDCUST  = 'both';
    
    public sObject[] queryObjectList;
    
    public integer counter=0;
    public integer list_size { get; set; }
    public integer total_size { get; set; } 


    public String baseUrl {
        get {
            baseUrl = url + '/' ;
            return baseUrl;
        }
        public set;
    }

    private String validatedFilterLogicString;
    private Map<String, String> indexCriteriaMap;

    public ApexPages.StandardSetController standardSetController;

    private final Map<Schema.Soaptype, SelectOption[]> fieldTypeWithOperatorsMap = new Map<Schema.Soaptype, SelectOption[]> {
        Schema.SOAPType.Boolean => new SelectOption[] {
            new SelectOption('', '---None---'),
            new SelectOption('=', 'equals'),
            new SelectOption('!=', 'not equal to')
        },

        Schema.SOAPType.Id => new SelectOption[] {
            new SelectOption('', '---None---'),
            new SelectOption('=', 'equals'),
            new SelectOption('!=', 'not equal to')
        },

        Schema.SOAPType.Date => new SelectOption[] {
            new SelectOption('', '---None---'),
            new SelectOption('=', 'equals'),
            new SelectOption('!=', 'not equal to'),
            new SelectOption('<', 'less than'),
            new SelectOption('>', 'greater than'),
            new SelectOption('<=', 'less or equal'),
            new SelectOption('>=', 'greater or equal')
        },

        Schema.SOAPType.DateTime => new SelectOption[] {
            new SelectOption('', '---None---'),
            new SelectOption('=', 'equals'),
            new SelectOption('!=', 'not equal to'),
            new SelectOption('<', 'less than'),
            new SelectOption('>', 'greater than'),
            new SelectOption('<=', 'less or equal'),
            new SelectOption('>=', 'greater or equal')
        },

        Schema.SOAPType.Double => new SelectOption[] {
            new SelectOption('', '---None---'),
            new SelectOption('=', 'equals'),
            new SelectOption('!=', 'not equal to'),
            new SelectOption('<', 'less than'),
            new SelectOption('>', 'greater than'),
            new SelectOption('<=', 'less or equal'),
            new SelectOption('>=', 'greater or equal')
        },

        Schema.SOAPType.Integer => new SelectOption[] {
            new SelectOption('', '---None---'),
            new SelectOption('=', 'equals'),
            new SelectOption('!=', 'not equal to'),
            new SelectOption('<', 'less than'),
            new SelectOption('>', 'greater than'),
            new SelectOption('<=', 'less or equal'),
            new SelectOption('>=', 'greater or equal')
        },

        Schema.SOAPType.String => new SelectOption[] {
            new SelectOption('', '---None---'),
            new SelectOption('=', 'equals'),
            new SelectOption('!=', 'not equal to'),
            new SelectOption('like', 'contains')
        }
    };


    public SelectOption[] operators {
        get {
            if (operators == null) {
                operators = new SelectOption[] {};
                operators.add(new SelectOption('', '---None---'));
                operators.add(new SelectOption('=', 'equals'));
                operators.add(new SelectOption('!=', 'not equal to'));
                operators.add(new SelectOption('<', 'less than'));
                operators.add(new SelectOption('>', 'greater than'));
                operators.add(new SelectOption('<=', 'less or equal'));
                operators.add(new SelectOption('>=', 'greater or equal'));
                operators.add(new SelectOption('like', 'contains'));
            }

            return operators;
        } Set;
    }


    public class ObjectCriteria {
        public String fieldName { Set; get; }
        public String operator { Set; get; }
        public sObject selectedObject { Set; get; }
        public SelectOption[] operators { Set; get; }
        public String andOrOperator { Set; get; }

        public ObjectCriteria(String fieldName, String operator, sObject selectedObject, SelectOption[] operators, String andOrOperator) {
            this.fieldName = fieldName;
            this.operator = operator;
            this.selectedObject = selectedObject;
            this.operators = operators;
            this.andOrOperator = andOrOperator;
        }
    }


    public class ObjectToShow {
        public Boolean checked { Set; get; }
        public sObject objectToShow { Set; get; }

        public ObjectToShow(sObject objectToShow) {
            this.objectToShow = objectToShow;
        }
    }


    //Constructor
    public Object_Filter_Controller () {
        getAllsObjects();
    }


    public  PageReference initialize() {
        isAdvancedFilterLogicOn = false;
        isFilterError = false;

        initializePageSizeOptionList();
        initializeObjectFieldSelectOptionList();
        initializeObjectList();
        return null;
    }


    //Get all the queriable fields for selected object
    public List<SelectOption> initializeObjectFieldSelectOptionList() {
        Map<String,String> fieldLabelToFieldNameMap = new Map<String,String>();
        objectCriteriaList = new ObjectCriteria[] {};
        objectFieldSelectOptionList = new Selectoption[] {};
        objectFieldsMap = new Map<String, Schema.Sobjectfield>();
        String[] fieldLabelsList = new String[] {};
        
        Schema.Sobjecttype token = globalDescribeMap.get(selectedSObject);
        sObject newObject = createObjectFromToken(token);

        for(Integer i = 1; i <= 5; i++ ) {
            objectCriteriaList.add(new ObjectCriteria('', '', newObject, operators, 'AND'));
        }

        objectFieldsMap = token.getDescribe().fields.getMap();
        for(String fieldName : objectFieldsMap.keySet()) {
            if(objectFieldsMap.get(fieldName).getDescribe().isFilterable()
               && objectFieldsMap.get(fieldName).getDescribe().isUpdateable()
            ) {
                fieldLabelToFieldNameMap.put(objectFieldsMap.get(fieldName).getDescribe().getLabel(), fieldName);
                fieldLabelsList.add(objectFieldsMap.get(fieldName).getDescribe().getLabel());
            }
        }

        fieldLabelsList.sort();

        objectFieldSelectOptionList.add(new SelectOption('', '---None---'));
        for(String fieldLabel : fieldLabelsList) {
            objectFieldSelectOptionList.add(new SelectOption(fieldLabelToFieldNameMap.get(fieldLabel), fieldLabel));
        }
        return objectFieldSelectOptionList;
    }


    public void initializeObjectList() {
        isFilterError = false;
        getTotal_size();

        if(list_size == null) {
            list_size = 10;
        }
        objectToShowList = new ObjectToShow[] {};

        selectedFieldList = new List<String>();
        String selectedField;

        for(ObjectCriteria criteriaForSelectedObject : objectCriteriaList) {
            selectedField = criteriaForSelectedObject.fieldName;
            if(selectedField != null) {
                selectedFieldList.add(selectedField);
            }
        }

        //GENERATED FIELD SELECT CHECK
        String query = ''
            + ' SELECT ' + generateFieldSelect(selectedFieldList)
            + '   FROM ' + selectedSObject
            + '   WHERE Id != null ';

            String whereClause = getObjectFilterCriteriaInString();
            if (isAdvancedFilterLogicOn == true && (filterLogicString == null || filterLogicString == '')) {
                isFilterError = true;
                filterLogicError ='Please specify your filter logic';
                return;
            }

            if (isAdvancedFilterLogicOn == true && filterLogicString != null && filterLogicString != '') {
                if (validateFilterLogic(query) == false) {
                    return;
                }

                whereClause = ' AND ( ' + validatedFilterLogicString + ' )';
            }
            if (whereClause != null && whereClause != '') {
                
                query += whereClause;
                query += ' LIMIT '+list_size;
                query += ' OFFSET '+counter;

                    queryObjectList = new sObject[] {};
                    queryObjectList = Database.query(query);
                    list_size = queryObjectList.size();
                    if (list_size != 0) {
                            for(sObject loopObject : queryObjectList) {
                                objectToShowList.add(new ObjectToShow(loopObject));
                            }
                }
            }
        
    }


    public void resetOperatorsForObjectCriteria() {
        if (getParam('index', null) == null) {
            return;
        }

        Integer index = Integer.valueOf(getParam('index', null));
        Integer filterRowNumber = index-1 ;
        if (objectCriteriaList[filterRowNumber].fieldName != null && objectCriteriaList[filterRowNumber].fieldName != '') {
            Schema.DescribeFieldResult describeResult = objectFieldsMap.get(objectCriteriaList[filterRowNumber].fieldName).getDescribe();
            objectCriteriaList[filterRowNumber].operators = fieldTypeWithOperatorsMap.get(describeResult.getSOAPType());
            objectCriteriaList[filterRowNumber].selectedObject = createObjectFromName(selectedSObject);
        }
    }


    public void addObjectCriteriaRow() {
        objectCriteriaList.add(new ObjectCriteria('', '', createObjectFromName(selectedSObject), operators, 'AND'));
    }


    public void removeObjectCriteriaRow() {
        Integer index = objectCriteriaList.size() - 1;
        objectCriteriaList.remove(index);
    }


    public String getObjectFilterCriteriaInString() {
        String strWhereClause = '';
        Integer iCount = 1;
        indexCriteriaMap = new Map<String, String>();

        for(ObjectCriteria objectCriteria : objectCriteriaList) {
            String fieldName =  objectCriteria.fieldName;
            String strIndividualWhereClause = '';
            if (objectCriteria.fieldName != null && objectCriteria.fieldName != '' &&
                objectCriteria.operator != null && objectCriteria.operator != '' &&
                objectCriteria.selectedObject.get(fieldName) != null) {
                
                Schema.DescribeFieldResult describeResult = objectFieldsMap.get(objectCriteria.fieldName).getDescribe();

                if (describeResult.getSOAPType() == Schema.SOAPType.String) {
                    if (objectCriteria.operator == 'like') {
                        if (describeResult.getType() == Schema.DisplayType.MultiPicklist) {
                            strIndividualWhereClause = ''
                                + ' ' + objectCriteria.fieldName
                                + ' ' + 'INCLUDES'
                                + ' ' +  '(' +'\'' + objectCriteria.selectedObject.get(objectCriteria.fieldName) + '\'' + ')';
                            strWhereClause = strWhereClause
                                + ' and ' + strIndividualWhereClause;
                        } else {
                            strIndividualWhereClause = ''
                                + ' ' + objectCriteria.fieldName
                                + ' ' + objectCriteria.operator
                                + ' ' + '\'%' + objectCriteria.selectedObject.get(objectCriteria.fieldName) + '%\'';
                            strWhereClause = strWhereClause
                                + ' and ' + strIndividualWhereClause;
                        }
                    } else {
                        strIndividualWhereClause = ''
                            + ' ' + objectCriteria.fieldName
                            + ' ' + objectCriteria.operator
                            + ' ' + '\'' + objectCriteria.selectedObject.get(objectCriteria.fieldName) + '\'';
                        strWhereClause = strWhereClause
                            + ' and ' + strIndividualWhereClause;
                    }
                } else if (describeResult.getSOAPType() == Schema.SOAPType.Id) {
                    strIndividualWhereClause = ''
                        + ' ' + objectCriteria.fieldName
                        + ' ' + objectCriteria.operator
                        + ' ' + '\'' + String.escapeSingleQuotes(String.valueOf(objectCriteria.selectedObject.get(objectCriteria.fieldName))) + '\'';
                    strWhereClause = strWhereClause
                        + ' and ' + strIndividualWhereClause;
                } else if (describeResult.getSOAPType() == Schema.SOAPType.Date) {
                    strIndividualWhereClause = ''
                        + ' ' + objectCriteria.fieldName
                        + ' ' + objectCriteria.operator
                        + ' ' + String.valueOf(Date.valueOf(objectCriteria.selectedObject.get(objectCriteria.fieldName)));
                    strWhereClause = strWhereClause
                        + ' and ' + strIndividualWhereClause;
                } else if (describeResult.getSOAPType() == Schema.SOAPType.DateTime) {
                    String compareDate = DateTime.newInstance(Date.valueOf(objectCriteria.selectedObject.get(fieldName)),Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    String compareDate1 = DateTime.newInstance(Date.valueOf(objectCriteria.selectedObject.get(fieldName)).adddays(1),Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                    if (objectCriteria.operator == '=') {
                        strIndividualWhereClause = ''
                            + ' ( ' + objectCriteria.fieldName
                            + '   >= ' + compareDate
                            + '  and ' + objectCriteria.fieldName
                            + '    < ' + compareDate1 +' )';
                        strWhereClause = strWhereClause
                            + ' and ' + strIndividualWhereClause;
                    } else if (objectCriteria.operator == '<=') {
                        strIndividualWhereClause = ''
                            + ' ' + objectCriteria.fieldName
                            + '    < ' + compareDate1;
                        strWhereClause = strWhereClause
                            + ' and ' + strIndividualWhereClause;
                    } else if (objectCriteria.operator == '>') {
                        strIndividualWhereClause = ''
                            + ' ' + objectCriteria.fieldName
                            + '  >= ' + compareDate1;
                        strWhereClause = strWhereClause
                            + ' and ' + strIndividualWhereClause;
                    } else if (objectCriteria.operator == '!=') {
                        strIndividualWhereClause = ''
                            + ' ( ' + objectCriteria.fieldName
                            + '   >= ' + compareDate1
                            + '   or ' + objectCriteria.fieldName
                            + '    < ' + compareDate +' )';
                        strWhereClause = strWhereClause
                            + ' and ' + strIndividualWhereClause;
                    }else {
                        strIndividualWhereClause = ''
                            + ' ' + objectCriteria.fieldName
                            + '     ' + objectCriteria.operator
                            + '     ' + compareDate;
                        strWhereClause = strWhereClause
                            + ' and ' + strIndividualWhereClause;
                    }
                } else {
                    strIndividualWhereClause = ''
                        + ' ' +  objectCriteria.fieldName
                        + ' ' + objectCriteria.operator
                        + ' ' + objectCriteria.selectedObject.get(objectCriteria.fieldName);
                    strWhereClause = strWhereClause
                        + ' and ' + strIndividualWhereClause;
                }
            }

            if (strIndividualWhereClause != '') {
                indexCriteriaMap.put(''+iCount, strIndividualWhereClause);
            }

            iCount++;
        }
        return strWhereClause;
    }


    //      *****      Pagination Methods      ******

    public void initializePageSizeOptionList() {
        pageSizeOptionList = new SelectOption[] {};
        pageSizeOptionList.add(new SelectOption('10','10'));
        pageSizeOptionList.add(new SelectOption('25','25'));
        pageSizeOptionList.add(new SelectOption('50','50'));
    }
    
    public PageReference Beginning() {
      counter = 0;
      initializeObjectList();
      return null;
    }

    public PageReference Previous() {
      counter -= list_size;
      initializeObjectList();
      return null;
    }

    public PageReference Next() {
      counter += list_size;
      initializeObjectList();
      return null;
    }

    public PageReference End() {
        counter = total_size - math.mod(total_size, list_size);
        initializeObjectList();
        return null;
    }

    public Boolean getDisablePrevious() { 
        if (counter>0) return false; else return true;
    }

    public Boolean getDisableNext() {
        if (counter + list_size < total_size) return false; else return true;
    }

    public Integer getTotal_size() {
        string countQuery = ''
            + ' SELECT count() '
            + ' FROM ' + selectedSObject
            + ' WHERE Id != null ';
        String whereClause = getObjectFilterCriteriaInString();
        countQuery += whereClause;

        total_size = Database.countQuery(countQuery);
        return total_size;
    }

    public Integer getPageNumber() {
        return counter/list_size + 1;
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    

    //    *****     Advanced filter logic functions      *****
    
    public void setAdvancedFilterLogic() {
        isAdvancedFilterLogicOn = true;
        Integer iCount = 1;
        String[] criteriaNumberList = new String[] {};
        for(ObjectCriteria objectCriteria : objectCriteriaList) {
            if(objectCriteria.fieldName != null && objectCriteria.fieldName != '') {
                criteriaNumberList.add(''+iCount);
            }
            iCount++;
        }
        filterLogicString = String.join(criteriaNumberList, ' AND ');
    }


    public void unSetAdvancedFilterLogic() {
        isAdvancedFilterLogicOn = false;
        filterLogicString = '';
    }

    public Boolean validateFilterLogic(String participantQuery) {
        if (indexCriteriaMap == null || indexCriteriaMap.size() == 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please specify filters'));
            return false;
        }

        String[] filterNumberList = new String[] {};
        String RegEx = '^[A-Za-z0-9{1,10}() ]+';
        Pattern MyPattern = Pattern.compile(RegEx);
        Matcher MyMatcher = MyPattern.matcher(filterLogicString);

        if (MyMatcher.matches() == false) {
            isFilterError = true;
            filterLogicError = 'Filter logic must not have any special characters';
            return false;
        }

        integer numberOfOpenParenthesis = filterLogicString.countMatches('(');
        integer numberOfCloseParenthesis = filterLogicString.countMatches(')');
        if (numberOfOpenParenthesis != numberOfCloseParenthesis ) {
            isFilterError = true;
            filterLogicError = 'Invalid bracket sequence';
            return false;
        }

        String tempfilterLogicString = filterLogicString.replace('(', ' ');
        tempFilterLogicString = tempFilterLogicString.replace(')', ' ');
        tempFilterLogicString.normalizeSpace();
        String[] stringList = tempFilterLogicString.split(' ');
        String previousChar = '';
        for(String str : stringList) {
            if (str.isNumeric()) {
                filterNumberList.add(str);
                if (previousChar.isNumeric()) {
                    isFilterError = true;
                    filterLogicError = 'Filter logic must have an Operator between successive filter numbers';
                    return false;
                } else if (Integer.valueOf(str) < 0 || Integer.valueOf(str)  > indexCriteriaMap.size()) {
                    isFilterError = true;
                    filterLogicError = 'Filter number ' +str+ ' is not valid. Please specfy numbers only for filters applied';
                    return false;
                }
            } else {
                if (str.equalsIgnoreCase('') == false && (previousChar.equalsIgnoreCase('AND') || previousChar.equalsIgnoreCase('OR') || previousChar.equalsIgnoreCase('NOT')) ) {
                    isFilterError = true;
                    filterLogicError = 'Filter logic must have a filter number between successive Operators';
                    return false;
                } else if (str.equalsIgnoreCase('AND') == false && str.equalsIgnoreCase('OR')== false && str.equalsIgnoreCase('NOT') == false && str.equalsIgnoreCase('') == false) {
                    isFilterError = true;
                    filterLogicError = 'Filter logic can have only AND, OR, NOT operators';
                    return false;
                }
            }
            previousChar = str;
        }

        validatedFilterLogicString = String.escapeSingleQuotes(filterLogicString);
        if (filterNumberList != null && filterNumberList.size() > 0 && indexCriteriaMap != null && indexCriteriaMap.size() > 0) {
            for (String filterNumber : filterNumberList) {
                if (indexCriteriaMap.containsKey(filterNumber) == false) {
                    isFilterError = true;
                    filterLogicError = 'IF CONDITION Invalid filter logic';
                    return false;
                }
                validatedFilterLogicString = validatedFilterLogicString.replace(filterNumber, indexCriteriaMap.get(filterNumber));
            }
        }

        try {
            participantQuery += ' AND ( ' + validatedFilterLogicString + ' )';
            Database.query(participantQuery);
        } catch (Exception ex) {
            isFilterError = true;
            filterLogicError = ' TRY CATCH Invalid filter logic';
            return false;
        }
        return true;
    }


    public static String generateFieldSelect(List<String> fieldSet) {
        String result = '';

        for(String field : fieldSet) {
            result += result.length() == 0 ? '' : ', ';
            result += String.escapeSingleQuotes(field);
        }

        return result;
    }
    
    


    public String getParam(String paramName, String defaultValue) {
        system.debug('==================getParam');
        system.assert(ApexPages.currentPage() != null, 'ApexPages.currentPage() == null');
        system.assert(ApexPages.currentPage().getParameters() != null, 'ApexPages.currentPage().getParameters() == null');
        String param = ApexPages.currentPage().getParameters().get(paramName);

        if (param == null && defaultValue == null) {
            return null;
        }

        if (param == null) {
            return String.escapeSingleQuotes(defaultValue);
        }

        return String.escapeSingleQuotes(param);
    }



     //      *****      My Added Utility Methods      ******

    //Global Describe call to get all SObjects
    public void getAllsObjects() {
       globalDescribeMap = new Map<String, Schema.Sobjecttype>();
       globalDescribeMap = Schema.getGlobalDescribe();
    }


    //Create Select list from the gobal describe map
    public List<SelectOption> getSObjectSelectList() {
        List<SelectOption> objectSelectList = new List<SelectOption>();
        List<String> tempList = new List<String>();
        
        objectLabelToObjectNameMap = new Map<String, String>();
        List<String> objectLabelsList = new List<String>();
        if(filterType == FILTER_CRITERIA_STANDARD) {
            for(String objectName : globalDescribeMap.keySet()) {
                if(       objectName != 'IdeaComment'
                       && globalDescribeMap.get(objectName).getDescribe().isQueryable() 
                       && globalDescribeMap.get(objectName).getDescribe().isSearchable()
                       && globalDescribeMap.get(objectName).getDescribe().isAccessible()
                       && globalDescribeMap.get(objectName).getDescribe().isCreateable()
                       && !globalDescribeMap.get(objectName).getDescribe().isCustom()
                  ) {
                 objectLabelToObjectNameMap.put(globalDescribeMap.get(objectName).getDescribe().getLabel(), objectName);
                  objectLabelsList.add(globalDescribeMap.get(objectName).getDescribe().getLabel());
                }
            }
        
        } else if(filterType == FILTER_CRITERIA_CUSTOM) {
            for(String objectName : globalDescribeMap.keySet()) {
                if(
                       globalDescribeMap.get(objectName).getDescribe().isQueryable() 
                    && globalDescribeMap.get(objectName).getDescribe().isSearchable()
                    && globalDescribeMap.get(objectName).getDescribe().isAccessible()
                    && globalDescribeMap.get(objectName).getDescribe().isCreateable()
                    && globalDescribeMap.get(objectName).getDescribe().isCustom()
                  ) {
                 objectLabelToObjectNameMap.put(globalDescribeMap.get(objectName).getDescribe().getLabel(), objectName);
                  objectLabelsList.add(globalDescribeMap.get(objectName).getDescribe().getLabel());
                }
            }
        
        } else if(filterType == FILTER_CRITERIA_STDCUST) {
            for(String objectName : globalDescribeMap.keySet()) {
                if(       objectName != 'IdeaComment'
                       && globalDescribeMap.get(objectName).getDescribe().isQueryable() 
                       && globalDescribeMap.get(objectName).getDescribe().isSearchable()
                       && globalDescribeMap.get(objectName).getDescribe().isAccessible()
                       && globalDescribeMap.get(objectName).getDescribe().isCreateable()
                  ) {
                 objectLabelToObjectNameMap.put(globalDescribeMap.get(objectName).getDescribe().getLabel(), objectName);
                  objectLabelsList.add(globalDescribeMap.get(objectName).getDescribe().getLabel());
                }
            }
            
        } 
        
        objectLabelsList.sort();
        
        objectSelectList.add(new SelectOption('','---None---'));
        for(String objectName : objectLabelsList) {
            objectSelectList.add(new SelectOption(objectLabelToObjectNameMap.get(objectName) , objectName));
        }
        return objectSelectList;
    }


    //Create new sObject from token
    public sObject createObjectFromToken(Schema.sObjectType objectType) {
        return objectType.newSObject();
    }


    //Create new sObject from name of the object
    public sObject createObjectFromName(String forObject) {
        Schema.Sobjecttype token = globalDescribeMap.get(forObject);
        return token.newSObject();
    }

}//END OF CLASS