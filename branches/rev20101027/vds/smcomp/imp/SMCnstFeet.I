/* $Id: SMCnstFeet.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCnstFeet.I
 *
 * Description:
 *
 *	File implementing the ACconstruct_feet for the compartments.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMCnstFeet.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/01/07  16:26:08  pinnacle
# tr179900037
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/05  15:32:58  pinnacle
# Replaced: smcomp/imp/SMCnstFeet.I for:  by v250_int for vds
#
# Revision 1.2  1998/02/20  17:45:14  pinnacle
# Replaced: smcomp/imp/SMCnstFeet.I for:  by impd for vds
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
 *	06/15/94	P. Lacroix	Correct a bug on the computation of
 *					the cog of the volume.
 *	04/05/98	vini 		TR179800514
 *      01/07/99        ah              TR179800037 Better message when fails
 * -------------------------------------------------------------------------
 */

class implementation SMcomp;

#include <string.h>
#include <ctype.h>
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h" 
#include "emsmass.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "SMcomp_def.h"

#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"

#include "SMmsg.h"

#include "AS_status.h"

from	ACrg_collect	import  AClist_attribute;
from	Gexp		import	create;
from	EMSsfboolean	import	EMboolean;
from	EMSdpr		import	EMmake_primitive1;
from    EMSsurface      import  EMgetactiveid;
from    EMSsubbs        import  EMreduce_range;

extern	GRclassid	OPP_EMSslboolean_class_id;
extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_ACconst_class_id;
extern	GRclassid	OPP_ACrg_collect_class_id;
extern  GRclassid  	OPP_EMSgensolid_class_id, OPP_EMSblock_class_id;
extern  GRclassid  	OPP_EMSpolyhdrn_class_id, OPP_EMSsfsolid_class_id;
extern  GRclassid  	OPP_EMScylindr_class_id , OPP_EMSsphere_class_id;

extern short _Pathway, _pathway_trim, _pathway_orient;
static short sav_pathway_trim, sav_pathway_orient;

%safe
static	IGRboolean 	emsBooleanStatus;
%endsafe

#define AS_DEBUG


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACconstruct_feet from ACncpx

  Abstract

	Generates the resultant feet set, given the compute parameters.
    	A NUL_LOBJID or a short list in feet_list are considered as temporary
 	missing feet. A corresponding error is given to give foot access.


  Arguments

	IGRlong 	*rc; 		 O	MSSUCC if success, MSFAIL 
						if not.

	IGRint 		cn_type; 	 I	reserved for future use

        IGRint 		count; 		 I	number of roots

	struct GRid 	list[];	         I    	list of roots the element is
						depending.

	struct GRmd_env *md_env;	 I	current md_env

	IGRint 		*fcount; 	 O	Number of feet (can be less
						than declared)

	struct GRid 	*feet_list	I/O	This array array is initialized
						at input to the nb of declared 
						feet. The method fills the 
						array.

  Notes/Remarks

  Root list:
 
 	- Dynamic collection (description, location, comp_flag, ...).
 	- N * [root dynamic collection + root volume or compartment].
 
 
  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/


method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 IGRlong 		status, msg, loc_msg;
 IGRint			index, i, kk, j;
 IGRchar		name[81],val_txt[80];
 IGRdouble		struct_coef, dpipo;
 IGRint			cmp_props, overlap;
 IGRshort		cmp_type, x_offset, y_offset;
 
 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level;
 
 struct	GRvg_construct  cst;
 IGRchar		s_exclude[80];

 struct GRid		vol_id[SM_MAX_ALLOW_VOL], col_id[SM_MAX_ALLOW_VOL];
 struct GRmdenv_info	obj_env[SM_MAX_ALLOW_VOL];
 IGRshort		obj_type[SM_MAX_ALLOW_VOL];

 IGRint			nb_vol, tt_vol;
 IGRdouble 		props[NUMB_PROPS];

 IGRint      		nb_exc, nb_inc;
 GRobjid		exc_list[SM_MAX_ALLOW_VOL], inc_list[SM_MAX_ALLOW_VOL];
 GRobjid		*pt_list;

 unsigned short  	option;

 char			status_str[80];
 IGRdouble 		volume;

 enum EMSbooltype  	bool_type;
 struct GRid 		tmp_id, NewId;
 struct GRid            active_id, top_lm_id;

 struct ret_struct      ret;

 struct GRmd_env	cp_env, tmp_env;
 struct
  {
   IGRshort	type;			/* SM_VOLUME, SM_COMPARTMENT, 0 */
   IGRchar	exclude;		/* Y(es) or N(o) 		*/	
   IGRdouble	struct_coef;
   IGRdouble 	volume;			/* real computed volume		*/
   IGRdouble 	area;			/* Total area			*/
   IGRdouble 	FlrArea;		/* Floor area			*/
   IGRdouble 	cog[3];			/* cog				*/
   struct GRid  *obj;			/* Pointeur to root object	*/
   struct GRid  cp_obj;			/* Pointeur to root object	*/
   struct GRid  comp_obj;		/* compartment oid		*/
   struct GRmdenv_info *obj_env;	/* Obj env			*/
  } vol_info[SM_MAX_ALLOW_VOL+1];    	/* Index 0 for the compartment	*/

  IGRchar err_msg[128]; // TR179800037
  IGRchar err_buf[128];
  
 *fcount = 0;
 *rc     = 0;
 overlap   = 0;

 emsBooleanStatus = TRUE;

 sprintf(err_msg,"Compartment %d Recompute Failed,",my_id);
 
 /* Jean 17 Aug 93                                                          */
 /* Try to see if we can retrieve all attributes . (We just try on number). */
 /* If Fail it means probably a problem with database                       */

 status = om$send(msg = message ACrg_collect.AClist_attribute
		  (&loc_msg,0,NULL,&i),
		  targetid =  list[0].objid,
		  targetos =  list[0].osnum);
 if(!(status & loc_msg & 1)) {
   sprintf(err_buf,"%s when getting attributes",err_msg);
   printf("%s\n",err_buf);
   UI_status(err_buf);   
   goto wrapup;
 }
 
 if(VDSGetAttDbl(&list[0], "cmp_props", &struct_coef) == 0) 
  {
   /* Take all */ 
   cmp_props = SM_CMP_DSP_RT_COG_PT  | SM_CMP_DSP_RT_COG_NAME |
               SM_CMP_DSP_CMP_COG_PT | SM_CMP_DSP_CMP_COG_NAME|
	       SM_CMP_CAL_VOLS	     | SM_CMP_VRF_OVER	      | SM_CMP_X_POS;
  }
 else cmp_props = (int) struct_coef;

 /* Get the compartment dynamic information */
 if(VDSGetAttTxt(&list[0], "name", name) == 0) 
  {
   name[0] = '\0';
  }
 sprintf(err_msg,"Compartment %s,%d Recompute Failed, ",name,my_id);
 
 if(VDSGetAttDbl(&list[0], "struct_coef", &struct_coef) == 0) 
  {
   struct_coef = -1;
  }

 
 if(VDSGetAttTxt(&list[0], "comp_type", val_txt) == 0) val_txt[0] = '\0';
 if(val_txt[0]=='\0' || strcmp(val_txt,"compartment") == 0) cmp_type =  SM_REG;
 else                                                       cmp_type =  SM_HULL;
 
 /* Set the construction list (get the active symb) .
 /* */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = md_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;


 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg     = &loc_msg,
                       sizbuf  = &sizebuf,
                       buffer  = &display,
                       nret    = &nret);

 /*| get the active level */
 sizebuf = sizeof(IGRshort);
 gr$get_active_level(msg     = &loc_msg,
                     sizbuf  = &sizebuf,
                     buffer  = &level,
                     nret    = &nret);
 cst.display    = &display;
 cst.level      = level;

 
 /* Loop for each root :
 /* 	- Get if redefined the struct coefficient.
 /*	- Get the volume or compart attributes.
 /*	- Get the volume or compart object.
 /*	- Copy the volume object.
 /*	- Create the cog point.
 /* 	- Compute the volume and area of the object.
 /*	
 /* */

 status = om$send( msg = message SMcomp.SMGetVolInfo(&msg, SM_MAX_ALLOW_VOL, 
			&nb_vol, &tt_vol, vol_id, col_id, obj_type, obj_env),
			targetid = my_id);

 for(index=0; index<nb_vol; index=index+1)
  {
   int 	v_ind;
   
   v_ind = index+1;
   /* Get if exist the struct coef */   
   if(VDSGetAttDbl(&col_id[index], "struct_coef", &vol_info[v_ind].struct_coef) == 0) 
    {
     vol_info[v_ind].struct_coef = struct_coef;
     if(struct_coef < 0 || struct_coef > 1)
      {
	sprintf(err_buf,"%s bad structure coefficient",err_msg);
	printf("%s\n",err_buf);
	UI_status(err_buf);   
	goto wrapup;
      } 
    }

   if(VDSGetAttTxt(&col_id[index], "exclude", s_exclude) == 0) 
    {
      sprintf(err_buf,"%s exclude flag not found",err_msg);
      printf("%s\n",err_buf);
      UI_status(err_buf);   
      goto wrapup;
    }
   if(s_exclude[0] == 'y' || s_exclude[0] == 'Y') vol_info[v_ind].exclude = 'Y';
   else						  vol_info[v_ind].exclude = 'N';
   
   /* Test if volume or compart */
   if(obj_type[index] == SM_COMPARTMENT)
    {
     /* It is a compart */
     /* The compart must have only one graphic volume */
     vol_info[v_ind].type = SM_COMPARTMENT;
     vol_info[v_ind].comp_obj = vol_id[index];
     status = om$send(msg = message NDmacro.ACreturn_foot(&msg, "sol", &vol_id[index],
     			  &obj_env[index].matrix_type, obj_env[index].matrix),
                        targetid = vol_id[index].objid,
                        targetos = vol_id[index].osnum );
     if(!(status & msg & 1))
      {
	sprintf(err_buf,"%s error getting root compartment solid",err_msg);
	printf("%s\n",err_buf);
	UI_status(err_buf);   
	goto wrapup;
      } 
    }
   else
    {
     /* Compute the mass prop ... */
     vol_info[v_ind].type = SM_VOLUME;
    }
   vol_info[v_ind].obj     = &vol_id[index];
   vol_info[v_ind].obj_env = &obj_env[index];
  }

 nb_vol ++; /* Take into account the info of the construct result */

 /* Create the union (disjoint) with all the includes and after create
 /* a difference with the result and the excludes. First need to make
 /* a copy.  */

 nb_exc = -1;
 nb_inc = -1;
 
 /* The environnent of the copied object (Does need to add in the Rtree)
 /* => cp_env.md_id.objid = NULL_OBJID;
 /*
 /* After they have been copied, a compress tree (if needed) is performed.
 /* */
 cp_env.md_id.objid = NULL_OBJID;
 cp_env.md_id.osnum = md_env->md_id.osnum;
 cp_env.md_env      = md_env->md_env;

 for(i=1;i<nb_vol;i++)
  {  
   struct GRmd_env  from_env;

   from_env.md_id.objid = NULL_OBJID;
   from_env.md_id.osnum = (*vol_info[i].obj).osnum;

   from_env.md_env = *(vol_info[i].obj_env);
   if(vol_info[i].exclude == 'Y') pt_list = &exc_list[++nb_exc];
   else				  pt_list = &inc_list[++nb_inc];
 
   /* Put the ASbrodcast in progess to TRUE to avoid copy of sub grpah */
   vol_info[i].cp_obj.osnum = cp_env.md_id.osnum;
   status = om$send(msg = message GRgraphics.GRcopy(&msg, &from_env,
                                          &cp_env, &vol_info[i].cp_obj.objid),
                        targetid = (*vol_info[i].obj).objid,
	                targetos = (*vol_info[i].obj).osnum);
   if(!(status & msg &1))
    {
      sprintf(err_buf,"%s error in GRcopy",err_msg);
      printf("%s\n",err_buf);
      UI_status(err_buf);   
      goto wrapup;
    }

   /* *pt_list = vol_info[i].cp_obj.objid; */

/* I really don't remember why I make the compress tree here. I think
 * that it should be done only if no boolean operation are made else
 * it is done afterwards.
 */
 

   /* Compress tree ... */
   status = om$send(msg = message EMSsurface.EMgetactiveid(&msg, 
                            &active_id, &top_lm_id),
                        targetid = vol_info[i].cp_obj.objid,
                        targetos = vol_info[i].cp_obj.osnum);
   if(!(status & msg & 1)) 
    { 
     /* Really strange but not really important */
     *pt_list = vol_info[i].cp_obj.objid;
    }
   else
    {
     /* This compress the dpr tree and compress the range box */
     status = om$send(msg = message EMSdpr.EMmake_primitive1(&msg, &cp_env,
                                &tmp_id),
	        targetid = active_id.objid,
		targetos = active_id.osnum);
     if(!(status & 1))  *pt_list = vol_info[i].cp_obj.objid;
     else 		*pt_list = tmp_id.objid;
    }
  }
 nb_exc++;
 nb_inc++;
 
 if(nb_inc < 1) 
 {
   sprintf(err_buf,"%s need at least one include volume",err_msg);
   printf("%s\n",err_buf);
   UI_status(err_buf);   
   goto wrapup;
 }

 if(nb_vol == 2)
  {
   /* Easy case, only one root, just put the copy as foot */

   /* if(md_env->md_id.objid != NULL_OBJID)
   /* {
   /*  printf("The object must be added to the Rtree\n");
   /* }
   /* */

   /* MAKE A REDUCE RANGE ON THE COPIED SOLID */

   feet_list[0].objid = inc_list[0];
   feet_list[0].osnum = md_env->md_id.osnum;

   vol_info[0].cp_obj = feet_list[0];
   vol_info[0].obj    = &feet_list[0];
  }


 if(nb_inc > 1)
  { 
   /* create an union solid */ 

   /* A boolean operation must be done (no RTREE) */
   cst.env_info = &cp_env;

   feet_list[0].osnum = cp_env.md_id.osnum;
   status = om$construct(classid = OPP_EMSslboolean_class_id,
                     	 osnum   = feet_list[0].osnum,
                     	 p_objid = &feet_list[0].objid );
   if(!(status & 1)) {
     
     sprintf(err_buf,"%s error creating EMSslboolean object",err_msg);
     printf("%s\n",err_buf);
     UI_status(err_buf);   
     goto wrapup;
   }
   
   option =  EMSsfbool_opt_retryDisjoint | EMSsfbool_opt_noredraw |
             EMSsfbool_opt_HandleStop;

   bool_type      =  EMSbool_union;
   status_str[0]  = '\0';
   cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  sav_pathway_trim   = _pathway_trim;
  sav_pathway_orient = _pathway_orient;
  _pathway_trim   = 1;
  _pathway_orient = 1;

   status = om$send(msg = message EMSsfboolean.EMboolean(&msg, 
		&cp_env.md_env.matrix_type, cp_env.md_env.matrix, 
		inc_list[0], nb_inc-1, &inc_list[1], &cst,
		bool_type, option, status_str, NULL, NULL, NULL, NULL),
           targetid = feet_list[0].objid,
	   targetos = feet_list[0].osnum  );

  _pathway_trim   = sav_pathway_trim;
  _pathway_orient = sav_pathway_orient;

/* added for TR-179800514 */
  VDsetEmsBooleanStatus(status);
  if(!(status & 1))
  {
   sprintf(err_buf,"%s boolean union failed",err_msg);
   printf("%s\n",err_buf);
   UI_status(err_buf);   

   /* added for TR-179800514 */
   om$send(msg = message Root.delete(0),
	   targetid = feet_list[0].objid,
	   targetos = feet_list[0].osnum );

   feet_list[0].objid = NULL_OBJID;
   my_id = NULL_OBJID;
   *fcount = 1;
   return 0;
  }

   /* printf("status_str: %s\n", status_str); */
   if(msg != EMS_I_DisjointElements || msg != EMS_I_EmptySet) overlap = 1;
   if(!(msg&1)) {
     sprintf(err_buf,"%s boolean union failed",err_msg);
     printf("%s\n",err_buf);
     UI_status(err_buf);   
     goto wrapup;
   }

   /* To be sure to get the top dpr */
   status = om$send(msg = message EMSsurface.EMgetactiveid(&msg, 
                            &active_id, &top_lm_id),
                        targetid = feet_list[0].objid,
                        targetos = feet_list[0].osnum);
   if(!(status & msg & 1)) 
    { 
     printf("Warning getting the top dpr\n");
     active_id = feet_list[0];
    }

   /* This compress the dpr tree and compress the range box */
   status = om$send(msg = message EMSdpr.EMmake_primitive1(&msg, &cp_env,
                                &tmp_id),
	        targetid = active_id.objid,
		targetos = active_id.osnum);
   as$status(action = GOTO_VALUE,value = wrapup);
   feet_list[0]       = tmp_id;
   vol_info[0].cp_obj = feet_list[0];
   vol_info[0].obj    = &feet_list[0];
   inc_list[0]	      = feet_list[0].objid;
  }

 if(nb_exc > 0)
  {
   /* make the boolean diferrence. There possible unions 		   */
   /*  EMSbool_difference, /* Boolean difference                           */
   /*  EMSbool_interiorD,  /* diff with wholly interior element(s)         */
   /*  EMSbool_disjointD,  /* diff with elements occupying disjoint space  */
   /*  EMSbool_solidNullD, /* something difference with empty set	   */
   /*  EMSbool_nullSolidD, /* empty set difference with something 	   */


   if( nb_exc > 1 ){

	struct	GRid	SMunion ;
	GRobjid		Sol;
	IGRint		k ;
	
	cst.env_info	= &cp_env;

	option = EMSsfbool_opt_retryDisjoint	|
		  EMSsfbool_opt_noredraw	|
		  EMSsfbool_opt_HandleStop;

	bool_type = EMSbool_union;
        Sol	= exc_list[0];

        for( k=1 ; k<nb_exc ; k++ ){

          SMunion.objid = NULL_OBJID;
          SMunion.osnum = cp_env.md_id.osnum;

          status =
          om$construct(classid = OPP_EMSslboolean_class_id,
                       osnum   = SMunion.osnum,
                       p_objid = &SMunion.objid );
          if( !(status & 1) ) goto general_boolean;

          SMcomp_make_union(	&msg,
				&SMunion,
				&Sol,
				&exc_list[k],
                                option,
				bool_type,
				&cst );
	  if( ! (msg & 1)){
		goto general_boolean;
	  }
	}

	exc_list[0] = SMunion.objid ;
	nb_exc	    = 1;
    }

   /* (no RTREE) */

general_boolean:

   cst.env_info = &cp_env;

   feet_list[0].osnum = cp_env.md_id.osnum;
   status = om$construct(classid = OPP_EMSslboolean_class_id,
                     	 osnum   = feet_list[0].osnum,
                     	 p_objid = &feet_list[0].objid );
   if(!(status & 1)) goto wrapup;

   option =  EMSsfbool_opt_retryDisjoint | EMSsfbool_opt_noredraw |
             EMSsfbool_opt_HandleStop;

   bool_type      =  EMSbool_difference;
   status_str[0]  = '\0';
   cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  sav_pathway_trim   = _pathway_trim;
  sav_pathway_orient = _pathway_orient;
  _pathway_trim   = 1;
  _pathway_orient = 1;

   status = om$send(msg = message EMSsfboolean.EMboolean(&msg, 
		&cp_env.md_env.matrix_type, cp_env.md_env.matrix, 
		inc_list[0], nb_exc, &exc_list[0], &cst,
		bool_type, option, status_str, NULL, NULL, NULL, NULL),
           targetid = feet_list[0].objid,
	   targetos = feet_list[0].osnum  );

  _pathway_trim   = sav_pathway_trim;
  _pathway_orient = sav_pathway_orient;

/* It Fail when tangancy face but it work in EMS. After a short look it maybe
 * come the way they look at the returned completion code. 
 * (file :model/src_testco/imp/ECbooleani.I)
 * It seems now working !!!!
 */

   if(!(msg & status & 1))
   {
     sprintf(err_buf,"%s boolean difference failed",err_msg);
     printf("%s\n",err_buf);
     UI_status(err_buf);   
     goto wrapup;
   }

   /* To be sure to get the top dpr */
   status = om$send(msg = message EMSsurface.EMgetactiveid(&msg, 
                            &active_id, &top_lm_id),
                        targetid = feet_list[0].objid,
                        targetos = feet_list[0].osnum);
   if(!(status & msg & 1)) 
    { 
     printf("Warning getting the top dpr\n");
     active_id = feet_list[0];
    }

   /* This compress the dpr tree and compress the renge box */
   status = om$send(msg = message EMSdpr.EMmake_primitive1(&msg, &cp_env,
                                &tmp_id),
	        targetid = active_id.objid,
		targetos = active_id.osnum);
   if(!(status & 1)) goto wrapup;
   feet_list[0]       = tmp_id;
   vol_info[0].cp_obj = feet_list[0];
   vol_info[0].obj    = &feet_list[0];
  }


 /* reduce the range tree */
 /* The returned NewId is a plane !!!!! */
 status = om$send(msg = message EMSsubbs.EMreduce_range(&msg, &cp_env,
                           &NewId.objid, 0),
                        targetid = feet_list[0].objid,
                        targetos = feet_list[0].osnum);
 if(!(status & msg & 1)) 
  {
   printf("Warning range not reduced\n");
  }



 /* For each volume, which is not a compartment, depending on properties,
 /* compute the mass props */
 vol_info[0].type   = 0;
 for(i=0; i< nb_vol; i++)
  {
   /* If there is only one volume, compute only one cog, .... */
   if(nb_vol == 2 && i == 1) 
    {
     /* Copy the previous one */
     vol_info[i].volume  = vol_info[0].volume;
     vol_info[i].area    = vol_info[0].area;
     vol_info[i].FlrArea = vol_info[0].FlrArea;
     vol_info[i].cog[0]  = vol_info[0].cog[0];
     vol_info[i].cog[1]  = vol_info[0].cog[1];
     vol_info[i].cog[2]  = vol_info[0].cog[2];
     continue;
    }

   if(i>0 && (!(cmp_props & SM_CMP_CAL_VOLS) && !(cmp_props & SM_CMP_VRF_OVER)))
    {
     /* the individual mass properties are not computed */
     vol_info[i].volume  = -1;
     vol_info[i].area    = -1;
     vol_info[i].FlrArea = -1;
     vol_info[i].cog[0]  =  0;
     vol_info[i].cog[1]  =  0;
     vol_info[i].cog[2]  =  0;
     continue;
    }
     
   if(vol_info[i].type == SM_COMPARTMENT)
    {
     /* Ask the compartment for its values */
     status = om$send(msg = message SMmgr.SMGetAttDbl(&msg, "volume", 
		&vol_info[i].volume, NULL), 
				targetid = vol_info[i].comp_obj.objid,
				targetos = vol_info[i].comp_obj.osnum);
     if(!(status & msg & 1)) 
      {
       printf("Error geting the volume for the root compartment: %d\n", i-1);
       goto wrapup;
      }

     status = om$send(msg = message SMmgr.SMGetAttDbl(&msg, "area", 
		&vol_info[i].area, NULL), 
				targetid = vol_info[i].comp_obj.objid,
				targetos = vol_info[i].comp_obj.osnum);
     if(!(status & msg & 1)) 
      {
       printf("Error geting the total area for the root compartment: %d\n", i-1);
       goto wrapup;
      }

     status = om$send(msg = message SMmgr.SMGetAttDbl(&msg, "floor_area", 
		&vol_info[i].FlrArea, NULL), 
				targetid = vol_info[i].comp_obj.objid,
				targetos = vol_info[i].comp_obj.osnum);
     if(!(status & msg & 1)) 
      {
       printf("Error geting the floor area for the root compartment: %d\n", i-1);
       goto wrapup;
      }

     /* Get the cog */
     index = -1;
     tmp_env.md_id = md_env->md_id;
     tmp_env.md_env = *(vol_info[i].obj_env);

     status = om$send(msg = message NDmacro.ACgive_structure((IGRint *) &msg,
                                 &index, "cog", &ret, &tmp_env),
				targetid = vol_info[i].comp_obj.objid,
				targetos = vol_info[i].comp_obj.osnum);
     if(!(status & msg & 1)) return OM_W_ABORT;
     for(j=0;j<3;j++) vol_info[i].cog[j] = ret.var.point_st.pt[j];
    }
   else
    {
     for(kk=0;kk<NUMB_PROPS;kk=kk+1) props[kk] = 0;
     if(SMCompMassProp(vol_info[i].obj, MASS_PROPERTIES, &cp_env.md_env,
		      1., 1., props) != 1)
      {
       printf("Error in the computation of the mass prop for the volume #: %d\n",i-1);
       return OM_W_ABORT;
      }
     vol_info[i].volume = props[0];  
     vol_info[i].area   = props[11];  
     vol_info[i].cog[0] = props[2];  
     vol_info[i].cog[1] = props[3];  
     vol_info[i].cog[2] = props[4];  

     /* Compute the floor */
     props[11] = 0;
     if(SMCompFloorProp(vol_info[i].obj, &cp_env, 1., 1., props) != 1)
      {
       printf("Error in the computation of the floor area for the volume #: %d\n",i-1);
       vol_info[i].FlrArea = -1;
      }
     else vol_info[i].FlrArea = props[11];

    }
  }

 if(nb_vol < 3) overlap = 2; /* No overlapping */
 else if(overlap == 1)
  {
   /* We already know that there is an overlapping */
  }
 else if(cmp_props & SM_CMP_VRF_OVER)
  {
   /* Just compute the volume to verify that the components where not 
   /* overlapping */
   volume = 0;
 
   for(i=1;i<nb_vol;i++)
    {
     if(vol_info[i].exclude == 'Y') 
      {
       volume = volume - vol_info[i].volume;
      }
     else 
      {
       volume = volume + vol_info[i].volume;
      }
    }
   if(((vol_info[0].volume - volume)/vol_info[0].volume) > 0.01) overlap = 1;
   else 							 overlap = 2;
   /* printf("volume: %lf, total volume: %lf\n", vol_info[0].volume, volume); */
   if(overlap == 1) printf("Overlap, Overlap, ....\n");
  }

 /* Create the center point, exp volume and area of all the roots compart */
 /* Don't forget the Rtree */
 cst.env_info = md_env;
 kk = 1;

 /* Get the offset */ 
 if(VDSGetAttDbl(&list[0], "x_offset", &dpipo) == 0) x_offset = 0;
 x_offset = (IGRshort) dpipo;
 if(VDSGetAttDbl(&list[0], "y_offset", &dpipo) == 0) y_offset = 0;
 y_offset = (IGRshort) dpipo;

 for(i=0;i<nb_vol;i++)
  {
   IGRshort	rc2, pt_props;
   IGRchar	tmp[80];

   pt_props = 0;
   rc2 	    = (short) cmp_props;
   pt_props = rc2 & 0x00F0; /* Take the justif */
   if(i==0)
    {
     /* Compartment cog */
     if(!(cmp_props & SM_CMP_DSP_CMP_COG_PT))    pt_props = pt_props | VD_NO_DISP_PT;
     if(!(cmp_props & SM_CMP_DSP_CMP_COG_NAME))  pt_props = pt_props | VD_NO_DISP_TXT;
    }
   else
    {
     /* for the other cogs */
     if(!(cmp_props & SM_CMP_DSP_RT_COG_PT))    pt_props = pt_props | VD_NO_DISP_PT;
     if(!(cmp_props & SM_CMP_DSP_RT_COG_NAME))  pt_props = pt_props | VD_NO_DISP_TXT;
    }

   /* MOdif PL June 1994 bad test */

   if(i>0 && (vol_info[i].type == SM_COMPARTMENT ||
     (!(cmp_props & SM_CMP_CAL_VOLS) && !(cmp_props & SM_CMP_VRF_OVER))))
    {
     /* root compart or center of gravity has not been computed => no point */
     feet_list[kk].objid = NULL_OBJID;
    }
   else
    {
     /* Create special VDpoint */
     status = vd$cnst_txt_pt(msg 		= &msg,
   		  	     pt 		= vol_info[i].cog,
			     name		= name,
		  	     x_offset 		= x_offset,
		  	     y_offset 		= y_offset,
		  	     props		= pt_props,
		  	     cst		= &cst,
		  	     obj		= &feet_list[kk]);
     if(!(status & msg & 1)) feet_list[kk].objid = NULL_OBJID;
    }
   kk++;
   
   if(i>0) continue;
   /* NO LONGER FEET (EXECPT COG) EXIST FOR ROOT VOLUME */
   /* Create the volume foot (only for the result) */
   tmp[0] = '\0';
   sprintf(tmp, "%g", vol_info[i].volume);
   feet_list[kk].osnum = OM_Gw_current_OS;

   status = om$construct(classid = OPP_Gexp_class_id,
                         osnum   = feet_list[kk].osnum,
                         p_objid = &feet_list[kk].objid);
   if(!(status & 1)) goto wrapup;

   status = om$send(msg = message Gexp.create(NULL, tmp , &rc2 ),
                                targetid = feet_list[kk].objid,
                                targetos = feet_list[kk].osnum);
   if(!(status&1)) feet_list[kk].objid = NULL_OBJID;
   kk++;

   /* Create the area foot */
   tmp[0] = '\0';
   sprintf(tmp, "%g", vol_info[i].area);
   feet_list[kk].osnum = OM_Gw_current_OS;

   status = om$construct(classid = OPP_Gexp_class_id,
                         osnum   = feet_list[kk].osnum,
                         p_objid = &feet_list[kk].objid);
   if(!(status & 1)) goto wrapup;

   status = om$send(msg = message Gexp.create(NULL, tmp , &rc2 ),
                                targetid = feet_list[kk].objid,
                                targetos = feet_list[kk].osnum);
   if(!(status&1)) feet_list[kk].objid = NULL_OBJID;
   kk++;

   /* Create the floor area foot */
   tmp[0] = '\0';
   sprintf(tmp, "%g", vol_info[i].FlrArea);
   feet_list[kk].osnum = OM_Gw_current_OS;

   status = om$construct(classid = OPP_Gexp_class_id,
                         osnum   = feet_list[kk].osnum,
                         p_objid = &feet_list[kk].objid);
   if(!(status & 1)) goto wrapup;

   status = om$send(msg = message Gexp.create(NULL, tmp , &rc2 ),
                                targetid = feet_list[kk].objid,
                                targetos = feet_list[kk].osnum);
   if(!(status&1)) feet_list[kk].objid = NULL_OBJID;
   kk++;

   /* If there is only one volume, create only one cog, .... */
   /* The properties can be used if(nb_vol == 2 && i == 0) break; */
  }
 
 if(md_env->md_id.objid != NULL_OBJID /* && nb_vol > 2 */ )
  {
   /* Add the resulting boolean solid in the rtree */
   status = om$send(msg = message GRgraphics.GRaddwrng(&msg, md_env),
                                targetid = feet_list[0].objid,
                                targetos = feet_list[0].osnum);
   if(!(status&1)) 
    {
     printf("Failed adding the resulting boolean solid to the rtree\n");
    }
 }

 
 
#ifdef VERS24   
 /* Compute deck_number and compart side */
 if(cmp_type == SM_REG)
  {
    int	  side;
    
    /* following line are not compute in 2.2 because problem with structural surface */

    struct  GRid deck;
    char    *ptr;
    int     deck_num,info;

    status = SMGetDeckCmpt(&feet_list[0],md_env,&deck,&info);
    if (!(status & 1)){ ex$message(msgnumb = SM_W_CmNoDeckNum);}
    else
     {
       /* ASSUMPTION: deck number is assumed to be number in deck name  */
       val_txt[0] = '\0';
       vd$get_name(name = val_txt,obj = &deck);
       
       ptr = val_txt;  
       while(*ptr && !isdigit(*ptr)) ptr++;
       if(*ptr) 
	{
	  sscanf(ptr,"%d",&deck_num);
	  sprintf(val_txt,"%d",deck_num);
	  status = om$send(msg = message SMmgr.SMSetAttTxt
			   (&msg,"deck_number",val_txt,
			    SM_DYNAMIC_ATT | SM_OTHER_ATT),
			   targetid = my_id);	
	  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
	}
       else {ex$message(msgnumb = SM_W_CmNoDeckNum);}
     }

  }
#endif

 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
 as$status();

 /* Clear if it was the error state */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, (IGRshort) 0),
                  targetid = my_id );
 as$status();


 *fcount = kk;
 *rc = 1;
 return	OM_S_SUCCESS;

 
wrapup:

 /* Change the state to modified & error */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, SM_CAL_ERR),
                  targetid = my_id );
 as$status();

 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
 as$status();

 *rc = 0;
 return OM_S_SUCCESS;
}

/*==========================================================================*/

SMcomp_make_union( msg, sol, sol1, sol2, option, bool_type, cst)
IGRlong			*msg ;
struct	GRid		*sol ;
GRobjid			*sol1;
GRobjid			*sol2;
unsigned short  	option;
enum EMSbooltype  	bool_type;
struct GRvg_construct   *cst;
{
IGRint			status;
IGRint			num_sol;
IGRchar			status_str[80];

  num_sol = 1;

#ifdef DEBUG
	write("before  EMSsfboolean.EMboolean \n");
#endif

  sav_pathway_trim   = _pathway_trim;
  sav_pathway_orient = _pathway_orient;
  _pathway_trim   = 1;
  _pathway_orient = 1;

  status =
  om$send( msg = message EMSsfboolean.EMboolean( 
					msg,
					&cst->env_info->md_env.matrix_type,
					cst->env_info->md_env.matrix,
           				*sol1,
					num_sol,
					sol2,
           				cst,
					bool_type,
					option,
					status_str,
					NULL,
					NULL,
					NULL,
					NULL ),
	   senderid = NULL_OBJID,
           targetid = sol->objid,
	   targetos = sol->osnum  );

  _pathway_trim   = sav_pathway_trim;
  _pathway_orient = sav_pathway_orient;


#ifdef DEBUG
	printf("sol after EMSslboolean.EMboolean msg: %d\n", *msg );
	printf("sol sol = %d,%d \n", sol->objid, sol->osnum );
#endif

   as$status( sts = status );

   if( !(*msg&status&1) ){
     	printf(" function union boolean failed\n");
	*msg = MSFAIL;
	return OM_S_SUCCESS;
    }

    *sol1 = sol->objid;
    *msg  = MSSUCC;
    return OM_S_SUCCESS;
}

/* addded for TR-179800514 */
VDsetEmsBooleanStatus(status)
IGRlong  status;
{
/* set the flag to FALSE */
if( ! (status & 1 ))emsBooleanStatus = FALSE;
else emsBooleanStatus = TRUE ; 
return OM_S_SUCCESS;
}


IGRlong VDgetEmsBooleanStatus ( IGRlong *msg )
{
/* get the flag for EMS Boolean */
if ( emsBooleanStatus == FALSE ) *msg = 0 ;
else *msg = 1 ;
return (*msg);
}

end implementation SMcomp;
