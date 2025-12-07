-- Ejemplo de View de BigQuery
-- Este archivo será leído por Terraform y creado como una view en BigQuery
-- Nombre de la view: example_view (basado en el nombre del archivo)

SELECT 
  column1,
  column2,
  COUNT(*) as count
FROM 
  `pph-central.analytical.source_table`
GROUP BY 
  column1, 
  column2

