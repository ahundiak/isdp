/* $Id: VDct1Defn.S,v 1.1.1.1 2001/01/04 21:08:02 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/imp/VDct1Defn.S
 *
 * Description: Take control of macro definations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Defn.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:02  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/06/29  18:28:08  pinnacle
# ct
#
# Revision 1.1  1999/06/08  14:20:16  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class specification VDct1Defn (0:0) of ACcpx_defn;

#include "VDtypedef.h"

instance VDct1Defn
{
  TGRid occID;
};

/* --------------------------------------------------
 * ACcpx_defn
 */
override
  ACgive_temp_desc,
//ACgive_feet_desc, Get compile error for some reason
  ACintpt_foot,
  ACintpt_foot_dir,
  ACmax_graph_ft,
  ACgive_name,
  ACreturn_real_def,
  ACreturn_symb_def;

/* --------------------------------------------------
 * Root
 */
override
  debug,
  delete,
  connect, 
  disconnect,
  wild_disconnect,		
  move_chan,
  copy_chan,
  unknown,
  range_disconnect,
  set_operation,
  ARwrite,
  ARread;

/* -----------------------------------------------
 * Don't know the details at this point of how
 * object gets constructed so provide some new
 * methods for possible later use
 *
 * The data pointer will actually be a pointer to some sort
 * of structure, if called with null just clear everything
 */
message VDctDefnSetData(IGRchar *data);
message VDctDefnGetData(IGRchar *data);
message VDctDefnGetName(IGRchar *name);
message VDctDefnSetName(IGRchar *name);
message VDctDefnGetOccID(TGRid  *occID);
message VDctDefnSetOccID(TGRid  *occID);

#if 0
instance ACcpx_defn 
{
  char macro_name[macro_MAX_CHAR];
  /*
   properties word :
     ACkeep_no_real_template
     ACsame_feet_in_set 
  */
  int prop;

  /* 
    Table mapping real template to template in father channel
    and feet names understood by that template 
  */    
  int tot_temp;
  variable struct stemp xdtemp[0];

  /* 
    Table mapping footname to position internal or template 
    know object lists 
  */  
  int feet_num;
  variable struct myfeet myfeet[0];
};
#endif

end specification VDct1Defn;
