/* $Id: SMVolBndi.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/bnd / SMVolBndi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMVolBndi.I,v $
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
# Revision 1.3  1996/04/29  09:05:58  pinnacle
# Replaced: smspace/bnd/SMVolBndi.I for:  by ksundar for vds.240
#
# Revision 1.2  1996/01/24  20:08:04  pinnacle
# Replaced: ./smspace/bnd/SMVolBndi.I for:  by azuurhou for vds.240
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

class implementation SMVolBnd;

#include <stdio.h>
#include <string.h>

#include "nddef.h"
#include "asmacros.h"
#include "vdsmacros.h"
#include "ndmacros.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "msdef.h"
#include "msmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"

#define AS_DEBUG
#include "AS_status.h"

#include "SMCmdBnd.h"
#include "SMmsg.h"
#include "VDmem.h"



from  ACrg_collect 	import ACadd_list_attribute;

extern GRclassid	OPP_SMcoll_class_id;

method ACmplace_from_def(int *rc, prop; char rep;char *macro_name;
			 int num_temp;	struct GRid *temp_list;
			 struct GRid *def_occ;
			 struct GRmd_env *md_env )
{
  IGRlong status;
  
  /* Put the properties to no protect: */

  prop = prop | ACcant_place_sym;

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

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{

	strcpy(info->type,"Bounded Volume ");
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

method	ACconstruct_feet( 	IGRlong *rc; 
				IGRint cn_type; 
			 	IGRint count; 
				struct GRid list[];
			 	struct GRmd_env *md_env;
			 	IGRint *fcount; 
				struct GRid *feet_list )
{
  IGRlong 		status,loc_msg;
  IGRboolean		found;
  struct GRvg_construct cst;
  struct IGRdisplay 	display;
  IGRlong 		sizebuf, nret;
  IGRshort 		level ;
  IGRint 		i, k, nb_surfs, nb_sf,  track, ordered;
  IGRdouble 		dbl_val;
  IGRdouble 		dbl_inf;
  struct GRid 		track_id, bndsf;
  char 			name[80];
  unsigned int		infinite;
  IGRshort 		type;
  struct GRid		*surfs;
  
  *rc = MSSUCC;
  surfs = NULL;

  track_id.objid = NULL_OBJID;
  track_id.osnum = md_env->md_id.osnum;

  /* Construct construction list */


  sizebuf = sizeof(struct IGRdisplay);
  gr$get_active_display(msg    = &loc_msg, sizbuf  = &sizebuf,
			buffer = &display, nret    = &nret);

  sizebuf = sizeof(IGRshort);
  gr$get_active_level(msg     = &loc_msg, sizbuf  = &sizebuf,
		      buffer  = &level,   nret    = &nret);

  cst.msg        = &loc_msg;
  cst.newflag    = FALSE;
  cst.geometry   = NULL;
  cst.env_info   = md_env;
  cst.class_attr = NULL;
  cst.name       = NULL;
  cst.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.display    = &display;
  cst.level      = level;

 
 
  /* Get the infinite */

  status = om$send(msg = message SMmgr.SMGetAttDbl
		   (&loc_msg,"infinite",&dbl_inf,&type),
		   targetid = my_id);
  as$status();
  if(!(loc_msg & 1))
   {printf("Error get infinite objid = %d\n",my_id); goto wrapup;}

  infinite = (unsigned int) dbl_inf;

 /* Get the track */

  status = om$send(msg = message SMmgr.SMGetAttDbl
		   (&loc_msg,"track",&dbl_val,&type),
		   targetid = my_id);
  as$status();
  if(!(loc_msg & 1))
   {printf("Error get track objid = %d\n",my_id); goto wrapup;}

 track = (int) dbl_val;

/* Get the name */

  status = om$send(msg = message SMmgr.SMGetAttTxt
		   (&loc_msg,"name",name,&type),
		   targetid = my_id);
  as$status();
  if(!(loc_msg & 1))
   {printf("Can't get the name objid = %d\n",my_id); goto wrapup;}
   
/* Get the ordered flag */

   status = om$send(msg = message SMmgr.SMGetAttDbl
		   (&loc_msg,"ordered",&dbl_inf,&type),
		   targetid = my_id);
  as$status();
  if(!(loc_msg & 1))
   {printf("Can't get the ordered flag objid = %d\n",my_id); goto wrapup;}
  ordered = (int)dbl_inf;

  nb_sf = count-1;
  if(track)   {
	track_id = list[count-1];
	nb_sf = count-2;
   }

  /* if a surface appears more than one time, don't take it if ordered = 0 */

  surfs = _MALLOC(nb_sf, struct GRid);
  if(surfs == NULL){
  	printf("ERROR Bad allocation\n");
  	goto wrapup;
  }
  nb_surfs = 0;  
  if(ordered == 0){
  	for(i=1;i<nb_sf+1;i++){
  		found = FALSE;
  		for(k=0;k<nb_surfs;k++){
  			if(surfs[k].objid == list[i].objid && 
  				surfs[k].osnum == list[i].osnum) {
  					found = TRUE;
  					break;
  				}
  		}
  		if(found == TRUE) continue;
  		surfs[nb_surfs] = list[i];
  		nb_surfs ++;
  	}
  }
  else{
  	nb_surfs = nb_sf;
  	for(i=0;i<nb_surfs;i++) surfs[i] = list[i+1];
  }

 /* Construct the bounded volume as feet 0 */


  status = SMCrtVolBnd(&loc_msg, nb_surfs, surfs, infinite, ordered, &track_id, 
  			md_env, &cst, &bndsf);

  as$status();
  if (!(status & loc_msg & 1)){
    		printf("error in SMCrtVolBnd\n");
     		feet_list[0].objid = NULL_OBJID;goto wrapup;
  }
  else
    {feet_list[0].objid = bndsf.objid; feet_list[0].osnum = bndsf.osnum;}

  *fcount = 1;
  _FREE(surfs) ;
  *rc = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  _FREE(surfs);
  *rc = MSFAIL;
  return OM_E_ABORT;
}

method SMcreate(IGRlong *msg; IGRchar *name; IGRint ordered; IGRint nb_surf; 
		struct GRid *track_id;struct GRid *surfs; unsigned int infinite)
{
  struct ACrg_coll 	ACrg[4];
  IGRlong 		sizebuf, nret;
  struct GRmd_env 	mod_env;
  struct GRid 		*roots;
  IGRlong 		status;
  IGRint		i, track, nb_roots;
  struct GRsymbology	symb;

  roots = NULL;
  *msg = MSSUCC;

  if(nb_surf == 0){
	ex$message(msgnumb = SM_E_ErNoSf);
	*msg = MSFAIL;
	goto wrapup;
  }
  sizebuf = sizeof(struct IGRdisplay);
  gr$get_active_display(	msg    = msg, 
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr, 
				nret   = &nret);

  sizebuf = sizeof(IGRshort);
  gr$get_active_level(		msg     = msg, 
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,   
				nret    = &nret);

  if(track_id->objid != NULL_OBJID) nb_roots = nb_surf + 2;
  else nb_roots = nb_surf + 1;


  roots = _MALLOC(nb_roots, struct GRid);
  if(roots == NULL){
	printf("ERROR, Bad allocation\n");
	*msg = MSFAIL;
	goto wrapup;
  }
	
  /* Construct ACrg_colection */

  strcpy(ACrg[0].name,"name");
  ACrg[0].desc.type = AC_ATTRIB_TEXT;
  strncpy(ACrg[0].desc.value.att_txt,name,ATTR_TXT)[ATTR_TXT -1] = '\0';

  
  strcpy(ACrg[1].name,"infinite");
  ACrg[1].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[1].desc.value.att_exp= (IGRdouble) infinite;
 
  strcpy(ACrg[2].name,"ordered");
  ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[2].desc.value.att_exp = (IGRdouble) ordered;

  if(track_id->objid == NULL_OBJID) track = 0;
  else track = 1;

  strcpy(ACrg[3].name,"track");
  ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[3].desc.value.att_exp = (IGRdouble)track;


  roots[0].osnum = OM_Gw_current_OS;
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
		   (msg,4,ACrg),
		   targetid = roots[0].objid,
		   targetos = roots[0].osnum);

  as$status();
  if(!(status & *msg & 1)){
	printf("Problem SMAddAtt for objid %d\n",my_id); 
	*msg = MSFAIL;
	goto wrapup;
  }
  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg    = msg, sizbuf  = &sizebuf,
		    buffer = &mod_env,nret = &nret);

  for(i=0;i<nb_surf;i++) roots[i+1] = surfs[i];
  if(track_id->objid != NULL_OBJID) roots[nb_surf+1] = *track_id;

  if(ordered) NDduplicate_root(nb_roots, roots);
  
  status = om$send(msg = message ACncpx.ACmplace
		   ((IGRint *)msg,ACcant_place_sym,0,
		    "SMVolBnd",nb_roots, roots,&mod_env),
		   targetid = my_id);

  as$status();
  if(!(status & *msg & 1)){
	printf("erreur place macro\n"); 
	*msg = MSFAIL;
	goto wrapup;
  }


  status = om$send(msg = message GRvg.GRputname(msg,name),
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
		


  _FREE(roots );
  return OM_S_SUCCESS;
wrapup:
  _FREE(roots );
  return OM_E_ABORT;
}


method SMModify(IGRlong *msg; IGRchar *name; IGRint ordered;
		IGRint nb_surf; struct GRid *track_id;
		struct GRid *surfs; unsigned int infinite)
{
  struct GRid 		*old_surfs, *temp,original, my_grid;
  IGRlong 		status;
  IGRboolean 		discon, put_batch = FALSE;
  char 			old_name[MAX_CHAR];
  IGRint		track, old_track, old_ordered, i, old_nbsf, nb_temp;
  unsigned int		old_infinite;
  IGRlong 		sizebuf, nret;
  struct GRmd_env 	mod_env;
  struct GRsymbology	symb;

  old_surfs = NULL;
  temp = NULL;

  *msg = MSSUCC;

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg    = msg, sizbuf  = &sizebuf,
		    buffer = &mod_env,nret = &nret);

  my_grid.objid = my_id;
  my_grid.osnum = mod_env.md_id.osnum;

  sizebuf = sizeof(struct IGRdisplay);
  gr$get_active_display(	msg    = msg, 
				sizbuf = &sizebuf,
                        	buffer = &symb.display_attr, 
				nret   = &nret);

  sizebuf = sizeof(IGRshort);
  gr$get_active_level(		msg     = msg, 
				sizbuf  = &sizebuf,
                      		buffer  = &symb.level,   
				nret    = &nret);

  status = om$send(msg = message SMVolBnd.SMGetParameters
		   (msg,old_name, &old_ordered, &old_track,&old_nbsf, 
			&old_surfs, &old_infinite),
		   targetid = my_id);
  as$status();
  if(!(status & *msg & 1)){
	printf("Erreur retrieving parameter of bounded surface\n");
	*msg = MSFAIL;
	goto wrapup;
  }

  if(strcmp(old_name,name))
   {

     if(!SMChgElemName(&my_grid, name, &mod_env)){
		printf("Warning: can't change macro name\n");
     }

     status = om$send(msg = message SMmgr.SMSetAttTxt
		      (msg,"name",name,SM_DYNAMIC_ATT),
		      targetid = my_id);
     as$status();
     if(!(status & *msg & 1)){
	printf("Erreur set name\n");
	*msg = MSFAIL;
	goto wrapup;
     }
     
   }

  if(track_id->objid != NULL_OBJID) track = 1;
  else track = 0;
  
  if(track != old_track)
   { 
     status = om$send(msg = message SMmgr.SMSetAttDbl
		      (msg,"track",(IGRdouble)track,SM_DYNAMIC_ATT),
		      targetid = my_id);
     as$status();
     if(!(status & *msg & 1)){
	printf("Erreur set track\n");
	*msg = MSFAIL;
	goto wrapup;
     }
     put_batch = TRUE;
   }

  if(track_id->objid != NULL_OBJID) nb_temp = nb_surf + 1;
  else nb_temp = nb_surf;


  temp = _MALLOC(nb_temp, struct GRid);
  if(temp == NULL){
	printf("ERROR Bad dynamic allocation\n");
	*msg = MSFAIL;
	goto wrapup;
  }     
  
  for(i=0;i<nb_surf;i++) temp[i] = surfs[i];
  if(track_id->objid != NULL_OBJID) temp[nb_surf] = *track_id;

  /* not a NDnode.NDchange_connect because some new roots can be old roots
     at an other place */

  discon = FALSE;
  
  if( old_nbsf != nb_temp) discon = TRUE;
  i = 0;
  while(discon == FALSE && i<old_nbsf && i< nb_temp ){
  		if(old_surfs[i].objid != temp[i].objid ||
  		   old_surfs[i].osnum != temp[i].osnum)
  		   	discon = TRUE;
  		i++;	   
  }

  if(discon){ 
     	put_batch = TRUE;
	if(old_nbsf){
  		status = om$send(msg = message NDnode.NDdisconnect
		      (old_nbsf,old_surfs),
		      targetid = my_id);
  		as$status();
  		if(!(status & 1)){
			printf("Erreur NDnode.NDdisconnect\n");
			*msg = MSFAIL;
			goto wrapup;
  		}
	}
  	if(ordered) NDduplicate_root(nb_temp, temp);
  	original.objid = NULL_OBJID;
  	status = om$send(msg = message NDnode.NDconnect
		      (nb_temp, temp, original, ND_ADD),
		      targetid = my_id);
  	as$status();
  	if(!(status & 1)){
		printf("Erreur NDnode.NDconnect\n");
		*msg = MSFAIL;
		goto wrapup;
  	}
  }
  


  if(infinite != old_infinite)
   { 
     status = om$send(msg = message SMmgr.SMSetAttDbl
		      (msg,"infinite",(IGRdouble) infinite,SM_DYNAMIC_ATT),
		      targetid = my_id);
     as$status();
     if(!(status & *msg & 1)){
	printf("Erreur set infinite\n");
	*msg = MSFAIL;
	goto wrapup;
     }
     put_batch = TRUE;
   }

  if(ordered != old_ordered)
   {

     status = om$send(msg = message SMmgr.SMSetAttDbl
		      (msg,"ordered",(IGRdouble) ordered,SM_DYNAMIC_ATT),
		      targetid = my_id);
     as$status();
     if(!(status & *msg & 1)){
	printf("Erreur set ordered\n");
	*msg = MSFAIL;
	goto wrapup;
     }
     put_batch = TRUE;
  }



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
     
     if(wait_batch == ND_DEFER) goto endend; /* Nothing to do */
  
     nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
   }
  
endend:
  _FREE(temp); 
  _FREE(old_surfs);
  return OM_S_SUCCESS;

wrapup:

  _FREE(temp);
  _FREE(old_surfs);
  return OM_E_ABORT;
}

method SMGetParameters(IGRlong *msg;IGRchar *name;
		IGRint *ordered; IGRint *track; IGRint *nb_surf; 
		struct GRid **surfs; unsigned int *infinite)

{ 
  IGRshort 	type;
  IGRlong 	status;
  char 		my_name[MAX_CHAR];
  IGRint  	i, tmp, count;
  struct GRid	*roots;
  IGRdouble	inf_dbl;

  roots = NULL;
  *msg = MSSUCC;

  if(surfs != NULL) *surfs = NULL;

  status = om$send(msg = message GRvg.GRgetname(msg,my_name),	   
		      targetid = my_id);
  as$status();
  if(!(status & *msg & 1)) my_name[0] = '\0';
  status = om$send(msg = message NDnode.NDget_objects
		      (ND_ROOT| ND_IN_BUF,NULL, 0, &roots, 0, OM_K_MAXINT,&count),
		      targetid = my_id);
  as$status();
  if(status != OM_S_SUCCESS)
      {printf("can't retreive roots for objid = %d\n",my_id);}

  /* Jean : 5/4/93  Modify if macro is broken (has lost his parents) */
 /* If macro has been move to root due to delete of one of the roots */
 /* Creation of two dummy expression to allow to recreate a depandancy */
  if(count == 0){
    struct GRid		exp;
    struct ACrg_coll 	ACrg[4];
    struct GRid 	original;
    unsigned int	inf_mask;
    int         	state;


    /* Recreate an ACrg_collection with default attributes */

    strcpy(ACrg[0].name,"name");
    ACrg[0].desc.type = AC_ATTRIB_TEXT;
    strncpy(ACrg[0].desc.value.att_txt,my_name,ATTR_TXT)[ATTR_TXT -1] = '\0';

    inf_mask = 0xFFFF;

    strcpy(ACrg[1].name,"infinite");
    ACrg[1].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[1].desc.value.att_exp= (IGRdouble)inf_mask;


    strcpy(ACrg[2].name,"ordered");
    ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[2].desc.value.att_exp = 0.0;

  
    strcpy(ACrg[3].name,"track");
    ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[3].desc.value.att_exp = 0.0;

    exp.osnum = OM_Gw_current_OS;
    status = om$construct(classid = OPP_SMcoll_class_id,
			osnum   = exp.osnum,
			p_objid = &exp.objid);
    as$status( action = GOTO_VALUE, value = wrapup);

    status = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL), 
		   targetid = exp.objid,
		   targetos = exp.osnum);
    as$status();

    status = om$send(msg = message ACrg_collect.ACadd_list_attribute
		   (msg,4,ACrg),
		   targetid = exp.objid,
		   targetos = exp.osnum);

    as$status();

    original.objid = NULL_OBJID;
    status = om$send(msg = message NDnode.NDconnect
		   (1, &exp, original, ND_ADD),
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

  if(name != NULL)
   {
     strcpy(name,my_name);
   }

  /* Get the track attribute */
   if(track ){
   	status = om$send(msg = message SMmgr.SMGetAttDbl
		      (msg,"track",&inf_dbl,&type),
		      targetid = my_id);
   	as$status();
   	if(!(*msg & 1)){
		printf("Error get ordered flag objid = %d\n",my_id); 
		status =  OM_S_SUCCESS;
		*msg = MSFAIL;
		goto wrapup;
   	}
   	*track = (int) inf_dbl;
    }

   status = om$send(msg = message SMmgr.SMGetAttDbl
		      (msg,"ordered",&inf_dbl,&type),
		      targetid = my_id);
   as$status();
   if(!(*msg & 1)){
	printf("Error get ordered flag objid = %d\n",my_id); 
	status =  OM_S_SUCCESS;
	*msg = MSFAIL;
	goto wrapup;
   }
   tmp = (int) inf_dbl;

  if(ordered != NULL)
  /* Get the ordered flag */
   {
     *ordered = tmp;
   }

  /* Get the surfaces */

  if(surfs != NULL || nb_surf != NULL)
   {

     if(nb_surf != NULL) *nb_surf = count-1;
     if(surfs != NULL){
	*surfs = _MALLOC( (count-1), struct GRid);
	if(*surfs == NULL){
		printf("ERROR Bad allocation of surfs\n");
		*msg = MSFAIL;
		goto wrapup;
	}
	for(i=0;i<count-1;i++) (*surfs)[i] = roots[i+1];
     }
   }


  /* Get infinite */

  if(infinite != NULL)
   {
     
     status = om$send(msg = message SMmgr.SMGetAttDbl
		      (msg,"infinite",&inf_dbl,&type),
		      targetid = my_id);
     as$status();
     if(!(*msg & 1)){
	printf("Can't get the infinite objid = %d\n",my_id); 
	status =  OM_S_SUCCESS;
	*msg = MSFAIL;
	goto wrapup;
     }
     *infinite = (unsigned int) inf_dbl;

   }  
wrapup:
  if(*msg == MSFAIL && surfs != NULL && (*surfs) != NULL)
	_FREE(*surfs);
  return status;
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjVolBnd ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMVolBnd;




