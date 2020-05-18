/**
 * Created by The Hulk on 04-04-2019.
 */
({
    doInit : function(comp, evt, helper){
        console.log('in Do init');
    },
    handleClick : function(comp, evt, helper){
        console.log('Clicked');
        helper.callApexMethod(comp,helper);

    }
})