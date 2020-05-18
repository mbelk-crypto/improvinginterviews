/**
 * Created by The Hulk on 04-04-2019.
 */
({


    callApexMethod: function (comp, helper){
                        comp.set("v.errBool",false);
        comp.set("v.spinnerBool",true);

         helper.enqueueJob(comp);
         console.log('after enqueue Job');
           comp.set("v.spinnerBool",true);

          var jobIntervalID =  window.setInterval(
                      $A.getCallback(function() {
                          helper.getStatus(comp,helper);
                      }), 5000
                  );
           console.log('after First getStatus with JobID = ' + jobIntervalID);
           comp.set("v.jobIntervalID",jobIntervalID);
    },


    getStatus : function(comp, helper){
        var action = comp.get("c.checkJobStatus");
        console.log('check Job Status');
        action.setCallback(this, function(response){
            var jobStatus = response.getReturnValue();
            if(jobStatus){
                console.log('When Job Status = true');
                window.clearInterval(comp.get("v.jobIntervalID"));
                comp.set("v.spinnerBool",false);
                comp.set("v.errBool",true);
                comp.set("v.errorMessage","Synced Successfully");

               $A.get("e.force:closeQuickAction").fire();
            }

        });
                 $A.enqueueAction(action);
    },

    enqueueJob : function(comp){
        var action = comp.get("c.queueJob");
                 $A.enqueueAction(action);
    }

})