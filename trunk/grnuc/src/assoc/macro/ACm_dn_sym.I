 /*
  ACm_dn_sym.I
  robert patience
  21_jul_86
*/
class implementation ACmacro_defn;

#include "ASmacroi.h"
#include "macro.h"
#include "batch.h"

#define AS_DEBUG


from GRlinear import GRputpolyline;
from ACpretgo import ACplace;
from ACpretdef import ACsconnect;
from ACpretgo   import XYsleep,ACset_def;

#define XFORM_OBJ 1
#define XFORM_SYM 2
#define NOT_XFORM 4

extern char *strpbrk();

struct Bcomp{struct GRid grid;int size;struct GRid *list;};

/* ========================================================================= */

method ACmap_test(struct GRid  sym;int *mapped) 
{
  if( (!IF_EQ_OBJID(sym.objid,me->symbol_macro.objid)) ||
      (sym.osnum != me->symbol_macro.osnum )            )
  { 
    /*" %d is NOT mapped, mapped is %d\n",sym.objid,me->symbol_macro.objid */
    *mapped=0;
  }
  else
  {
    /*" %d is mapped\n",sym.objid */
    *mapped=1;
    if(me->prop&ACsym_computed) *mapped=2;
  }
  return(OM_S_SUCCESS);
}

/* ========================================================================= */
method ACfind_pretgo(int *count;struct GRid **slist)
{
long status,loc_msg;
struct 		GRid *list,*glist;
int             i,j,wcount,scount;
GRclassid       go_classid;
OM_S_OBJID      *other;

 status = om$send(msg = message ACcomplex.ACget_other
					(&loc_msg, &me->tot_assoc ,&other),
		  targetid = my_id);
 as$status(action = RET_STATUS);
  
  *count=0;
  if(!me->tot_assoc) return(1);
/*??? only one pass  please */

  for(i=0;i<me->tot_assoc;i++)
    {
    wcount=0;
    status =om$get_channel_count( objid = other[i],
				p_chanselect = &AC_mto_graf_chns,
				count = (OMuint *)&(wcount));
    if(wcount)
     {
     glist= (struct GRid *)
 	  om$malloc (size = (wcount) * sizeof( struct GRid ));
     ACmagic_read(other[i], &AC_mto_graf_chns,glist,wcount );
    /*" wcount %d \n", wcount */
     for(j=0;j<wcount;j++)
      {
      status = om$get_classid(osnum = glist[j].osnum,objid = glist[j].objid,
		  	   p_classid = &go_classid);
      as$status(action = RET_STATUS);

      if((om$is_ancestry_valid(subclassid = go_classid,
                      superclassid = OPP_ACpretgo_class_id)==OM_S_SUCCESS))
       {
       *count +=1;
       }
      }
     om$dealloc( ptr =glist );
     }
   }

  /*" hit %d \n", *count */
  list= (struct GRid *)
 	  om$malloc (size = (*count) * sizeof( struct GRid ));
  *slist=list;
  scount=0;
  for(i=0;i<me->tot_assoc;i++)
   {
   wcount=0;
   status =om$get_channel_count( objid = other[i],
				p_chanselect = &AC_mto_graf_chns,
				count = (OMuint *)&(wcount));
    if(wcount)
     {
     glist= (struct GRid *)
 	  om$malloc (size = (wcount) * sizeof( struct GRid ));
     ACmagic_read(other[i], &AC_mto_graf_chns,glist,wcount );
     for(j=0;j<wcount;j++)
      {
      status = om$get_classid(osnum = glist[j].osnum,objid = glist[j].objid,
		  	   p_classid = &go_classid);
      as$status(action = RET_STATUS);

      if((om$is_ancestry_valid(subclassid = go_classid,
                      superclassid = OPP_ACpretgo_class_id)==OM_S_SUCCESS))
       {
       list[scount++]=glist[j];
       }
      }
     om$dealloc( ptr =glist );
     }
   }
     

 return(OM_S_SUCCESS);
}

/* ========================================================================= */
method ACmap_to_hdr(struct GRid  sym;struct GRid *list) 
{
int 		i, count, size,status,index;
struct 		GRid *slist;

   if(!(me->prop&ACpret_index_built))
   {
/*   printf("Only for translation \n");*/
     {
     int cntt;cntt=0;
     status = om$send ( 	
		msg = message ACpretdef.ACsconnect(me->xdtemp, &cntt), 
		p_chanselect = &AC_template_chns );
     as$status ( );
     }
   status = om$send(msg = message ACmacro_defn.ACfind_pretgo(&count,&slist),
			targetid=my_id);
   as$status ( );
   index=0;
   for(i=0;i<count;i++)
    {
   /*" 		indexing - %d \n",slist[i].objid   */
    status = om$send(msg = message ACpretgo.ACplace(&index),
		    	     targetid = slist[i].objid);
    as$status();
    }
   if(count)  om$dealloc( ptr =slist );
   me->prop |= ACpret_index_built;   
   }

   {
   if(!me->map_struct)
     {
     slist = (struct GRid *)
 	  om$malloc (size = (me->tot_up) * sizeof( struct GRid ));
     me->map_struct=(char *) slist;
     }

   slist=(struct GRid  *) me->map_struct;
   /*" pointer %d \n", me->map_struct */
   for(i=0;i<me->tot_up;i++)
    {
    slist[i]=list[i];
   /*" 		loading - %d \n",slist[i].objid   */
    }
   }
    
  if(!( me->prop&ACcant_place_sym))
   {
   status =om$get_channel_count( objid = sym.objid,
				osnum = sym.osnum,
				p_chanselect = &AS_to_comp,
				count = (OMuint *)&size );
   as$status( action = RET_STATUS );

   if(size) 
    {
    if(!me->go_struct)
    {
      /*" allocate go_struct for %d \n", size  */
      slist = (struct GRid *)
 	  om$malloc (size = (size+10) * sizeof( struct GRid ));
          /* dim based assumption */
      me->go_struct = (char *) slist;
    }

    slist=(struct GRid  *) me->go_struct;
    ACread(sym, &AS_to_comp, slist,size );
    /*" pointer %d size %d\n", me->go_struct,size */

    for(i=0;i<size;i++)
     {
     /*" 		loaded - %d \n",slist[i].objid   */
     }
    }
   }

  me->symbol_macro=sym;
  me->prop &= (~ACsym_computed);

  return(OM_S_SUCCESS);
}


/* ========================================================================= */

method ACunmap_hdr(struct GRid  sym) 
{
  /*" %d is NOT mapped, mapped is %d\n",sym.objid,me->symbol_macro.objid */

  if( (IF_EQ_OBJID(sym.objid,me->symbol_macro.objid)) &&
      (sym.osnum == me->symbol_macro.osnum )            )
  {
  me->symbol_macro.objid=NULL_OBJID;
  me->prop &= (~ACsym_computed);
  }

  return(OM_S_SUCCESS);
}

/* ========================================================================= */

method  ACfind_map(struct GRid **ptr)
{
  *ptr=(struct GRid *)me->map_struct;
  return(1);
}
/* ========================================================================= */

method  ACfind_go(struct GRid **ptr)
{
  *ptr=(struct GRid *)me->go_struct;
  return(1);
}

/* ========================================================================= */
method ACbuild_comp()
{
struct Bcomp *BB;
OM_S_OBJID *other;
int i;
long status,loc_msg;


  status = om$send(msg = message ACcomplex.ACget_other
					(&loc_msg,&me->tot_assoc,&other),
		   targetid = my_id);
  as$status(action = RET_STATUS);

    if(!me->tot_assoc)return(1);

/*??? only one malloc please */
    BB =  (struct Bcomp *)
 	  om$malloc (size =(me->tot_assoc)*sizeof( struct Bcomp ));

    for(i=0;i<me->tot_assoc;i++)
     {
     BB[i].grid.objid=other[i];
     status =om$get_channel_count( objid = other[i],
				p_chanselect = &AC_template_chns,
				count = (OMuint *)&(BB[i].size));
     BB[i].list = (struct GRid *)
 	  om$malloc (size = (BB[i].size) * sizeof( struct GRid ));
     ACmagic_read(other[i], &AC_template_chns,BB[i].list,BB[i].size );
     }
    me->comp_struct=(char *)BB;

return(1);
} 

/* ========================================================================= */
/* The comand object to clean up files with corrupted Dimension must know when
/* the recompute fails. There are case where we return success even after a
/* failure of the recompute. I don't want to change it now --> use of the
/* following global variable. It is up to the caller to initialize its value
/* JLA 08-Jun-90 
/* ========================================================================= */

/* ========================================================================= */

method ACconnect_compute(IGRlong *msg;IGRint cn_type,tempsz;
		struct GRid  sym;struct GRid *list;
		struct ret_struct *rtstr[]; struct GRmd_env *md_env ;
		int *int_out_ch,*size_inst;char *inst_save) 
{
  int 			status, i;
  int			no_go,size,tot_size,no_go_save,size_save;
  int 	        	el_cn_type;
  struct GRid   	sym_grid;
  int 			continue_xform;
  struct NDxf_info 	*xf_info;
  struct Bcomp 		*BB;

  

  /*" Macro_name %s\n",me->macro_name */
  /*" ND_COMP_XF %d , cn_type %d\n",ND_COMP_XF,cn_type */
  /*" module object space  %d \n", md_env->md_id.osnum*/

  if(!me->comp_struct)
     {
     status = om$send(msg = message ACmacro_defn.ACbuild_comp(),
  		   targetid = my_id); 
     as$status( action =RET_STATUS );
     }


  if( (!IF_EQ_OBJID(sym.objid,me->symbol_macro.objid)) ||
      (sym.osnum != me->symbol_macro.osnum )            )
    {
     status = om$send(msg = message ACmacro_defn.ACmap_to_hdr(sym,list),
  		   targetid = my_id); 
     as$status( action =RET_STATUS );
    }

  if(!(me->prop&ACsym_computed))
    {
     me->prop |= ACsym_computed;
     *int_out_ch |= ACinst_ch_in;
    }

  no_go=0;
  tot_size=0;
  BB=(struct Bcomp *)me->comp_struct;

 if(me->tot_up!= tempsz)
 {
   printf("Macro %d %d name %s lost template\n me->tot_up = %d tempsz = %d \n",
	   sym.objid,sym.osnum, me->macro_name,me->tot_up,tempsz);
 }
 else
 {
    for(i=0;i<me->tot_assoc;i++)
     {
     size=0;

     status = om$send(msg =  message NDmacro.ACcompute_node 
				(msg, el_cn_type,
				BB[i].size,BB[i].list,md_env,
			        int_out_ch,&size,&no_go,&(inst_save[tot_size])),
  		   targetid =BB[i].grid.objid );

  /*"size %d object %d \n ", size,BB[i].grid.objid*/
     tot_size += size; 
     as$status( );
     }
  if(tot_size != *size_inst)
   printf("%d %d type %s FATAL mapping problems inst size = %d, ret size =%d\n",
		sym.objid,sym.osnum,me->macro_name,*size_inst,tot_size);
 }

  for(i=0;i<me->feet_num;i++)
  {
  if(me->myfeet[i].chan == feet_virtual &&
  (!(( me->myfeet[i].prop & macro_generic)&&(! *int_out_ch & ACinst_ch_in)))) 
/*
    if(me->myfeet[i].chan == feet_virtual )
 */
    {

      status = om$send(msg = message NDnode.NDgive_structure(msg, 
				(struct ret_struct *)rtstr[i],
				md_env),
		       targetid = BB[me->myfeet[i].pos].grid.objid );
      as$status( action = RET_STATUS );
    }
  }

  return(OM_S_SUCCESS);
}

/* ========================================================================= */

method ACgive_inst_defn(int *size;char **int_save)
{
  *size=me->sz_inst_save;
  *int_save=(me->inst_save); 
  return(OM_S_SUCCESS);
}

/* ========================================================================= */

method ACsym_init()
{
  OM_S_OBJID 	*list,*other;
  int 		count, i, status,cur_objn,cur_inst;
  char 		*inst_save;
  int		nb_other;
  long loc_msg;

  cur_objn=10;
  cur_inst=100;

  inst_save	= om$malloc(size=cur_inst);
  list		= (OM_S_OBJID *) om$malloc(size=cur_objn *sizeof(OM_S_OBJID)); 
 
  /*| disconnect graphic objs */
  status = om$send( msg = message Root.wild_disconnect( AC_mto_graf_chns ),
 	   	    targetid = my_id );
  as$status( action = RET_STATUS );

  me->symbol_macro.objid=my_id;

  count=0;
  me->sz_inst_save=0;
  /*| map from visible on other objects */

  status = om$send(msg = message ACcomplex.ACget_other
						    (&loc_msg,&nb_other,&other),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  for( i=0; i<nb_other; i++ ){
	status = om$send( msg = message NDmacro.ACmap_from_visible
		(&list,&cur_objn,&count,&(me->sz_inst_save),
					&cur_inst,&inst_save),
			targetid = other[i] );
	as$status( action = RET_STATUS );
  }

  /*" map_from_visible objcnt %d size inst %d\n", count, me->sz_inst_save */

  status = om$vla_set_dimension(varray= me->inst_save,
                             size = me->sz_inst_save );
  as$status( msg =  "macro.place vla inst_save" );

  /*| fill val */
  OM_BLOCK_MOVE( inst_save , me->inst_save ,me->sz_inst_save);

  {
    OM_S_OBJID wobj;
    IGRlong flag;
    struct GRid mygrid;
    int index;
    flag=1;
    mygrid.osnum=OM_Gw_current_OS;
    mygrid.objid=my_id;
    index=0;
    for(i=0;i<count;i++)
    {
      /*" create pretgo  %d \n", list[i] */
    status = om$construct( classid = OPP_ACpretgo_class_id, 
		  	 osnum   = OM_Gw_current_OS,
		  	 p_objid = &(wobj) );
    as$status();
    status= om$send( msg = message Root.move_chan(AS_to_owner,
	  			list[i], OM_Gw_current_OS,AS_to_owner),
		     senderid = wobj,
  	             targetid = wobj  );
    as$status();
    status= om$send( msg = message Root.move_chan(AS_notification,
	  			list[i], OM_Gw_current_OS,AS_notification),
		     senderid = wobj,
  	             targetid = wobj  );
    as$status();
      /*" connect graphic %d to %d\n", list[i], my_id */

    status = om$send(msg = message Root.connect( AC_mfrom_graf_chns,
						OM_K_MAXINT,my_id,
		      				OM_Gw_current_OS, 
						AC_mto_graf_chns,0),
	             targetid = list[i] );
    as$status();
    status = om$send(msg = message ACpretgo.ACplace(&index),
		    	     targetid = wobj);

    status = om$send(msg = message ACpretgo.ACset_def(&mygrid),
		    	     targetid = wobj);
    as$status();
    }
  me->prop |= ACpret_index_built;
  }
  om$dealloc( ptr = list);
  om$dealloc( ptr = inst_save);

  return(OM_S_SUCCESS);
}

/* NB :
   - Freeing allocated array in the NDsleep method is WRONG because 
     objects don't receive NDsleep if their OS is not saved. It's only the
     case bellow for old type of macro which should no longer be used.
   - For the above reason, me->map_struct points to the VLAS me->inst_save
     which is reset 0 before saving. ( this vals was only used by old type 
     of macro).
*/
     


method NDsleep (struct GRmd_env *md_env)
{
struct 		Bcomp *BB;
int 		i;
int status;

   /*| free comp */
   if(me->comp_struct)
    {
    BB= (struct Bcomp *) me->comp_struct;
    for(i=0;i<me->tot_assoc;i++)
     {
     if(BB[i].list)	om$dealloc( ptr =BB[i].list  );
     }
    om$dealloc( ptr =me->comp_struct  );
    }


   /*| free map_struct */

   if(me->prop & ACcant_place_sym)
    {
     status = om$vla_set_dimension(varray = me->inst_save,
                                    size = 0);
    }

   /*| have freed all */

   me->comp_struct=0;
   me->go_struct=0;   
   me->map_struct=0;   
   me->symbol_macro.objid=NULL_OBJID;
   return(1);
}


end implementation ACmacro_defn;
