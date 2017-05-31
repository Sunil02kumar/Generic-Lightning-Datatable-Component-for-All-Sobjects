({

	callToServer : function(component, method, callback, params) {
        console.log('Calling helper callToServer function');
		var action = component.get(method);
        if(params){
            action.setParams(params);
        }
        console.log(JSON.stringify(params));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('Processed successfully at server');
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR"){
                alert('MALFORMED SOQL STRING. Wrong values have been specified for component attributes. Please check WSDL for correct API names and try again');
            }
        });
		$A.enqueueAction(action);
    }
})