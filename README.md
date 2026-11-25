# Retenciones

Reporte de retenciones en RAP / ABAP Cloud (S/4HANA Cloud Private).

`Retenciones.docx` tiene el contexto original. El código fuente actualizado está en `src/`:

| Archivo | Objeto |
|---|---|
| `src/zi_fiap_rep_ret.ddls.asddls` | Custom Entity `ZI_FIAP_REP_RET` |
| `src/zcl_fiap_retenciones_dpc.clas.abap` | Query provider `ZCL_FIAP_RETENCIONES_DPC` |
| `src/zcl_fiap_ret_log.clas.abap` | Clase de lógica `ZCL_FIAP_RET_LOG` |

## Ajustes

- Nueva columna **CAI**: el `CONSEC` se obtiene de `ZI_COM_PFA_BASE` (sociedad, `BELNR`, `MIROGJAHR`) o, si no está ahí, de `ZI_RE_PFA_H` (`CompanyCode`, `DocumentNumber`, `DocumentYear` → `Consec`); con ese valor se lee el CAI de `ZPFA_FACT_CAI`.
- El filtro **Documento Contable** ahora se aplica (antes la DPC no lo leía).
- `enriquecer_datos_z`: la lectura de `ZPFA_DATA` usa sociedad + documento + ejercicio (antes solo sociedad).
- Llave de la entidad ampliada con `AccountingDocumentItem` y `WithholdingTaxType` para evitar filas con llave repetida en Fiori.
- La DPC procesa el ordenamiento de columnas (`get_sort_elements`) y la búsqueda libre (`get_search_expression`).
- Detalle (Object Page): la lectura por llave funciona sin el filtro País, y la entidad define encabezado y secciones Documento / Proveedor / Retención.
- Núm. Doc. Factura con formato `000-000-00-00000000` solo en las líneas que tienen CAI (si el número tiene 16 dígitos).
