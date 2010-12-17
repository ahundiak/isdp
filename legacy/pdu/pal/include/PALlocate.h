#ifndef lc_u_include

#define lc_u_include

#include "OMprimitives.h"
#include "OMerrordef.h"
#include "growner.h"

#define  PROMPT_LEN	50

GRspacenum	LCosnum;
GRobjid		LCobjid;

extern LCmark_node();
extern strncpy(), memcpy();

#omdef pal$locate( msg, 
					locate_prompt ^
                        		locate_str, 
					acc_prompt ^
                        		acc_str, 
					relocate_prompt ^
                        		relocate_str, 
					flag = 0, 
					dynamics = 0, 
					no_of_gr_classes = 0, 
					gr_classes = NULL, 
					response, 
					md_env = NULL, 
					objid, 
					osnum, 
					no_of_ignore_classes = 0, 
					ignore_classes = NULL,
					locate_ref = TRUE,
					obj_md_env = NULL,
					locate_fence = FALSE,
					cycle_flag = FALSE
					
				 )

locate_an_element( &( msg ), 

#if om$specified( locate_prompt )
						( locate_prompt ), 
						NULL, 
#else
						0, 
						( locate_str ), 
#endif
#if om$specified( acc_prompt )
						( acc_prompt ), 
						NULL, 
#else
						0, 
						( acc_str ), 
#endif
#if om$specified( relocate_prompt )
						( relocate_prompt ), 
						NULL, 
#else
						0, 
						( relocate_str ), 
#endif

						( flag ), 
						( dynamics ), 
						( no_of_gr_classes ), 
						( gr_classes ), 
						&( response ), 
						( md_env ), 
						&( objid ), 
						&( osnum ), 
						( no_of_ignore_classes ), 
						( ignore_classes ),
						( locate_ref ),
						( obj_md_env ),
						( locate_fence ),
						( cycle_flag ));
#endomdef


int LOCATE_ABORT;	/* This flag should be set if LOCATE is to be aborted */

/* the following variables are used for fence operations. This function 
   locally stores the fence objects and later send one by one to the 
   caller.
*/

struct GRobj_env *LCfence_objects;
int LCfence_objects_count;
int LCcurrent_fence_object_index;
extern	OMuword OPP_GRgrset_class_id;

locate_an_element( msg, locate_prompt, locate_str, 
			acc_prompt, acc_str, relocate_prompt, relocate_str, flag, 
			dynamics, no_of_gr_classes, gr_classes, response, 
			md_env, objid, osnum, no_of_ignore_classes, 
			ignore_classes, locate_ref, obj_md_env, locate_fence,
                        cycle_flag )
int			*msg, locate_prompt, acc_prompt, relocate_prompt;
int			flag, no_of_gr_classes, *response, no_of_ignore_classes, dynamics;
int			locate_ref, locate_fence, cycle_flag;
char		*locate_str, *relocate_str, *acc_str;
GRspacenum 	*gr_classes, *ignore_classes;
GRspacenum	*osnum;
GRobjid		*objid;
struct		GRmd_env *md_env, *obj_md_env;
{
	char		LC_locate_prompt[PROMPT_LEN+1], LC_acc_prompt[PROMPT_LEN+1];
	char		LC_relocate_prompt[PROMPT_LEN+1], msgbuf[100], *LC_data;
	OMuword		classid;
	int		LC_tmp, LC_tmp1, LC_no_of_obj, LC_flag, LC_rc, LC_indx;
	double		*LC_pt;
	struct		GRevent LC_event;
	struct		GRid LC_grid[20], tmp_id;
	struct		GRobj_info LC_info;
	struct		GRmd_env LC_md_env, LC_obj_md_env[20];
        char            *msg_str;


/* If module environment is not filled up fill it with locate module environment*/

	if ( md_env == NULL )
	{
		ci$get_module_info( md_env = &LC_md_env );
		md_env = &LC_md_env;
	}

	if ( ! fetch_fence_object( objid, osnum, response, obj_md_env ) )
		return;
		
	LOCATE_ABORT = 0;

	if ( locate_str )
		strncpy( LC_locate_prompt, locate_str, PROMPT_LEN );
	else
	{
		ex$message( msgnumb = locate_prompt, buff = LC_locate_prompt );
	}

	if ( acc_str )
		strncpy( LC_acc_prompt, acc_str, PROMPT_LEN );
	else
	{
		ex$message( msgnumb = acc_prompt, buff = LC_acc_prompt );
	}

	if ( relocate_str )
		strncpy( LC_relocate_prompt, relocate_str, PROMPT_LEN );
	else
	{
		ex$message( msgnumb = relocate_prompt, buff = LC_relocate_prompt );
	}

	while ( 1 )
	{
		LC_no_of_obj = 0;
		*msg = 0;

		ci$getevent( event = &LC_event, 
					response = response, 
					stackable = TRUE, 
					data = LC_data, 
					prompt = LC_locate_prompt );

		if ( LOCATE_ABORT )
		{
			LOCATE_ABORT = 0;
			return;
		}

		if ( *response == SPECIFIED_OBJ )
		{

			if ( ! locate_fence )
			{
				*msg = 1;
				*objid = LC_event.located_object[0].located_obj.objid;
				*osnum = LC_event.located_object[0].located_obj.osnum;
				return;
			}
/* Look for fence object */

			om$get_classid( objid=LC_event.located_object[0].located_obj.objid, 
					osnum=LC_event.located_object[0].located_obj.osnum, 
					p_classid = &classid );

			if ( om$is_ancestry_valid( subclassid = classid, 
						superclassid = OPP_GRgrset_class_id )
						== OM_I_INVANCESTRY )
			{
				*msg = 1;
				*objid = LC_event.located_object[0].located_obj.objid;
				*osnum = LC_event.located_object[0].located_obj.osnum;
				return;
			}

/* Fence object located */

			LCcurrent_fence_object_index = 0; // Lets initialize 
 					// LCcurrent_fence_object_index, only
                	                // at the beginning of the code to process
					// Fence object, to avoid initializeing
					// it in many places. That would be
					// redundant. It can be assumed when we
					// get a fence object, the objects located
					// in the earlier fence are all returned.

			ci$send( msg = message GRgrset.GSinqcount( &LC_rc, 
							&LCfence_objects_count ),
				targetid = LC_event.located_object[0].located_obj.objid,
				targetos = LC_event.located_object[0].located_obj.osnum );

/* Here we are assuming that the pointer is not pointing to any 'to be freed'
   memory chunk. If it does, if we dont free it, unnecessarily the chunk is
   going to wasted. But since when we return the last object in the earlier
   fence, we free the memory, our assumption would be valid.
*/

			LCfence_objects = ( struct GRobj_env * )
						malloc( LCfence_objects_count * 
							sizeof( struct GRobj_env ) );
			if ( LCfence_objects == NULL )
			{
				write( "Locate.h : Error in mallocing\n" );
				return;
			}

			LC_tmp = LCfence_objects_count;
			LCfence_objects_count = 0; /* This is mandatory as this is how
						the method GSget_object is implemented */

			ci$send( msg = message GRgrset.GSget_object( &LC_rc, 
					LCfence_objects, LC_tmp*sizeof( struct GRobj_env ),
					&LCfence_objects_count, 0, LC_tmp-1 ),
				targetid = LC_event.located_object[0].located_obj.objid,
				targetos = LC_event.located_object[0].located_obj.osnum );


			for ( LC_tmp = 0 ; LC_tmp < LCfence_objects_count ; 
								LC_tmp = LC_tmp+1 )
			{
				LCfence_objects[LC_tmp].obj_id.objid = tmp_id.objid;
				LCfence_objects[LC_tmp].obj_id.osnum = tmp_id.osnum;
			}

/* Now if our useful elements count is zero, we would free the memory chunk. */

			if ( ! LCfence_objects_count )
			{
				free( LCfence_objects );
				LCfence_objects = NULL;
				continue;
			}
/* Now highlight all the objects and prompt the user to accept */

			for ( LC_tmp = 0 ; LC_tmp < LCfence_objects_count ; 
							LC_tmp = LC_tmp + 1 )
			{
				locate_hilite_dehilite( LCfence_objects[LC_tmp].obj_id.objid,
							LCfence_objects[LC_tmp].obj_id.osnum,
							GRhd, md_env );
			}

			get_accept_reject( cycle_flag, &LC_event, response, LC_data, 
						LC_acc_prompt );

			for ( LC_tmp = 0 ; LC_tmp < LCfence_objects_count ; 
							LC_tmp = LC_tmp + 1 )
			{
				locate_hilite_dehilite( LCfence_objects[LC_tmp].obj_id.objid,
							LCfence_objects[LC_tmp].obj_id.osnum,
							GRhe, md_env );
			}
			if ( LOCATE_ABORT )
			{
				LOCATE_ABORT = 0;
				return;
			}

			if ( *response == DATA )
			{
				fetch_fence_object( objid, osnum, response, obj_md_env );
				*msg = 1;
				return;
			}
			else
			{
				if ( LCfence_objects )
					free( LCfence_objects );
				LCfence_objects_count = 0;
				continue;
			}
		}

		if ( *response == D_RESET ) 
			return(-1);

		if ( *response == RESET ) 
			return(0);

		LC_flag = 0;

		if ( *response == STRING )
		{
			if ( ! LC_data[0] )
				continue;
			else
				LC_flag = 1;
		}

		else if ( *response == DATA )
		{
			LC_pt = ( double * )LC_data;

			ci$put( point = LC_pt, 
				window_id = LC_event.event.button.objid,
				osnum = &LC_event.event.button.osnum );

			LC_flag = 2;
		}

		if ( LC_flag == 1 )
		{
			PALlocate_by_keyin( &LC_rc, LC_data, LC_grid );

			/* if the tagged in element is not found then dispaly error message */
			if ( LC_rc )
				LC_no_of_obj = 1;
			else
			{
/*				ex$message( msgnumb = PDM_E_ElNotFnd, buff = msgbuf );*/
                                msg_str = (char *)PDUtranslate_message(PDM_E_ELEMENT_NOT_FOUND);
				status( msg_str );
			}
				
		}

		else if ( LC_flag == 2 )
		{
			PALlocate_by_datapt( &LC_rc, 
					&LC_no_of_obj, 
					LC_grid, 
					LC_obj_md_env,
					no_of_gr_classes, 
					gr_classes,
					locate_ref);

//	write( LC_no_of_obj, "\n" );
//	write( "LC_objid:",LC_grid[0].objid,"\n" );
//	write( "LC_osnum:",LC_grid[0].osnum,"\n" );

			if( !LC_rc )
			{
/*				ex$message( msgnumb = PDM_E_ElNotFnd, buff = msgbuf );*/
                                msg_str = (char *)PDUtranslate_message(PDM_E_ELEMENT_NOT_FOUND);
				status( msg_str );
			}

/* This is to make sure that the locate criteria set by the lc$macro is not
   used by the subsequent lc$macros.
*/
			LCmark_node( LC_NO_CRITERIA );
		}

		for ( LC_indx = 0 ; LC_indx < LC_no_of_obj ; LC_indx = LC_indx + 1 )
		{
			om$get_classid( objid = LC_grid[LC_indx].objid, 
					osnum = LC_grid[LC_indx].osnum, 
					p_classid = &classid );

			for( LC_tmp = 0 ; LC_tmp < no_of_ignore_classes; LC_tmp = LC_tmp+1 )
				if ( om$is_ancestry_valid( subclassid = classid, 
						superclassid = ignore_classes[LC_tmp] )
						! = OM_I_INVANCESTRY )
					break;

			if ( LC_tmp ! = no_of_ignore_classes )
				continue;

			LCosnum = LC_grid[LC_indx].osnum;
			LCobjid = LC_grid[LC_indx].objid;

			locate_hilite_dehilite( LC_grid[LC_indx].objid,
						LC_grid[LC_indx].osnum,
						GRhd, md_env );
										
			ci$send( msg = message GRgraphics.GRgetobjinfo( msg, 
						&LC_info ), 
			 			targetid = LC_grid[LC_indx].objid, 
			 			targetos = LC_grid[LC_indx].osnum );

			status( LC_info.type );

			get_accept_reject( cycle_flag, &LC_event, response, LC_data, 
						LC_acc_prompt );

			if ( LOCATE_ABORT )
			{
				LOCATE_ABORT = 0;
				return;
			}

			locate_hilite_dehilite( LC_grid[LC_indx].objid,
						LC_grid[LC_indx].osnum,
						GRhe, md_env );

			if ( *response == DATA )
			{
				*msg = 1;
				*objid = LC_grid[LC_indx].objid;
				*osnum = LC_grid[LC_indx].osnum;
				if ( obj_md_env )
					memcpy( obj_md_env, &LC_obj_md_env[LC_indx], 
							sizeof( struct GRmd_env ) );
				LC_pt = ( double * )LC_data;

			/* IF statement added to ensure that ci$put is used only once */
				if ( !cycle_flag && flag )
					ci$put( point = LC_pt );
				return;
			}

			if ( *response == D_RESET )
				break;

			if ( ( *response == STRING ) && ( flag || cycle_flag ) )
			{
				*msg = 1;
				*objid = LC_grid[LC_indx].objid;
				*osnum = LC_grid[LC_indx].osnum;

				*response = DATA;
				ci$put( string = LC_data );
				return;
			}

			if ( *response ! = RESET )
				continue;
		}

		if ( *response == D_RESET )
			continue;

/*		ex$message( msgnumb = PDM_E_MemElNotF, buff = msgbuf );*/
		sprintf(msgbuf, "Element Not Found");
	}
}

fetch_fence_object( objid, osnum, response, obj_md_env )
GRobjid *objid;
GRspacenum *osnum;
int *response;
struct GRmd_env *obj_md_env;
{
	if ( ! LCfence_objects_count )		/* No fence objects to be returned. */
		return(1);
	*objid = LCfence_objects[LCcurrent_fence_object_index].obj_id.objid;
	*osnum = LCfence_objects[LCcurrent_fence_object_index].obj_id.osnum;
	if ( obj_md_env )
		memcpy( obj_md_env, 
			&LCfence_objects[LCcurrent_fence_object_index].mod_env, 
					sizeof( struct GRmd_env ) );

	*response = SPECIFIED_OBJ;
	LCcurrent_fence_object_index = LCcurrent_fence_object_index + 1;
	if ( LCcurrent_fence_object_index == LCfence_objects_count )
	{
		free( LCfence_objects );
		LCfence_objects = NULL;
		LCfence_objects_count = 0;
	}
	return( 0 );
}

get_accept_reject( cycle_flag, LC_event, response, LC_data, LC_acc_prompt )
int cycle_flag;
struct GRevent *LC_event;
int *response;
char *LC_data, *LC_acc_prompt;
{
	ci$getevent( event = LC_event, 
		stackable = TRUE, 
		response = response, 
		data = LC_data, 
		prompt = LC_acc_prompt );

	if ( cycle_flag && *response == DATA)  
						
	{
		ci$put( point = ( double * )LC_data, 
			window_id = LC_event->event.button.objid, 
			osnum = &LC_event->event.button.osnum );
	}
}

locate_hilite_dehilite( objid, osnum, display_mode, md_env )
GRobjid objid;
GRspacenum osnum;
int display_mode;
struct GRmd_env *md_env;
{
	int loc_display_mode, msg;

	loc_display_mode = display_mode;

	ci$send( msg = message GRgraphics.GRdisplay( 
						&msg, 
						&( md_env->md_env.matrix_type), 
						md_env->md_env.matrix, 
						&loc_display_mode, 
						&md_env->md_id ), 
				targetid = objid,
	 			targetos = osnum );
}

init_locate()
{
	LCobjid = NULL;
	LCosnum = NULL;
	LCfence_objects = NULL;
	LCfence_objects_count = 0;
}

wakeup_locate()
{
	int	display_mode;

}

sleep_locate()
{
	int	msg, display_mode;

	LCobjid = NULL;
	LCosnum = NULL;
}

delete_locate()
{
	if ( LCfence_objects )
		free( LCfence_objects );
	LCfence_objects = NULL;
	LCfence_objects_count = 0;
	LCcurrent_fence_object_index = 0;
}

update_fence_objects_list( from_index )
int from_index;
{
	int i;

	for( i = from_index; i < (LCfence_objects_count - 1); i = i + 1 )
	{
		memcpy( LCfence_objects+ i, 
			LCfence_objects+i +1, 
			sizeof( struct GRobj_env ) );
	}

	LCfence_objects_count = LCfence_objects_count - 1;
}
#endif
