#include <stdio.h>
#include "PDUintdef.h"
#include "FI.h"
#include "MEMstruct.h"
#include "PDUnode.h"
#include "PDUassy.h"

/* Global assembly flags */
short        PDU_assembly_list = FALSE;     /* flag for the part listing mcf */
short        PDU_select_area = FALSE;       /* flag for part selection mcf */
short        PDU_keyin_area = FALSE;        /* flag for part selection fields */
short        PDU_get_assy = FALSE;          /* flag to get a new assy struct */
short        PDU_load_assy = FALSE;         /* flag for updating part fields */
short        PDU_assy_cmd = FALSE;          /* flag for updating assembly form
					       after attach and detach */

/* Global row marker */
int        PDU_act_row;
short      PDU_second_row = FALSE;

/* Global assembly buffers */
MEMptr     PDU_assy_parts_bufr = NULL;
MEMptr     PDU_def_assy_bufr = NULL;
MEMptr     PDU_struct_bufr = NULL;

/* global form flags */
short        PDU_define_assy_created = FALSE;
short        PDU_define_assy_displayed = FALSE;

/* global assembly part identifiers */
char       *PDU_assy_catalog = NULL;
char       *PDU_assy_partid = NULL;
char       *PDU_assy_revision = NULL;
char       *PDU_assy_description = NULL;
char       *PDU_assy_parttype = NULL;

/* global form id for assy structure */
Form       PDU_struct_type;

/* global attach variables */
int        PDU_explode_depth = MAX_LEVEL;
int        PDU_save_level = MAX_LEVEL;

/* global expression variables */
char       *PDU_child_no;
char       *PDU_parent_no;
char       *PDU_first_level_child;
int        PDU_level_no;

/* global assembly linklists */
struct PDUassy_node       *PDU_assy_head = NULL;
struct PDUpath_node       *PDU_path_list = NULL;
