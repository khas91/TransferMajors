IF OBJECT_ID('Adhoc.dbo.SAA_NOTE_TYPE') IS NOT NULL
	DROP TABLE Adhoc.dbo.SAA_NOTE_TYPE
IF OBJECT_ID('Adhoc.dbo.SAA_NOTE_STYPE') IS NOT NULL
	DROP TABLE Adhoc.dbo.SAA_NOTE_STYPE

SELECT
	*
INTO
	Adhoc.dbo.SAA_NOTE_TYPE
FROM
	(
SELECT
	'FSCJ1' AS [Institution]
	,orgs.OrgID AS [SAA_NOTE_TYPE]
	,'1/1/1901' AS [EFFDT]
	,'A' AS [EFF_STATUS]
	,LEFT(orgs.Descr, 30) AS [DESCR]
	,LEFT(orgs.Descr, 10) AS [DESCRSHORT]
FROM
	Adhoc.dbo.PS_ORGID_FICE_XWALK orgs

UNION

SELECT
	'FSCJ1' AS [Institution]
	,'350004' AS [SAA_NOTE_TYPE]
	,'1/1/1901' AS [EFFDT]
	,'A' AS [EFF_STATUS]
	,'LEGACY TRANSFER' AS [DESCR]
	,LEFT('LEGACY TRANSFER', 10) AS [DESCRSHORT]
	) SRC

SELECT
	'FSCJ1' AS [Institution]
	,xwalk.OrgID  AS [SAA_NOTE_TYPE]
	,SRC.[Program] AS [SAA_NOTE_SUBTYPE]
	,'1/1/1901' AS [EFFDT]
	,'A' AS [EFF_STATUS]
	,CASE
		WHEN SRC.[Program] = 'Legacy' THEN 'Legacy'
		WHEN cip.CIPCode IS NULL THEN nces.CIPTitle
		ELSE cip.CipTitle
	END AS [DESCR]
	,CASE
		WHEN SRC.[Program] = 'Legacy' THEN 'Legacy'
		WHEN cip.CIPCode IS NULL THEN LEFT(nces.CIPTitle, 10)
		ELSE LEFT(cip.CipTitle, 10)
	END AS [DESCSHORT]
INTO
	Adhoc.dbo.SAA_NOTE_STYPE
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
	LEFT JOIN StateValidationTables.dbo.CIPCodes cip ON cip.CIPCode = SRC.Program
	LEFT JOIN StateValidationTables.dbo.NCESCIPCodes nces ON nces.CIPCode = LEFT(SRC.[Program], 2)
ORDER BY
	SRC.OrgID, Program


SELECT
	*
FROM
	(
SELECT DISTINCT
	psid.PS_EMPL_ID
	,'FSCJ1' AS [INSTITUTION]
	,CASE
		WHEN bac2.InstitutionId IS NOT NULL THEN xwalk.OrgID
		WHEN type.SAA_NOTE_TYPE IS NULL THEN '350004'
		ELSE type.SAA_NOTE_TYPE
	END AS [SAA_NOTE_TYPE]
	,CASE
		WHEN bac2.InstitutionId IS NULL AND bac.InstitutionId IS NOT NULL THEN 'Legacy'
		WHEN stype.SAA_NOTE_SUBTYPE IS NULL THEN 'Legacy'
		ELSE stype.SAA_NOTE_SUBTYPE
	END AS [SAA_NOTE_STYPE]
	,'DummyAdvisor' AS [ADVISOR_ID]
	,'OP' AS [SAA_NOTE_STATUS]
	,'Y' AS [SAA_NOTE_ACCESS]
	,'TRANSFER MAJOR' AS [SAA_NOTE_SUBJ]
FROM
	MIS.dbo.ST_STDNT_OBJ_AWD_A_178 obj
	INNER JOIN MIS.dbo.ST_DA_BNCHMRKS_A_133 bench ON bench.STDNT_ID = obj.STDNT_ID
													AND bench.PGM_CD = obj.PGM_ID
	INNER JOIN MIS.dbo.ST_STDNT_SSN_SID_XWALK_606 psid ON psid.STUDENT_SSN = obj.STDNT_ID
	LEFT JOIN MIS.dbo.UTL_CODE_TABLE_120 code ON code.CODE = obj.TRNSFR_MJR
	LEFT JOIN MIS.dbo.UTL_CODE_TABLE_GENERIC_120 gen ON gen.ISN_UTL_CODE_TABLE = code.ISN_UTL_CODE_TABLE
	LEFT JOIN Adhoc.dbo.PS_ORGID_FICE_XWALK xwalk ON xwalk.FICE = obj.TRNSFR_INST
	LEFT JOIN MIS.StateData.vBacInst bac ON bac.InstitutionId = '0' + xwalk.FICE
	LEFT JOIN MIS.StateData.vBacInst bac2 ON bac2.InstitutionId = '0' + xwalk.FICE
										  AND bac2.Program = gen.FIELD_VALUE
	LEFT JOIN Adhoc.dbo.SAA_NOTE_STYPE stype ON stype.SAA_NOTE_SUBTYPE = gen.FIELD_VALUE
	LEFT JOIN Adhoc.dbo.SAA_NOTE_TYPE type ON type.SAA_NOTE_TYPE = xwalk.OrgID
WHERE
	obj.EFF_TERM >= '20141'
	AND obj.PGM_ID = '1108'
	AND bench.CC_25PCT_CMPLTD = 'X'
	--AND obj.PRIM_FLG = '1'
	--AND obj.ADMT_STAT = 'Y'
	--AND obj.PGM_STAT = 'AC'
	AND ((gen.cnxarraycolumn = 1
	AND code.STATUS = 'A'
	AND code.TABLE_NAME = 'SUS-MAJORS') OR code.CODE IS NULL)
	) SRC