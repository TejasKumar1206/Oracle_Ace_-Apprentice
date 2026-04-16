/* +======================================================================+
   |                Copyright (c) 2009 Oracle Corporation                 |
   |                   Redwood Shores, California, USA                    |
   |                        All rights reserved.                          |
   +======================================================================+
 *
 * Formula Name : ABC_OTL_COST_OVERRIDE
 
 * Formula Type:  Time Calculation rule
 
 * Description: 
 *  
 *  Change History
 *  --------------
 *
 *  Who               Ver      Date          Description
 *-----------------  ------   ------------  -----------------------------
 * Tejas Kumar M      1.0     17-APRIL-2026    Created. 

***************************************************************************/
DEFAULT FOR HWM_CTXARY_RECORD_POSITIONS   is  EMPTY_TEXT_NUMBER 
DEFAULT FOR HWM_CTXARY_HWM_MEASURE_DAY    is  EMPTY_NUMBER_NUMBER 
DEFAULT FOR HWM_CTXARY_SUBRESOURCE_ID     IS  EMPTY_NUMBER_NUMBER 
DEFAULT FOR measure  is  EMPTY_NUMBER_NUMBER 
DEFAULT FOR PayrollTimeType   is  EMPTY_TEXT_NUMBER 
DEFAULT FOR SubresourceId is  EMPTY_NUMBER_NUMBER
DEFAULT FOR CMP_ASSIGNMENT_SALARY_BASIS_NAME IS ' '
DEFAULT FOR ENDDAYDURATION IS EMPTY_NUMBER_NUMBER
DEFAULT FOR STARTDAYDURATION IS EMPTY_NUMBER_NUMBER
DEFAULT FOR StartTime   is  EMPTY_DATE_NUMBER
DEFAULT FOR StopTime   is  EMPTY_DATE_NUMBER
DEFAULT FOR PJC_TASK_ID is  EMPTY_NUMBER_NUMBER
DEFAULT FOR PJC_PROJECT_ID is  EMPTY_NUMBER_NUMBER
DEFAULT FOR ENTRY_LEVEL IS 'PA'

INPUTS ARE 
  HWM_CTXARY_RECORD_POSITIONS,
  HWM_CTXARY_HWM_MEASURE_DAY,
  measure,
  SubresourceId,
  PayrollTimeType,
  ENDDAYDURATION,
  STARTDAYDURATION,
  StartTime,
  StopTime,
  PJC_TASK_ID,
  PJC_PROJECT_ID

/*  Following 2 lines are required right after inputs for all OTL and HWM formulas */
ffs_id = GET_CONTEXT(HWM_FFS_ID, 0)
rule_id = GET_CONTEXT(HWM_RULE_ID, 0)  
ffName = 'ABC_OTL_COST_OVERRIDE'
rLog  = add_rlog (ffs_id, rule_id, '>>> Enter - ' || ffName  ) 
 
/* ----------- constant values   -------- */
/* ------------------------------------- */

/*Output Variables-Start*/

P_FUND = ' '
P_FUND_FROM_CC =' '
P_COSTCENTER= ' '
P_COSTTYPE = ' '
P_PROJECT = ' '
P_ACTIVITYTYPE = ' '
P_FERC = ' '
P_BUDGETCODE = ' '
L_ENTRY_LEVEL = ' '


L_FUND = EMPTY_TEXT_NUMBER

L_COSTCENTER = EMPTY_TEXT_NUMBER
L_COSTTYPE = EMPTY_TEXT_NUMBER
L_PROJECT = EMPTY_TEXT_NUMBER
L_ACTIVITYTYPE = EMPTY_TEXT_NUMBER
L_FERC = EMPTY_TEXT_NUMBER
L_BUDGETCODE = EMPTY_TEXT_NUMBER
L_SALARY_BASIS = ' '
L_PROJECT_TASK_PARAM = ' '
L_ENTRY_LEVEL = 'PA'

NullDate =  '01-JAN-1900'(DATE)  
NullDateTime = '1900/01/01 00:00:00' (date)   
NullText = '**FF_NULL**'

RecPositoinEoPeriod = 'END_PERIOD' 
RecPositoinEoDay = 'END_DAY' 
RecPositoinDetail = 'DETAIL'  

sumLvlTimeCard = 'TIMECARD'
sumLvlDay = 'DAY'
sumLvlDetail  = 'DETAIL'

TimeRecordType_MEASURE = 'MEASURE'
TimeRecordType_RANGE = 'RANGE'

/* ----------- Context value   -------- */
/* ------------------------------------ */
measure_period = GET_CONTEXT(HWM_MEASURE_PERIOD, 0)  


/* ----------- Rule Header parameters  -------- */
/* -------------------------------------------- */
hSumLvl= Get_Hdr_Text(rule_id, 'RUN_SUMMATION_LEVEL', 'TIMECARD') 
hExecType  = Get_Hdr_Text(rule_id,'RULE_EXEC_TYPE', 'CREATE')  

hCreateYn  = 'N' 
if (upper(hExecType) = 'CREATE'  ) then ( 
  hCreateYn  = 'Y' 
) 
  
 l_status = add_rlog (ffs_id , rule_id ,'Rule Header and Context:'  ||  
					 ' , ffs_id ='  ||  TO_CHAR( ffs_id ) ||   
					 ' , rule_id ='  ||  TO_CHAR( rule_id ) ||   
					 ' , measure_period='  ||  TO_CHAR( measure_period ) ||   
					 ' , hSumLvl='  ||   hSumLvl ||    
					 ' , hExecType='  ||   hExecType ||      
					 ' , hCreateYn='  ||   hCreateYn   )

/* ----------- Rule input parameters  -------- */
/* ------------------------------------------- */
pCategoryId  = get_rvalue_number (rule_id ,'WORKED_TIME_CONDITION', 0) 
pMaxHrs  = get_rvalue_number (rule_id ,'DEFINED_LIMIT', 0) 
   
l_status = add_rlog (ffs_id , rule_id , 'Rule Parameters: '   ||
			 ' , pMaxHrs='  ||  TO_CHAR( pMaxHrs ) || 
			 ' , pCategoryId ='  ||  TO_CHAR( pCategoryId )  ) 
/* ----------- Temp Workarea variables  -------- */
wMaAry = HWM_CTXARY_RECORD_POSITIONS.count   
rLog  = add_rlog (ffs_id, rule_id, 'Start bulk process - wMaAry=' || TO_CHAR( wMaAry )  )

L_DATE = '2020/01/01 00:00:00' (DATE)

/*l_current_date = GET_CURRENT_DATE()*/

L_HWM_CTX_SEARCH_START_DATE  = GET_CONTEXT(HWM_CTX_SEARCH_START_DATE,L_DATE)
L_HWM_CTX_SEARCH_END_DATE  = GET_CONTEXT(HWM_CTX_SEARCH_END_DATE, L_DATE)
L_HWM_SUBRESOURCE_ID  = GET_CONTEXT(HWM_SUBRESOURCE_ID, 0)
L_HWM_RESOURCE_ID  = GET_CONTEXT(HWM_RESOURCE_ID, 0)

rLog  = add_rlog (ffs_id, rule_id, ffName||' L_HWM_CTX_SEARCH_START_DATE => '|| TO_CHAR(L_HWM_CTX_SEARCH_START_DATE))
rLog  = add_rlog (ffs_id, rule_id, ffName||' L_HWM_CTX_SEARCH_END_DATE => '|| TO_CHAR(L_HWM_CTX_SEARCH_END_DATE))
rLog  = add_rlog (ffs_id, rule_id, ffName||' L_HWM_SUBRESOURCE_ID => '|| TO_CHAR(L_HWM_SUBRESOURCE_ID))
rLog  = add_rlog (ffs_id, rule_id, ffName||' L_HWM_RESOURCE_ID => '|| TO_CHAR(L_HWM_RESOURCE_ID))

max_ary = HWM_CTXARY_RECORD_POSITIONS.count  
rLog  = add_rlog (ffs_id, rule_id, ffName||' HWM_CTXARY_RECORD_POSITIONS count=>' || TO_CHAR( max_ary )  )
l_index = HWM_CTXARY_RECORD_POSITIONS.first(-1)

wkTotalHrsDay = 0
wkTotalHrsTc = 0   
nidx = 0
KIDX = 1

/* ----------- Loop through current Time Card Main Logic -------- */
/* -------------------------------------------------------------------- */  
WHILE (nidx < wMaAry ) LOOP
(	  
    nidx = nidx + 1	 
	tcMeasure = 0  
	paytypeIn 	 = NullText
	l_assignment = 0
	tcRecPosition   = HWM_CTXARY_RECORD_POSITIONS[nidx] 
	l_new_segment = 'x'
	LPROJECT = -1
	LTASK = -1
	L_PAYROLLTIMETYPE = NullText
	
    if tcRecPosition = 'DETAIL'
	then
	(
	
	if (MEASURE.exists(nidx) ) then ( tcMeasure  = MEASURE[nidx]   )
	if (PayrollTimeType.exists(nidx) ) then (paytypeIn  = PayrollTimeType[nidx] )
	if (StartTime.exists(nidx) ) then (	l_date  = StartTime[nidx] )
	if (SubresourceId.exists(nidx) ) then ( tcAssignmentID  = SubresourceId[nidx] ) 
	IF (PJC_PROJECT_ID.EXISTS(NIDX)) THEN (LPROJECT  = PJC_PROJECT_ID[NIDX]) 
	IF (PJC_TASK_ID.EXISTS(NIDX)) THEN (LTASK  = PJC_TASK_ID[NIDX]) 
	
	rLog  = add_rlog (ffs_id, rule_id, ffName||' MEASURE count=>' ||TO_CHAR(tcMeasure))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' PayrollTimeType count=>' ||paytypeIn)
	rLog  = add_rlog (ffs_id, rule_id, ffName||' StartTime count=>' ||TO_CHAR(l_date))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' SubresourceId count=>' ||TO_CHAR(tcAssignmentID))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' PJC_PROJECT_ID count=>' ||TO_CHAR(LPROJECT))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' PJC_TASK_ID count=>' ||TO_CHAR(LTASK))
	
	L_HR_ASSIGNMENT_ID = tcAssignmentID
	l_effective_date = l_date
	

/* Determine Cost Type */	
if (PayrollTimeType.exists(nidx)) then
(

L_PAYROLLTIMETYPE = PayrollTimeType[nidx]

IF (L_PAYROLLTIMETYPE != 'VC VEH CALL OUT' AND  L_PAYROLLTIMETYPE != 'O OVERTIME' AND  L_PAYROLLTIMETYPE != 'SP STANDBY PAY' AND  L_PAYROLLTIMETYPE != 'HO HOLIDAY OVERTIME' AND  L_PAYROLLTIMETYPE !='RG REGULAR') THEN     
( /* Skip: this is an Absence, which is not PROJECT/TASK or COSTING related */
L_PROJECT_TASK_PARAM = NullText
rLog  = add_rlog (ffs_id, rule_id, ffName||'TK_Log -> L_PROJECT_TASK_PARAM count=>' ||L_PROJECT_TASK_PARAM)
)
ELSE
(
rLog  = add_rlog (ffs_id, rule_id, ffName||'TK_Log -> Inside Else Block=>' ||L_PAYROLLTIMETYPE)

    if (tcMeasure > 0) then   	 
	(

               L_PROJECT_TASK_PARAM =  '|=P_PROJECT_ID='''||TO_CHAR(LPROJECT)||''''||'|P_TASK_ID='''||TO_CHAR(LTASK)||''''
               P_FUND = GET_VALUE_SET('ABC_COSTING_FUND_SEGMENT',L_PROJECT_TASK_PARAM)
               P_PROJECT = GET_VALUE_SET('ABC_COSTING_GLPROJECT_SEGMENT',L_PROJECT_TASK_PARAM)
               P_COSTCENTER = GET_VALUE_SET('ABC_COSTING_COSTCENTER_SEGMENT',L_PROJECT_TASK_PARAM)
               P_ACTIVITYTYPE = GET_VALUE_SET('ABC_COSTING_ACTIVITYTYPE_SEGMENT',L_PROJECT_TASK_PARAM)
               P_FERC = GET_VALUE_SET('ABC_COSTING_FERC_SEGMENT',L_PROJECT_TASK_PARAM)
               P_BUDGETCODE = GET_VALUE_SET('ABC_COSTING_BUDGETCODE_SEGMENT',L_PROJECT_TASK_PARAM)


			
/* Determine Cost Type */	
L_PAYROLLTIMETYPE = PayrollTimeType[nidx]

		if L_PAYROLLTIMETYPE = 'VC VEH CALL OUT' then (P_COSTTYPE = '0405')  
		if L_PAYROLLTIMETYPE = 'O OVERTIME' then  (P_COSTTYPE = '0211')
		if L_PAYROLLTIMETYPE = 'SP STANDBY PAY' then  (P_COSTTYPE = '0221')
		if L_PAYROLLTIMETYPE = 'HO HOLIDAY OVERTIME' then  (P_COSTTYPE = '0211')  
		if L_PAYROLLTIMETYPE = 'HOLIDAY' then  (P_COSTTYPE = '0217')  	
		
	    if L_PAYROLLTIMETYPE = 'RG REGULAR' then 			 
			(	 
				IF L_SALARY_BASIS = 'Salaried' then
				(
				 P_COSTTYPE = '0201'
				 )
				 ELSE
				 (
				 P_COSTTYPE = '0210'
                 )
            )
				 
				rLog  = add_rlog (ffs_id, rule_id, ffName||' L_PAYROLLTIMETYPE =>' ||L_PAYROLLTIMETYPE)
				rLog  = add_rlog (ffs_id, rule_id, ffName||' L_SALARY_BASIS =>' ||L_SALARY_BASIS)			   
			   	rLog  = add_rlog (ffs_id, rule_id, ffName||' P_FUND =>' ||P_FUND)
                rLog  = add_rlog (ffs_id, rule_id, ffName||' P_PROJECT =>' ||P_PROJECT)
                rLog  = add_rlog (ffs_id, rule_id, ffName||' P_COSTCENTER =>' ||P_COSTCENTER)
                rLog  = add_rlog (ffs_id, rule_id, ffName||' P_ACTIVITYTYPE =>' ||P_ACTIVITYTYPE)
                rLog  = add_rlog (ffs_id, rule_id, ffName||' P_FERC =>' ||P_FERC)
                rLog  = add_rlog (ffs_id, rule_id, ffName||' P_BUDGETCODE =>' ||P_BUDGETCODE)
				rLog  = add_rlog (ffs_id, rule_id, ffName||' P_COSTTYPE =>' ||P_COSTTYPE)
			   
		
L_FUND[NIDX] = P_FUND
L_COSTCENTER[NIDX] = P_COSTCENTER
L_PROJECT[NIDX] = P_PROJECT
L_ACTIVITYTYPE[NIDX] = P_ACTIVITYTYPE
L_FERC[NIDX] = P_FERC
L_BUDGETCODE[NIDX] = P_BUDGETCODE
L_COSTTYPE[NIDX] = 	P_COSTTYPE

  rLog  = add_rlog (ffs_id, rule_id, ffName||' L_FUND =>' ||L_FUND[NIDX])
  rLog  = add_rlog (ffs_id, rule_id, ffName||' L_COSTCENTER =>' ||L_COSTCENTER[NIDX])
  rLog  = add_rlog (ffs_id, rule_id, ffName||' L_PROJECT =>' ||L_PROJECT[NIDX])
  rLog  = add_rlog (ffs_id, rule_id, ffName||' L_ACTIVITYTYPE =>' ||L_ACTIVITYTYPE[NIDX])
  rLog  = add_rlog (ffs_id, rule_id, ffName||' L_FERC =>' ||L_FERC[NIDX])
  rLog  = add_rlog (ffs_id, rule_id, ffName||' L_BUDGETCODE =>' ||L_BUDGETCODE[NIDX])
  rLog  = add_rlog (ffs_id, rule_id, ffName||'L_COSTTYPE =>' ||L_COSTTYPE[NIDX])

	)	  
)  /* LPROJECT IS NULL */  
)
)
)  

rLog  = add_rlog (ffs_id, rule_id, '<< Exit - ' || ffName   ) 

RETURN  l_fund, l_costcenter, l_project, l_activitytype, l_ferc, l_budgetcode, l_costtype