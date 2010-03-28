/*
 *	 BEEKER   Etienne 
 * 	sept 87
 *	functions managing the ci locate filter with OM macros
 *
 *	04/18/94	Sudha	Purify fix - added scale_flag to LClocate
 */

class implementation ci;
from GRgrset import GSget_object;

#include "dpmacros.h"
#include "grdpbmacros.h"
#include "codef.h"

#include "lcmacros.h"
#include "grgs.h"
#include "grgsmacros.h"

#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

/*----------------------------------------------------------------------------*/
/* -- This is the same as `lc$locate' in lcmacros.h except that the "^" between
	*_prompt and *_key has been removed.
   -- */
#undef lc$locate
#omdef lc$locate (rc,
                  event1, 
                  event2,
		  event3  	  = NULL,
		  nbytes1         = NULL, 
		  nbytes2         = NULL, 
                  mask1           = NULL,
                  mask2           = NULL,
                  value_type1     = NULL,
                  value_type2     = NULL,
                  eventsize       = NULL,
                  display_flag    = 0,
                  hilight_mode    = -1,
                  unhilight_mode  = -1,
                  response        = response, 
		  response_data   = response_data,
                  locate_prompt   = NULL,
                  locate_key      = LC_NO_MSG,
                  acc_prompt      = NULL,
                  acc_key	  = LC_NO_MSG, 
                  relocate_prompt = NULL,
                  relocate_key    = LC_NO_MSG,
                  attributes      = attributes, 
                  stack,
                  dyn             = NULL,
		  act_handler	  = NULL,
		  act_args	  = NULL,
		  select          = NULL,
		  select_args     = NULL,
		  range_handler   = NULL,
		  range_args      = NULL,
		  stack_size      = 1,
                  rtree_classes   = NULL,
                  eligible_classes= NULL,
                  regex		  = 0,
                  type            = 0,
		  scale_flag      = GRIO_X_SCALE)

        LClocate ((rc), (event1), (event2), (event3), (mask1), (mask2),
            (eventsize), (display_flag), (response), (response_data), 
            (locate_prompt), (acc_prompt), (relocate_prompt), (attributes), 
            (stack), (dyn), (type), (act_handler), (act_args) ,
            (rtree_classes), (eligible_classes), (select), (select_args),
            (stack_size), (regex), (locate_key), (acc_key), (relocate_key),
            (hilight_mode), (unhilight_mode),  (nbytes1), (nbytes2),
            (range_handler), (range_args), (value_type1), (value_type2),
	    (scale_flag) )


#endomdef
/*----------------------------------------------------------------------------*/
extern struct instance_ci	*ci_data;
extern char			**ci_data_varvaltable;
extern char			*ci_data_info;
extern OMuword			OPP_GRgrset_class_id ;
/* In global for the Dimensioning Subsystem */
struct GRevent ci_grevent0, ci_grevent1;
/*----------------------------------------------------------------------------*/
#argsused
int CIlocate(mess, lcevdata, runparms, state )

struct ci_instruction	*mess;		/* IN: PPL instruction		 */
CIco_resp		*lcevdata ;	/* IN: Passed by Executive to ci */
CIruntime		*runparms ;
short			*state	  ;
/*
 * Implements the locate function of PPL.
 * See definition of ci$locate macro in ppl/include/cilocate.h.
 */

{
  OM_S_OBJID		*Up_objid ;	/* User pointer to located object id */
  short			*Up_osnum,	/* User pointer to OS number         */
			TMPosnum ;	/* Buffer for above if NULL	     */
  char			*Uloc_prompt,	/* User locate prompt		     */
  			*Uacc_prompt,	/* User accept prompt		     */
  			*Urlc_prompt,	/* User relocate prompt		     */
                        string[50];     /* buffer for ex$message             */
  int			Uloc_prmnum,	/* User locate prompt number	     */
  			Uacc_prmnum,	/* User accept prompt number	     */
  			Urlc_prmnum ;	/* User relocate prompt	number	     */
  struct GRmd_env	*Up_mod_env,	/* User pointer to module environment*/
			TMPmod_env;	/* Buffer for above if NULL	     */
  double		*Up_data_pt,	/* User pointer to data point	     */
			TMPdata_pt[3],	/* Buffet for above if NULL	     */
  			*Up_accp_pt,	/* User accept point		     */
			TMPaccp_pt[3],	/* Buffer for the above if NULL	     */
  			*Usnap_pt;	/* User snap point		     */
  OM_S_OBJID		*Up_wind_id,	/* User pointer to locate window id  */
			TMPwind_id;	/* Buffer for above if NULL	     */
  short			*Up_wind_os,	/* User pointer to locate window os  */
			TMPwind_os;	/* Buffer for above if NULL	     */
  int			Ustckble,	/* User flag for stackable or not    */
  			Uownr_act,	/* User owner action		     */
  			*Up_respnse,	/* User pointer to response	     */
			TMPrespnse;	/* Buffer for above if NULL	     */
  struct GRlc_info	*Up_locinfo,	/* User pointer to locate information*/
			TMPlocinfo;	/* Buffer for above if NULL	     */
  OM_S_CLASSLIST	*Up_eligble,	/* User pointer to eligible classe(s)*/
  			TMPeligble;	/* Buffer for above if NULL	     */
  struct GRevent	ci_grevent3;	/* Event returned by lc$locate	     */

  /* decls for lc$locate */
  IGRlong			status,
				locate_mask,
				input_mask,
  				msg,
  				display_flag;
  IGRint			size,
				*response ;
  IGRchar			*response_data ;
  struct GRlc_locate 		attr;
  static struct GRlc_stack 	stack;
  OMuword			eligible_classid;

  register short		*pm ;	/* Array of parms of PPL's CIlocate  */

/* -- Index of parameters of PPL's CIlocate.
   -- */
  enum CIlocate_args {
	CILOCRC	=  0, LOC_OBJ	=  1, LOC_OSN	=  2, LOCPRMP	=  3,
	ACCPRMP	=  4, RLCPRMP	=  5, CLASSES	=  6, MOD_ENV	=  7,
	DATA_PT	=  8, ACCP_PT	=  9, STCKBLE	= 10, WIND_ID	= 11,
	WIND_OS	= 12, OWNRACT	= 13, PPRTIES	= 14, SNAP_PT	= 15,
	LOCINFO	= 16, RESPNSE	= 17, COUNT	= 18, ELIGBLE	= 19
  } ;

  pm = mess->paramlist ;

/* -- Reads parameters into local variables, provide default values or memory
      buffers for unset ones.
   -- */
  Up_objid  = (OM_S_OBJID *)st_cival( pm[LOC_OBJ] ) ;
  if( ( Up_osnum = (short *)st_cival( pm[LOC_OSN] ) ) == NULL ) Up_osnum = &TMPosnum ;

/* -- Prompts given as strings or message numbers ?
   -- */
	if( isstring( pm[LOCPRMP] ) ) {
		Uloc_prmnum = LC_NO_MSG ;
		Uloc_prompt = st_cival( pm[LOCPRMP] ) ;
		if( Uloc_prompt == NULL ) {
			goto DEFAULT ;
		}
	} else {
		Uloc_prmnum = i_cival( pm[LOCPRMP] ) ;
		Uloc_prompt = NULL ;
		if( Uloc_prmnum == 0 ) {
			Uloc_prmnum = LC_NO_MSG ;
			DEFAULT :
			if( runparms->msgsys.clear_prompt ) {
                                ex$message(msgnumb = GR_P_IdEle,
                                           buff = string);
                                Uloc_prompt = string;
/*				Uloc_prompt = "Identify element"; */
			} else {
				Uloc_prompt = runparms->msgsys.Prompt ;
			}
		} 
	}
	if( isstring( pm[ACCPRMP] ) ) {
		Uacc_prmnum = LC_NO_MSG ;
		Uacc_prompt = st_cival( pm[ACCPRMP] ) ;
	} else {
		Uacc_prmnum = i_cival( pm[ACCPRMP] ) ;
		Uacc_prompt = NULL ;
	}
	if( isstring( pm[RLCPRMP] ) ) {
		Urlc_prmnum = LC_NO_MSG ;
		Urlc_prompt = st_cival( pm[RLCPRMP] ) ;
	} else {
		Urlc_prmnum = i_cival( pm[RLCPRMP] ) ;
		Urlc_prompt = NULL ;
	}

/* DG August 11 */
#ifdef DEBUG
  printf( "CIlocate: ELIGBLE %u CLASSES %s\n", st_cival( pm[ELIGBLE] ),
	  st_cival( pm[CLASSES] ) ) ;
#endif
	/* A class name was specified: turn it into OM stuff. */
	if( ( Up_eligble = (OM_S_CLASSLIST *)st_cival( pm[ELIGBLE] ) ) == NULL ) {
		Up_eligble = &TMPeligble ;

		TMPeligble.w_count = 1 ;
		TMPeligble.w_flags = OM_CLST_subclass ;
		status = om$get_classid( classname = st_cival( pm[CLASSES] ),
				         p_classid = &eligible_classid ) ;
		if( !( status & SUCC ) ) {
			ci$om_failed( text = "CIlocate -> om$get_classid",
				      sts  = status ) ;
		}
		TMPeligble.p_classes = &eligible_classid ;
	}

  if( !( Up_mod_env = (struct GRmd_env *)st_cival( pm[MOD_ENV] ) ) )
	Up_mod_env = &TMPmod_env ;
  if( !( Up_data_pt = (double *)st_cival( pm[DATA_PT] ) ) )
	Up_data_pt =  TMPdata_pt ;
  if( !( Up_accp_pt = (double *)st_cival( pm[ACCP_PT] ) ) )
	Up_accp_pt =  TMPaccp_pt ;
  if( !( Up_wind_id = (OM_S_OBJID *)st_cival( pm[WIND_ID] ) ) )
	Up_wind_id = &TMPwind_id ;
  if( !( Up_wind_os = (short *)st_cival( pm[WIND_OS] ) ) )
	Up_wind_os = &TMPwind_os ;
  if( !( Up_locinfo = (struct GRlc_info *)st_cival( pm[LOCINFO] ) ) )
	Up_locinfo = &TMPlocinfo ;
  if( !( Up_respnse = (int *)st_cival( pm[RESPNSE] ) ) )
	Up_respnse = &TMPrespnse ;
  
  Uownr_act	= ci_give_intvalue( pm[OWNRACT] );
  Usnap_pt	= (double *)st_cival( pm[SNAP_PT] );
  Ustckble	= i_cival(  pm[STCKBLE] );

	/*
	 *  Call locate filter to locate an object 
	 */
	input_mask  =     GRm_DATA
			| GRm_RESET
			| GRm_BACK_UP
			| GRm_STRING
			| GRm_SPECIFIED_OBJ
			| GRm_FORM_FINISHED ;

	locate_mask =	  GRm_DATA
			| GRm_RESET
			| GRm_BACK_UP
			| GRm_STRING 
			| GRm_SPECIFIED_OBJ
			| GRm_FORM_FINISHED ;

	display_flag = ELEM_HILIGHT | ALL_WINDOWS ;

	if( Usnap_pt == NULL ) {
		/* If project point is not requested */
		display_flag |= NO_PROJ_ACCEPT_POINT ;		
	}
	size = sizeof( struct GRevent ) ;
	attr.properties = i_cival( pm[PPRTIES] ) ;
	if( ( attr.owner_action = Uownr_act ) == 0 )
	        attr.owner_action =	  LC_RIGID_OWNER
					| LC_FLEX_COMP 
					| LC_FLEX_OWNER
					| LC_REF_OBJECTS;

	response	= lcevdata->response		;
	response_data	= lcevdata->response_data	;
	do {
		msg = MSSUCC ;
/*  If the queue is empty that means no objects are located. Exit the
    CIlocate process only if relocate_prompt is set to CI_NULL.
    TR 91N3403. -- msm.
*/
                if ((Urlc_prompt == NULL) && (queue_empty)) {
                  int		*p_count = (int *)st_cival( pm[COUNT] ) ;
                  if (p_count != NULL )
                      *p_count = 0;
                   return ISUCCESS ;
                }
		status = lc$locate (
			rc 		= &msg,
			event1 		= &ci_grevent0,
			event2 		= &ci_grevent1,
			event3		= &ci_grevent3,
			mask1		= locate_mask,
			mask2		= input_mask,
			eventsize	= &size,
			display_flag    = display_flag,
			locate_prompt   = Uloc_prompt,
			acc_prompt	= Uacc_prompt,
			relocate_prompt = Urlc_prompt, 
			locate_key	= Uloc_prmnum,
			acc_key		= Uacc_prmnum,
			relocate_key	= Urlc_prmnum, 
			attributes	= &attr,
			stack		= &stack,
			eligible_classes= Up_eligble ) ;
		*Up_respnse = *response;

		/* Awaited action */
		if( *response == DATA || *response == SPECIFIED_OBJ )
			break;

		/* TERMINATE & CLEAR STACK cannot be trapped */ 
/* DG June 30 */
		if(	*response == CLEAR_STACK
		    ||	*response == TERMINATE ) {
			stack.num_entries = 0 ;
			return ISTACK ;
		}

		if( !ci_can_be_stacked(ci_data, ci_data_info) ){
			erreur("locate: cannot interrupt or stack this file");
			break;
		}

		/* DO THIS TEST BEFORE THE ONE OF msg and status !!!! */
		/* Volontary exit */
		if( Ustckble && 
			(  *response == RESET 
			|| *response == STRING
			|| *response == D_RESET ))
				return ISUCCESS ;
              /* exit on RESET even if Ustckble is 0. TR#92N0729. -- msm */
                if( !(Ustckble) &&
                        (  *response == RESET))
                                return ISUCCESS ;

		if(	ci_grevent1.response == GR_UNKNOWN_TYPE
		    ||	*response == D_COMMAND
		    ||	*response == HELP
		    ||	*response == TOGGLE_COMMAND
		    ||	*response == EX_CMD_KEY /* DG July 4th */
		    ||	*response == EX_POCKET
		    ||  *response == CMD_STRING ) {
			if( Ustckble ) return ISTACK ;   /* Command stacked */
		}
	} while( TRUE ) ;

	stack.num_entries = 0;

	if( !( 1 & status ) ) {
		/* Locate filter error */
		fprintf( stderr, "CIlocate error: lc$locate msg %d(0x%x)\n",
				msg, msg );
		return ISUCCESS ;
	}

	/* DG 03 July 88: consider the case when a fence is located */
	{ 
	OM_S_OBJID	oid = ci_grevent3.located_object[0].located_obj.objid;
	OMuword		osn = ci_grevent3.located_object[0].located_obj.osnum,
			ocl;
	int		*p_count = (int *)st_cival( pm[COUNT] ) ;

	om$get_classid(	osnum = osn, objid = oid, p_classid = &ocl ) ;

	if( om$is_ancestry_valid( subclassid = ocl,
				  superclassid = OPP_GRgrset_class_id )
			== OM_S_SUCCESS
		&& p_count != NULL ) {
			struct GRobj_env	*comp_env ;
			int			i, size, cnt = *p_count;
			struct GRid		set_grid ;

			size = cnt * sizeof( struct GRobj_env )  ;
		/* What if malloc fails ? */
			comp_env = (struct GRobj_env *) malloc( size ) ;
			cnt = 0;  /* JLA 02-APRIL-89 */

			set_grid.objid = oid;
			set_grid.osnum = osn;
			status = gr$gsget_objects(
					msg		= &msg,
					array		= comp_env,
					size		= size,
					count		= &cnt,
					from_obj	= 0,
					to_obj		= OM_K_MAXINT,
					senderid	= NULL_OBJID,
					object_id	= &set_grid ) ;

			if( !( status & 1 ) ) {
				ci$om_failed(	sts	= OM_W_ABORT,
						text	= "CIlocate -> GRgrset.GSget_object" ) ;
				free( comp_env );
				return ISUCCESS ;
			}
			if( *p_count > cnt ) *p_count = cnt ;

			for( i = 0 ; i < *p_count ; i++ ) {
				Up_objid[i] = comp_env[i].obj_id.objid ;
				Up_osnum[i] = comp_env[i].obj_id.osnum ;
			}
			free( comp_env );
		} else {
			*Up_objid = oid ;
			*Up_osnum = osn ;
			if( p_count != NULL ) *p_count = 1 ;
		}
	} /* End fence */

	dp$erase_hilite( msg = &status ) ;

	*Up_locinfo = ci_grevent3.located_object[0];
        *Up_mod_env = ci_grevent3.located_object[0].module_info;

	*Up_wind_id = ci_grevent1.event.button.objid;
	*Up_wind_os = ci_grevent1.event.button.osnum;

	Up_data_pt[0] = ci_grevent0.event.button.x;
	Up_data_pt[1] = ci_grevent0.event.button.y;
	Up_data_pt[2] = ci_grevent0.event.button.z;

	Up_accp_pt[0] = ci_grevent1.event.button.x;
	Up_accp_pt[1] = ci_grevent1.event.button.y;
	Up_accp_pt[2] = ci_grevent1.event.button.z;

	if( Usnap_pt != NULL ) {
		Usnap_pt[0] = ci_grevent3.located_object[0].proj_pnt[0];
		Usnap_pt[1] = ci_grevent3.located_object[0].proj_pnt[1];
		Usnap_pt[2] = ci_grevent3.located_object[0].proj_pnt[2];
	}

	runparms->msgsys.clear_prompt = TRUE ;

	if( !( runparms->options & CI_NOMSG_MODE ) ) {
		COND_message( runparms->msgsys.Message ) ;
	}
        ex$message(     field	= PROMPT_FIELD,
			in_buff = "" ) ;

	i_cival( pm[CILOCRC] ) = 1 ;
	return ISUCCESS ;

} /* CIlocate */
/*----------------------------------------------------------------------------*/
CIget_module_info(func)
struct ci_instruction *func;
/*
 * Retrieves the module environment.
 */
{
	struct GRmd_env *md_info;
	struct GRid     modGrid;
	OM_S_OBJID	*mod_id;
	short		*mod_os;
	IGRlong		NumberOfBytes, BytesReceived;
	IGRlong		status;
	IGRlong		msg;

	if( (md_info = (struct GRmd_env *)st_cival(func->paramlist[1])) != NULL ){
		NumberOfBytes = sizeof( struct GRmd_env );
		status = gr$get_module_env(
			msg	= &msg,
			sizbuf	= &NumberOfBytes, 
			buffer	= md_info,
			nret	= &BytesReceived );

		if (!status || COERROR(msg)){
			erreur("gr$get_module_env error");

		i_cival(func->paramlist[0]) = FALSE ;
		return ISUCCESS ;
		}
	}

	GRfindmod( &modGrid );
	if( (mod_id = (OM_S_OBJID *)st_cival(func->paramlist[2])) != NULL )
		*mod_id = modGrid.objid;

	if( (mod_os = (short *)st_cival(func->paramlist[3])) != NULL )
		*mod_os = modGrid.osnum;

	i_cival(func->paramlist[0]) = 1;
	return ISUCCESS ;
}

end implementation  ci;

