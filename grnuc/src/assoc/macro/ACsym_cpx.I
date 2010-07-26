/*
  ACsym_cpx.I
  robert patience
  21_jul_86
*/
class implementation ACsym;

#include "ASmacroi.h"
#include "macro.h"

#include "lc.h"
#include "lcdef.h"
#include "asbox.h"
#include "grdpb.h"
#include "grerr.h"
#include "godef.h"
#include "grownerdef.h"

#define AS_DEBUG

extern GRclassid OPP_GRtext_class_id;

from ACmacro_defn import 	ACgive_feet_desc, 	ACgive_temp_desc,
	ACconnect_compute, 	ACunmap_hdr, 		ACgive_name,
	ACgive_inst_defn;

from ACpretgo import ACplace;


/* ========================================================================= */

struct s_inst
{
  char 		name[macro_MAX_CHAR];
  int  		num_obj;
  unsigned char inst_sz,state;
  char 		xform_chan, xform_pos;
};

method ACput_s_inst(int *size;char *inst_buf)
{
  char 			*macro_name;
  int 			status,suc;
  struct s_inst 	*n_inst;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  n_inst	= ((struct s_inst *) &(inst_buf[*size]));

  status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  if(strcmp(macro_name,n_inst->name))
  {

    if((me->STATE & sym_rtn_built ))
    {
      status = om$send(msg = message ACcpx.ACfree_rtn_str(),
		       targetid = my_id );
      as$status( action = RET_STATUS );
    }

    /*" attaching macro %s\n",n_inst->name */

    status = om$send(msg = message ACsym.ACattach(&suc,n_inst->name),
		     targetid = my_id );
    as$status( action = RET_STATUS );

    status = om$send( msg = message ACcpx.find_macro(&mac_def),
                      targetid = my_id);
    as$status(action = RET_STATUS);
  }
  
  me->go_sz=n_inst->num_obj;

  me->xform_chan=n_inst->xform_chan;me->xform_pos=n_inst->xform_pos;

  me->STATE&=(~sym_in_macro);if(n_inst->state & 1)me->STATE |= (sym_in_macro);

  me->inst_sz=n_inst->inst_sz + ((n_inst->state >> 1)<< 8) ;

  *size 	+=  sizeof(struct s_inst) ;
  
  *size 	+=  me->inst_sz ;

/*
  for(i=0;i<me->inst_sz;i++)
  {
    me->inst_save[i]=inst_buf[ (*size)++];
  }
*/
return(1);
}

method ACget_s_inst(int *size;char *inst_buf)
{
  char 			*macro_name;
  int 			status, i;
  struct s_inst 	*o_inst;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  o_inst=((struct s_inst *) &(inst_buf[*size]));

  status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  strcpy(o_inst->name,macro_name);


  o_inst->num_obj=me->go_sz;

  o_inst->xform_chan = me->xform_chan;o_inst->xform_pos  = me->xform_pos;

  o_inst->inst_sz 	= (0377 & me->inst_sz);
  o_inst->state 	= (me->inst_sz >> 8) << 1; /*kludge because of ch size*/
  /*" size %d  \n",me->inst_sz */

  if(me->STATE & sym_in_macro) o_inst->state |=1;

  *size 	+=  sizeof(struct s_inst) ;

  for(i=0;i<me->inst_sz;i++)
  {
    inst_buf[ (*size)++]=me->inst_save[i];
  }

return(1);
}
 
method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
  int 		status, i, size ,index, int_out_ch ;
  struct GRid mygrid;
  struct GRid mac_def;


  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

  if(*prop & ACinst_ch_in)
   {
   size=0;
   status = om$send(msg = message 
		   ACsym.ACput_s_inst(&size,inst_save),
		   targetid = my_id );
   as$status( action = RET_STATUS );
   index=*no_go;
   status = om$send(msg = message ACpretgo.ACplace(&index),
		    p_chanselect = &AS_to_comp);
      /*"  no_go index me->go %d %d %d\n",*no_go,index ,me->go_sz */
   if(me->go_sz>(index-*no_go))
    {
    OM_S_OBJID wobj;
    for(i=index-*no_go;i<me->go_sz;i++)
     {
     status = om$construct( classid = OPP_ACpretgo_class_id, 
		  	 osnum   = OM_Gw_current_OS,
		  	 p_objid = &(wobj) );
     as$status();
      /*" connect graphic %d to %d\n", wobj, my_id */
     status = om$send(msg = message Root.connect(AC_mto_graf_chns,0,
						wobj , OM_Gw_current_OS, 
						AC_mfrom_graf_chns,OM_K_MAXINT),
	             targetid = my_id);
     as$status();
     }
    index=*no_go;
    status = om$send(msg = message ACpretgo.ACplace(&index),
		    p_chanselect = &AS_to_comp);
    }
   /*
   else if(me->go_sz<(index-*no_go))
    {
    status = om$send(msg = message Root.delete(0),
		    p_chanselect = &AS_to_comp,
                    from = me->go_sz, to = (index-*no_go));
    } 
    */  
   }

  /* test return structures are made */
  if(!(me->STATE & sym_rtn_built ))
  {
    status = om$send(msg = message ACsym.ACtbuild_rtn_str( count, list),
		     targetid = my_id );
    as$status( action = RET_STATUS );
  }

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  int_out_ch =*prop;
  status = om$send(msg = message ACmacro_defn.ACconnect_compute(
				msg,cn_type,count,mygrid,list, 
				me->rtstr, md_env,
		&int_out_ch,&(me->inst_sz),&inst_save[sizeof(struct s_inst)]),
		targetid=mac_def.objid,targetos=mac_def.osnum);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACcpx.ACload_temp_feet(count,list, md_env),
	     	      targetid = my_id);
  as$status( action = RET_STATUS );

/*
  size=0;
  status = om$send(msg = message 
		   ACsym.ACget_s_inst(&size,inst_save),
		   targetid = my_id );
  as$status( action = RET_STATUS );
*/

  *size_inst += sizeof(struct s_inst)+me->inst_sz;
  if (!( (me->state) & ND_OUT_OF_RT) )
    {*no_go += me->go_sz;}


  return ( OM_S_SUCCESS  );
}

/* ========================================================================= */

method  ACmap_from_visible(OM_S_OBJID **plist;int *obj_buf_sz,*count;
		int *sz_inst_save,*inst_buf_sz;char **pinst_save)
{
  int 			status, size,siz_inst;
  char 			*inst_save;

  /*"ACsym.ACmap_from_visible count %d sz_inst %d\n", *count, *sz_inst_save */

  siz_inst	= sizeof(struct s_inst);
  inst_save = *pinst_save;

  if((*sz_inst_save+siz_inst+om$dimension_of(varray=ME.ACsym->inst_save))
	>= *inst_buf_sz - 1)
  {
    *inst_buf_sz= *inst_buf_sz + siz_inst +
	om$dimension_of(varray=ME.ACsym->inst_save)+100;
    /*"change buffer size %d for %d \n", *inst_buf_sz, *sz_inst_save+siz_inst */
    inst_save= (char*)realloc(inst_save,*inst_buf_sz);
    *pinst_save=inst_save;
  }

  status = om$get_channel_count(	objid 		= my_id,
		       		p_chanselect 	= &AS_to_comp,
				count 		= (OMuint *)&(me->go_sz) );
  as$status( msg ="ACsym.map_fromvis count objs" );

  size=0;
  status = om$send(msg = message 
		   ACsym.ACget_s_inst(&size,&(inst_save[*sz_inst_save])),
		   targetid = my_id );
  as$status( action = RET_STATUS );
  *sz_inst_save += size;

  me->state|=ND_DIS_BY_CH;
  status = om$send( mode = OM_e_wrt_message,  
		    msg = message ASnode.ACmap_from_visible(plist,obj_buf_sz,
					count, sz_inst_save,inst_buf_sz,
					pinst_save),
		    targetid = my_id ) ;
  as$status( action = RET_STATUS );
  me->state &= (~ND_DIS_BY_CH);

  /*"ACsym.ACmap_frvis exit count %d sz_inst %d\n", *count, *sz_inst_save */

  return (  OM_S_SUCCESS );
}

/* ========================================================================= */
method ACcon_s_inst(int *size;char *inst_buf;int dpsize,obsize;
		    char *dpbuf,*macro_name)
{
  int 			i;
  struct s_inst 	*o_inst;
  o_inst=((struct s_inst *) &(inst_buf[*size]));
  strcpy(o_inst->name,macro_name);


  o_inst->num_obj=obsize;
  o_inst->xform_chan = 0;o_inst->xform_pos  = 0;

  o_inst->inst_sz 	= (0377 & dpsize);
  o_inst->state 	= (dpsize >> 8) << 1; /*kludge because of ch size*/
  /*" size %d  \n",dpsize */

  o_inst->state |=1;

  *size 	+=  sizeof(struct s_inst) ;

  for(i=0;i<dpsize;i++)
  {
    inst_buf[ (*size)++]=dpbuf[i];
  }
return(1);
}

/* ========================================================================= */

method ACbecome_macro ( IGRlong *msg; IGRint position; struct GRmd_env *md_env)
{
  me->STATE |= (sym_in_macro);
  *msg = ND_DROP_MAC | ND_CONS_MAC | ND_SYMB_MAC;
  return ( OM_S_SUCCESS );
}


/* ========================================================================= */

method NDchange_connect( IGRint nb_root; struct GRid *old_root, *new_root)

{
 IGRlong status;
 struct GRid mygrid;
 struct GRid mac_def;

 status = om$send( msg = message ACcpx.find_macro(&mac_def),
                   targetid = my_id);
 as$status(action = RET_STATUS);


 mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

 status = om$send( msg = message ACmacro_defn.ACunmap_hdr(mygrid),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
 as$status(action = RET_STATUS);
 
 status = om$send(msg = message ACcpx.NDchange_connect
		 (nb_root,old_root,new_root),		  
		  targetid = my_id,
	 	  mode = OM_e_wrt_message);
 as$status();

 return (status);
}



end implementation ACsym;
