/*
  ACcomplex.I
  robert patience
  21_jul_86
*/

class implementation ACcomplex;

#define AS_DEBUG

#include "macro.h"
#include "ASmacroi.h"
#include "ndmacros.h"

from GRgraphics import GRdelete;


/* ========================================================================= */

method ACremove_all(int severity )
{
  int			status, msg;
  struct GRmd_env	md_env;
  long S1,S2;

  S1 = sizeof (struct GRmd_env);
  status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &md_env,
                    		nret   = &S2 );
  as$status(action = RET_STATUS );

  md_env.md_id.osnum = OM_Gw_current_OS;

  status = om$send( msg = message ACcomplex.ACmremove_all( &msg, severity, 
							   &md_env ), 
		    targetid = my_id );
  as$status( action = RET_STATUS );

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method ACmremove_all(int *msg, severity; struct GRmd_env *md_env )
{
  long loc_msg;
  int			status;
  struct GRid save_id;
  OM_S_OBJID *other;
  int   i, nb_other;


  *msg=0;
  save_id = md_env->md_id;
  md_env->md_id.objid = NULL_OBJID;
  md_env->md_id.osnum = OM_Gw_current_OS; 

  /* because the osnum is used to remove symbol name from the b-tree 
  /* if there is symbol in the macro def 
  /**********/

  status = om$send( msg = message ACcomplex.ACget_other
					(&loc_msg,&nb_other,&other),
		    targetid = my_id);
  if(status&loc_msg&1)
   { for(i=0;i<nb_other;i++)
      {
       status = om$send( msg = message NDnode.NDdelete( md_env ),
			 targetid = other[i],
			 targetos = OM_Gw_current_OS);
       /*
         Commenting this out since in case of profiles there are needless
         error messages that get printed. 

         as$status( );
       */
      }
   }

  status = om$send( msg = message GRgraphics.GRdelete( (IGRlong *)msg, md_env ),
	    	  p_chanselect = &AC_mto_graf_chns);
  as$status( );

  if(severity)
  {
    status = om$send( msg = message NDnode.NDdelete( md_env ),
	    	  p_chanselect = &AC_template_chns );
    as$status( );
  }

  status = om$send( mode = OM_e_wrt_message,  
		    msg = message NDnode.NDdelete( md_env ), 
		    targetid = my_id );
  as$status( );

  *msg=1;
  md_env->md_id = save_id;
  return ( OM_S_SUCCESS );
}

/* ====================================================================	*/

method ACget_other( IGRlong *msg; IGRint *nb_other; OM_S_OBJID **other_list )

{

	*msg		= MSSUCC;
	*nb_other	= om$dimension_of( varray	= me->others );
	*other_list	= me->others;

return	OM_S_SUCCESS;
}


method ACset_other( IGRlong *msg; IGRint nb_other; OM_S_OBJID *other_list )

{
 int i;
 long status;

 *msg = MSFAIL;

 status = om$vla_set_dimension(varray = me->others,
			       size = nb_other);
 if(!(status&1)) return OM_W_ABORT;

 for(i=0;i<nb_other;i++) me->others[i] = other_list[i];

 *msg = MSSUCC;
 return OM_S_SUCCESS;
}
end implementation ACcomplex;
