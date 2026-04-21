/*SQL Query to get Payroll Earnings Run Result and Cost Segement Values from Specific Payroll Period
-----------------------------------------------------------------------------------------------------
Parameters Example:
P_PAY_START_DATE: 2026/03/14 (Payroll Pay Period Start Date)
P_PAY_END_DATE: 2026/03/27 (Payroll Pay Period End Date)
P_PAY_DATE: 2026/04/03 (Payroll Pay Period Process Date)

*/

WITH Time_Unit AS
(Select 
Pri.VALUE1,
pee.creator_id
from
pay_range_items_f pri,
pay_value_definitions_f vd,
pay_dir_override_usages_f dou,
pay_allow_overrides_vl aor,
pay_value_definitions_vl vdl,
PAY_DIR_CARD_COMPONENTS_F pdcc,
PAY_DIR_CARD_DEFINITIONS_vl pdcd,
pay_dir_card_comp_defs_vl pdccd,
pay_dir_cards_f pdcf,
PAY_ELEMENT_ENTRIES_F pee
where 
pri.value_defn_id = vd.value_defn_id
AND vd.dir_override_usage_id = dou.dir_override_usage_id
AND dou.allow_overrides_id = aor.allow_overrides_id
AND vd.parent_value_defn_id = vdl.value_defn_id
AND vdl.base_name = 'Time Unit'
AND vd.source_type = 'PDCC'
AND vd.source_id = pdcc.DIR_CARD_COMP_ID
AND pdccd.dir_card_comp_def_id = pdcc.dir_card_comp_def_id
AND pdccd.dir_card_definition_id = pdcd.dir_card_definition_id
AND pdcd.base_display_name = 'Time Cards'
AND pdcc.dir_card_id = pdcf.dir_card_id
AND pee.element_type_id = pdccd.element_type_id
AND pee.creator_id = pdcc.DIR_CARD_COMP_ID
AND pee.creator_type = 'DIR_COMP')

,Payroll_Run_Result AS
(
SELECT 
prrv.INPUT_VALUE_ID,
prrv.RUN_RESULT_ID,
pettl.element_name AS RUN_RESULT_ELEMENT_NAME,
prrv.result_value AS ELEMENT_ENTRY_ID
FROM pay_payroll_actions ppa,
pay_all_payrolls_f payf,
pay_payroll_rel_actions ppra,
pay_run_results prr,
pay_run_result_values prrv,
pay_element_types_f petf,
pay_element_types_tl pettl,
pay_ele_classifications pec,
pay_input_values_f pivf,
pay_payroll_assignments ppasg,
per_all_assignments_f paaf,
per_all_people_f papf,
per_person_names_f ppnf
WHERE ppra.retro_component_id IS NULL
AND ppa.payroll_action_id = ppra.payroll_action_id
AND ppa.payroll_id = payf.payroll_id
AND ppra.payroll_rel_action_id = prr.payroll_rel_action_id
AND prr.run_result_id = prrv.run_result_id
AND prr.element_type_id = petf.element_type_id
AND petf.element_type_id = pivf.element_type_id
AND petf.classification_id = pec.classification_id
AND pettl.element_type_id = petf.element_type_id
AND pettl.language = 'US'
AND pec.base_classification_name = 'Standard Earnings'
AND pettl.element_name IN ('RG REGULAR Earnings Results','O OVERTIME Earnings Results','SP STANDBY PAY Earnings Results','VC VEH CALL OUT Earnings Results','H HOLIDAY Earnings Results','HO HOLIDAY OVERTIME Earnings Results')
AND pivf.input_value_id = prrv.input_value_id
AND ppasg.payroll_relationship_id = ppra.payroll_relationship_id
AND paaf.assignment_id = ppasg.hr_assignment_id
AND paaf.person_id = papf.person_id
AND papf.person_id = ppnf.person_id
AND pivf.BASE_NAME = 'RefCode'
AND ppa.action_type IN ('R','Q') -- 'R' for Payroll Run, which includes Calculate Payroll
AND ppa.action_status = 'C' -- 'C' for Completed
AND TO_CHAR(ppa.effective_date,'YYYY/MM/DD') = :P_PAY_DATE
AND SYSDATE BETWEEN paaf.effective_start_date AND paaf.effective_end_date
AND SYSDATE BETWEEN papf.effective_start_date AND papf.effective_end_date
AND SYSDATE BETWEEN ppnf.effective_start_date AND ppnf.effective_end_date
AND ppnf.name_type = 'GLOBAL'
)
,Cost_Center_From_Department AS
(
Select
papf.person_id,
t4.org_information1 as COST_CENTER_FROM_DEPT
FROM
hr_all_organization_units_f t1,
hr_organization_units_f_tl t2,
hr_org_unit_classifications_f t3,
hr_organization_information t4,
per_all_assignments_m paam,
per_all_people_f papf
Where t1.organization_id = t2.organization_id
AND t2.organization_id = t3.organization_id
AND t3.organization_id = t4.organization_id
AND t2.LANGUAGE = 'US'
AND t3.CLASSIFICATION_CODE = 'DEPARTMENT'  
AND t4.org_information_context = 'PER_GL_COST_CENTER_INFO'
AND papf.person_id = paam.person_id        
and paam.primary_assignment_flag='Y'
and paam.assignment_type='E'
AND paam.organization_id = t2.organization_id 
AND TO_DATE(:P_PAY_DATE,'YYYY/MM/DD') BETWEEN papf.effective_start_date AND papf.effective_end_date
AND TO_DATE(:P_PAY_DATE,'YYYY/MM/DD') BETWEEN paam.effective_start_date AND paam.effective_end_date
AND TO_DATE(:P_PAY_DATE,'YYYY/MM/DD') BETWEEN T3.effective_start_date AND T3.effective_end_date
AND TO_DATE(:P_PAY_DATE,'YYYY/MM/DD') BETWEEN T1.effective_start_date AND T1.effective_end_date      
AND TO_DATE(:P_PAY_DATE,'YYYY/MM/DD') BETWEEN T2.effective_start_date AND T2.effective_end_date
)

SELECT DISTINCT
PAPF.PERSON_NUMBER "EMPLOYEE NUMBER",
PETF.BASE_ELEMENT_NAME "BASE ELEMENT NAME",
PAAM.ASSIGNMENT_NUMBER,
pprd.payroll_relationship_number,
TO_CHAR(PEEF.EFFECTIVE_START_DATE,'YYYY/MM/DD') "ELEMENT START DATE",
PEEF.EFFECTIVE_START_DATE START_DATE,
TO_CHAR(PEEF.EFFECTIVE_END_DATE,'YYYY/MM/DD') "ELEMENT END DATE",
PEEF.ELEMENT_TYPE_ID,
PEEF.ELEMENT_ENTRY_ID,
PEEF.CREATOR_TYPE,
PEEF.CREATOR_ID,
PEEF.MULTIPLE_ENTRY_COUNT,
TO_CHAR(PEEF.CREATION_DATE,'YYYY/MM/DD') "CREATION DATE",
ETL.ELEMENT_NAME "ELEMENT NAME",
PRR.RUN_RESULT_ID,
PRR.RUN_RESULT_ELEMENT_NAME,
PRRV.result_value AS AMOUNT,
round(TU.VALUE1,1) AS TIME_UNIT,
CAA.SEGMENT1 AS FUND,
CAA.SEGMENT2 AS COST_CENTER,
CAA.SEGMENT3 AS COST_TYPE,
CAA.SEGMENT4 AS GL_PROJECT,
CAA.SEGMENT5 AS ACTIVITY_TYPE,
CAA.SEGMENT6 AS FERC,
CAA.SEGMENT7 AS BUDGET_CODE,
CCFD.COST_CENTER_FROM_DEPT,
PAPF.PERSON_NUMBER||'_'||TO_CHAR(PEEF.EFFECTIVE_START_DATE,'YYYYMMDD')||'_'||ETL.ELEMENT_NAME||'_'||ROUND(TU.VALUE1,1) AS UNIQUE_ID,
DENSE_RANK() OVER (
    PARTITION BY PERSON_NUMBER, TO_CHAR(PEEF.EFFECTIVE_START_DATE,'YYYYMMDD')
    ORDER BY TO_CHAR(PEEF.EFFECTIVE_START_DATE,'YYYYMMDD'),ROUND(TU.VALUE1,1),PEEF.ELEMENT_ENTRY_ID
  ) AS SEQ_IN_DAY,
PAPF.PERSON_NUMBER||'_'||TO_CHAR(PEEF.EFFECTIVE_START_DATE,'YYYYMMDD')||'_'||ETL.ELEMENT_NAME||'_'||ROUND(TU.VALUE1,1)||'_'||DENSE_RANK() OVER (
    PARTITION BY PERSON_NUMBER, TO_CHAR(PEEF.EFFECTIVE_START_DATE,'YYYYMMDD')
    ORDER BY TO_CHAR(PEEF.EFFECTIVE_START_DATE,'YYYYMMDD'),ROUND(TU.VALUE1,1),PEEF.ELEMENT_ENTRY_ID
  ) AS LINK
FROM
PAY_ELEMENT_TYPES_F PETF,
PAY_ELEMENT_ENTRIES_F PEEF,
PER_ALL_ASSIGNMENTS_M PAAM,
PER_ALL_PEOPLE_F PAPF,
PAY_ELEMENT_TYPES_TL ETL,
pay_pay_relationships_dn pprd,
PAY_ENTRY_USAGES peu,
Time_Unit TU,
Payroll_Run_Result PRR,
Cost_Center_From_Department CCFD,
PAY_RUN_RESULT_VALUES PRRV,
pay_input_values_f PIVF,
PAY_COST_ALLOCATIONS_F PCA,
PAY_COST_ALLOC_ACCOUNTS CAA

WHERE 1 = 1
AND PEEF.ELEMENT_TYPE_ID(+) = PETF.ELEMENT_TYPE_ID
AND PAAM.PERSON_ID = PEEF.PERSON_ID(+)
AND PAAM.PRIMARY_FLAG = 'Y'
AND PAAM.ASSIGNMENT_TYPE = 'E'

AND PAPF.PERSON_ID = PAAM.PERSON_ID
AND PAPF.PERSON_ID = pprd.PERSON_ID
AND PEEF.ELEMENT_ENTRY_ID = peu.ELEMENT_ENTRY_ID
AND peu.PAYROLL_RELATIONSHIP_ID = pprd.payroll_relationship_id

AND TU.CREATOR_ID = PEEF.CREATOR_ID

AND PEEF.ELEMENT_ENTRY_ID = PRR.ELEMENT_ENTRY_ID
AND PRRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
AND PIVF.input_value_id  = PRRV.input_value_id
AND PIVF.BASE_NAME = 'Earnings Calculated'

AND CCFD.PERSON_ID = PAPF.PERSON_ID

AND CAA.SOURCE_SUB_TYPE = 'COST'
AND PCA.COST_ALLOCATION_RECORD_ID = CAA.COST_ALLOCATION_RECORD_ID
AND PCA.SOURCE_ID = PEEF.ELEMENT_ENTRY_ID(+)

AND PEEF.ELEMENT_TYPE_ID(+) = PETF.ELEMENT_TYPE_ID
AND PETF.ELEMENT_TYPE_ID = ETL.ELEMENT_TYPE_ID
AND ETL.LANGUAGE = 'US'

AND TRUNC(PEEF.EFFECTIVE_START_DATE) = TRUNC(PEEF.EFFECTIVE_END_DATE)
AND TO_CHAR(PEEF.EFFECTIVE_START_DATE(+),'YYYY/MM/DD') BETWEEN TO_DATE(:P_PAY_START_DATE,'YYYY/MM/DD') AND TO_DATE(:P_PAY_END_DATE,'YYYY/MM/DD')

AND TRUNC(SYSDATE) BETWEEN PAAM.EFFECTIVE_START_DATE AND PAAM.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN PETF.EFFECTIVE_START_DATE AND PETF.EFFECTIVE_END_DATE
AND TRUNC(SYSDATE) BETWEEN pprd.START_DATE AND pprd.END_DATE

ORDER BY PAPF.PERSON_NUMBER,PEEF.EFFECTIVE_START_DATE,ETL.ELEMENT_NAME,SEQ_IN_DAY