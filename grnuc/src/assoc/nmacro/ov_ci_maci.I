class implementation ov_ci_mac;
/*--------------------------------------------------------------------------*/
/*
/*  ov_ci_maci.I
/*  robert patience
/*  5 sept 1989
/*
/*---------------------------------------------------------------------------
/* */

#define AS_DEBUG	/* debug pre-processor */

#include "ci_macro.h"

#include "memory.h"
#include "igrdef.h"    
#include "codef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "macro.h"
#include "DIdef.h"
#include "DIprims.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include <stdio.h>
#include "cierrordef.h" 
#include "ciexecmacros.h" 
#include "grownmacros.h"

extern IGRint CI_MAC_place ; /* on/off to activate cifile.place/compute  */
extern IGRboolean ASbroadcast_in_progress;


from ci         	import set_value, is_entry_point;
from ci_mac_def 	import ACgive_cim_desc ;
from ACcpx_defn		import ACgive_feet_desc, ACintpt_foot,ACintpt_foot_dir,
			       ACgive_temp_desc, ACgive_name ;
from ACmacro_defn 	import ACgive_upscan;


/* ========================================================================= */
 
method  ACconstruct_feet ( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *feet_num;
			   struct GRid *feet_list)
{
  char 			*entry;
  struct GRid		ci_macro_id;
  IGRint 		status;
  struct GRid		MY_GRID;
  IGRboolean              save_br;
  struct GRid *grobj_ids;


  entry = ((CI_MAC_place) ? "place" : "compute" );
  CI_MAC_place = 0;
  save_br=ASbroadcast_in_progress;

  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	    string = ("element %d not updated because degraded state\n",my_id));
    return(OM_W_ABORT);}

  if(me->STATE  & ncpx_root)
    { /*| Root nci_macro */ *msg = ND_COMP_SUCC;  return( OM_S_SUCCESS ); }

  MY_GRID.objid = my_id; MY_GRID.osnum = OM_Gw_current_OS;


  ASbroadcast_in_progress=TRUE;

  status=om$send(msg = message ov_ci_mac.ci_kl_NDcompute_node
		( msg,cn_type,count,list,md_env),
		      targetid = my_id  );

  if(!(status&1))
   {
   if(test_ci1( entry, my_id, OM_Gw_current_OS, 
		&ci_macro_id, me->internal_buffer ))
     {
      status = om$send( msg = message ci.set_value 
		((int *)msg,"MOD_ENV",(char *) md_env,sizeof(struct GRmd_env)),
            	    targetid = ci_macro_id.objid , 
		    targetos = ci_macro_id.osnum);
      as$status ( );
     /* For Jean Luc safety ..... */
     GRabsg_del_all();
     *msg  = run_ci( entry,ci_macro_id );
     if(!(*msg&1)) goto wrapup;
     }
    else
     {
      printf("No ppl compute entry point found \n");
      *msg = MSFAIL;
      goto wrapup;
     }
   }

   
  status = ACpull_feet(&MY_GRID,feet_num,&grobj_ids);
  OM_BLOCK_MOVE(grobj_ids,feet_list,*feet_num*sizeof(struct GRid));
  status = ACfree_feet(&MY_GRID);

wrapup :
  ASbroadcast_in_progress = save_br;
  return( OM_S_SUCCESS );
}

/* ========================================================================= */

method update_int_data( int *succ, size)
{
   om$vla_set_dimension ( varray = me->internal_buffer, 
                         size = size );

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */
/* 	this method put the external feet all at once on the to_components
/*   channel
/* ========================================================================= */

method set_all_extern_feet( 	
			IGRint 		*succ;
			IGRint		nbobj;
			struct GRid 	*grobj_ids;
			struct GRmd_env *mod_env 
		       )
{
 struct GRid my_grid;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;


/* jla 07-nov-90
/* int status;
/* IGRboolean 		save_br;
/* struct GRid         context;
/* 
/* 
/*   *succ = 0;
/*   context.objid=(OM_S_OBJID )me->rtstr;
/*   context.osnum=(OMuword )      me->xform_pos;
/*   save_br=ASbroadcast_in_progress;
/*   ASbroadcast_in_progress=TRUE;
/* 
/*   status = om$send( msg = message ACncpx.ACcontext_compute_feet(
/* 		  nbobj,context,grobj_ids, mod_env),
/* 	     	      targetid = my_id);
/*   as$status();
/*   status = om$send(msg = message ACncpx.ACchange_feet
/* 		     (nbobj,grobj_ids,mod_env ),
/* 		     targetid = my_id );
/*   as$status();
/*   ASbroadcast_in_progress =save_br;
/******/

/*^{int ijla;
    for(ijla=0;ijla<nbobj;ijla++)
      printf("%d --> %d %d\n",ijla,grobj_ids[ijla].objid,grobj_ids[ijla].osnum);
   }*/

  ACpush_feet(&my_grid,nbobj,grobj_ids);
  *succ = 1;

  return ( OM_S_SUCCESS );
}




/* ========================================================================= */



test_ci1( entry_point,ci_mac_my_id,ci_mac_my_os,ci_macro_id,my_internal_buffer)
char 			*entry_point;
OM_S_OBJID 		ci_mac_my_id;
GRspacenum 		ci_mac_my_os;
struct GRid		*ci_macro_id;
char			*my_internal_buffer;
/*. test_ci */
{
  IGRint             	status, msg, 
			ci_entry_point_flag;

  struct ci_mac_st 	*p_desc;
  IGRint		temp_feet_num, intern_feet_num, extern_feet_num;
  struct GRid		MY_GRID ;
  OM_S_OBJID		tmp_ciid ;
  struct GRid 		mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
		    senderid = ci_mac_my_id, 
                    targetid = ci_mac_my_id,
		    targetos = ci_mac_my_os);
  as$status();
  if(!(status&1)) return (0); /* 0 is the only error EB knows  .... */


  status = om$send ( msg = message ci_mac_def.ACgive_cim_desc( &msg, &p_desc,
			&temp_feet_num, &intern_feet_num, &extern_feet_num),
		     senderid = ci_mac_my_id,
                       targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status();
  if(!(status&1)) return (0);

  MY_GRID.objid = ci_mac_my_id; MY_GRID.osnum = ci_mac_my_os;

  /* tmp_ciid is just used to spare DUP time and see if entry
     point exists in the file */
  tmp_ciid =NULL_OBJID;
  status =ci$load ( 	file_name = p_desc->ci_name,
			file_id = &(tmp_ciid ),
			load = RETRIEVE,
		      	sender_id = ci_mac_my_id );

  if (tmp_ciid == NULL_OBJID || !(status&1)){
	  status =ci$load ( 	file_name = p_desc->ci_name,
				file_id = &(tmp_ciid ),
	                        load = LOAD,
			      	sender_id = ci_mac_my_id );
	  /*" status %d tmp_ciid  = %d \n", status, tmp_ciid  */
	  if(!(status&1))
	  {/*" unable to load %s\n", p_desc->ci_name */
	    return(0);
	  }
  }

  /* we check that the entry point exist */
  status = om$send( msg = message ci.is_entry_point( &ci_entry_point_flag,
						     entry_point ),
		    senderid = ci_mac_my_id,
            	    targetid = tmp_ciid , 
		    targetos = OM_Gw_TransOSnum_0);
  as$status ( );

  /*"ci_entry_point_flag %d\n", ci_entry_point_flag  */
  if( ci_entry_point_flag != CI_S_SUCCESS )    
     {/*" unable to find entry point %s\n",entry_point  */
      return(0);}

  ci_macro_id->objid=NULL_OBJID;
  status =ci$load ( 	file_name = p_desc->ci_name,
			file_id = &(ci_macro_id->objid),
			load = DUP,
		      	sender_id = ci_mac_my_id );
  ci_macro_id->osnum =   OM_Gw_TransOSnum_0;

  status = om$send( msg = message ci.set_value 
	    	      (&msg,"CI_MACRO_ID",(char *)&MY_GRID,sizeof(struct GRid)),
		    senderid = ci_mac_my_id,
            	    targetid = ci_macro_id->objid , 
		    targetos = OM_Gw_TransOSnum_0);
  as$status ( );

  status = om$send( msg = message ci.set_value ( &msg,"me" , 
			(char *)&my_internal_buffer, sizeof(char *) ),
		      senderid = ci_mac_my_id,
            	      targetid = ci_macro_id->objid , 
		      targetos = OM_Gw_TransOSnum_0);
  as$status ( );

 return(1);
}

run_ci( entry_point,ci_macro_id)
char 			*entry_point;
struct GRid		ci_macro_id;
/*.run_ci*/
{
  IGRboolean 		save_br;
  IGRint             	ret_code,status;
  struct GRid active_owner; 
  IGRint actmsg;

  save_br=ASbroadcast_in_progress;
  ASbroadcast_in_progress=TRUE;

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);

  status =ci$run (  file_id = &(ci_macro_id.objid),
	      	    entry   = entry_point,
/*		    delete  = 1,	*/
		    retsize = sizeof(int),
		    retval  = &ret_code,
		    sender_id = NULL_OBJID );


  ci$delete( file_id	= ci_macro_id.objid );


  /*" ret_code %d \n", ret_code */
  ASbroadcast_in_progress =save_br;
  if(actmsg == MSSUCC)  
		gr$put_active_owner(msg=&actmsg,active_owner=&active_owner);
   
  return(ret_code);
}

/* ========================================================================= */

method ci_kl_user_func( 
			IGRchar			*entry;
			struct GRmd_env		*mod_env;
			char   			*user_data;
		       )
{
  return(0);
}

method ci_kl_ACget_context_s_compute( IGRlong *msg; IGRint cn_type;
			   struct GRmd_env *md_env;
			   struct GRid context_obj)
{
  return(0);
}


method ci_kl_ACgive_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{
  return(0);
}


method ci_kl_NDcompute_node ( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env)
{
  return(0);
}

/* ========================================================================= */

end implementation ov_ci_mac;

