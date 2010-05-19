/* $Id: SMSetDwSymb.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMSetDwSymb.I
 *
 * Description:
 *
 *      This file implements the method related to the dead weight symbology
 *	of the compartment object.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMSetDwSymb.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
 *
 *      07/15/92        Ch. Heraud      Creation date.
 *      05/07/93        J.Jasinczuck 	Replace  dead weight symbology by an 
 *					attribute driven symbology
 *
 * -------------------------------------------------------------------------
 */

class implementation SMcomp;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "ACrg_collect.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"

#include "SMcomp_def.h"
#include "SMmacros.h"

#include "AS_status.h"

from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACpretend	import	ACgive_downscan, ACfind_parent;

/*+me
 -------------------------------------------------------------------------

  Public Message SMSetDwSymb

  Abstract

   	Set the symbology of the compartment to the one associated with the 
	attribute choosen to drive the symbology .
  
	For instance if this attribut name was "SW", look if a path "SW" 
	exists and if it exists get its symbology and modify the compartment 
	symbology.

  Arguments

  IGRlong		*msg		O : Completion code.


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_W_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

method SMSetDwSymb(IGRlong *msg)
{
 IGRlong 		status, loc_msg;
 IGRchar		symb_att[DI_PATH_MAX],name[DI_PATH_MAX];
 struct GRsymbology     symb;
 IGRint                 found;

 *msg = MSFAIL;

 /* Jean . 5/7/93 . Replace dead weight by attributes driven symbology*/
#if 0
 status = om$send(msg = message SMcomp.SMGetDw(&loc_msg, NULL, name),
		targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC)
  {
   /* No name !!! */
   return(OM_W_ABORT);
  }
#endif

 /* Get attributes driven symbology */
 if(!SMGetSymbTrack(symb_att,NULL))  return OM_S_SUCCESS; 
 
 name[0] = '\0';
 /* Retreive old dead weight before modifying attributes */
 status = om$send(msg = message SMcomp.SMGetAttTxt
		  (&loc_msg,symb_att,name,(IGRshort *)NULL),
		  targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("Error get attribut %s for object %d,%d\n",
	   symb_att,my_id,OM_Gw_current_OS);
    return OM_S_SUCCESS;
  }

 if(name[0] == '\0') goto quit; /* Nothing to set */
 
 status = vds$get_path( in_name   = name,
                        symbology = &symb,
                        found     = &found);
 if(!(status &1)|| found != 1)
  {
   /* No path name corresponding to the dead weight found */
   return OM_S_SUCCESS;
  }
 
 /* Modify the symbology */
 status = om$send(msg = message GRvg.GRputsymb(&loc_msg, &symb),
		targetid = my_id);
 if(!(status &1) || loc_msg != MSSUCC) return OM_S_SUCCESS;
 
 quit:
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------

  Public Message SMGetDw

  Abstract

   	Get the dead weight object id and name.

  Arguments

  IGRlong		*msg		O : Completion code.

  struct GRid		*dw		O : Dead weight id (can be NULL).

  IGRchar		*name		O : Dead weight name (can be NULL).


  Status/Return Code

      OM_S_SUCCESS	if success;
      OM_W_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

method SMGetDw(IGRlong *msg; struct GRid *dw; IGRchar *name)
{
 IGRlong 		status, loc_msg;
 IGRchar		tmp_name[DI_PATH_MAX];
 struct SMObjList	list;
 struct ACrg_coll	crit;

 list.list = NULL;

 *msg       = MSFAIL;

 if(name) name[0] = '\0';
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "dead_weight", tmp_name, NULL),
			targetid = my_id);
 if(!(status & loc_msg & 1)) 
  {
   /* No dead weight defined !!! */
   if(dw)  dw->objid = NULL_OBJID;
  }
 else
  {
   if(name) strcpy(name, tmp_name);
   if(dw != NULL)
    {
     /* Get the group id */
     strcpy(crit.name, "name");
     crit.desc.type = AC_ATTRIB_TEXT;
     strcpy(crit.desc.value.att_txt, tmp_name);
     
     status = SM$CritSel(msg		= &loc_msg,
			 options	= 0,
			 state		= SM_NEW | SM_UPD | SM_MOD,
			 type		= SM_DW,
			 sub_type	= 0xFFFF,
			 nb_crit	= 1,
			 crit		= &crit,
			 list		= &list);
     if(!(status & loc_msg & 1)) return OM_W_ABORT;
     
     if(list.nb_objects <=0)
      {
       dw->objid = NULL_OBJID;
      }
     else
      {
       if(list.nb_objects > 1) 
         printf("Warning, more than one dead-weight found for: %s\n", tmp_name);
	 
       *dw = list.list[0].obj_id;
       if(list.list){ free(list.list); list.list = NULL;}
      }
    }   
  }


 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------

  Public Message SMGetDw

  Abstract

   	Get the group object id and name and the sub group name and index.

  Arguments

  IGRlong		*msg		O : Completion code.

  struct GRid		*grp		O : group id (can be NULL).

  IGRchar		*grp_name	O : group name (can be NULL).

  IGRchar		*sub_name	O : sub group name (can be NULL).

  IGRint		*ind_sub_grp	O : Sub group index (can be NULL).


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_W_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

method SMGetGrp(IGRlong *msg; struct GRid *grp; IGRchar *grp_name, *sub_name;
		IGRint *ind_sub_grp)
{
 IGRlong 		status, loc_msg;
 IGRchar		tmp_name[DI_PATH_MAX];
 struct SMObjList	list;
 struct ACrg_coll	crit;

 *msg = MSFAIL;
 list.list = NULL;

 if(grp_name != NULL) grp_name[0] = '\0';
 if(sub_name != NULL) sub_name[0] = '\0';

 if(ind_sub_grp != NULL) *ind_sub_grp = 1;

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "grp", tmp_name, NULL),
			targetid = my_id);
 if(!(status & loc_msg & 1)) 
  {
   /* No group defined !!! */
   if(grp)  grp->objid = NULL_OBJID;
  }
 else 
  {
   if(grp_name) strcpy(grp_name, tmp_name);

   if(grp != NULL)
    {
     /* Get the group id */
     strcpy(crit.name, "name");
     crit.desc.type = AC_ATTRIB_TEXT;
     strcpy(crit.desc.value.att_txt, tmp_name);
     
     status = SM$CritSel(msg		= &loc_msg,
			 options	= 0,
			 state		= SM_NEW | SM_UPD | SM_MOD,
			 type		= SM_GRP,
			 sub_type	= 0xFFFF,
			 nb_crit	= 1,
			 crit		= &crit,
			 list		= &list);
     if(!(status & loc_msg & 1)) return OM_W_ABORT;
     
     if(list.nb_objects <=0)
      {
       grp->objid = NULL_OBJID;
      }
     else
      {
       if(list.nb_objects > 1) 
         printf("Warning, more than one groups found for: %s\n", tmp_name);
	 
       *grp = list.list[0].obj_id;
       if(list.list){free(list.list);list.list = NULL;}
      }
    }   
  }

 if(sub_name)
  {
   /* Get the sub-group */
   status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "sub_grp", tmp_name, NULL),
			targetid = my_id);
   if(!(status & loc_msg & 1)) 
    {
     /* No sub-group defined !!! */
    }
   else 
    {
     strcpy(sub_name, tmp_name);
    }
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

end implementation SMcomp;
 

