ad_library {

    Initialize the scheme used to control communication between the RTE and the back-end
    datamodel that implements persistent storage for SCORM courses.

    This is based on the schema implemented by ilias, and is mapped directly into
    the JSON string representation required by the RTE, so should not be changed
    unless you are absolutely sure you know what you're doing (for instance, adding
    implementation-specific stuff or tracking changes to ilias).

    @creation-date 2010/04/09
    @author Don Baccus
    @cvs-id $Id$
}

# Should probably be in scorm-core ...

# The order of attributes in the schema is important, as they're passed to the RTE as
# a JSON array of arrays of values rather than key-value pairs (same as a db_list_of_lists).
# This isn't the most robust representation imaginable, but I'm keeping it because we want
# to use the ilias RTE unchanged if at all possible.

# Note that package is treated as a special case in the GET/POST_cmi procs.  The other
# tables are all cmi tables and the query resultsets are generated automatically from
# the schema definition declared here.  Table order is important.  Don't change it
# unless you understand why it's important (hint: look at the dependencies generated
# by foreign key references).

# Each attribute is described by an attribute name and optional modifier.  The modifiers
# are only significant for cmi_POST, and have the following semantics:

# (none):
#     Read-only column, do not include in automatically-generated INSERT statements.
#     This provides a small degree of protection against rogue JS calls to the RTE.
# W
#     Writable column which is inserted as is.  The JSON values false and true are
#     mapped to 0 an 1 respectively, null remains null, and other values are passed
#     as strings after being DoubleApos'd.
# KEY
#     Denotes the primary key of the table.  This is filled in with the next value
#     of the acs object sequence (they're not objects, but there's no reason to use
#     a dedicated sequence for these things).
# KEYREF
#     Denotes a reference to a primary key of a previously encountered table.  The
#     value in this column is replaced with the new primary key of the referenced
#     table if it has been defined in this call to cmi_POST, NULL otherwise.  Foreign
#     key references to all cmi keys other than cmi_node_id should not be marked
#     not null.
# USERREF
#     This is replaced with the user_id parameter to the cmi_POST function.  When
#     called from the player's dispatch script, it will be set to the current user's
#     id.
# LEARNERNAMEREF
#     This is replaced by the name for the user referenced by cmi_POST's user_id
#     parameter.
# TIMESTAMP
#     This is replaced by the database's current timestamp.
# CPNODEREF
#     This only occurs in the node table description, as all other tables associated
#     with automatic cmi_GET/POST operations have foreign keys to the cmi_node entry
#     for (cp_node_id, user_id).  When encountered, previous cmi data for this
#     cp_node/user pair is deleted.  Some minimal protection against rogue JS RTE
#     calls is provided by ensuring that the given cp_node_id exists for the
#     current course.

nsv_set scorm_schema tables \
    {package node comment interaction objective correct_response}

nsv_set scorm_schema package_table {user_id learner_name cp_package_id mode credit}

nsv_set scorm_schema node_table \
    {{accesscount W} {accessduration W} {accessed W} {activityAbsoluteDuration W}
     {activityAttemptCount W} {activityExperiencedDuration W} {activityProgressStatus W}
     {attemptAbsoluteDuration W} {attemptCompletionAmount W} {attemptCompletionStatus W}
     {attemptExperiencedDuration W} {attemptProgressStatus W} {audio_captioning W}
     {audio_level W} {availableChildren W} {cmi_node_id KEY} {completion W}
     {completion_status W} {completion_threshold W} {cp_node_id CPNODEREF} {created W}
     {credit W} {delivery_speed W} {entry W} {exit W} {language W} {launch_data W}
     {learner_name LEARNERNAMEREF} {location W} {max W} {min W} {mode W} {modified W}
     {progress_measure W} {raw W} {scaled W} {scaled_passing_score W} {session_time W}
     {success_status W} {suspend_data W} {total_time W} {user_id USERREF} {timestamp TIMESTAMP}}

nsv_set scorm_schema comment_table \
    {{cmi_comment_id KEY} {cmi_node_id KEYREF} {comment W} {timestamp TIMESTAMP} {location W}
     {sourceIsLMS W}}

nsv_set scorm_schema interaction_table \
    {{cmi_interaction_id KEY} {cmi_node_id KEYREF} {description W} {id W} {latency W}
     {learner_response W} {result W} {timestamp TIMESTAMP} {type W} {weighting W}}

nsv_set scorm_schema objective_table \
    {{cmi_objective_id KEY} {cmi_node_id KEYREF} {cmi_interaction_id KEYREF}
     {completion_status W} {description W} {id W} {max W} {min W} {raw W} {scaled W}
     {progress_measure W} {success_status W} {scope W}}

nsv_set scorm_schema correct_response_table \
    {{cmi_correct_response_id KEY} {cmi_interaction_id KEYREF} {pattern W}}

# We could use the RTE special page value directly as a message key.  However, ilias
# conveniently provides translations for these messages in several languages, using
# the mapped message key, and doing the mapping will simplify the process of incorporating
# their translations into our player.

nsv_array set scorm_special_pages \
  {_COURSECOMPLETE_ seq_coursecomplete
   _ENDSESSION_ seq_endsession
   _SEQBLOCKED_ seq_blocked
   _NOTHING_ seq_nothing
   _ERROR_ seq_error
   _DEADLOCK_ seq_deadlock
   _INVALIDNAVREQ_ seq_invalidnavreq
   _SEQABANDON_ seq_abandon
   _SEQABANDONALL_ seq_abandonall
   _TOC_ seq_toc}

