ad_page_contract {

    Main player template.  Sets up the RTE initial environment.  The RTE then
    takes over most operations.

    @cvs-id $Id$
} {
    id:naturalnum,notnull
} -validate {
    check_id {
        if { ![db_0or1row check_id {}] } {
            ad_complain "object \"$id\" is not a scorm course."
        }
    }
}

permission::require_permission \
    -party_id [ad_conn user_id] \
    -object_id $id \
    -privilege read

set show_log_p [scorm_player::debugging_enabled_p]

set rte_url [scorm_player::get_rte_url]
set yahoo_url [scorm_player::get_yahoo_url]
set event_url [scorm_player::get_event_url]
set treeview_url [scorm_player::get_treeview_url]

template::head::add_css -href /resources/scorm-player/styles/player.css
template::head::add_css -href /resources/scorm-player/styles/delos.css

template::head::add_script -type text/javascript -src $yahoo_url -order 1
template::head::add_script -type text/javascript -src $event_url -order 2
template::head::add_script -type text/javascript -src $treeview_url -order 3
template::head::add_script -type text/javascript \
    -src /resources/scorm-player/scripts/ilias/rteconfig.js -order 4

# Unfortunately the RTE begins by inspecting the document, which fails if it's loaded
# in the HEAD section of the document, even with defer set.  That code should be
# put in the init function so it's not executed until it's called from the body.  This
# also prevents me from putting my overwriting functions in rte-changes.js into the
# HEAD.  At least Yahoo does it right ...

set body(class) loadingState
set body(id) scormplayer
set scorm_init_args [scorm_player::get_scorm_init_args -id $id]
