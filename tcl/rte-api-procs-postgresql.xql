<?xml version="1.0"?>
<queryset>
  <rdbms><type>postgresql</type><version>8.3</version></rdbms>

  <fullquery name="scorm_player::rte_api::suspend_POST.update">      
    <querytext>
      update cp_suspend
      set data = :data
      where cp_package_id = :id
        and user_id = :user_id
    </querytext>
  </fullquery>

  <fullquery name="scorm_player::rte_api::suspend_POST.insert">      
    <querytext>
      insert into cp_suspend
        (cp_package_id, user_id, data)
      values
        (:id, :user_id, :data)
    </querytext>
  </fullquery>
</queryset>
