      select default_lesson_mode, auto_review, credit,
      case
        when auto_review
        then 'true'
        else 'false'
      end as auto_review
      from scorm_courses
      where scorm_course_id = 3
