/* $Id: vddrwproto.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	include/prototypes/vddrwproto.h
 *
 * Description: prototypes
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddrwproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/01/29  22:25:50  pinnacle
 * ah
 *
 *
 * History:
 *	MM/DD/YY  AUTHOR  DESCRIPTION
 *	01/29/98  ah      Creation
 * -------------------------------------------------------------------*/

#ifndef vddrwproto_include
#define vddrwproto_include

extern IGRint VDdrwGetSetupFileName(IGRchar *setupName);
extern IGRint VDdrwSetSetupFileName(IGRchar *setupName);

extern IGRint VDinit_from_drawing_setup();

extern IGRint VDread_from_drawing_setup(
  IGRchar  *drawing_macro_name,
  IGRchar  *model_macro_name,
  IGRchar **feet_names,
  IGRint   *nb_feet,
  IGRint    max_feet
);

extern IGRint VDread_from_DrawingTable(
  FILE     *input_file,
  IGRchar  *drawing_macro_name,
  IGRchar  *model_macro_name,
  IGRchar **feet_names,
  IGRint   *nb_feet,
  IGRint    max_feet
);

extern IGRint VDinit_from_DrawingTable(FILE **input_file);

extern IGRint VDget_design_name( 
  GRspacenum       osnum, 
  IGRchar         *design_key, 
  struct GRmd_env *md_env
);

extern IGRint VDadd_predef_feet(
  IGRint   *nb_feet,
  IGRchar **feet_names
);

extern IGRint VDinit_feet_name( 
  IGRchar  *ftname, 
  IGRchar **feet_names, 
  IGRint    nb
);

#endif

