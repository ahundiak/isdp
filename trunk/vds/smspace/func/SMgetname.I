/* $Id: SMgetname.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMgetname.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMgetname.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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

/*
	
     PL       06-08-92  : Design date

ABSTRACT : 

	Implements Functions used for the space management product.
	
	- SMget_name()

*/

class implementation Root;
#include <stdio.h>
#include <string.h>

#include "EMSssprops.h"
#include "EMSconstruct.h"
#include "emsedgedef.h"
#include "EMSmsgdef.h"
#include "EMS.h"
#include "EMScmacros.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsmapdef.h"
#include "emssfintdef.h"
#include "emsimpdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "macro.h"
#include "nddef.h"

#include "VDSutil_def.h"
#include "acmacros.h"
#include "DIdef.h"
#include "COmdef.h"

#include "igrtypedef.h"
#include "ex.h"
#include "gr.h"
#include "go.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdp.h"

#include "macro.h"
#include "emsbool.h"
#include "dp.h"
#include "madef.h"
#include "msdef.h"

#include "AS_status.h"
#include "SMgraph.h"



#define   AS_DEBUG 	1

from GRvg       	import GRgetname; 
from ACpretend		import ACgive_downscan,ACfind_parent;


/*1 ====================== SMget_name =====================


	always return(1) .

*/
SMget_name(txt,obj_grid)
char            *txt;
struct GRid     *obj_grid;
{
 struct GRid    mac;
 IGRlong        status, msg;
 char           txt2[DI_PATH_MAX], name[DI_PATH_MAX], *pt_name;

  /*"plane: %d, %d\n", obj_grid->objid, obj_grid->osnum */
  txt[0] = '\0';

    status = om$send(msg = message ACpretend.ACgive_downscan(name),
                     senderid = NULL_OBJID,
                     targetid = obj_grid->objid,
                     targetos = obj_grid->osnum);
    if(status&1)
     {
      /*| It is a macro */

      status = om$send(msg = message ACpretend.ACfind_parent(&mac,NULL,NULL),
                      senderid = NULL_OBJID,
                      targetid = obj_grid->objid,
                      targetos = obj_grid->osnum);
      if(status&1)
       {
        status = om$send(msg = message GRvg.GRgetname(&msg,txt2),
                      senderid = NULL_OBJID,
                      targetid = mac.objid,
                      targetos = mac.osnum);
        if(status&msg&1)
         {
          pt_name = strrchr(txt2,':');
          if(pt_name == NULL)   strcpy(txt,pt_name);
          else
           {
            /* *pt_name = ' '; */
            strcat(&pt_name[1],":");
            strcat(&pt_name[1],name);
            strcpy(txt,&pt_name[1]);
            /*"macro, get the name: %s:, %s \n", name, &pt_name[1]*/
           }
         }
        else txt[0] = '\0';
       }
     }
    else
     {
      /* It is an regular object */
      status = om$send(msg = message GRvg.GRgetname(&msg,name),
                      senderid = NULL_OBJID,
                      targetid = obj_grid->objid,
                      targetos = obj_grid->osnum);
      if(status&msg&1)
       {
        /*| Just take the last part of the name */
        pt_name = strrchr(name,':');
        if(pt_name == NULL)   strcpy(txt,pt_name);
        else
         {
          /* *pt_name = ' '; */
          strcpy(txt,&pt_name[1]);
          /*"Regular object, get the name: %s:, %s \n", name, &pt_name[1] */
         }
       }
      else txt[0] = '\0';
     }
 return(1);

}

end implementation Root;

