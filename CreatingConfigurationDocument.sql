IF OBJECT_ID('Adhoc.dbo.TransferMajorsConfiguration') IS NOT NULL
	DROP TABLE Adhoc.dbo.TransferMajorsConfiguration

SELECT
	xwalk.OrgID
	,xwalk.FICE
	,Program
INTO
	Adhoc.dbo.TransferMajorsConfiguration
FROM
	(
SELECT
	DISTINCT xwalk.[OrgID], bac.Program
FROM
	MIS.StateData.vBacInst bac
	INNER JOIN Adhoc.dbo.PS_ORGID_FICE_XWALK xwalk ON '0' + xwalk.FICE = bac.InstitutionId
UNION
SELECT
	DISTINCT xwalk.OrgID, gen.FIELD_VALUE
FROM
	MIS.dbo.ST_STDNT_OBJ_AWD_A_178 obj
	INNER JOIN MIS.dbo.ST_DA_BNCHMRKS_A_133 bench ON bench.STDNT_ID = obj.STDNT_ID
											      AND bench.PGM_CD = obj.PGM_ID
	INNER JOIN MIS.dbo.UTL_CODE_TABLE_120 code ON code.CODE = obj.TRNSFR_MJR
	INNER JOIN MIS.dbo.UTL_CODE_TABLE_GENERIC_120 gen ON gen.ISN_UTL_CODE_TABLE = code.ISN_UTL_CODE_TABLE
	INNER JOIN Adhoc.dbo.PS_ORGID_FICE_XWALK xwalk ON xwalk.FICE = obj.TRNSFR_INST
	LEFT JOIN MIS.StateData.vBacInst bac ON bac.InstitutionId = '0' + obj.TRNSFR_INST
WHERE
	obj.EFF_TERM >= '20141'
	AND obj.PGM_ID = '1108'
	AND bench.CC_25PCT_CMPLTD = 'X'
	AND obj.PRIM_FLG = '1'
	AND obj.ADMT_STAT = 'Y'
	AND obj.PGM_STAT = 'AC'
	AND gen.cnxarraycolumn = 1
	AND code.STATUS = 'A'
	AND code.TABLE_NAME = 'SUS-MAJORS'
	AND bac.InstitutionId IS NULL
UNION
SELECT
	DISTINCT xwalk.[OrgID]
	,'Legacy'
FROM
	Adhoc.dbo.PS_ORGID_FICE_XWALK xwalk
UNION
SELECT
	DISTINCT '350004',gen.FIELD_VALUE
FROM
	MIS.dbo.ST_STDNT_OBJ_AWD_A_178 obj
	INNER JOIN MIS.dbo.UTL_CODE_TABLE_120 code ON code.CODE = obj.TRNSFR_MJR
	INNER JOIN MIS.dbo.UTL_CODE_TABLE_GENERIC_120 gen ON gen.ISN_UTL_CODE_TABLE = code.ISN_UTL_CODE_TABLE
WHERE
	obj.PGM_ID = '1108'
	AND obj.ADMT_STAT = 'Y'
	AND obj.EFF_TERM >= '20141'
	AND code.STATUS = 'A'
	AND obj.PGM_STAT = 'AC'
	AND obj.PRIM_FLG = '1'
	AND code.TABLE_NAME = 'SUS-MAJORS'
	AND gen.cnxarraycolumn = 1
	) SRC
	LEFT JOIN Adhoc.dbo.PS_ORGID_FICE_Xwalk xwalk ON xwalk.OrgID = SRC.OrgID
ORDER BY
	SRC.OrgID, Program