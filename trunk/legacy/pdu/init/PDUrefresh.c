#include	<PDUstr.h>
#include	<PDUstr.new>
#include	<PDUerror.h>
#include	<PDUfile_def.h>
#include	<PDUproto.h>

extern struct PDUrefresh     *refresh;

void refresh_init()
  {

  if (refresh == NULL)
    refresh = (struct PDUrefresh *) malloc (sizeof(struct PDUrefresh));

/* Changed to NULL_STRING from NULL - Vasu 22.02.92 */

  refresh->rev_project = NULL_STRING;
  refresh->rev_catalog = NULL_STRING;
  refresh->cat_path = NULL_STRING;
  refresh->rev_partid = NULL_STRING;
  refresh->rev_revision = NULL_STRING;
  refresh->rev_filename = NULL_STRING;
  refresh->rev_parttype = NULL_STRING;
  refresh->rev_description = NULL_STRING;

  refresh->new_project = NULL_STRING;
  refresh->new_catalog = NULL_STRING;
  refresh->new_partid = NULL_STRING;
  refresh->new_revision = NULL_STRING;
  refresh->new_parttype = NULL_STRING;
  refresh->new_description = NULL_STRING;

  refresh->act_project = NULL_STRING;
  refresh->act_catalog = NULL_STRING;
  refresh->act_partid = NULL_STRING;
  refresh->act_revision = NULL_STRING;
  refresh->act_filename = NULL_STRING;
  refresh->act_description = NULL_STRING;
  refresh->act_parttype = NULL_STRING;

  refresh->parm_part_list = NULL;   
  refresh->parm_value_list = NULL;  /* Not changed these, as these are   */
				    /* Not strictly char ptrs, but are   */
				    /* MEMptrs cast back and forth  as   */
				    /* chars and MEMptrs.                */
				    /*  - Vasu 29.02.92                  */

/* Changed to NULL_STRING from NULL - Vasu 22.02.92 */

  refresh->status = PDM_S_SUCCESS;

  }

