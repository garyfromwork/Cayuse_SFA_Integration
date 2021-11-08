select distinct 
    ftvorgn_title "Name",
    SFADATA.F_CAYUSE_ORGN_SHORT_NAME(FTVORGN_TITLE) AS "ShortName",
    new_orgn "PrimaryCode",
    ' ' "SecondaryCode",
    'S' "ParentUnitPrimaryCode",
    'Yes' "Active" 
from ftvorgn b
inner join sfadata.csod_division a
    on a.new_orgn = b.ftvorgn_orgn_code
where ftvorgn_eff_date <= sysdate
and ftvorgn_nchg_date > sysdate
and ftvorgn_status_ind = 'A'
and length(ftvorgn_orgn_code) = 5
and ftvorgn_orgn_code not in ('11021','20010','20020','2201','22115','22129',
'2220','22226','22602','2301','2400','2500','25008','25603','2600','26005','26006',
'2700','2900','29102','29303','29310','50012','52006','53108','53109','53110','56011','90012','90013',
'9510','99999')
order by new_orgn asc;
