ad_library {

    Utility procs for the scorm  player.  Based on functions implemented in
    ilias's Modules/Scorm/classes/ilSCORM13Player.php script.

    @creation-date 2010/04/09
    @author Don Baccus
    @cvs-id $Id$
}

namespace eval scorm_player {}

ad_proc -private scorm_player::delete_course_cmi_data {
    -id:required
} {
    Remove all CMI data associated with a particular course.

    Since PG and Oracle both implement ON DELETE CASCADE, this is much simpler than the
    ilias MySql myisam table counterpart.

} {
    db_dml delete {}
}

ad_proc -private scorm_player::delete_cmi_data {
    -cp_node_id:required
    -user_id:required
} {
    Remove all CMI data for the given user and cp_node.

    Since PG and Oracle both implement ON DELETE CASCADE, this is much simpler than the
    ilias MySql myisam table counterpart.

} {
    db_dml delete {}
}

ad_proc scorm_player::debugging_enabled_p {} {

    @return 1 if debugging is enabled, 0 otherwise
} {
    return [parameter::get -package_id [ad_conn package_id] -parameter EnableJSDebugging]
}

ad_proc scorm_player::get_rte_url {} {

    Returns the url of the proper Javascript RTE to use, either the minimized one
    (default) or a properly formatted one which is much easier to read and debug.

    The behavior is controlled by the package instance "EnableJSDebugging" parameter.

} {
    set script [expr { [scorm_player::debugging_enabled_p] ? "rte.js" : "rte-min.js" }]
    return /resources/scorm-player/scripts/ilias/$script
}

ad_proc scorm_player::get_yahoo_url {} {

    Returns the url of the proper yahoo library to use, either the minimized one
    (default) or a properly formatted one which is much easier to read and debug.

    The behavior is controlled by the package instance "EnableJSDebugging" parameter.

} {
    set script [expr { [scorm_player::debugging_enabled_p] ? "yahoo.js" : "yahoo-min.js" }]
    return /resources/ajaxhelper/yui/yahoo/$script
}

ad_proc scorm_player::get_event_url {} {

    Returns the url of the proper yahoo event library to use, either the minimized one
    (default) or a properly formatted one which is much easier to read and debug.

    The behavior is controlled by the package instance "EnableJSDebugging" parameter.

} {
    set script [expr { [scorm_player::debugging_enabled_p] ? "event.js" : "event-min.js" }]
    return /resources/ajaxhelper/yui/event/$script
}

ad_proc scorm_player::get_treeview_url {} {

    Returns the url of the proper yahoo treeview library to use, either the minimized one
    (default) or a properly formatted one which is much easier to read and debug.

    We're using the ilias customized version of the YUI treeview scripts for now.

    The behavior is controlled by the package instance "EnableJSDebugging" parameter.

} {
    set script [expr { [scorm_player::debugging_enabled_p] ? "treeview.js" : "treeview-min.js" }]
    return /resources/scorm-player/scripts/ilias/$script
}

ad_proc scorm_player::get_scorm_init_args {
    -id:required
} {

    Return a JSON string representation of the args to pass to scorm_init on RTE
    start-up.  This is modeled after the code in the ilias PHP class ilSCORM13Player,
    but with URLs and other data munged to fit our rewrite into the non-object
    oriented Tcl language.

    @param id The reference id for the SCORM course.
    @return JSON string to be passed to the scorm_init() javascript function when
            the course player loads.

} {
    set user_id [ad_conn user_id]
    set name [person::name -person_id $user_id]
    db_1row course_info {}
    set scope [expr { [string is true $global_to_system] ? "null" : $id }]

    # Most of the RTE lang strings are generated in the player html and
    # I've done so directly, but there are a couple of calls to "toggleView()"
    # in the code that lead to our needing these language strings to be passed
    # via the config structure.

    set langstrings [util::json::object::create [subst \
        {btnhidetree "[_ scorm-player.Hide_Tree]"
         btnshowtree "[_ scorm-player.Show_Tree]"}]]

    set init_object [util::json::object::create [subst \
        {cp_url rte-api/cp?id=$id
         cmi_url rte-api/cmi?id=$id
         adlact_url rte-api/adlact?id=$id
         specialpage_url rte-api/specialPage?id=$id
         suspend_url rte-api/suspend?id=$id
         get_suspend_url rte-api/getSuspend?id=$id
         gobjective_url rte-api/gobjective?id=$id
         get_gobjective_url rte-api/getGobjective?id=$id
         ping_url rte-api/pingSession?id=$id
         scope $scope
         learner_id $user_id
         course_id $id
         learner_name {$name}
         mode $default_lesson_mode
         credit $credit
         auto_review $auto_review
         hide_navig false
         debug false
         package_url [ad_conn package_url]scorm-player/sco/${id}/
         session_ping 0
         envEditor 0
         langstrings {$langstrings}}]]

    return [util::json::gen $init_object]
}

ad_proc scorm_player::interval_to_seconds {
    -timestamp:required
} {
    Convert a SCORM 2004 ISO 8601 interval to seconds.  The particular format used in
    SCORM 2004 is not direclty supported by Tcl, Tcllib, or PostgreSQL so we gotta convert
    it ourselves.
} {
    if { $timestamp eq "" } {
        return -code error "timestamp can not be an empty string"
    }
    set multipliers {31557600 2629800 86400 3600 60}
    set seconds 0
    set index 1
    if { [string first P $timestamp] == 0 } {
        foreach delimiter {Y M D} {
            if { [regexp "^(\[\\d\]+)$delimiter" [string range $timestamp $index end] match digits] } {
                incr seconds [expr {[lindex $multipliers 0] * $digits}]
                incr index [string length $match]
            }
            set multipliers [lrange $multipliers 1 end]
        }
        if { [string range $timestamp $index $index] eq "T" } {
            incr index
            foreach delimiter {H M} {
                if { [regexp "^(\[\\d\]+)$delimiter" [string range $timestamp $index end] match digits] } {
                    incr seconds [expr {[lindex $multipliers 0] * $digits}]
                    incr index [string length $match]
                }
                set multipliers [lrange $multipliers 1 end]
            }
            if { [regexp {^([\d]+[\.]?[\d]*)S} [string range $timestamp $index end] match digits] } {
                incr seconds [expr {round($digits)}]
                incr index [string length $match]
            }
        }
    }
    if { $index != [string length $timestamp]} {
        return -code error "timestamp \"$timestamp\" is poorly formed"
    }
    return $seconds
}

ad_proc scorm_player::seconds_to_interval {
    -timestamp:required
} {
    Convert a database interval into a SCORM 2004 style interval.

    Note: only works for hours, minutes and fractional seconds thus far.
} {
    if { $timestamp eq "" } {
        return null
    }
    set splits [split $timestamp :]
    if { [llength $splits] > 3 } {
        return --code error \
            "scorm_player::seconds_to_interval only handles hours, minutes, seconds"
    }
    return "PT[lindex $splits 0]H[lindex $splits 1]M[lindex $splits 2]S"
}
