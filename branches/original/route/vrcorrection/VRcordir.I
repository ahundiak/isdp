/* $Id: VRcordir.I,v 1.1.1.1 2001/01/04 21:12:50 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRcordir.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcordir.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:50  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/16  23:26:54  pinnacle
# Replaced: vrcorrection/VRcordir.I for:  by r240_int for route240
#
 *
 * History:
 *	09/11/92  momo		creation
 *	01/15/96  tlb		Add prototypes
 *
 ******************************************************************************/


class implementation VRCorrection;

#define AS_DEBUG

#include <libgen.h>
#include <string.h>
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h" 
#include "DIomac.h" /*DIcheck_link DIfree*/
#include "exdef.h"
#include "exmacros.h"
#include "grownerdef.h"
#include "grownmacros.h"

#include "AS_status.h"

#define AS_DEBUG

from DImaster import store_info, retrieve_info, remove_info;

 method IGRdir.remove ( DIint *status; DIchar *name; DIint index )
 {
  *status = MSSUCC;
  return (OM_S_SUCCESS);
 }


method translate ( DIint *stat; DIchar *name; int index; DIchar *p_name; DIobjid *objid )
{
  int status,suc;
  struct GRid 		feet_obj;
  char *nm;

  nm=(char *)name;
  status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                               ( &suc, name, -1, -1, me->my_NbCorCmp, me->my_StrCmpList, NULL, &feet_obj ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  if(objid)
  *objid = feet_obj.objid;
  if(suc==0) *stat= DIR_W_NAME_NOT_FOUND;
   else      *stat= DIR_S_SUCCESS ;
  return ( OM_S_SUCCESS );
}

method dump ( DIint *stat; DIchar *reg_exp; OM_p_CLASSLIST classlist;
                DIchar ***lines; DIgrid **grids; DIint *count; 
                DIchar options )
{
  int 			i, status,suc;
  char 			**mname = NULL;
  struct GRid		*ft = NULL,wk_ft;
  int 			wcount;

/*"option %d OPT_SYS %d\n",options,OPT_SYS */

  ft=(struct GRid *)om$malloc (size = me->my_NbCorCmp * sizeof(struct GRid));
  mname=(char **) om$malloc (size =  me->my_NbCorCmp * sizeof(char **));

  wcount=0;

  for(i=0;i<me->my_NbCorCmp;i++)
   {
   status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                                 ( &suc, me->my_StrCmpList[i].CmpName, -1, -1, 
				   me->my_NbCorCmp, me->my_StrCmpList, NULL, &wk_ft
                                 ),
                      targetid = my_id );
   as$status( action = RET_STATUS );
   as$status( sts = suc, action = RET_STATUS );

    mname[wcount] = om$malloc(size = strlen(me->my_StrCmpList[i].CmpName)+1); 
    strcpy(mname[wcount],me->my_StrCmpList[i].CmpName );

    /* because HB check probably classes before sending dump message    */
    /* and to have parent ACdiowner understand like a nested collection */

    ft[wcount]=wk_ft;

    wcount +=1;
   }

  *count= *count + wcount;
  *grids= (DIgrid *) ft;
  *lines=mname;
  *stat= DIR_S_SUCCESS ;
 return(1);
}


method add ( DIint  *status; DIchar *name; DIobjid objid; int *p_index )
{
 *status = DIR_E_ABORT;
 return(OM_S_SUCCESS);
}


 method GRgetname(IGRlong *msg; IGRchar *name)
 {
  if (di$untranslate ( objid = my_id, objname = name ) == DIR_S_SUCCESS)
     *msg = MSSUCC;
  else
     *msg = MSFAIL;

  return 1;
 }

/* a unique name is allowed */

method GRputname(IGRlong *msg; IGRchar *name)
{
  char old_name[PATH_MAX];
  int i;

  *msg = MSFAIL;

    /*| remove the names from the global table */

  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = old_name ) != DIR_S_SUCCESS)
      { 
       if(name == NULL || name[0] == '\0')  *msg = MSSUCC;
       else if (DIadd_dir ( OM_Gw_current_OS, my_id, name, 1 ) == DIR_S_SUCCESS)
    					    *msg = MSSUCC;
       break;
      }
    else if(DIunlink_dir ( old_name, 1 ) != DIR_S_SUCCESS) break;
   }

  return OM_S_SUCCESS;
}

method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
 return (om$send(msg = message ASnode.GRputname(msg,name),
		 targetid = my_id));

}


method delete(int i)
{
  char name [PATH_MAX];
  int i;

    /*| remove the names from the global table */

  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = name ) != DIR_S_SUCCESS) break;
    if(DIunlink_dir ( name, 1 ) != DIR_S_SUCCESS) break;
   }

 return  om$send(msg = message ASnode.delete(i),
		  mode = OM_e_wrt_message,
		  targetid = my_id);
}

method DIgive_output (  char *formula )
{
 strcat(formula,"()");
 return OM_S_SUCCESS;
}

end implementation VRCorrection;
