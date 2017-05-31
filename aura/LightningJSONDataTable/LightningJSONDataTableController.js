({
	doInit : function(component,event,helper){
       helper.callToServer(
            component,
            "c.generateDataSet",
            function(response) {
                console.log(response);
                var tableData = response;
                tableData =tableData .replace(/(&quot\;)/g,"\"")
                tableData  = tableData .replace(/(&lt\;)/g,'<').replace(/(&gt\;)/g,'>').replace(/(&#39\;)/g,'\'').replace(/(&amp\;)/g,'&');
                var jsonData = JSON.parse(tableData)
                console.log('****JSON response:'+JSON.stringify(jsonData));
                //rendering jquery datatable
                setTimeout(function(){ 
                    var tableHeaders="";
                    $.each(jsonData.columns, function(i, val){
                        tableHeaders += "<th>" + val + "</th>";
                    });
                    $("#tableDiv").empty();   
                    $("#tableDiv").append('<table id="displayTable" class="display" cellspacing="0" width="100%"><thead><tr>' + tableHeaders + '</tr></thead></table>');
                    $("#displayTable").dataTable(jsonData);
                }, 500);    
            }, 
            {
            	objAPIname: component.get('v.objAPIname'),
            	fieldsAPIname: component.get('v.fieldsAPINameList'),
            	columnsLabel: component.get('v.columnsLabelList'), 
                hyperlinkColumn: component.get('v.columnForHyperLink'),
                sortingOrder: component.get('v.sortingOrder'),
            	filterCriteria: component.get('v.filterCriteria'),
                recordsLimit: component.get('v.recordsLimit')
            }
        ); 
    }
})