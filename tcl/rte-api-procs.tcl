ad_library {

    This library implements procedures which map to methods in the
    ilias Scorm player's ilSAHSPresentationGUI base class.

    The dispatch script rte-api/index.vuh calls the various apirpocs.  user_id
    is always passed even if it's not required for simplicity. Those procs
    that actually use it have their user_id parameter marked "required".  Others
    ignore it.

    @creation-date 2010/04/13
    @author Don Baccus
    @cvs-id $Id$
}

namespace eval scorm_player {
    namespace eval rte_api {}
}

ad_proc scorm_player::rte_api::cp_GET {
    -id:required
    -user_id
} {
    Returns the JSON string for the given course.  We've copied the ilias
    convention of shoving the string into the jsdata column of the cp_package
    row for the course.
} {
    return [db_string get_jsdata {}]
}

ad_proc scorm_player::rte_api::adlact_GET {
    -id:required
    -user_id
} {
    Returns the JSON string for the activity tree for the given course.  We've copied
    the ilias convention of shoving the string into the activitytree column of the cp_package
    row for the course.
} {
    return [db_string get_activitytree {}]
}

ad_proc scorm_player::rte_api::specialPage_GET {
    -id:required
    -page:required
    -user_id
} {
    Return one of the "special pages", such as "course completed", or "please
    navigate using the tree on the left", i.e. pages not included within a
    course but provided by the course player.
} {
    ns_set update [ad_conn outputheaders] content-type text/html
    return [ad_parse_template -params [list [list page $page]] \
               /packages/scorm-player/lib/player/special-pages]
}

ad_proc scorm_player::rte_api::suspend_POST {
    -id:required
    -user_id:required
    -data:required
} {
    Save suspend data collected by the RTE.
} {
    if { [db_0or1row exists {}] } {
        db_dml update {}
    } else {
        db_dml insert {}
    }
    return
}

ad_proc scorm_player::rte_api::getSuspend_GET {
    -id:required
    -user_id:required
} {
    Return saved suspend data to the RTE.
} {
    if { [db_0or1row get_suspend_data {}] } {
        db_dml delete_suspend_data {}
        return $data
    }
    return
}

ad_proc scorm_player::rte_api::gobjective_POST {
    -id:required
    -user_id:required
    -data:required
} {
    Save global objective data collected by the RTE.  The objectives and scope
    (scoped to course, global to LMS) are defined in the course's manifest.
} {

    if { $data eq "" } {
        return
    }

    foreach {key object} [util::json::object::get_values $data] {
        foreach {objective_id object} [util::json::object::get_values $object] {
            array unset objective_by_user 
            array unset objective_by_scope 

            # ilias code promises that these exist.

            array set objective_by_user [util::json::object::get_values $object]
            array set objective_by_scope \
                [util::json::object::get_values $objective_by_user($user_id)]            
            if { $key eq "status" } {
                set objective_id -course_overall_status-
                set scope_id $id
                set completed $objective_by_scope(completed)
                set satisfied $objective_by_scope(satisfied)
                set measure $objective_by_scope(measure)
            } elseif { [info exists objective_by_scope($id)] } {
                set scope_id $id
                set value $objective_by_scope($id)
            } else {
                set scope_id 0
                set value $objective_by_scope(null)
            }
            if { [db_0or1row exists {}] } {
                db_dml update_$key {}
            } else {
                db_dml insert_$key {}
            }
        }
    }          
    return
}

ad_proc scorm_player::rte_api::getGobjective_GET {
    -id:required
    -user_id:required
} {
    Return saved global objectives information to the RTE.
} {
    set data ""

    # Something seems horribly wrong here: we return state for every user, which
    # can then be read via firebug etc.  I've confirmed that this is how ilias
    # works.  For now, I replicate that behavior.

    db_multirow gobjectives gobjectives {} {
        if { $scope_id == 0 } {
            set scope_id null
        }

        if { $satisfied ne "" } {
            set data [util::json::object::set_by_path \
                         -object $data \
                         -path [list satisfied $objective_id $user_id $scope_id] \
                         -value $satisfied]
        }

        if { $measure ne "" } {
            set data [util::json::object::set_by_path \
                         -object $data \
                         -path [list measure $objective_id $user_id $scope_id] \
                         -value $measure]
        }
    }
    return [expr { $data ne "" ? [util::json::gen $data] : "{}" }]
}

ad_proc scorm_player::rte_api::pingSession_GET {
    -id:required
    -user_id
} {
    Keepalive technology ... "ping!"
} {
    ns_set update [ad_conn outputheaders] content-type text/plain
    return
}

ad_proc scorm_player::rte_api::getRTEjs_GET {
    -id:required
    -user_id
} {
    Not needed as we grab it via an href in the script tag.
} {
    return -code error "Unneeded and unimplemented proc getRTEjs_GET called."
}

ad_proc -private scorm_player::rte_api::cmi_GET {
    -id:required
    -user_id:required
} {
    Process a GET cmi operation.  This retrieves the relevant data from the database
    and returns it as a JSON string.  The datamodel structure is defined in
    rte-api-init.tcl.
} {

    set schema {}
    set data {}

    foreach {table} [nsv_get scorm_schema tables] {
        set attribute_list [nsv_get scorm_schema ${table}_table]

        # attribute_names is the list of names only (minus modifier) used to build
        # the JSON schema description.  This isn't the same as the list of attribute
        # names used in the database due to the special "c_" qualifier added to those
        # that happen to match database keywords.

        set attribute_names {}

        # select_attributes is the list of munged attribute names to use in the rowset
        # descriptor for the query.

        set select_attributes {}

        # Build the list of JSON schema attribute names, and qualified database
        # attribute (column) rowset names.  In practice, the database rowset names are
        # ignored for cp_package, which is very much a special case.

        foreach attribute $attribute_list {
            foreach {name dummy} $attribute {}
            lappend attribute_names $name
            lappend select_attributes cmi_${table}.[scorm_core::db_name -name $name]
        }
        lappend schema $table [util::json::array::create $attribute_names]
        set select_attributes [join $select_attributes ,]
        set rowset [db_list_of_lists $table {}]
        lappend data $table
        set rows {}
        foreach row $rowset {
            lappend rows [util::json::array::create $row]
        }
        lappend data [util::json::array::create $rows]
    }

    return [util::json::gen \
        [util::json::object::create \
           [list schema [util::json::object::create $schema] \
                 data [util::json::object::create $data]]]]

}

ad_proc -private scorm_player::rte_api::cmi_POST {
    -id:required
    -user_id:required
    -data:required
} {
    Process a POST cmi operation.  This takes a JSON string as data, parses it, and
    stores the data into the database.  This is where the persistent storage of RTE
    tracking information takes place.  The datamodel structure is defined in
    rte-api-init.tcl
} {

    # Browse mode allows one to navigate through a course without generating tracking
    # data.  Useful for checking out a course before making it public.

    if { [db_string get_lesson_mode {}] eq "browse" } {
        return
    }

    foreach {table table_data} [util::json::object::get_values $data] {
        set data_rows($table) {}
        foreach row [util::json::array::get_values $table_data] {
            lappend data_rows($table) [util::json::array::get_values $row]
        }
    }

    # Now for each table insert each row in the data structure, massaging special
    # values and ignoring read-only columns in the process.  Note that this process
    # is sensitive to the ordering of the schema defined in our init file.

    foreach table [array names data_rows] {
        set attributes [nsv_get scorm_schema ${table}_table]

        # This is a bit brute-force, we're going to walk the attributes and munge
        # special columns and drop out read-only columns dynamically for each row.
        # While it would be possible to go after this in a more sophisticated way,
        # since each iteration results in an intrinsically slow database INSERT,
        # it's not worth it.

        foreach data_row $data_rows($table) {
            if { [llength $data_row] != [llength $attributes] } {
                return -code error "Schema and JSON data column count must be equal."
            }
            set fixed_data_row {}
            set insert_attributes {}
            for { set i 0} { $i < [llength $attributes] } { incr i } {
                foreach {name modifier} [lindex $attributes $i] {}
                switch $modifier {        
                    KEY {
                        set key [db_nextval acs_object_id_seq]
                        set keys($name) $key
                        set data_row [lreplace $data_row $i $i $key]
                    }
                    KEYREF {
                        set value [expr { [info exists keys($name)] ? $keys($name) : "null" }]
                        set data_row [lreplace $data_row $i $i $value]
                    }
                    USERREF {
                        set data_row [lreplace $data_row $i $i $user_id]
                    }
                    LEARNERNAMEREF {
                        set data_row \
                            [lreplace $data_row $i $i [person::name -person_id $user_id]]
                    }
                    TIMESTAMP {
                        set data_row [lreplace $data_row $i $i [db_string now {}]]
                    }
                    CPNODEREF {
                        set cp_node_id [lindex $data_row $i]
                        if { ![db_0or1row check_cp_node_id {}] } {
                            return -code error \
                                "cp_node \"$cp_node_id\" does not belong to this course"
                        }
                        scorm_player::delete_cmi_data \
                            -cp_node_id $cp_node_id -user_id $user_id
                    }
                    W { }
                    default {
                        # Skip read-only columns
                        continue
                    }
                }
                lappend insert_attributes [scorm_core::db_name -name $name]
                lappend fixed_data_row \
                    [util::json::json_value_to_sql_value [lindex $data_row $i]]
            }
            db_dml insert {}
        }
    }

    set result \
       [expr {[info exists keys(cmi_node_id)] ? [list $cp_node_id $keys(cmi_node_id)] : {}}]

    return [util::json::gen [util::json::object::create $result]]

}
