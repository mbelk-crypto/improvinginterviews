({
    downloadMethod : function(component, event) {
        var action = component.get("c.downloadData");
        console.log('recordId ::++ ',component.get('v.recordId'));
        action.setParams({
            strRecordId : component.get('v.recordId')
        });
        action.setCallback(this, function(r) {
            var state = r.getState();
            var response = r.getReturnValue();
            console.log('response :::> ',response);
            if (state === "SUCCESS") {
                
                var a = document.createElement('a');
                a.style = "display:none";  
                var blob = this.converBase64toBlob(response);
                var url = window.URL.createObjectURL(blob);
                console.log('url ::++',url);
                a.href = url;
                a.target = '_blank';
                a.download = 'InterviewPacket.Pdf';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
                
                $A.get("e.force:closeQuickAction").fire()
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
    converBase64toBlob: function(content) {    
        var sliceSize = 512;
        var byteCharacters = window.atob(content); //method which converts base64 to binary
        var byteArrays = [];
        for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
            var slice = byteCharacters.slice(offset, offset + sliceSize);
            var byteNumbers = new Array(slice.length);
            for (var i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }
            var byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }
        var blob = new Blob(byteArrays); //statement which creates the blob
        return blob;
    }
})