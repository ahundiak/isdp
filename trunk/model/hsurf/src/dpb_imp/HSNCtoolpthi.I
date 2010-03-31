
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation HSNCtoolpth;

/*
DESCRIPTION
	Implementation file for the toolpath object

HISTORY
	Creation Date
*/

#define CHECK_RETURN_CODES	1

#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "ODE.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"

#include "exdef.h"
#include "exmacros.h"

#include "hsurferrpriv.h"

#include "hslight.h"
#include "hsurf.h"

%safe
#include "HSpr_dpb_imp.h"
%endsafe

static	IGRint 		curr_disp_list_size;	/* 512 * vla */

/*--- my_construct -------------------------------------------------*/
method my_construct()
/*
DESCRIPTION
	Construct toolpath object.
HISTORY
	07/00/88	KMJ	Creation
*/

{
	IGRlong        	sts;
	OM_S_CHANSELECT	tp_chan, tpmgr_chan;
	OM_S_OBJID     mod_id;
	OMuword        super_osnum, mod_osnum;
	OM_S_OBJID     tpmgr_id;

	me->num_quadwords = 0;
	curr_disp_list_size = HSNC_DISP_LIST_SIZE;

	/* get HSNCtoolpmg id		*/
	sts = ex$get_cur_mod( osnum = &mod_osnum, id = &mod_id );
	OM_ERRCHK( sts, "HSNCtoolpthi.I: ex$get_cur_mod failed.");
/***
	_debug(	fprintf(stderr, "my_construct: mod_osnum=%d, mod_id=%d\n", mod_osnum, mod_id);)
***/

	sts = ex$get_super( mod_id      = mod_id,
	                    mod_osnum   = mod_osnum,
	                    super_name  = "HSNCtoolpmg",
	                    create      = 1,
	                    super_class = "HSNCtoolpmg",
	                    super_id    = &tpmgr_id,
	                    super_osnum = &super_osnum );
	OM_ERRCHK( sts, "HSNCtoolpthi.I: ex$get_super failed.");
/*	_debug(fprintf(stderr, "HSNCtoolpthi.I my_construct: tpmgr_id=%d, super_osnum=%d; my_id=%d\n", tpmgr_id, super_osnum, my_id);)*/
	sts = om$make_chanselect( channame	= "HSNCtoolpth.tpmgr",
				   p_chanselect	= &tp_chan);
	OM_ERRCHK( sts, "HSNCtoolpthi.I: om$make_chanselect failed.");
	
	sts = om$make_chanselect( channame	= "HSNCtoolpmg.tp",
				  p_chanselect	= &tpmgr_chan);
	OM_ERRCHK( sts, "HSNCtoolpthi.I: om$make_chanselect failed.");
	

	sts = om$send (	msg = message Root.connect(tpmgr_chan, 0, my_id, OM_Gw_current_OS, 
					tp_chan, 0), 
			targetid = tpmgr_id);	
	OM_ERRCHK( sts, "HSNCtoolpthi.I: om$send Root.connect failed.");
        me->num_bg_objenvs = 0;
        me->num_part_objenvs = 0;
        
	return sts;
}  

/*--- add_to_disp_list -------------------------------------------------*/

method add_to_disp_list(IGRdouble *command; IGRint *num_quadwds)
/*
DESCRIPTION
	adds another display list "command" to the end of the current display list
HISTORY
	07/00/88	KMJ	Creation
*/

{
	IGRint		i;
	IGRlong 	sts = OM_S_SUCCESS;
        IGRint          t_num_quadwds;

	t_num_quadwds = me->num_quadwords + *num_quadwds;
	while (t_num_quadwds > curr_disp_list_size)			
	{								
		curr_disp_list_size += HSNC_DISP_LIST_SIZE;
/*
		_debug(fprintf(stderr, "vla recalloc, curr_disp_list=%d\n", 
                               curr_disp_list_size);)
*/
		sts = om$vla_set_dimension (varray = me->disp_list,
					    size   = curr_disp_list_size );
		OM_ERRCHK(sts, "HSNCtoolpthi.I: om$vla_set_dimension failed.");
	}								

	for ( i=0; i<*num_quadwds; i++ )
	{
		*(me->disp_list + me->num_quadwords + i) = *(command + i);
	}
	me->num_quadwords += *num_quadwds;

/*
	_debug( fprintf(stderr,
	"before leave add_to_disp_list: me->num_quadwords=%d, input num_quadwds=%d\n",me->num_quadwords, *num_quadwds); )

*/
	return ( sts );

} /* add_to_disp_list */

/*--- change_disp_list -------------------------------------------------*/

method change_disp_list( IGRdouble *disp_list; IGRint *num_quadwds )
/*
DESCRIPTION
	changes the number of display list "commands" and the entire display list itself,
	and the quadwords
HISTORY
	07/00/88	KMJ	Creation
*/
{
   IGRshort i;

   for ( i=0; i<*num_quadwds; i++ )
   {
      *(me->disp_list + me->num_quadwords + i) = *(disp_list + i);
   }
   me->num_quadwords = *num_quadwds;

   return( OM_S_SUCCESS );

} /* change_disp_list */

/*--- read_disp_list  -------------------------------------------------*/

method read_disp_list( IGRdouble *disp_list )
/*
DESCRIPTION
	returns the number of display list "commands" and the entire display list itself
HISTORY
*/
{
	IGRint i, sts = OM_S_SUCCESS;

	/* *num_quadwds = me->num_quadwords; */
	for (i=0; i<me->num_quadwords; i++) *(disp_list + i) = *(me->disp_list + i);

	sts = om$vla_set_dimension ( varray = me->disp_list, size = 0 );
	OM_ERRCHK( sts, "HSNCtoolpthi.I: om$vla_set_dimension failed." );
	me->num_quadwords = 0;

	return( OM_S_SUCCESS );

} /* read_disp_list */

/*--- read_num_quadwords  -------------------------------------------------*/

method read_num_quadwords(IGRint *num_quadwds)
/*
DESCRIPTION
	return the quad word count.

HISTORY
	07/00/88	KMJ	Creation
*/
{
	*num_quadwds = me->num_quadwords;
	return( OM_S_SUCCESS );
} /* read_num_quadwords */

method set_object_env ( int num_bg_objenvs; 
                       struct GRobj_env *bg_obj_envs;
                       int num_part_objenvs;
                       struct GRobj_env *part_obj_envs;
                       struct GRid      *gragad)
{
   /* set the object envirionment values */

   me->num_bg_objenvs = num_bg_objenvs;
   om$vla_set_dimension( varray = me->background_objenvs,
                         size = num_bg_objenvs);
   memcpy( me->background_objenvs, bg_obj_envs, 
            sizeof( struct GRobj_env ) * num_bg_objenvs );
   me->num_part_objenvs = num_part_objenvs;
   om$vla_set_dimension( varray = me->part_objenvs,
                         size = num_part_objenvs);
   memcpy( me->part_objenvs, part_obj_envs, 
            sizeof( struct GRobj_env ) * num_part_objenvs );
   me->gragad = *gragad;
   return( TRUE );
}

method get_object_env ( int *num_bg_objenvs; 
                       struct GRobj_env **bg_obj_envs;
                       int *num_part_objenvs;
                       struct GRobj_env **part_obj_envs;
                       struct GRid      *gragad)
{
   int i;

   *num_bg_objenvs = me->num_bg_objenvs;
   *bg_obj_envs = (struct GRobj_env *) malloc( sizeof( struct GRobj_env ) * *num_bg_objenvs );
   for (i = 0; i < *num_bg_objenvs; i++)
   {
      (*bg_obj_envs)[i] = me->background_objenvs[i];
   }
   *num_part_objenvs = me->num_part_objenvs;
   *part_obj_envs = (struct GRobj_env *) malloc( sizeof( struct GRobj_env ) * *num_part_objenvs );
   for (i = 0; i < *num_part_objenvs; i++)
   {
      (*part_obj_envs)[i] = me->part_objenvs[i];
   }
   *gragad = me->gragad;
   return( TRUE );
}

method debug()
{
/*
instance HSNCtoolpth
{
   variable	IGRdouble	disp_list[HSNC_DISP_LIST_SIZE];
   IGRint		num_quadwords;
   channel {(many_to_one)} tpmgr;
   IGRint                      num_bg_objenvs;
   struct GRobj_env            background_objenv;
   variable struct GRobj_env   background_objenvs[0];
   IGRint                      num_part_objenvs;
   struct GRobj_env            part_objenv;
   variable struct GRobj_env   part_objenvs[0];
   struct GRid                 gragad;
};
*/
   int size;

   printf("HSNCtoolpth object: my_id = %d\n",my_id);
   size = om$dimension_of( varray = me->disp_list );
   printf("   size disp_list:           %d\n",size);
   printf("   num_quadwords:            %d\n",me->num_quadwords);
   size = om$dimension_of( varray = me->background_objenvs );
   printf("   size background_objenvs:  %d\n",size);
   printf("   num_bg_objenvs:           %d\n",me->num_bg_objenvs);
   printf("   background_objenv.obj_id  osnum = %d objid = %d\n",
      me->background_objenv.obj_id.osnum,me->background_objenv.obj_id.objid);
   printf("             .mod_env.md_id  osnum = %d objid = %d \n",
      me->background_objenv.mod_env.md_id.osnum,me->background_objenv.mod_env.md_id.objid);
   printf("             .mod_env.md_env matrix_type = %d matrix = %#X \n",
      me->background_objenv.mod_env.md_env.matrix_type,me->background_objenv.mod_env.md_env.matrix);
   size = om$dimension_of( varray = me->part_objenvs );
   printf("   size part_objenvs:  %d\n",size);
   printf("   num_part_objenvs:           %d\n",me->num_part_objenvs);
   printf("   part_objenv.obj_id  osnum = %d objid = %d\n",
      me->part_objenv.obj_id.osnum,me->part_objenv.obj_id.objid);
   printf("             .mod_env.md_id  osnum = %d objid = %d \n",
      me->part_objenv.mod_env.md_id.osnum,me->part_objenv.mod_env.md_id.objid);
   printf("             .mod_env.md_env matrix_type = %d matrix = %#X \n",
      me->part_objenv.mod_env.md_env.matrix_type,me->part_objenv.mod_env.md_env.matrix);
   printf("   gragad                    osnum = %d objid = %d\n",
      me->gragad.osnum,me->gragad.objid);
   return(0);      
}
end implementation HSNCtoolpth;
