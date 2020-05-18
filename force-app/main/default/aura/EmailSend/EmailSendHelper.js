({
    fetchMailData: function(component, event){
        var action = component.get("c.getMailData");
        console.log('recordId :::** ',component.get('v.recordId'));
        action.setParams({
            strRecordId : component.get('v.recordId')
        });
        action.setCallback(this, function(r) {
            var state = r.getState();
            var response = r.getReturnValue();
            console.log('response :::> ',response);
            console.log('state :::> ',state );
            if (state === "SUCCESS") {
                
                component.set("v.email", response);
                //component.set("v.modalOpen", true);
            }else if (action.getState() == "ERROR") {
                var errors = action.getError();
                console.log('errors ::>',errors);
                if (errors[0] && errors[0].message) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({title : 'Error',message: errors[0].message,duration:'3000',key: 'info_alt',type: 'error',mode: 'pester'});
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
	 sendHelper: function(component, getEmail, getSubject, getbody) {
        // call the server side controller method 	
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            strRecordId : component.get('v.recordId'),
            'mMail': getEmail,
            'mSubject': getSubject,
            'mbody': getbody
        });
        action.setCallback(this, function(r) {
            var state = r.getState();
            var response = r.getReturnValue();
            if (state === "SUCCESS") {
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({title : 'Success',message: 'Mail Sent',duration:'3000',key: 'info_alt',type: 'success',mode: 'pester'});
                toastEvent.fire();
                //component.set("v.modalOpen", false);
            }else if (action.getState() == "ERROR") {
                var errors = action.getError();
                console.log('errors ::>',errors);
                if (errors[0] && errors[0].message) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({title : 'Error',message: errors[0].message,duration:'3000',key: 'info_alt',type: 'error',mode: 'pester'});
                    toastEvent.fire();
                }
            } 
        });
        $A.enqueueAction(action);
    }
})