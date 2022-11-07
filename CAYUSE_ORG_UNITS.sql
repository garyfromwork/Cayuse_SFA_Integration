select distinct 
    ftvorgn_orgn_code || ' ' || ftvorgn_title "Name",
    SFADATA.F_CAYUSE_ORGN_SHORT_NAME(FTVORGN_TITLE) AS "ShortName",
    ftvorgn_orgn_code "PrimaryCode",
    NULL "SecondaryCode",
    (CASE
        WHEN ftvorgn_orgn_code IN ('11001', '11002', '11003', '11011', '15001')
        THEN '1'
        WHEN ftvorgn_orgn_code IN ('15002','15008','20001','29302','30001','40010','50011','57001','90011','95101') 
        THEN '15001'
        WHEN ftvorgn_orgn_code IN ('20002','20011','20013','20015','20019','20023',
            '20026','21001','22010','23011','24001','25001',
            '26001','27001','27002','28001','29001','29101',
            '29103','29130','29302','29304','29401','29501','29502','29504','60011') 
        THEN '20001'
        WHEN ftvorgn_orgn_code IN ('20240','29303')
        THEN '20023'
        WHEN ftvorgn_orgn_code IN ('21002','21100','21200','21300','21400','21500') 
        THEN '21001'
        WHEN ftvorgn_orgn_code IN ('22012','22017','22100','22104','22105',
            '22107','22108','22200','22201','22203','22222',
            '22300','22400','22405','22500','22506','22510',
            '22514','22601','22604','22607','22705','22706') 
        THEN '22010'
        WHEN ftvorgn_orgn_code IN ('23014','23015','23016','23100','23114',
            '23115','23117','23200','23201','23202','23203',
            '23207','23210','23211','23300') 
        THEN '23011'
        WHEN ftvorgn_orgn_code IN ('24100','24101','24102','24103','24104',
            '24105','24107','24109','24110','24111','24112',
            '24114','24115','24116','24117','24118','24119',
            '24120','24121','24122','24123','24126','24129',
            '24200','24201','24202','24203','24204','24205',
            '24207','24209','24218','24245','24300','24301',
            '24304') 
        THEN '24001'
        WHEN ftvorgn_orgn_code IN ('25002','25003','25004','25100','25109',
            '25200','25202','25206','25215','25300','25400',
            '25401','25500','25600','25601','25602','25700',
            '25750','25800','25900','25902','25911','25913')
        THEN '25001'
        WHEN ftvorgn_orgn_code IN ('26002','26004','26008','26010','26011',
            '26050','26100','26200','26300','26400','26410',
            '26414','26500','26501','26510','26600','26602',
            '26701','26708','26800')
        THEN '26001'
        WHEN ftvorgn_orgn_code IN ('27101','27201')
        THEN '27001'
        WHEN ftvorgn_orgn_code IN ('29002','29003','29007','29011','29012','29013')
        THEN '29001'
        WHEN ftvorgn_orgn_code IN ('29200','29204','29311')
        THEN '29302'
        WHEN ftvorgn_orgn_code IN ('30101','30201','30401','30501','30601','31001','55011')
        THEN '30001'
        WHEN ftvorgn_orgn_code IN ('30204','30205','30206','30207','30209','30210',
            '30212','30216','30232','30249','30251','30254','30257','30258')
        THEN '30201'
        WHEN ftvorgn_orgn_code IN ('31003')
        THEN '30401'
        WHEN ftvorgn_orgn_code IN ('30604')
        THEN '30601'
        WHEN ftvorgn_orgn_code IN ('31002', '31004')
        THEN '31001'
        WHEN ftvorgn_orgn_code IN ('40011','40017','80010')
        THEN '40010'
        WHEN ftvorgn_orgn_code IN ('52001','52101','52003','53101','53701','54011')
        THEN '50011'
        WHEN ftvorgn_orgn_code IN ('51005')
        THEN '51001'
        WHEN ftvorgn_orgn_code IN ('51001','52002','52005','52301')
        THEN '52001'
        WHEN ftvorgn_orgn_code IN ('52201','52303','52103')
        THEN '52101'
        WHEN ftvorgn_orgn_code IN ('52110','52205','52206','52207','52208','52109')
        THEN '52201'
        WHEN ftvorgn_orgn_code IN ('52302','53401','53431','53435','53103')
        THEN '53101'
        WHEN ftvorgn_orgn_code IN ('52004','52401','57011')
        THEN '57001'
        WHEN ftvorgn_orgn_code IN ('55016')
        THEN '55011'
        WHEN ftvorgn_orgn_code IN ('90016')
        THEN '90011'
        WHEN ftvorgn_orgn_code IN ('95102','95105','95106','95109','95112','95113','95201',
            '95202','95401','95402','95601','96021','96031','96041','96051',
            '96061','97021','97031','97041','97051','97061','97071','97081',
            '97091','97101')
        THEN '95101'
        ELSE ftvorgn_orgn_code END) "ParentUnitPrimaryCode",
    'Yes' "Active" 
from ftvorgn b
inner join sfadata.csod_division a
    on a.orgn = b.ftvorgn_orgn_code
where ftvorgn_eff_date <= sysdate
and ftvorgn_nchg_date > sysdate
and ftvorgn_status_ind = 'A'
and length(ftvorgn_orgn_code) = 5
and ftvorgn_orgn_code not in ('11021','20010','20020','2201','22115','22129',
'2220','22226','22602','2301','2400','2500','25008','25603','2600','26005','26006',
'2700','2900','29102','29310','50012','52006','53108','53109','53110','56011','90012','90013',
'9510','99999')
and ftvorgn_orgn_code not like '12%'
order by ftvorgn_orgn_code asc;
