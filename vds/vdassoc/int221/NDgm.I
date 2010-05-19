/* $Id: NDgm.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / NDgm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: NDgm.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
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

class implementation NDnode;

#include <sys/types.h>
#include "GMdef.h"
#include "GM.h"
#include "GMpriv.h"
#include "GMmacros.h"
#include "nddef.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "GMerrordef.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Function NDget_comp_state                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

NDget_comp_state(l_object, nb_object, l_attr, p_graph)
  /*
  Description: This function return the NDnode status stored in the graph
               structure.
  Constraints: All the object must have been broadcasted before calling their
               state.
  */
  struct GRid     l_object[]; /* IN     List of objects to modify             */
  int             nb_object;  /* IN     Number of objects to modify           */
  int             l_attr[];   /* IN     List of corresponding status          */
  struct GMgraph  *p_graph;   /* IN     graph				      */
  /*.NDget_comp_state*/
  {
  long           status;      /* Status returned by the functions             */
  int            ind;         /* Index for a loop                             */

  /*| Get the internal state */

  status = gm$get_attr
             (nb_object  = nb_object,
              l_object   = l_object,
              l_int_attr = l_attr,
              p_graph    = p_graph);

/* MOMO 11-05-92 : begin of modif. */
/* in I\ROUTE we change some nodes of the graph during the compute all new
/* objects are not in the p_graph. GMget_type function return FALSE in this 
/* case but the compute stays valid and can continue.
/**/

/*
  gm$status();
*/

/* MOMO 11-05-92 : end of modif. */
   
  /*| Convert it to the specific ND format */

  for(ind = 0; ind < nb_object; ind++)
   {
     l_attr[ind] = (l_attr[ind]&GM_BR_INFO) >> 12 ;
     if(     l_attr[ind] == (MSSUCC&0xf)
        || !l_attr[ind]) l_attr[ind] = MSSUCC;
    }

  return (status);
}/* end NDget_comp_state*/
end implementation NDnode;

