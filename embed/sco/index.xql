<?xml version="1.0"?>

<queryset>
  <fullquery name="get_folder_id">
    <querytext>
      select folder_id
      from scorm_courses
      where scorm_course_id = :id
    </querytext>
  </fullquery>

</queryset>

