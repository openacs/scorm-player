<?xml version="1.0"?>
<queryset>

  <fullquery name="scorm_player::delete_all_cmi_data.delete">
    <querytext>
      delete from cmi_node
      where cp_node_id in (select cp_node_id
                           from cp_node
                           where cp_package_id = :id)
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::delete_cmi_data.delete">
    <querytext>
      delete from cmi_node
      where cp_node_id = :cp_node_id
        and user_id = :user_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::get_scorm_init_args.course_info">
    <querytext>
      select sc.default_lesson_mode, sc.auto_review, sc.credit,
      case
        when sc.auto_review
        then 'true'
        else 'false'
      end as auto_review,
      cp.global_to_system
      from scorm_courses sc, cp_package cp
      where sc.scorm_course_id = :id
        and cp.cp_package_id = sc.scorm_course_id
    </querytext>
  </fullquery>
			
</queryset>
