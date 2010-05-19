/* $Id: VDm_drawing.S,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/cmd / VDm_drawing.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_drawing.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/18  06:37:00  pinnacle
# Replaced: vddrawing/cmd/VDm_drawing.S for: CR 179603526 by smpathak for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class specification VDm_drawing (0:1) of COpara;

#include "growner.h"



#define MAX_OBJ_NUM 60
#define TYPE_MAX 512

instance VDm_drawing
  {
  int Entry_Request;
  int Nb_Max_Obj;
  variable struct GRid Obj_List[MAX_OBJ_NUM]; 
  struct GRid macro_dir;
  struct GRid geom_macro;
  struct GRid display_window;
  double scale;
  char locate_type[TYPE_MAX];
  
};

override 

  wakeup,
  sleep,
  execute;



message realloc_obj(int nb_obj);

message change_scale();

/* abstract
 If some of the selected elements or some of their parents are scale dependent, 
 change this scale before extraction 
*/
 
message extract();

/* abstract
 Copy selected part to drawing file 
*/

message read_drawing_macro();

message get_setup_file();

end specification VDm_drawing;
