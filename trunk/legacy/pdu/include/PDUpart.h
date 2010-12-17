/***************************************************
 * Product Data Manager data structure definitions *
 ***************************************************/

#include	"MEMstruct.h"
#include	"OMminimum.h"

struct PDUpart
	{
	char		*view;
	char		*serial_number;
	int		line_number;

	MEMptr		part_list;
	MEMptr		view_buffer;
	MEMptr		assy_struct;
	MEMptr		attach_list;
	MEMptr		part_attrs;
	MEMptr		dynamic_part_list;
	MEMptr		dynamic_value_list;
	MEMptr		parm_part_list;
	MEMptr		parm_value_list;

	OM_S_OBJID	partid;
	};
