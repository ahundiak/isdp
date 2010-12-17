#include <stdio.h>
#include "FI.h"
#include "PDUstr.h"
#include "PDUuser.h"
#include "PDUpart.h"
#include "PDUforms.h"
#include "MEMstruct.h"
#include "PDUextdef.h"

MEMptr PDU_bom_attr_bufr = NULL;		/* buffer for BOM attributes */
MEMptr PDU_bom_data_bufr = NULL;		/* buffer for BOM data */
MEMptr PDU_bom_list_bufr = NULL;		/* value list buffer for BOM */
MEMptr PDU_bom_map_bufr = NULL;			/* buffer for BOM mapping*/
MEMptr PDU_cat_attr_bufr = NULL;       		/* value list buffer for BOM */
char   *PDU_report_name = NULL;                 /* report name */
char   *PDU_report_title = NULL;		/* dynamic title for form */
char   *PDU_output_file = NULL;			/* output file for report */
Form   PDU_calling_form;                        /* calling from for reports */
char   *PDU_delete_reports = NULL;              /* pointer to reports needing to
                                                   deleted locally */
char   *PDU_store_catalog = NULL;		/* store catalog */
char   *PDU_store_partid = NULL;		/* store partid */
char   *PDU_store_revision = NULL;              /* store revision */
char   *PDU_store_description = NULL;		/* store description */
char   *PDU_bom_datatype = NULL;		/* store bom datatype */
char   *PDU_attr_datatype = NULL;		/* store attribute datatype */
char   *PDU_template = NULL;			/* store RIS template */
short  PDU_select_bomattr = FALSE;
short  PDU_select_catattr = FALSE;
short  PDU_report_exists = FALSE;
int    PDU_store_row;
