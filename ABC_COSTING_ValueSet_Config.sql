The following are the steps to set up the Costing FF Value Sets to get the GL segments from the projectId and taskId.
This is used in Costing FF: Setup and maintenance/search/Fast Formulas/ABC_OTL_COST_OVERRIDE


0. Setup and maintenance/search/Manage Value Sets.

1. 
Value Set code/Description: ABC_COSTING_BUDGETCODE_SEGMENT
Module: Global Payroll
Validation Type: Table
Value Data Type: Character  
FROM Clause: pjf_projects_all_b p, pjf_proj_elements_b t, PJF_TASKS_V pt
Value Column Name/ID Column Name  : t.attribute3
WHERE Clause: 
 p.project_id = t.project_id
 and t.object_type = 'PJF_TASKS'
 and p.project_id = :{PARAMETER.P_PROJECT_ID}
 and pt.task_id = :{PARAMETER.P_TASK_ID}
 and t.element_number = pt.task_number

2.
Value Set code/Description: ABC_COSTING_ACTIVITYTYPE_SEGMENT
Module: Global Payroll
Validation Type: Table
Value Data Type: Character  
FROM Clause: pjf_projects_all_b p, pjf_proj_elements_b t, PJF_TASKS_V pt
Value Column Name/ID Column Name  : t.attribute5
WHERE Clause: 
 p.project_id = t.project_id
 and t.object_type = 'PJF_TASKS'
 and p.project_id = :{PARAMETER.P_PROJECT_ID}
 and pt.task_id = :{PARAMETER.P_TASK_ID}
 and t.element_number = pt.task_number

3.
Value Set code/Description: ABC_COSTING_COSTCENTER_SEGMENT
Module: Global Payroll
Validation Type: Table
Value Data Type: Character  
FROM Clause: pjf_projects_all_b p, pjf_proj_elements_b t, PJF_TASKS_V pt
Value Column Name/ID Column Name  : t.attribute2
WHERE Clause: 
 p.project_id = t.project_id
 and t.object_type = 'PJF_TASKS'
 and p.project_id = :{PARAMETER.P_PROJECT_ID}
 and pt.task_id = :{PARAMETER.P_TASK_ID}
 and t.element_number = pt.task_number

4.
Value Set code/Description: ABC_COSTING_FERC_SEGMENT
Module: Global Payroll
Validation Type: Table
Value Data Type: Character  
FROM Clause: pjf_projects_all_b p, pjf_proj_elements_b t, PJF_TASKS_V pt
Value Column Name/ID Column Name  : t.attribute4
WHERE Clause: 
 p.project_id = t.project_id
 and t.object_type = 'PJF_TASKS'
 and p.project_id = :{PARAMETER.P_PROJECT_ID}
 and pt.task_id = :{PARAMETER.P_TASK_ID}
 and t.element_number = pt.task_number

5.
Value Set code/Description: ABC_COSTING_FUND_SEGMENT
Module: Global Payroll
Validation Type: Table
Value Data Type: Character  
FROM Clause: pjf_projects_all_b p, pjf_proj_elements_b t, PJF_TASKS_V pt
Value Column Name/ID Column Name  : t.attribute1
WHERE Clause: 
 p.project_id = t.project_id
 and t.object_type = 'PJF_TASKS'
 and p.project_id = :{PARAMETER.P_PROJECT_ID}
 and pt.task_id = :{PARAMETER.P_TASK_ID}
 and t.element_number = pt.task_number

6.
Value Set code/Description: ABC_COSTING_GLPROJECT_SEGMENT
Module: Global Payroll
Validation Type: Table
Value Data Type: Character  
FROM Clause: pjf_projects_all_b p, pjf_proj_elements_b t, PJF_TASKS_V pt
Value Column Name/ID Column Name  : t.attribute6
WHERE Clause: 
 p.project_id = t.project_id
 and t.object_type = 'PJF_TASKS'
 and p.project_id = :{PARAMETER.P_PROJECT_ID}
 and pt.task_id = :{PARAMETER.P_TASK_ID}
 and t.element_number = pt.task_number