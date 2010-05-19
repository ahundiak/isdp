/* $Id: VDSTextMsg.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/cmd / VDSTextMsg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSTextMsg.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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
# Revision 1.2  1995/08/07  23:20:26  pinnacle
# Replaced: vdlocate/cmd/VDSTextMsg.I for:  by azuurhou for vds.240
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

/*\
Description
   This is the implemenatation file for generating a select set by selecting
   the individual elements that should be in the set.  The select set is
   placed on the input queue.

History
   10-09-91 Genesis at ISDC
\*/

class implementation VDCmdLcNm;

#include <stdio.h>
#include <string.h>

#include "grgsdef.h"
#include "grmessage.h"
#include "grgsmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "OMmacros.h"
#include "refdef.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "asmacros.h"
#include "comiscmac.h"
#include "VDStextdef.h"
#include "VDSudp_mac.h"
#include "VDSpathdef.h"
#include "FI.h"
#include "AS_status.h"

#include "VDmsg.h"

#define	INSIDE          1
#define OUTSIDE         0
#define LO_COLOR        0
#define HI_COLOR        512
#define LO_STYLE        0
#define HI_STYLE        8
#define LO_WEIGHT       0
#define HI_WEIGHT       32
#define WEIGHT_DEFINED  1
#define COLOR_DEFINED   2
#define STYLE_DEFINED   4

#define MAX_STATCHAR	45

#define AS_DEBUG	1

from	GRgrset		import	GSobject_add; 
from	GRcontext	import	GRgetmodule_env;


extern GRclassid        OPP_DIrectory_class_id;

/* ---------------------------------------------------------------------
/* VDSconstruct_graphics_set
/* --------------------------------------------------------------------- */

method VDSconstruct_graphics_set ( long * sts )
{
/*.VDSconstruct_graphics_set*/

IGRint	status = OM_S_SUCCESS;


/*
 *  Construct a graphics set.  The flag = 2 signifies to construct
 *  a graphics set that is to be used as a select set.
 */
  *sts = MSSUCC;

  if( me->gs_id.objid != NULL_OBJID ){
     /*" empty gs_id[%d,%d]\n", me->gs_id.objid, me->gs_id.osnum */
     status = gr$gsempty (msg = sts, 
 			 p_chanselect = &me->located_chansel);
 
    if( *sts != MSSUCC){
 	om$report_error( sts = status );
 	goto wrapup;
    }
  }
  me->gs_id.osnum = me->act_env.md_id.osnum;
  status = gr$gsinit(	msg = sts, 
			flag = 2,
			p_objid = &me->gs_id.objid,
			osnum = me->gs_id.osnum,
			p_chanselect = &me->located_chansel);	/* CEO_LOCATE */
  if( *sts != MSSUCC){
	om$report_error( sts = status );
	goto wrapup;
  }

  /*" me->gs_id: %d, %d\n",me->gs_id.objid,me->gs_id.osnum*/
  *sts = MSSUCC;
  return OM_S_SUCCESS;

wrapup:
  *sts = MSFAIL;
  return OM_E_ABORT;
}

/* ---------------------------------------------------------------------
/* VDSinit_select_form
/* --------------------------------------------------------------------- */

method VDSinit_select_form( long * sts )
{
/*.VDSinit_select_form*/
IGRint			status = OM_S_SUCCESS;
IGRchar			expr_dir[DI_PATH_MAX];
IGRint			resp, setup_state;
struct	GRid		tmp_obj;

  *sts = MSSUCC;
  setup_state = FALSE;
/*
 * get current working directory
 */
  /*| get_cur_mod */
  status = ex$get_cur_mod(   id = &tmp_obj.objid,
			  osnum = &tmp_obj.osnum );
  if(!(status&1)){
	printf("ERROR ex$get_cur_mod\n");
	me->state = _terminate;	me->del_flag = 1;return( OM_I_STOP_SENDING );
  }
/* 
 * check if directory exist; if not create the directory
 */

  /*| give pathname */
  status = di$give_pathname(osnum  = tmp_obj.osnum,
 			  pathname = expr_dir );
  if( status != DIR_S_SUCCESS ){
	printf("ERROR di$give_pathname\n");
	me->state = _terminate;	me->del_flag = 1;return( OM_I_STOP_SENDING );
  }
  /*" active file <%s> \n", expr_dir */

  strcat( expr_dir, VDS_EXPR_DIR );
  /*" expr_dir : <%s> \n", expr_dir */
  status = di$translate(	objname = expr_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );
  if( status != DIR_S_SUCCESS ){
	/*| have to create the object */
	tmp_obj.objid = NULL_OBJID;
	setup_state = TRUE;
	status = di$mkdir( dirname = expr_dir,
			p_dirid = &tmp_obj.objid,
			p_osnum = &tmp_obj.osnum );
	if( status != DIR_S_SUCCESS ){
		me->state = _terminate;	me->del_flag = 1;return( OM_I_STOP_SENDING );
	}
  }
  strcpy( me->expr_dir, expr_dir );	
  /*" exp_dir <%s> \n", me->expr_dir */

/*
 * initialisation of the textset list and afterwards 
 * read the expression from the directory
 */


  resp = VDSread_expr_dir(	&me->text_list,
				me->expr_dir ,
				&me->act_env);
  if( ! resp  ){
	printf(" ERROR: fct VDSread_expr_dir failed \n");
	goto wrapup;
  }

  resp = VDSfill_textset_list(	&me->text_list,
				me->my_form_ptr, 
				VDS_SELECT_FLD );
  if( ! resp ){
	printf(" ERROR: fct VDSfill_textset_list failed \n");
	goto wrapup;
  }
/*
 * look if an default expression is set
 */
  if( ! setup_state ){
    resp = VDSget_select_text(	&me->text_list,
				&me->disp_text,
				me->expr_dir,
				&me->act_env );
    if( ! resp ){
	  printf(" ERROR: fct VDSget_select_text failed \n");
	  goto wrapup;
    }
  }
  else{	resp = VDSset_null_text( 	&me->disp_text );
	if( ! resp ){
	  printf(" ERROR: fct VDSset_null_text failed \n");
	  goto wrapup;
	}
  }

  /* initialisation of variable  */
  me->event_str[0] = '\0';

  me->gs_id.objid = NULL_OBJID;
  me->gs_id.osnum = me->act_env.md_id.osnum;

  *sts = MSSUCC;
  return OM_S_SUCCESS;

wrapup:
  *sts = MSFAIL;
  return OM_S_SUCCESS;
}

/* ---------------------------------------------------------------------
/* VDSselect_graphics_set
/* --------------------------------------------------------------------- */

method VDSselect_graphics_set ( long * sts )
{
/*.VDSselect_graphics_set*/
IGRint	status = OM_S_SUCCESS;
IGRint	count;

  *sts = MSSUCC;

  status = gr$gsinqcount( msg	= sts, 
			  count = &count,
			  object_id = &me->gs_id );
  if( !( status & 1 )){
	om$report_error( sts = status );
	goto wrapup;
  }
  /*" gs_id: [%d,%d] has %d objects\n", me->gs_id.objid, me->gs_id.osnum, count */

  if( count ){            
    /*| Define the graphics set as the active select set */
    status = gr$gsput_select_set(	msg	= sts,
					mod_env = &me->act_env,
					select_set_id = &me->gs_id );
    if( !( status & 1 )){
	om$report_error(sts = status);
	goto wrapup;
    }

    /* put the select set in the queue */
    status = om$send( msg = message VDCmdLcNm.VDSput_setqueue
						( sts ),
			  targetid = my_id );
    if( !( status & 1 )){
	om$report_error( sts = status );
	goto wrapup;
    }
  }
  else {*sts = MSFAIL; goto wrapup; }

  *sts = MSSUCC;
  return OM_S_SUCCESS;

wrapup:

  *sts = MSFAIL;
  return OM_S_SUCCESS;
}

/* ---------------------------------------------------------------------
/* VDSput_setqueue
/* --------------------------------------------------------------------- */

method VDSput_setqueue ( long * sts )
{
/*.VDSput_setqueue*/
IGRint		status = OM_S_SUCCESS;
IGRint		response;
IGRlong		size;
struct GRevent	event;

  *sts = MSSUCC;

  /*" gs_id: [%d,%d]\n", me->gs_id.objid, me->gs_id.osnum */

  event.num_id = 1;
  event.located_object[0].located_obj = me->gs_id;
  event.located_object[0].module_info = me->act_env;

  size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

  /*| Put EX_OBJID event on front of software queue */

  response = EX_OBJID;
  /*| send event */
  status = ex$putque(	msg      = sts,
			response = &response,
			byte     = &size,
			buffer   = (IGRchar *)&event.event.button );
  if( !( status & 1 )){
	om$report_error( sts = status );
	goto wrapup;
  }
  *sts = MSSUCC;
  return OM_S_SUCCESS;

wrapup:

  *sts = MSFAIL;
  return OM_E_ABORT;
}

/* ---------------------------------------------------------------------
/* VDSevaluate_string
/* --------------------------------------------------------------------- */

method VDSevaluate_string( 	long * sts ; 
				struct GRid **list_id; 
				struct GRmd_env **env_list; 
				int  *nb_list;
				int  *max_list)

{
/*.VDSevaluate_string*/
IGRint		r_pos, sel_flag,index, nb_ref,status = OM_S_SUCCESS;
IGRint		my_stat, err_flag;
IGRint		*nb_lines,nb_search, i, k, l,len, path_len;
IGRchar		***lines,**search_path, attach_in[DI_PATH_MAX],
		pathname[DI_PATH_MAX];
struct GRid	*exid,mgr_id,ref_id, context;
DIgrid		**exp;
struct GRmd_env	*smd_env,md_env;
OM_S_CHANSELECT chan,super_chan;
IGRchar		ref_file[DI_PATH_MAX], **attach, msg_text[3*DI_PATH_MAX],
		response_data[DI_PATH_MAX], stat_text[3*DI_PATH_MAX],choosen[DI_PATH_MAX];
IGRlong		response;
IGRuint		count;
struct GRevent  event;
GRclassid       obj_classid;

IGRboolean	found;

/*
 * Put event one on front of software queue.
 */


  *sts = MSSUCC;
  err_flag	= FALSE;

  ref_id.objid	= NULL_OBJID;
  context.objid	= NULL_OBJID;

  smd_env	= NULL;
  nb_lines	= NULL;
  lines		= NULL;
  exp		= NULL;
  search_path	= NULL;
  exid		= NULL;
  attach	= NULL;

  ref_file[0]	= '\0';
  nb_search 	= 0;
  count		= 0;
  index		= 0;



/*
 * get system pathname and concatenate the VDS_REF_DIR directory
 * directory to generate a total path
 */
  my_stat = di$give_pathname( 	osnum	 = me->act_env.md_id.osnum, 
				pathname = pathname );
  if( my_stat != DIR_S_SUCCESS ){
	di$report_error(sts = (int)my_stat);
	err_flag = TRUE; goto wrapup;
  }

  strcat( pathname, VDS_REF_DIR );
  path_len = strlen( pathname );    /* pathname = ":filename:ref:" */

/*
 * make the channel selection, because the object is in a
 * reference file; Used to get the module env of the specified
 * ref plane
 */

  om$make_chanselect( channame     = "GRreffile.to_context",
                      p_chanselect = &chan);

  om$make_chanselect( channame     = "Super_rfmgr.mgr",
                      	      p_chanselect = &super_chan);


  if( me->event_str[0] == ':' ){ 
	
	/* absolute path => don't use path_system */


	nb_search = 1;
  	nb_lines = (int *)om$malloc(size = nb_search * sizeof(int));
  	if( nb_lines == NULL ){
		printf(" ERROR: bad dynamic allocation of nb_lines(%d)\n", nb_search );
		err_flag = TRUE; goto wrapup;
	}
  	exp = (DIgrid **)om$malloc(size = nb_search * sizeof(DIgrid *) ); 
  	if( exp == NULL ){
		printf(" ERROR: bad dynamic allocation of exp(%d)\n", nb_search );
		err_flag = TRUE; goto wrapup;
	}
	for(i=0;i<nb_search;i++) exp[i] = NULL;
	
  	lines = (char ***)om$malloc(size =  nb_search * sizeof(char **));
  	if( lines == NULL ){
		printf(" ERROR: bad dynamic allocation of lines(%d)\n", nb_search );
		err_flag = TRUE; goto wrapup;
	}
	for(i=0;i<nb_search;i++) lines[i] = NULL;
	
	lines[0]	= NULL;
	exp[0]		= NULL;
	nb_lines[0]	= 0;
	
	my_stat = di$dump(	regexp = me->event_str,
            			lines  = &lines[0],
				grids  = &exp[0],
	    			ptr    = &nb_lines[0]);
	if( my_stat != DIR_S_SUCCESS )  goto wrapup;

	else{
    		if(*max_list < *nb_list + nb_lines[0]){
			*list_id = (struct GRid *) om$realloc(
					   ptr  = (char *) *list_id,
					   size = ( *max_list + nb_lines[0] )
						* sizeof(struct GRid) ); 
    			if( *list_id == NULL ){
				   printf("ERROR: bad reallocation of list_id\n");
				   err_flag = TRUE;
				   goto wrapup;
    			}
			*env_list = (struct GRmd_env *) om$realloc(
					   ptr  = (char *) *env_list,
					   size = (*max_list + nb_lines[0])
						* sizeof(struct GRmd_env) ); 
    			if( *env_list == NULL ){
				   printf("ERROR: bad reallocation of env_list\n");
				   err_flag = TRUE;
				   goto wrapup;
    			}
			*max_list = *max_list + nb_lines[0];
		}
  		for( k=0; k<nb_lines[0]; k=k+1){

 		  	status = om$get_classid(osnum     = exp[0][k].osnum,
                         		  objid     = exp[0][k].objid,
                         		  p_classid = &obj_classid);

 		  	if( om$is_ancestry_valid(subclassid   = obj_classid,
                          		superclassid = OPP_DIrectory_class_id )
                           		== OM_S_SUCCESS ){
				/* the object is a directory, don't add to grset */
				continue;
		  	}
		}
		/* get the module_env of the object */
		
		if( strncmp( me->event_str, pathname, path_len ) == 0 ){

			/* me->event_str begin as ":filename:ref:" 
	     	   	ie the object is in a ref_file */


	  	   	my_stat = di$split(	pathname = me->event_str, 
	  				   	dirname  = ref_file);
	  	   	if(my_stat != DIR_S_SUCCESS){
			   	printf("error di$split\n");
			   	goto wrapup;
	  	   	}
	  	   	my_stat = di$translate(	objname = ref_file,
					p_objid = &ref_id.objid,
					p_osnum = &ref_id.osnum );
	  	   	if( my_stat != DIR_S_SUCCESS ){
	    		   	err_flag = TRUE; 
	    		   	goto wrapup;
	  	   	}

	  	   	my_stat = ex$get_super(	mod_id = me->act_env.md_id.objid,
					mod_osnum = me->act_env.md_id.osnum,
					super_name = "Ref Mgr",
					super_class = "Super_rfmgr",
					create = 0,
					super_id = &mgr_id.objid,
					super_osnum = &mgr_id.osnum);


	   	   	if(my_stat != OM_S_SUCCESS) printf("error ex$get_super\n");

          
	  	   	om$get_channel_count( p_chanselect = &super_chan,
						osnum = mgr_id.osnum,
						objid = mgr_id.objid,
						count = &count);


	  	   	exid = (struct GRid *)om$malloc(size = count * sizeof(struct GRid));
  	  	   	if( exid == NULL ){
			   	printf(" ERROR: bad dynamic allocation of exid\n");
			   	err_flag = TRUE; goto wrapup;
		   	}


	  	   	attach = (char **)om$malloc(size =  count * sizeof(char *));
  	  	   	if( attach == NULL ){
			   	printf(" ERROR: bad dynamic allocation of attach\n");
			   	err_flag = TRUE; goto wrapup;
		   	}
	  
          	   	for(i=0;i<count;i++){
			   	attach[i] = NULL;
			   	attach[i] = (char *) om$malloc(size =  DI_PATH_MAX *  sizeof(char));
  	  		   	if( attach[i] == NULL ){
				   	printf(" ERROR: bad dynamic allocation of attach[%d]\n",i);
				   	err_flag = TRUE; goto wrapup;
			   	}
	   	   	}
			FIfld_get_text(me->my_form_ptr, VDS_ATTACH_NAME, 0,0, DI_PATH_MAX,
					attach_in, &sel_flag, &r_pos);
			found = FALSE;
          	   	for(i=0;i<count;i++){
	  		   	om$get_objid_at_index( 	osnum = mgr_id.osnum,
				 	objid = mgr_id.objid,
					p_chanselect = &super_chan,
					index = i,
					objidaddr = &exid[i].objid,
					osnumaddr = &exid[i].osnum);
	   		   	my_stat = di$untranslate(	objname = attach[i],
						objid = exid[i].objid,
						osnum = exid[i].osnum);
			   	if(my_stat != DIR_S_SUCCESS){
				   	printf("error di$untranslate\n");
				   	di$report_error(sts = my_stat);
			   	}
			   	my_stat = di$split(	pathname = attach[i], 
						   	name     = attach[i]);
			   	if(my_stat != DIR_S_SUCCESS){
				   	printf("error di$split\n");
				   	di$report_error(sts = my_stat);
			   	}
				if(attach_in[0] != '\0' && 
					!strcmp(attach_in, attach[i])){
					found = TRUE;
					index = i;
					break;
				}

	   	   	}

			if(found) goto DEFINED_ATTACH;
			else if(attach_in[0] != '\0') 
			 	FIg_set_text(me->my_form_ptr, FI_MSG_FIELD, 
					"Invalid attach name");


	  	   	nb_ref = 0;
	   	   	sprintf(msg_text,"Attach name for %s ?",me->event_str);
	   	   	k=0;
	   	   	index = 0;
	   	   	strcpy(stat_text,"Attach Name: ");
	   	   	len = strlen(stat_text);

           	   	for(i=0;i<count;i++){
  	  		   	om$get_objid_at_index( osnum = exid[i].osnum,
				    	objid = exid[i].objid,
				    	p_chanselect = &chan,
				    	index = 0,
				    	objidaddr = &context.objid,
				    	osnumaddr = &context.osnum );

          		   	status = om$send( msg = message GRcontext.GRgetmodule_env
					(sts, &md_env ),
                  	       	   	targetid = context.objid,
                  	       	   	targetos = context.osnum );
	  		   	if( !( status & 1 )){
				   	om$report_error(sts = status);
				   	err_flag = TRUE; goto wrapup;
	   		   	}
			   	if(ref_id.osnum == md_env.md_id.osnum) {
				   	strcpy(attach[k],attach[i]);
				   	exid[k].objid = exid[i].objid;
				   	exid[k].osnum = exid[i].osnum;

				   	k = k+ 1;
				   	if(nb_ref != 0) strcat(stat_text," , ");
				   	if(len+strlen(attach[i]) > MAX_STATCHAR){
					   	/*status too long => in 2 times*/
					   	UI_status(stat_text);
					   	strcpy(stat_text,"Attach Name: ... ,");
				   	}
				   	strcat(stat_text,attach[i]);
				   	nb_ref = nb_ref + 1;
	  			   	len = strlen(stat_text);
		 	   	}

	   	   	}
	   	   	strcpy(choosen,attach[0]);
	   	   	if(nb_ref > 1){
	      		   	my_stat = MSFAIL;
	      		   	while(my_stat != MSSUCC){
				  /* 	ex$message(msgnumb = VD_M_FirstAtt); */
				   	UI_status(stat_text);
				   	my_stat = co$getevent(	msg = sts,
					   	event_mask = (GRm_BACK_UP | GRm_RJT_MOVEON | GRm_STRING),
					   	prompt = msg_text,
					   	response = &response,
					   	response_data = response_data,
					   	event = &event);
				   	if(my_stat != MSSUCC){printf("ERROR co$getevent \n");err_flag = TRUE;goto wrapup;}

				   	if(response == EX_RJT_MOVEON ) {
				   		strcpy(choosen,attach[0]);
				   		my_stat = MSSUCC;
				   	}
				   	else if(response == EX_STRING)
		  		   	{
					   	for(k=0;k<nb_ref;k++){
			  			   if(strcmp(response_data,attach[k])) my_stat = MSFAIL;
						   else{ 
						   	strcpy(choosen,attach[k]);
						   	index = k;
						   	my_stat = MSSUCC;
						   	break;
						   }
			 		   	}
		  		   	}
				   	else {
					   	/* Unknown Response Type */
					   	*sts = MSINARG;
					   	goto wrapup;
				   	}
				   	UI_message("");
                		   	ex$message( msgnumb = VD_W_NoValAtt);

	       		   	}
            	   	}		
	   
DEFINED_ATTACH:
	   	   	UI_status("");

  	   	   	om$get_objid_at_index( osnum = exid[index].osnum,
				 objid = exid[index].objid,
				 p_chanselect = &chan,
				 index = 0,
				 objidaddr = &context.objid,
				 osnumaddr = &context.osnum );

           	   	status = om$send( msg = message GRcontext.GRgetmodule_env
					(sts, &md_env ),
                  	    targetid = context.objid,
                  	    targetos = context.osnum );
	   	   	if( !( status & 1 )){
			   	om$report_error(sts = status);
			   	err_flag = TRUE; goto wrapup;
	   	    	}

	   	}
	   	else{
          	   	/* object not in reference file */
	  	   	md_env = me->act_env;
	   	} 
  		for( k=0; k<nb_lines[0]; k=k+1){
		  	
		  	(*list_id)[*nb_list].osnum = exp[0][k].osnum;
		  	(*list_id)[*nb_list].objid = exp[0][k].objid;
		  	(*env_list)[*nb_list]= md_env;
		  	*nb_list = *nb_list + 1;
		} 
	} 
  }
  else{	
	/*| me->event_str[0] != ':' retrieve search path */

   	my_stat = vds$get_search_path(	nb_search   = &nb_search, 
					search_path = &search_path);
  	if( !( my_stat&1 )){
	  	printf(" ERROR: macro get_search_path failed\n");
	  	err_flag = TRUE; goto wrapup;
	}

	/* 
	 * allocate a list for each module env of the found objects
	 */
  	smd_env = (struct GRmd_env *)om$malloc(size =  nb_search * sizeof(struct GRmd_env ));
  	if( smd_env == NULL ){
	  	printf(" ERROR: bad dynamic allocation of smd_env(%d)\n", nb_search );
	  	err_flag = TRUE; goto wrapup;
	}

	nb_lines = NULL;
  	nb_lines = (int *)om$malloc( size = nb_search * sizeof(int) );
  	if( nb_lines == NULL ){
		printf(" ERROR: bad dynamic allocation of nb_lines(%d)\n", nb_search );
		err_flag = TRUE; goto wrapup;
	}
	exp = NULL;
  	exp = (DIgrid **)om$malloc(size = nb_search * sizeof(DIgrid *) ); 
  	if( exp == NULL ){
		printf(" ERROR: bad dynamic allocation of exp(%d) \n", nb_search );
		err_flag = TRUE; goto wrapup;
	}
	for(l=0;l<nb_search;l++) exp[l] = NULL;
	lines = NULL;
  	lines = (char ***)om$malloc( size =  nb_search * sizeof(char **) );
  	if( lines == NULL ){
		printf(" ERROR: bad dynamic allocation of line(%d)n", nb_search );
		err_flag = TRUE; goto wrapup;
	}
	for(l=0;l<nb_search;l++) lines[l] = NULL;
	
  	for( l=0; l<nb_search; l++ ){

	  	strcat(search_path[l], ":");
	  	strcat(search_path[l], me->event_str );

		
	  	lines[l]	= NULL;
	  	exp[l]	= NULL;
	  	nb_lines[l]	= 0;
	

	  	my_stat = di$dump(	regexp	= search_path[l],
            				lines	= &lines[l],
					grids	= &exp[l],
	    				ptr	= &nb_lines[l] );

	  	if( my_stat != DIR_S_SUCCESS ){
			/*| di$dump fail */ 
			continue;
	  	}
	  	
	    	if(*max_list < *nb_list + nb_lines[l]){
			*list_id = (struct GRid *) om$realloc(
    					   ptr  = (char *) *list_id,
					   size = ( *max_list + nb_lines[l] )
						* sizeof(struct GRid) ); 
    			if( *list_id == NULL ){
				   	printf("ERROR: bad reallocation of list_id\n");
				   	err_flag = TRUE;
				   	goto wrapup;
    			}
			*env_list = (struct GRmd_env *) om$realloc(
					   ptr  = (char *) *env_list,
					   size = ( *max_list + nb_lines[l] )
						* sizeof(struct GRmd_env) ); 
    			if( *env_list == NULL ){
				   	printf("ERROR: bad reallocation of env_list\n");
				   	err_flag = TRUE;
				   	goto wrapup;
    			}
			*max_list = *max_list + nb_lines[l];
		}
  		for( k=0; k<nb_lines[l]; k=k+1 ){

 		  	status = om$get_classid(osnum     = exp[l][k].osnum,
                         		  	objid     = exp[l][k].objid,
                         		  	p_classid = &obj_classid);

 		  	if( om$is_ancestry_valid(subclassid   = obj_classid,
                          		superclassid = OPP_DIrectory_class_id )
                           		== OM_S_SUCCESS ){
				/*|the object is a directory, don't add to grset */
				continue;
		 	}
		}
		
	  	/* get the md_env */
	  	
	  	if(strncmp( search_path[l], pathname, path_len) == 0){

	    		/*| retrieve name of ref_file */

	  	   	my_stat = di$split(	pathname = search_path[l], 
	  				   	dirname  = ref_file);
	  	   	if(my_stat != DIR_S_SUCCESS){
			   	printf("error di$split\n");
			   	goto wrapup;
	  	   	}
	  	   	my_stat = di$translate(	objname = ref_file,
					p_objid = &ref_id.objid,
					p_osnum = &ref_id.osnum );
	  		if( my_stat != DIR_S_SUCCESS ){
	    			if( my_stat == DIR_W_NAME_NOT_FOUND ){
	      	  			smd_env[l] = me->act_env;
		  			continue;/* MODIF 22-05-92 */
	    			}
				else{	err_flag = TRUE; 
					goto wrapup;
				}
	  		}

	    		my_stat = ex$get_super(	mod_id = me->act_env.md_id.objid,
					mod_osnum = me->act_env.md_id.osnum,
					super_name = "Ref Mgr",
					super_class = "Super_rfmgr",
					create = 0,
					super_id = &mgr_id.objid,
					super_osnum = &mgr_id.osnum);


	    		if(my_stat != OM_S_SUCCESS) printf("error ex$get_super\n");

          
	    		om$get_channel_count( p_chanselect = &super_chan,
				  osnum = mgr_id.osnum,
				  objid = mgr_id.objid,
				  count = &count);


	    		exid = NULL;
	     		exid = (struct GRid *)om$malloc(size = count * sizeof(struct GRid));
  	     		if( exid == NULL ){
		 		printf(" ERROR: bad dynamic allocation of exid\n");
		 		err_flag = TRUE; goto wrapup;
	     		}

	     		attach = (char **)om$malloc(size =  count * sizeof(char *));
  	    		if( attach == NULL ){
		 		printf(" ERROR: bad dynamic allocation of attach\n");
		 		err_flag = TRUE; goto wrapup;
	     		}
	  
             		for(i=0;i<count;i++)
              		{
		 		attach[i] = NULL;
		 		attach[i] = (char *) om$malloc(size =  DI_PATH_MAX *  sizeof(char));
  	  	 		if( attach[i] == NULL ){
			 		printf(" ERROR: bad dynamic allocation of attach[%d]\n",i);
			 		err_flag = TRUE; goto wrapup;}
	      		}

			FIfld_get_text(me->my_form_ptr, VDS_ATTACH_NAME, 0,0, DI_PATH_MAX,
					attach_in, &sel_flag, &r_pos);
			found = FALSE;
             		for(i=0;i<count;i++){
	  	 		om$get_objid_at_index( 	osnum = mgr_id.osnum,
				 	objid = mgr_id.objid,
					p_chanselect = &super_chan,
					index = i,
					objidaddr = &exid[i].objid,
					osnumaddr = &exid[i].osnum);
	   	 		my_stat = di$untranslate(	objname = attach[i],
						objid = exid[i].objid,
						osnum = exid[i].osnum);
		 		if(my_stat != DIR_S_SUCCESS){
			 		printf("error di$untranslate\n");
			 		di$report_error(sts = my_stat);}
		 		my_stat = di$split(pathname = attach[i], name = attach[i]);
		 		if(my_stat != DIR_S_SUCCESS){
			 		printf("error di$split\n");
			 		di$report_error(sts = my_stat);
			 	}

				if(attach_in[0] != '\0' && 
					!strcmp(attach_in, attach[i])){
					found = TRUE;
					index = i;
					break;
				}
	      		}
			if(found) goto DEFINED_ATTACH1;
			else if(attach_in[0] != '\0') 
			 	FIg_set_text(me->my_form_ptr, FI_MSG_FIELD, 
					"Invalid attach name");

	    		nb_ref = 0;
	    		sprintf(msg_text,"Attach name for %s ?",search_path[l]);
	    		k=0;
	    		index = 0;
	    		strcpy(stat_text,"Attach Name: ");
	    		len = strlen(stat_text);
            		for(i=0;i<count;i++){
  	  			om$get_objid_at_index( osnum = exid[i].osnum,
				 		objid = exid[i].objid,
				 		p_chanselect = &chan,
				 		index = 0,
				 		objidaddr = &context.objid,
				 		osnumaddr = &context.osnum );

          			status = om$send( msg = message GRcontext.GRgetmodule_env
					(sts, &md_env ),
                  	    		targetid = context.objid,
                  	    		targetos = context.osnum );
	  			if( !( status & 1 )){
					om$report_error(sts = status);
					err_flag = TRUE; goto wrapup;
	   			}
				if(ref_id.osnum == md_env.md_id.osnum) {
					strcpy(attach[k],attach[i]);
					exid[k].objid = exid[i].objid;
					exid[k].osnum = exid[i].osnum;

					k = k+ 1;
					if(nb_ref != 0) strcat(stat_text," , ");
					if(len+strlen(attach[i]) > MAX_STATCHAR){
						/*|status too long => in 2 times*/
						UI_status(stat_text);
						strcpy(stat_text,"Attach Name: ... ,");
					}
					strcat(stat_text,attach[i]);
					nb_ref = nb_ref + 1;
	  				len = strlen(stat_text);
		 		}

	     		}
	    		strcpy(choosen,attach[0]);

	    		if(nb_ref > 1){
	      			my_stat = MSFAIL;
	      			while(my_stat != MSSUCC){
				/*	ex$message(msgnumb = VD_S_RejFstAtt); */
					UI_status(stat_text);
					my_stat = co$getevent(	msg = sts,
						event_mask = (GRm_BACK_UP | GRm_RJT_MOVEON | GRm_STRING),
						prompt = msg_text,
						response = &response,
						response_data = response_data,
						event = &event);
					if(my_stat != MSSUCC){printf("ERROR co$getevent \n");err_flag = TRUE;goto wrapup;}

					if(response == EX_RJT_MOVEON ) {
						strcpy(choosen,attach[0]);
						my_stat = MSSUCC;
					}
					else if(response == EX_STRING)
		  			{
						for(k=0;k<nb_ref;k++) 
			 			{
			  				if(strcmp(response_data,attach[k])) my_stat = MSFAIL;
							else 
				  			{ strcpy(choosen,attach[k]);index = k;my_stat = MSSUCC;break;}
			 			}
		  			}
					else {
      						/* Unknown Response Type */
						*sts = MSINARG;
						goto wrapup;
					}
					UI_message("");
                			ex$message( msgnumb = VD_W_NoValAtt);
	       			}
             		}
DEFINED_ATTACH1:
	    		UI_status("");

	    		om$get_objid_at_index(osnum = exid[index].osnum,
				  objid = exid[index].objid,
				  p_chanselect = &chan,
				  index = 0,
				  objidaddr = &context.objid,
				  osnumaddr = &context.osnum );

            		status = om$send( msg = message GRcontext.GRgetmodule_env
						(sts, &smd_env[l] ),
                  		  targetid = context.objid,
                  		  targetos = context.osnum );
	      		if( !( status & 1 )){
		    		om$report_error( sts = status );
		    		printf(" ERROR: msg GRcontext.GRgetmodule_env failed\n");
		    		err_flag = TRUE; goto wrapup;
	      		}

	    	}
   	    	else{
              		/*| the path has no reference */ 
	      		smd_env[l] = me->act_env;
	  	} 
	
  		for( k=0; k<nb_lines[l]; k=k+1 ){

		  	(*list_id)[*nb_list].osnum = exp[l][k].osnum;
		  	(*list_id)[*nb_list].objid = exp[l][k].objid;
		  	(*env_list)[*nb_list]= smd_env[l];
		  	*nb_list = *nb_list + 1;
		} 
	  } 

  } 

wrapup:
  /**/
  /* wrapup deallocate the reserved memory */
  /**/

  if(attach != NULL) {
 	    	for(i=0;i<count;i++) 
               	if(attach[i]!=NULL) 
                              {free(attach[i]);attach[i]=NULL;}
 	    	if(attach != NULL)free(attach);
            	attach = NULL;
                     
  }

  if( exid != NULL ){free(exid); exid = NULL;  }

  if( exp != NULL ){
   	for( i=0; i<nb_search; i++) {free(exp[i]);exp[i] = NULL;}
	free( exp ); exp = NULL;
  }
  if( lines != NULL ){
   	for( i=0; i<nb_search; i++){
      		di$free(lines = lines[i],
              		count = nb_lines[i]);
		lines[i] = NULL;
	}
	free( lines ); lines = NULL;
  }

  if( nb_lines != NULL)	{free(nb_lines);nb_lines = NULL;}
  if( smd_env  != NULL)	{free(smd_env);smd_env = NULL;}
  if( search_path != NULL){
	for(i=0; i<nb_search; i++){ 
		if( search_path[i] != NULL )
			free( search_path[i] );
		search_path[i] = NULL;
	}
	free( search_path ); search_path = NULL;
  }

  if( err_flag ) 		*sts = MSFAIL;
  else	if(*sts != MSINARG)	*sts = MSSUCC;
  return OM_S_SUCCESS ;

}

/* ---------------------------------------------------------------------
/* VDSevaluate_active_event
/* --------------------------------------------------------------------- */

method VDSevaluate_active_event( long * sts)
{
IGRchar		**prefix_list, **p_list;
IGRchar		**expres_list, **e_list;
IGRchar		**suffix_list, **s_list;
IGRchar		**no_prefix_list, **no_p_list;
IGRchar		**no_expres_list, **no_e_list;
IGRchar		**no_suffix_list, **no_s_list;
IGRint		pre_max, exp_max, env_prop,suf_max, response;
IGRint		no_pre_max, no_exp_max,no_suf_max;
IGRchar		err_msg[DI_PATH_MAX],my_msg[20];
IGRint		status = OM_S_SUCCESS;
IGRint		i, j;
IGRlong		size;
struct GRid	*list_id,*no_list_id;
struct GRmd_env	*env_list,*no_env_list;
IGRint		nb_list,no_nb_list;
IGRlong         err_key;
struct GRevent	event;

  *sts = MSSUCC;
  pre_max 	=  no_pre_max = 0;
  exp_max 	=  no_exp_max = 0;
  suf_max 	=  no_exp_max = 0;
  
  p_list = no_p_list = NULL;
  s_list = no_s_list = NULL;
  e_list = no_e_list = NULL;

  list_id  = no_list_id  = NULL;
  env_list = no_env_list = NULL; 

  UI_status("");
  err_msg[0] = '\0';

  if(me->disp_text.prefix[0] != '\0' ) 
   {
    if(vds_getreg(me->disp_text.prefix, &prefix_list, &pre_max,
                  &no_prefix_list, &no_pre_max, &err_key,my_msg ) != 1)
     {
      /* Syntax erreur for the prefix */
       if(err_key != 0) ex$message( msgnumb = err_key, buff = err_msg,
                                  type = "%s",var = `my_msg`);
      /*"err_msg : %s\n",err_msg */
      status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
      if( status != FI_SUCCESS ) me->del_flag = TRUE;
       *sts = MSFAIL; goto wrapup;
     }
    p_list = prefix_list;
    no_p_list = no_prefix_list;
    /*^for(i=0;i<pre_max;i++) {printf("p_list: %s\n",p_list[i]);}
    for(i=0;i<no_pre_max;i++) {printf("no_p_list: %s\n",no_p_list[i]);}*/
   }

  if(me->disp_text.expres[0] != '\0' ) 
   {
    if(vds_getreg(me->disp_text.expres, &expres_list, &exp_max,
                   &no_expres_list, &no_exp_max, &err_key,my_msg ) != 1)
     {
      /*| Syntax erreur for the expression */
       if(err_key != 0) ex$message( msgnumb = err_key, buff = err_msg,
                                     type = "%s",var = `my_msg`);
      /*"err_msg: %s\n",err_msg */
      status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
      if( status != FI_SUCCESS ) me->del_flag = TRUE;
      *sts = MSFAIL; goto wrapup;
    }
    e_list = expres_list;
    no_e_list = no_expres_list;
    /*^for(i=0;i<exp_max;i++) {printf("e_list: %s\n",e_list[i]);}
    for(i=0;i<no_exp_max;i++) {printf("no_e_list: %s\n",no_e_list[i]);}*/
   }

   
  if(me->disp_text.suffix[0] != '\0' ) 
   {
    if(vds_getreg(me->disp_text.suffix, &suffix_list, &suf_max,
                  &no_suffix_list, &no_suf_max, &err_key, my_msg) != 1)
     {
      /* Syntax erreur for the suffix */
       if(err_key != 0) ex$message( msgnumb = err_key, buff = err_msg,
                                    type = "%s",var = `my_msg`);
      /*"err_msg: %s\n",err_msg */
      status = FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
      if( status != FI_SUCCESS ) me->del_flag = TRUE;
        *sts = MSFAIL;goto wrapup;
     }
    s_list = suffix_list;
    no_s_list = no_suffix_list;
   /*^for(i=0;i<suf_max;i++) {printf("s_list: %s\n",s_list[i]);}
      for(i=0;i<no_suf_max;i++) {printf("no_s_list: %s\n",no_s_list[i]);}*/
   }

  /* Construct the list of objid */
 
  if(p_list == NULL && e_list == NULL && s_list == NULL){
        ex$message( msgnumb = VD_S_LocNoObj,buff = err_msg);
        FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
	*sts = MSFAIL;goto wrapup;
  }

  
   if(!VDS_construct_list_objid(p_list,e_list,s_list, pre_max,exp_max,suf_max, 
                                &nb_list, &list_id,&env_list,
                                me->event_str,err_msg,my_id))
   { *sts = MSFAIL; goto wrapup; }

 /* Now substract the negate set */
   if(no_p_list != NULL)
   {
       /*"Entree supress no_p_list"*/
      if(!VDS_construct_list_objid(no_p_list,e_list,s_list,
                                   no_pre_max,exp_max,suf_max, 
                                   &no_nb_list, &no_list_id,&no_env_list,
                                   me->event_str,err_msg,my_id))
        { *sts = MSFAIL; goto wrapup; }

        for(i = 0; i < no_nb_list ; i++)
           for(j = 0; j < nb_list; j++)
              if( no_list_id[i].objid == list_id[j].objid &&
                  no_list_id[i].osnum == list_id[j].osnum )
                       supress_list_objid(list_id,env_list,j,&nb_list);

       if(no_list_id) {free(no_list_id);free(no_env_list);}   
   }
  
   if(no_e_list != NULL)
    {
       /*"Entree supress no_e_list"*/
      if(!VDS_construct_list_objid(p_list,no_e_list,s_list,
                                   pre_max, no_exp_max,suf_max, 
                                   &no_nb_list, &no_list_id,&no_env_list,
                                   me->event_str,err_msg,my_id))
        { *sts = MSFAIL; goto wrapup;}

        for(i = 0; i < no_nb_list ; i++)
           for(j = 0; j < nb_list; j++)
              if( no_list_id[i].objid == list_id[j].objid &&
                  no_list_id[i].osnum == list_id[j].osnum )
                     supress_list_objid(list_id,env_list,j,&nb_list);
                   
         if(no_list_id) {free(no_list_id);free(no_env_list);}
    }

   if(no_s_list != NULL)
   {
      /*"Entree supress no_s_list"*/
      if(!VDS_construct_list_objid(p_list,e_list,no_s_list,
                                   pre_max,exp_max,no_suf_max, 
                                   &no_nb_list, &no_list_id,&no_env_list,
                                   me->event_str,err_msg,my_id))
        { *sts = MSFAIL ; goto wrapup; }

        for(i = 0; i < no_nb_list ; i++)
           for(j = 0; j < nb_list; j++)
             if( no_list_id[i].objid == list_id[j].objid &&
                 no_list_id[i].osnum == list_id[j].osnum )
                      supress_list_objid(list_id,env_list,j,&nb_list);
              if(no_list_id) {free(no_list_id);free(no_env_list);}
    }


/* function jla which create pretend object when object is duplicated*/

  status = VDmake_VDpretend(list_id,env_list,nb_list,list_id,env_list);
  if( !( status & 1)){
	om$report_error(sts = status);
	printf(" ERROR:  VDmake_VDpretend failed\n");
	*sts = MSFAIL ; goto wrapup;
  }

/*^
  for(i=0;i<nb_list;i++) {
	printf("pretend[%d]: %d, %d ",i,list_id[i].objid,list_id[i].osnum);
	printf("env_pretend[%d]: %d, %d\n",i,env_list[i].md_id.objid,
					  env_list[i].md_id.osnum);
  }
*/

  if(nb_list == 0) {
        ex$message( msgnumb = VD_S_LocNoObj,buff = err_msg);
        FIg_set_text( me->my_form_ptr, FI_MSG_FIELD, err_msg );
      	*sts = MSFAIL ; goto wrapup;
  }
  if(nb_list == 1){
  	/*|only one object, don't create set\n*/

  	event.num_id = 1;
  	event.located_object[0].located_obj = list_id[0];
  	event.located_object[0].module_info = env_list[0];


  	size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

  	/*| Put EX_OBJID event on front of software queue */

  	response = EX_OBJID;
  	/*| send event */
  	status = ex$putque(	msg      = sts,
				response = &response,
				byte     = &size,
				buffer   = (IGRchar *)&event.event.button );
  	if( !( status & 1 )){
  	        om$report_error( sts = status );
                *sts = MSFAIL;
		goto wrapup;
  	}
  	
  }
  else{
  	status = om$send( msg = message VDCmdLcNm.VDSconstruct_graphics_set
						( sts ),
			  targetid = my_id );
       
           if(!(status & 1)){
                *sts = MSFAIL;
                om$report_error(sts = status);
                goto wrapup;
          }
          if(*sts != MSSUCC)
          {
                ex$message( msgnumb = VD_E_CmdRst );
                *sts = MSFAIL;
                goto wrapup;
          }

  	/* graphic set post_processing */
  	status = gr$gspost_processing(msg = sts,
				p_chanselect = &me->located_chansel );
  	if( !( status & 1  )){
                om$report_error(sts = status);
                *sts = MSFAIL;
		goto wrapup;
  	}
       

  	/* add_object to set */
  	
  	env_prop = 0;
  	for(i=0;i<nb_list;i++) {
	  status = om$send( msg = message GRgrset.GSobject_add(
							sts, 
							&list_id[i],
                  					&env_list[i], 
							&env_prop, 
							NULL, NULL ),
                  		targetid = me->gs_id.objid,
                  		targetos = me->gs_id.osnum);
		  if( !( status & 1)){
			om$report_error(sts = status);
			printf(" ERROR: msg GRgrset.GSobject_add failed\n");
			*sts = MSFAIL ; goto wrapup;
		  }
  	}
  }

  /* Deallocation ..... */

  if(nb_list > 1){
  	status = om$send( msg = message VDCmdLcNm.VDSselect_graphics_set
						( sts ),
			  targetid = my_id );

   	if(!(status & 1))
          { om$report_error(sts = status);
            *sts = MSFAIL; goto wrapup; }
  	if(*sts == MSFAIL){ 
		/*|No graphics set selected */ 
                ex$message( msgnumb = VD_S_LocNoObj);
		*sts = MSFAIL; goto wrapup;
  	}
  }
 

  *sts = MSSUCC;

wrapup:
  if(*sts == MSFAIL) 
   {
    ex$message(msgnumb= VD_E_CmdRst);
   }
  if(env_list ){free(env_list);env_list = NULL;} 
  if(list_id ){free(list_id);list_id = NULL;} 
  if(p_list)
   {
    for(i=0;i<pre_max;i++) if(p_list[i]) free(p_list[i]);
    free(p_list);
   }

  if(e_list)
   {
    for(i=0;i<exp_max;i++) if(e_list[i]) free(e_list[i]);
    free(e_list);
   }

  if(s_list)
   {
    for(i=0;i<suf_max;i++) if(s_list[i]) free(s_list[i]);
    free(s_list);
   }
   if(no_p_list)
   {
    for(i=0;i<no_pre_max;i++) if(no_p_list) free(no_p_list[i]);
    free(no_p_list);
   }

  if(no_e_list)
   {
    for(i=0;i<no_exp_max;i++) if(no_e_list[i]) free(no_e_list[i]);
    free(no_e_list);
   }

  if(no_s_list)
   {
    for(i=0;i<no_suf_max;i++) if(no_s_list[i]) free(no_s_list[i]);
    free(no_s_list);
   }

   return( OM_S_SUCCESS );
}


/* If given prefix,expression,suffix , compute the list_of_objid corresponding
   to the name */
int VDS_construct_list_objid(p_list,e_list,s_list, pre_max,exp_max,suf_max,
                             nb_list, list_id,env_list, me_event_str,err_msg,myid)
IGRchar **p_list,**e_list,**s_list;  /* (I) List of prefix, expression, suffix */
IGRint pre_max,exp_max,suf_max;      /* (I) The number of element of each list */ 
IGRint *nb_list;                     /* (O) The number of element of objid list*/ 
struct GRid **list_id;               /* (O) The list of objid of element       */
struct GRmd_env	**env_list;          /* (O) The list of environnemet of element*/
IGRchar *me_event_str;               /* (I) me->env_str                        */
IGRchar *err_msg;                    /* (O) possible error message             */
GRobjid myid;                        /* (I) my_id (because it's function!)     */
{
IGRint sts,status;
int i,j,k;
int max_list = 0; 


    *nb_list = 0;
    *env_list = NULL;
    *list_id = NULL;

    if( err_msg ) err_msg[0] = '\0'; 

  *list_id = (struct GRid *) om$malloc(size = 10 * sizeof(struct GRid));
  if(*list_id == NULL){
		printf(" ERROR: bad dynamic allocation of list_id\n");
        	goto wrapup;
  }
  *env_list = (struct GRmd_env *) om$malloc(size = 10 * sizeof(struct GRmd_env));
  if(*env_list == NULL){
		printf(" ERROR: bad dynamic allocation of env_list\n");
        	goto wrapup;
  }
  max_list = 10;
  *nb_list  = 0;

  /* Now combine prefix, expression , suffix and construct objid */
  /* each list must be examined at least one time so a do loop */
  i = 0;
  do 
  {
    j = 0;
    do
    {
      k =0;    
      do
      { 
	me_event_str[0] = '\0';
	if( p_list != NULL ) strcat( me_event_str,  p_list[i] );
	if( e_list != NULL ) strcat( me_event_str,  e_list[j] );
	if( s_list != NULL ) strcat( me_event_str,  s_list[k] );
	/*" str[%d.%d,%d]: <%s>\n", i,j,k, me_event_str */
	if(me_event_str[0] == '\0'){
		/*| me_event_str[0] is null, continue */
		continue;
	}
	status = om$send( msg = message VDCmdLcNm.VDSevaluate_string
				  ( &sts ,list_id, env_list, nb_list, &max_list),
			  targetid = myid , senderid = myid);
       	as$status( action = GOTO_VALUE, value = wrapup );
  	if(sts == MSINARG){ 
      	     ex$message( msgnumb = VD_S_UnkRspTp);
             goto wrapup;
        }
  	if(sts == MSFAIL){ 
             ex$message( msgnumb = VD_S_BadEval);
             goto wrapup;
        }
        k++;
       } while(k < suf_max);
     j++;
     }while(j < exp_max);
   i++;
   } while(i < pre_max);

/*^
  printf("nb_list: %d\n",*nb_list);
  for(i=0;i<*nb_list;i++) {
	printf("list_id[%d]: %d, %d ",i,(*list_id)[i].objid,(*list_id)[i].osnum);
	printf("env_list[%d]: %d, %d\n",i,(*env_list)[i].md_id.objid,
					  (*env_list)[i].md_id.osnum);
  }
*/
   return 1;
wrapup:
   return 0;
}

/* Supress the objid of the given indice in the list_id and env_list */

supress_list_objid(list_id,env_list,indice,len)
struct GRid *list_id;       /* (I) the list of objid where supress      */ 
struct GRmd_env	*env_list;  /* (I) the list of md_env where supress too */
IGRint indice;              /* (I) the indice of element to supress     */
IGRint *len;                /* (I/O) the numbers of elements in the two lists */
{
IGRint i;

    for(i = indice; i < *len - 1 ; i++)
    {
       list_id[i] = list_id[i+1];
       env_list[i] = env_list[i+1];
    }
    (*len)--; 
    /*^printf("Supress indice %d \nThe new list as now %d elements \n",i,*len);
       for(i=0;i<*len;i++) {
     	printf("list_id[%d]: %d, %d ",i,list_id[i].objid,list_id[i].osnum);
	printf("env_list[%d]: %d, %d\n",i,env_list[i].md_id.objid,
					  env_list[i].md_id.osnum);
       }
    */
  return 1;
}
              
end implementation VDCmdLcNm;

