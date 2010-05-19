/* $Id: SMwindi.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/imp / SMwindi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMwindi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
/*  History :
/*	CH  : 15 Jul 92	  creation date.
/*
/* */

class implementation SMwind;

#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"
#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "SMcomp_def.h"

#include "AS_status.h"

from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;

#define AS_DEBUG

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def(int *rc, prop; 	char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
 IGRlong status;

 /* Put the properties to no proptect:
 /*	- Does not create source,
 /*	- Does not verify the number (variable number of templates) 
 /*	- Does not verify the template types
 /* */
 prop = prop | AChdr_noprotect | ACcant_place_sym;
 status = om$send(msg = message ACncpx.ACmplace_from_def(rc, prop, rep, 
		         macro_name, num_temp, temp_list, def_occ, md_env),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );
 as$status(action = RET_STATUS);

 /* Create as a new one */
 status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
                  targetid = my_id );
 as$status(action = RET_STATUS);
 
 return	OM_S_SUCCESS;
}


/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
 strcpy(info->type, "WIND AREA PLG");

 *rc = MSSUCC;
 return	OM_S_SUCCESS;
}

/* ********************* MSG NDmove_to_root () *******************	*/

method NDmove_to_root (	IGRlong *msg; 
			struct GRid *src_grid;
                       	struct GRmd_env *md_env )
{
 IGRlong 	status;
 struct GRid  	my_grid;
 IGRint		i, nb_roots, del_root;
 IGRchar 	my_state;
 IGRint         cn_type;
 struct GRid	roots[2+SM_MAX_ALLOW_PLG];
 IGRint		ColDelList[SM_MAX_ALLOW_PLG];

 extern struct ext_list NDdelete;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 status = om$send(msg = message NDnode.NDget_state(&my_state),
                  targetid = my_id);
 if((status&1) && my_state&ND_DONT_MVRT)
   {
    /* Object to delete if no root */
    status = om$send(msg = message ACncpx.NDmove_to_root(msg,src_grid,md_env),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
    return(status);
   }


 /* which root(s) have been deleted */
 /* Special treatement only if the number of line strings > 0 */
 /* */

 /*  0 => rg collection 
 /*  1 => cs
 /*  N * (line strings)
 /* */

 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT, roots, 
			2+SM_MAX_ALLOW_VOL, NULL,0,OM_K_MAXINT,&nb_roots),
                  targetid = my_id);
 as$status();
 if((!status & 1))
  {
   printf("ERROR NDnode.NDget_objects\n");
   return (status);
  }

 if(nb_roots < 2)
  {
   /* Strange ... */

   status = om$send(msg = message ACncpx.NDmove_to_root(msg,src_grid,md_env),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
   return(status);
  }
    
 /* if rg coll or dead weight or group deleted => delete the object */
 if(NDin_buffer(roots[0], &NDdelete) != -1 ||
    NDin_buffer(roots[1], &NDdelete) != -1)
  {
   status = om$send(msg = message ACncpx.NDmove_to_root(msg,src_grid,md_env),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
   return(status);
  }

 /* If a root line string has been deleted, recompute the compart
 /* and the dependency
 /* */
 del_root = 0;
 for(i=2;i<nb_roots;i=i+1)
  {
   if(NDin_buffer(roots[i], &NDdelete) != -1)
    {
     /* Just disconnect the objects */

     status = om$send(msg = message NDnode.NDdisconnect(1,&roots[i]),
                     targetid = my_id);
     as$status(action = RET_STATUS);

     /* Keep track of the deleted components */
     ColDelList[del_root++] = i-2;
    }
  }
 
 if(del_root > 0)
  {
   if(nb_roots - del_root < 3)
    {
     /* No more line string ... */
     status = om$send(msg = message ACncpx.NDmove_to_root(msg,src_grid,md_env),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
     return(status);
    }

   /* Update the Dynamic collection */
   if(SMWindUpdCol(&roots[0], ColDelList, del_root, nb_roots - 2) != 1)
    {
     printf("Wind area polygon, Error updating attributes\n");
    }

   /* Put it in the bacth queue */
   cn_type = ND_COMP;
   nd$wait_batch(type 	    = GR_GEOM_POSTED,
                 l_object   = &my_grid,
                 l_obj_info = &cn_type,
                 nb_obj     = 1);

   /* Change the state to modify */
   status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
   as$status();

  }
 else
  {
   /* Not parent deleted. It should be a direct move_to_root */
   status = om$send(msg = message ACncpx.NDmove_to_root(msg,src_grid,md_env),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
   return(status);
  }
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/*
/* SMWindUpdCol:
/*
/*   Thus function modify the collection gathering attributes information
/*   in case of deletion of roots. 
/*
/*   index is the correspondig indexes to the deleted root.
/*
/*   This does not take into account the user defined attributes.
/*   (only  "p_no", "p_type", "s_coef", "c_coord", "desc").
/*
/*   Return TRUE if OK.
/*
/* */

SMWindUpdCol(Col, index, nb_index, nb_tt)
struct GRid 	*Col;	/* Collection id			(I) */
IGRint		*index; /* Index of the delete object		(I) */
IGRint		nb_index; /* Number of objects to removed	(I) */
IGRint		nb_tt;  /* Maximum number of attributes info	(I) */
{
 IGRint    NewList[SM_MAX_ALLOW_PLG];
 IGRint	   k, i, del, j;

 k = 0;
 for(i=0;i<nb_tt && i<SM_MAX_ALLOW_PLG; i++) 
  {
   del = 0;
   for(j=0;j<nb_index;j++)
    {
     if(index[j] == i)
      {
       /* Rem attributes */
       del = 1;
       break;
      }
    }
   if(del == 0) NewList[k++] = i;
  }

 for(i=0;i<k;i++)
  {
   if(i == NewList[i]) continue;

   if(SMWindUpdCol1(Col, "p_no"   , i, NewList[i]) != 1) return 0;
   if(SMWindUpdCol1(Col, "p_type" , i, NewList[i]) != 1) return 0;
   if(SMWindUpdCol1(Col, "s_coef" , i, NewList[i]) != 1) return 0;
   if(SMWindUpdCol1(Col, "c_coord", i, NewList[i]) != 1) return 0;
   if(SMWindUpdCol1(Col, "desc"   , i, NewList[i]) != 1) return 0;
  }
 return 1;
}

SMWindUpdCol1(Col, name, index1, index2)
struct GRid 	*Col;	/* Collection id			(I) */
IGRchar		*name;  /* Attribute name to modify		(I) */
IGRint		index1;  /* Index of the to object		(I) */
IGRint		index2;  /* Index of the from object		(I) */
{
 IGRlong		sts, loc_msg;
 struct ACrg_coll 	att;


 sprintf(att.name, "%s_%d", name, index2);
 sts = om$send(msg = message ACrg_collect.ACget_named_attribute(&loc_msg, &att),
 			senderid = NULL_OBJID,
			targetid = Col->objid,
			targetos = Col->osnum);
 if(!(sts & loc_msg & 1)) return 0;

 sprintf(att.name, "%s_%d", name, index1);

 sts = om$send(msg = message ACrg_collect.ACmod_list_attribute(&loc_msg, 1, &att),
 			senderid = NULL_OBJID,
			targetid = Col->objid,
			targetos = Col->osnum);
 if(!(sts & loc_msg & 1)) return 0;
 
 return 1;
}



/* ********************* MSG SMGetWindPlgs() *******************	*/

method SMGetWindPlgs(IGRlong *msg; IGRint ListSize, *NbPlgs, *TtNumber; 
		      struct GRid *Plgs; struct GRmdenv_info *MdEnv)
{
 IGRlong		status, loc_msg;
 struct GRid 		plg;
 IGRshort		matrix_type;
 IGRdouble		matrix[16];
 IGRint			i, k;
 char 			tmpchar[81];

 *TtNumber = 0;
 *NbPlgs   = 0;
 *msg      = MSFAIL;

 i=1;
 while(1)
  {
   sprintf(tmpchar,"plg%d",i);

   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, tmpchar,
                    &plg, &matrix_type, matrix),
                        targetid = my_id);
   if(!(status & loc_msg & 1)) break;
   
   (*TtNumber) ++;

   if(ListSize >= i)
    {
     if(Plgs  != NULL) Plgs[*NbPlgs] = plg;
     if(MdEnv != NULL)
      {
       MdEnv[*NbPlgs].matrix_type = matrix_type;
       for(k=0;k<16;k++) MdEnv[*NbPlgs].matrix[k] = matrix[k];
      }
     (*NbPlgs)++;
    }
   i++;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}




/* ********************* MSG SMWindAddPlg() *******************	*/

method SMWindAddPlg(IGRlong *msg; struct GRid *root; IGRint NbAtt; 
                    struct ACrg_coll *att)
{
 IGRlong		 status, loc_msg;
 struct GRid            *roots, original, col;
 IGRint                  nb_roots, i, index;
 IGRboolean              update;
 IGRshort                type;

 *msg = MSFAIL;

 /* Verify if the object is already a root */
 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL, 0,
                         &roots, 0, OM_K_MAXINT, &nb_roots),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 update = FALSE;
 for(i=2;i<nb_roots;i++)
   if(roots[i].objid == root->objid && roots[i].osnum == root->osnum)
    {
      update = TRUE;
      break;
    }
 
 col = roots[0];
 index = i - 2;  /* Index of the object */

 /* Modify the name to take into account the way they are stored */
 for(i=0;i<NbAtt;i++) sprintf(att[i].name,"%s_%d",att[i].name,index);

 if(update)
  {
   /* Just update the attributes */
   type = 1;
   for(i=0;i<NbAtt;i++)
    {
     status = om$send(msg = message SMmgr.SMSetAtt(&loc_msg, 1, &att[i], &type),
                                targetid = my_id);
     if(!(status &1)) return OM_W_ABORT;
     if(loc_msg != MSSUCC)
      {
       printf("Wind Area Plg, Erreur updating: %s\n", att[i].name);
       continue;
      }
    }
  }
 else
  {
   /* Add a new one */ 
   original.objid = NULL_OBJID;
   status = om$send(msg = message NDnode.NDconnect(1, root, original, ND_ADD),
                            targetid = my_id);
   if(!(status & 1)) return OM_W_ABORT;

   /* Add the attributes */
   status = om$send(msg = message ACrg_collect.ACadd_list_attribute(&loc_msg,
                                                NbAtt, att),
                                targetid = col.objid,
				targetos = col.osnum);
   if(!(status & loc_msg & 1)) 
    {
     printf("Wind Area, cannot add this object\n");
     status = om$send(msg = message NDnode.NDdisconnect(1,root),
                     targetid = my_id);
     return OM_W_ABORT;
    }
  }
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}



/* ********************* MSG SMWindRemPlg() *******************	*/

method SMWindRemPlg(IGRlong *msg; struct GRid *root; IGRint *NbExist)
{
 IGRlong		 status;
 struct GRid            *roots;
 IGRint                  nb_roots, i, CurIndex;

 *msg = MSFAIL;

 /* Get the index and the number of roots */
 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL, 0,
                         &roots, 0, OM_K_MAXINT, &nb_roots),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 *msg = MSFAIL;

 if(NbExist) *NbExist = nb_roots - 2;

 CurIndex = -1;
 for(i=2;i<nb_roots;i++)
  {
   if(roots[i].objid != root->objid || roots[i].osnum != root->osnum) continue;
   CurIndex = i;
   break;
  }

 if(CurIndex == -1) return OM_S_SUCCESS;
                                                     
 if(SMWindUpdCol(&roots[0], &CurIndex, 1, nb_roots - 2) != 1)
  {
   printf("Error updating the attributes\n");
   return OM_W_ABORT;
  }

 /* Disconnect */
 status = om$send(msg = message NDnode.NDdisconnect(1,root),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 if(NbExist) *NbExist = *NbExist - 1;

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ********************* MSG SMWindGetInfo() *******************	*/

method SMWindGetInfo(IGRlong *msg; IGRint *index; struct GRid *root;
                     IGRint *NbAtt; struct ACrg_coll *att)
{
 IGRlong		 status, loc_msg;
 struct GRid            *roots;
 IGRint                  nb_roots, i, CurIndex;
 IGRshort                type[SM_WIND_NB_MAX_ATTR];
 char                    *p;

 *msg = MSFAIL;

 /* Verify if the object is already a root */
 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL, 0,
                         &roots, 2, OM_K_MAXINT, &nb_roots),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 nb_roots -= 2; /* Start at one */


 *msg = MSFAIL;
 if(NbAtt) *NbAtt = 0;
 
 CurIndex = -1;
 if(index != NULL && *index != -1)
  {
   /* Index way */
   if(*index < 0 || *index >= nb_roots) return OM_S_SUCCESS;
   if(root) *root = roots[*index];
   CurIndex = *index;
  }
 else if(root != NULL && root->objid != NULL_OBJID)
  {
   /* root id way */
   for(i=0;i<nb_roots;i++)
    {
     if(roots[i].objid != root->objid || roots[i].osnum != root->osnum) continue;
     CurIndex = i;
     break;
    }
   if(CurIndex == -1) return OM_W_ABORT;
   if(index) *index = CurIndex; 
  }

 if(NbAtt == NULL || att == NULL) { *msg = MSSUCC; return OM_S_SUCCESS; }

 /* Assomption that there is no user attribute */
 *NbAtt = 0;
 SMWindFillPlg(NbAtt, att, CurIndex);
 
 status = om$send(msg = message SMmgr.SMGetAtt(&loc_msg, *NbAtt, att, type),
                            targetid = my_id);

 if(!(status & loc_msg & 1)) return OM_W_ABORT;

 /* Add by Jean : Supress index of polygon in attribute name */
 for(i=0; i< *NbAtt; i++)
  {
    p  = strrchr(att[i].name,'_');
    if(p) *p = '\0';
  } 

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjWind ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/



end implementation SMwind;
 

