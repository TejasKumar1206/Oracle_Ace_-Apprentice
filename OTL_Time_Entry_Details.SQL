SQL Query to get Time Entry Details based on OTL Period Start date and End Date
-------------------------------------------------------------------------------
with payroll
     AS (SELECT ppa.hr_assignment_id,
                ppa.hr_term_id,
                papd.payroll_id
         FROM   pay_assigned_payrolls_dn papd,
                pay_payroll_assignments ppa,
                pay_pay_relationships_dn pprd
         WHERE  ppa.payroll_term_id = papd.payroll_term_id(+)
                AND pprd.payroll_relationship_id = ppa.payroll_relationship_id
                AND SYSDATE BETWEEN ppa.start_date AND ppa.end_date
                AND SYSDATE BETWEEN pprd.start_date AND pprd.end_date
                AND SYSDATE BETWEEN papd.start_date AND papd.end_date)
SELECT *
    FROM (
     SELECT DISTINCT To_char(dtl.start_time, 'MM/DD/YYYY')      START_TIME,
                        dtl.start_time                             st,
                        person_number,
                        ppnf.first_name,
                        ppnf.last_name,
                        middle_names,
                        dtl.stop_time,
                        dtl.resource_id,
                        --dtl.measure,
                        round(dtl.measure,1) measure,
                        (SELECT project_number  FROM   hwm_ext_attrb_detail_v atr ,pjc_projects_ccw_v prj
                         WHERE  attribute_category = 'Projects'
                          AND layer_code = 'TIME_RPTD'
                          AND grp_type_name = 'Processed TimecardDay' 
                          AND prj.project_id = atr.attribute_number1
                          AND atr.tm_rec_id = dtl.tm_rec_id ) Projects, 
                        (SELECT task_number  FROM   hwm_ext_attrb_detail_v atr ,pjc_tasks_ccw_v tsk
                         WHERE  attribute_category = 'Projects'
                          AND layer_code = 'TIME_RPTD'
                          AND grp_type_name = 'Processed TimecardDay' 
                          AND tsk.project_id = atr.attribute_number1
                          AND tsk.task_id = atr.attribute_number2
                          AND atr.tm_rec_id = dtl.tm_rec_id ) Task,   
                        dtl.tm_rec_id,
                        To_char(dtl.creation_date, 'MM/DD/YYYY')   CREATION_DATE   ,
                        dtl.last_updated_by,
                        To_char(dtl.last_update_date, 'MM/DD/YYYY')  LAST_UPDATE_DATE,
                        atr.attribute_category,
                        CASE
                          WHEN aatl.name IS NULL THEN atr.attribute_category
                          ELSE aatl.name
                        END                                        AS time_type,
                        To_char(ptp.start_date, 'MM/DD/YYYY')      start_date,
                        To_char(ptp.end_date, 'MM/DD/YYYY')        end_date,
                        To_char(ptp.end_date, 'YYYYMMDD')          batch
        FROM   hwm_ext_timecard_detail_v dtl,
               per_all_people_f papf,
               per_person_names_f ppnf,
               hwm_ext_attrb_detail_v atr,
               anc_absence_types_f_tl aatl,
               per_all_assignments_f paaf,
               pay_time_periods ptp,
               per_job_leg_f pjfl,
               payroll
        WHERE  dtl.layer_code = 'TIME_RPTD'
               AND dtl.latest_version = 'Y'
               AND Trunc(SYSDATE) BETWEEN Trunc (dtl.date_from) AND
                                          Trunc (dtl.date_to)
               AND papf.person_id = dtl.resource_id
               AND paaf.person_id = papf.person_id
               AND ppnf.person_id = papf.person_id
               AND name_type = 'GLOBAL'
               AND paaf.assignment_status_type = 'ACTIVE'
               AND assignment_type = 'E'
               AND paaf.primary_flag = 'Y'
               AND pjfl.job_id(+) = paaf.job_id
               AND Trim(information_category(+)) = 'HRX_US_JOBS'
                  AND  SYSDATE BETWEEN pjfl.effective_start_date(+) AND pjfl.effective_end_date(+)
                  
               AND SYSDATE BETWEEN paaf.effective_start_date AND
                                   paaf.effective_end_date
               AND SYSDATE BETWEEN ppnf.effective_start_date AND
                                   ppnf.effective_end_date

               AND SYSDATE BETWEEN papf.effective_start_date AND
                                   papf.effective_end_date
               AND dtl.grp_type_name = 'Processed TimecardDay'
               AND dtl.start_time between :P_start_date and :P_end_date
               AND atr.tm_rec_id = dtl.tm_rec_id
               AND atr.resource_id = dtl.resource_id
               AND payroll.hr_assignment_id = paaf.assignment_id
               AND payroll.hr_term_id = paaf.work_terms_assignment_id
               AND payroll.payroll_id = ptp.payroll_id
               AND dtl.start_time BETWEEN ptp.start_date AND ptp.end_date
               AND atr.attribute_category NOT IN ('Projects',
                   'Security Attributes', 'CommonAttributes',
                   'ORA_CUSTOM', 'Schedules', 'HXT','AbsenceTimeEntryParams' )
               AND To_char(aatl.absence_type_id(+)) =
                   To_char(atr.attribute_category)
               AND aatl.LANGUAGE(+) = 'US'
       and    CASE
                          WHEN aatl.name IS NULL THEN atr.attribute_category
                          ELSE aatl.name
                        END      not in ('EXCUSED NO PAY 95',
'FH Floating Holiday',
'V VACATION',
'FS FMLA SICK',
'S SICK',
'WORKERS COMP',
'FMLA NO PAY 90',
'FV FMLA VACATION',
'FUNERAL LEAVE 15',
'SICK NO PAY 91'
)
       UNION
       SELECT DISTINCT To_char(dtl.start_time, 'MM/DD/YYYY')      START_TIME,
                        dtl.start_time                             st,
                        person_number,
                        ppnf.first_name,
                        ppnf.last_name,
                        middle_names,
                        dtl.stop_time,
                        dtl.resource_id,
                        --dtl.measure,
                        round(dtl.measure,1) measure,
                        (SELECT project_number  FROM   hwm_ext_attrb_detail_v atr ,pjc_projects_ccw_v prj
                         WHERE  attribute_category = 'Projects'
                          AND layer_code = 'TIME_RPTD'
                          AND grp_type_name = 'Processed TimecardDay' 
                          AND prj.project_id = atr.attribute_number1
                          AND atr.tm_rec_id = dtl.tm_rec_id ) Projects, 
                        (SELECT task_number  FROM   hwm_ext_attrb_detail_v atr ,pjc_tasks_ccw_v tsk
                         WHERE  attribute_category = 'Projects'
                          AND layer_code = 'TIME_RPTD'
                          AND grp_type_name = 'Processed TimecardDay' 
                          AND tsk.project_id = atr.attribute_number1
                          AND tsk.task_id = atr.attribute_number2
                          AND atr.tm_rec_id = dtl.tm_rec_id ) Task,   
                        dtl.tm_rec_id,
                        To_char(dtl.creation_date, 'MM/DD/YYYY')   CREATION_DATE  ,
                        dtl.last_updated_by,
                        To_char(dtl.last_update_date, 'MM/DD/YYYY')   LAST_UPDATE_DATE,
                        atr.attribute_category,
                        CASE
                          WHEN aatl.name IS NULL THEN atr.attribute_category
                          ELSE aatl.name
                        END                                        AS time_type,
                        To_char(ptp.start_date, 'MM/DD/YYYY')      start_date,
                        To_char(ptp.end_date, 'MM/DD/YYYY')        end_date,
                        To_char(ptp.end_date, 'YYYYMMDD')          batch
        FROM   hwm_ext_timecard_detail_v dtl,
               per_all_people_f papf,
               per_person_names_f ppnf,
               hwm_ext_attrb_detail_v atr,
               anc_absence_types_f_tl aatl,
               per_all_assignments_f paaf,
               pay_time_periods ptp,
               payroll,
               per_job_leg_f pjfl
        WHERE  dtl.layer_code IN ( 'ABSENCES' )
               AND papf.person_id = dtl.resource_id
               AND paaf.person_id = papf.person_id
               AND ppnf.person_id = papf.person_id
               AND name_type = 'GLOBAL'
               AND paaf.assignment_status_type = 'ACTIVE'
               AND assignment_type = 'E'
               AND paaf.primary_flag = 'Y'
               AND pjfl.job_id(+) = paaf.job_id
               AND Trim(information_category(+)) = 'HRX_US_JOBS'
                  AND  SYSDATE BETWEEN pjfl.effective_start_date(+) AND pjfl.effective_end_date(+)
               AND SYSDATE BETWEEN paaf.effective_start_date AND
                                   paaf.effective_end_date
               AND SYSDATE BETWEEN ppnf.effective_start_date AND
                                   ppnf.effective_end_date

               AND SYSDATE BETWEEN papf.effective_start_date AND
                                   papf.effective_end_date

               AND dtl.grp_type_name IN (
                   'Absences Entry', 'Processed TimecardDay' )
               AND dtl.start_time BETWEEN :p_start_date AND :p_end_date
               AND atr.tm_rec_id = dtl.tm_rec_id
               AND atr.resource_id = dtl.resource_id
               AND payroll.hr_assignment_id = paaf.assignment_id
               AND payroll.hr_term_id = paaf.work_terms_assignment_id
               AND payroll.payroll_id = ptp.payroll_id
               AND dtl.start_time BETWEEN ptp.start_date AND ptp.end_date
               AND atr.attribute_category NOT IN ('Projects',
                   'Security Attributes', 'CommonAttributes',
                   'ORA_CUSTOM', 'Schedules', 'HXT','AbsenceTimeEntryParams' )
               AND To_char(aatl.absence_type_id(+)) =
                   To_char(atr.attribute_category)

               AND aatl.LANGUAGE(+) = 'US'
               AND dtl.latest_version = 'Y'
               AND Trunc(SYSDATE) BETWEEN Trunc (dtl.date_from) AND
                                          Trunc (dtl.date_to) 
         UNION ALL
        SELECT NULL START_TIME,
               NULL st,
               NULL person_number,
               NULL first_name,
               NULL last_name,
               NULL MIDDLE_NAMES,
               NULL stop_time,
               NULL resource_id,
               NULL measure,
               NULL Project,
               NULL Task,
               NULL tm_rec_id,
               NULL CREATION_DATE,
               NULL last_updated_by,
               NULL LAST_UPDATE_DATE,
               NULL attribute_category,
               NULL  time_type,
               NULL start_date,
               NULL end_date,
               NULL batch
        FROM   dual)
WHERE 
1=1
AND time_type <> 'FMLA'
ORDER BY person_number, st, time_type