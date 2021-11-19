WITH primary_posns AS (
    SELECT
        Z.*,
        NBRBJOB.*,
        C.*,
        A.*,
        'Yes' PRIMARY_POSN
    FROM
        spriden z,
        nbrbjob,
        pebempl c,
        nbrjobs a
    WHERE
        a.nbrjobs_pidm = spriden_pidm
        AND a.nbrjobs_pidm = pebempl_pidm
        AND a.nbrjobs_pidm = nbrbjob_pidm
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND NBRBJOB_CONTRACT_TYPE = 'P'
        AND NBRJOBS_ORGN_CODE_TS NOT IN ('11001','11021','20023','20026','22129','22226','24209',
            '25008','25914','26050','26414','26510','29002','29003','29007','29011','29012',
            '29013','29304','29310','29311','30204','30205','30206','30209','30210','30212',
            '30232','30249','30251','30254','30257','30258','30501','30601','40017','52002',
            '52005','52006','52109','52201','52302','52303','53110','53701','54011','80010',
            '90011','90012','90016','95102','95113','95401','95601','96021','96031','96041',
            '96051','96061','97021','97031','97041','97051','97061','97071','97081','97091','97101')
        AND nbrbjob_suff IN(
            SELECT
                DISTINCT i.pzrappt_suff
            FROM
                txcnmgr.pzrappt i
            WHERE
                i.pzrappt_pidm = a.nbrjobs_pidm
                AND i.pzrappt_apptno =(
                        SELECT
                            MAX(j.pzrappt_apptno)
                        FROM
                            txcnmgr.pzrappt j
                        WHERE
                            j.pzrappt_pidm = i.pzrappt_pidm
                            AND j.pzrappt_posn IN(
                                SELECT
                                    k.nbrbjob_posn
                                FROM
                                    nbrbjob k,
                                    nbrjobs l
                                WHERE
                                    k.nbrbjob_pidm = j.pzrappt_pidm --and k.nbrbjob_posn = j.pzrappt_posn
                                    --and k.nbrbjob_suff = j.pzrappt_suff
                                    AND k.nbrbjob_contract_type = 'P'
                                    AND k.nbrbjob_begin_date <= sysdate
                                    AND(
                                        k.nbrbjob_end_date IS NULL
                                        OR(
                                            k.nbrbjob_end_date IS NOT NULL
                                            AND k.nbrbjob_end_date > sysdate
                                        )
                                    )
                                    AND l.nbrjobs_pidm = k.nbrbjob_pidm
                                    AND l.nbrjobs_posn = k.nbrbjob_posn
                                    AND l.nbrjobs_suff = k.nbrbjob_suff --and l.nbrjobs_ecls_code in ('R1', 'R2', 'R3', 'R4', 'R5', 'R6')
                                    AND l.nbrjobs_status <> 'T' --AND (UPPER(NBRJOBS_DESC) NOT LIKE '%(TEMP)%' AND NBRJOBS_POSN NOT LIKE 'H%')
                                    AND l.nbrjobs_effective_date =(
                                        SELECT
                                            MAX(nbrjobs_effective_date)
                                        FROM
                                            nbrjobs m
                                        WHERE
                                            m.nbrjobs_pidm = l.nbrjobs_pidm
                                            AND m.nbrjobs_posn = l.nbrjobs_posn
                                            AND m.nbrjobs_suff = l.nbrjobs_suff
                                            AND m.nbrjobs_effective_date <= sysdate
                                    )
                                )
                        )
                )
        AND a.nbrjobs_status <> 'T'
        AND nbrbjob_posn = a.nbrjobs_posn
        AND nbrbjob_suff = a.nbrjobs_suff
        AND a.nbrjobs_effective_date =(
            SELECT
                MAX(nbrjobs_effective_date)
            FROM
                nbrjobs
            WHERE
                nbrjobs_pidm = a.nbrjobs_pidm
                AND nbrjobs_posn = a.nbrjobs_posn
                AND nbrjobs_suff = a.nbrjobs_suff
                AND nbrjobs_effective_date <= sysdate
        ) --AND pebempl_empl_status <> 'T'
        AND pebempl_ecls_code NOT IN(
            'R0',
            'S1',
            'S2',
            'S3'
        )
        AND spriden_pidm IN(
            SELECT
                DISTINCT pebempl_pidm
            FROM
                pebempl
            WHERE
                --pebempl_empl_status <> 'T'
                (
                    pebempl_trea_code IS NULL
                    OR(
                        pebempl_trea_code IS NOT NULL
                        AND pebempl_term_date > sysdate
                    )
                )
                AND NOT EXISTS(
                    SELECT
                        1
                    FROM
                        spriden
                    WHERE
                        spriden_pidm = pebempl_pidm
                        AND spriden_change_ind IS NULL
                        AND lower(spriden_last_name) LIKE 'xxx%'
                )
        )
        AND spriden_change_ind IS NULL
        AND nbrbjob_begin_date <= sysdate
        AND(
            nbrbjob_end_date IS NULL
            OR(
                nbrbjob_end_date IS NOT NULL
                AND nbrbjob_end_date > sysdate
            )
        )
    ORDER BY
        spriden_last_name,
        spriden_mi,
        spriden_first_name ASC
),
secondary_posns AS (
    SELECT
        Z.*,
        NBRBJOB.*,
        C.*,
        A.*,
        'No' PRIMARY_POSN
    FROM
        spriden z,
        nbrbjob,
        pebempl c,
        nbrjobs a
    WHERE
        a.nbrjobs_pidm = spriden_pidm
        AND a.nbrjobs_pidm = pebempl_pidm
        AND a.nbrjobs_pidm = nbrbjob_pidm
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND NBRBJOB_CONTRACT_TYPE = 'S'
        AND NBRJOBS_ORGN_CODE_TS NOT IN ('11001','11021','20023','20026','22129','22226','24209',
            '25008','25914','26050','26414','26510','29002','29003','29007','29011','29012',
            '29013','29304','29310','29311','30204','30205','30206','30209','30210','30212',
            '30232','30249','30251','30254','30257','30258','30501','30601','40017','52002',
            '52005','52006','52109','52201','52302','52303','53110','53701','54011','80010',
            '90011','90012','90016','95102','95113','95401','95601','96021','96031','96041',
            '96051','96061','97021','97031','97041','97051','97061','97071','97081','97091','97101')
        AND nbrbjob_suff IN(
            SELECT
                DISTINCT i.pzrappt_suff
            FROM
                txcnmgr.pzrappt i
            WHERE
                i.pzrappt_pidm = a.nbrjobs_pidm
                AND i.pzrappt_apptno =(
                        SELECT
                            MAX(j.pzrappt_apptno)
                        FROM
                            txcnmgr.pzrappt j
                        WHERE
                            j.pzrappt_pidm = i.pzrappt_pidm
                            AND j.pzrappt_posn IN(
                                SELECT
                                    k.nbrbjob_posn
                                FROM
                                    nbrbjob k,
                                    nbrjobs l
                                WHERE
                                    k.nbrbjob_pidm = j.pzrappt_pidm --and k.nbrbjob_posn = j.pzrappt_posn
                                    --and k.nbrbjob_suff = j.pzrappt_suff
                                    AND k.nbrbjob_contract_type = 'S'
                                    AND k.nbrbjob_begin_date <= sysdate
                                    AND(
                                        k.nbrbjob_end_date IS NULL
                                        OR(
                                            k.nbrbjob_end_date IS NOT NULL
                                            AND k.nbrbjob_end_date > sysdate
                                        )
                                    )
                                    AND l.nbrjobs_pidm = k.nbrbjob_pidm
                                    AND l.nbrjobs_posn = k.nbrbjob_posn
                                    AND l.nbrjobs_suff = k.nbrbjob_suff --and l.nbrjobs_ecls_code in ('R1', 'R2', 'R3', 'R4', 'R5', 'R6')
                                    AND l.nbrjobs_status <> 'T' --AND (UPPER(NBRJOBS_DESC) NOT LIKE '%(TEMP)%' AND NBRJOBS_POSN NOT LIKE 'H%')
                                    AND l.nbrjobs_effective_date =(
                                        SELECT
                                            MAX(nbrjobs_effective_date)
                                        FROM
                                            nbrjobs m
                                        WHERE
                                            m.nbrjobs_pidm = l.nbrjobs_pidm
                                            AND m.nbrjobs_posn = l.nbrjobs_posn
                                            AND m.nbrjobs_suff = l.nbrjobs_suff
                                            AND m.nbrjobs_effective_date <= sysdate
                                    )
                                )
                        )
                )
        AND a.nbrjobs_status <> 'T'
        AND nbrbjob_posn = a.nbrjobs_posn
        AND nbrbjob_suff = a.nbrjobs_suff
        AND a.nbrjobs_effective_date =(
            SELECT
                MAX(nbrjobs_effective_date)
            FROM
                nbrjobs
            WHERE
                nbrjobs_pidm = a.nbrjobs_pidm
                AND nbrjobs_posn = a.nbrjobs_posn
                AND nbrjobs_suff = a.nbrjobs_suff
                AND nbrjobs_effective_date <= sysdate
        ) --AND pebempl_empl_status <> 'T'
        AND pebempl_ecls_code NOT IN(
            'R0',
            'S1',
            'S2',
            'S3'
        )
        AND spriden_pidm IN(
            SELECT
                DISTINCT pebempl_pidm
            FROM
                pebempl
            WHERE
                --pebempl_empl_status <> 'T'
                (
                    pebempl_trea_code IS NULL
                    OR(
                        pebempl_trea_code IS NOT NULL
                        AND pebempl_term_date > sysdate
                    )
                )
                AND NOT EXISTS(
                    SELECT
                        1
                    FROM
                        spriden
                    WHERE
                        spriden_pidm = pebempl_pidm
                        AND spriden_change_ind IS NULL
                        AND lower(spriden_last_name) LIKE 'xxx%'
                )
        )
        AND spriden_change_ind IS NULL
        AND nbrbjob_begin_date <= sysdate
        AND(
            nbrbjob_end_date IS NULL
            OR(
                nbrbjob_end_date IS NOT NULL
                AND nbrbjob_end_date > sysdate
            )
        )
    ORDER BY
        spriden_last_name,
        spriden_mi,
        spriden_first_name ASC
),
RAW_PRESIDENT AS (
	SELECT SPRIDEN_LAST_NAME, 
		SPRIDEN_MI, 
		SPRIDEN_FIRST_NAME, 
		SPRIDEN_ID, 
		NBRJOBS.*, 
		NBRBJOB.* 
	FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
		--AND NBRBJOB_CONTRACT_TYPE = 'P'
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
    AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ASST%'
	AND (UPPER(NBRJOBS_DESC) LIKE '%PRESIDENT%')
	AND NBRJOBS_EFFECTIVE_DATE = 
        (SELECT MAX(A.NBRJOBS_EFFECTIVE_DATE) 
            FROM NBRJOBS A 
            WHERE A.NBRJOBS_PIDM = NBRJOBS_PIDM 
            AND A.NBRJOBS_SUFF = NBRJOBS_SUFF 
            AND A.NBRJOBS_POSN = NBRJOBS_POSN
            AND A.NBRJOBS_STATUS = 'A'
            AND UPPER(A.NBRJOBS_DESC) LIKE 'PRESIDENT'
        )
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
PRESIDENT AS (
    SELECT 'PRESIDENT' TITLE, RAW_PRESIDENT.* FROM RAW_PRESIDENT
    WHERE RAW_PRESIDENT.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) FROM RAW_PRESIDENT A
                                                    WHERE RAW_PRESIDENT.NBRJOBS_PIDM = A.NBRJOBS_PIDM
                                                    AND RAW_PRESIDENT.NBRJOBS_POSN = A.NBRJOBS_POSN)
),
RAW_VP AS (
	SELECT SPRIDEN_LAST_NAME, 
		SPRIDEN_MI, 
		SPRIDEN_FIRST_NAME, 
		SPRIDEN_ID, 
		NBRJOBS.*, 
		NBRBJOB.* 
	FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
    --AND NBRBJOB_CONTRACT_TYPE = 'P'
    AND (NBRBJOB_BEGIN_DATE <= SYSDATE AND (NBRBJOB_END_DATE > SYSDATE OR NBRBJOB_END_DATE IS NULL))
    AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
    AND (UPPER(NBRJOBS_DESC) LIKE '%VP %' 
        OR UPPER(NBRJOBS_DESC) LIKE '%VP'
        OR UPPER(NBRJOBS_DESC) LIKE '%VICE PRESIDENT%' 
        OR UPPER(NBRJOBS_DESC) LIKE '%EXEC ASST%'
        OR UPPER(NBRJOBS_DESC) LIKE '%ASST TO DEAN STDNTS%'
        OR UPPER(NBRJOBS_DESC) LIKE UPPER('Asst VPSA/Dean of Stdnt'))
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%GRAD ASST%'
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%EXEC ASST TO PROVOST%'
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ASSC%'
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
VP AS (
    SELECT 'VICE_PRESIDENT' TITLE, RAW_VP.* FROM RAW_VP
    WHERE RAW_VP.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) FROM RAW_VP A
                                                WHERE RAW_VP.NBRJOBS_PIDM = A.NBRJOBS_PIDM
                                                AND RAW_VP.NBRJOBS_POSN = A.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_VP.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
),
RAW_PROVOST AS (
	SELECT SPRIDEN_LAST_NAME, 
		SPRIDEN_MI, 
		SPRIDEN_FIRST_NAME, 
		SPRIDEN_ID, 
		NBRJOBS.*, 
		NBRBJOB.* 
	FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
    --AND NBRBJOB_CONTRACT_TYPE = 'P'
    AND (NBRBJOB_BEGIN_DATE <= SYSDATE AND (NBRBJOB_END_DATE > SYSDATE OR NBRBJOB_END_DATE IS NULL))
    AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
	AND (UPPER(NBRJOBS_DESC) LIKE '%PROVOST%' OR UPPER(NBRJOBS_DESC) LIKE '%EXEC ASST%PROVOST%')
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%STUDENT%'
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%PROVOST EXEC VP%'
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
PROVOST AS (
    SELECT 'PROVOST' TITLE, RAW_PROVOST.* FROM RAW_PROVOST
    WHERE RAW_PROVOST.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) FROM RAW_PROVOST A
                                                WHERE RAW_PROVOST.NBRJOBS_PIDM = A.NBRJOBS_PIDM
                                                AND RAW_PROVOST.NBRJOBS_POSN = A.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_PROVOST.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_PROVOST.SPRIDEN_ID = VP.SPRIDEN_ID)
),
RAW_DIRECTORS AS (
    SELECT SPRIDEN_LAST_NAME, SPRIDEN_MI, SPRIDEN_FIRST_NAME, SPRIDEN_ID, NBRJOBS.*, NBRBJOB.*
    FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
	AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ASST%')
	AND ((UPPER(NBRJOBS_DESC) LIKE '%DIR/PROFESSOR%')
        OR (UPPER(NBRJOBS_DESC) LIKE 'DIR/ASSC PROFESSOR')
        OR (UPPER(NBRJOBS_DESC) LIKE '%EXEC DIR ENRLMNT%')
        OR (UPPER(NBRJOBS_DESC) LIKE '%OFFCR CHIEF DIVERSITY%')
        OR (UPPER(NBRJOBS_DESC) LIKE 'DIR ATH')
        OR (UPPER(NBRJOBS_DESC) LIKE '%DIRECTOR%')
        OR (UPPER(NBRJOBS_DESC) LIKE '%INTERIM%%DIR%'))
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
DIRECTORS AS (
    SELECT 'DIRECTORS' AS TITLE, RAW_DIRECTORS.* FROM RAW_DIRECTORS
    WHERE RAW_DIRECTORS.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) 
                                                        FROM RAW_DIRECTORS A 
                                                        WHERE A.NBRJOBS_PIDM = RAW_DIRECTORS.NBRJOBS_PIDM
                                                            AND A.NBRJOBS_POSN = RAW_DIRECTORS.NBRJOBS_POSN
                                               )
    AND RAW_DIRECTORS.NBRJOBS_SGRP_CODE = (SELECT MAX(NBRJOBS_SGRP_CODE) 
                                                        FROM RAW_DIRECTORS A 
                                                        WHERE A.NBRJOBS_PIDM = RAW_DIRECTORS.NBRJOBS_PIDM
                                                            AND A.NBRJOBS_POSN = RAW_DIRECTORS.NBRJOBS_POSN
                                               )
    AND RAW_DIRECTORS.NBRBJOB_BEGIN_DATE = (SELECT MAX(NBRBJOB_BEGIN_DATE)
                                            FROM NBRBJOB A
                                            WHERE A.NBRBJOB_PIDM = RAW_DIRECTORS.NBRBJOB_PIDM
                                            AND A.NBRBJOB_POSN = RAW_DIRECTORS.NBRBJOB_POSN
                                            AND A.NBRBJOB_CONTRACT_TYPE = RAW_DIRECTORS.NBRBJOB_CONTRACT_TYPE)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_DIRECTORS.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_DIRECTORS.SPRIDEN_ID = VP.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT PROVOST.SPRIDEN_ID FROM PROVOST WHERE RAW_DIRECTORS.SPRIDEN_ID = PROVOST.SPRIDEN_ID)
),
RAW_ACADEMIC_SU AS (
    --NOW INCLUDES THE CODE FOR THE INTERIM CHAIRS AS WELL
    SELECT SPRIDEN_LAST_NAME, SPRIDEN_MI, SPRIDEN_FIRST_NAME, SPRIDEN_ID, NBRJOBS.*, NBRBJOB.*
    FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
		--AND NBRBJOB_CONTRACT_TYPE = 'P'
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
	AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ASST%')
	AND (UPPER(NBRJOBS_DESC) LIKE '%CHAIR%' 
        OR UPPER(NBRJOBS_DESC) LIKE '%DEAN%' 
        OR UPPER(NBRJOBS_DESC) LIKE '%INTERIM CHAIR%')
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
ACADEMIC_SU AS (
    SELECT 'DEANS/CHAIRS' TITLE, RAW_ACADEMIC_SU.* FROM RAW_ACADEMIC_SU
    WHERE RAW_ACADEMIC_SU.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) 
                                                    FROM RAW_ACADEMIC_SU A 
                                                    WHERE A.NBRJOBS_PIDM = RAW_ACADEMIC_SU.NBRJOBS_PIDM 
                                                    AND A.NBRJOBS_POSN = RAW_ACADEMIC_SU.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_ACADEMIC_SU.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_ACADEMIC_SU.SPRIDEN_ID = VP.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT PROVOST.SPRIDEN_ID FROM PROVOST WHERE RAW_ACADEMIC_SU.SPRIDEN_ID = PROVOST.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT DIRECTORS.SPRIDEN_ID FROM DIRECTORS WHERE RAW_ACADEMIC_SU.SPRIDEN_ID = DIRECTORS.SPRIDEN_ID)
),
RAW_FACULTY AS (
    SELECT SPRIDEN_LAST_NAME, SPRIDEN_MI, SPRIDEN_FIRST_NAME, SPRIDEN_ID, NBRJOBS.*, NBRBJOB.*
    FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
		--AND NBRBJOB_CONTRACT_TYPE = 'P'
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
	AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
	AND NBRJOBS_POSN LIKE 'F%'
    AND NBRJOBS_ECLS_CODE NOT IN ('E2','F3','H2','H4','N2','R0','R2','R4','R6')
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
FACULTY AS (
    SELECT 'FACULTY' AS TITLE, RAW_FACULTY.* FROM RAW_FACULTY
    WHERE RAW_FACULTY.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) 
                                                FROM RAW_FACULTY A 
                                                WHERE A.NBRJOBS_PIDM = RAW_FACULTY.NBRJOBS_PIDM 
                                                AND A.NBRJOBS_POSN = RAW_FACULTY.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_FACULTY.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_FACULTY.SPRIDEN_ID = VP.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT PROVOST.SPRIDEN_ID FROM PROVOST WHERE RAW_FACULTY.SPRIDEN_ID = PROVOST.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT DIRECTORS.SPRIDEN_ID FROM DIRECTORS WHERE RAW_FACULTY.SPRIDEN_ID = DIRECTORS.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT ACADEMIC_SU.SPRIDEN_ID FROM ACADEMIC_SU WHERE RAW_FACULTY.SPRIDEN_ID = ACADEMIC_SU.SPRIDEN_ID)
),
RAW_EMPLOYEE AS (
    SELECT SPRIDEN_LAST_NAME, SPRIDEN_MI, SPRIDEN_FIRST_NAME, SPRIDEN_ID, NBRJOBS.*, NBRBJOB.*
    FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
--		AND NBRBJOB_CONTRACT_TYPE = 'P'
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
	AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
	AND NBRJOBS_ECLS_CODE NOT IN ('E2','F3','H2','H4','N2','R0','R2','R4','R6')
	AND NBRJOBS_POSN LIKE 'E%'
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
EMPLOYEE AS (
    SELECT 'EMPLOYEE' AS TITLE, RAW_EMPLOYEE.* FROM RAW_EMPLOYEE
    WHERE RAW_EMPLOYEE.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) 
                                                    FROM RAW_EMPLOYEE A 
                                                    WHERE A.NBRJOBS_PIDM = RAW_EMPLOYEE.NBRJOBS_PIDM
                                                    AND A.NBRJOBS_POSN = RAW_EMPLOYEE.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_EMPLOYEE.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_EMPLOYEE.SPRIDEN_ID = VP.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT PROVOST.SPRIDEN_ID FROM PROVOST WHERE RAW_EMPLOYEE.SPRIDEN_ID = PROVOST.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT DIRECTORS.SPRIDEN_ID FROM DIRECTORS WHERE RAW_EMPLOYEE.SPRIDEN_ID = DIRECTORS.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT ACADEMIC_SU.SPRIDEN_ID FROM ACADEMIC_SU WHERE RAW_EMPLOYEE.SPRIDEN_ID = ACADEMIC_SU.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT FACULTY.SPRIDEN_ID FROM FACULTY WHERE RAW_EMPLOYEE.SPRIDEN_ID = FACULTY.SPRIDEN_ID)
),
RAW_EXECUTIVE_ASSISTANTS AS (
    SELECT SPRIDEN_LAST_NAME, SPRIDEN_MI, SPRIDEN_FIRST_NAME, SPRIDEN_ID, NBRJOBS.*, NBRBJOB.* FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
--		AND NBRBJOB_CONTRACT_TYPE = 'P'
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
    AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
	AND NBRJOBS_ECLS_CODE NOT IN ('E2','F3','H2','H4','N2','R0','R2','R4','R6')
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
    AND UPPER(NBRJOBS_DESC) NOT LIKE 'ASST TO DEAN STDNTS'
	AND (UPPER(NBRJOBS_DESC) LIKE UPPER('%EXECUTIVE%ASST%')
        OR UPPER(NBRJOBS_DESC) LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        OR UPPER(NBRJOBS_DESC) LIKE UPPER('%Exec Asst%')
        OR UPPER(NBRJOBS_DESC) LIKE UPPER('ASST TO PRESIDENT'))
),
EXECUTIVE_ASSISTANTS AS (
    SELECT 'EXECUTIVE ASSISTANTS' TITLE, RAW_EXECUTIVE_ASSISTANTS.* FROM RAW_EXECUTIVE_ASSISTANTS
    WHERE RAW_EXECUTIVE_ASSISTANTS.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) 
                                                    FROM RAW_EXECUTIVE_ASSISTANTS A 
                                                    WHERE A.NBRJOBS_PIDM = RAW_EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM
                                                    AND A.NBRJOBS_POSN = RAW_EXECUTIVE_ASSISTANTS.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_EXECUTIVE_ASSISTANTS.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_EXECUTIVE_ASSISTANTS.SPRIDEN_ID = VP.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT PROVOST.SPRIDEN_ID FROM PROVOST WHERE RAW_EXECUTIVE_ASSISTANTS.SPRIDEN_ID = PROVOST.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT DIRECTORS.SPRIDEN_ID FROM DIRECTORS WHERE RAW_EXECUTIVE_ASSISTANTS.SPRIDEN_ID = DIRECTORS.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT ACADEMIC_SU.SPRIDEN_ID FROM ACADEMIC_SU WHERE RAW_EXECUTIVE_ASSISTANTS.SPRIDEN_ID = ACADEMIC_SU.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT FACULTY.SPRIDEN_ID FROM FACULTY WHERE RAW_EXECUTIVE_ASSISTANTS.SPRIDEN_ID = FACULTY.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT EMPLOYEE.SPRIDEN_ID FROM EMPLOYEE WHERE RAW_EXECUTIVE_ASSISTANTS.SPRIDEN_ID = EMPLOYEE.SPRIDEN_ID)
),
RAW_ASSISTANTS AS (
    SELECT SPRIDEN_LAST_NAME, SPRIDEN_MI, SPRIDEN_FIRST_NAME, SPRIDEN_ID, NBRJOBS.*, NBRBJOB.* FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
--		AND NBRBJOB_CONTRACT_TYPE = 'P'
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
    AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
	AND NBRJOBS_ECLS_CODE NOT IN ('E2','F3','H2','H4','N2','R0','R2','R4','R6')
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
	AND (UPPER(NBRJOBS_DESC) LIKE UPPER('%Asst To Dean%')
        OR UPPER(NBRJOBS_DESC) LIKE UPPER('ASST TO DEAN STDNTS'))
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT'))
),
ASSISTANTS AS (
    SELECT 'DEAN ASSISTANTS' TITLE, RAW_ASSISTANTS.* FROM RAW_ASSISTANTS
    WHERE RAW_ASSISTANTS.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) 
                                                    FROM RAW_ASSISTANTS A 
                                                    WHERE A.NBRJOBS_PIDM = RAW_ASSISTANTS.NBRJOBS_PIDM
                                                    AND A.NBRJOBS_POSN = RAW_ASSISTANTS.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_ASSISTANTS.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_ASSISTANTS.SPRIDEN_ID = VP.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT PROVOST.SPRIDEN_ID FROM PROVOST WHERE RAW_ASSISTANTS.SPRIDEN_ID = PROVOST.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT DIRECTORS.SPRIDEN_ID FROM DIRECTORS WHERE RAW_ASSISTANTS.SPRIDEN_ID = DIRECTORS.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT ACADEMIC_SU.SPRIDEN_ID FROM ACADEMIC_SU WHERE RAW_ASSISTANTS.SPRIDEN_ID = ACADEMIC_SU.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT FACULTY.SPRIDEN_ID FROM FACULTY WHERE RAW_ASSISTANTS.SPRIDEN_ID = FACULTY.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT EMPLOYEE.SPRIDEN_ID FROM EMPLOYEE WHERE RAW_ASSISTANTS.SPRIDEN_ID = EMPLOYEE.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT EXECUTIVE_ASSISTANTS.SPRIDEN_ID FROM EXECUTIVE_ASSISTANTS WHERE RAW_ASSISTANTS.SPRIDEN_ID = EXECUTIVE_ASSISTANTS.SPRIDEN_ID)
),
RAW_ADMIN AS (
    SELECT SPRIDEN_LAST_NAME, SPRIDEN_MI, SPRIDEN_FIRST_NAME, SPRIDEN_ID, NBRJOBS.*, NBRBJOB.* FROM NBRJOBS
    INNER JOIN NBRBJOB
        ON NBRBJOB_PIDM = NBRJOBS_PIDM
        AND NBRBJOB_POSN = NBRJOBS_POSN
--		AND NBRBJOB_CONTRACT_TYPE = 'P'
		AND (NBRBJOB_BEGIN_DATE <= SYSDATE 
			AND (NBRBJOB_END_DATE > SYSDATE 
				OR NBRBJOB_END_DATE IS NULL))
    INNER JOIN SPRIDEN
        ON SPRIDEN_PIDM = NBRJOBS_PIDM
        AND SPRIDEN_CHANGE_IND IS NULL
    INNER JOIN PEBEMPL
        ON PEBEMPL_PIDM = NBRJOBS_PIDM
        AND PEBEMPL_EMPL_STATUS <> 'T'
        AND PEBEMPL_INTERNAL_FT_PT_IND <> 'P'
    WHERE NBRJOBS_STATUS = 'A'
    AND NBRJOBS_EFFECTIVE_DATE <= SYSDATE
	AND NBRJOBS_ECLS_CODE NOT IN ('E2','F3','H2','H4','N2','R0','R2','R4','R6')
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
	AND LOWER(NBRJOBS_DESC) LIKE '%asst admin%'
    AND (UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%' 
        AND UPPER(NBRJOBS_DESC) NOT LIKE '%ADJCT%'
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASST%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%EXECUTIVE%ASSISTANT%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('%Exec Asst%')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO PRESIDENT')
        AND UPPER(NBRJOBS_DESC) NOT LIKE UPPER('ASST TO DEAN STDNTS'))
),
ADMIN AS (
    SELECT 'ADMIN ASSISTANTS' TITLE, RAW_ADMIN.* FROM RAW_ADMIN
    WHERE RAW_ADMIN.NBRJOBS_EFFECTIVE_DATE = (SELECT MAX(NBRJOBS_EFFECTIVE_DATE) FROM RAW_ADMIN A
                                                WHERE RAW_ADMIN.NBRJOBS_PIDM = A.NBRJOBS_PIDM
                                                AND RAW_ADMIN.NBRJOBS_POSN = A.NBRJOBS_POSN)
--    AND NOT EXISTS (SELECT PRESIDENT.SPRIDEN_ID FROM PRESIDENT WHERE RAW_ADMIN.SPRIDEN_ID = PRESIDENT.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT VP.SPRIDEN_ID FROM VP WHERE RAW_ADMIN.SPRIDEN_ID = VP.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT PROVOST.SPRIDEN_ID FROM PROVOST WHERE RAW_ADMIN.SPRIDEN_ID = PROVOST.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT DIRECTORS.SPRIDEN_ID FROM DIRECTORS WHERE RAW_ADMIN.SPRIDEN_ID = DIRECTORS.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT ACADEMIC_SU.SPRIDEN_ID FROM ACADEMIC_SU WHERE RAW_ADMIN.SPRIDEN_ID = ACADEMIC_SU.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT FACULTY.SPRIDEN_ID FROM FACULTY WHERE RAW_ADMIN.SPRIDEN_ID = FACULTY.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT EMPLOYEE.SPRIDEN_ID FROM EMPLOYEE WHERE RAW_ADMIN.SPRIDEN_ID = EMPLOYEE.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT EXECUTIVE_ASSISTANTS.SPRIDEN_ID FROM EXECUTIVE_ASSISTANTS WHERE RAW_ADMIN.SPRIDEN_ID = EXECUTIVE_ASSISTANTS.SPRIDEN_ID)
--    AND NOT EXISTS (SELECT ASSISTANTS.SPRIDEN_ID FROM ASSISTANTS WHERE RAW_ADMIN.SPRIDEN_ID = ASSISTANTS.SPRIDEN_ID)
),
RACES AS (
    SELECT GORPRAC_PIDM,
        LISTAGG((CASE GORPRAC_RACE_CDE WHEN '4' THEN 'AMERICAN_INDIAN_ALASKA_NATIVE'
                WHEN '5' THEN 'ASIAN'
                WHEN '6' THEN 'BLACK_AFRICAN_AMERICAN'
                WHEN '7' THEN 'NATIVE_HAWAIIAN_PACIFIC_ISLANDER'
                WHEN '8' THEN 'WHITE'
                ELSE ' ' END), ' ')
        WITHIN GROUP (
            ORDER BY GORPRAC_RACE_CDE
        ) AS RACE
    FROM GORPRAC
    GROUP BY GORPRAC_PIDM
    ORDER BY GORPRAC_PIDM
),
PEOPLE AS (
    SELECT PRESIDENT.TITLE TITLE,
        PRESIDENT.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(PRESIDENT.SPRIDEN_MI, ' ') MIDDLE_NAME,
        PRESIDENT.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = PRESIDENT.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = PRESIDENT.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        PRESIDENT.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = PRESIDENT.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = PRESIDENT.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = PRESIDENT.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = PRESIDENT.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = PRESIDENT.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = PRESIDENT.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        PRESIDENT.NBRJOBS_ANN_SALARY
    FROM PRESIDENT
    UNION 
    SELECT VP.TITLE TITLE,
        VP.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(VP.SPRIDEN_MI, ' ') MIDDLE_NAME,
        VP.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = VP.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = VP.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        VP.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = VP.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = VP.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = VP.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = VP.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = VP.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = VP.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        VP.NBRJOBS_ANN_SALARY
    FROM VP
    UNION
    SELECT PROVOST.TITLE TITLE,
        PROVOST.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(PROVOST.SPRIDEN_MI, ' ') MIDDLE_NAME,
        PROVOST.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = PROVOST.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = PROVOST.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        PROVOST.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = PROVOST.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = PROVOST.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = PROVOST.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = PROVOST.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = PROVOST.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = PROVOST.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        PROVOST.NBRJOBS_ANN_SALARY
    FROM PROVOST
    UNION
    SELECT DIRECTORS.TITLE TITLE,
        DIRECTORS.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(DIRECTORS.SPRIDEN_MI, ' ') MIDDLE_NAME,
        DIRECTORS.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = DIRECTORS.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = DIRECTORS.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        DIRECTORS.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = DIRECTORS.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = DIRECTORS.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = DIRECTORS.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = DIRECTORS.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = DIRECTORS.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = DIRECTORS.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        DIRECTORS.NBRJOBS_ANN_SALARY
    FROM DIRECTORS
    UNION
    SELECT ACADEMIC_SU.TITLE,
        ACADEMIC_SU.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(ACADEMIC_SU.SPRIDEN_MI, ' ') MIDDLE_NAME,
        ACADEMIC_SU.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = ACADEMIC_SU.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = ACADEMIC_SU.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        ACADEMIC_SU.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = ACADEMIC_SU.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = ACADEMIC_SU.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = ACADEMIC_SU.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = ACADEMIC_SU.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = ACADEMIC_SU.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = ACADEMIC_SU.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        ACADEMIC_SU.NBRJOBS_ANN_SALARY
    FROM ACADEMIC_SU
    UNION
    SELECT FACULTY.TITLE TITLE,
        FACULTY.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(FACULTY.SPRIDEN_MI, ' ') MIDDLE_NAME,
        FACULTY.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = FACULTY.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = FACULTY.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        FACULTY.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = FACULTY.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = FACULTY.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = FACULTY.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = FACULTY.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = FACULTY.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = FACULTY.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        FACULTY.NBRJOBS_ANN_SALARY
    FROM FACULTY
    UNION
    SELECT EMPLOYEE.TITLE TITLE,
        EMPLOYEE.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(EMPLOYEE.SPRIDEN_MI, ' ') MIDDLE_NAME,
        EMPLOYEE.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = EMPLOYEE.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = EMPLOYEE.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        EMPLOYEE.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = EMPLOYEE.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = EMPLOYEE.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = EMPLOYEE.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = EMPLOYEE.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = EMPLOYEE.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = EMPLOYEE.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        EMPLOYEE.NBRJOBS_ANN_SALARY
    FROM EMPLOYEE
    UNION
    SELECT EXECUTIVE_ASSISTANTS.TITLE TITLE,
        EXECUTIVE_ASSISTANTS.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(EXECUTIVE_ASSISTANTS.SPRIDEN_MI, ' ') MIDDLE_NAME,
        EXECUTIVE_ASSISTANTS.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        EXECUTIVE_ASSISTANTS.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = EXECUTIVE_ASSISTANTS.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        EXECUTIVE_ASSISTANTS.NBRJOBS_ANN_SALARY
    FROM EXECUTIVE_ASSISTANTS
    UNION
    SELECT ASSISTANTS.TITLE TITLE,
        ASSISTANTS.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(ASSISTANTS.SPRIDEN_MI, ' ') MIDDLE_NAME,
        ASSISTANTS.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = ASSISTANTS.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = ASSISTANTS.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        ASSISTANTS.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = ASSISTANTS.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = ASSISTANTS.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = ASSISTANTS.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = ASSISTANTS.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = ASSISTANTS.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = ASSISTANTS.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACCOUNT,
        ASSISTANTS.NBRJOBS_ANN_SALARY
    FROM ASSISTANTS
    UNION
    SELECT ADMIN.TITLE TITLE,
        ADMIN.SPRIDEN_FIRST_NAME FIRST_NAME,
        NVL(ADMIN.SPRIDEN_MI, ' ') MIDDLE_NAME,
        ADMIN.SPRIDEN_LAST_NAME LAST_NAME,
        NVL((SELECT SPBPERS_NAME_PREFIX FROM SPBPERS WHERE SPBPERS_PIDM = ADMIN.NBRJOBS_PIDM), ' ') PREFIX,
        NVL((SELECT SPBPERS_NAME_SUFFIX FROM SPBPERS WHERE SPBPERS_PIDM = ADMIN.NBRJOBS_PIDM), ' ') SUFFIX,
        'Yes' ACTIVE,
        ADMIN.SPRIDEN_ID EMPLOYEE_ID,
        NVL((SELECT GOREMAL_EMAIL_ADDRESS FROM GOREMAL WHERE GOREMAL_PIDM = ADMIN.NBRJOBS_PIDM AND lower(GOREMAL_EMAIL_ADDRESS) LIKE '%@sfasu.edu' AND GOREMAL_PREFERRED_IND = 'Y'), ' ') EMAIL,
        NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = ADMIN.NBRJOBS_PIDM), ' ') USERNAME,
        ' ' NIH_COMMONS_ID,
        ' ' NSF_ID,
        ' ' NASA_NSPIRES_ID,
        ' ' ORCID_ID,
        ' ' DEGREE_DESCRIPTION,
        ' ' DEGREE_YEAR,
        ' ' DEGREE_QUALIFICATIONS,	
--        (CASE (SELECT UPPER(SPBPERS_SEX) FROM SPBPERS WHERE SPBPERS_PIDM = ADMIN.NBRJOBS_PIDM) WHEN 'F' THEN 'FEMALE'
--            WHEN 'M' THEN 'MALE'
--            ELSE ' ' END) AS GENDER,
--        (CASE (SELECT SPBPERS_ETHN_CDE FROM SPBPERS WHERE SPBPERS_PIDM = ADMIN.NBRJOBS_PIDM) WHEN '1' THEN 'NOT_HISPANIC'
--            WHEN '2' THEN 'HISPANIC'
--            ELSE ' ' END) AS ETHNICITY,
--        NVL((SELECT RACE FROM RACES WHERE RACES.GORPRAC_PIDM = ADMIN.NBRJOBS_PIDM), ' ') RACES,
        ' ' DISABILITIES,
--        NVL((SELECT SPBPERS_CITZ_IND FROM SPBPERS WHERE SPBPERS_PIDM = ADMIN.NBRJOBS_PIDM), 'US_CITIZEN') CITIZENSHIP,
        ' ' PHONE,
        ' ' FAX,
        '1936 North Street' STREET_1,
        ' ' STREET_2,
        'United States of America' COUNTRY,
        'Texas' STATE_PROVINCE,
        'Nacogdoches' COUNTY,
        'Nacogdoches' CITY,
        '75962-3940' POSTAL_CODE,
        'Yes' CREATE_ACOUNT,
        ADMIN.NBRJOBS_ANN_SALARY
    FROM ADMIN
),
POSNS as (
    SELECT distinct spriden_id,
      spriden_first_name,
      spriden_last_name,
      spriden_mi,
      pebempl_empl_status,
      pebempl_ecls_code,
      nbrbjob_posn,
      nbrjobs_status,
      nbrbjob_suff,
      nbrbjob_contract_type,
      nbrjobs_desc,
      nbrjobs_orgn_code_ts,
      NBRJOBS_ANN_SALARY,
      NBRJOBS_ECLS_CODE,
      NBRJOBS_POSN,
      (SELECT ftvorgn_title
        FROM ftvorgn
        WHERE nbrjobs_orgn_code_ts = ftvorgn_orgn_code
        AND FTVORGN_STATUS_IND       = 'A'
        AND FTVORGN_eff_DATE         =
            (SELECT MAX(FTVORGN_eff_DATE)
                FROM FTVORGN B
                WHERE B.FTVORGN_ORGN_CODE = nbrjobs_orgn_code_ts
                AND FTVORGN_STATUS_IND    = 'A')
      ) TS_ORGN_DESC,
      pebempl_orgn_code_home,
      (SELECT ftvorgn_title
      FROM ftvorgn
      WHERE FTVORGN_STATUS_IND   = 'A'
      AND pebempl_orgn_code_home = ftvorgn_orgn_code
      AND FTVORGN_eff_DATE       =
        (SELECT MAX(B.FTVORGN_eff_DATE)
        FROM FTVORGN B
        WHERE B.FTVORGN_ORGN_CODE = pebempl_orgn_code_home
        AND B.FTVORGN_STATUS_IND  = 'A'
        )
      ) HOME_ORGN_DESC,
      PRIMARY_POSN
    FROM PRIMARY_POSNS
    WHERE UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%'
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%JUNCT%'
    AND SPRIDEN_ID IN (SELECT DISTINCT PEOPLE.EMPLOYEE_ID FROM PEOPLE)
    union all
    SELECT distinct spriden_id,
      spriden_first_name,
      spriden_last_name,
      spriden_mi,
      pebempl_empl_status,
      pebempl_ecls_code,
      nbrbjob_posn,
      nbrjobs_status,
      nbrbjob_suff,
      nbrbjob_contract_type,
      nbrjobs_desc,
      nbrjobs_orgn_code_ts,
      NBRJOBS_ANN_SALARY,
      NBRJOBS_ECLS_CODE,
      NBRJOBS_POSN,
      (SELECT ftvorgn_title
          FROM ftvorgn
          WHERE nbrjobs_orgn_code_ts = ftvorgn_orgn_code
          AND FTVORGN_STATUS_IND       = 'A'
          AND FTVORGN_eff_DATE         =
            (SELECT MAX(FTVORGN_eff_DATE)
            FROM FTVORGN B
            WHERE B.FTVORGN_ORGN_CODE = nbrjobs_orgn_code_ts
            AND FTVORGN_STATUS_IND    = 'A')
      ) TS_ORGN_DESC,
      pebempl_orgn_code_home,
      (SELECT ftvorgn_title
      FROM ftvorgn
      WHERE FTVORGN_STATUS_IND   = 'A'
      AND pebempl_orgn_code_home = ftvorgn_orgn_code
      AND FTVORGN_eff_DATE       =
        (SELECT MAX(B.FTVORGN_eff_DATE)
        FROM FTVORGN B
        WHERE B.FTVORGN_ORGN_CODE = pebempl_orgn_code_home
        AND B.FTVORGN_STATUS_IND  = 'A'
        )
      ) HOME_ORGN_DESC,
      PRIMARY_POSN
    FROM SECONDARY_POSNS
    WHERE UPPER(NBRJOBS_DESC) NOT LIKE '%ADJUNCT%'
    AND UPPER(NBRJOBS_DESC) NOT LIKE '%JUNCT%'
    AND SPRIDEN_ID IN (SELECT DISTINCT PEOPLE.EMPLOYEE_ID FROM PEOPLE)
) 
SELECT DISTINCT NVL((SELECT GOBTPAC_EXTERNAL_USER FROM gobtpac WHERE GOBTPAC_PIDM = (SELECT SPRIDEN_PIDM FROM SPRIDEN WHERE SPRIDEN_ID = POSNS.SPRIDEN_ID AND SPRIDEN_CHANGE_IND IS NULL)), ' ') Username,
       POSNS.SPRIDEN_ID EmployeeID,
       (SELECT FTVORGN_FUND_CODE_DEF || '-' || POSNS.nbrjobs_orgn_code_ts 
        FROM FTVORGN 
        WHERE FTVORGN_ORGN_CODE = POSNS.nbrjobs_orgn_code_ts
        AND FTVORGN_EFF_DATE <= SYSDATE AND FTVORGN_NCHG_DATE > SYSDATE
        AND FTVORGN_STATUS_IND = 'A') UnitPrimaryCode,
       POSNS.TS_ORGN_DESC UnitName,
       POSNS.NBRJOBS_DESC Title,
       POSNS.PRIMARY_POSN PrimaryAppointment,
       ' ' USGovernmentAgency,
       PEOPLE.EMAIL ContactEmail,
       ' ' ContactOfficePhone,
       ' ' ContactMobilePhone,
       ' ' ContactPager,
       ' ' ContactFax,
       'Email' ContactPrefferedContactMethod,
       PEOPLE.STREET_1 ContactStreet1,
       ' ' ContactStreet2,
       PEOPLE.COUNTY ContactCounty,
       PEOPLE.COUNTRY ContactCountry,
       PEOPLE.STATE_PROVINCE ContactState_Province,
       PEOPLE.CITY ContactCity,
       PEOPLE.POSTAL_CODE ContactPostalCode,
       ' ' ContactWebsite,
       '1936 North Street'||CHR(44)||' Nacogdoches'||CHR(44)||' TX 759062' PerformanceSiteOrganization,
       'Yes' PerformanceSiteActive,
       '073894727' PerformanceSiteDUNS,
       PEOPLE.EMAIL PerformanceSiteEmail,
       ' ' PerformanceSiteOfficePhone,
       ' ' PerformanceSiteMobilePhone,
       ' ' PerformanceSitePager,
       ' ' PerformanceSiteFax,
       'Email' PerformanceSitePreferredContactMethod,
       ' ' PerformanceSiteStreet1,
       ' ' PerformanceSiteStreet2,
       ' ' PerformanceSiteCounty,
       ' ' PerformanceSiteCountry,
       ' ' PerformanceSiteState_Province,
       ' ' PerformanceSiteCity,
       ' ' PerformanceSitePostalCode,
       ' ' PerformanceSiteWebsite,
       'TX-001' PerformanceSiteCongressionalDistrict,
       CASE WHEN NBRJOBS_POSN LIKE 'E%' OR NBRJOBS_POSN LIKE 'H%' OR NBRJOBS_POSN LIKE 'N%' THEN '12' ELSE ' ' END
       CalendarMonths,
       CASE WHEN NBRJOBS_POSN LIKE 'E%' OR NBRJOBS_POSN LIKE 'H%' OR NBRJOBS_POSN LIKE 'N%' THEN TO_CHAR(POSNS.NBRJOBS_ANN_SALARY)
       		ELSE ' ' END
       CalendarSalary,
       CASE WHEN NBRJOBS_POSN LIKE 'F%' THEN '9' ELSE ' ' END
       AcademicMonths,
       CASE WHEN NBRJOBS_POSN LIKE 'F%' THEN TO_CHAR(POSNS.NBRJOBS_ANN_SALARY)
       		ELSE ' ' END
       AcademicSalary,
       CASE WHEN NBRJOBS_POSN LIKE 'P%' THEN '3' ELSE ' ' END
       SummerMonths,
       CASE WHEN NBRJOBS_POSN LIKE 'P%' THEN TO_CHAR(POSNS.NBRJOBS_ANN_SALARY*3)
       		ELSE ' ' END
       SummerSalary,
       'Y' PrincipalInvestigator,
       ' ' Assistant,
       ' ' AdministrationOfficial,
       ' ' SigningOfficial,
       ' ' Payee
FROM POSNS
LEFT JOIN PEOPLE
ON PEOPLE.EMPLOYEE_ID = POSNS.SPRIDEN_ID
ORDER BY USERNAME ASC, POSNS.SPRIDEN_ID ASC;
