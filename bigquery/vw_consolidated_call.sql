CREATE OR REPLACE VIEW `pph-central.analytical.vw_consolidated_call`  AS 
SELECT cl.*
     , cm.name                                                        AS `Campaign Name`
  FROM `platform-partners-des.bronze.consolidated_call`               cl
  LEFT JOIN `platform-partners-des.bronze.consolidated_campaigns`     cm
    ON cm.company_project_id                                          = cl.source  
   AND cm.id                                                          = cl.campaign_id
;