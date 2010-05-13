<?xml version="1.0"?>
<queryset>

  <fullquery name="check_id">
    <querytext>
      select 1
      from dual
      where exists (select 1
                    from scorm_courses
                    where scorm_course_id = :id)
    </querytext>
  </fullquery>

</queryset>
