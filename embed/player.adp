<master>
  <property name="&body">body</property>

  <table {VAL_DISPLAY} id="toolbarTable" width="100%" height="100%" style="height: 100%" cellspacing="0" cellpadding="0" border="0" summary="">
    <tr height="1%">
      <td class="submit">  
        <div style="clear:both; margin: 1px 8px 3px 8px;">
                
          <a target="_self" href="#" class="button" onclick="toggleView();" id="treeToggle">#scorm-player.Hide_Tree#</a>
          <a target="_self" href="#" class="button" id="navStart">#scorm-player.Start#</a>
          <a target="_self" href="#" class="button" id="navExit">#scorm-player.Exit#</a>
          <a target="_self" href="#" class="button" id="navExitAll"">#scorm-player.Exit_All#</a>
          <a target="_self" href="#" class="button" id="navSuspendAll">#scorm-player.Suspend_All#</a>
          <a target="_self" href="#" class="button" id="navPrevious">#scorm-player.Previous#</a>
          <a target="_self" href="#" class="button" id="navContinue">#scorm-player.Continue#</a>
        </div>
      </td>
    </tr>
  </table>
    
  <table id="introTable" width="100%" cellspacing="0" cellpadding="0" border="0" summary="">
    <tr valign="top" >      
      <td class="std">
        <noscript>#scorm-player.Javascript_Required#</noscript>
        <div style="display: none !important; background-color: red !important; color: white !important; font: 14pt/1.0 monospace !important">{NO_CSS}</div>
        <div id="introLabel">loading</div>
      </td>        
    </tr>
  </table>

  <table id="mainTable" width="100%" height="100%" style="width: 100%; height: 100%"
      cellspacing="0" cellpadding="0" border="0" summary="">
    <tr valign="top">
      <td style="width:25%" width="25%" id="leftView">
        <div id="treeView"></div>
        <div id="ilLog" style="font-size:9px; white-space:pre; overflow:scroll;">
          <pre id="ilLogPre" style="font-family:Verdana,Arial,Helvetica,sans-serif;"></pre>
        </div>
          
        <div id="treeControls" style="vertical-align:middle; margin-left:5px">
          <if @show_log_p;literal@ true>
            <a id="toggleLog" href="#"
                onclick="toggleLog('#scorm-player.Hide_Log#','#scorm-player.Show_Log#');"
                style="font-size:11px;">
              #scorm-player.Show_Log#
            </a>
            &nbsp; &nbsp;
          </if>
          <a id="toggleTree" href="#"
              onclick="toggleTree('#scorm-player.Collapse_All#','#scorm-player.Expand_All#');"
              style="font-size:11px;">
            #scorm-player.Collapse_All#
          </a>
        </div>
      </td>
      <td style="width:75%; height:98%;" width="75%" height="98%" id="tdResource">
        <iframe id="res" style="width: 100%; height:100%;" frameborder="0"></iframe>
      </td>
    </tr>
      
  </table>

  <!--script type="text/javascript" src="@rte_url@"></script-->
  <!--script type="text/javascript" src="/resources/scorm-player/scripts/openacs/rte-changes.js">
  </script-->

  <script type="text/javascript">
    //<![CDATA[
      Date.remoteOffset = (new Date()).getTime()
      <if @show_log_p;literal@ true>
        var disable_all_logging=false,disable_sequencer_logging=true;
      </if>
      <else>
        var disable_all_logging=true,disable_sequencer_logging=true;
      </else>
      scorm_init(@scorm_init_args;noquote@);
    //]]>
  </script>
