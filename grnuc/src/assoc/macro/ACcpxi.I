/*
  ACcpxi.I
  robert patience
  21_jul_86
*/
class implementation ACcpx;

#define AS_DEBUG

extern char *regcmp();
extern char *regex();
extern char *strpbrk();

#include "ASmacroi.h"

#include <limits.h>
#include "macro.h"
#include "acmacros.h"
#include "grownerdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "grownmacros.h"
#include "grerr.h"
#include "acrepdef.h"

extern GRclassid OPP_ACtmp_defn_class_id;

from ACcpx_defn import 	ACintpt_foot, 
			ACgive_name, ACgive_temp_desc, ACgive_feet_desc,
			ACreturn_real_def;


from ci 	import 	f_execute;
from ACroot 	import 	ACmplace;
from ACmacro_defn import ACgive_upscan;
#if 0
from ACsym        import ACunmap_fr_defn;
#endif
from ACncpx      import ACget_rep;
/* ========================================================================= */

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  char 	*macro_name;
  int	status;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
		    targetid = my_id);
  if(status&1) status = om$send(
			 msg = message ACcpx_defn.ACgive_name ( &macro_name ),
                         targetid=mac_def.objid,
			 targetos=mac_def.osnum);
  *msg = 1;
  if(status&1)
   {
    strcpy( info->type, "CPX-" );
    strcat( info->type, macro_name );
   }
  else
   {
    strcpy( info->type, "CPX" );
   }
  
  return( OM_S_SUCCESS );
}

/* ========================================================================= */

method find_macro(struct GRid *macro)
{
 int status;
 GRclassid obj_class;
 extern GRclassid OPP_ACmacro_defn_class_id;

/*"find_macro entry with mac_def %d %d\n",me->mac_def.objid,me->mac_def.osnum*/

/* Before 1.3.1 the osnum of the macro definion was not set to 0 when the
   occurence was connected to a temporary macro definition created in the
   same object space than the occurence.
   Thus testing the osnum is not enought to know if the defeninition is the real
   one,or a temporary one with a wrong osnum.
*/


/* Is the occurence already linked to the real macro definition */

  status = OM_W_ABORT;

  if(me->mac_def.osnum != 0) 
   {
    status = om$is_objid_valid( objid = me->mac_def.objid,
				osnum = me->mac_def.osnum);

    if(status&1) status = om$get_classid(p_classid = &obj_class,
			    		 objid = me->mac_def.objid,
			    		 osnum = me->mac_def.osnum);

    if(status&1 &&
       om$is_ancestry_valid(superclassid = OPP_ACmacro_defn_class_id,
			    subclassid = obj_class) == OM_S_SUCCESS)
      {
       *macro = me->mac_def;
       status = OM_S_SUCCESS; 
      }
     else if(status&1 &&
       om$is_ancestry_valid(superclassid = OPP_ACtmp_defn_class_id,
			    subclassid = obj_class) == OM_S_SUCCESS)
      {
       status = om$send(msg = message ACcpx_defn.ACreturn_real_def(macro,NULL),
		        targetid = me->mac_def.objid,
		        targetos = me->mac_def.osnum);
      }
     else
      {
       status = OM_W_ABORT;
      }
   }


/*The ouccurence is linked to a temporary macro definition. Finf the real one*/

  if(!(status&1))
   {
    status = om$send(msg = message ACcpx_defn.ACreturn_real_def(macro,NULL),
		     targetid = me->mac_def.objid,
		     targetos = OM_Gw_current_OS);
    if(status&1)
     {
      me->mac_def = *macro;

      /* Dirty repair job for 1.2 macros */
      as$status(test = (me->STATE & sym_rtn_built),
           string =("WARNING ACcpx %d was saved with sym_rtn_build set",my_id));
      me->STATE &= (~sym_rtn_built);

     }
    else
     {
      macro->objid = NULL_OBJID;
     }
   }
/*"find_macro exit macro %d %d\n",macro->objid,macro->osnum*/
  return(status);
} 

/* ========================================================================= */

method ACload_macro(struct GRid macro)
{
 /*"macro %d %d\n",macro.objid,macro.osnum */

  if(macro.osnum == 0) me->mac_def.osnum = 0;

  else me->mac_def = macro;

  return(1);
} 
/* ========================================================================= */

method ACattach(int *suc;char *macro_name)
{
  struct GRid 	macro;
  IGRint 	status;

  *suc=0;

  macro.objid = NULL_OBJID;
  macro.osnum = OM_Gw_current_OS;
  status = 1;

  status = ac$find_macro_defn( action		= ACfind_load,
		      	       macro_name 	= macro_name,
		      	       p_macro_defn_id 	= &macro );

  if (!(status&1)) return (1);

  /*"macro %d %d \n", macro.objid, macro.osnum */


  me->mac_def=macro;
  *suc=1;
  return(1);
}


/* ========================================================================= */

method ACfind_temp_obj   (int *suc;char *name;    struct GRid *temp_obj)
{
  int 		temp_num, status,i;
  struct stemp 	*dtemp;
  struct GRid mac_def;


  *suc=0; 
  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACcpx_defn.ACgive_temp_desc(&temp_num,&dtemp),
		    targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  for(i=0;i<temp_num;i++)
  {
    if(!strcmp(name,dtemp[i].name))
    {
      status = om$send(msg = message ACcpx.ACfind_exp_temp_obj(suc,i,temp_obj),
		     targetid = my_id);
      as$status( action = RET_STATUS );
      return(1);
    }
  }
  return(1);
}

/* ========================================================================= */

method ACfind_exp_temp_obj(int *suc,pos; struct GRid *foot_obj)
{
  OMuword	osn;
  OM_S_OBJID 	hdr;
  int 		temp_num, status;
  struct stemp 	*dtemp;
  struct GRid mac_def;
  int index;
  int rep;

  *suc=0; hdr = NULL_OBJID;
  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);



  
  status = om$send( msg = message ACcpx_defn.ACgive_temp_desc(&temp_num,&dtemp),
		    targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

 
  /* JLA SUPPORT OR REPRESENTATION IN NESTING 26-APR */
  status = om$send(msg = message ACncpx.ACget_rep(&rep),
		   targetid = my_id);
  if(status != OM_S_SUCCESS) rep = 0;

  index = dtemp[pos].back;
  if(rep & (AC_DEP_REP|AC_FREE_REP)) { index--; /*| index modify */ }
  if(index<0)  { return (1);}

  om$get_objid_at_index( objid 		= my_id, 
			 p_chanselect 	= &AC_template_chns,
			 index 		= index,
			 osnumaddr 	= &osn, 
			 objidaddr 	= &hdr); 
  if(IF_NULL_OBJID(hdr)) return(1);

  if('.'==dtemp[pos].down_scan[0])
  {
    foot_obj->objid = hdr;
    foot_obj->osnum = osn;
    *suc=1;
  }
  else
  {
    status = om$send(msg = message ACcpx.ACgive_foot(suc, 
						dtemp[pos].down_scan, foot_obj),
        	     targetid = hdr);
    as$status( action = RET_STATUS );
  }
  return(1);
}

/* ========================================================================= */

method ACfind_temp_struct(int *suc;char *name;struct ret_struct  *ptr_rst;
			  struct GRmd_env *md_env)
{
  int 			temp_num, status,i;
  struct stemp 		*dtemp;
  struct GRid mac_def;

  *suc=0; 

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACcpx_defn.ACgive_temp_desc(&temp_num,&dtemp),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  for(i=0;i<temp_num;i++)
  {
    if(!strcmp(name,dtemp[i].name))
    {
      status = om$send(msg = message ACcpx.ACfind_exp_temp_struct(suc,i,
							ptr_rst, md_env),
		     targetid = my_id );
      as$status(action = RET_STATUS );
      return(1);
    }
  }
  return(1);
}

/* ========================================================================= */

method ACfind_exp_temp_struct(int *suc,pos;
		struct ret_struct  *ptr_rst;struct GRmd_env *md_env )
{
  OMuword	osn;
  OM_S_OBJID 	hdr;
  int 		temp_num, status;
  struct stemp 	*dtemp;
  struct GRid mac_def;
  int index;
  int rep;

  *suc=0;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACcpx_defn.ACgive_temp_desc(&temp_num,&dtemp),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  /* JLA SUPPORT OR REPRESENTATION IN NESTING 26-APR */

  status = om$send(msg = message ACncpx.ACget_rep(&rep),
		   targetid = my_id);
  if(!(status&1)) rep = 0;

  index = dtemp[pos].back;
  if(rep & (AC_DEP_REP|AC_FREE_REP)) { index--; /*| index modify */ }
  if(index<0)  
   { ptr_rst->type = double_type;
     ptr_rst->var.root_pm_st.value = me->xform_chan;
     *suc = 1;
     return OM_S_SUCCESS;
   }

  om$get_objid_at_index( objid 		= my_id, 
			 p_chanselect 	= &AC_template_chns,
			 index 		= index,
			 osnumaddr 	= &osn,
			 objidaddr 	= &hdr); 
  if(IF_NULL_OBJID(hdr)) return(1);

  if('.'==dtemp[pos].down_scan[0])
  {
    /*" ask non cpx temp %d \n",dtemp[pos].back*/
    status = om$send(msg = message NDnode.NDgive_structure((IGRlong *)suc,  
						ptr_rst,md_env),
		     targetid = hdr);
    as$status( action = RET_STATUS );
    *suc=1;
  }
  else
  {
    /*" ask temp %d for %s \n",dtemp[pos].back,dtemp[pos].down_scan*/
    status = om$send(msg = message ACcpx.ACgive_structure (suc,
					&(dtemp[pos].direct_index),
					dtemp[pos].down_scan,ptr_rst,md_env),
		     targetid = hdr);
    as$status( action = RET_STATUS );
  }
  return(1);
}

/* ========================================================================= */

method ACdrop( struct GRmd_env *md_env)
{
  int 			status;
  struct GRid 		src_grid;
  long 			msg;
  int 			size;

  status = om$send( msg = message NDnodein.ACin_macro_def( &size ),
		    targetid = my_id );
  as$status( action = RET_STATUS );

  if(size!=0)
   {printf("delete of nested macro before owner\n");
    return(0);}

  status=om$send( msg = message NDnode.NDmove_to_root(&msg,&src_grid, md_env),
                    p_chanselect = &ND_children);
  as$status(action = RET_STATUS);
  if((me->STATE & sym_rtn_built ))
  {
    status = om$send(msg = message ACcpx.ACfree_rtn_str(), 
		     targetid = my_id );
    as$status(action = RET_STATUS );
  }
  status = om$send( mode = OM_e_wrt_message,  
		    msg = message GRowner.GRdrop(&msg, md_env), 
		     targetid = my_id );
  as$status(action = RET_STATUS );
  return(1);
}

/* ========================================================================= */

method  ACbuild_rtn_str(struct GRmd_env *md_env; int cn_type )
{
  int 		status,msg;
  struct GRid 	*tlist;
  int 		size;
  struct GRmd_env rd_env;
 
  tlist = NULL;

  if((me->STATE & sym_rtn_built))
  {
    /*|ACcpx build has built return_str: => OK upward */
    return(1);
  }

  status = om$send( msg = message NDnodein.ACin_macro_def( &size ),
		    targetid = my_id );
  as$status( action = RET_STATUS );

  if(size!=0)
   {printf("Building nest macros\n");
    }

/*
   Modif jla 06-June-1990 : The ret_struct must be build in the units of
   the ACcpx file and not using some transformation matrix when the ACcpx
   is in a reference file
*/


  ex$get_modid( mod_osnum = OM_Gw_current_OS,
                mod_id    = &rd_env.md_id.objid);
  rd_env.md_id.osnum = OM_Gw_current_OS;
  rd_env.md_env.matrix_type = MAIDMX;
  MAidmx(&msg,rd_env.md_env.matrix);


  status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_template_chns,
				count = (OMuint *)&size );
  as$status( action = RET_STATUS );

  if(size)
  {
    tlist = (struct GRid *) om$malloc( size = (size) * sizeof( struct GRid ));
    if(tlist == NULL){ return(0); }
    ACmagic_read(my_id, &AC_template_chns, tlist, size);
  }


  status = om$send( msg = message ACcpx.ACtbuild_rtn_str( size,tlist),
                    targetid =my_id);
  as$status();

  status = om$send(msg = message NDnode.NDcompute_node((IGRlong *)&msg,cn_type,
							size,tlist,&rd_env),
		   targetid = my_id);
  as$status( action = RET_STATUS );


  if(size)
    om$dealloc(ptr=tlist);
  return(1);
}

/* ========================================================================= */

method  ACtbuild_rtn_str (IGRint tsize; struct GRid *list)
{
  int 			feet_num, i, status;
  struct ret_struct  	*y;
  struct myfeet 	*feet;
  char 			*bptr;
  int 			bsize;
  GRclassid             par_classid;
  struct GRid mac_def;
  /*| send ACtbuild_rtn_str up the graph */

  if((me->STATE & sym_rtn_built))
  {
    /*|ACcpx build has built return_str: => OK upward */
    return(1);
  }

  for(i=0; i<tsize;i++)
  {
     /* there must be a better way */ 
    status = om$get_classid(osnum = list[i].osnum,objid = list[i].objid,
		  	   p_classid = &par_classid);
    as$status(action = RET_STATUS);

      if((om$is_ancestry_valid(subclassid = par_classid,
                      superclassid = OPP_ACcpx_class_id)==OM_S_SUCCESS))
       {
       /*"  ACcpx.ACbuild_rtn_str to %d\n", list[i].objid */
       status = om$send( msg = message  ACcpx.ACbuild_rtn_str(0, ND_COMP ),
		    targetid=list[i].objid);
       as$status( action = RET_STATUS ); 
       }
  }

  /* prepare my returned structures */

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc(&feet_num, &feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  me->rtstr=0;
  if(feet_num)
   {
   bsize=0;  
   for(i=0; i<feet_num; i++)
    {
    if ((feet[i].chan==feet_virtual) ) 
     {
     bsize += ASgive_size_st(feet[i].prop);
     }
    else if ((feet[i].chan==feet_in_template) ) 
     {
     bsize += ASgive_size_st(feet[i].prop);
     }
    }
   me->rtstr= (struct ret_struct **)
		om$malloc (size = (feet_num+1) *  sizeof(y));
   bptr=om$malloc ( size = bsize);
   me->rtstr[0]= (struct ret_struct *) bptr;
   me->rtstr +=1;
   for(i=0;i<feet_num;i++)
       me->rtstr[i]=0;
   /* one allocate for all return struct */
  
   for(i=0;i<feet_num;i++)
    {
    if(feet[i].chan==feet_virtual)
     {
      me->rtstr[i]= (struct ret_struct *) bptr;
      bptr += ASgive_size_st(feet[i].prop);
      /*"allcoate at %d pos %d \n",me->rtstr[i],i */
     }
    else if(feet[i].chan==feet_in_template)
     {
      me->rtstr[i]= (struct ret_struct *) bptr;
      bptr += ASgive_size_st(feet[i].prop);
      /*"temp foot at %d pos %d \n",me->rtstr[i],i */
     }
    }
   }
  me->STATE= me->STATE | sym_rtn_built;
  return(1);
}

/* ========================================================================= */

method  ACfree_rtn_str()
{
  struct myfeet 	*feet;
  int 			feet_num, status;
  struct GRid mac_def;

  if(!(me->STATE & sym_rtn_built))
  {
    printf("ACcpx free freed returned strct \n");
    return(0);
  }

  me->STATE &= (~sym_rtn_built);

  if(me->state & ND_DEGRADED) return(1);

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc(&feet_num, &feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  if(feet_num)
   {
    me->rtstr -=1;
    om$dealloc(ptr=me->rtstr[0]);
    om$dealloc(ptr=me->rtstr);
   }

  return(1);
}

/* ========================================================================= */

method  ACload_temp_feet(int tsize;struct GRid *tlist;struct GRmd_env *md_env)
{
  int 			feet_num,temp_num,i,status;
  long 			suc;
  struct myfeet 	*feet;
  struct stemp 	*dtemp;
  struct GRid mac_def;

  if(me->rtstr)
   {
   status = om$send(msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
   as$status(action = RET_STATUS);

   status = om$send(msg = message ACcpx_defn.ACgive_feet_desc(&feet_num,&feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
   as$status( action = RET_STATUS );
   status = om$send(msg = message ACcpx_defn.ACgive_temp_desc(&temp_num,&dtemp),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
   as$status( action = RET_STATUS );

   /* ??? this loop should be avoided */   
   for(i=0;i<feet_num;i++)
    {
	/*"Foot #%d\n", i */
    if(feet[i].chan==feet_in_template)    
       {
        /*"temp foot at %d \n",me->rtstr[i]*/
 	 if('.'==dtemp[feet[i].pos].down_scan[0])
	  {
    	/*"give_str to %d, %d\n", tlist[dtemp[feet[i].pos].back].osnum, tlist[dtemp[feet[i].pos].back].objid */
	    status = om$send(msg = message NDnode.NDgive_structure(&suc,  
						me->rtstr[i],md_env),
		     targetid = tlist[dtemp[feet[i].pos].back].objid );
	    as$status( action = RET_STATUS );
	  }
	  else
	  {
	    status = om$send(msg = message ACcpx.ACgive_structure ((IGRint *)&suc,
					&(dtemp[feet[i].pos].direct_index),
			dtemp[feet[i].pos].down_scan,me->rtstr[i],md_env),
		     targetid = tlist[dtemp[feet[i].pos].back].objid);
	    as$status( action = RET_STATUS );
	  }
       }
    
    }
   } 

  return(1);
}

 
/* ========================================================================= */
method ACfind_go(int bf_size,*count; struct GRid **gos_GRid)
{
int status,i;
OMuint size;
struct GRid target,*prt_GRid;
extern GRclassid 	OPP_GRgraphics_class_id;
GRclassid 		target_cl;

  status =om$get_channel_count( objid = my_id,
				  p_chanselect = &AC_mto_graf_chns,
				  count = &size );
  for(i=0;i<size;i++)
  {
    status = om$get_objid_at_index (	objid 		= my_id,
                                  	p_chanselect 	= &AC_mto_graf_chns,
                                  	index		= i,
                                  	objidaddr	= &(target.objid),
				  	osnumaddr	= &(target.osnum));
    as$status( action = RET_STATUS );
    om$get_classid(objid=target.objid,osnum=target.osnum,
				p_classid = &target_cl);
    if(om$is_ancestry_valid(subclassid =target_cl ,
                           superclassid = OPP_ACcpx_class_id) == OM_S_SUCCESS)
    {
      status = om$send(msg = message ACcpx.ACfind_go(bf_size,count,gos_GRid),
			targetid = target.objid,targetos=target.osnum);
      as$status( );

    }
    else if(om$is_ancestry_valid(subclassid =target_cl ,
                       superclassid = OPP_GRgraphics_class_id) == OM_S_SUCCESS)
    {
     prt_GRid=*gos_GRid;
     prt_GRid[*count]=target;
     /*"loading %d at %d \n",target.objid,*count */
     *count= *count+1;
      
    }
  }


  return(1);
}

/* ========================================================================= */

/* not well done upscan must be in cpx_defn */
method ASpossible_parent( IGRint ifrom, ito, *geom_code, *option_code,
                   *index_track, *index_ref, *index_plan, *nb_return, *nb_tot )
{
  IGRint 	i, j;
  int 		totup,prop,status;
  struct sup 	*xup;
  struct GRid mac_def;
 
  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACmacro_defn.ACgive_upscan
			(&totup,&prop,&xup),
		   targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  *nb_tot = totup;
  if( ifrom < 0 ) ifrom = 0;
  if( ito  < ifrom ) { *nb_return = 0; return(OM_S_SUCCESS); }
  if( ito  > *nb_tot - 1 ) ito = *nb_tot - 1;
  *nb_return = ito - ifrom + 1;
 
  for( i = ifrom, j = 0; i <= ito ; i++, j++ )
  {
/* jla 20-avril-90    geom_code[j]=xup[i].type; */
    geom_code[j]= ~0;
    option_code[j]=1;
  }

  /*  track point or ref ? */
   
  *index_ref   = -1;  /* no ref.        */
  *index_track = -1;  /* no track point */
  *index_plan  = -1;  /* no plane       */        

  return(OM_S_SUCCESS);
}
/* ========================================================================= */

method NDgive_structure ( IGRlong *msg;struct ret_struct  *ptr_rst;
			  struct GRmd_env *md_env )
/* this method is used to enquire about this root parameter */
{
  char		*macro_name;
  int 		status;
  struct GRid mac_def;

  ptr_rst->type = macro_generic;
  ptr_rst->var.macro_st.hdr_type =ACtcomplex;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  if(status&1)
  status = om$send( msg = message ACcpx_defn.ACgive_name(&macro_name),
                      targetid=mac_def.objid,targetos=mac_def.osnum);
  if(status&1)
   {
    strcpy(ptr_rst->var.macro_st.name , macro_name);
    *msg = MSSUCC;
   }
  else
   {
    ptr_rst->var.macro_st.name[0]  = '\0';
    *msg = MSFAIL;
   }

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method NDcopy ( IGRlong *msg;IGRint cp_type;
		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid )
{
  struct GRid 	macro;
  IGRint 	status;

/*
   MODIF jla 30-June-89 create super object in target directory before
   anything else
*/

  if(OM_Gw_current_OS != to_env->md_id.osnum)
  {
   OM_S_OBJID mod_id,super_id;
   /* Doesn't use md_id.objid in argument because of dynamics */

   status = ex$get_modid(mod_osnum = to_env->md_id.osnum,
                         mod_id    = &mod_id);
   if(status&1) status = ex$get_super(mod_id = mod_id,
                                      mod_osnum = to_env->md_id.osnum,
                                      super_name = "super_para",
                                      create = TRUE,
                                      super_class = "super_para",
                                      super_id = &super_id);
   as$status();
  }


  if ( me->STATE & sym_rtn_built )
  {
    status = om$send(msg = message ACcpx.ACfree_rtn_str(),
		     targetid = my_id);
    as$status( action = RET_STATUS );
  }


/*
   make sure the macro is connected to its real definition before
   performing the copy 
*/

   status = om$send(msg = message ACcpx.find_macro(&macro),
                    targetid =  my_id);
   as$status();


  status = om$send( mode = OM_e_wrt_message,  
		    msg = message ASnode.NDcopy( msg, cp_type,  fr_env, 
							to_env,newobjid ), 
		    targetid = my_id );
  as$status( action = RET_STATUS );

  /*" old os %d new os %d \n",fr_env->md_id.osnum,to_env->md_id.osnum */
  /*" copy %d %d\n",  newobjid->objid,newobjid->osnum */
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method NDcopy_to_root(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *md_env,*new_info;
  			 struct GRid *newobjid )
{
  int 			size, status,suc;
  long 			msg;
  struct GRid  		*ogrp_objs,*ngrp_objs;
  struct myfeet 	*feet;
  int 			feet_num, i;
  struct ret_struct 	*ft;
  struct GRid		mygrid;
  extern GRclassid	OPP_ACroot_class_id;
  int			cn_type;
  IGRlong actmsg;
  struct GRid active_owner;
  struct GRid mac_def;

  /* to have acc happy */ 

  ogrp_objs = ngrp_objs = NULL;
  ft = NULL;


  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
              string =("element %d not copied because degraded state\n",my_id));
    return(OM_W_ABORT);}


  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc(&feet_num, &feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

  status =om$get_channel_count( objid = my_id,
				p_chanselect =&AC_mto_graf_chns,
				count = (OMuint *)&size );
  as$status( action = RET_STATUS );

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);


  if (feet_num) 
  {
    ft = (struct ret_struct *)
	om$malloc( size =( feet_num*sizeof( struct ret_struct)));
    if(ft == NULL) return (OM_W_ABORT );
  }
  
  if(size)
  {
    ogrp_objs=(struct GRid *) om$malloc(size = (size * sizeof(struct GRid)));
    ngrp_objs=(struct GRid *) om$malloc(size = (size * sizeof(struct GRid)));
  }
    
  if(!(me->STATE & sym_rtn_built))
  {
    cn_type = ND_COMP;
    status = om$send(msg = message ACcpx.ACbuild_rtn_str(md_env, cn_type),
		     targetid = my_id);
    as$status( action = GOTO_VALUE, value = CLEAN_MALLOC );
  }

  if(size)
  {
   ACmagic_read(my_id, &AC_mto_graf_chns,ogrp_objs,size);
   for(i=0;i<size;i++)
   {
    status = om$send(msg =  message GRgraphics.GRcopy	( &msg, md_env,
					new_info, &(ngrp_objs[i].objid) ),
                       targetid = ogrp_objs[i].objid);
    as$status( action = GOTO_VALUE, value = CLEAN_MALLOC );
    ngrp_objs[i].osnum=new_info->md_id.osnum;
   }
  }  

  for(i=0;i<feet_num;i++)
  {
    if((feet[i].chan == feet_virtual)||(feet[i].chan == feet_in_template))
    {
      ft[i]=*(me->rtstr[i]);
    }
  }
  newobjid->osnum=new_info->md_id.osnum;

  status = om$construct( classid = OPP_ACroot_class_id, 
	p_objid = &(newobjid->objid ),osnum=newobjid->osnum);
  as$status(action = GOTO_VALUE, value = CLEAN_MALLOC );

  status = om$send(msg = message ACcpx.ACload_macro(mac_def),
		   targetid = newobjid->objid,
		   targetos = newobjid->osnum); 
  as$status( action = GOTO_VALUE, value = CLEAN_MALLOC );
  
  

  status = om$send(msg = message ACroot.ACmplace(&suc,0,NULL,
					size,ngrp_objs,	feet_num,ft,md_env),
		   targetid = newobjid->objid,targetos = newobjid->osnum );  
  as$status( action = GOTO_VALUE, value = CLEAN_MALLOC );

CLEAN_MALLOC:
  if(size) 
  { 
    om$dealloc( ptr = ngrp_objs); 
    om$dealloc( ptr = ogrp_objs);
  }

  if(feet_num) om$dealloc (ptr = ft);

  if(actmsg == MSSUCC) gr$put_active_owner
				    ( msg=&actmsg,active_owner=&active_owner);

/*"%d %d --> %d %d\n",my_id,OM_Gw_current_OS,newobjid->objid,newobjid->osnum*/
  return(status);
}

/* ========================================================================= */

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid;
			  struct GRmd_env *md_env )
{
  int cp_type, status;
  struct GRid		mygrid;
  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

  if(me->state & ND_DEGRADED)
    {
    *src_grid=mygrid;
    return(1);
    }

  cp_type=0;
  status = om$send(msg = message ACcpx.NDcopy_to_root(msg,  cp_type, 
  			  			md_env, md_env, src_grid),
		   targetid = my_id );
  as$status( action = RET_STATUS );

/* dirty ??? */
#if 0
  status = om$send(msg = message ACsym.ACunmap_fr_defn(),
                    		p_chanselect = &ND_children);
#endif
                    		
  status = om$send(msg = message Root.move_chan( ND_children,my_id,
				OM_Gw_current_OS, ND_children),
		   targetid = src_grid->objid );
  as$status( action = RET_STATUS );

  {
    char 	cpx_name[DI_PATH_MAX];
    int		index, ret_index, nb_syn, rc, rm_syn;

    rc = di$untranslate ( objid   	= my_id, 
			  ptr 		= &nb_syn );

/*" rc %d nb_syn %d \n",rc,nb_syn */
    if(!(rc&1)) nb_syn = 0;

       for(index=0; index<nb_syn; index++)
       {
         /* always get name at index 0 because the array of names is collapsed*/
         /* by the following remove name                                      */

         rc = di$untranslate ( objid   	= my_id, 
 			       objname 	= cpx_name,
			       index 	= 0,
			       p_index 	= &ret_index,
			       ptr	= &rm_syn );
         if(!(rc&1))
           {
	    di$report_error(sts = rc);
	    continue;
           }

         /*" name %s\n",cpx_name */

         rc = di$rm_name (   regexp 	= cpx_name );
         if(!(rc&1))
           {
	    di$report_error(sts = rc);
	    continue;
           }
         rc = di$add_name (  objid   	= src_grid->objid, 
			     objname 	= cpx_name );
         if(!(rc&1))
           {
	    di$report_error(sts = rc);
           }
        }
  }
  status = om$send( mode = OM_e_wrt_message,  
		    msg = message ACcpx.NDdelete(md_env), 
		    targetid = my_id );
  as$status(action = RET_STATUS );

  return(1);
}

/* ========================================================================= */

method NDprint_root(struct GRmd_env *md_env; FILE *stream)
{
  OMuint              	i,j;
  long 			status;
  int 			msg;
  char                	name[macro_MAX_CHAR], *macro_name;
  struct myfeet 	*feet;
  int 			feet_num,*iptr;
  struct ret_struct     rts;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACcpx_defn.ACgive_name(&macro_name),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc(&feet_num, &feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  as$printer_set_name( prefix = "MACRO_ROOT", name = name);
  if (strcmp(name,"")!=0)
  {
    for(i=0;i<feet_num;i=i+1)
    {
      j=(OMuint)~0;
      status = om$send(msg = message ACcpx.ACgive_structure(&msg,(int *)&j,
						feet[i].name,&rts,md_env),
		     targetid = my_id );
      as$status( action = RET_STATUS );

      fprintf(stream,"	rst[%d].type=%#x; \n",i,rts.type);
      iptr=(int *) &(rts.var.dbg_st);
      for(j=0;j<(ASgive_size_st(rts.type)/4) +1;j++)
      {
        if(j<44)
          fprintf(stream,"	  rst[%d].junk[%d]= %#x; \n",i,j,iptr[j]);
      }
    }
    fprintf(stream,
	    "send ACroot.ACplace(&suc,0,\"%s\",0,0,%d,rst) to %s;\n"
	    ,macro_name,feet_num,name);
  }
  return(1);
}
 
/* ========================================================================= */

method NDdelete ( struct GRmd_env *md_env )
{
  int 	status;

  if(me->STATE & sym_rtn_built)
  {
    status = om$send(msg = message ACcpx.ACfree_rtn_str(),
  		     targetid = my_id );
    as$status( action = RET_STATUS );
  }
  status = om$send( mode = OM_e_wrt_message,  
		    msg = message ASnode.NDdelete( md_env ), 
		    targetid = my_id );
  as$status( action = RET_STATUS );
  di$rm_objid ( objid = my_id );
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
  *msg = MSSUCC;
  *properties = GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
	/*	GR_LC_CMP_READ 	   |     */
/* To test change color on a macro component  jla 06-oct-89 */
	  	GR_LC_CMP_READ 	   | GR_LC_CMP_WRITE |
		GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
		GR_LC_RIGID;
 
  return(OM_S_SUCCESS);
}

/* ========================================================================= */

method GRgetsymb(IGRlong *msg; struct GRsymbology *symb)
{
    IGRlong           om_msg;
    int i;


    *msg = MSFAIL;
    for(i=0;i<OM_K_MAXINT;i++)
     {
      om_msg = om$send(msg = message GRvg.GRgetsymb (msg, symb),
                     p_chanselect = &AC_mto_graf_chns,
                     from = i,
                     to = i);

      if(om_msg != OM_W_UNKNOWN_MSG)
      {
 /* MACRO OCCURENCE RETURNS LAYER OF ITS FIRST COMPONENT              */
 /* Temporary fixes for Proctor and Gamble that will become standart  */
 /* behaviour in 2.0                                 jla  16-may-91   */
 /*      if(om_msg & *msg & 1) *msg = GR_I_NO_LAYER;    */
 /*      else *msg = MSFAIL;                            */
       break;
      }
     }
    return (om_msg);
}



method NDctl_parent_type(long *msg;int type; char *info)
{
 char *macro_name;
 long status;
 struct GRid mac_def;

/* Is a macro required ? */

 *msg = MSFAIL;
 if(!(type&macro_generic)) return OM_S_SUCCESS;

/* Do we have to control its type */

 if(info == NULL || (info[0] == '*' && info[1] == '\0') || info[0] == '\0') 
  { *msg = MSSUCC; return OM_S_SUCCESS;}

 status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);

 if(status&1) status = om$send(
                         msg = message ACcpx_defn.ACgive_name ( &macro_name ),
                         targetid=mac_def.objid,
                         targetos=mac_def.osnum);
 if(ASmatchRE(info,macro_name)) *msg = MSSUCC;
 else 				*msg = MSFAIL;
 

 return OM_S_SUCCESS;
}

method NDget_parent_type(long *msg;int *type; char *info)
{
 char *macro_name;
 long status;
 struct GRid mac_def;

 *msg = MSFAIL;
 status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
 as$status(action = RET_STATUS);

 if(status&1) status = om$send(
                         msg = message ACcpx_defn.ACgive_name ( &macro_name ),
                         targetid=mac_def.objid,
                         targetos=mac_def.osnum);
 as$status(action = RET_STATUS);
 strncpy(info,macro_name,macro_MAX_CHAR);
 *type = macro_generic;
 info[macro_MAX_CHAR-1] = '\0';
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

/* ======================= MSG GRcopy () ==============================	*/

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
			struct GRmd_env *new_dsenv; GRobjid *newobjid )

{
IGRlong		sts;
IGRint		cp_type=0;
struct	GRid	my_new_id;
IGRshort	props, action;
IGRlong		loc_msg;

	*msg	= MSSUCC;
	sts = om$send(	msg	 = message NDnode.NDcopy_to_root(
					msg,
					cp_type,
					obj_dsenv,
					new_dsenv,
					&my_new_id ),
			targetid = my_id );
	as$status( sts = sts );
	as$status( sts = *msg );
	*newobjid	= my_new_id.objid;
	/*" newobjid : %d\n", *newobjid */

	if( ! ( sts & *msg & 1 ) )	return	sts;

	/*| remove GR_RIGID_RELATIONSHIP property for copy */
	action  = 0;
	props	= GR_RIGID_RELATIONSHIP;
	om$send(	msg	 = message GRgraphics.GRchgprops
					( &loc_msg, &action, &props ),
			targetid = my_new_id.objid,
			targetos = my_new_id.osnum );

return	sts;
}

end implementation ACcpx;
