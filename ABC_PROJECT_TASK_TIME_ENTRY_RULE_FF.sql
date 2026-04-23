/* +======================================================================+
   |                Copyright (c) 2009 Oracle Corporation                 |
   |                   Redwood Shores, California, USA                    |
   |                        All rights reserved.                          |
   +======================================================================+
 *
 * Formula Name : ABC_PROJECT_TASK_TIME_ENTRY_RULE_FF
 * Formula Type : Time Entry Rules
 * Description : This formula ensures employee is not able to submit any empty project or task for time entry on the timecard.
 * Change History
 * --------------
 *
 * Who               Ver      Date          Description
 *-----------------  ------   ------------  -----------------------------
 * Tejas Kumar M      1.0     16-MAR-2026    Created. 
***************************************************************************/
DEFAULT FOR HWM_CTXARY_RECORD_POSITIONS   is  EMPTY_TEXT_NUMBER 
DEFAULT FOR HWM_CTXARY_HWM_MEASURE_DAY    is  EMPTY_NUMBER_NUMBER 
DEFAULT FOR HWM_CTXARY_SUBRESOURCE_ID     IS  EMPTY_NUMBER_NUMBER 
DEFAULT FOR measure  is  EMPTY_NUMBER_NUMBER 
DEFAULT FOR PayrollTimeType   is  EMPTY_TEXT_NUMBER 
DEFAULT FOR SubresourceId is  EMPTY_NUMBER_NUMBER
DEFAULT FOR CMP_ASSIGNMENT_SALARY_BASIS_NAME IS ' '
DEFAULT FOR StartTime   is  EMPTY_DATE_NUMBER
DEFAULT FOR StopTime   is  EMPTY_DATE_NUMBER
DEFAULT FOR PJC_TASK_ID is  EMPTY_NUMBER_NUMBER
DEFAULT FOR PJC_PROJECT_ID is  EMPTY_NUMBER_NUMBER

INPUTS ARE 
  HWM_CTXARY_RECORD_POSITIONS,
  HWM_CTXARY_HWM_MEASURE_DAY,
  measure,
  SubresourceId,
  PayrollTimeType,
  StartTime,
  StopTime,
  PJC_TASK_ID,
  PJC_PROJECT_ID

/*  Following 2 lines are required right after inputs for all OTL and HWM formulas */
ffs_id = GET_CONTEXT(HWM_FFS_ID, 0)
rule_id = GET_CONTEXT(HWM_RULE_ID, 0)  
ffName = 'ABC_PROJECT_TASK_TIME_ENTRY_RULE_FF'
rLog  = add_rlog (ffs_id, rule_id, '>>> Enter - ' || ffName  ) 
 
/* ----------- constant values   -------- */
/* ------------------------------------- */

/*Output Variables-Start*/

L_SALARY_BASIS = ' '

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

/* Fixed Values from Rule header  */
process_empty_tc  = Get_Hdr_Text(rule_id ,'INCLUDE_EMPTY_TC', 'Y') 
if (upper(process_empty_tc) = 'YES' or upper(process_empty_tc) = 'Y' ) then ( 
   process_empty_tc = 'Y' 
) 

sum_lvl = Get_Hdr_Text(rule_id ,'RUN_SUMMATION_LEVEL', 'TIMECARD')   

rLog = add_rlog (ffs_id, rule_id, 'In Context/Hdr: '  ||  
		' , ffs_id='  ||  TO_CHAR( ffs_id ) ||   
		' , measure_period='  ||  TO_CHAR( measure_period ) ||
		' , hSumLvl='  ||  sum_lvl    ) 

/* ----------- Rule input parameters  -------- */
/* ------------------------------------------- */

pMsgCd  = get_rvalue_text (rule_id ,'MESSAGE_CODE', 'ABC_OTL_PROJECT_TASK_MSG_CD')  
pMsgcd1 = get_rvalue_text (rule_id ,'MESSAGE_CODE1', 'ABC_OTL_PAYROLL_TIME_TYPE_CD')
pTimeCatId  =   get_rvalue_number (rule_id ,'WORKED_TIME_CONDITION', 0)  

rLog = add_rlog (ffs_id, rule_id, '(Rule parameters: '  ||  
							'; ffs_id='  ||  TO_CHAR( ffs_id ) ||     
							'; pMsgcd='  ||  pMsgcd ||    
							'; pTimeCatId='  ||  TO_CHAR( pTimeCatId ) )
   

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
   
nidx = 0
KIDX = 1

OUT_MSG_ARRAY 	=	EMPTY_TEXT_NUMBER	 

/* ----------- Loop through current Time Card Main Logic -------- */
/* -------------------------------------------------------------------- */  
WHILE (nidx < wMaAry ) LOOP
(	  
    nidx = nidx + 1	 
	tcMeasure = 0  
	paytypeIn 	 = NullText
	l_assignment = 0
	tcRecPosition   = HWM_CTXARY_RECORD_POSITIONS[nidx] 
    tcStartTime = NullDate
	l_new_segment = 'x'
	LPROJECT = -1
	LTASK = -1
	L_PAYROLLTIMETYPE = NullText
	
	
	if (MEASURE.exists(nidx) ) then ( tcMeasure  = MEASURE[nidx]   )
	if (PayrollTimeType.exists(nidx) ) then (paytypeIn  = PayrollTimeType[nidx] )
	if (StartTime.exists(nidx) ) then (	tcStartTime  = StartTime[nidx] )
	if (SubresourceId.exists(nidx) ) then ( tcAssignmentID  = SubresourceId[nidx] ) 
	IF (PJC_PROJECT_ID.EXISTS(NIDX)) THEN (LPROJECT  = PJC_PROJECT_ID[NIDX]) 
	IF (PJC_TASK_ID.EXISTS(NIDX)) THEN (LTASK  = PJC_TASK_ID[NIDX]) 
	
	rLog  = add_rlog (ffs_id, rule_id, ffName||' MEASURE count=>' ||TO_CHAR(tcMeasure))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' PayrollTimeType count=>' ||paytypeIn)
	rLog  = add_rlog (ffs_id, rule_id, ffName||' StartTime count=>' ||TO_CHAR(tcStartTime))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' SubresourceId count=>' ||TO_CHAR(tcAssignmentID))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' PJC_PROJECT_ID count=>' ||TO_CHAR(LPROJECT))
	rLog  = add_rlog (ffs_id, rule_id, ffName||' PJC_TASK_ID count=>' ||TO_CHAR(LTASK))
	
	L_HR_ASSIGNMENT_ID = tcAssignmentID
	l_effective_date = tcStartTime

	
	
     change_contexts(HR_ASSIGNMENT_ID = L_HR_ASSIGNMENT_ID, EFFECTIVE_DATE = l_effective_date)
	(
          L_SALARY_BASIS = CMP_ASSIGNMENT_SALARY_BASIS_NAME
	)

	

if (PayrollTimeType.exists(nidx)) then
(
L_PAYROLLTIMETYPE = PayrollTimeType[nidx]
)

IF L_SALARY_BASIS = 'Salaried' then
(

OUT_MSG = NullText

IF (L_PAYROLLTIMETYPE = 'HO HOLIDAY OVERTIME' OR L_PAYROLLTIMETYPE = 'VC VEH CALL OUT' OR  L_PAYROLLTIMETYPE = 'O OVERTIME' OR  L_PAYROLLTIMETYPE = 'SP STANDBY PAY' ) THEN     
   ( 
   
			 tkn = 'START_DATE'  
			 val =  to_char(tcStartTime,'yyyy/mm/dd') 
			 OUT_MSG =  get_output_msg1( 'HWM',pMsgcd1,tkn ,val)
			
			
        if (OUT_MSG <> NullText) Then 
		(
			OUT_MSG_ARRAY[nidx]   = OUT_MSG
		) 
		
            if (nidx >  1000 ) Then (
			/* endless loop?  Stop process if more than max_loop records found */
			ex = raise_error (ffs_id, rule_id, 'Formula ' || ffName || ' terminated due to possible end-less loop.' )
		)
)

Else
(

IF (L_PAYROLLTIMETYPE = 'RG REGULAR') THEN    
(
OUT_MSG = NullText

if(tcMeasure => 0)then (

		    if(LPROJECT = -1 OR LTASK = -1) THEN
			(
			 tkn = 'START_DATE'  
			 val =  to_char(tcStartTime,'yyyy/mm/dd') 
			 OUT_MSG =  get_output_msg1( 'HWM',pMsgcd,tkn ,val)
		
			)
			
			)
			Else(
			 
             rLog  = add_rlog (ffs_id, rule_id, ' , Final Else =' )	 	

			)
			
        if (OUT_MSG <> NullText) Then 
		(
			OUT_MSG_ARRAY[nidx]   = OUT_MSG
		) 
		
            if (nidx >  1000 ) Then (
			/* endless loop?  Stop process if more than max_loop records found */
			ex = raise_error (ffs_id, rule_id, 'Formula ' || ffName || ' terminated due to possible end-less loop.' )
		)

)

)

)

Else
(

IF (L_PAYROLLTIMETYPE = 'VC VEH CALL OUT' OR  L_PAYROLLTIMETYPE = 'O OVERTIME' OR  L_PAYROLLTIMETYPE = 'SP STANDBY PAY' OR  L_PAYROLLTIMETYPE = 'HO HOLIDAY OVERTIME' OR  L_PAYROLLTIMETYPE ='RG REGULAR') THEN     
   ( 

OUT_MSG = NullText

if(tcMeasure => 0)then (

		    if(LPROJECT = -1 OR LTASK = -1) THEN
			(
			 tkn = 'START_DATE'  
			 val =  to_char(tcStartTime,'yyyy/mm/dd') 
			 OUT_MSG =  get_output_msg1( 'HWM',pMsgcd,tkn ,val)
		
			)
			
			)
			Else(
			 
             rLog  = add_rlog (ffs_id, rule_id, ' , Final Else =' )	 	

			)
			
        if (OUT_MSG <> NullText) Then 
		(
			OUT_MSG_ARRAY[nidx]   = OUT_MSG
		) 
		
            if (nidx >  1000 ) Then (
			/* endless loop?  Stop process if more than max_loop records found */
			ex = raise_error (ffs_id, rule_id, 'Formula ' || ffName || ' terminated due to possible end-less loop.' )
		)

)

)

)

rLog  = add_rlog (ffs_id, rule_id, '<< Exit - ' || ffName)  

RETURN OUT_MSG_ARRAY