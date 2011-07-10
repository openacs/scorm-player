/* This file contains functions from the ilias JavaScript RTE that have
   been modified for use within the OpenACS environment.  The original ilias
   RTE files are unmodified, the functions in this file simply override the
   originals.
*/

// Toggle functions are redefined to take a string, which we'll localize in the template
// that calls it.  These were not localized in the Ilias RTE so we'd need to replace
// them even if we chose to pass the localized values in the config JSON string rather
// than as params to the call.

function toggleTree(collapse,expand) {
	elm = all("toggleTree");
	
	if (treeState==false) {
		elm.innerHTML=collapse;
		treeYUI.expandAll();
		treeState=true;
	} else {
		elm.innerHTML=expand;
		treeYUI.collapseAll();
		treeState=false;
	}
}

function toggleLog(hide,show) {
	elm = all("toggleLog");
	if (logState==false) {
		elm.innerHTML=hide;
		logState=true;
		onWindowResize()
	} else {
		elm.innerHTML=show;
		logState=false;
		onWindowResize();
	}
}

function onDocumentClick (e) 
{
    e = new UIEvent(e);
    var target = e.srcElement;
    
    
    //integration of ADL Sqeuencer

    // OpenACS change: Ilias version of this if statement ignores any A tag with no ID set
    if (target.tagName !== 'A' || target.className.match(/disabled/) )
    {
        // ignore clicks on other elements than A
        // or non identified elements or disabled elements (non active Activities)
    } 
    
    //handle eventes like Contine, Previous, Exit...
    else if (target.id.substr(0, 3)==='nav') 
    {
        var navType=target.id.substr(3);
        launchNavType(navType);    
    } 
    
    //SCO selected by user directly (itm is used as ITEM_PREFIX)
    else if (target.id.substr(0, 3)===ITEM_PREFIX) 
    {
        if (e.altKey) {} // for special commands
        else 
        {
            mlaunch = msequencer.navigateStr( target.id.substr(3));
           
             if (mlaunch.mSeqNonContent == null) {
                //alert(activities[mlaunch.mActivityID]);    
                //throw away API from previous sco and sync CMI and ADLTree
                onItemUndeliver();
                statusHandler(mlaunch.mActivityID,"completion","unknown");
                onItemDeliver(activities[mlaunch.mActivityID]);
            //    setTimeout("updateNav()",2000);  //temporary fix for timing problems
            } else {
              //call specialpage
                  loadPage(gConfig.specialpage_url+"&page="+mlaunch.mSeqNonContent);
            }
        }
    }
    else if (typeof window[target.id + '_onclick'] === "function")
    {
        window[target.id + '_onclick'](target);
    } 
    else if (target.target==="_blank")
    {
        return;
    } 

    // OpenACS change to allow non-player navigation to work, but only after saving
    // state.
    else if (target.tagName == 'A' && !target.className.match(/disabled/))
    {
        launchNavType('ExitAll');    
//        syncCMIADLTree();
//        save_global_objectives();
//        save();
        return;
    } 
    // End OpenACS change.

    e.stop();
}

