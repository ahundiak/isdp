/* $Id: SMMainSfi.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        smstrsf/SMMainSfi.I
 *
 * Description:
 *
 *      This file implements the methods for the main (or structural) surfaces.
 *
 * Dependencies:
 *
 *      SMMainSf
 *
 * Revision History:
 *	$Log: SMMainSfi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
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
 *      02/01/93        P. Lacroix      Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation SMMainSf;

#include "string.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VDSutil_def.h"
#include "SMcomp_def.h"
#include "SMStructSf.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "AS_status.h"

#define AS_DEBUG


from	VDSpt	import	VDsettext, VDsetprops;
from    SMcoll  import  SMSetDbInfo;

extern GRclassid	OPP_SMcoll_class_id;


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the type of the main surface when it
	is located (status field).

  Arguments


      IGRlong		*msg             O   	completion code
      struct GRobj_info	*info            O	structure for information about
                                 		the object


  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails



 -------------------------------------------------------------------------
-mo*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
long		status, loc_msg;
char		sftype[81];
 
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg,"surftype",
			sftype, NULL),
 			targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No type defined !!! for the main surface\n");
    return OM_W_ABORT;
  }
 if(strcmp(sftype, "deck") == 0) strcpy(info->type,"Deck");
 else if(strcmp(sftype, "l bulk") == 0) strcpy(info->type,"Longitudinal Bulkhead");
 else if(strcmp(sftype, "t bulk") == 0) strcpy(info->type,"Transversal Bulkhead");
 else if(strcmp(sftype, "hull") == 0) strcpy(info->type,"Hull");
 else if(strcmp(sftype, "other") == 0) strcpy(info->type,"Structural Surface");
 else strcpy(info->type,"Structural Surface");

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}


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
     OM_E_ABORT		if fails

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
       GRputname from GRgraphics

  Abstract

	Stores the name of the object.

  Arguments


      IGRlong		*msg             O   	completion code
      IGRchar		*name		 I	The name of the object.

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-mo*/

method GRputname(IGRlong *msg; IGRchar *name)
{
 IGRlong                status, loc_msg;
 IGRchar		old_name[81], *pt;

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

 status = om$send(msg = message SMMainSf.SMModPtTxt(&loc_msg, NULL, NULL, NULL,
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
 IGRchar		old_name[81], *pt;

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

 status = om$send(msg = message SMMainSf.SMModPtTxt(&loc_msg, NULL, NULL, NULL,
                                                  pt),
                  targetid = my_id );
 as$status(action = RET_STATUS);
 
 return status;
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
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

method SMModPtTxt(IGRlong *msg; IGRshort *x_offset, *y_offset, *props;
		IGRchar *text)
{
 IGRlong 	        status, loc_msg;
 IGRshort               type;
 IGRchar		*pt;
 struct GRid            obj;

 *msg   = MSSUCC;

 type = SM_SYST_ATT | SM_DYNAMIC_ATT;

 /* Get the cog feet */

 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "cog",
                  	&obj, NULL, NULL),
                        targetid = my_id);
 if(!(status & 1)) return OM_E_ABORT;
 if(!(loc_msg & 1))  obj.objid = NULL_OBJID;
 
 if(x_offset) *x_offset = 0.;
 if(y_offset) *y_offset = 0.;

 /* if obj.objid == NULL_OBJID ie the cog has yet been compute, do nothing */

 if(obj.objid == NULL_OBJID) 
	UI_status("Warning, cog cannot be modified (not yet computed)");


 if(props && obj.objid != NULL_OBJID){
     IGRshort pipo;

     pipo = 0;

     pipo = (*props) & 0x00F0;

     if(!( (*props) & SM_CMP_DSP_CMP_COG_PT))   pipo |= VD_NO_DISP_PT;
     if(!( (*props) & SM_CMP_DSP_CMP_COG_NAME)) pipo |= VD_NO_DISP_TXT;

     status = om$send(msg = message VDSpt.VDsetprops(pipo),
                        targetid = obj.objid,
			targetos = obj.osnum);
     as$status(action = RET_STATUS);

     status = om$send(msg = message SMmgr.SMSetAttDbl(&loc_msg, "props", 
                                                      *props, type),
			targetid = my_id );
     as$status(action=RET_STATUS);
 }

 if(text && obj.objid != NULL_OBJID){
     	/* Update the attribute */
     	pt = strrchr(text,':');
     	if(pt == NULL) pt = &text[0];
     	else           pt = &pt[1];

     	status = om$send(msg = message VDSpt.VDsettext(text),
                        targetid = obj.objid,
			targetos = obj.osnum);
     	as$status(action = RET_STATUS);

       	status = om$send(msg = message SMmgr.SMSetAttTxt(&loc_msg, "name", pt, type),
			targetid = my_id );
       	as$status(action=RET_STATUS);
 } 

 return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------

  Public Message SMcreate

  Abstract

  	This message fills all the parameters of the macro and 
	place it.

  Arguments

  IGRlong             *msg		O : Completion code.

  IGRint            	nb_att		I : nb attributes in the ACrg_coll

  struct ACrg_coll	*ACrg		I : the attributes 

  IGRshort           	*att_type	I : type of each attribute

  struct GRid		*surface	I : the surface 

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/
method SMcreate( IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
		 IGRshort *att_type; struct GRid *surface)
{
IGRlong 		sizebuf, nret;
struct GRmd_env 	act_env;
struct GRid 		my_grid, roots[2];
IGRlong 		status;
IGRint			cn_type, nb_roots;
IGRchar			name_surf[ATTR_TXT];
struct GRsymbology	symb;
IGRchar                 family[ATTR_TXT],partno[ATTR_TXT],partrev[ATTR_TXT];

 *msg = MSSUCC;
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(		msg    = msg, 
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr, 
				nret   = &nret);

 sizebuf = sizeof(IGRshort);
 gr$get_active_level(		msg     = msg, 
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,   
				nret    = &nret);

 sizebuf = sizeof(struct GRmd_env);
 gr$get_module_env(	msg     = msg,
                      	sizbuf  = &sizebuf,
                      	buffer  = &act_env,
                      	nret    = &nret);


 nb_roots = 2;


 roots[1] = *surface;

 roots[0].osnum = act_env.md_id.osnum;

 status = om$construct(classid = OPP_SMcoll_class_id,
			osnum   = roots[0].osnum,
			p_objid = &roots[0].objid);
 as$status();
 if(!(status & 1)){
	printf("can't create ACrg\n");   
	goto wrapup;
 }

 status = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
  						ND_DEL_NO_CH | ND_WAIT_DEL),

		   targetid = roots[0].objid,
		   targetos = roots[0].osnum);

 as$status();
 if(!(status & 1)){
	printf("ERROR NDnode.NDchg_state\n"); 
	goto wrapup;
 }
  
 status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
		   targetid = my_id);
 as$status();

 status = om$send(msg = message ACncpx.ACmplace
		  ((IGRint *)msg,AChdr_nodisplay | AChdr_nocompute,0,
		   "SMMainSf",nb_roots, roots,&act_env),
		  targetid = my_id);

 as$status();
 if(!(status & *msg & 1)){
  printf("erreur place macro\n"); 
	goto wrapup;
 }


  /* Put the attributes of the surface */

  /* Jean 18/Aug/93 : */ 
  if(SMGetAttr("family",ACrg,att_type,nb_att,
	       (int *)NULL,(double *)NULL,family,(IGRshort *)NULL) &&
     SMGetAttr("partno",ACrg,att_type,nb_att,
	       (int *)NULL,(double *)NULL,partno,(IGRshort *)NULL) &&
     SMGetAttr("partrev",ACrg,att_type,nb_att,
	       (int *)NULL,(double *)NULL,partrev,(IGRshort *)NULL))
   {
     status = om$send(msg = message SMcoll.SMSetDbInfo
		      (msg,"surface",family,partno,partrev),
		      targetid = roots[0].objid,
		      targetos = roots[0].osnum);
     if(!(status & *msg & 1))
      {printf("Error set database info in SMcoll\n");goto wrapup;}
   }

  status = om$send(msg = message SMmgr.SMSetAtt
		   (msg, nb_att,ACrg, att_type),
		   targetid = my_id);
  as$status(sts = (status & *msg),action = GOTO_VALUE, value = wrapup);

  SMGetAttr("name",ACrg,att_type,nb_att,
	   (int *)NULL,(double *)NULL,name_surf,(IGRshort *)NULL);
  
  status = om$send(msg = message GRgraphics.GRputname(msg, name_surf),
		   targetid = my_id);
  if(!(status & *msg & 1))
   {printf("Error put name of the surface\n");goto wrapup;}
 
  cn_type  = ND_COMP;     /* recompute the object */
  nd$wait_batch(type       = GR_GEOM_POSTED,
		l_object   = &my_grid,
		l_obj_info = &cn_type,
		nb_obj     = 1); 

  nd$exec_batch(mode = 0);



 /* put active symbology */

 status = om$send(msg = message GRvg.GRputsymb(msg,&symb),
		   targetid = my_id);
 as$status();
 if(!(status & *msg & 1)){
	printf("Erreur putsymb objid = %d\n",my_id); 
	goto wrapup;
 }
		
 /* delete macro if one of the parent is deleted */


 status = om$send(msg = message NDnode.NDchg_state(ND_DONT_MVRT,ND_DONT_MVRT),
		   targetid = my_id);
 as$status();
 if(!(status & *msg & 1)){
	printf("Erreur NDnode.NDchg_state = %d\n",my_id); 
	goto wrapup;
 }
		

*msg = MSSUCC;
 return OM_S_SUCCESS;
wrapup:

*msg = MSFAIL;
 return OM_E_ABORT;
}

/*+me
 -------------------------------------------------------------------------

  Public Message SMModify

  Abstract

  	This message modifies all the parameters of an existing macro .
	

  Arguments

  IGRlong               *msg		O : Completion code.

  IGRint            	nb_att		I : nb attributes in the ACrg_coll

  struct ACrg_coll	*ACrg		I : the attributes 

  IGRshort           	*att_type	I : type of each attribute

  struct GRid		*surface	I : the surface 

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

method SMModify( IGRlong *msg;IGRint nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type;struct GRid *surface)
{
IGRint			old_nbatt,modif_flag,wait_batch,cn_type;
IGRlong 		status, sizebuf, nret;
IGRchar			name[ATTR_TXT];
IGRshort		consume, old_consume, state,is_consume, is_display, 
			old_props, props, type;
IGRdouble		area, density, weight;
struct ACrg_coll	old_ACrg[SM_MAINSF_MAX_ATTR];
struct GRobj_env	surf;
struct GRid 		my_grid, old_surface;
struct GRmd_env 	act_env;
struct GRsymbology	symb;

*msg = MSSUCC;

modif_flag = NO_CHANGE;

my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;
 
type = SM_SYST_ATT | SM_DYNAMIC_ATT;

*msg = MSSUCC;
sizebuf = sizeof(struct GRmd_env);
gr$get_module_env(	msg    	= msg, 
			sizbuf	= &sizebuf,
		    	buffer 	= &act_env,
			nret 	= &nret);



sizebuf = sizeof(struct IGRdisplay);
gr$get_active_display(		msg    = msg, 
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr, 
				nret   = &nret);

sizebuf = sizeof(IGRshort);
gr$get_active_level(		msg     = msg, 
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,   
				nret    = &nret);


status = om$send(msg = message SMMainSf.SMGetParameters
		   (msg, &old_nbatt, old_ACrg, NULL, &old_surface),
		   targetid = my_id);
if(!(status & *msg & 1)){
    	printf("Erreur retrieving parameter of perpendicular\n");
	goto wrapup;
}

/* if name or props is modified, display must be modified */

status = SMGetRgSf(ACrg, nb_att, NULL, NULL,NULL, NULL,name, NULL, NULL,&props,
			&consume);
if(!(status & 1)){
        printf("Erreur Get name and props from ACrg\n");
	goto wrapup;
}
status = SMGetRgSf(old_ACrg, old_nbatt,NULL,NULL,NULL,NULL,NULL, NULL, NULL,
			&old_props, &old_consume);
if(!(status & 1)){
        printf("Erreur Get props from old_ACrg\n");
	goto wrapup;
}
if(props != old_props) modif_flag |= TO_REDISPLAY;
if(consume != old_consume) modif_flag |= TO_RECOMPUTE;

switch(SMChgElemName(&my_grid,name,&act_env)){

   case 0:
     printf("Warning : can't change_name objid = %d\n",my_grid.objid);
     break;
   case 1: modif_flag |= TO_REDISPLAY; break;  /* Real change of name */
   case 3: break;  /* Nothing change */                            
}


if(surface->objid != old_surface.objid ||
   surface->osnum != old_surface.osnum){

	
	status = om$send(msg = message NDnode.NDchange_connect
                      		(1, &old_surface, surface),
                                targetid = my_id );
	as$status();
	if(!(status & 1)){
                printf("Erreur NDnode.NDchange_connect\n");
		goto wrapup;
	}
     	modif_flag |= TO_RECOMPUTE;
}



if(!(SMIsACrgEqual(ACrg, nb_att, old_ACrg, old_nbatt))){
	status = om$send(msg = message SMmgr.SMResetAtt
		      (msg,nb_att,ACrg,att_type),
		      targetid = my_id);
	as$status();
	if(!(status & 1)){
                printf("Erreur SMmgr.SMResetAtt\n");
		goto wrapup;
	}

	/* if density is modified, weight must be recomputed */

   	status = om$send(msg = message SMmgr.SMGetState(&state),
                        targetid = my_id);
   	if(!(status & 1)) {
                printf("Erreur SMmgr.SMGetState\n");
		goto wrapup;
  	}

 	if(state & SM_NOT_COMP) {
		/* the cog is not created, the area is incorrect */
		area = -1;
		weight = -1;
 		status = om$send(msg = message SMmgr.SMSetAttDbl(msg, "weight",
					weight, type),
                  targetid = my_id );
 		as$status();
 		if(!(status & (*msg) & 1)) {
			printf("ERROR changing weight\n");;
			goto wrapup;
 		}
	}
	else{
 		status = om$send(msg = message SMmgr.SMGetAttDbl(msg,"area",
			&area, NULL),
 			targetid = my_id);
 		if(!(status & (*msg) & 1)){
    			printf("No area defined for the surface\n");
    			goto wrapup;
  		}
 		status = om$send(msg = message SMmgr.SMGetAttDbl(msg,"density",
			&density, NULL),
 			targetid = my_id);
 		if(!(status & (*msg) & 1)){
    			printf("No density defined for the surface\n");
    			goto wrapup;
  		}

 		weight = density * area;

 		status = om$send(msg = message SMmgr.SMSetAttDbl(msg, "weight",
			weight, type),
                  targetid = my_id );
 		as$status();
 		if(!(status & (*msg) & 1)) {
			printf("ERROR changing weight\n");;
			goto wrapup;
 		}
	}
     	modif_flag |= TO_CHANGE_STATE;
}


if(modif_flag & TO_RECOMPUTE)
   {
    
     if(old_consume == 1){
		/* must unconsume the old_surface */

  		is_consume = 0;
  		is_display = 1;
 		if(!GetEnvFrObj(&old_surface, &surf.mod_env, &surf.obj_id)) {
   			printf("Error GetEnvFrObj\n");
   			goto wrapup;
 		}
  		status = VDconsume_and_display( old_surface, is_consume, 
						is_display, 
						&surf.mod_env );
  		as$status( );
     }
     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;

     cn_type    = ND_COMP; /* recompute the object */
     status = nd$wait_batch(type       = GR_GEOM_POSTED,
			    l_object   = &my_grid,
			    l_obj_info = &cn_type,
			    nb_obj     = 1);

     nd$mod_batch(request    = ND_INQ,p_ret_mode = &wait_batch);
     
     if(wait_batch != ND_DEFER) /* else nothing to do */
     	nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
   }
else if(modif_flag & TO_REDISPLAY){

     status = om$send(msg = message NDnode.NDdisplay
		      (1,GRbe,&act_env),
		      targetid = my_grid.objid,
		      targetos = my_grid.osnum);
     as$status();

     status = om$send(msg = message SMMainSf.SMModPtTxt
		      ( msg,
		        NULL,
			NULL,
			&props,
		       	name ),
		      targetid = my_grid.objid,
		      targetos = my_grid.osnum);
     as$status(sts = (status & *msg));

     status = om$send(msg = message NDnode.NDdisplay
		      (1,GRbd,&act_env),
		      targetid = my_grid.objid,
		      targetos = my_grid.osnum);
     as$status(); 
}

if(modif_flag != NO_CHANGE){
	status = om$send(msg = message SMmgr.SMChgState(SM_STATE,SM_MOD),
		   targetid = my_id);
	as$status();
}

*msg = MSSUCC;
return OM_S_SUCCESS;

wrapup:
*msg = MSFAIL;
return OM_E_ABORT;

}

/*+me
 -------------------------------------------------------------------------

  Public Message SMGetParameters

  Abstract

     This method get the parameters of an existing macro.
     A NULL pointer can be given if a parameter is not needed.
	

  Arguments

  IGRlong               *msg		O : Completion code.

  IGRint            	*nb_att		O : nb attributes in the ACrg_coll

  struct ACrg_coll	*ACrg		O : the attributes 

  IGRshort           	*att_type	O : type of each attribute

  struct GRid		*surface	O : the surface 

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

method SMGetParameters( IGRlong *msg;IGRint *nb_att; struct  ACrg_coll *ACrg;
			IGRshort *att_type; struct GRid *surface; )
{
IGRlong 		status;
IGRint  		count;

 *msg = MSSUCC;

 if(surface != NULL){
 	status = om$send(msg = message NDnode.NDget_objects
		  (ND_ROOT , surface, 1 ,NULL, 1, 1,&count),
		      targetid = my_id);
 	if(status != OM_S_SUCCESS){
		printf("ERROR NDnode.NDget_objects\n"); 
		goto wrapup;
 	}
 }

 /* Get attributes of the Surface */

 if(nb_att && ACrg){
 	status = om$send( msg = message SMmgr.SMListAtt
		    (msg, SM_MAINSF_MAX_ATTR ,
		     nb_att,ACrg,att_type),
		      targetid = my_id);
 	as$status(action = RET_STATUS);
 	if(!(status & (*msg) &1 ) ){
		printf("ERROR retrieving the attributes of the main surface\n"); 
		goto wrapup;
 	}
 }

*msg = MSSUCC;
return OM_S_SUCCESS;

wrapup:

*msg = MSFAIL; 	
return OM_W_ABORT;

}

/*+me
 -------------------------------------------------------------------------

  Public Message SMIsPointOnSf

  Abstract

     This method determines if the given point lies on the surface	
     The point can be given by its geometry or by its object.
	

  Arguments

  IGRlong                  *msg		 O : Completion code.

  IGRdouble                *pt_geom	 I : point geometry 

  struct GRobj_env	   *pt_object    I : point object 

  IGRint		   *on_surface	 O : 1 = the point is on the surface

  Status/Return Code
     OM_S_SUCCESS	if success;
     OM_E_ABORT		if fails

 -------------------------------------------------------------------------
-me*/

method SMIsPointOnSf( 	IGRlong *msg; IGRdouble *pt_geom; 
			struct GRobj_env *pt_object; 
			IGRint *on_surface)
{
IGRint			i, count, status;
IGRpoint		point;
IGRdouble		epsilon;
struct ret_struct 	ret_st;
struct GRid		surf, my_grid;


 *msg = MSSUCC;

 epsilon = 1e-3;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if(on_surface == NULL || (pt_geom == NULL && pt_object == NULL) ){
	printf("ERROR Invalid Argument in SMIsPointOnSf\n"); 
	goto wrapup;
 }

 if(pt_geom != NULL)
	for(i=0;i<3;i++) point[i] = pt_geom[i];
 else{
	 status = as$any_give_structure(go_grid = pt_object->obj_id,
					inst = &ret_st,
					mod_env = &pt_object->mod_env);
 	if(!(status & 1)) {
		printf("ERROR as$any_give_structure\n"); 
		goto wrapup;
	}
 	for(i=0;i<3;i++) point[i] = ret_st.var.point_st.pt[i];

 }
 status = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT ,&surf, 1 ,NULL, 1, 1,&count),
                   targetid = my_id);
if(status != OM_S_SUCCESS) {
                printf("ERROR NDnode.NDget_objects\n");
                as$status(action = RET_STATUS);
}

 
 status = SMIsPtOnSf(point, &surf, NULL, epsilon, on_surface);
 if(!(status & 1)) {
		printf("ERROR SMIsPtOnSf\n"); 
		goto wrapup;
 }
 

*msg = MSSUCC;
return OM_S_SUCCESS;

wrapup:

*msg = MSFAIL; 	
return OM_W_ABORT;
}


/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjMainSf ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/



end implementation SMMainSf;


