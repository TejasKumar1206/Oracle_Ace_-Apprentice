/*Oracle PL/SQL Package to Divide the data in a ATP DB Table into batches and assign batch number for each Batch through PROCEDURE
----------------------------------------------------------------------------------------------------------------------------------*/

CREATE OR REPLACE PACKAGE BODY ABC_ADD_BATCH_ID_TBL_PKG AS

PROCEDURE ABC_ADD_BATCH_ID_TBL_PR(threadcount NUMBER)
AS
l_load_status CONSTANT VARCHAR2(50) := 'NEW';

CURSOR batch_id_c(p_batch_person_count NUMBER) IS 
Select
bt.batch_id,
stg.LOAD_SEQUENCE,
bt.EMPLOYEE_NO
FROM
ABC_ATP.HR_EMP_STORE_TIMESHEET_INT stg,
(
Select
floor((ROW_NUMBER()OVER(ORDER BY EMPLOYEE_NO)-1)/p_batch_person_count)+1 batch_id,
EMPLOYEE_NO
FROM
(
select DISTINCT EMPLOYEE_NO from ABC_ATP.HR_EMP_STORE_TIMESHEET_INT
where NVL(UPPER(load_status),'NEW') = l_load_status)
) bt
where NVL(UPPER(stg.load_status),'NEW') = l_load_status
AND stg.EMPLOYEE_NO = bt.EMPLOYEE_NO;

type batch_id_tbl is table of batch_id_c%ROWTYPE;
ln_batch_person_count NUMBER := 0;
lt_batch_id_tbl batch_id_tbl;

BEGIN
SELECT 
ceil(COUNT(DISTINCT EMPLOYEE_NO)/threadcount) EMPLOYEE_NO
INTO ln_batch_person_count
from 
ABC_ATP.HR_EMP_STORE_TIMESHEET_INT t
where nvl(upper(load_status),'NEW') = l_load_status;

OPEN batch_id_c(ln_batch_person_count);
LOOP 
     FETCH batch_id_c
	 BULK COLLECT INTO lt_batch_id_tbl;
	 FORALL i IN lt_batch_id_tbl.FIRST..lt_batch_id_tbl.LAST 
	     UPDATE ABC_ATP.HR_EMP_STORE_TIMESHEET_INT
		 SET
		    batch_id = lt_batch_id_tbl(i).batch_id
			WHERE 
			LOAD_SEQUENCE = lt_batch_id_tbl(i).LOAD_SEQUENCE;
			
			COMMIT;
			
	 EXIT WHEN lt_batch_id_tbl.count = 0;
END LOOP;

CLOSE batch_id_c;
END ABC_ADD_BATCH_ID_TBL_PR;
END ABC_ADD_BATCH_ID_TBL_PKG;
/