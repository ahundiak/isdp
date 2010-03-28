/*
 * contains the methods used by the command interpreter
 * to be reentrant, i.e share the same code 
 *
 * Etienne BEEKER
 * creation:23 Nov 87
 * 
 */
class implementation ci;

#include <malloc.h>
#include <memory.h>
#include "cierrordef.h"

extern char *errmess;
extern struct instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;

/*----------------------------------------------------------------------------*/
int ci_clonage( msg, ci_orig,  ci_clone, sender_id, sender_os )

int		*msg ;		/* OUT: Completion code			*/
OM_S_OBJID	ci_orig;	/* IN : Id of CI object be copied	*/
OM_S_OBJID	*ci_clone;	/* OUT: Id of resulting clone		*/
OM_S_OBJID	sender_id;	/* IN : Id of caller			*/
OMuword		sender_os ;	/* IN : OS of caller			*/
/*
 * constructs a clone of a ci object
 * they will share the same code but have separate data segments.
 */
{
	int rc;

	/* verify that the ci_orig is subclass ci */
	if( !ci$e_x_e_c(	file_name	= NULL,
				file_id		= &ci_orig,
				entry		= "",
				load_flag	= 0,
				verif_flag	= 1,
				init_flag	= 0,
				run_flag	= 0,
				delete_flag	= 0,
				sender_id	= sender_id,
				sender_os	= sender_os,
				stat		= msg,
				retval		= NULL,
				retsize		= 0 ) ) {
				
		erreur("ci_clonage: ci_orig must be subclass of ci or does not exist");
		goto WRAPUP ;
	}

	rc= om$construct_and_copy( objid	= ci_orig	,
				   obj_osnum	= OM_Gw_TransOSnum_0,
				   osnum	= OM_Gw_TransOSnum_0,
                         	   p_objid	= ci_clone 	);
	if( rc != OM_S_SUCCESS ) {
		ci$om_failed(	sts = rc,
				text= "ci_clonage -> om$construct_and_copy" ) ;
		*msg = CI_E_CLON_FAILED ;
		goto WRAPUP ;
	}

	/* allocates the data fields of the instance data */
	rc = om$send(	mode	 = OM_e_wrt_object,
			msg	 = message ci.load_s( msg ),
			senderid = sender_id,
			targetid = *ci_clone,
			targetos = OM_Gw_TransOSnum_0 );

	if( rc != OM_S_SUCCESS ) {
		ci$om_failed(	sts = rc,
				text= "ci_clonage -> ci.load_s" ) ;
		*msg = CI_E_CLON_FAILED ;

/* --		Must delete clone then ... ?
   -- */
		om$send( msg	  = message Root.delete( 0 ),
			 senderid = sender_id,
			 targetid = *ci_clone,
			 targetos = OM_Gw_TransOSnum_0 ) ;
	}  else {
                rc = 1 ;
                ci$f_execute(   file    = *ci_clone,
                                entry   = "init",
                                action  = &rc,
                                senderid= sender_id ) ;
        }

	WRAPUP :
	return *msg == CI_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method load_s( int *msg )
/*----------------------------------------------------------------------------*/
/*
 * Special load, which allocates only the specific data 
 * Performs some updates on pointers
 */
{
	int nbv;	/* nb of variables */
	int sz_data;	/* size of the data */
	int delta;
	int rc;
	ci_IGE 		*brother_info;
	char 		**brother_varval,
			**my_varval ;
	struct instance_ci *tmp_data;

	*msg = CI_S_SUCCESS ;

	/* duplicate pointers */
	brother_varval = ME.ci->my_varvaltable;
	brother_info = (ci_IGE *)ME.ci->my_info;

	/* nb of variables */
	nbv = ME.ci->data->nbvar;

	/* nbvar contains last interesting address */
	/* calculates the size of the data */
	sz_data = (int)( brother_varval[nbv] - brother_varval[0] );

	/* do the memory allocation */
	/* and copy the var values ( i.e. for constants ) */
	ME.ci->my_varvaltable
			= my_varval
			= (char **)malloc( sizeof(char *) *  (nbv+1) );

	if( my_varval == NULL ) {
		*msg = CI_E_CANT_MALLOC ;
		goto WRAPUP ;
	}
	memcpy( my_varval, 
		brother_varval,
		sizeof(char *) *  (nbv+1));

	my_varval[0] = malloc( sizeof(char) *  sz_data );
	if( my_varval[0] == NULL ) {
		free( my_varval ) ;
		*msg = CI_E_CANT_MALLOC ;
		goto WRAPUP ;
	}
	
	memcpy( my_varval[0], 
		brother_varval[0],
		sizeof(char) * sz_data);

	/* restores the values of other pointers */
	delta = (int)( my_varval[0] -  brother_varval[0]);

	my_varval[nbv] = brother_varval[nbv] + delta;
	tmp_data = ME.ci->data;		/* speed up clonage */
	while( nbv-- > 0 ){
	    if(  tmp_data->vartable[nbv][0] != '@' &&
	      !( tmp_data->varflagtable[nbv] & CI_XTRN ) ){
			my_varval[nbv] = brother_varval[nbv] + delta;
	    }
	}

	rc = alloc_ci_IGE( &ME.ci->my_info ) ;
	if( !rc ) {
		*msg = CI_E_CANT_MALLOC ;
		goto WRAPUP ;
	}
	
	((ci_IGE *)ME.ci->my_info)->sender_id = brother_info->sender_id;
/*
	((ci_IGE *)ME.ci->my_info)->interrupt = brother_info->interrupt;
 */

	
	/* updates the counter of clones */
	ME.ci->data->nb_clone++;
	
	/* unstacked the file if the brother was stacked */
	ci_unstack( me^^super_cmd.state ) ;
/* OLD 	ci_unstack( ME.ci->data );  end OLD */

	WRAPUP :
	return OM_S_SUCCESS ;
}

end implementation ci;

