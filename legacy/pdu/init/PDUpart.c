#include	<PDUintdef.h>
#include	<PDUpart.h>
#include	<PDUproto.h>

extern struct PDUpart     *part;

void PDUpart_init()
  {

  if (part == NULL)
    part = (struct PDUpart *) malloc (sizeof(struct PDUpart));

  part->view = NULL;
  part->serial_number = NULL;

  part->part_list = NULL;
  part->attach_list = NULL;
  part->view_buffer = NULL;
  part->assy_struct = NULL;
  part->part_attrs = NULL;
  part->dynamic_part_list = NULL;
  part->dynamic_value_list = NULL;
  part->parm_part_list = NULL;
  part->parm_value_list = NULL;

  }

