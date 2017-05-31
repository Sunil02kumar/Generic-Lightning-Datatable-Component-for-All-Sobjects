//----------------------------------------------------------
//Author: Sunil Kumar(sunil02kumar@gmail.com)
//Purpose: To generate JSOn string to display records in datatable in lightning component
//********changes logs*********
//-------------------------------------------------------
public class LightningJSONDataTableController{
     //*******Constants*******************
    private static final String DATE_DATATYPE = 'DATE';
    private static final String DATETIME_DATATYPE = 'DATETIME';
    private static final String CURRENCY_DATATYPE = 'CURRENCY';
    private static final String PARENT_RELATIONSHIP = 'REFERENCE';
    
    @AuraEnabled
    public static String generateDataSet (string objAPIname, string fieldsAPIname, string columnsLabel, string hyperlinkColumn, string sortingOrder, string filterCriteria, string recordsLimit){
        //Variable to store column label and API name information information
        List<String> columnLabelList = new List<String>();
        List<String> FieldAPINameList = new List<String>();
        datasetForTable dataSet =new datasetForTable();
        Map<String,String> fieldToFieldTypeMap = new Map<String,String>();
        //Section to generate dynamic query start------------------
        string fieldQuery = '';
        string objectApiName ='';
        string fieldApiName = '';
        string sortingOrderBy = '';
        string whereClause = '';
        string limitString = '';
        string HyperLinkField = '';
        string queryString ='';

        if(hyperlinkColumn != null && hyperlinkColumn !=''){
            HyperLinkField = hyperlinkColumn.trim();
        }if(objAPIname!=null && objAPIname!=''){
            objectApiName = objAPIname.trim();
        }if(fieldsAPIname != null && fieldsAPIname != ''){
            List<string> passedFiledNames = fieldsAPIname.trim().split(',');
            if(passedFiledNames.size() > 0 ){
                for(string ss : passedFiledNames){
                    if(ss != null && ss != ''){
                        if(!ss.EqualsIgnoreCase('ID')){
                            fieldQuery = fieldQuery + ' , ' + ss.trim();
                        }
                        FieldAPINameList.add(ss.trim());
                    }
                }
            }
        }if(sortingOrder != null && sortingOrder != ''){
            List<string> sortingColumns = sortingOrder.trim().split(',');
            if(sortingColumns.size() > 0 ){
                for(string ss : sortingColumns){
                    if(ss != null && ss != ''){
                        sortingOrderBy = sortingOrderBy + '  ' + ss.trim();
                    }
                }
                sortingOrderBy = ' Order by ' +  sortingOrderBy;
            }
        }if(filterCriteria != null && filterCriteria != ''){
            whereClause = ' where ' + filterCriteria;
        }if(recordsLimit != null && recordsLimit != '' && recordsLimit != '0'){
                limitString = ' LIMIT '+ integer.valueof(recordsLimit);
        }else{
            limitString = ' LIMIT 9000';
        }
            
        queryString = 'select  id' + fieldQuery + ' from ' + objectApiName +  whereClause + sortingOrderBy + limitString;
        //Section to find columns label start-------------------
        if(columnsLabel!=null && columnsLabel!=''){
            List<string> filedLabels = columnsLabel.trim().split(',');
            if(filedLabels.size() > 0 ){
                for(string ss : filedLabels){
                    if(ss != null && ss != ''){
                        columnLabelList.add(ss.trim());
                    }
                }
            }
        }
        //Section to find coumns label ends--------------------
            
        //Section to find field and their field type map starts------------
        fieldToFieldTypeMap = generateFieldTypeMap(objectApiName,FieldAPINameList);
        system.debug('***********fieldToFieldTypeMap:'+fieldToFieldTypeMap);
        //Section to find field and their field type map ends------------
        system.debug('***********queryString:'+queryString);
        system.debug('***********FieldAPINameList:'+FieldAPINameList);
        system.debug('***********columnLabelList:'+columnLabelList);
        list<sobject> sbList= new List<sobject>();
        if(queryString != null && queryString != ''){
            try{
                sbList=database.query(queryString);
                
            }catch(exception ex){ 
                system.debug('****Exception while query the related records.'+ ex.getmessage());
                return 'MALFORMED SOQL STRING';
            }
        }
        //generating the dataset in order to display on UI
        list<list<String>> dataValues=new list<list<String>>();
        list<list<String>> columnsLabels=new list<list<String>>();
        if(sbList.size()>0){
            for(sobject sb:sbList){
                list<String> fieldvalues = new List<String>();
                for(String ss:FieldAPINameList){
                    try{
                        string colValue;
                        system.debug('******column API Name .'+ ss );
                        if(ss.contains('.')){
                            List<string> splitedFields = ss.split('\\.');
                            system.debug('****splitedFields .'+ splitedFields );
                            if(sb.getSobject(splitedFields[0])!=null && splitedFields[1] !=null){
                                system.debug('******colValue describe .'+ sb.getSobject(splitedFields[0]));
                                colValue = (String) sb.getSobject(splitedFields[0]).get(splitedFields[1]);
                            }
                        }else{
                            if(sb.get(ss)!=null){
                                colValue = string.valueof(sb.get(ss));
                                if(fieldToFieldTypeMap.get(ss)!=null){
                                    if(fieldToFieldTypeMap.get(ss)== DATE_DATATYPE || fieldToFieldTypeMap.get(ss)==DATETIME_DATATYPE){
                                        try{
                                            colValue = colValue.split(' ')[0];
                                            List<String> dateColumns=colValue.split('-');
                                            integer year=integer.valueof(dateColumns[0]);
                                            integer month=integer.valueof(dateColumns[1]);
                                            integer day=integer.valueof(dateColumns[2]);
                                            date myDate = date.newInstance(year, month, day);
                                            system.debug('************myDate:'+myDate);
                                            colValue = myDate.format();
                                        }catch(exception ex){
                                            system.debug('******column is not of date or datetime datatype:'+ex.getmessage());
                                        }
                                    }else if(fieldToFieldTypeMap.get(ss)==CURRENCY_DATATYPE){
                                        String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String) sb.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
                                        colValue = GetCurrencySymbolFromISO(currencyIso)+ Decimal.valueof(colValue).format();
                                    }
                                }
                            }
                        }
                        
                        system.debug('******colValue .'+ colValue );
                        if(colValue == null || colValue == ''){
                            fieldvalues.add('');
                        }else{
                            if(ss.equalsIgnoreCase(HyperLinkField)){
                                colValue = '<a href=\'/' + sb.get('id') + '\'  target=\'_blank\'>' + colValue + '</a>';
                            }
                            fieldvalues.add(string.valueof(colValue));
                        }
                    }catch(exception ex){ 
                        fieldvalues.add('');
                        system.debug('*******Error in some Field API Name.'+ ex.getmessage());
                    }
                }
                dataValues.add(fieldvalues);
            }
        }
        if(columnLabelList.size()>0){
            for(String ss : columnLabelList){
                columnsLabels.add(new List<String>{ss});
            }
        }
        dataSet.data = dataValues;
        dataSet.columns = columnsLabels ;
        string jsondata=JSON.serialize(dataSet);    
        system.debug('*****jsondata:'+jsondata);
        return jsondata;
        
    }
    //method to generate field and their field type map
    public static Map<String,String> generateFieldTypeMap(string objectApiName,List<String> FieldAPINameList){
        Map<String,String> returnMap = new Map<String,String>();
        if(objectApiName!=null && objectApiName !=''){
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getdescribe().fields.getMap(); 
            for(String ss:FieldAPINameList){
                if(ss.contains('.')){
                    returnMap.put(ss,PARENT_RELATIONSHIP); 
                }else{
                    returnMap.put(ss,string.valueof(fieldMap.get(ss).getDescribe().getType())); 
                }
            }
        }
        return returnMap;
    }
    //method to return currency symbol
    public static String GetCurrencySymbolFromISO(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('KRW' == Iso ? '₩' : 
           ('CNY' == Iso ? '元' : 
           '')))))));
           return currencySymbol;
    }
    public class datasetForTable{
        public List<List<String>> columns;
        public List<List<String>> data;
    }

}