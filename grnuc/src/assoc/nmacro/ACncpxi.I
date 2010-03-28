/*
  ACncpxi.I
  robert patience
  1 sept 1989
*/
class implementation ACncpx;

#define AS_DEBUG

#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "godef.h"
#include "grownerdef.h"
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "gocmacros.h"
#include "ASmsg.h"
#include "msmacros.h"
#include <alloca.h>


from ACcpx_defn import 	ACgive_name, ACgive_temp_desc, ACgive_feet_desc;
from ACcpx_defn import 	ACintpt_foot,ACmax_graph_ft;
from ACmacro_defn import 	ACgive_upscan;
from ACpretend  import 	ACfind_parent;
from ACpretend  import 	ACrebind;
from ACconst  import 	ACget_foot_in_mac;

extern GRclassid OPP_ACpl_hold_class_id, OPP_ASsource_class_id,
		 OPP_ACpretend_class_id, OPP_expression_class_id;


/* ========================================================================= */

method  ACbuild_rtn_str(struct GRmd_env *md_env; int cn_type )
{
  return(1);
}

/* ========================================================================= */

method  ACtbuild_rtn_str (IGRint tsize; struct GRid *list)
{
  return(1);
}

/* ========================================================================= */

method  ACfree_rtn_str()
{
  return(1);
}



/* ========================================================================= */

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid; 
		      struct GRmd_env *md_env )
{
int status;
struct GRid mygrid;

/* test consumed/missing and recompute if necessary */
 if(me->STATE & ncpx_missing)
    {
    status = om$send(msg =message NDnode.NDs_compute_node(msg,ND_COMP,md_env),
		   targetid =my_id);
    as$status( );
    me->STATE &= (~ncpx_missing);
    }

 mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

 if(me->state&ND_DONT_MVRT)
   {
    /* support only --> doesn't move to root */
    nd$wait_batch(type = GR_DELETED,
                   nb_obj = 1,
                   l_object = &mygrid);
    status = OM_S_SUCCESS;
   }
 else
  {
   /* instanciate parents and disconnect from them */
   if(!(me->STATE & ncpx_root))
   status = om$send( msg = message ACncpx.ACinstanciate_template_feet
			 	     (msg,&mygrid,OM_K_MAXINT,
				      md_env->md_id.objid == NULL_OBJID ? 0 :1),
                   targetid = my_id);

   status = om$send( msg = message Root.wild_disconnect( AC_template_chns),
                    targetid    = my_id );
  }

 as$status( );
 me->STATE = (me->STATE ) | (ncpx_root);
 *src_grid=mygrid;

 return(status);
}

/* ========================================================================= */

method NDcopy(IGRlong *msg;IGRint cp_type;
	      struct GRmd_env *md_env,*new_info;
  	      struct GRid *newobjid )
{
int status,status1;

 status = om$send( msg = message ACcpx.NDcopy(msg,cp_type , 
 		   md_env,new_info,newobjid),
                   targetid = my_id  ,
		   mode = OM_e_wrt_message );
 as$status();
 if(!(status&*msg&1)) goto wrapup;

 /*
    Change serial number of my copy if I have db_info
 */

 if(me->size_buffer == -1)
  {
   /* serial number is the objid */
   status1 = om$send( msg = message ACdb_info.ACput_serial_no(newobjid->objid),
		      targetid = newobjid->objid  ,
		      targetos = newobjid->osnum);
   as$status(sts = status1);

  }

 else if(me->size_buffer > 4)
  {
   /* serial number is managed by PDU and begins at 1000 */
   status1 = om$send( msg = message ACdb_info.ACset_serial_no(),
                      targetid = newobjid->objid  ,
                      targetos = newobjid->osnum);
   as$status(sts = status1);
  }

wrapup :
 return(status);
}

method ACinstanciate_template_feet( long *msg;struct GRid *occurence;
				   int nb_to_instanciate;
				   int rtree_flag)
{
 int feet_num,nb_component,max_g_ft,nb_template_feet,i;
 struct myfeet	*feet;
 struct GRid mac_def,foot_GRid,cpy_GRid,work_obj,my_grid;
 struct GRmd_env fr_env,to_env;
 long cpos = OM_K_MAXINT;
 long loc_msg,status;

 /* Init */

  my_grid.objid = my_id; 
  my_grid.osnum = OM_Gw_current_OS; 

  MAidmx((int *)&loc_msg,to_env.md_env.matrix);
  to_env.md_env.matrix_type = MAIDMX;
  to_env.md_id.osnum = OM_Gw_current_OS;
  to_env.md_id.objid = NULL_OBJID;

  fr_env.md_id.objid = NULL_OBJID;
 

  /*
     Retrieve macro definition, feet description and the maximum number of
     real feet 
  */

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
		    targetid = my_id);
  as$status(action = RET_STATUS);

  status = om$send( msg = message ACmacro_defn.ACgive_feet_desc(
			&feet_num, &feet),
		    targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  status = om$send(msg= message ACcpx_defn.ACmax_graph_ft(&max_g_ft),
		   targetid = mac_def.objid ,targetos =mac_def.osnum);
  as$status( action = RET_STATUS );

  /* control how many feet have already been created (variable feet number or
     template feet already instanciated by ACreturn_foot) */

  status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_mto_graf_chns,
				count = (OMuint *) &nb_component );
  as$status( action = RET_STATUS );

  /* Copy now template feet and connect at the correct index */

  nb_template_feet = 0;
  for(i=0;i<nb_to_instanciate && i<feet_num;i=i+1)
   {
   if((feet[i].chan&3) == feet_in_template)
    {
    nb_template_feet++;
    if(nb_template_feet + max_g_ft <= nb_component) continue; 

    status = om$send(msg = message ACcpx.ACfind_exp_temp_obj
			((int *)&loc_msg,feet[i].pos,&foot_GRid),
		       targetid = occurence->objid,
		       targetos = occurence->osnum);
    if(!(status&loc_msg&1)) continue;

    status = om$send(msg = message NDmacro.ACreturn_foot
					(&loc_msg,"",&foot_GRid,
					 &fr_env.md_env.matrix_type,
					  fr_env.md_env.matrix),
                     targetid = foot_GRid.objid,targetos = foot_GRid.osnum );
    if(!(status&loc_msg&1)) continue;
    fr_env.md_id.osnum = foot_GRid.osnum;
    
    status = om$send( msg = message GRgraphics.GRcopy
        		    (&loc_msg,&fr_env,&to_env,&cpy_GRid.objid),
                      targetid = foot_GRid.objid,targetos = foot_GRid.osnum );
    cpy_GRid.osnum=to_env.md_id.osnum;

    if(!(status&loc_msg&1)) continue;

/* Don't want to see template feet deseapar a sleep time because support only */
    status = om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH,0),
		      targetos = cpy_GRid.osnum,
		      targetid = cpy_GRid.objid);

    /* If necessary place some pl_hold to have correct channel index */

    for(;nb_component<max_g_ft+nb_template_feet-1;nb_component++)
       {
	 ACcreate_pl_hold(&work_obj,to_env.md_id.osnum);
         status = om$send(msg = message GRconnector.GRrigidconn
		    ( &loc_msg,&my_grid,(IGRlong *)&cpos),
	             targetid=work_obj.objid,targetos=work_obj.osnum );
       }

      status = om$send(msg = message GRconnector.GRrigidconn
		    ( &loc_msg,&my_grid,&cpos),
	             targetid=cpy_GRid.objid,targetos=cpy_GRid.osnum );
      if(status&loc_msg&1) nb_component++;
    }   
   }

  /* If request, add element in the Rtree */
  if(rtree_flag)
   {
    ex$get_modid(mod_osnum = OM_Gw_current_OS,
		 mod_id = &to_env.md_id.objid);
    for(i=max_g_ft;i<nb_component;i++)
	om$send(msg = message GRgraphics.GRaddwrng(&loc_msg,&to_env),
		p_chanselect = &AC_mto_graf_chns,
		from = i, to = i);

   }
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


/* ========================================================================= */

method NDcopy_to_root(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *md_env,*new_info;
  			 struct GRid *newobjid )
{
int status;
char new_state;
struct GRid my_grid;

my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;


/* test consumed/missing and recompute if necessary */
 if(me->STATE & ncpx_missing)
    {
    status = om$send(msg =message NDnode.NDs_compute_node(msg,ND_COMP,md_env),
		   targetid =my_id);
    as$status( );
    me->STATE &= (~ncpx_missing);
    }

 status = om$send( msg = message NDnode.NDcopy(msg,cp_type, 
 		   md_env,new_info,newobjid),
                   targetid = my_id   );
 as$status(); 

 new_state = me->state & ~ND_DONT_MVRT;
 status = om$send( msg = message NDnode.NDchg_state(~0,new_state),
                   targetid = newobjid->objid, targetos = newobjid->osnum );

 status = om$send( msg = message ACncpx.ACchg_STATE(ncpx_root,ncpx_root),
                   targetid = newobjid->objid, targetos = newobjid->osnum );

/*
   Copy to root also copies the template feet to have a full root collection
   corresponding to the macro definition
*/

 status = om$send( msg = message ACncpx.ACinstanciate_template_feet
				(msg,&my_grid,OM_K_MAXINT,
				 new_info->md_id.objid == NULL_OBJID ? 0 :1),
                   targetid = newobjid->objid, targetos = newobjid->osnum );
 as$status();
 return status;
}



/* ========================================================================= */
#define path_MAX_CHAR 160

/* test if an object is a pl_hold */

int pl_hold(tst_GRid)
struct GRid tst_GRid;
{
int status;
GRclassid obj_class;
    /*" pl_hold for %d %d\n",tst_GRid.objid,tst_GRid.osnum */

    status = om$get_classid(objid=tst_GRid.objid,
		     osnum=tst_GRid.osnum,
		     p_classid=&obj_class);
    as$status();
    if(obj_class == OPP_ACpl_hold_class_id) return(1);
    else return(0);
}

/* create a pl_hold object */


ACcreate_pl_hold(work_obj,osnum)
struct GRid *work_obj;
GRspacenum osnum;
{
  long	loc_msg;
  short action = 1,    
        mask   = GRIS_LOCATABLE|GRIS_DISPLAYABLE; 

  work_obj->osnum=osnum;
  return  om$construct( classid = OPP_ACpl_hold_class_id,
			p_objid = &work_obj->objid ,
			osnum = work_obj->osnum,
			msg = message GRgraphics.GRchgprops
						(&loc_msg,&action,&mask));
}

/* ========================================================================= */
method   ACreturn_foot(IGRlong *msg;char *foot_name;     
		struct GRid *foot_GRid;IGRshort *mat_type;IGRdouble *matrix)
{
  int		pos, chan, type, status, loc_msg, i, temp_foot_pos;
  struct GRid 	macro,obj,mygrid;
  char 		*chpos; 
  char *strchr();

/*"return foot for %s\n",foot_name */

  *msg=0;
  foot_GRid->objid=NULL_OBJID;
  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;
  

  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
             string = ("element %d degraded doesn't return foot %s \n",
			my_id,foot_name));
    *msg = 0;
    return(OM_W_ABORT);}

  /*
      downscan is "." --> return for historic reason first graphic object
      connected on the component channel
  */
  
  if('.'== foot_name[0])
  {
   status = om$send(msg = message NDnodein.ACreturn_foot
		      (msg,foot_name,foot_GRid,mat_type,matrix ),
		      targetid = my_id,
		      mode = OM_e_wrt_message );
   as$status( );
   return(status);
  }

  /*  downscan is "" --> return myself  */

  else if(0== foot_name[0])
  {
   foot_GRid->osnum = OM_Gw_current_OS;  foot_GRid->objid = my_id;
   *msg = 1;
   if(mat_type) *mat_type = MAIDMX;
   if(matrix) MAidmx(&loc_msg,matrix);
   return(1);
  }

/* Find the foot corresponding to the downscan */

  status = om$send(msg = message ACcpx.find_macro(&macro),
		      targetid = my_id );
  as$status( action = RET_STATUS );

/*
   If nesting find the nested collection obj and send it the return_foot
   message
*/

  if(chpos=strchr(foot_name,':')) 
  {
    *chpos = '\0';
    status = om$send(msg =  message ACcpx.ACreturn_foot
						(msg,foot_name,&obj,NULL,NULL),
		    targetid = my_id );
    *chpos = ':';
    if(!(status&1)) *msg = 0;
    as$status(action = RET_STATUS );

    status = om$send(msg =  message ACcpx.ACreturn_foot
					(msg,chpos+1,foot_GRid,mat_type,matrix),
        	    targetid = obj.objid ,targetos = obj.osnum);
    if(!(status&1)) *msg = 0;
    return(status);
  }


/*
   There is no nesting, find the object
   - on the owner channel
   or
   - on the template channel and copy to member 
*/ 


  status = om$send(msg= message ACcpx_defn.ACintpt_foot((int *)msg,foot_name,
					&chan,&pos, &type),
		      targetid = macro.objid ,targetos = macro.osnum);
  as$status( action = RET_STATUS );

  if(!(*msg))return(1);


  if(chan == feet_in_graphic )
  {
   /*| Is it on owner channel */
   if(me->STATE & ncpx_missing)
    {
     struct GRmd_env wk_env;
     IGRlong 		S1,S2;

     /*| Recompute the consumed ACcpx */
     S1 = sizeof (struct GRmd_env);
     status = gr$get_module_env(	msg    = &loc_msg,
                    		sizbuf = &S1,
                    		buffer = &wk_env,
                    		nret   = &S2 );
     as$status(action = RET_STATUS );
     status = om$send(msg =message NDnode.NDs_compute_node
		   ((IGRlong *)&loc_msg,ND_COMP,&wk_env),targetid =my_id);
     as$status( );
     me->STATE &= (~ncpx_missing);
    }

   status = om$get_objid_at_index( objid 	= my_id,
                                  p_chanselect	= &AC_mto_graf_chns,
                                  index 	= pos,
                                  objidaddr 	= &(foot_GRid->objid),
				  osnumaddr 	= &(foot_GRid->osnum) );
   if(!(status&1) || pl_hold(*foot_GRid))
      { *msg = 0; }
   else
      { *msg = 1;
        if(mat_type) *mat_type = MAIDMX;
        if(matrix) MAidmx(&loc_msg,matrix);
      }
  }
  else if(chan == feet_in_template)
  {
   int nb_feet;
   struct myfeet *feet_desc;

   /*| If this template feet is already instanciated, returned it  */


   status = om$send(msg= message ACcpx_defn.ACgive_feet_desc
							(&nb_feet,&feet_desc),
		    targetid = macro.objid ,targetos = macro.osnum);
   as$status( action = RET_STATUS );

   pos = 0;
   temp_foot_pos = -1;
   for(i=0;i<nb_feet;i++)
     {
      if     ((feet_desc[i].chan & 3) == feet_in_graphic) pos++;
      else if((feet_desc[i].chan & 3) == feet_in_template && temp_foot_pos<0)
 	{
	 if(!strcmp(foot_name,feet_desc[i].name)) temp_foot_pos = nb_feet;
	 else pos++;
	}
     }
	  
   status = om$get_objid_at_index( objid 	= my_id,
                                  p_chanselect	= &AC_mto_graf_chns,
                                  index 	= pos,
                                  objidaddr 	= &(foot_GRid->objid),
				  osnumaddr 	= &(foot_GRid->osnum) );
   if(!(status&1))
    {

     /* Need to instanciate template feet out of the rtree */

     status = om$send(msg = message ACncpx.ACinstanciate_template_feet
				(msg,&mygrid,pos+1,0),
		      targetid = my_id);

     status = om$get_objid_at_index( objid 	= my_id,
                                  p_chanselect	= &AC_mto_graf_chns,
                                  index 	= pos,
                                  objidaddr 	= &(foot_GRid->objid),
				  osnumaddr 	= &(foot_GRid->osnum) );

    }
   if(!(status&1) || pl_hold(*foot_GRid))
      { *msg = 0; }
   else
    { *msg = 1;
      if(mat_type) *mat_type = MAIDMX;
      if(matrix) MAidmx(&loc_msg,matrix);
    }
  }

/* virtual foot -> construct pretend */

  else if(chan == feet_virtual)
    {
     /*| construct virtual foot for pretend */
     status = om$send(msg= message ACcpx.ACconnect_pretend
					((int *)msg,foot_name,foot_GRid),
                      targetid = my_id);
     as$status( action = RET_STATUS );
     if(mat_type) *mat_type = MAIDMX;
     if(matrix) MAidmx(&loc_msg,matrix);
     *msg = 1;
    }
 return(1);
}

/* ========================================================================= */

method ACgive_path(int *suc;struct GRid *go_obj;char *footname)
{
  int status,i,j,nb_template_feet;
  struct GRid mac_def;
  struct myfeet *feet;
  int feet_num,max_g_ft;

  footname[0]=0;
  *suc = 0;

/* Retrieve macro definition, feet definition, how many feet are output */

  status = om$send(msg = message ACcpx.find_macro(&mac_def),
 		     targetid = my_id );
  as$status(action = RET_STATUS );

  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc(&feet_num, &feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status();

  status = om$send(msg= message ACcpx_defn.ACmax_graph_ft(&max_g_ft),
		      targetid = mac_def.objid ,targetos =mac_def.osnum);
  as$status();

  
/* Find index of the object on the component channel */

  status = om$get_index( objid_c = my_id,
			 objid = go_obj->objid,
                         p_chanselect 	= &AC_mto_graf_chns,
                         indexaddr	=  (OMuint *) &i);
  if(!(status&1)) {return OM_S_SUCCESS;}


/* Find member name */

  nb_template_feet = 0;
  for(j=0;j<feet_num;j++)
    {
      if((feet[j].chan & 3)==feet_in_graphic && (feet[j].pos==i))
        {*suc=1; strcpy(footname,feet[j].name);break;}

      else if((feet[j].chan & 3)==feet_in_template)
	if(i==max_g_ft+nb_template_feet)
          {*suc=1; strcpy(footname,feet[j].name);break;}
 	else nb_template_feet++;
    }
  return(1);
}

/* ========================================================================= */
method ACbecome_macro(IGRlong *msg; IGRint position;
                         struct GRmd_env *md_env)
{
 *msg = ND_DROP_MAC | ND_CONS_MAC | ND_SYMB_MAC;
 return (OM_S_SUCCESS);
}


/* ========================================================================= */
  
method GRdrop(IGRlong *msg;struct  GRmd_env *md_env)
 {
  struct GRid src;
  short set,props;


  IGRlong status;
  status = om$send(msg = message NDnode.NDmove_to_root(msg,&src,md_env),
		   targetid = my_id);
  as$status();

/* remove if ncessary my bit del_no_children
   because last dependent disconnecting will change my component to
   non displayable etc
*/

 status = om$send(msg = message  NDnode.NDchg_state(ND_DEL_NO_CH,0),
                  targetid = my_id);


/*| Rebind the pretend depending on me */
  status = om$send(msg = message ACpretend.ACrebind((int *)msg,&src),
		   senderid = src.objid,
		   targetos = src.osnum,
		   p_chanselect = &ND_children); 
  as$status();

/* Disconnect my component */

  set = 0;
  props = GR_RIGID_RELATIONSHIP;
  status = om$send(msg = message GRgraphics.GRchgprops(msg,&set,&props),
                   p_chanselect = &AS_to_comp);
  as$status();
  status = om$send(msg = message Root.wild_disconnect(AS_to_comp),
		   targetid = src.objid,
		   targetos = src.osnum);
  as$status();

/* Delete my_self */
  status = nd$wait_batch(type = GR_DELETED,
			 nb_obj = 1,
			 l_object = &src);
  return(status);
 }

/* ========================================================================= */

ACcontext_compute_component(msg,other,context,new_other,md_env)
long *msg;
struct GRid *other,     /* I component to compute */
	    *context,   /* I its context          */
	    *new_other; /* O new component id if changed */
struct GRmd_env *md_env;
{
 long status,to_compute;
 struct GRid *buff,*l_anc;
 int *l_state,j,nb_anc;
 int cn_type =  ND_COMP_IN_LIB | ND_COMP_NO_ERASE   | ND_COMP_NO_REM_RT |
            ND_COMP_NO_DISPLAY | ND_COMP_NO_ADD_RT  ;
 GRclassid target_cl;
 
 
 /* get parents of the computed element */

 l_anc = NULL;
 l_state = NULL;
 nb_anc = 0;
 to_compute = om$send(msg = message NDnode.NDget_objects
		    (ND_ROOT|ND_IN_BUF,NULL,0,&buff,0,OM_K_MAXINT,&nb_anc),
		     senderid = NULL_OBJID,
		     targetid = other->objid,
		     targetos = other->osnum);
 if(nb_anc)
  {
   l_anc = (struct GRid *) alloca(nb_anc*sizeof(struct GRid));
   l_state = (int *) alloca(nb_anc*sizeof( int ));
   if(!l_anc || !l_state) {status = OM_W_ABORT; goto ERROR;}
   OM_BLOCK_MOVE(buff,l_anc,nb_anc*sizeof(struct GRid));
   for(j=0;j<nb_anc;j++) l_state[j] = ND_COMP_SUCC;
  }
 else if (to_compute)
  {
   /* Avoid to send NDupdate to root solid .... */
    om$get_classid(objid=other->objid,
                   osnum=other->osnum,
                    p_classid = &target_cl);

     if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ASnode_class_id) != OM_S_SUCCESS)
	to_compute = FALSE;
  }
 /* Recompute it */
    
 if(to_compute)
  {
   status = om$send(msg = message NDnode.NDupdate
	     ((int *)msg,cn_type,nb_anc,l_anc,l_state,context,new_other,md_env),
		     senderid = NULL_OBJID,
		     targetid = other->objid,
		     targetos = other->osnum);
   as$status();
  }
 else
  {
   status = OM_S_SUCCESS;
   *new_other = *other;
   *msg = MSSUCC;
   if(context->objid != NULL_OBJID) ACtrans_symb(*context,*other);
  }
 return status;

ERROR :
 *msg = MSFAIL; return status;
}


method ACcontext_compute_feet(int count;
			struct GRid 	context_obj;
			struct GRid 	*feet_list;
			struct GRmd_env *md_env)
{
int status;
struct GRid *tlist = NULL;
int size,i,ibis;
IGRlong msg;
struct GRid ctx_ft,mac_def;
struct myfeet *feet_desc;

   /*"count entry %d\n",count */

   size=0;
   status = OM_S_SUCCESS;
   if(!IF_EQ_OBJID(context_obj.objid,NULL_OBJID))
   {
    /* Get feet of previous occurence */
    status =om$get_channel_count( osnum =context_obj.osnum,
				 objid =context_obj.objid ,
				p_chanselect = &AC_mto_graf_chns,
				count = (OMuint *) &size );

    /* If the context has no member take the context as member of my component
       It occurs with conditional with different depth in the ownership graph:
       For a condition value, a foot is a graphic object
       For another value, this foot is a construction 
    */
    if(status&1 && size)
    {
     tlist = (struct GRid *) om$malloc (size = (size) * sizeof( struct GRid ));
     ACread(context_obj, &AC_mto_graf_chns, tlist, size);
    }
    else
    {
     size = count;
     tlist = (struct GRid *) om$malloc (size = (size) * sizeof( struct GRid ));
     for(i=0;i<count;i++) tlist[i] = context_obj; 
    }
     

    /* get feet description used if missing templates */

    status = om$send(msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
    as$status(action = RET_STATUS);

    status = om$send( msg = message ACmacro_defn.ACgive_feet_desc(
                        &ibis, &feet_desc),
                      targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status( action = RET_STATUS );

    }


   for(i=0;i<count;i++)
    {
    if(!IF_EQ_OBJID(feet_list[i].objid,NULL_OBJID))
     {
     ctx_ft.objid=NULL_OBJID;
     if(i<size)
      {
      if(!pl_hold(tlist[i])) ctx_ft=tlist[i];
      }

     /* If not found, try to find another matching template */
      if(ctx_ft.objid == NULL_OBJID && size)
	{
	 char *c;
	 int feet_name_len;

	 feet_name_len = strlen(feet_desc[i].name); 
	 c = feet_desc[i].name + feet_name_len -1;
	 while(feet_name_len > 0 && *c >= '0' && *c <= '9') 
	     {c--; feet_name_len--;}
	   
/* jla jan 93. Does not work when the new computed macro has less feet     */
/* (count) than the previous occurence (real_size) and if the instanciated */
/* feet are something like X1 X2 Y2 --> Y1				   */
/* for(ibis=0; ibis<count &&  ibis<size ; ibis++)			   */

	 for(ibis=0; ibis<size ; ibis++)
	  {
           if(i==ibis) continue;
	   if(pl_hold(tlist[ibis])) continue;
	   if(strncmp(feet_desc[i].name,feet_desc[ibis].name,feet_name_len) == 0)
	     {
/*"WARNING feet %s is context of %s\n",feet_desc[ibis].name,feet_desc[i].name*/
	      ctx_ft = tlist[ibis]; break;
	     } 
	  }
	}

       status = ACcontext_compute_component(&msg,feet_list+i,&ctx_ft,
					    feet_list+i,md_env);
       as$status( );
     }
    }

   if(size) om$dealloc(ptr = tlist);
  
  return (  status );
}

/* ========================================================================= */

method ACchange_feet(int count;
			struct GRid 	*feet_list;
			struct GRmd_env *mod_env 
			)
{
  int		status,i;
  struct GRid		graph_obj_new,work_obj,MY_GRID;
  GRclassid 		target_cl;
  IGRlong		msg;
  MY_GRID.objid = my_id; MY_GRID.osnum = OM_Gw_current_OS;

/* only to support ACncpx that dont support context management */

/* Really necessary now since I have removed the GRdelete from
   get_context_s_compute in order to not delete the default macro 
   in the macro library jla 27-03-91 */

  status = om$send (msg = message GRgraphics.GRdelete ( &msg, mod_env ), 
		     	p_chanselect = &AC_mto_graf_chns );
  as$status (  );

  for ( i=0; i<count; i++)
  {
   if(!IF_NULL_OBJID(feet_list[count-1-i].objid))
    {count=count-i;break;}
  }

  for ( i=0; i<count; i++)
  {
    work_obj=feet_list[i];
/*"foot %d %d \n", work_obj.objid,work_obj.osnum*/
    if(IF_NULL_OBJID(work_obj.objid))
    {
     status = ACcreate_pl_hold(&work_obj,OM_Gw_current_OS);
     as$status(action = RET_STATUS);
    }
    om$get_classid(objid=work_obj.objid,
		   osnum=work_obj.osnum,
		    p_classid = &target_cl);

    if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
    {
      if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS
	 ||
         om$is_ancestry_valid(subclassid =target_cl ,
                         superclassid = OPP_ACpretend_class_id) == OM_S_SUCCESS)
      {
       status = om$send( msg = message NDnode.ASreturn_go( &graph_obj_new, 
				NULL,NULL),
		  targetid = work_obj.objid ,
		  targetos = work_obj.osnum);
       as$status ( action = RET_STATUS );
       work_obj=graph_obj_new;
      }
      else
      {
       status = om$send( msg = message NDmacro.ACbecome_foot
						(&msg,&work_obj,mod_env),
                    targetid=work_obj.objid,targetos=work_obj.osnum);
       as$status( );

      }
    }

    status = om$send(msg = message GRconnector.GRrigidconn( &msg,&MY_GRID,
							    (IGRlong *)&i),
	             targetid=work_obj.objid,targetos=work_obj.osnum );
    as$status ();

   if( msg != MSSUCC ) 
    printf(" GRrigidconn msg  %x \n",msg);
  }
  return ( OM_S_SUCCESS );
}

/* ========================================================================= */

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  char 	*macro_name;
  int	status;
  struct GRid mac_def;
  int rep;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);


  if(status&1)
          status = om$send( msg = message ACcpx_defn.ACgive_name( &macro_name ),
                            targetid=mac_def.objid,targetos=mac_def.osnum);
  *msg = MSSUCC;
  if(status&1)
   {
   if((me->STATE ) & (ncpx_root))
    {
    ex$message(buff=info->type, msgnumb=AS_I_RootN);
    }
   else
    {
    ex$message(buff=info->type, msgnumb=AS_I_Const);
    }
   strcat( info->type, macro_name );
   status = om$send(msg = message ACncpx.ACget_rep(&rep),
		    targetid = my_id);
   if((status&1) && rep&(AC_FREE_REP|AC_DEP_REP))
    {
     IGRchar msg[29];
     if(rep&AC_2D_REP) {
       ex$message(buff=msg,msgnumb=AS_I_2d); 
       strcat(info->type,msg); }
    else if(rep&AC_3D_REP) {
       ex$message(buff=msg,msgnumb=AS_I_3d); 
       strcat(info->type,msg); }
    else if(rep&AC_ENV_REP) {
       ex$message(buff=msg,msgnumb=AS_I_env); 
       strcat(info->type,msg); }
    }
   }
  else
   {
    ex$message(buff=info->type,msgnumb=AS_I_ConstN);
   }
  return( OM_S_SUCCESS );
}
/* ========================================================================= */

method  ACget_STATE(int *STATE)
{
 *STATE = me->STATE;
 return(OM_S_SUCCESS);
}
method  ACchg_STATE(int mask,n_state)
{
 me->STATE = (me->state & ~mask) | (n_state&mask);
 return OM_S_SUCCESS;
}
/* ========================================================================= */
#define acfail() \
    status = om$send(msg = message ACncpx.NDdelete(&emp_env), \
		       targetid = my_id ); \
    as$status(action = RET_STATUS); \
    return(1);

method ACmplace(int *suc, prop; 	char rep;char *macro_name;
	       	int num_temp; 		struct GRid *temp_list;
		struct GRmd_env *md_env)
{
 int status;
 struct GRid def_occ;
 def_occ.objid = NULL_OBJID;
 status = om$send(msg =  message ACncpx.ACmplace_from_def(suc, prop, rep,
		             macro_name, num_temp, temp_list, &def_occ, md_env),
		  targetid = my_id);
 return status;
}

method ACmplace_from_def(int *suc, prop; 	char rep;char *macro_name;
	       	int num_temp; 		struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env)
{
  int			cn_type;
  int 			tot_up, mac_prop, status, i;
  struct sup 		*dsup;
  struct GRmd_env	emp_env;
  IGRlong		msg;
  int ideb_rep;
  int new_rep;
  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;

/*"rep is %x num_temp %d\n",rep,num_temp */

/* Remove if necessary template 0 which is representation */

  if(rep && temp_list[0].objid == NULL_OBJID)
    {
     num_temp --;
     temp_list++;
     ideb_rep = 1;
    }
  else    ideb_rep = 0;

  if(!(prop&AChdr_noprotect))
  {
    for( i=0;i<num_temp;i++ )
     {
      status = as$make_source( 	go_grid = temp_list[i],
		                as_os = temp_list[i].osnum,
		                as_grid = &temp_list[i] );
      as$status(action = RET_STATUS);
     }
  }

  status = om$send( msg = message NDnode.NDconnect( num_temp, temp_list, 
					      NULL_GRID, ND_NEW),
		    targetid = my_id);
  as$status( );

  status = om$send(msg = message ACncpx.ACattach(suc,macro_name),
		   targetid = my_id);

/* to work properly if macro lib has been removed from list of loaded lib */
  if(!(status&*suc&1) && def_occ->objid != NULL_OBJID)
  {
   status = om$send(msg = message ACcpx.find_macro(&me->mac_def),
		    targetid = def_occ->objid,
		    targetos = def_occ->osnum);
   if(status&1) *suc = 1; 
  }

  if(*suc!=1) {acfail()}

/* Verify parent representation consistency */

  if(rep&(AC_FREE_REP|AC_DEP_REP))
   {
    status = ac$compute_rep_value(initial_rep = 0,
			        p_root = temp_list,
				nb_root = num_temp,
				resulting_rep = &new_rep);

    if(new_rep&AC_ERROR_REP) return OM_W_ABORT;	       /* Inconsistent roots */
    else if(new_rep&AC_FREE_REP)rep=AC_FREE_REP | rep & ~AC_DEP_REP;
						       /*roots without rep*/
    else 			rep = new_rep;	       /* roots with rep  */
   }

  status = om$send(msg = message ACncpx.ACput_rep(rep,~0),
	           targetid = my_id);
  as$status(action = RET_STATUS);

  if(!(prop&AChdr_noprotect))
  {
    status = om$send( msg = message ACmacro_defn.ACgive_upscan(&tot_up,
					&mac_prop, &dsup),
		       targetid=me->mac_def.objid,
		       targetos=me->mac_def.osnum );
    as$status( msg = "ACncpx.ACplace->ACmacro_defn.give_desc");

    if(!(mac_prop&ACcant_place_sym))
     {
      printf("ACncpx cannot place macros prepared for symbol macro\n");
      *suc=0;{acfail()}
     }
    if(tot_up!=num_temp+ideb_rep)
    {
      printf("ACncpx.place_real bad template\n");
      *suc=0;{acfail()}
    }

    /* check valid expanded template */
    {
      struct ret_struct pardef;
      int 		tot_temp;
      struct stemp 	*dtemp;

      status = om$send( msg = message ACcpx_defn.ACgive_temp_desc
							     (&tot_temp,&dtemp),
		  targetid=me->mac_def.objid,
		  targetos=me->mac_def.osnum );
      as$status( );
      for(i=ideb_rep;i<tot_temp;i++)
      {
	int root_type;
	status = om$send(msg =  message ACcpx.ACfind_exp_temp_struct( suc, 
						  i, &pardef, md_env),
	 		 targetid = my_id );
        as$status(action = RET_STATUS);
   /*"%x found type %x expected %x suc %d \n",pardef.type,dtemp[i].type,i,*suc*/
        root_type = dtemp[i].type;
        if(root_type&other_generic) root_type |= debug_type;
        if(root_type&curve_generic) root_type |= line_generic|conic_generic;
        if(!(*suc&1) ||
            (!IS_SAME_GEOM( pardef.type,root_type)&& !(root_type==~0)))
        {
          printf( "Place macro illegal template defn for %s\n",
		dtemp[i].down_scan );
          *suc=0;
          return( 1 );
        }
      }
    }
  }

  if(prop&AChdr_nocompute)return(1);
  {
    /*| NDs_compute */
    cn_type =ND_COMP;
    status = om$send(msg = message ACncpx.ACcontext_compute
						(&msg,cn_type,
						num_temp ,temp_list,def_occ,
					        &emp_env),
		     targetid = my_id );
   as$status(action = RET_STATUS);
   
   
  }

  if(prop&AChdr_norange) return(1);
  {
    /*| addwrng */
    status = om$send(msg = message GRgraphics.GRaddwrng(&msg, md_env),
			  	p_chanselect = &AC_mto_graf_chns);
    as$status();
  }

  if(prop&AChdr_nodisplay)return(1);
  status = om$send(msg = message NDnode.NDdisplay(0,GRbd, md_env),
		     targetid = my_id );
  as$status(action = RET_STATUS);
  return(1);
}

/* ========================================================================= */

method ACmroot_place(int *suc; 		char rep,*macro_name;
		      int numb_obj;  	struct GRid  *ft_objs;
		      struct GRmd_env *md_env)
{
  int 			status;

  me->STATE = (me->STATE ) | (ncpx_root);
 
  status = om$send(msg = message ACncpx.ACattach(suc,macro_name),
		   targetid = my_id );
  as$status( action =  RET_STATUS );

  me->xform_chan = rep;

  if(*suc!=1)
  {
    status = om$send(msg = message ACncpx.NDdelete(md_env),
		     targetid = my_id );
    as$status( action =  RET_STATUS );
    return(1);
  }

  status = om$send( msg = message ACncpx.ACchange_feet(
			numb_obj,ft_objs, md_env),
	     	      targetid = my_id);
  as$status();
  return(1);
}

/* ========================================================================= */

method GRxform(IGRlong *msg; struct GRmd_env *obj_dsenv; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 int status;

  if(me->STATE & ncpx_root)  
   {
   /*| xform on to graph channel */
   status = om$send( msg = message GRvg.GRxform
		(msg,obj_dsenv,matrix_type,matrix,newobjid),
		     p_chanselect=&AC_mto_graf_chns );
   as$status( );

   status = om$send(msg = message NDnode.NDchange_node(NULL), 
		targetid = my_id);
   as$status();
   }
  else
   {
    /*| I am going to ov_ci_mac.GRxform */
    status=om$send(msg= message 
		ACcpx.GRxform(msg,obj_dsenv,matrix_type,matrix,newobjid),
		targetid=my_id,
                mode = OM_e_wrt_message);
   }

  *newobjid=my_id;
  return(1);
}
 

#define ACS_MDL_CONSUME		0x01	/* model will be consume	*/
#define ACS_MDL_UNCONSUME	0x02	/* model will be unconsume	*/
#define ACS_MDL_CMPT		0x04	/* model will be recompute	*/
#define ACS_MDL_DELETE		0x08	/* model will be delete		*/

/* ========================================================================= */
method ACntf_consume( IGRlong *msg )

{
IGRlong		sts, loc_msg;
struct	arg	{ IGRlong *msg; IGRint action; } arg;
OM_S_MESSAGE	ntf_msg;


	/* Implementation of method doesnt work through reference file */

	/*| initialization */
	*msg	= 1 ;
	loc_msg	= MSSUCC;

	// send ntf_symbol with consume operation
	arg.msg		= &loc_msg;
	arg.action	= ACS_MDL_CONSUME;

	sts = om$make_message(	classname	= "VDrelat_hdr",
				methodname	= "ACntf_symbol",
				p_arglist	= &arg,
				size		= sizeof arg,
				p_msg		= &ntf_msg );
	if( sts & 1 ){

		// send message on channel children
		sts = om$send(	msg		= &ntf_msg,
				p_chanselect	= &ND_children );
	}

return	OM_S_SUCCESS;
}

/* ========================================================================= */
method ACntf_unconsume(IGRlong *msg)
{
IGRlong		sts, loc_msg;
struct	arg	{ IGRlong *msg; IGRint action; } arg;
OM_S_MESSAGE	ntf_msg;

	/* Implementation of method doesnt work through reference file */

	/*| initialization */
	*msg	= 1 ;
	loc_msg	= MSSUCC;

	// send ntf_symbol with unconsume operation
	arg.msg		= &loc_msg;
	arg.action	= ACS_MDL_UNCONSUME;

	sts = om$make_message(	classname	= "VDrelat_hdr",
				methodname	= "ACntf_symbol",
				p_arglist	= &arg,
				size		= sizeof arg,
				p_msg		= &ntf_msg );
	if( sts & 1 ){

		// send message on channel children
		sts = om$send(	msg		= &ntf_msg,
				p_chanselect	= &ND_children );
	}

return	OM_S_SUCCESS;
}


/* ========================================================================= */
method ACtest_consumed(IGRlong *msg)
{
  if(me->STATE & ncpx_consumed)
    *msg=1;
  else
    *msg=0;

  return(1);
}


/* ========================================================================= */
method ACindex_in(char *foot_name;OM_S_MESSAGE *mess)
{
int suc;
int status;
GRclassid 		target_cl;
struct GRid 		real_GRid,wrk_GRid,context;
IGRlong 		msg;
    status = om$send(msg =  message ACncpx.ACgive_foot
		(&suc,foot_name,&real_GRid),
		targetid = my_id );
    as$status( );

    om$get_classid(objid = real_GRid.objid,
		 osnum = real_GRid.osnum,
		    p_classid = &target_cl);
     if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_NDnode_class_id) != OM_S_SUCCESS)
	{
        context.objid = NULL_OBJID;
        /*" makeing source on  %d \n",real_GRid.objid */
        ASmake_source_from_go(&msg,&real_GRid,&context,
		real_GRid.osnum,&wrk_GRid);
        real_GRid=wrk_GRid;
        /*" gives  %d \n",real_GRid.objid */
	}

    status = om$send( msg = mess,
		targetid = real_GRid.objid,targetos = real_GRid.osnum);
    as$status();
 return(1);
}

/* ========================================================================= */

method ACconsume(IGRlong *msg;char *footname;int cpy_req;struct GRid *cpy_GRid;
                        struct GRmd_env *md_env)
{
int             status;

  if('.'!= footname[0] &&  0!= footname[0])
  {
   status = om$send(msg = message ACncpx.ACindex_in
	(footname,message NDmacro.ACconsume(msg,"",cpy_req,cpy_GRid,md_env)),
		       targetid = my_id);
   as$status( );
   return(status);
  }

  status = om$send(msg = message ACncpx.ACntf_consume(msg),
                targetid = my_id );
  as$status( );
  me->STATE = (me->STATE ) | (ncpx_consumed);

/* owned dont make missing because of compute problems 
 status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_to_macros,
				count = &size1 );
 as$status( );
 status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_mfrom_graf_chns,
				count = &size2 );
 as$status( );
*/

/* if(size1 || size2 || md_env->md_id.osnum != OM_Gw_current_OS)*/
 if(1)
  {
  status = om$send( msg = message NDnodein.ACconsume
		   (msg,footname,cpy_req,cpy_GRid,md_env),
                   targetid = my_id  ,
		   mode = OM_e_wrt_message );
  as$status();
  }
 else
  {
  }

  return (  OM_S_SUCCESS );
}


/* ========================================================================= */

method ACunconsume(IGRlong *msg;char *footname)
{
int status;

  if('.'!= footname[0] &&  0!= footname[0])
  {
   status = om$send(msg = message ACncpx.ACindex_in
	(footname,message NDmacro.ACunconsume(msg,"")),
		       targetid = my_id);
   as$status( );
   return(status);
  }

  *msg=0;
  status = om$send(msg = message ACncpx.ACntf_unconsume(msg),
                targetid = my_id );
  as$status( );

  me->STATE &= (~ncpx_consumed);
  if(me->STATE & ncpx_missing)
    {
     {
     struct GRmd_env wk_env;
     IGRlong 		S1,S2;
     IGRlong msg;
     S1 = sizeof (struct GRmd_env);
     status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &wk_env,
                    		nret   = &S2 );
     as$status(action = RET_STATUS );
     status = om$send(msg =message NDnode.NDs_compute_node
		   (&msg,ND_COMP,&wk_env),targetid =my_id);
     as$status( );
     }
    me->STATE &= (~ncpx_missing);
    }

  status = om$send( msg = message NDnodein.ACunconsume
		   (msg,footname),
                   targetid = my_id  ,
		   mode = OM_e_wrt_message );
  as$status();


  return (  OM_S_SUCCESS );
}

/* ========================================================================= */

method ACchange_node ( struct GRmd_env *md_env )
{
 struct GRid owner;
 struct GRid mygrid;
 IGRint cn_type;

/* Modif jla, 27 apr 91 " sending ACchange_node recursively to the owner used
   to create a nice loop when the owner (like piping correction)
   - does not understand ACchange_node
   - inherit the GRowner unknown handler which pass unknown message to
     its component ...
*/

 owner.osnum = OM_Gw_current_OS;  owner.objid = my_id;
 do
  { 
    mygrid = owner;
    ASget_as_owner( &mygrid, &owner );
  } while (owner.objid != NULL_OBJID);

 /*"owner is %d %d\n",owner.objid,owner.osnum */

   cn_type = ND_COMP;
   nd$wait_batch(type = GR_GEOM_POSTED,
                 l_object = &mygrid,
                 l_obj_info = &cn_type,
                 nb_obj   = 1);
  return (  OM_S_SUCCESS );
}

/* ========================================================================= */
method ACbubble_up (long *msg;char *footname;int up_index;
		    OM_p_MESSAGE Condition,Action;
		     enum OM_e_wrt_flag delAction)
{
 int 			status;
 int 			size;
 struct GRid		*list = NULL;

  if('.'!= footname[0] &&  0!= footname[0])
  {
   status = om$send(msg = message ACncpx.ACindex_in
	(footname, message NDmacro.ACbubble_up
			(msg,"",up_index,Condition,Action,delAction)),
		       targetid = my_id);
   as$status( );
   return(status);
  }

  if(me->STATE & ncpx_root)
   {
   struct GRid		owner,mac_foot,mygrid;
   mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;
   ASget_as_owner( &mygrid, &owner);
   if(!IF_NULL_OBJID(owner.objid))
    {
    status = om$send(msg = message ACconst.ACget_foot_in_mac
		(msg,mygrid,&mac_foot),targetid =owner.objid);
    as$status( );
    status = om$send(msg = message NDmacro.ACbubble_up
		(msg,footname,up_index,Condition,Action,delAction),	
		targetid =mac_foot.objid,
		targetos =mac_foot.osnum);
    as$status( );
    }
   }
  else
   {  
   status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_template_chns,
				count = (OMuint *) &size );
   as$status( action = RET_STATUS );
   if(size)
    list = (struct GRid *) om$malloc (size = (size) * sizeof( struct GRid ));
   ACmagic_read(my_id, &AC_template_chns, list, size);

   status = om$send(msg = message ACncpx.ACpass_up
		(msg,size,list,up_index,Condition,Action,delAction), 
		targetid = my_id);
   as$status();
   if(size)
     om$dealloc(ptr =list);
   }

  return (  OM_S_SUCCESS );
}

/* ========================================================================= */
method ACpass_up (long *msg;
		int count; struct GRid list [];		
		int up_index;OM_p_MESSAGE Condition,Action;
		     enum OM_e_wrt_flag delAction)
{
int f;
#define _execute_ 1
#define _pass_up_ 2
long status;

 status = OM_S_SUCCESS;

 if(!Condition)
  f=_pass_up_;
 else
  {
  f=0;
  status =om$send(msg=Condition,targetid=my_id);
  }

 switch(status) 
	{
	case OM_S_SUCCESS 	: f=_execute_ | _pass_up_	; 	break;
	case OM_I_STOP_SENDING 	: f=_execute_ ;status=OM_S_SUCCESS; 	break;
	case OM_W_ABORT 	: f=_pass_up_;status=OM_S_SUCCESS; 	break;
	case OM_E_ABORT 	: status=OM_S_SUCCESS		; 	break;
	default:
	case OM_E_ERROR 	: status=OM_E_ABORT		; 	break;
    	}

 if(f & _execute_)
	{
 	status =om$send(msg=Action,targetid=my_id,mode=delAction);
  	as$status();
	}
 if( (f & _pass_up_ ) && (status &1) )
	{
  	status = om$send(msg = message ACncpx.ACbubble_up
		(msg,"",up_index,Condition,Action,delAction), 
		targetid = list[up_index].objid,
		targetos = list[up_index].osnum );
  	as$status();
	}
 
  return ( status  );
}


method  NDsleep(struct GRmd_env *md_env)
{
 long loc_msg,status;
 int max_g_ft,nb_component,i;
 extern IGRboolean ASbroadcast_in_progress;
 IGRboolean save_br;
 OM_S_OBJID save_md;
 struct GRid mac_def,component;

/* Delete template-feet pl_hold that were created temporary for ACreturn_foot */

 if(!(me->STATE & ncpx_root))
  {
   status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
/* START VDS CORRECTION */
   if( !(status & 1)){ goto wrapup ; }
/* END   VDS CORRECTION */

   status = om$send(msg= message ACcpx_defn.ACmax_graph_ft(&max_g_ft),
                   targetid = mac_def.objid ,targetos =mac_def.osnum);

/* START VDS CORRECTION */
   if( !(status & 1)){ goto wrapup ; }
/* END   VDS CORRECTION */

   status = om$get_channel_count( objid = my_id,
				  p_chanselect = &AC_mto_graf_chns,
				  count = (OMuint *) &nb_component);
   save_br = ASbroadcast_in_progress;
   ASbroadcast_in_progress = TRUE;
 
   for(i=nb_component-1; i>= max_g_ft; i--)
     status = om$send(msg = message GRgraphics.GRremwrng(&loc_msg,md_env),
		      p_chanselect = &AC_mto_graf_chns,
		      from = i , to = i);

   save_md = md_env->md_id.objid;
   md_env->md_id.objid = NULL_OBJID;
   for(i=nb_component-1; i>= max_g_ft; i--)
     status = om$send(msg = message GRgraphics.GRdelete(&loc_msg,md_env),
		      p_chanselect = &AC_mto_graf_chns,
		      from = i , to = i);

   for(i=max_g_ft-1;i>=0;i--)
    {
     status = om$get_objid_at_index(objid = my_id,
		      p_chanselect = &AC_mto_graf_chns,
		      index = i,
		      objidaddr = &component.objid,
		      osnumaddr = &component.osnum);
     if(!(status&1) || !pl_hold(component)) break;
     status = om$send(msg = message GRgraphics.GRdelete(&loc_msg,md_env),
		      targetid = component.objid);
    }
   md_env->md_id.objid = save_md;
   ASbroadcast_in_progress = save_br;
  }
/* START VDS CORRECTION */
wrapup :
/* END   VDS CORRECTION */

 return om$send(msg = message ACcpx.NDsleep(md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
}
	
end implementation ACncpx;
