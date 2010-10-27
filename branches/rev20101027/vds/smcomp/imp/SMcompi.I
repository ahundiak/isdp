/* $Id: SMcompi.I,v 1.3 2002/04/08 17:11:16 ylong Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMcompi.I
 *
 * Description:
 *
 *      Class defining the behavior of the compartments.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMcompi.I,v $
 *	Revision 1.3  2002/04/08 17:11:16  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/11/05 21:00:34  ylong
 *	Overwrite GRdelete. We need to enable it when pload.
 *	
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
 *      04/24/92        Ch. Heraud      Creation date.
 *      06/01/94        P. Lacroix      subclass under VDSroot.
 *	06/15/94	P. Lacroix	override GRgetrang (get the range of
 *					the foot "solid") because of a bug at
 *					GRowner level.
 *
 * -------------------------------------------------------------------------
 */


class implementation SMcomp;

#include "string.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grmacros.h"
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

#include "ACrg_collect.h"
#include "DIprims.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"


#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"

#include "SMcomp_def.h"
#include "SMmsg.h"

#include "AS_status.h"

from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;
from    VDSpt           import  VDgetoffset, VDsetoffset, VDsetprops, VDsettext;

extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_ACconst_class_id;
extern	GRclassid	OPP_ACrg_collect_class_id;
extern  GRclassid  	OPP_EMSgensolid_class_id, OPP_EMSblock_class_id;
extern  GRclassid  	OPP_EMSpolyhdrn_class_id, OPP_EMSsfsolid_class_id;
extern  GRclassid  	OPP_EMScylindr_class_id , OPP_EMSsphere_class_id;

#define AS_DEBUG


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract

	Place an occurence of the macro in the design file.

  Arguments
      int 		*suc       	O 	0 FAILED 1 SUCCESS

      int		prop            I 	see macro.h

      char		rep             I 	navsea representation

      char 		*macro_name	I 	the macro to place

      int 		numb_obj	I 	the number of real template

      struct GRid 	*uplist     	I 	the list of templates

      struct GRid 	*def_occ    	I 	transfer context has to be 
						performed from this default 
						occurence

      struct GRmd_env	*mod_env	I	module env

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

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

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the compartment when it
	is located (status field).

  Arguments


      IGRlong		*msg             O   	completion code
      struct GRobj_info	*info            O	structure for information about
                                 		the object


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails


 -------------------------------------------------------------------------
-mo*/


method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
 IGRlong 	status, loc_msg;
 IGRshort	type;
 IGRchar	tpipo[DI_PATH_MAX];

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "comp_type",tpipo, NULL),
 			targetid = my_id);
 if(!(status & loc_msg & 1))  tpipo[0] = '\0';  /* No type found !!! */
 if( strcmp(tpipo,"hull compartment") ) type =  SM_REG;
 else                                   type =  SM_HULL; 
 

 if(type & SM_REG) strcpy(info->type, "COMPARTMENT");
 else
  {
   status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "h_type", tpipo, NULL),
 			targetid = my_id);
   if(!(status & loc_msg & 1)) 
    {
     /* No hull type defined !!! */
     strcpy(tpipo,"STA");
    }

   if(     strncmp(tpipo,"STA", 3) == 0) strcpy(info->type, "STABILITY HULL");
   else if(strncmp(tpipo,"STR", 3) == 0) strcpy(info->type, "STRENGTH HULL");
   else if(strncmp(tpipo,"BONJ",4) == 0) strcpy(info->type, "BONJ HULL");
   else if(strncmp(tpipo,"SUBD",4) == 0) strcpy(info->type, "SUBD HULL");
   else if(strncmp(tpipo,"GRN", 3) == 0) strcpy(info->type, "GRAIN HULL");
   else 			   	 strcpy(info->type, "HULL");
  }
 
 *rc = MSSUCC;
 return	OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRdelete from VDSroot

  Abstract

	This method myself , also delete CACHE atrribute

  Arguments


      IGRlong		*msg		O   	completion code
      struct GRmd_env	*md_env		I	context info


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails


 -------------------------------------------------------------------------
-mo*/

method GRdelete( IGRlong *rc; struct GRmd_env *md_env )

{
  IGRlong		status;
  IGRint		j, nb_att, nb_roots;
  IGRchar		code[DI_PATH_MAX];

  struct ACrg_coll	code_att[3];

  struct GRid		ACdyn, cache_obj;
  
  ACdyn.objid = NULL_OBJID;
  cache_obj.objid = NULL_OBJID;
  code[0] = '\0';

  /* Get the ACrg of compartment */
  status = om$send (	msg	 = message NDnode.NDget_objects
					(ND_ROOT,&ACdyn,1,NULL, 0,0,&nb_roots),
                        targetid = my_id);
  if((status & 1))
  {
     nb_att = 3;
     strcpy(code_att[0].name,"family");
     strcpy(code_att[1].name,"partno");
     strcpy(code_att[2].name,"partrev");
     code_att[0].desc.type = AC_ATTRIB_TEXT;
     code_att[1].desc.type = AC_ATTRIB_TEXT;
     code_att[2].desc.type = AC_ATTRIB_TEXT;

     for( j = 0; j < nb_att; j++ )
     {
       code_att[j].desc.value.att_txt[0] = '\0';
       status = om$send(msg      = message ACrg_collect.ACget_named_attribute
                                                (rc,&code_att[j]),
                      targetid = ACdyn.objid,
                      targetos = ACdyn.osnum);
     }

     /* Create name of cache */
     status = SMCreateCacheCode (
                        "compartment",
                        code_att[0].desc.value.att_txt,  /* family  */
                        code_att[1].desc.value.att_txt,  /* partno  */
                        code_att[2].desc.value.att_txt,  /* partrev */
                        OM_Gw_current_OS,
                        code );

     status = di$translate (	objname = code,
				p_objid = &cache_obj.objid,
				p_osnum = &cache_obj.osnum );

     if( (status&1) && cache_obj.objid != NULL_OBJID )
     {
        gr$delete_object (	msg		= rc,
				object_id	= &cache_obj );
     }
  }
 
  status =
  om$send (	msg             = message VDSroot.GRdelete( rc, md_env ),
                targetid        = my_id,
                mode            = OM_e_wrt_message );

  return status;
}

/*+me
 -------------------------------------------------------------------------

  Public Message SMGetVolInfo

  Abstract

    	Return the list of root volumes, volume types, rg collection ids of
	the compartment.
  	The size must be allocated by the user (max volumes = SM_MAX_ALLOW_VOL).
  	If NULL is passed for volume, rg_coll or type they will not be taken
  	into account.

  	About the volume, it is the graphic objects which are returned.

  	The rg collection gather information on the volume, the type specify
  	if it is a compartment or a regular volume.


  Arguments

  IGRlong		*msg		O : Completion code.
  IGRint		list_size	I : Size of volume, rg_col, md_env
					    if they are not NULL.
  IGRint		*nb_vol		O : Number of returned elments
  IGRint		*tt_number	O : Total number of elements.
  struct GRid		*volume		O : List of root volume (can be 
					    NULL if not needed).
  struct GRid		*rg_coll	O : List of rg collections (can be 
					    NULL if not needed).
  IGRshort		*type		O : List of volume type (SM_VOLUME,
					    SM_COMPARTMENT).
  struct GRmdenv_info 	*md_env		O : list of env  (can be 
					    NULL if not needed).


  Status/Return Code
      OM_S_SUCCESS    if success.
      OM_E_ABORT      if not	

 -------------------------------------------------------------------------
-me*/

method SMGetVolInfo(IGRlong *msg; IGRint list_size, *nb_vol, *tt_number; 
		    struct GRid *volume, *rg_col; IGRshort *type;
		    struct GRmdenv_info *md_env)
{
 IGRlong		status;
 struct GRid 		*roots, vol;
 IGRint			nb_roots, i;
 struct GRmdenv_info 	obj_env;
 GRclassid		obj_class;
 extern GRclassid 	OPP_SMcomp_class_id, OPP_ACpretend_class_id;

 *tt_number = 0;
 *nb_vol    = 0;
 *msg       = MSFAIL;

 /* get the roots */
 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF, NULL, 0,
			 &roots, 0, OM_K_MAXINT, &nb_roots),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 /*  0 => rg collection 
 /*  N * (coll + vol)
 /* */

 *tt_number = (int) (nb_roots - 1) / 2;  

 for(i=2,*nb_vol=0;i<nb_roots && *nb_vol<list_size;i=i+2)
  {
   /* Get the root volumes and env */
   status = om$send(msg = message NDmacro.ACreturn_foot(msg, "",
                  	&vol, &obj_env.matrix_type, obj_env.matrix),
                        targetid = roots[i].objid,
                        targetos = roots[i].osnum );
   as$status(action = RET_STATUS);
   if(volume != NULL) volume[*nb_vol] = vol;
   if(md_env != NULL) md_env[*nb_vol] = obj_env;
    
   if(type != NULL)
    {
     /* Get the type of the root (SM_VOLUME or SM_COMPART) */
     
     om$get_classid(osnum	= vol.osnum,
                    objid 	= vol.objid,
                    p_classid 	= &obj_class );
     if(om$is_ancestry_valid(subclassid = obj_class ,
                         superclassid = OPP_SMcomp_class_id ) == OM_S_SUCCESS)
      {
       /* It is a compartment */
       type[*nb_vol] = SM_COMPARTMENT;
      }
     else
      {
       /* It is a regular volume */
       type[*nb_vol] = SM_VOLUME;
      }
    }
   if(rg_col != NULL) 
    {
     /* Get the rg coll */
     status = om$send(msg = message NDmacro.ACreturn_foot(msg, "",
                  &rg_col[*nb_vol], NULL, NULL),
                        targetid = roots[i-1].objid,
                        targetos = roots[i-1].osnum );
     as$status(action = RET_STATUS);
    }
   *nb_vol = *nb_vol + 1;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRputname from GRgraphics

  Abstract

	Stores the name of the object.

  Arguments


      IGRlong		*msg             O   	completion code
      IGRchar		*name		 I	The name of the object.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method GRputname(IGRlong *msg; IGRchar *name)
{
 IGRlong                status, loc_msg;
 IGRchar		old_name[81], *pt, *strrchr();

 status = om$send(msg = message ACncpx.GRputname(msg, name),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );
 as$status(action = RET_STATUS);

 if(name == NULL) return OM_S_SUCCESS;

 /* Get the name stored in the rg collection, compare and modify or not */
 /* */
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "name", old_name , NULL),
			targetid = my_id );
 as$status(action=RET_STATUS);
 if(loc_msg!=MSSUCC)
  {
   /* No name found ????, do nothing */
   return OM_S_SUCCESS;
  }

 if(name[0] == ':')
  {
   /* Extract the short name */
   pt = strrchr(name,':');
   if(pt == NULL)
    {
     /* ??? */
     return OM_S_SUCCESS;
    }
   pt = &pt[1];
  }
 else pt = &name[0];

 if(strcmp(old_name, pt) == 0) return OM_S_SUCCESS;

 status = om$send(msg = message SMcomp.SMModPtTxt(&loc_msg, NULL, NULL, NULL,
                                                  pt),
                  targetid = my_id );
 as$status(action = RET_STATUS);

 return OM_S_SUCCESS;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRchgname from GRgraphics

  Abstract

	Changes the name of the object.

  Arguments


      IGRlong		*msg             O   	completion code
      struct GRmd_env	*env		 I	environment of the object.
      IGRchar		*name		 I	The name of the object.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails



 -------------------------------------------------------------------------
-mo*/



method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
 IGRlong 		status, loc_msg;
 IGRchar		old_name[81], *pt, *strrchr();

 *msg = MSSUCC;
	 
 status = om$send(msg = message ACncpx.GRchgname(msg, env, name),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );
 as$status(action = RET_STATUS);

 /* Get the name stored in the rg collection, compare and modify or not */
 /* */
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg, "name", old_name , NULL),
			targetid = my_id );
 as$status(action=RET_STATUS);
 if(loc_msg!=MSSUCC)
  {
   /* No name found ????, do nothing */
   return OM_S_SUCCESS;
  }

 if(name[0] == ':')
  {
   /* Extract the short name */
   pt = strrchr(name,':');
   if(pt == NULL)
    {
     /* ??? */
     return OM_S_SUCCESS;
    }
   pt = &pt[1];
  }
 else pt = &name[0];

 if(strcmp(old_name, pt) == 0) return OM_S_SUCCESS;

 status = om$send(msg = message SMcomp.SMModPtTxt(&loc_msg, NULL, NULL, NULL,
                                                  pt),
                  targetid = my_id );
 as$status(action = RET_STATUS);
 
 return status;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
        NDparent_deleted from NDnode

  Abstract

     This message tells the element that some of the parents it depends
     upon are deleted.

     Default implementation at NDnode level is to transform the element
     to non associative by sending it the message NDnode.NDmove_to_root
     (described bellow).

     The element can check which of its roots are deleted and decide to
     rebind to non deleted roots.

     It has been overriden to keep the element associative if it is a volume
     that has been deleted (only disconnect it as well as its associated ACrg).

  Arguments

      IGRlong		 *msg             O 	completion code MSSUCC MSFAIL
      IGRint		count_deleted     I	number of deleted elements
      struct GRid	list_deleted[]    I 	list of deleted elements
      struct GRid	*new_obj          O 	new id of the element if it 
						changes
      struct GRmd_env	*md_env           I	module env info

  Notes/Remarks

     NB : If the element change id, it is up to it to transfer its
     children/root channel connection to the new object.



  Status/Return Code
      O_S_SUCCESS	if success;
      O_E_ABORT	if fails.

 -------------------------------------------------------------------------
-mo*/

method NDparent_deleted( IGRlong *msg;
                         IGRint count_deleted; struct GRid list_deleted [];
                         struct GRid *new_obj;struct GRmd_env *md_env)
{
 IGRlong 	status;
 struct GRid  	my_grid;
 IGRint		i, j, sol_index, nb_roots;
 IGRchar 	my_state;
 IGRint         cn_type;
 IGRboolean	found, regular;
 struct GRid	roots[1 + 2 * SM_MAX_ALLOW_VOL];

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 status = om$send(msg = message NDnode.NDget_state(&my_state),
                  targetid = my_id);

 if((status&1) && my_state&ND_DONT_MVRT)
  {

  /* Object to delete if no root */

   status = om$send(msg = message ACncpx.NDparent_deleted(msg, count_deleted,
				list_deleted, new_obj, md_env),
                    targetid = my_id,
                    mode = OM_e_wrt_message);
   return(status);
  }


 /* which root(s) have been deleted */
 /* Special treatement only if volume and if the number of volumes > 0 */
 /* */

 /*  0 => rg collection 
 /*  N * (coll + vol)
 /* */


 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT, roots, 
			1+2*SM_MAX_ALLOW_VOL, NULL, 0, OM_K_MAXINT, &nb_roots),
                  targetid = my_id);
 as$status();
 if((!status & 1))
  {
   printf("ERROR NDnode.NDget_objects\n");
   return (status);
  }

 
/***** Modif PL April 13 1994 *********
/*
/* don't move to root if no volume left but only disconnect the root
/* and recompute the compartment to allow the user to modify it.
/* 
/* if(nb_roots - count_deleted < 3)
/*  {
/*   /* Regular behaviour because there is no longer volume as root of the */
/*   /* compartment							 */
/*
/*
/*
/*   status = om$send(msg = message ACncpx.NDparent_deleted(msg, count_deleted,
/*				list_deleted, new_obj, md_env),
/*                    targetid = my_id,
/*                    mode = OM_e_wrt_message);
/*   return(status);
/*  }
/********/

    
 /* if rg coll => delete the object 				    */
 /* If it is a volume or a compartement, just disconnect it	    */

 
 regular = FALSE;
 for(i=0;i<count_deleted;i++)
  {

   found = FALSE;
   for(j=0;j<nb_roots;j++)
    {
     if(list_deleted[i].objid == roots[j].objid &&
        list_deleted[i].osnum == roots[j].osnum)
      {
       found = TRUE;
       if(j < 1) regular = TRUE;
       break;
      }
    }

   /* Modif PL april 12 1994: if list_deleted is not in the list of root
      forget it (otherwise the compart will be moved to root)
    */

   if(found == FALSE) continue;

   if( regular == TRUE) 
    {
     goto DEL_OBJ;
     /*
      * why don't we delete the compart instead of move_to_root ??? 
      * 
      * status = 
      * om$send(msg = message ACncpx.NDparent_deleted(msg, count_deleted,
      *				list_deleted, new_obj, md_env),
      *              targetid = my_id,
      *              mode = OM_e_wrt_message);
      * return(status);
      */
    }

   if( (j % 2) == 0) sol_index = j;
   else 	     sol_index = j+1;   /* rg of the volume */

   /* Just disconnect the object and the Rg collection */

   status = om$send(msg = message NDnode.NDdisconnect(1,&roots[sol_index]),
                     targetid = my_id);
   as$status(action = RET_STATUS);

   status = om$send(msg = message NDnode.NDdisconnect(1,&roots[sol_index-1]),
                     targetid = my_id);
   as$status(action = RET_STATUS);
  }

 /* Put it in the bacth queue for recomputation */

 cn_type = ND_COMP;
 nd$wait_batch(  type 	    = GR_GEOM_POSTED,
                 l_object   = &my_grid,
                 l_obj_info = &cn_type,
                 nb_obj     = 1);

 *msg = MSSUCC;
 return OM_S_SUCCESS;

 DEL_OBJ:

 nd$wait_batch(  type 	    = GR_DELETED,
                 l_object   = &my_grid,
                 nb_obj     = 1);

 *msg = MSSUCC;
 return OM_S_SUCCESS;

}

/*+me
 -------------------------------------------------------------------------

  Public Message SMGetCalSect

  Abstract

    Return the calculation section object depending on the compartment.
    Only one calculation section must depend on a compartment.

    If no calculation section is found CalSect is set to NULL_OBJID.


  Arguments



  IGRlong		*msg		O : Completion code.

  struct GRid		*CalSect	O : calculation section id 
					    (can be NULL).

  struct GRmdenv_info 	*md_env		O : env of the cal section 
					    (can be NULL).
  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

method SMGetCalSect(IGRlong *msg; struct GRid *CalSect;
		    struct GRmdenv_info *md_env)
{
 IGRlong		status;
 struct GRid 		*childs, obj;
 IGRint			nb_childs, i;
 struct GRmdenv_info 	obj_env;
 GRclassid		obj_class;
 extern GRclassid 	OPP_SMsection_class_id;

 *msg       = MSFAIL;
 if(CalSect != NULL) CalSect->objid = NULL_OBJID;

 /* A compartment must have only one section */

 /* get the childs */
 status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF, 
 			NULL, 0, &childs, 0, OM_K_MAXINT, &nb_childs),
                        targetid = my_id);
 as$status(action = RET_STATUS);

 for(i=0;i<nb_childs;i++)
  {
   /* Get the root volumes and env */
   status = om$send(msg = message NDmacro.ACreturn_foot(msg, "",
                  	&obj, &obj_env.matrix_type, obj_env.matrix),
                        targetid = childs[i].objid,
                        targetos = childs[i].osnum );
   as$status(action = RET_STATUS);

   /* Look for the section object */
   om$get_classid(osnum		= obj.osnum,
                  objid 	= obj.objid,
                  p_classid 	= &obj_class );
   if(om$is_ancestry_valid(subclassid = obj_class,
                         superclassid = OPP_SMsection_class_id ) == OM_S_SUCCESS)
    {
     /* Section found */
     if(CalSect != NULL) *CalSect = obj;
     if(md_env  != NULL) *md_env  = obj_env;
     break;
    }
  }
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------

  Public Message SMDiscRoots

  Abstract

    Disconect root objects (volume/compart) of an existing compartment.
    If no more graphic root object exist the output argument valid
    is set to FALSE and it is the caller who decides to delete or
    not the compartment.
    If a given DiscRoots does not match a real root, nothing is perform
    and the completion code is set to MSFAIL.


  Arguments

  IGRlong		*msg		O : Completion code. 

  IGRint              	NbRoots         I : Number of roots to be added.

  struct GRid		*DiscRoots  	I : List of roots objects.

  IGRshort            	*Valid          O : True if it remains at least
                                          one graphic objects as root.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

method SMDiscRoots(IGRlong *msg; IGRint NbRoots; struct GRid *DiscRoots; 
                   IGRshort *valid)
{
 IGRlong 	status;
 IGRint		i, j, k, nb_roots;
 struct GRid	roots[2 * SM_MAX_ALLOW_VOL];
 struct GRid	DiscList[2 * SM_MAX_ALLOW_VOL];

 /*  0 => rg collection 
 /*  N * (coll + vol)
 /* */

 *msg   = MSFAIL;
 *valid = FALSE;

 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT, roots, 
			2*SM_MAX_ALLOW_VOL, NULL, 1, OM_K_MAXINT, &nb_roots),
                  targetid = my_id);
 as$status();
 if((!status & 1))
  {
   printf("ERROR NDnode.NDget_objects\n");
   return (status);
  }

 nb_roots = nb_roots - 1; /* Start at 1 */
 k = 0;
 for(i=0;i<NbRoots;i++)
  {
   for(j=1;j<nb_roots;j=j+2)
    {
     if(DiscRoots[i].objid == roots[j].objid &&
        DiscRoots[i].osnum == roots[j].osnum)
      {
       /* Test that it is consistant */
       DiscList[k++] = roots[j];      /* graphic */
       DiscList[k++] = roots[j-1];    /* SMcoll  */
      }
    }
  }

 /* Another list is used because there is no disconnection if a given   */
 /* root to disconnect does not match an existing root                  */
 if(k != 2 * NbRoots) return OM_S_SUCCESS;

 for(i=0;i<k;i=i+2)
  {
   /* Just disconnect the object and the Rg collection */
   status = om$send(msg = message NDnode.NDdisconnect(1, &DiscList[i]),
                     targetid = my_id);
   as$status(action = RET_STATUS);

   status = om$send(msg = message NDnode.NDdisconnect(1, &DiscList[i+1]),
                     targetid = my_id);
   as$status(action = RET_STATUS);
  }
  
 /* Is there still some graphic roots */
 if((nb_roots - k) > 1) *valid = TRUE;
 else                   *valid = FALSE;

 *msg   = MSSUCC;
 return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------

  Public Message SMAddRoots

  Abstract

    Add new roots (SMcoll and volume/compart) to an existing compartment.
    The NewRoots argument is a list of (collection and graphic objects). 
    The graphic objects must already be an associative object.


  Arguments

  IGRlong		*msg		O : Completion code.

  IGRint              	NbRoots         I : Number of roots to be added.

  struct GRid		*NewRoots  	I : List of roots objects.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails


 -------------------------------------------------------------------------
-me*/


method SMAddRoots(IGRlong *msg; IGRint NbRoots; struct GRid *NewRoots)
{
 IGRlong 	status;
 struct GRid    original;

 *msg   = MSFAIL;

 /* NbRoots must be even           */
 /* NewRoots[i]   SMcoll           */
 /* NewRoots[i+1] SMcomp or Volume */

 if((NbRoots % 2) != 0) return OM_W_ABORT;

 /* Should test the class ... */

 original.objid = NULL_OBJID; 

 status = om$send(msg = message NDnode.NDconnect(NbRoots, NewRoots, original, ND_ADD),
                     targetid = my_id);
 as$status(action = RET_STATUS);
 
 *msg   = MSSUCC;
 return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------

  Public Message SMModPtTxt

  Abstract

  This message modifies the parameters linked to the point text (cog foot). 
  This avoid a full recompute of the macro when modifying only display 
  attributes.

  Arguments

  IGRlong		*msg		O : Completion code. 

  IGRshort            	*x_offset       I : x offset (window) in pixels
                                          (NULL if no modification).

  IGRshort            	*y_offset       I : y offset (window) in pixels
                                          (NULL if no modification).

  IGRshort            	*props          I : Point text properties
                                          (NULL if no modification).

  IGRchar             	*text           I : New text definition.


  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-me*/


method SMModPtTxt(IGRlong *msg; IGRshort *x_offset, *y_offset, *props;
                   IGRchar *text)
{
 IGRlong 	        status, loc_msg;
 IGRshort               XOff, YOff, type;
 IGRchar		*pt,FootName[20];
 IGRint                 i;
 struct GRid            obj;

 *msg   = MSFAIL;

 type = SM_SYST_ATT | SM_DYNAMIC_ATT;

 /* Get all the cog feet */
 strcpy(FootName,"cog");
 for(i=0;i<SM_MAX_ALLOW_VOL+1;i++)
  {
   if(i>0) sprintf(FootName,"cog%d",i);

   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, FootName,
                  	&obj, NULL, NULL),
                        targetid = my_id);
   if(!(status & loc_msg & 1)) break;
 
   if(x_offset != NULL || y_offset != NULL)
    {
     status = om$send(msg = message VDSpt.VDgetoffset(&XOff, &YOff),
                        targetid = obj.objid,
			targetos = obj.osnum);
     as$status(action = RET_STATUS);
   
     if(x_offset != NULL) 
      {
       XOff = *x_offset;
       if(i==0)
        {
         status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "x_offset", 
                                                   (IGRdouble) XOff, type),
			targetid = my_id );
         as$status(action=RET_STATUS);
	}
      }
     if(y_offset != NULL) 
      {
       YOff = *y_offset;
       if(i==0)
        {
         status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "y_offset", 
                                                   (IGRdouble) YOff, type),
			targetid = my_id );
         as$status(action=RET_STATUS);
	}
      }
   
     status = om$send(msg = message VDSpt.VDsetoffset(XOff, YOff),
                        targetid = obj.objid,
			targetos = obj.osnum);
     as$status(action = RET_STATUS);
    } 

   if(props)
    {
     IGRshort pipo;

     pipo = 0;
     if(i==0)
      {
       /* Compartment cog */
       if(!(*props & SM_CMP_DSP_CMP_COG_PT))   pipo |= VD_NO_DISP_PT;
       if(!(*props & SM_CMP_DSP_CMP_COG_NAME)) pipo |= VD_NO_DISP_TXT;
      }
     else
      {
       /* volume cog */
       if(!(*props & SM_CMP_DSP_RT_COG_PT))   pipo |= VD_NO_DISP_PT;
       if(!(*props & SM_CMP_DSP_RT_COG_NAME)) pipo |= VD_NO_DISP_TXT;
      }

     pipo = pipo | (*props & 0x00F0);

     status = om$send(msg = message VDSpt.VDsetprops(pipo),
                        targetid = obj.objid,
			targetos = obj.osnum);
     as$status(action = RET_STATUS);

     status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "cmp_props", 
                                                      *props, type),
			targetid = my_id );
     as$status(action=RET_STATUS);
    }

   if(text)
    {
     /* Update the attribute */
     pt = strrchr(text,':');
     if(pt == NULL) pt = &text[0];
     else           pt = &pt[1];

     status = om$send(msg = message VDSpt.VDsettext(text),
                        targetid = obj.objid,
			targetos = obj.osnum);
     as$status(action = RET_STATUS);

     if(i==0)
      {
       status = om$send(msg = message SMmgr.SMSetAttTxt(&loc_msg, "name", pt, type),
			targetid = my_id );
       as$status(action=RET_STATUS);
      }
    } 
  }
 *msg   = MSSUCC;
 return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        NDcompute_node from NDnode

  Abstract

     	this method is designed to recompute a node after a change of the
     	elements whose the node is depending upon.

	It has been overriden to call a ppl file for the computed
	attributs.

  Arguments

     IGRlong		*msg		 O 	 completion code
     IGRint		cn_type		 I	 reserved for future use
     IGRint		count		 I	 nb of roots
     struct GRid	list[]		 I	 list of roots of the object.
     struct GRmd_env	*md_env		 I	 Environment info.

  Status/Return Code
      OM_S_SUCCESS	if success;
      OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method NDcompute_node ( IGRlong *msg; IGRint cn_type;
		       IGRint count; struct GRid list [];
		       struct GRmd_env *md_env)
{
  IGRint status;
  IGRlong loc_msg;
  char    val_txt[80];
  IGRint  cmp_type;

  status = om$send(msg = message SMAttMgr.NDcompute_node
		   (msg,cn_type,count,list,md_env),
		   targetid = my_id,
		   mode     = OM_e_wrt_message);
  if(!(status & *msg & 1)) return status;

  /* Verify it's a real compartment and call PPL attribut in this case */
  if(VDSGetAttTxt(&list[0], "comp_type", val_txt) == 0) val_txt[0] = '\0';

  if( strcmp(val_txt,"hull compartment")) cmp_type =  SM_REG;
  else                                    cmp_type =  SM_HULL;
  
   /* Set PPL attribut */
 if(cmp_type == SM_REG)
  {
    IGRchar          ppl_name[80];
    struct GRid      comp_id;
    struct GRid      vol_id;

    comp_id.objid = my_id;
    comp_id.osnum = OM_Gw_current_OS;
    
    ppl_name[0] = '\0';
    if(SMGetPPlAttr(ppl_name) && ppl_name[0] != '\0') 
     {
       struct GRmd_env vol_env;

       status = om$send(msg = message NDmacro.ACreturn_foot
			(&loc_msg,"sol",&vol_id,
			 &vol_env.md_env.matrix_type,vol_env.md_env.matrix),
			targetid = my_id);
       if(!(status & loc_msg & 1))
	{
	  printf("Error NDmacro.ACreturn_foot Object %d,%d\n",
		 my_id,OM_Gw_current_OS);
	  
	  *msg = ND_COMP_FAIL; 
	  return status;
	}

       status = SMSetUserAtt(ppl_name,              /* ppl file name */
			     &comp_id,              /* Compartment id */	
			     &vol_id,               /* Volume id */
			     md_env);               /*compartment mod env */
    
       if(!(status & 1))
	{ex$message(msgnumb = SM_E_CmPPlFile,type="%s",var=`ppl_name`);}
       
     }
  }

  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        GRgetrang from GRgraphics

  Abstract

     	this method retrieves the range of the object.

	It has been overriden because of a bad behavior at GRowner level.
	Here, it sends the message to the foot "solid".

  Arguments

     IGRlong		*msg		 O 	 completion code

     IGRshort		*matrix_type	 O	type of environment matrix
     IGRmatrix		matrix		 O	environment matrix.
     IGRboolean		*world           O	indicator of whether the range 
						should be computed in world or 
						local coordinates.
                                  		1 : apply the environment matrix
                                  		0 : do not apply the 
						    environment matrix
     GRrange		range            O 	range of the object.

  Status/Return Code
      OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-mo*/


method GRgetrang (IGRlong *msg; 
                  IGRshort *matrix_type;
                  IGRmatrix matrix; 
                  IGRboolean *world; 
                  GRrange range)
{
IGRint		status;
struct GRid	mySolid;
IGRdouble	mat[16];
IGRshort	mat_type;

 status = om$send(msg = message NDmacro.ACreturn_foot(msg, "sol", &mySolid,
						    &mat_type, mat),
			targetid= my_id ) ;
 as$status(sts = status, action = GOTO_VALUE, value = wrapup);
 if( !( status & (*msg) & 1 ) ) goto wrapup;

 status = om$send(msg = message GRgraphics.GRgetrang(msg, matrix_type, matrix,
						world, range),
			senderid = NULL_OBJID,
			targetid = mySolid.objid,
			targetos = mySolid.osnum) ;
 return status;

 wrapup:

 status = om$send(msg = message GRowner.GRgetrang(msg, matrix_type, matrix,
						world, range),
		mode = OM_e_wrt_message,
		targetid= my_id ) ;
 return status;
 
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjCompart ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMcomp;
 

