class implementation ci_macro;
/*--------------------------------------------------------------------------*/
/*
/*  ci_macroi.I
/*  Serge Frezefond ( ISDC Paris )
/*  
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
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
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

%safe
IGRint CI_MAC_place = 0; /* on/off to activate cifile.place/compute  */
%endsafe

from ci         	import set_value, get_value, is_entry_point;
from ci_mac_def 	import ACgive_cim_desc ;
from ACcpx_defn		import ACgive_feet_desc, ACintpt_foot,ACintpt_foot_dir,
			       ACgive_temp_desc, ACgive_name ;
from ACpretgo		import ACgive_info,ACstore_info;
from ACmacro_defn 	import ACgive_upscan;

extern OM_S_OBJID	md_id_pour_ci_macro; /* pb avec ci_place et md_env */

extern GRclassid 	OPP_ASsource_class_id, OPP_ACpretgo_class_id;

/* ========================================================================= */

method store_internal ( IGRint *succ; IGRchar *p_internal )
{
  struct 	ci_mac_st *desc;
  IGRint	temp_feet_num, intern_feet_num, extern_feet_num,
		status;
  struct GRid mac_def;

  *succ = OM_E_ABORT;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


  

  if (p_internal)
  {
    status = om$send ( msg =message ci_mac_def.ACgive_cim_desc ( succ, &desc,
			&temp_feet_num, &intern_feet_num, &extern_feet_num),
                       targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status ( action = RET_STATUS );

    if( desc->int_size  > 0 )
    {
      /*"copy for %d bytes\n", desc->int_size */
      memcpy ( me->internal_buffer, p_internal, desc->int_size );
    }
   *succ = OM_S_SUCCESS;
  }

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method give_internal ( IGRint *succ; IGRchar *p_internal )
{
  struct ci_mac_st 	*desc;
  IGRint		temp_feet_num, intern_feet_num, 
			extern_feet_num, status;
  struct GRid mac_def;

  *succ = OM_E_ABORT;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  if (p_internal)
  {
    status = om$send ( msg = message ci_mac_def.ACgive_cim_desc( succ, &desc,
			 &temp_feet_num, &intern_feet_num, &extern_feet_num),
                       targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status ( action = RET_STATUS );

    if( desc->int_size > 0 )
    { memcpy ( p_internal, me->internal_buffer, desc->int_size ); }
    *succ = OM_S_SUCCESS;
  }

  return ( OM_S_SUCCESS );
}
/* ========================================================================= */
method update_int_data( int *succ, size)
{
  struct ci_mac_st 	*desc;
  IGRint		temp_feet_num, intern_feet_num, 
			extern_feet_num, status;
  struct GRid mac_def;

  *succ=0;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send ( msg = message ci_mac_def.ACgive_cim_desc( succ, &desc,
			 &temp_feet_num, &intern_feet_num, &extern_feet_num),
                       targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status ( action = RET_STATUS );
  if( desc->int_size == 0 )
    {
    om$vla_set_dimension ( varray = me->internal_buffer, 
                         size = size );
    *succ = 1;
    }


  return ( OM_S_SUCCESS );
}

/* ========================================================================= */
method give_internal_ptr ( IGRint *succ; IGRchar **p_internal )
{
  struct ci_mac_st 	*desc;
  IGRint		temp_feet_num, intern_feet_num, 
			extern_feet_num, status;
  struct GRid mac_def;

  *succ=0;
  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send ( msg = message ci_mac_def.ACgive_cim_desc( succ, &desc,
			 &temp_feet_num, &intern_feet_num, &extern_feet_num),
                       targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status ( action = RET_STATUS );

  *p_internal=&(me->internal_buffer[0]);
  if( desc->int_size == 0 &&
	!(om$dimension_of(varray=me->internal_buffer)))
      {
      *succ=0;
      }
  else
      {
      *succ = 1;
      }
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method  NDcompute_node ( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env)
{
  char 			*entry;
  struct GRid		ci_macro_id;
  IGRint 		status;
  int 			rc;
  IGRint		temp_feet_num, intern_feet_num, extern_feet_num;
  struct GRid		MY_GRID;
  struct ci_mac_st 	*p_desc;
  struct GRid mac_def;

  *msg = 0;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);



 /*
    modif jla 05-june-90 
    NDcompute_node can trigger the NDcompute_node of other element. We don't
    want the flag to be inherited --> RESET immediatly 
 */

  entry = ((CI_MAC_place) ? "place" : "compute" );
  CI_MAC_place = 0;

  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	    string = ("element %d not updated because degraded state\n",my_id));
    return(OM_W_ABORT);}

  status = om$send ( msg = message ci_mac_def.ACgive_cim_desc( &rc, &p_desc,
			&temp_feet_num, &intern_feet_num, &extern_feet_num),
                       targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status ( action = RET_STATUS );
  MY_GRID.objid = my_id; MY_GRID.osnum = OM_Gw_current_OS;

  if(!(me->STATE & sym_rtn_built))
  {
    status = om$send(msg = message ACcpx.ACtbuild_rtn_str( count, list),
		     targetid = my_id );
    as$status( action = RET_STATUS );
  }

  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	    string = ("element %d not updated because degraded state\n",my_id));
    return(OM_W_ABORT);}
  
   {
   struct GRid active_owner; 
   IGRint actmsg;
   gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
   if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);

   /*"active owner %d\n",active_owner.objid */
   execute_ci1(	entry, md_env, my_id, OM_Gw_current_OS, 0, 0,
		&ci_macro_id, me->STATE, me->internal_buffer);
   if(actmsg == MSSUCC)  gr$put_active_owner(msg=&actmsg,active_owner=&active_owner);
   }



  status = om$send( msg = message ACcpx.ACload_temp_feet(count,list, md_env),
	     	      targetid = my_id);
  as$status( action = RET_STATUS );
  *msg = MSSUCC;
  return( 1 );
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
  IGRint		status, temp_feet_num, intern_feet_num, extern_feet_num;
  IGRlong               i,j,msg;
  struct ci_mac_st	*p_cim_desc;
  struct GRid		MY_GRID;
  GRclassid 		target_cl;
  struct GRid mac_def;

  *succ = 0;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  MY_GRID.objid = my_id;  MY_GRID.osnum = OM_Gw_current_OS;

  status = om$send(msg = message ci_mac_def.ACgive_cim_desc(succ, &p_cim_desc, 
			&temp_feet_num, &intern_feet_num, &extern_feet_num),
                     targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status ( action = RET_STATUS );

  if(nbobj != extern_feet_num)
  {
    fprintf(stderr, "ci_macro.set_all_extern : wrong external feet number\n");
    *succ = 0; return(OM_S_SUCCESS);
  }
  status = om$send( msg = message GRgraphics.GRdelete( &msg, mod_env),
	  	p_chanselect = &AC_mto_graf_chns);
  as$status( action = RET_STATUS );

  for(i=0; i < nbobj; i++)
  {
    struct GRid graph_obj;
    if(IF_NULL_OBJID(grobj_ids[i].objid))
    {
       build_point(&grobj_ids[i], mod_env);
    }

    graph_obj= grobj_ids[i];
    om$get_classid(objid=grobj_ids[i].objid,p_classid = &target_cl);
    if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS)
    {
      status = om$send( msg = message NDnode.ASreturn_go( &graph_obj, 
				NULL,NULL ),
		  targetid = grobj_ids[i].objid);
      as$status( action = RET_STATUS );
    }
    else if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
    {
      status=om$send(msg = message Root.wild_disconnect(ND_father),
                 targetid =grobj_ids[i].objid );
      as$status( action = RET_STATUS );
    }
    j=i;
    status = om$send( msg = message GRconnector.GRrigidconn( (IGRlong *)succ, 
								&MY_GRID, &j),
		  targetid = graph_obj.objid );
    as$status( action = RET_STATUS );
  }
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */


method get_extern_feet( 	
			IGRint 		*succ;
			IGRint		nb_extern;
			IGRchar		**feet_names;
			struct GRid 	*grobj_ids
		      )
{
  IGRint		status;

  status = om$send( msg = message ci_macro.get_exp_extern_feet(
			succ, nb_extern, feet_names, NULL, grobj_ids ),
                    targetid = my_id );
  as$status ( action = RET_STATUS );
    
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method get_exp_extern_feet( 	
			IGRint 		*succ;
			IGRint		nb_extern;
			IGRchar		**feet_names;
			IGRint		*direct_ext_feet_index;
			struct GRid 	*grobj_ids
		      )
{
  IGRint		status, chan, pos, type, i;
  GRclassid 		target_cl;
  struct GRid		tmp_obj;
  struct GRid mac_def;

  *succ = 0;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  for(i=0; i<nb_extern; i++)
  {
    if(direct_ext_feet_index==NULL)
    {
      status=om$send( msg = message ACcpx_defn.ACintpt_foot(succ,feet_names[i], 
			&chan, &pos, &type ),
                  targetid=mac_def.objid,targetos=mac_def.osnum );
      as$status ( action = RET_STATUS );
    
      if(!(*succ & 1) || (chan != feet_in_graphic)) 
      { *succ = 0; return(OM_S_SUCCESS);}
    }
    else
      pos = direct_ext_feet_index[i];
 
    status = om$get_objid_at_index(
			objid 		= my_id,
			p_chanselect 	= &AC_mto_graf_chns,
			index 		= pos,
			objidaddr 	= &(tmp_obj.objid),
			osnumaddr 	= &(tmp_obj.osnum) );
    as$status( action = RET_STATUS );

    om$get_classid( objid	= tmp_obj.objid,
		    p_classid 	= &target_cl );

    if( om$is_ancestry_valid(subclassid =target_cl ,
                        superclassid = OPP_ACpretgo_class_id) == OM_S_SUCCESS)
    {
      status = om$send( msg = message ACpretgo.ACgive_info( &grobj_ids[i] ),
  	         	targetid =  tmp_obj.objid );
      as$status( action = RET_STATUS );
    }
    else
      grobj_ids[i] = tmp_obj;

    om$get_classid(objid=grobj_ids[i].objid,
			osnum=grobj_ids[i].osnum,
			p_classid = &target_cl);
    if(!om$is_ancestry_valid(subclassid =target_cl ,
                           superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
    {
      struct GRid src_obj;

      status = as$make_source( go_grid = grobj_ids[i],as_grid = &src_obj,
		               as_os=grobj_ids[i].osnum );
      if(!(status&1)) return 0;
      grobj_ids[i]= src_obj;
    }


    if ( IF_NULL_OBJID( grobj_ids[i].objid ) ) 
    { *succ = 0; return(OM_S_SUCCESS);}
  }
  *succ = 1;
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method chang_extern_feet( 	
			IGRint 		*succ;
			IGRint		nb_extern;
			IGRchar		**feet_names;
			struct GRid 	*grob_news;
			struct GRmd_env *mod_env 
		)
{
  IGRint		status;

  status = om$send( msg = message ci_macro.chang_exp_extern_feet(
			succ, nb_extern, feet_names, NULL, grob_news,
			mod_env ),
                    targetid = my_id );
  as$status ( action = RET_STATUS );
    
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method chang_exp_extern_feet( 	
			IGRint 		*succ;
			IGRint		nb_extern;
			IGRchar		**feet_names;
			IGRint		*direct_ext_feet_index;
			struct GRid 	*grob_news;
			struct GRmd_env *mod_env 
		)
{
  long status,msg;
  IGRint		 chan, pos, type, i ;
  struct GRid		graph_obj_new, graph_obj_hldr, graph_obj_old,work_obj,
 			MY_GRID;
  GRclassid 		target_cl;
  struct GRsymbology 	symb;
  short 	props,set,set_props;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);



  MY_GRID.objid = my_id; MY_GRID.osnum = OM_Gw_current_OS;

  /*"grob_news %d %d\n",grob_news->objid,grob_news->osnum */

  for ( i=0; i<nb_extern; i++)
  {
    work_obj = grob_news[i];

    if(IF_NULL_OBJID(work_obj.objid))
    {
      build_point(&work_obj, mod_env);
    }
    /* ASget_go( work_obj, &graph_obj_new ); */
    /* pb jll Grgrgrp				 */

    graph_obj_new = work_obj;
    om$get_classid(objid=work_obj.objid,
		   osnum=work_obj.osnum,
		    p_classid = &target_cl);

    if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS)
    {
      status = om$send( msg = message NDnode.ASreturn_go( &graph_obj_new, 
				NULL,NULL ),
		  targetid = work_obj.objid ,
		  targetos = work_obj.osnum);
    }
    else if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
    { 
      status=om$send(msg = message Root.wild_disconnect(ND_father),
                 targetid = work_obj.objid ,
		  targetos = work_obj.osnum);
      as$status( action = RET_STATUS );
    }
  
    *succ = 0;
    if(direct_ext_feet_index==NULL)
    {
      status = om$send( msg = message ACcpx_defn.ACintpt_foot(succ, 
				feet_names[i], &chan, &pos, &type ),
		        targetid=mac_def.objid,targetos=mac_def.osnum );
      as$status ( action = RET_STATUS );

      if(!(*succ & 1) || (chan != feet_in_graphic)) 
      { *succ = 0; return(OM_S_SUCCESS);}
    }
    else
      pos = direct_ext_feet_index[i];

    status = om$get_objid_at_index(objid 	= my_id,
				p_chanselect 	= &AC_mto_graf_chns,
				index 		= pos,
				objidaddr 	= &graph_obj_hldr.objid,
				osnumaddr	= &graph_obj_hldr.osnum );

    if(status!=1) return(OM_S_SUCCESS);
    
    om$get_classid( objid	= graph_obj_hldr.objid,
		    p_classid 	= &target_cl );

    if( om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ACpretgo_class_id) == OM_S_SUCCESS)
    {
      /*" %d is a ACpretgo\n", graph_obj_hldr.objid */
      status = om$send( msg = message ACpretgo.ACgive_info( &graph_obj_old ),
  	         	targetid = graph_obj_hldr.objid  );
      as$status( action = RET_STATUS );
      status = om$send( msg = message ACpretgo.ACstore_info( graph_obj_new ),
  	         	targetid = graph_obj_hldr.objid  );
      as$status( action = RET_STATUS );
    }
    else
      graph_obj_old = graph_obj_hldr;

  /*" the graphic obj is %d %d \n", graph_obj_old.objid, graph_obj_old.osnum */

    if(IF_NULL_OBJID(graph_obj_old.objid))   return ( OM_S_SUCCESS );

   /* JLA 23 jan 91 : target channel must be empty before a move_chan */

    status = om$send( msg = message Root.wild_disconnect(AS_to_owner),
                 targetid = graph_obj_new.objid,
                 targetos = graph_obj_new.osnum );
    as$status( action = RET_STATUS );


    status = om$send( msg = message Root.move_chan( AS_to_owner,
	 graph_obj_old.objid,graph_obj_old.osnum , AS_to_owner ),
  	         targetid = graph_obj_new.objid,
		 targetos = graph_obj_new.osnum );
    as$status( action = RET_STATUS );

   /*" update symbology objid %d\n", graph_obj_new.objid */

    status = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
                      targetid = graph_obj_old.objid,
                      targetos = graph_obj_old.osnum);
    as$status( action = RET_STATUS );
    
    status = om$send(msg = message GRvg.GRgetprops(&msg,&props),
                      targetid = graph_obj_old.objid,
                      targetos = graph_obj_old.osnum);
    as$status( action = RET_STATUS );

    status = om$send(msg = message GRvg.GRputsymb(&msg,&symb),
                      targetid = graph_obj_new.objid,
                      targetos = graph_obj_new.osnum);
    as$status( action = RET_STATUS );

    if(props&GRIS_LOCATABLE) set = 1;
    else                     set = 0;
    set_props = GRIS_LOCATABLE;
    /*"locatable %d\n",set */
    status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set,
                                                           &set_props),
                      targetid = graph_obj_new.objid,
                      targetos = graph_obj_new.osnum);
    as$status( action = RET_STATUS );

    if(props&GRIS_DISPLAYABLE) set = 1;
    else                       set = 0;
    set_props = GRIS_DISPLAYABLE;
    /*"displayable %d\n",set */
    status = om$send(msg = message GRgraphics.GRchgprops(&msg,&set,
                                                           &set_props),
                      targetid = graph_obj_new.objid,
                      targetos = graph_obj_new.osnum);
    as$status( action = RET_STATUS );

    status = om$send( msg = message GRgraphics.GRdelete( &msg, mod_env),
		      targetid = graph_obj_old.objid,
		      targetos = graph_obj_old.osnum );
    as$status( action = RET_STATUS );
  }
  *succ = 1;
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method set_intern_feet( 	
			IGRint 			*succ;
			IGRint			nbobj;
			IGRchar			**feet_names;
			struct ret_struct  	**intern_struct
	       )
{
  IGRint		status;

  status = om$send( msg = message ci_macro.set_exp_intern_feet( 	
			succ, nbobj, feet_names, NULL, intern_struct ),
                    targetid = my_id );
  as$status ( action = RET_STATUS );
    
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method set_exp_intern_feet( 	
			IGRint 			*succ;
			IGRint			nbobj;
			IGRchar			**feet_names;
			IGRint			*direct_ext_feet_index;
			struct ret_struct  	**intern_struct
	       )
{
  IGRint		temp_feet_num, intern_feet_num, extern_feet_num,
			feet_num, status, chan, pos, type, i;
  struct GRid		mac_def;
  struct ci_mac_st	*p_cim_desc;
  struct myfeet 	*feet;

  *succ = 0;
  status = om$send( msg = message ACcpx.find_macro(&mac_def),
		targetid = my_id);
  as$status( action = RET_STATUS );

  status = om$send( msg = message ci_mac_def.ACgive_cim_desc(succ, &p_cim_desc,
		      &temp_feet_num, &intern_feet_num, &extern_feet_num),
		targetid = mac_def.objid,targetos = mac_def.osnum);
  as$status( action = RET_STATUS );
 
  status  = om$send( msg = message ACcpx_defn.ACgive_feet_desc( &feet_num, 
									&feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  if(nbobj > intern_feet_num)
  {
    fprintf(stderr, "ci_macro.set_intern_feet : too many obj\n");
    *succ = 0; return(OM_S_SUCCESS);
  }

  for(i=0; i < nbobj; i++)
  {
    if(direct_ext_feet_index==NULL)
    {
      status =om$send(msg = message ACcpx_defn.ACintpt_foot(succ,feet_names[i], 
							&chan, &pos, &type ),
		  targetid = mac_def.objid,targetos = mac_def.osnum);
      as$status( action = RET_STATUS );

      if(!(*succ & 1) || (chan != feet_virtual)) { return(OM_S_SUCCESS);}
    }
    else
      pos = direct_ext_feet_index[i];

    /*^
       printf("OM_BLOCK_MOVE(	type %x\n", 
	   me->rtstr[temp_feet_num + pos]->type);
       if((intern_struct[i])->type==0x20010) 
         printf("text field %s\n",
			 (intern_struct[i])->var.text_st.text_string);
    */
    /*"	OM_BLOCK_MOVE(	type %x\n", feet[temp_feet_num + pos].prop */
    /*"	type (intern_struct %x\n", (intern_struct[i])->type  */

    OM_BLOCK_MOVE( (char *)(intern_struct[i]), 
		((char *)(me->rtstr[temp_feet_num + pos])),
		ASgive_size_st( feet[temp_feet_num + pos].prop ));
  }
  *succ = 1;
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method set_all_intern_feet( 	
			IGRint 			*status;
			struct ret_struct  	**intern_struct
	       )
{
  IGRint		temp_feet_num, intern_feet_num, extern_feet_num,
			feet_num, rc, i;
  struct GRid		mac_def;
  struct ci_mac_st	*p_cim_desc;
  struct myfeet 	*feet;

  *status = 0;
  rc = om$send( msg = message ACcpx.find_macro(&mac_def),
		targetid = my_id);
  as$status(sts= rc, action = RET_STATUS);

  rc = om$send( msg = message ci_mac_def.ACgive_cim_desc(status, &p_cim_desc,
		      &temp_feet_num, &intern_feet_num, &extern_feet_num),
		targetid = mac_def.objid,targetos = mac_def.osnum);
  as$status( sts= rc, action = RET_STATUS );
 
  rc  = om$send( msg = message ACcpx_defn.ACgive_feet_desc( &feet_num, &feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( sts= rc, action = RET_STATUS );


  for(i=0; i <intern_feet_num ; i++)
  {

/*^
 printf("charging %s type %x\n",feet[i+temp_feet_num].name,
		                feet[i+temp_feet_num].prop);
 printf("	-type %x\n",intern_struct[i]->type);
 if(intern_struct[i]->type==0x20010) 
   printf("text field %s\n",  intern_struct[i]->var.text_st.text_string);
 
*/

    OM_BLOCK_MOVE( (char *)(intern_struct[i]), 
		((char *)(me->rtstr[i+temp_feet_num])),
		ASgive_size_st(feet[i+temp_feet_num].prop));

  }
  *status = 1;
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method obj_init  ( 
		IGRint 	*succ;
               	IGRchar *cpx_name;
               	OMuint  temp_num; OM_S_OBJID *temp;
               	IGRchar *internal /* to set internals at placement */
	     )
{ 
  struct GRid		*GRid_temp = NULL;
  int			i, status, msg, prop;
  struct GRmd_env	md_env;
  IGRlong 		S1, S2;

  ASsuper_construct();

  S1 = sizeof (struct GRmd_env);
  status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &md_env,
                    		nret   = &S2 );
  as$status( action = RET_STATUS );

  if(temp_num)
  {
    GRid_temp = (struct GRid *)om$malloc( size = temp_num *sizeof(struct GRid));
    if (GRid_temp == NULL) return(0);
  }
  for (i=0; i<temp_num; i++)
  {
       GRid_temp[i].objid = temp[i];
       GRid_temp[i].osnum = OM_Gw_current_OS;
  }

  prop = 0;
  status = om$send ( msg = message ci_macro.init( succ, prop, cpx_name, 
			temp_num, GRid_temp, internal,  &md_env),
	    	 targetid = my_id );
  as$status( action = CONTINUE );
 
  if((temp_num)&&(GRid_temp)) om$dealloc(ptr = GRid_temp);

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method init  ( 
		IGRint 	*succ;
		IGRint	prop;
               	IGRchar *cpx_name;
               	OMuint  temp_num; 	struct GRid *temp;
               	IGRchar *internal ;	/* to set internals at placement */
		struct  GRmd_env *md_env 
	     )
{
  struct     		ci_mac_st *p_desc;
  IGRint		temp_feet_num, intern_feet_num, extern_feet_num, i,
			status;
  struct GRid		*assoc_parent_list = NULL;
  long			msg;
  int			cn_type;
  int                   real_temp_num; 
  struct GRmd_env	emp_env;

  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;

  ASsuper_construct();
  me->state = me->state & ~ND_DEGRADED;

/*
   If associative geometry was not initialize, the super object initialization
   try to reconnect placed macro to their real definitions. Because
   the definition of the ci_macro has not already be defined ( will
   be defined by ACattach), it changes its state to "DEGRADED"
*/

  status = om$send ( msg = message ACcpx.ACattach( succ, cpx_name ),
	    	 targetid = my_id );
  as$status( action = RET_STATUS);
  /*  if (*succ != 1) return(0); */

  status = om$send( msg = message ci_mac_def.ACgive_cim_desc( succ, &p_desc, 
		&temp_feet_num, &intern_feet_num, &extern_feet_num),
                  targetid=me->mac_def.objid,
		  targetos=me->mac_def.osnum );
  as$status ( action = RET_STATUS );

  /* control on template type to do */

  if((p_desc->int_size>0))
  {
   /*" internal feet %d size %d \n",intern_feet_num,p_desc->int_size */
    om$vla_set_dimension ( varray = me->internal_buffer, 
                         size = p_desc->int_size );
    if(internal) memcpy ( me->internal_buffer, internal, p_desc->int_size );
  }

  /*| control the number of template */
  if(temp_num)
  {
    assoc_parent_list = (struct GRid *)om$malloc( 
				size = temp_num * sizeof(struct GRid) );
    if(assoc_parent_list==NULL) return(0);
  }
  real_temp_num = 0;
  for(i=0; i<temp_num; i++)
  {
    if(!(IF_NULL_OBJID(temp[i].objid)))
    {
      if(!(prop & AChdr_noprotect))
      {
        status = as$make_source ( go_grid = temp[i],
			      as_os = temp[i].osnum,
                              as_grid = &(assoc_parent_list[real_temp_num++]) );
        as$status( action = RET_STATUS );
      }
      else
      {
	assoc_parent_list[real_temp_num++] = temp[i];
      }
    }
  }

  {
    status = om$send ( msg = message NDnode.NDconnect
                      ( real_temp_num, assoc_parent_list, NULL_GRID, ND_NEW ),
                 targetid = my_id );
    as$status( action = RET_STATUS );
  }


  if(!((prop & AChdr_nocompute) || (prop & AChdr_nobuild)))
  {
    CI_MAC_place = 1;

    cn_type = ND_COMP;
    status = om$send( msg = message ci_macro.NDcompute_node(&msg,  cn_type,
				real_temp_num, assoc_parent_list,  &emp_env),
		     targetid = my_id);
    as$status( action = RET_STATUS );
    *succ = msg;
    CI_MAC_place = 0;
  }
  if( (temp_num) && (assoc_parent_list) ) om$dealloc(ptr = assoc_parent_list );
  if(prop&AChdr_norange) return(1);
  {
    /*| addwrng */
    status = om$send(msg = message GRgraphics.GRaddwrng(&msg, md_env),
			  	p_chanselect = &AC_mto_graf_chns);
    as$status();
  }

  if(!(prop & AChdr_nodisplay))
  {
    /*| display myself */
    status = om$send( msg = message NDnode.NDdisplay(0, GRbd, md_env ),
 		      targetid = my_id);
    as$status( action = RET_STATUS );
  }

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method ACreplace(struct GRmd_env *md_env)
{

  int			status;
  long			msg;


  CI_MAC_place = 1;
  status=om$send( msg = message NDnode.NDs_compute_node(&msg,ND_COMP,md_env ), 
		  targetid = my_id );
  as$status ( action = RET_STATUS );
  CI_MAC_place = 0;

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method ACgive_structure( int *succ,*direct_index; char *feet_name;
			 struct ret_struct  *ptr_rst; struct GRmd_env *md_env )
{
  struct GRid 		feet_obj;
  IGRint   		pos, chan, type, index, status;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);



  *succ=0;
   if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
             string = ("element %d degraded doesn't return foot %s structure\n",
			my_id,feet_name));
    return(OM_W_ABORT);}

  
  if(!(me->STATE & sym_rtn_built))
   {
    status = om$send( msg = message ACcpx.ACbuild_rtn_str(md_env,ND_COMP ),
		     targetid = my_id);
    as$status( action = RET_STATUS );
   }
   

  if(direct_index && *direct_index != -1)
   {
   if(me->rtstr[*direct_index])
    {
    /*" load ext direct_index %d,pointer %d\n",
		*direct_index,me->rtstr[*direct_index]*/
    OM_BLOCK_MOVE( (char *)(me->rtstr[*direct_index]),  
  		((char *) (ptr_rst)),
		ASgive_size_st(me->rtstr[*direct_index]->type));
    *succ =1;

    /* jla 06-june-90 when ACgive_structure is accross reference file */
    if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
							
    return(1);
    }
   }

  status = om$send( msg = message ACcpx_defn.ACintpt_foot_dir(succ,
			direct_index, feet_name, &chan,&pos, &type,&index),
		  targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status ( action = RET_STATUS );

  if (*succ != 1) return(1);

  if(chan == feet_in_template)
  {
    OM_BLOCK_MOVE( (char *)(me->rtstr[index]),  
	((char *) (ptr_rst)),
	ASgive_size_st(me->rtstr[index]->type));

    /* jla 06-june-90 when ACgive_structure is accross reference file */
    if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
/*
    status = om$send( msg = message ACcpx.ACfind_exp_temp_struct(succ, pos, 
						ptr_rst, md_env),
             	    targetid = my_id);
    as$status ( action = RET_STATUS );
*/
  }
  else if(chan == feet_virtual ) 
  { 

    /*
	
       printf("OM_BLOCK_MOVE(	type %x\n", me->rtstr[pos]->type);
       if((me->rtstr[pos])->type==0x20010) 
         printf("text field %s\n",
			 (me->rtstr[pos])->var.text_st.text_string);
    */
    OM_BLOCK_MOVE( (char *)(me->rtstr[index]),  ((char *) (ptr_rst)),
		ASgive_size_st(me->rtstr[index]->type));

    /* jla 06-june-90 when ACgive_structure is accross reference file */
    if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
  }
  else
  if (chan == feet_in_graphic|| chan == feet_numeric) 
  { 
    status = om$get_objid_at_index(
			objid 		= my_id,
			p_chanselect 	= &AC_mto_graf_chns,
			index 		= pos,
			objidaddr 	= &feet_obj.objid,
			osnumaddr	= &feet_obj.osnum);
    as$status( action = RET_STATUS );

    if(IF_NULL_OBJID(feet_obj.objid))
    { *succ =0;   return ( OM_S_SUCCESS );}

    status = as$any_give_structure(go_grid = feet_obj, inst = ptr_rst );
    as$status( action = RET_STATUS );
  }
  *succ = 1;
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method print_struct ( struct ret_struct  *rst )
{
  printf ( "rst->type : %d\n", rst->type );

  if (rst->type == double_type)
    printf ( "double : %lf (%s)\n", 
              rst->var.root_pm_st.value); 
  else
    printf ( "text : '%s'\n", rst->var.text_st.text_string );

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method debug ()
{
  struct             	ci_mac_st *p_desc;
  IGRint             	feet_num, status;
  struct             	myfeet *my_feet;
  struct GRid	     	macro;
  IGRint		temp_feet_num, intern_feet_num, extern_feet_num;

  status = om$send( msg = message ACcpx.find_macro( &macro ), 
		    targetid = my_id );
  as$status( action =RET_STATUS );

  /*"macro : %d %d\n", macro.objid, macro.osnum */
  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc( &feet_num, 
								&my_feet ),
	    	    targetid = macro.objid,targetos = macro.osnum);
  as$status( action =RET_STATUS );

  /*"feet_num : %d\n", feet_num */

  status = om$send( msg = message ci_mac_def.ACgive_cim_desc ( &status, &p_desc,
			    &temp_feet_num, &intern_feet_num, &extern_feet_num),
	    	    targetid = macro.objid,targetos = macro.osnum);
  as$status( action = RET_STATUS );


  /*"ci_name  : '%s'\n", p_desc->ci_name */
  /*"int_name : '%s'\n", p_desc->int_name */
  /*"int_size : %d\n", p_desc->int_size	*/
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method execute_func( 	int 		*succ; 
			char 		*entry;
 			struct GRmd_env *mod_env )
{
  struct GRid		ci_macro_id;
 
  *succ = 1;

  if(!  execute_ci1( 	entry, mod_env, my_id, OM_Gw_current_OS, 0, 0,
		&ci_macro_id,  me->STATE, me->internal_buffer ))
    *succ = 0;

  return( 1 );
}
/* ========================================================================= */

method NDdelete( struct GRmd_env *md_env )
{
  IGRint		status;
  struct GRid		ci_macro_id;

  status =  execute_ci1("NDdelete", md_env, my_id, OM_Gw_current_OS, 0, 0,
		&ci_macro_id,  me->STATE, me->internal_buffer);
  /*"NDdelete status is %d\n", status */
  if(status!=1)
  {
    /*|I am doing ACcpx.NDdelete */

    status = om$send( mode = OM_e_wrt_message,
		      msg  = message ACcpx.NDdelete(md_env),
		      targetid = my_id );
    as$status ( action = CONTINUE );
  }

  return( 1 );
}
/* ========================================================================= */

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid; 
                      struct GRmd_env *md_env )
{
  IGRint		status;
  struct GRid		ci_macro_id;

  src_grid->objid=my_id;
  src_grid->osnum=OM_Gw_current_OS;
  status = execute_ci1( "NDmove_to_root", md_env, my_id, OM_Gw_current_OS, 0, 0,
		&ci_macro_id,  me->STATE, me->internal_buffer);
  /*"NDmove_to_root status is %d\n", status */
  if(status!=1)
  {
    /*| I am doing ACcpx.NDmove_to_root */
    status = om$send( mode = OM_e_wrt_message,
		    msg = message ACcpx.NDmove_to_root(msg,src_grid, md_env),
            	    targetid = my_id );
    return(status);
  }
  return( 1 );
}

/* ========================================================================= */

method GRxform( IGRlong *msg; struct GRmd_env *md_env;
	 	IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid )
{
  struct GRid	ci_macro_id;
  int 		status;

  *newobjid=my_id;
  status = execute_ci1( "GRxform", md_env, my_id, OM_Gw_current_OS,
			 matrix_type, matrix,
			 &ci_macro_id, me->STATE, me->internal_buffer );
  /*"GRxform status is %d\n", status */

  if(status!=1)
  {
    /*| I am going to ACcpx.GRxform */
    status=om$send(msg= message 
		ACcpx.GRxform(msg,md_env,matrix_type,matrix,newobjid),
		targetid=my_id,
                mode = OM_e_wrt_message);
    return( status );
  }
  return( 1 );
}

/* ========================================================================= */

method ACreturn_foot(IGRlong *suc;char *foot_name; struct GRid *foot_GRid;
		     IGRshort *mat_type;IGRdouble *matrix)
{
  int		pos, chan, type, status, loc_msg;
  struct GRid 	macro;

  *suc=0;
   if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
             string = ("element %d degraded doesn't return foot %s \n",
			my_id,foot_name));
    return(OM_W_ABORT);}
  
  status = om$send(msg = message ACcpx.find_macro(&macro),
		      targetid = my_id );
  as$status( action = RET_STATUS );

  status = om$send(msg= message ACcpx_defn.ACintpt_foot((IGRint *)suc,foot_name,
					&chan,&pos, &type),
		      targetid = macro.objid ,targetos = macro.osnum);
  as$status( action = RET_STATUS );

  if(*suc!=1)return(1);
  if(chan == feet_in_graphic || chan == feet_numeric)
  {
    status = om$get_objid_at_index( objid 	= my_id,
                                  p_chanselect	= &AC_mto_graf_chns,
                                  index 	= pos,
                                  objidaddr 	= &(foot_GRid->objid),
				  osnumaddr 	= &(foot_GRid->osnum) );
    as$status( action = RET_STATUS );
    *suc = graphic_foot;
  }
  else
    if(chan == feet_in_template)
    {
      status = om$send(msg = message ACcpx.ACfind_exp_temp_obj((IGRint *)suc,
							 pos, foot_GRid),
		       targetid = my_id);
      as$status( action = RET_STATUS );
    }

  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&loc_msg,matrix);

  return(1);
}

/* ========================================================================= */

method ACgive_path(int *suc;struct GRid *go_obj;char *footname)
{
  int 			status;
  struct GRid 		mac_def,rgo;
  struct GRid		target;
  OMuint 		size,i,j;
  int 			feet_num;
  GRclassid 		target_cl;
  struct myfeet 	*feet;
  char			term,dum[80];

  footname[0]=0;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


  status =om$get_channel_count( objid 		= my_id,
				p_chanselect 	= &AC_mto_graf_chns,
				count 		= &size );
  for(i=0;i<size;i++)
  {
    status = om$get_objid_at_index (	objid 		= my_id,
                                  	p_chanselect 	= &AC_mto_graf_chns,
                                  	index		= i,
                                  	objidaddr	= &(target.objid),
				  	osnumaddr	= &(target.osnum));
    as$status( action = RET_STATUS );

    om$get_classid( objid 	= target.objid,
		    osnum 	= target.osnum,
		    p_classid 	= &target_cl );

    if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ACpretgo_class_id) == OM_S_SUCCESS)
    {
      status=om$send( msg = message  ACpretgo.ACgive_info(&rgo),
      		    targetid = target.objid,targetos=target.osnum);
      as$status();
    }
    else
    {
      rgo.objid = target.objid;
      rgo.osnum = target.osnum;
    }
    if(IF_EQ_OBJID(go_obj->objid,rgo.objid)) {*suc=1;term=0;break;}
  }

  if(*suc==1)
  {
    status = om$send( msg = message ACcpx_defn.ACgive_feet_desc
		   (&feet_num, &feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status();
    sprintf(dum,"%d",i);
    for(j=0;j<feet_num;j++)
    {
      if(feet[j].pos==i && feet[j].chan==feet_in_graphic)
      {
        strcpy(dum,feet[j].name);break;
      } 
    }
    dum[strlen(dum)+1]=0;
    dum[strlen(dum)]=term;
    strcat(dum,footname);
    strcpy(footname,dum);
  }
  return(1);
}

/* ========================================================================= */
extern IGRboolean ASbroadcast_in_progress;

execute_ci1( 	entry_point, mdenv, ci_mac_my_id, ci_mac_my_os,
		 matrix_type, matrix, 
		ci_macro_id, my_state, my_internal_buffer)
char 			*entry_point;
struct GRmd_env		*mdenv;
OM_S_OBJID 		ci_mac_my_id;
GRspacenum		ci_mac_my_os;
IGRshort 		*matrix_type;
IGRmatrix		matrix;
struct GRid		*ci_macro_id;
char			my_state, *my_internal_buffer;
/*. execute_ci */
{
  IGRint             	status, msg, i ,rc,
			ci_entry_point_flag, me_flag,
			ret_code;

  struct ci_mac_st 	*p_desc;
  IGRint		temp_feet_num, intern_feet_num, extern_feet_num;
  struct GRid		MY_GRID;
  OM_S_OBJID		sav_md_id_ci_macro;
  IGRboolean 		save_br;
  struct GRid mac_def;

  rc=0;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
		    senderid = ci_mac_my_id,
		    targetid = ci_mac_my_id,
		    targetos = ci_mac_my_os);

  as$status(action = RET_STATUS);
  

/*"entry point %s def %d %d\n",entry_point,mac_def.objid,mac_def.osnum */
  status = om$send ( msg = message ci_mac_def.ACgive_cim_desc( &msg, &p_desc,
			&temp_feet_num, &intern_feet_num, &extern_feet_num),
		       senderid = ci_mac_my_id,
                       targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status ( action = RET_STATUS );
  MY_GRID.objid = ci_mac_my_id; MY_GRID.osnum = ci_mac_my_os;

  if(   (!strcmp("_dat_cmpx",p_desc->ci_name))
     || (!strcmp("_dat_elem",p_desc->ci_name)) )
   { 
      return(0); 
   }

  status =ci$load ( 	file_name = p_desc->ci_name,
			file_id = &(ci_macro_id->objid),
			/* load = DUP, */
                        load = LOAD,
		      	sender_id = ci_mac_my_id );

  /*" status %d ci_macro_id->objid = %d", status, ci_macro_id->objid */
  ci_macro_id->osnum =   OM_Gw_TransOSnum_0;

  if(!(status&1))
  {
    printf(" unable to load %s\n", p_desc->ci_name );
    return(0);
  }
  
  /* we check that the entry point exist */
  status = om$send( msg = message ci.is_entry_point( &ci_entry_point_flag,
						     entry_point ),
		    senderid = ci_mac_my_id,
            	    targetid = ci_macro_id->objid, 
		    targetos = OM_Gw_TransOSnum_0);
  as$status ( action = GOTO_VALUE, value = CLEAN_CLONE_LABEL );

  /*"ci_entry_point_flag %d\n", ci_entry_point_flag  */
  if( ci_entry_point_flag != CI_S_SUCCESS )    {rc=0;goto CLEAN_CLONE_LABEL;}

  status = om$send( msg = message ci.set_value 
	    	  (&msg, "CI_MACRO_ID",(char *) &MY_GRID, sizeof(struct GRid) ),
		    senderid = ci_mac_my_id,
            	    targetid = ci_macro_id->objid , 
		    targetos = OM_Gw_TransOSnum_0);
  as$status ( );

  status = om$send( msg = message ci.set_value 
		(&msg, "MOD_ENV", (char *) mdenv, sizeof(struct GRmd_env)),
		    senderid = ci_mac_my_id,
            	    targetid = ci_macro_id->objid , 
		    targetos = OM_Gw_TransOSnum_0);
  as$status ( );

  {
    struct stemp 	*temp_defn;
    int			template_num;
    struct GRid		template_GRid;
    struct ret_struct  	template_ret_struct;
    char 		ci_template_ret_struct[macro_MAX_CHAR + 12];
    char 		ci_template_GRid[macro_MAX_CHAR + 6];
  
    /*| setting the objid and ret struct of the template of a ci_macro */
    status = om$send( msg = message ACcpx_defn.ACgive_temp_desc( &template_num,
							    &temp_defn ),
		      senderid = ci_mac_my_id,
	      	        targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status( action = GOTO_VALUE, value = CLEAN_CLONE_LABEL );

    template_GRid.osnum = OM_Gw_current_OS;

    for(i=0; i<template_num; i++)
    {
      strcpy(ci_template_ret_struct, temp_defn[i].name);
      strcat(ci_template_ret_struct, "_ret_struct");
      strcpy(ci_template_GRid, temp_defn[i].name);
      strcat(ci_template_GRid, "_GRid");

      status = om$send( msg = message  ACcpx.ACfind_exp_temp_obj( &status, 
						i, &template_GRid),
			senderid = ci_mac_my_id,
			targetos = ci_mac_my_os,
             		targetid = ci_mac_my_id );

      status = om$send( msg = message ci.set_value (&msg, ci_template_GRid, 
				(char * )&template_GRid, sizeof(struct GRid) ),
			senderid = ci_mac_my_id,
            	        targetid = ci_macro_id->objid , 
		    	targetos = OM_Gw_TransOSnum_0);

      status = om$send( msg = message ACcpx.ACfind_exp_temp_struct(&status, i,
				                 &template_ret_struct, mdenv ),
			senderid = ci_mac_my_id,
			targetos = ci_mac_my_os,
       			targetid = ci_mac_my_id );

      status = om$send( msg = message ci.set_value ( &msg, 
			ci_template_ret_struct, (char *) &template_ret_struct,
		        sizeof(struct ret_struct) ),
			senderid = ci_mac_my_id,
            	        targetid = ci_macro_id->objid , 
		    	targetos = OM_Gw_TransOSnum_0);
    }
  }

  if((p_desc->int_size>0))
  {  
    status = om$send( msg = message ci.set_value ( &msg,"me" , 
			(char *) &my_internal_buffer, sizeof(char *) ),
		      senderid = ci_mac_my_id,
            	      targetid = ci_macro_id->objid , 
		      targetos = OM_Gw_TransOSnum_0);
    as$status ( action = GOTO_VALUE, value = CLEAN_CLONE_LABEL );
    if(msg==CI_S_SUCCESS)
      me_flag=1;
    else 
    {
      me_flag=0;
      status = om$send( msg = message ci.set_value ( &msg, p_desc->int_name, 
			my_internal_buffer, p_desc->int_size ),
		      senderid = ci_mac_my_id,
            	      targetid = ci_macro_id->objid , 
		      targetos = OM_Gw_TransOSnum_0);
      as$status ( action = GOTO_VALUE, value = CLEAN_CLONE_LABEL );
    }
  }

  /*| copy the matrix_type and matrix in the ci */
  if(   (!strcmp(entry_point, "GRxform")) && 
	(matrix_type!=NULL) && (matrix!=NULL) )
  {
    status = om$send( msg = message ci.set_value 
	   	     (&msg, "MATRIX_TYPE",(char *) matrix_type, sizeof(IGRshort) ),
		     senderid = ci_mac_my_id,
	    	     targetid = ci_macro_id->objid , 
		     targetos = OM_Gw_TransOSnum_0);
    if(msg!=CI_S_SUCCESS)
      printf("for GRxform MATRIX_TYPE should be declared\n" );

    status = om$send( msg = message ci.set_value 
	   	     (&msg, "MATRIX", (char *) matrix, 16*sizeof(double) ),
		     senderid = ci_mac_my_id,
	    	     targetid = ci_macro_id->objid , 
		     targetos = OM_Gw_TransOSnum_0);
    if(msg!=CI_S_SUCCESS)
      printf("for GRxform MATRIX_TYPE should be declared\n" );
  }
  sav_md_id_ci_macro = md_id_pour_ci_macro ;
  md_id_pour_ci_macro = mdenv->md_id.objid;
  save_br=ASbroadcast_in_progress;
  ASbroadcast_in_progress=TRUE;


  status =ci$run (  file_id = &(ci_macro_id->objid),
	      	    entry   = entry_point,
		    retsize = sizeof(int),
		    retval  = &ret_code,
		    sender_id = ci_mac_my_id );

  /*" ret_code %d \n", ret_code */

  ASbroadcast_in_progress =save_br;
  md_id_pour_ci_macro = sav_md_id_ci_macro;

  if (!strcmp(entry_point, "place") && !(ret_code&1)) 
  {
    /*" failure %d \n", ret_code */


    printf("failure in PPL file %s entry_point %s\n",
	    p_desc->ci_name,entry_point);

    status = om$send( msg    = message Root.delete(0),
		    senderid = ci_mac_my_id,
	    	    targetid = ci_mac_my_id,
		    targetos = OM_Gw_current_OS);

    as$status( );
    goto CLEAN_CLONE_LABEL;
  }


  if((p_desc->int_size>0) && (!me_flag) )
  {
    status = om$send( msg = message ci.get_value 
	   	     ( &msg, p_desc->int_name, my_internal_buffer, 
			p_desc->int_size),
		      senderid = ci_mac_my_id,
	    	      targetid = ci_macro_id->objid, 
		      targetos = OM_Gw_TransOSnum_0 );
    as$status( msg = "ci_macro.NDs_compute_node->ci.get_value" );
  }

  rc=1;

CLEAN_CLONE_LABEL:

  /*| delete the clone */
/*
  status = om$send( msg = message Root.delete(0),
		    senderid = ci_mac_my_id,
	    	    targetid = ci_macro_id->objid,
		    targetos = OM_Gw_TransOSnum_0 );
  as$status( msg = "ci_macro.NDs_compute_node->ci.get_value" );
*/

  return(rc);
}

/* ========================================================================= */

build_point( POINT, md_env)
struct GRid *POINT;
struct GRmd_env *md_env;
{
  double 		split_pts[6], knots[4], weights[1];
  struct IGRdisplay   	dis;
  struct GRvg_construct cst;
  int			i, status;
  long			msg;
  struct IGRbsp_curve   bsp_curve;

  knots[0] = 0.;
  knots[1] = 0.;
  knots[2] = 1.;
  knots[3] = 1.;
  for(i=0;i<6;i++) split_pts[i] = 0.;

  bsp_curve.order          = 2;
  bsp_curve.periodic       = 0;
  bsp_curve.non_uniform    = 0;
  bsp_curve.num_poles      = 2;
  bsp_curve.poles          = split_pts;
  bsp_curve.num_knots      = 4;
  bsp_curve.knots          = knots;
  bsp_curve.rational       = 0;
  bsp_curve.weights        = weights;
  bsp_curve.planar         = 1;
  bsp_curve.phy_closed     = 0;
  bsp_curve.num_boundaries = 0;
  bsp_curve.bdrys          = 0;

/*  dis.rgb_value      = 0;  -pcw 06/10/91 */
  dis.color          = 5;
  dis.weight         = 0;
  dis.style          = 0;

  cst.msg            = &msg;
  cst.properties     = 0; 	/* not displayable,  not locatable */
  cst.display        = &dis;
  cst.env_info       = md_env;
  cst.newflag        = 0;
  cst.level          = 1;
  cst.geometry       = (char *) &bsp_curve;  /* &poly_geom; */
  cst.class_attr     = 0;
  cst.name           = 0;

  status = om$construct(classname =  "GR3dpoint",
		    msg = message GRgraphics.GRconstruct( &cst ),
	  	    p_objid = &(POINT->objid));
  as$status( action = RET_STATUS );

  POINT->osnum=OM_Gw_current_OS;     
 return 1;
}

end implementation ci_macro;

