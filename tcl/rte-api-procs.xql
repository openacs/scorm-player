<?xml version="1.0"?>
<queryset>

  <fullquery name="scorm_player::rte_api::cp_GET.get_jsdata">      
    <querytext>
      select jsdata
      from cp_package
      where cp_package_id = :id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::adlact_GET.get_activitytree">      
    <querytext>
      select activitytree
      from cp_package
      where cp_package_id = :id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::suspend_POST.exists">      
    <querytext>
      select 1
      from dual
      where exists (select 1
                    from cp_suspend
                    where cp_package_id = :id
                      and user_id = :user_id)
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::getSuspend_GET.get_suspend_data">      
    <querytext>
      select data
      from cp_suspend
      where cp_package_id = :id
        and user_id = :user_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::getSuspend_GET.delete_suspend_data">      
    <querytext>
      delete from cp_suspend
      where cp_package_id = :id
        and user_id = :user_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::gobjective_POST.exists">      
    <querytext>
      select 1
      from dual
      where exists (select 1
                    from cmi_gobjective
                    where objective_id = :objective_id
                      and user_id = :user_id
                      and scope_id = :scope_id)
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::gobjective_POST.update_satisfied">      
    <querytext>
      update cmi_gobjective
      set satisfied = :value,
        c_timestamp = current_timestamp
      where objective_id = :objective_id 
        and user_id = :user_id
        and scope_id = :scope_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::gobjective_POST.update_measured">      
    <querytext>
      update cmi_gobjective
      set measure = :value,
        c_timestamp = current_timestamp
      where objective_id = :objective_id 
        and user_id = :user_id
        and scope_id = :scope_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::gobjective_POST.update_status">      
    <querytext>
      update cmi_gobjective
      set measure = :measure,
        satisfied = :satisfied,
        status = :completed,
        c_timestamp = current_timestamp
      where objective_id = :objective_id 
        and user_id = :user_id
        and scope_id = :scope_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::gobjective_POST.insert_satisfied">      
    <querytext>
      insert into cmi_gobjective
        (objective_id, user_id, satisfied, scope_id, c_timestamp) 
      values
        (:objective_id, :user_id, :value, :scope_id, current_timestamp)
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::gobjective_POST.insert_measured">      
    <querytext>
      insert into cmi_gobjective
        (objective_id, user_id, measure, scope_id, c_timestamp) 
      values
        (:objective_id, :user_id, :value, :scope_id, current_timestamp)
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::gobjective_POST.insert_status">      
    <querytext>
      insert into cmi_gobjective
        (objective_id, user_id, measure, satisfied, status, scope_id) 
      values
        (:objective_id, :user_id, :measure, :satisfied, :completed, :scope_id)
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::getGobjective_GET.gobjectives">
    <querytext>
      select objective_id, scope_id, satisfied, measure, user_id
      from cmi_gobjective, cp_node, cp_mapinfo
      where cmi_gobjective.objective_id <> '-course_overall_status-'
        and cmi_gobjective.status is null
        and cp_node.cp_package_id = :id
        and cp_node.nodename = 'mapInfo'
        and cp_node.cp_node_id = cp_mapinfo.cp_node_id
        and cmi_gobjective.objective_id = cp_mapinfo.targetobjectiveid
      group by objective_id, scope_id, satisfied, measure, user_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_GET.node">      
    <querytext>
      select $select_attributes
      from cmi_node 
        inner join cp_node using (cp_node_id)
      where cmi_node.user_id = :user_id
        and cp_node.cp_package_id = :id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_GET.comment">      
    <querytext>
      select $select_attributes
      from cmi_comment 
        inner join cmi_node using (cmi_node_id)
        inner join cp_node using (cp_node_id)
      where cmi_node.user_id = :user_id
        and cp_node.cp_package_id = :id;
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_GET.correct_response">      
    <querytext>
      select $select_attributes
      from cmi_correct_response 
        inner join cmi_interaction using (cmi_interaction_id)
        inner join cmi_node using (cmi_node_id)
        inner join cp_node using (cp_node_id)
      where cmi_node.user_id = :user_id
        and cp_node.cp_package_id = :id;
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_GET.interaction">      
    <querytext>
      select $select_attributes
      from cmi_interaction 
        inner join cmi_node using (cmi_node_id)
        inner join cp_node using (cp_node_id)
      where cmi_node.user_id = :user_id
        and cp_node.cp_package_id = :id;
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_GET.objective">      
    <querytext>
      select $select_attributes
      from cmi_objective 
        inner join cmi_node using (cmi_node_id)
        inner join cp_node using (cp_node_id)
      where cmi_node.user_id = :user_id
        and cp_node.cp_package_id = :id;
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_GET.package">      
    <querytext>
      select :user_id as user_id, 
        persons.first_names || ' ' || persons.last_name as learner_name, 
        scorm_courses.scorm_course_id, scorm_courses.default_lesson_mode as mode,
        scorm_courses.credit
      from persons, cp_package
        inner join scorm_courses ON cp_package.cp_package_id = scorm_courses.scorm_course_id 
      where persons.person_id = :user_id
        and scorm_courses.scorm_course_id = :id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_POST.get_lesson_mode">      
    <querytext>
      select default_lesson_mode
      from scorm_courses
      where scorm_course_id = :id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_POST.now">      
    <querytext>
      select current_timestamp
      from dual
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_POST.check_cp_node_id">      
    <querytext>
      select 1
      from dual
      where exists (select 1
                    from cp_node
                    where cp_node_id = :cp_node_id
                      and cp_package_id = :id)
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::cmi_POST.insert">      
    <querytext>
      insert into cmi_$table
        ([join $insert_attributes ,])
      values
        ([join $fixed_data_row ,])
    </querytext>
  </fullquery>
			
</queryset>
