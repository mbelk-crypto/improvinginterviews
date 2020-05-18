({
	doInit : function(component, event, helper) {
		var recordId = component.get('v.recordId');
        component.set('v.iframeUrl','/apex/InterviewPacketPdf?id='+recordId);
	}
})