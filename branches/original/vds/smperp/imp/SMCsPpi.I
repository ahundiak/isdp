/* $Id: SMCsPpi.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smperp/imp / SMCsPpi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCsPpi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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

class implementation SMCsPp;
 
 #include "OMmacros.h"
 #include "string.h"
 #include "nddef.h"
 #include "asmacros.h"
 #include "ndmacros.h"
 #include "gr.h"
 #include "igrdp.h"
 #include "grdpbdef.h"
 #include "grdpbmacros.h"
 #include "ACattrib.h"
 #include "ACrg_collect.h"
 #include "expression.h"
 #include "expmacros.h"
 #include "vdsmacros.h"
 #include "grerr.h"
 #include "vds.h"
 #include "VDmsg.h"
 #include "SMmsg.h"

 #include "AS_status.h"
 #include "SMCsPp.h"
 

 
 #define MAX_CHAR	256
 #define MAX_TEMP	4
 #define MAX_FEET	3
 
 
 from	ACrg_collect 	import ACset_list_attribute,ACadd_list_attribute;


 extern GRclassid	OPP_SMcoll_class_id;

/* -------------------------------------------------------------------- */

/* Give type of the SMPerp */

method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
  if(type)     *type =  SM_PP;
  if(sub_type) *sub_type = 0xFFFF;
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------- */

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; 
		    IGRboolean tag; IGRshort out_units; 
		    struct GRmdenv_info *obj_env, *trans_env)
{
  IGRlong 		status;
  IGRint		analysis;
  char 			name[DI_PATH_MAX];
  char 			axis[10];
  IGRdouble 		value, aftdist,foredist, cv_dist;
  IGRshort 		type;
  struct GRid		aft_id, fore_id;

  *msg = MSFAIL;

  /* for now take only the aft perp */

  status = om$send(msg = message SMCsPp.SMGetParameters
		   (msg, NULL, &aft_id, &fore_id, NULL, NULL,  
		    name),
		   targetid = my_id);
  if(!(status & *msg & 1)) {
	printf("ERROR SMCsPp.SMGetParameters\n");
	return status;
  }

  status = SMGetExpDist(&aft_id, &fore_id, &aftdist, &foredist, NULL, NULL);
  if(!(status &  1)) {
	printf("ERROR SMGetExpDist\n");
	return status;
  }

  status = om$send(msg = message SMmgr.SMGetAttDbl
		      (msg,"is_analysis",&value,&type),
		      targetid = my_id);
  as$status(action = RET_STATUS);
  analysis = (IGRint)value;

  if(!analysis) return OM_S_SUCCESS;

  status = om$send(msg = message SMmgr.SMGetAttTxt(msg,"axis",axis,0),
		   targetid = my_id);

  if(!(status & *msg & 1)) {
	printf("ERROR retrieving axis of perpendicular\n");
	return status;
  }

   
  /* Seasafe name only 4 characteres */
  name[5] = '\0';
 
  if(options & SM_ASCII_FILE)
   {
    if(options & SM_SF_SHORT_EXT)
     {
      fprintf(p_file,"%s \"%s\"\n\n","AP", name);
     }
    else
     {
       SMConvDistIntUnit(aftdist,out_units,&cv_dist,OM_Gw_current_OS);
       fprintf(p_file,"%s \"%s\" %g \"%s\"\n\n","AP", name,cv_dist, axis);
     }
    if(options & SM_SF_SHORT_EXT)
     {
      fprintf(p_file,"%s \"%s\"\n\n","FP", name);
     }
    else
     {
       SMConvDistIntUnit(foredist,out_units,&cv_dist,OM_Gw_current_OS);
       fprintf(p_file,"%s \"%s\" %g \"%s\"\n\n","FP", name,cv_dist, axis);
     }
   }
  else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   goto wrapup;
  }

 *msg = MSSUCC;
 return OM_S_SUCCESS;

 wrapup:
  return OM_W_ABORT;
}

/* -------------------------------------------------------------------- */
 
 method ACmplace_from_def(int *rc, prop; char rep;char *macro_name;
 			 int num_temp;	struct GRid *temp_list;
 			 struct GRid *def_occ;
 			 struct GRmd_env *md_env )
{
   IGRlong status;
   
   /* Put the properties to no protect: */
 
   prop = prop | AChdr_noprotect | ACcant_place_sym;
 
   status = om$send(msg = message ACncpx.ACmplace_from_def
 		   (rc, prop, rep, macro_name,
 		    num_temp, temp_list, def_occ, md_env),
 		   mode     = OM_e_wrt_message,
 		   targetid = my_id );
   as$status(action = RET_STATUS);
      
  /* Create as a new one */

  status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
		   targetid = my_id );
  as$status(action = RET_STATUS);
   
   return	OM_S_SUCCESS;
}
 
/* -------------------------------------------------------------------- */

 method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
 {
  int		analysis, status;
  double	value;
  IGRshort 	type;
  
  status = om$send(msg = message SMmgr.SMGetAttDbl
		      (msg,"is_analysis",&value,&type),
		      targetid = my_id);
  as$status(action = RET_STATUS);
  analysis = (IGRint)value;

  if(analysis)	strcpy(info->type,"Design Perpendicular");
  else 		strcpy(info->type,"Perpendicular");
 
  *msg = MSSUCC;
  return(OM_S_SUCCESS);
 }
 
/* -------------------------------------------------------------------- */

method	ACconstruct_feet( 	IGRlong *rc; 
 				IGRint cn_type; 
 			 	IGRint count; 
 				struct GRid list[];
 			 	struct GRmd_env *md_env;
 			 	IGRint *fcount; 
 				struct GRid *feet_list )
{
IGRint 			i, sizebuf, nret, is_middle, 
			nb_feet;
IGRlong 		status,loc_msg;
IGRdouble		value, AftDist, ForeDist, dist;
IGRshort 		level;
struct GRvg_construct 	cst, tmp_cst;
struct IGRdisplay 	display;
struct GRid		coord, plane, aft_id, fore_id;
char			AftName[MAX_CHAR], MidName[MAX_CHAR], ForName[MAX_CHAR];
IGRmatrix		matrix, cs_mat;
IGRuchar 		props;
short 			mat_type, cs_pl;
char 			axis[3],axe;


 *rc = MSSUCC;

 for(i=0;i<MAX_FEET;i++) feet_list[i].objid = NULL_OBJID;

 coord.objid = NULL_OBJID;
 coord.osnum = md_env->md_id.osnum;

 /* Construct construction list */
 
 
 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(	msg	= &loc_msg, 
			sizbuf  = &sizebuf,
 			buffer 	= &display, 
			nret    = &nret);
 
 sizebuf = sizeof(IGRshort);
 gr$get_active_level(	msg     = &loc_msg, 
			sizbuf  = &sizebuf,
 		      	buffer  = &level,   
			nret    = &nret);
 
 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = md_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 cst.display    = &display;
 cst.level      = level;
 

 status = om$send(msg = message SMCsPp.SMGetParameters
		   (&loc_msg, &coord, &aft_id, &fore_id, 
		    NULL,NULL, NULL),
		   targetid = my_id);
 if(!(status & loc_msg & 1)){
    	printf("Erreur retrieving parameters of perpendicular\n");
	goto wrapup;
 }
 status = SMGetExpDist(&aft_id, &fore_id, &AftDist, &ForeDist, NULL, NULL);
 if(!(status &  1)) {
	printf("ERROR SMGetExpDist\n");
	goto wrapup;
 }
 status = om$send( msg = message NDmacro.ACreturn_foot
		   (&loc_msg , "",&coord, &mat_type, matrix ),
		   targetid = coord.objid,
		   targetos = coord.osnum );
 if(!(status & loc_msg & 1)){
  	printf("Erreur retrieving the matrix of the coord syst\n"); 
	goto wrapup;
 }

 if(!VDget_mat(&coord, mat_type, matrix, cs_mat, &props, &cs_pl)){
  	printf("Erreur VDget_mat\n"); 
	goto wrapup;
 }

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg,"axis",axis,0),
		   targetid = my_id);

 if(!(status & loc_msg & 1)) {
	printf("ERROR retrieving axis of perpendicular\n");
	goto wrapup;
 }

 switch(axis[0])
   {
   	case 'x': axe = 'x'; break;
   	case 'y': axe = 'y'; break;
   	case 'z': axe = 'z'; break;
   	default: axe = 'x';
   }

 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg,"AftName",AftName,0),
		   targetid = my_id);

 if(!(status & loc_msg & 1)) {
	printf("ERROR retrieving AftName of perpendicular\n");
	goto wrapup;
 }
 

 /* construct the AftPerp as feet 0 */

 tmp_cst = cst;
 vd$const_plane (msg     = (int *)&loc_msg,
		  matrix  = cs_mat,
		  axe     = axe,
		  dist    = AftDist,
		  name    = AftName, 
		  props   = props,
		  cst     = &tmp_cst,
		  obj     = &plane);
 if (loc_msg!=1){
	printf("error in const_plane\n");
     	feet_list[0].objid = NULL_OBJID;
	goto wrapup;
 }
 else{
	feet_list[0].objid = plane.objid; 
	feet_list[0].osnum = plane.osnum;
 }

 /* construct the MidPerp as feet 1 (if is_middle = 1) */

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"is_middle", 
						&value,0),
		   targetid = my_id);

 if(!(status & loc_msg & 1)) {
	printf("ERROR retrieving is_middle of perpendicular\n");
	goto wrapup;
 }
 is_middle = (IGRint) value;

 if(is_middle){
 	status = om$send(msg = message SMmgr.SMGetAttTxt
				(&loc_msg,"MidName",MidName,0),
		   targetid = my_id);

 	if(!(status & loc_msg & 1)) {
		printf("ERROR retrieving MidName of perpendicular\n");
		goto wrapup;
 	}

  	tmp_cst = cst;
	dist = AftDist + ForeDist/2;
  	vd$const_plane (msg     = (int *)&loc_msg,
		  	matrix  = cs_mat,
		  	axe     = axe,
		  	dist    = dist,
		  	name    = MidName, 
		  	props   = props,
		  	cst     = &tmp_cst,
		  	obj     = &plane);
  	if (loc_msg!=1){
    		printf("error in const_plane\n");
     		feet_list[1].objid = NULL_OBJID;
		goto wrapup;
	}
  	else{
    		feet_list[1].objid = plane.objid; 
		feet_list[1].osnum = plane.osnum;
	}
 }
 else feet_list[1].objid = NULL_OBJID;

 /* construct the ForPerp as feet 2 */

 tmp_cst = cst;
 dist = AftDist + ForeDist;
 status = om$send(msg = message SMmgr.SMGetAttTxt(&loc_msg,"ForName",ForName,0),
		   targetid = my_id);

 if(!(status & loc_msg & 1)) {
	printf("ERROR retrieving ForName of perpendicular\n");
	goto wrapup;
 }

 vd$const_plane (msg     = (int *)&loc_msg,
		  matrix  = cs_mat,
		  axe     = axe,
		  dist    = dist,
		  name    = ForName, 
		  props   = props,
		  cst     = &tmp_cst,
		  obj     = &plane);
 if (loc_msg!=1){
    	printf("error in const_plane\n");
     	feet_list[2].objid = NULL_OBJID;
	goto wrapup;
 }
 else{
    	feet_list[2].objid = plane.objid; 
	feet_list[2].osnum = plane.osnum;
 }

 nb_feet = 3;

 *fcount = nb_feet;
 *rc = MSSUCC;
 return OM_S_SUCCESS;

 wrapup:

 *fcount = 0;
 *rc = MSFAIL;
 return OM_W_ABORT;
  
}
 
/* -------------------------------------------------------------------- */

method SMcreate(IGRlong *msg; struct GRid *coord; struct GRid *aft_id;
		struct GRid *fore_id;IGRint nb_att; 
		struct ACrg_coll *ACrg; IGRchar *MacName)
{
IGRlong 		sizebuf, nret;
struct GRmd_env 	act_env;
struct GRid 		roots[4];
IGRlong 		status;
IGRint			nb_roots;
struct GRsymbology	symb;
IGRshort 		type[3];


 *msg = MSSUCC;

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


 nb_roots = 4;


 roots[1] = *coord;

 roots[2] = *aft_id;

 roots[3] = *fore_id;

 roots[0].osnum = act_env.md_id.osnum;
 status = om$construct(classid = OPP_SMcoll_class_id,
			osnum   = roots[0].osnum,
			p_objid = &roots[0].objid);
 as$status();
 if(!(status & 1)){
	printf("can't create ACrg\n");   
	*msg = MSFAIL;
	goto wrapup;
 }

 status = om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
  						ND_DEL_NO_CH | ND_WAIT_DEL),

		   targetid = roots[0].objid,
		   targetos = roots[0].osnum);

 as$status();
 if(!(status & 1)){
	printf("ERROR NDnode.NDchg_state\n"); 
	*msg = MSFAIL;
	goto wrapup;
 }
 status = om$send(msg = message ACrg_collect.ACadd_list_attribute
		   (msg,nb_att,ACrg),
		   targetid = roots[0].objid,
		   targetos = roots[0].osnum);

 as$status();
 if(!(status & *msg & 1)){
	printf("Problem SMAddAtt for objid %d\n",my_id); 
	*msg = MSFAIL;
	goto wrapup;
 }
  
 NDduplicate_root(nb_roots, roots);
 status = om$send(msg = message ACncpx.ACmplace
		   ((IGRint *)msg,ACcant_place_sym,0,
		    "SMCsPp",nb_roots, roots,&act_env),
		   targetid = my_id);

 as$status();
 if(!(status & *msg & 1)){
	printf("erreur place macro\n"); 
	*msg = MSFAIL;
	goto wrapup;
 }

 type[0] = SM_SYST_ATT | SM_DYNAMIC_ATT;
 type[1] = SM_SYST_ATT | SM_DYNAMIC_ATT;
 type[2] = SM_SYST_ATT | SM_DYNAMIC_ATT;

 /* BIP BIP The type of the attributes is not really set */

 status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
		   targetid = my_id);
 as$status();

 status = om$send(msg = message GRvg.GRputname(msg,MacName),
		   targetid = my_id);
 as$status();
 if(!(status & *msg & 1)){
	printf("Erreur putname objid = %d\n",my_id); 
	*msg = MSFAIL;
	goto wrapup;
 }

 /* put active symbology */

 status = om$send(msg = message GRvg.GRputsymb(msg,&symb),
		   targetid = my_id);
 as$status();
 if(!(status & *msg & 1)){
	printf("Erreur putsymb objid = %d\n",my_id); 
	*msg = MSFAIL;
	goto wrapup;
 }
		


 return OM_S_SUCCESS;
wrapup:

 return OM_E_ABORT;
}


/* -------------------------------------------------------------------- */

method SMModify(IGRlong *msg; struct GRid *coord; struct GRid *aft_id;
		struct GRid *fore_id;IGRint nb_att; 
		struct ACrg_coll *ACrg; IGRchar *MacName)
{
IGRint			old_nbatt;
IGRlong 		status, sizebuf, nret;
IGRdouble 		AftDist, ForeDist, old_AftDist, old_ForeDist;
IGRchar 		tmp[MAX_CHAR], old_MacName[MAX_CHAR];
struct ACrg_coll	old_ACrg[SM_PERP_MAX_ATTR];
struct GRid 		old_roots[3],roots[3], my_grid, 
			original;
struct GRmd_env 	act_env;
struct GRsymbology	symb;
IGRboolean		discon, put_batch;

*msg = MSSUCC;

put_batch = FALSE;
discon = FALSE;

my_grid.objid = my_id;
my_grid.osnum = act_env.md_id.osnum;


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

status = SMGetExpDist(aft_id, fore_id, &AftDist, &ForeDist, NULL, NULL);
if(!(status &  1)) {
	printf("ERROR SMGetExpDist\n");
	*msg = MSFAIL;
	goto wrapup;
}


status = om$send(msg = message SMCsPp.SMGetParameters
		   (msg, &old_roots[0], &old_roots[1], &old_roots[2],  
		    &old_nbatt, old_ACrg,  old_MacName),
		   targetid = my_id);
if(!(status & *msg & 1)){
    	printf("Erreur retrieving parameter of perpendicular\n");
	*msg = MSFAIL;
	goto wrapup;
}

status = SMGetExpDist(&old_roots[1], &old_roots[2], &old_AftDist, &old_ForeDist,
			NULL, NULL);
if(!(status &  1)) {
	/* connections are corrupted */
}

if(strcmp(old_MacName,MacName)){

     if(!SMChgElemName(&my_grid, MacName, &act_env))
		printf("Warning: can't change macro name\n");
}

roots[0] = *coord;
roots[1] = *aft_id;
roots[2] = *fore_id;


if(coord->objid != old_roots[0].objid ||
   coord->osnum != old_roots[0].osnum){
     discon = TRUE;
     put_batch = TRUE;
}
if(aft_id->objid != old_roots[1].objid || 
   aft_id->osnum != old_roots[1].osnum){
     	discon = TRUE;
     	put_batch = TRUE;
}
else if(AftDist != old_AftDist){
	sprintf(tmp,"%lf",AftDist);
	status = exp$modify(	exp_id	 	= old_roots[1].objid,
				exp_syntax	= tmp,
				osnum 		= old_roots[1].osnum);
 	if(status != EXP_S_SUCCESS){
		printf("ERROR modifying the expression for AftDist\n");
		*msg = MSFAIL;
		goto wrapup;
 	}
     	put_batch = TRUE;
}  
if(fore_id->objid != old_roots[2].objid || 
   fore_id->osnum != old_roots[2].osnum){
     	put_batch = TRUE;
     	discon = TRUE;
}
else if(ForeDist != old_ForeDist){
	sprintf(tmp,"%lf",ForeDist);
	status = exp$modify(	exp_id	 	= old_roots[2].objid,
				exp_syntax	= tmp,
				osnum 		= old_roots[2].osnum);
 	if(status != EXP_S_SUCCESS){
		printf("ERROR modifying the expression for ForeDist\n");
		*msg = MSFAIL;
		goto wrapup;
 	}
     	put_batch = TRUE;
}  
 
if(discon){ 
  	status = om$send(msg = message NDnode.NDdisconnect
		      (3, &old_roots[0]),
                   		targetid = my_id);
  	as$status();
  	if(!(status & 1)){
			printf("Erreur NDnode.NDdisconnect\n");
			return OM_E_ABORT;
  	}
  	NDduplicate_root(3, &roots[0]);
  	original.objid = NULL_OBJID;
  	status = om$send(msg = message NDnode.NDconnect
		      (3, &roots[0], original, ND_ADD),
                   		targetid = my_id);

  	as$status();
  	if(!(status & 1)){
		printf("Erreur NDnode.NDconnect\n");
		return OM_E_ABORT;
  	}
  }

if(!(SMIsACrgEqual(ACrg, nb_att, old_ACrg, old_nbatt))){
	status = om$send(msg = message SMmgr.SMResetAtt
		      (msg,nb_att,ACrg,NULL),
		      targetid = my_id);
	as$status();
	if(!(status & 1)){
                printf("Erreur SMmgr.SMResetAtt\n");
		*msg = MSFAIL;
		goto wrapup;
	}
     	put_batch = TRUE;
}
  
status = om$send(msg = message SMmgr.SMChgState(SM_STATE,SM_MOD),
		   targetid = my_id);
as$status();

if(put_batch)
   {
     IGRint  cn_type,wait_batch;
     struct GRid my_grid;
    
     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;

     cn_type    = 1; /* recompute the object */
     status = nd$wait_batch(type       = GR_GEOM_POSTED,
			    l_object   = &my_grid,
			    l_obj_info = &cn_type,
			    nb_obj     = 1);

     nd$mod_batch(request    = ND_INQ,p_ret_mode = &wait_batch);
     
     if(wait_batch == ND_DEFER) return OM_S_SUCCESS; /* Nothing to do */
  
     nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
   }

  return OM_S_SUCCESS;
wrapup:
  return OM_E_ABORT;
}

/* -------------------------------------------------------------------- */

method SMGetParameters(
		 IGRlong *msg; struct GRid *coord; struct GRid *aft_id;
		 struct GRid *fore_id;IGRint *nb_att; 
		 struct ACrg_coll *ACrg; IGRchar *MacName)
{
IGRlong 		status;
IGRint  		is_analysis, count;
struct GRid		my_grid, *roots;
IGRdouble		value;
IGRboolean		missing;

 *msg = MSSUCC;
 my_grid.objid = my_id;
 my_grid.osnum = 2;
 missing = FALSE;

 status = om$send(msg = message NDnode.NDget_objects
		  (ND_ROOT | ND_IN_BUF,NULL, 0 ,&roots, 0, OM_K_MAXINT,&count),
		      targetid = my_id);
 if(status != OM_S_SUCCESS){
		printf("ERROR NDnode.NDget_objects\n"); 
		*msg = MSFAIL; 	
		goto wrapup;
 }
  /* Jean : 5/4/93  Modify if macro is broken (has lost his parents) */
 /* If macro has been move to root due to delete of one of the roots */
 /* Creation of two dummy expression to allow to recreate a depandancy */
  if(count == 0){
    struct GRid		exp[3];
    struct ACrg_coll 	ACrg[8];
    struct GRid 	original;
    IGRdouble		val = 0.0;
    int         	state;

    missing = TRUE; /* needed to know the position of the cs in the roots list*/

    /* Recreate an expression with default parameter */
    exp[1].osnum = 2;
    status = exp$create(exp_name  = NULL,
		      exp_value = val,
		      p_exp_id  = &exp[1].objid,
		      osnum     = exp[1].osnum);
    as$status(action = GOTO_VALUE, value = wrapup);

    status = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL), 
		   targetid = exp[1].objid,
		   targetos = exp[1].osnum);
    as$status();

    /* Recreate an expression with default parameter */
    exp[2].osnum = 2;
    status = exp$create(exp_name  = NULL,
		      exp_value = val,
		      p_exp_id  = &exp[2].objid,
		      osnum     = exp[2].osnum);
    as$status(action = GOTO_VALUE, value = wrapup);

    status = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL), 
		   targetid = exp[2].objid,
		   targetos = exp[2].osnum);
    as$status();

    /* Recreate an ACrg_collection with default attributes */

    status = SMSetRgAtt(0, 0, 0,"Aft","Mid","Fore", "SMDrwPrp",
                   "x", ACrg);

    if(!(status & 1)){
        	printf("ERROR SMSetRgAtt\n");
 		*msg = MSFAIL; 	
		goto wrapup;
    }


    exp[0].osnum = OM_Gw_current_OS;
    status = om$construct(classid = OPP_SMcoll_class_id,
			osnum   = exp[0].osnum,
			p_objid = &exp[0].objid);
    as$status(action = GOTO_VALUE, value = wrapup);

    status = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL), 
		   targetid = exp[0].objid,
		   targetos = exp[0].osnum);
    as$status();

    status = om$send(msg = message ACrg_collect.ACadd_list_attribute
		   (msg,8,ACrg),
		   targetid = exp[0].objid,
		   targetos = exp[0].osnum);

    as$status();

    original.objid = NULL_OBJID;
    status = om$send(msg = message NDnode.NDconnect
		   (3, exp, original, ND_ADD),
		   targetid = my_id); 
    as$status(action = GOTO_VALUE, value = wrapup);

    /* Refound all parents so we can execute normal instruction */
    status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT | ND_IN_BUF,NULL,0,&roots,0,OM_K_MAXINT,
		    &count),
		   targetid = my_id );

    as$status();
    if(status != OM_S_SUCCESS )
     {printf("ERROR retrieve roots of the macro \n"); return OM_E_ABORT;}

    /* Macro have probably been move to root .Change it state and
       so it will be recompute when in batch                     */
    status =  om$send(msg = message ACncpx.ACget_STATE(&state),
		    targetid = my_id);
    as$status(action = GOTO_VALUE, value = wrapup);
    
    if(state & ncpx_root) /* Move to root */
     {
       status = om$send(msg = message ACncpx.ACchg_STATE(ncpx_root,~ncpx_root),
		      targetid = my_id);
       as$status (action = GOTO_VALUE, value = wrapup);
     }
  }

 
 if(coord != NULL ){
	if( missing == FALSE){
		coord->objid = roots[1].objid;
		coord->osnum = roots[1].osnum;
	}
	else coord->objid = NULL_OBJID;
 }
 if(MacName != NULL){

     status = om$send(msg = message SMmgr.SMGetShortName(msg,MacName),	   
		      targetid = my_id);
 	if(!(status & (*msg) &1 ) ){
		MacName[0] = '\0';
	}
 }
 if(aft_id != NULL ){
	if( missing == FALSE){
		aft_id->objid =  roots[2].objid;
		aft_id->osnum =  roots[2].osnum;
	}
	else{
		aft_id->objid =  roots[1].objid;
		aft_id->osnum =  roots[1].osnum;
	}
 }
 status = om$send(msg = message SMmgr.SMGetAttDbl
		      (msg,"is_analysis",&value,0),
		      targetid = my_id);
 if(!(status & (*msg) &1 ) ){
		printf("ERROR retrieving is_analysis\n"); 
		*msg = MSFAIL; 	
		goto wrapup;
 }
 is_analysis = (IGRint)value;
 if(fore_id != NULL ){
	if( missing == FALSE){
		fore_id->objid = roots[3].objid;
		fore_id->osnum = roots[3].osnum;
	}
	else {
		fore_id->objid = roots[2].objid;
		fore_id->osnum = roots[2].osnum;
	}
 }

 /* Get attributes of the Perpendicular */

 if(nb_att && ACrg){
 	status = om$send( msg = message SMmgr.SMListAtt
		    (msg, SM_PERP_MAX_ATTR ,
		     nb_att,ACrg,NULL),
		      targetid = my_id);
 	as$status(action = RET_STATUS);
 	if(!(status & (*msg) &1 ) ){
		printf("ERROR retrieving the attributes of the perpendicular\n"); 
		*msg = MSFAIL; 	
		goto wrapup;
 	}
 }

 return OM_S_SUCCESS;

 wrapup:
  return OM_W_ABORT;
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjPerp ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMCsPp;




