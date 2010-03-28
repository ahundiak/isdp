class implementation ASmodlin;

#include "OMmacros.h"
#include "ASmatrix.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "msdef.h"
#include "grerr.h"
#include "graph.h"
#include "ASmsg.h"
#include "msmacros.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int before __((IGRpoint p1, IGRpoint p2, int ind, IGRdouble orient));
static void project_point __((IGRpoint p0, IGRpoint v0, IGRpoint p_from, 
                              IGRpoint p_proj));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



#define MAX_SEG 10
#define PARTIAL_SYMBOL 100
#define AS_DEBUG


from ASmodifier import ASmod_g_modif;

from ACcpx import find_macro;
from ACcpx_defn import ACgive_feet_desc;
from ACpretend import ACpconnect;
from OMObjSpace import pass;

extern GRclassid OPP_ASindexpt_class_id,
		 OPP_GR3dpoint_class_id,
		 OPP_ASsource_class_id,
		 OPP_ASModlin_class_id,
		 OPP_ASmodifier_class_id,
		 OPP_GRowner_class_id;
extern struct ext_list NDdelete;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function before                                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

static before(p1,p2,ind,orient)

  /*
  returned 1 if p1 is before p2 on the support line taking in account
  orientation 0 else
  */

  IGRpoint p1,p2;
  int ind;
  IGRdouble orient;
  { 
  /*"before between %lf and %lf\n",p1[ind],p2[ind]*/

  if(p1[ind]*orient<p2[ind]*orient) return(1);
  else return(0);
}/* end function before */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function  project_point                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/* this function project p_from point to p_proj on the line defined
   by the point p0 and the unit vector v0
*/

static void project_point(p0,v0,p_from,p_proj)
  IGRpoint p0,v0,p_from,p_proj;
  {
  IGRpoint vect;
  IGRdouble ps;

  v_sub(p_from,p0,vect);
  ps = v_dot(v0,vect);
  v_scale(v0,ps,vect);
  v_add(p0,vect,p_proj);
}/* end function project_point */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function  ASdummy_index                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*
   When a point apears twice in the list of roots of the element
   creates an index point instead and use it as root to avoid a double
   connection on the same channel between the same couple of object 
*/
ASdummy_index(point_grid,index_grid)
struct GRid point_grid,*index_grid;
/*.ASdummy_index*/
{
 IGRlong status;

 struct GRvg_construct        cnst_lis;     /* construction list         */
 IGRshort               active_level;
 struct GRas                  asso_lis;     /* associative information   */
 struct IGRdisplay      active_display;
 struct GRmd_env        active_env;

 IGRlong     cnst_lis_msg;  /* return msg from cnst          */
 struct GRid context;
 IGRdouble index_coor;

 IGRlong NumberOfBytes;
 IGRlong BytesReceived;
 IGRlong msg;




    context.objid = NULL_OBJID;
    index_coor = 0;

    /*
     *  get the default symbology data from the DPB
     */
    NumberOfBytes = sizeof( active_level);
    gr$get_active_level(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &active_level,
            nret = &BytesReceived);

    if ( !(msg&1)) return (OM_W_ABORT);


    /*
     *  get the default display symbology data from the DPB
     */
    NumberOfBytes = sizeof( active_display);
    gr$get_active_display(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &active_display,
            nret = &BytesReceived);

    if ( !(msg&1)) return (OM_W_ABORT);

    NumberOfBytes = sizeof( active_env);
    gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &active_env,
                nret = &BytesReceived);
    if ( !(msg&1)) return (OM_W_ABORT);
   
    


    cnst_lis.msg = &cnst_lis_msg;    
    cnst_lis.env_info = &active_env;  
    cnst_lis.display = &active_display;
    cnst_lis.level = active_level;
    cnst_lis.geometry = 0;            
    cnst_lis.newflag = FALSE;
    cnst_lis.class_attr = (IGRchar *) &asso_lis;
    cnst_lis.properties = 0;
    cnst_lis.name = NULL;

    asso_lis.num_parents = 1;
    asso_lis.parents = &point_grid;
    asso_lis.context = &context;

    asso_lis.go_attr = NULL;
    asso_lis.as_attr = (IGRchar *) &index_coor;


 status = om$construct(osnum = active_env.md_id.osnum,
                     classid = OPP_ASindexpt_class_id,
                     p_objid = &index_grid->objid,
                         msg = message GRgraphics.GRconstruct(&cnst_lis));
 index_grid->osnum = active_env.md_id.osnum;
 as$status(action = RET_STATUS);
 return(status);
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDplace                                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDplace 
  (
  struct GRas *asso_lis;         /* IN/OUT Information about the associativity*/
  struct GRmd_env *md_env;      /* IN     Information about the environment  */
  IGRchar *go_cnst_lis           /* IN/OUT Information about the graphic obj  */
  )
  {
  IGRlong   msg,status;         /* Status returned by om                     */
  IGRdouble newpoints[6*MAX_SEG];
  IGRint npt;
  IGRint ASpartial_delete();
  struct GRid *a_parents;
  struct GRid *buffer;
  int         index;
  struct GRid old_modifier;
  struct ret_struct  support_def;
  IGRint iparent,imodif,typ_mod,par_mod;
  int my_p;
  struct GRid my_grid;
  struct GRid sup_go;
  struct GRmd_env sup_env;

  /* add to node */

  status = om$send (msg = message NDnode.NDconnect(asso_lis->num_parents,
                                 asso_lis->parents,NULL_GRID,ND_NEW),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  /* Is there already modifier on this line */

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  ASfind_modifier(*asso_lis->parents,my_grid,&old_modifier);


/*  status = om$get_classid(osnum     = asso_lis->parents[0].osnum,
/*                 objid     = asso_lis->parents[0].objid,
/*                 p_classid = &obj_class);
/*  as$status(action = RET_STATUS);
/*
/*  if(((om$is_ancestry_valid(subclassid = obj_class,
/*			  superclassid = OPP_ASmodifier_class_id)==OM_S_SUCCESS)
/*   ||(om$is_ancestry_valid(subclassid = obj_class,
/*		  superclassid = OPP_ASmodlin_class_id)==OM_S_SUCCESS)))
/******/
  if(!IF_EQ_OBJID(old_modifier.objid,NULL_OBJID))
   {
   /*| There is already a modifier on the curve */

/*     old_modifier = asso_lis->parents[0]; */
     status = om$send (msg   = message ASmodlin.AStake_and_kill
					(old_modifier,md_env),
		       targetid = my_id);
    as$status(action = RET_STATUS);

    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                        NULL,0,&buffer,0,OM_K_MAXINT,&my_p),
	             targetid = my_id);
    as$status(action = RET_STATUS);

    a_parents = (struct GRid *) om$malloc(size = my_p*sizeof(struct GRid));

    for(index=0; index<my_p ; index++)
      {
      a_parents[index] = buffer[index];
/*"parent %d --> %d %d\n",index,a_parents[index].objid,a_parents[index].osnum */
      }
    }
  else
    {
     /*| its the first one */
     old_modifier.objid = NULL_OBJID;
     a_parents = asso_lis->parents;
    }

  /*  compute me */

  status = om$send(msg = message NDnode.NDgive_structure
						     (&msg,&support_def,md_env),
              targetid = a_parents->objid);
  as$status(action = RET_STATUS);

  v_equal(support_def.var.line_st.p0,newpoints);
  v_equal(support_def.var.line_st.p1,newpoints+3);
  npt = 2;

  /* compute first the extends */

  iparent = 1;
  for (imodif=0 ; imodif<me->nmodif ; imodif ++)
    {
    typ_mod = me->typ_mod[imodif];
    par_mod = me->par_mod[imodif];
    if(typ_mod<0)
      {
      iparent = iparent + par_mod;
      }
    else
      {
      msg= ASextend_line(par_mod,a_parents+iparent,md_env,newpoints,
                         support_def.var.line_st.v0,typ_mod);
      if(!(msg&1)) return(msg);
      iparent = iparent + par_mod;
      }
    }


  /* compute now the partial delete */

  iparent = 1;
  for (imodif=0 ; imodif<me->nmodif ; imodif ++)
    {
    typ_mod = me->typ_mod[imodif];
    par_mod = me->par_mod[imodif];
    if(typ_mod<0)
      {
      msg = ASpartial_delete(a_parents+iparent,md_env,newpoints,&npt,
			         support_def.var.line_st.v0);

      if(!(msg&1)) return(msg);
      iparent = iparent + par_mod;
      }
    else
      {
      iparent = iparent + par_mod;
      }
    }

  /* 
  prepare the graphic definition. At least one line must be created
  by copy support (with change properties if necessary) and GRpostabs send
  */

  {
  IGRlong  msg;
  IGRint iseg;
  IGRdouble *pt;
  OM_S_OBJID new_go;
  struct GRid go_id;
  struct GRpost_info post_info;
  IGRlong rc;
  IGRshort action;
  IGRshort mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  long pos = OM_K_MAXINT;
  struct IGRpolyline geom;
  extern IGRboolean ASbroadcast_in_progress;
  IGRboolean old_ASbroad;
  enum GRdpmode pen; 


  me->nseg = (npt+1)/2;


 old_ASbroad = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;

 status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
						   &sup_env.md_env.matrix_type,
						    sup_env.md_env.matrix),
		  targetid = a_parents[0].objid,
		  targetos = a_parents[0].osnum);
   as$status(action = GOTO_VALUE, value = wrapup);

   
   for(iseg=0,pt=newpoints ; iseg<me->nseg ; iseg++,pt=pt+6)
     {
     /* copy the support and connect */
     status = om$send(msg         = message GRgraphics.GRcopy(&msg,
                                    &sup_env,md_env,
                                    &(go_id.objid)),
                     targetid     = sup_go.objid,
                     targetos     = sup_go.osnum);
     as$status(action = GOTO_VALUE, value = wrapup);

     go_id.osnum = a_parents[0].osnum;

     if(!IF_NULL_OBJID(old_modifier.objid))
       {
       /*| Change the properties if necessary  */
       action=1;
       status = om$send(msg      = message GRvg.GRchgprops(&msg,&action,&mask),
                        targetos = go_id.osnum,
                        targetid = go_id.objid);
       as$status(action = GOTO_VALUE, value = wrapup);
      }

     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;
     status=om$send (msg = message GRconnector.GRrigidconn(&msg,&my_grid,&pos),
                 targetid = go_id.objid,
                 targetos = go_id.osnum);
     as$status(action = GOTO_VALUE, value = wrapup);

     geom.num_points = 2;
     geom.points     = pt;

     post_info.construct_flag = FALSE;
  
     status=om$send( msg = message GRlinear.GRputpolyline( &msg,md_env,
                                       &post_info,&geom, &new_go),
                    targetid = go_id.objid);
     as$status(action = GOTO_VALUE, value = wrapup);
     }

wrapup :
   ASbroadcast_in_progress = old_ASbroad;

/* 
   all is ok erases the parents and changes its graphics properties
   if no previous partial delete on it
*/
  if(IF_EQ_OBJID(old_modifier.objid,NULL_OBJID))
    {
    /*| Erase the old graphic objects */

    pen = GRbe;
    status = om$send(msg      = message GRgraphics.GRdisplay(&rc,
					&sup_env.md_env.matrix_type,
					 sup_env.md_env.matrix,
					&pen,&md_env->md_id),
                     targetos = sup_go.osnum,
                     targetid = sup_go.objid);
    as$status();

    action = 0;
    status = om$send(msg          = message GRvg.GRchgprops(&msg,&action,&mask),
                     targetid     = sup_go.objid,
                     targetos     = sup_go.osnum);
    as$status(action = RET_STATUS);

    status = om$send(msg = message NDnode.NDchg_state
					            (ND_DIS_BY_CH,ND_DIS_BY_CH),
		      targetid = asso_lis->parents[0].objid,
		      targetos = asso_lis->parents[0].osnum);
    as$status();

    }
  else
    {
     om$dealloc(ptr = a_parents);
    }
  }
  return(OM_S_SUCCESS);
}/* end method NDplace */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method AStake_and_kill                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

AStake_and_kill_mod(old_modif,new_modif,typ_new,par_new,nmodif,md_env)
struct GRid old_modif,new_modif;
char *typ_new,*par_new;
int *nmodif;
struct GRmd_env *md_env;
/*.AStake_and_kill_mod*/
 {
  IGRlong   status;
  IGRchar *ptr;
  int count,icount,i;
  int old_p,my_p,index;
  struct GRid *parents;
  struct GRid *buffer;
  IGRint n_old;
  IGRchar typ_old[NMODIF_MAX],par_old[NMODIF_MAX];
  GRclassid obj_class;

  /* the type and modif of the previous modifier was */
  /* to make modlin and modbsp work together */

  om$get_classid(objid = old_modif.objid,p_classid = &obj_class);
  if(om$is_ancestry_valid(subclassid=obj_class,
			superclassid=OPP_ASmodifier_class_id) == OM_S_SUCCESS)
   {
    status=om$send(msg=message ASmodifier.ASmod_g_modif(&n_old,typ_old,par_old),
		   senderid = NULL_OBJID,
                   targetos = old_modif.osnum,
                   targetid = old_modif.objid);
    as$status(action = RET_STATUS);

      
    om$get_classid(objid = new_modif.objid,p_classid = &obj_class);
    if(om$is_ancestry_valid(subclassid=obj_class,
			  superclassid=OPP_ASmodlin_class_id) == OM_S_SUCCESS)
      {
       for(i=0;i<n_old;i++) if(typ_old[i]==2) typ_old[i] = -1;
      }
    }
  else
    {
    status=om$send(msg = message ASmodlin.ASgive_modif(&n_old,typ_old,par_old),
		   senderid = NULL_OBJID,
                   targetos = old_modif.osnum,
                   targetid = old_modif.objid);
    as$status(action = RET_STATUS);
      
    om$get_classid(objid = new_modif.objid,p_classid = &obj_class);
    if(om$is_ancestry_valid(subclassid=obj_class,
			  superclassid=OPP_ASmodifier_class_id) == OM_S_SUCCESS)
      {
       for(i=0;i<n_old;i++) if(typ_old[i]==-1) typ_old[i] = 2;
      }
    }

    if( (*nmodif+n_old) > NMODIF_MAX)
	 {printf("to many modificator\n"); return(OM_W_ABORT);}

 
    /*" Get the parents of old_modif %d\n",old_modif.objid */

    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                        NULL,0,&buffer,0,OM_K_MAXINT,&old_p),
		   senderid = NULL_OBJID,
                   targetos = old_modif.osnum,
                   targetid = old_modif.objid);
    as$status(action = RET_STATUS);

    ptr = om$malloc(size = old_p*sizeof(struct GRid));
    if(ptr == NULL) return(OM_W_ABORT);
    parents = (struct GRid *) ptr;

  /* Load the parents of the previous modifier  */
    for(index=0; index<old_p ; index++) parents[index] = buffer[index];


  /*
     Add my parents
     If one of my parents is already parent of the old modifier, 
     use an intermediate indexpoint to avoid the double connection
     between the 2 same objects
  */
    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                        NULL,0,&buffer,0,OM_K_MAXINT,&my_p),
		   senderid = NULL_OBJID,
                   targetos = new_modif.osnum,
                   targetid = new_modif.objid);
    as$status(action = RET_STATUS);

    count = old_p + my_p -1;   /* just one time the support */

    ptr = om$realloc(size = count*sizeof(struct GRid),ptr = ptr);
    if(ptr == NULL) return (OM_W_ABORT);
    parents = (struct GRid *) ptr;

    for(i=1,icount=old_p ; i<my_p ; i++,icount++)
        parents[icount] = buffer[i];

    for(icount=old_p ; icount<count ; icount++)
       {
	for(i=1 ; i<old_p ; i++)
	 {
	  if(IF_EQ_OBJID(parents[icount].objid,parents[i].objid))
            {
             ASdummy_index(parents[icount],&parents[icount]);
	     break;
	    }
	 }
       }

    for(i=0; i<*nmodif ;i++)
       {
        typ_new[i+n_old] = typ_new[i];
        par_new[i+n_old] = par_new[i];
        /*"new %d  %d\n",typ_new[i],par_new[i] */
       }
 
     for(i = 0; i<n_old;i++)
       {
        typ_new[i] = typ_old[i];
        par_new[i] = par_old[i];
        /*"new %d  %d\n",typ_new[i],par_new[i] */
       }

    *nmodif = n_old + *nmodif;

  /*" Deconnecte les parents de old_modifier %d\n",old_modif.objid*/

    status = om$send(msg      = message NDnode.NDdisconnect(0,NULL),
		     senderid = NULL_OBJID,
	             targetos = old_modif.osnum,
                     targetid = old_modif.objid);
    as$status(action = RET_STATUS);

   /*" connecte les parents sur %d\n",new_modif.objid*/

   status = om$send (msg = message NDnode.NDconnect
					   (count,parents,NULL_GRID,ND_FULL),
		   senderid = NULL_OBJID,
                   targetid = new_modif.objid,
                   targetos = new_modif.osnum);
   as$status(action = RET_STATUS);

  /* connect to myself children of the old modifier */

   status=om$send( msg = message NDnode.NDchange_connect
						     (1,&old_modif,&new_modif),
		     senderid = old_modif.objid,
		     targetos = old_modif.osnum,
		     p_chanselect = &ND_children);
   as$status(action = RET_STATUS);

 /* erase and delete old_modifier */

    status = om$send(msg      = message NDnode.NDdisplay(0,GRbe,md_env),
		     senderid = NULL_OBJID,
                     targetos = old_modif.osnum,
                     targetid = old_modif.objid);
    as$status();

    status = om$send(msg = message NDnode.NDdelete(md_env),
		     senderid = NULL_OBJID,
	             targetos = old_modif.osnum,
 	             targetid = old_modif.objid);
    as$status(action = RET_STATUS);

  /* Dealloc pointer */

    om$dealloc( ptr = ptr);

  return(OM_S_SUCCESS);
 }

/*
  take the old_modif and kill this object 
*/

method AStake_and_kill(struct GRid old_modif; struct GRmd_env *md_env)
  {
  IGRlong   status;
  struct GRid my_grid;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  status=AStake_and_kill_mod(old_modif,my_grid,me->typ_mod,me->par_mod,
			     &me->nmodif,md_env);
  return(status);

}/* end method AStake_and_kill */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          method NDcompute_node                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDcompute_node ( IGRlong *msg; IGRint cn_type; int count;
  			struct GRid list_par[]; struct GRmd_env *md_env)
  {
  IGRlong  status;
  IGRint npt;
  IGRdouble newpoints[6*MAX_SEG];
  IGRint ASpartial_delete();
  struct ret_struct  support_def;
  IGRint typ_mod,par_mod;
  IGRint iparent,imodif;
  long pos = OM_K_MAXINT;

  if(me->nseg >= PARTIAL_SYMBOL)
    {/* Do not compute macro in partial delete */
      return(OM_S_SUCCESS);
    }


/* The support is  */

    status=om$send(msg=message NDnode.NDgive_structure(msg,&support_def,md_env),
                targetos = list_par[0].osnum,
                targetid = list_par[0].objid);
    as$status(action = RET_STATUS);

   v_equal(support_def.var.line_st.p0,newpoints);
   v_equal(support_def.var.line_st.p1,newpoints+3);
   npt = 2;


/*
  compute first the extends 
*/
  iparent = 1;
  for (imodif=0 ; imodif<me->nmodif ; imodif ++)
      {
       typ_mod = me->typ_mod[imodif];
       par_mod = me->par_mod[imodif];
       if(typ_mod<0)
	 {
	  iparent = iparent + par_mod;
	 }
	else
	 {
          *msg = ASextend_line(par_mod,list_par+iparent,md_env,newpoints,
			    support_def.var.line_st.v0,typ_mod);
          if(!(*msg&1)) return(OM_W_ABORT);
	  iparent = iparent + par_mod;
	 }
      }


/*
  compute now the partial delete
*/
  iparent = 1;
  for (imodif=0 ; imodif<me->nmodif ; imodif ++)
      {
       typ_mod = me->typ_mod[imodif];
       par_mod = me->par_mod[imodif];
       if(typ_mod<0)
	 {
          *msg = ASpartial_delete(list_par+iparent,md_env,newpoints,&npt,
			       support_def.var.line_st.v0);
          if(!(*msg&1)) return(OM_W_ABORT);
	  iparent = iparent + par_mod;
	 }
	else
	  {
	   iparent = iparent + par_mod;
	  }
	}


/*
    update the graphic object
    If necessary graphic objects will be created or deleted
*/

{
 IGRint nseg,iseg;
 struct GRpost_info post_info;
 struct GRid newgo;
 IGRdouble *pt;
 IGRint stat;
 OM_S_OBJECT_LINKAGE list;
 IGRint size=1;
 OMuint count;
 struct GRid my_grid;
 struct IGRpolyline geom;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;


    nseg = (npt+1)/2;

/* create and connect additionnal segment if needed */

    if(nseg>me->nseg)
      {
       stat=om$get_channel_objects(objid=my_id,
				   p_chanselect=&AS_to_comp,
				   list=&list,size=size,count=&count);
       for (iseg=me->nseg; iseg<nseg; iseg++)
         {
          status=om$send(msg = message GRgraphics.GRcopy(msg,md_env,
					      md_env,&newgo.objid),
                	 targetos = list.osnum,
                	 targetid = list.S_objid);
          as$status(action = RET_STATUS);

	  newgo.osnum = list.osnum;
          status = om$send
                     (msg = message GRconnector.GRrigidconn(msg,&my_grid,&pos),
                      targetid = newgo.objid,
  		      targetos = newgo.osnum);
          as$status(action = RET_STATUS);
	 }
      }

/* delete unneeded segment in reverse order  */

    for(iseg = me->nseg-1 ; iseg >= nseg ; iseg--)
     {
     status=om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRdelete(msg,md_env),
                  senderid = my_id,
                  p_chanselect = &AS_to_comp,
                  from = iseg,
                  to = iseg);
      as$status(action = RET_VALUE,value = RET_STATUS);
     }

/* update their position */

    for (iseg=0,pt=newpoints ; iseg<nseg ; iseg++,pt=pt+6)
      {
       geom.num_points = 2;
       geom.points     = pt;

       post_info.construct_flag = FALSE;
  
       status=om$send( msg = message GRlinear.GRputpolyline( msg, md_env,
                                       &post_info, &geom, &newgo.objid),
                  senderid = my_id,
                  p_chanselect = &AS_to_comp,
                  from = iseg,
                  to = iseg);
       as$status(action = RET_STATUS);
      }

  me->nseg = nseg;
  }
  return(OM_S_SUCCESS);

}/* end method compute_node */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function ASextend_line                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASextend_line(count,parent,md_env,points,v0,change_ext)
  IGRint count;
  struct GRid *parent;
  struct GRmd_env *md_env;
  IGRdouble *points,*v0;
  IGRint change_ext;
  /*.ASextend_line*/
  {
  struct ret_struct  pardef2,pardef3;
  IGRpoint proj;
  IGRlong   msg,status;              /* Status returned by om                     */

  if (count!=1 && count!=2)
   {
    /*| ASextend_line bad parent number  */
    return(0);
   }

  /* point defining the extend geometry */

  status = om$send
             (msg      = message NDnode.NDgive_structure(&msg,&pardef2,md_env),
              senderid = NULL_OBJID,
              targetos = parent->osnum,
              targetid = parent->objid );
  as$status(action = RET_STATUS);

  /*
   Is there a track point ? In this case the point to change is relative
   to the this point
  */
  if(count == 2)
    {
     /*  modif ch le 12 fev. 87 */
     IGRdouble scal1;
     IGRvector v1, v2;

    status = om$send
               (msg    = message NDnode.NDgive_structure(&msg,&pardef3,md_env) ,
                senderid = NULL_OBJID,
                targetos = (parent+1)->osnum,
                targetid = (parent+1)->objid );
    as$status(action = RET_STATUS);

     v_sub(pardef3.var.point_st.pt,pardef2.var.point_st.pt,v1);
     v_sub(points+3,points,v2);
     scal1 = v_dot(v1,v2);

     if( scal1 < 0 )  change_ext = 1-change_ext ;
    }

/*
   Compute the projection of the extend point on to the line and 
   Perform the change
*/

  project_point(points,v0,pardef2.var.point_st.pt,proj);

  if(change_ext == 0)
     v_equal( proj, points );
 
  else
     v_equal( proj, points+3 );

/*"res %lf %lf %lf\n    %lf %lf %lf\n",points[0],points[1],points[2],points[3],points[4],points[5]*/

  return(1);

}/* end function ASextend_line */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function ASpartial_delete                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*
   partial delete of a segment (or of an already partial deleted segment
*/

IGRint ASpartial_delete(parent,md_env,points,npt,v0)
IGRint *npt;
struct GRid *parent;
IGRdouble points[],v0[];
struct GRmd_env *md_env;
  /*.ASpartial_delete*/
  {
  IGRlong   msg,status;          /* Status returned by om                     */
  enum delseg_state { BEFORE,DURING,AFTER};
  enum delseg_state  actual_state;
  IGRint nseg,iseg;
  IGRdouble seg_start[3*MAX_SEG],seg_end[3*MAX_SEG];
  struct ret_struct  pointdef1,pointdef2;
  IGRdouble *start_delete,*end_delete;
  IGRint i,ind,npt3;
  IGRdouble orient,diff,diffm,fabs();

/* to class the points we take the most significant coordonate of the support
   orient = 1 if line directed in increasing coordonate ,-1 else */

  
  ind=0;
  npt3 = 3*( *npt-1);
  diffm = fabs(points[0]-points[npt3]);
  
  for(i=1;i<3;i++)
     {
      diff = fabs(points[i]-points[npt3+i]);
      if(diffm < diff) { ind =i;diffm = diff;}
     }
 
   if(points[ind]<points[npt3+ind]) orient =  1;
   else				    orient = -1;

  /*" significant coor. : %d,orient = %lf \n",ind,orient*/


/* begin and end of the deleted zone in the same orientation than the line */

    status = om$send
               (msg  = message NDnode.NDgive_structure(&msg,&pointdef1,md_env) ,
                senderid = NULL_OBJID,
                targetos = parent->osnum,
                targetid = parent->objid );
    as$status(action = RET_STATUS);


    status = om$send
               (msg  = message NDnode.NDgive_structure(&msg,&pointdef2,md_env) ,
                senderid = NULL_OBJID,
                targetos = (parent+1)->osnum,
                targetid = (parent+1)->objid );
    as$status(action = RET_STATUS);

/*"class pd %d %d coor %lf %lf\n",parent->objid,(parent+1)->objid,pointdef1.var.point_st.pt[ind],pointdef2.var.point_st.pt[ind] */


  if (before(pointdef1.var.point_st.pt,pointdef2.var.point_st.pt,ind,orient))
     {
      start_delete = pointdef1.var.point_st.pt;
      end_delete   = pointdef2.var.point_st.pt;
     }
  else
     {
      start_delete = pointdef2.var.point_st.pt;
      end_delete   = pointdef1.var.point_st.pt;
     }

/*  project these points on the support */
    
   project_point(points,v0, start_delete, start_delete);

   project_point(points,v0, end_delete, end_delete);


/* waiting to use again a link list to store the points .... */

   nseg = *npt/2;
   npt3 = 0;

   for(iseg = 0; iseg<nseg; iseg++)
     {
      v_equal(points+npt3,seg_start+3*iseg);npt3 +=3;
      v_equal(points+npt3,seg_end+3*iseg);npt3 +=3;
     }
/* The new partial delete becomes : */

   actual_state = BEFORE;
   i = 0;
   for(iseg=0 ; iseg<nseg ; iseg++)
      {
       if(i >= 2*MAX_SEG)
         {
         /*"to many segments, bool_seg interupted\n"*/
	  break;
	 }

    switch (actual_state)
     {
      
      case BEFORE :
            if(before(seg_end+3*iseg,start_delete,ind,orient))
               {v_equal(seg_start+3*iseg,points+3*i); i+=1 ;
                v_equal(seg_end+3*iseg,points+3*i); i+=1 ;
		break;
               }
	    else
	       {
		actual_state = DURING;
		if(before(seg_start+3*iseg,start_delete,ind,orient))
                  {
		   v_equal(seg_start+3*iseg,points+3*i); i+=1 ;
                   v_equal(start_delete,points+3*i); i+=1 ;
                  }
                }
	  
      case DURING :
		if(before(seg_end+3*iseg,end_delete,ind,orient)) break;
		else
		  {
		   actual_state = AFTER;
		   if(before(seg_start+3*iseg,end_delete,ind,orient))
		     {
                      v_equal(end_delete,points+3*i); i+=1 ;
		      v_equal(seg_end+3*iseg,points+3*i); i+=1 ;
		      break;
		     }
                  }

      case AFTER  :
            v_equal(seg_start+3*iseg,points+3*i); i+=1 ;
            v_equal(seg_end+3*iseg,points+3*i); i+=1 ;
	    break;
     }  /* end switch */
  }     /* end for    */

/* bool_segment always needs to have at least 2 points -> 1 segement */

   if(i == 0) {v_equal(seg_start,points+3*i); i+=1 ;
	       v_equal(seg_start,points+3*i); i+=1 ;}

  *npt=i;

/*^ 
    printf("res %d points\n",*npt);
    for(i=0;i<*npt;i++)
      printf("%d --> %lf %lf %lf\n",i,points[3*i],points[3*i+1],points[3*i+2]);
*/

  return(1);
}/* end function ASpartial_delete */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDparent_deleted                         */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
   This method is used to  display again the line when the points
   definings the ASextends or the partial delete are deleted
*/

in_delete(obj,deleted,count_deleted)
struct GRid *obj,*deleted;
int count_deleted;
{ int i;
  for(i=0;i<count_deleted;i++)
   { if(   obj->objid == deleted[i].objid 
	&& obj->osnum == deleted[i].osnum) return i;
   }
  return -1;
}
 
ASmodif_parent_deleted(msg,count_deleted,deleted,my_grid,typ_mod,par_mod,nmodif,
		       md_env)
IGRint *msg;
int count_deleted;
struct GRid my_grid,*deleted;
IGRchar *typ_mod,*par_mod;
IGRint *nmodif;
struct GRmd_env *md_env;
{
 IGRlong status;
 struct GRid *parents;
 struct GRid line_sup;
 int count_p;
 IGRint nmodif_new,i_parent,i_modif,nb_p,i_p;
 IGRint parent_delete;
 IGRint cp_type = 0;
 enum GRdpmode pen;

/* 
  If the support is deleted : I deseapear

  If not  . If modifications remains , recompute them and redisplay me

*/

/*
    first I erase my_self
*/

    status = om$send(msg = message NDnode.NDdisplay(0,GRbehe,md_env),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
    as$status();

    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                        NULL,0,&parents,0,OM_K_MAXINT,&count_p),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
    /*" Nb of parents = %d\n",count_p */
    as$status(action = RET_STATUS);
     if(count_p == 0)
       {
        /*| I have lost my parents */
        status = om$send(msg = message NDnode.NDdelete(md_env),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
        as$status(action = RET_STATUS);
        return(OM_S_SUCCESS);
       }

 line_sup = parents[0];

  /*"support : %d \n",line_sup.objid*/

   if(in_delete(&line_sup,deleted,count_deleted) != -1)
   {
  /*|  support deleted  */
     status = om$send(msg = message NDnode.NDdelete(md_env),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
    as$status(action = RET_STATUS);

    return(OM_S_SUCCESS);
   }

/* the support is not deleted. Find the modification deleted */

  /*"before delete %d modif\n",*nmodif*/

    nmodif_new = 0;
    i_parent = 1;
    for (i_modif=0; i_modif<*nmodif ; i_modif++)
       {
	parent_delete = 0;
	nb_p = par_mod[i_modif];
	for(i_p = 0; i_p<nb_p; i_p++)
	  { 
/*"Is %d %d del\n",parents[i_parent+i_p].objid, parents[i_parent+i_p].osnum */
        if(in_delete(parents+i_parent+i_p,deleted,count_deleted) != -1)
	     {parent_delete = 1;break;}
	}
     if(!parent_delete)
	{
	 typ_mod[nmodif_new] = typ_mod[i_modif];
	 par_mod[nmodif_new] = par_mod[i_modif];
	 nmodif_new += 1;
         /*"modif %d survies\n",i_modif*/
	}
      else
	{
         /*"modif %d deleted\n",i_modif*/
         /*^{ int jla;
	   printf("nb_p %d\n",nb_p);
           for(jla=0;jla<nb_p;jla++)
		 printf("--> %d %d\n",parents[i_parent+jla].objid,
				      parents[i_parent+jla].osnum);
	  }
         */

         status = om$send(msg = message NDnode.NDdisconnect
							(nb_p,parents+i_parent),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
         as$status(action = RET_STATUS);
        }
      i_parent += nb_p;
    }
    

/* How many modifications remains */

  /*"%d modif after delete\n",nmodif_new*/
 
  if(nmodif_new == 0)
/* I'm deleted, my support is displayable again */
    {
     IGRlong rc;
     struct GRid sup_go;
     IGRshort sup_matrix_type;
     IGRmatrix sup_matrix;
     IGRboolean action = 1;
     IGRshort mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

    status = om$send(msg = message NDnode.NDchg_state (ND_DIS_BY_CH,0),
		     senderid = NULL_OBJID,
		     targetid = line_sup.objid,
		     targetos = line_sup.osnum);
    as$status();

    status = om$send(msg = message NDnode.ASreturn_go(&sup_go,
						  &sup_matrix_type,sup_matrix),
		  senderid = NULL_OBJID,
		  targetid = line_sup.objid,
		  targetos = line_sup.osnum);
    as$status(action = RET_STATUS);

    status = om$send(msg          = message GRvg.GRchgprops(&rc,&action,&mask),
		     senderid = NULL_OBJID,
		     targetid     = sup_go.objid,
                     targetos     = sup_go.osnum);
    as$status(action = RET_STATUS);

    pen = GRbd;
    status = om$send(msg      = message GRgraphics.GRdisplay(&rc,
					&sup_matrix_type,sup_matrix,
					&pen,&md_env->md_id),
		  senderid = NULL_OBJID,
                     targetos = sup_go.osnum,
                     targetid = sup_go.objid);
    as$status();

    status = om$send(msg = message NDnode.NDdelete(md_env),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
    as$status(action = RET_STATUS);
    return(OM_S_SUCCESS);
    }
  
/* modification remains, I survie */

   else
   {
    *nmodif = nmodif_new;
    status = om$send (msg      = message NDnode.NDs_compute_node((IGRlong *)msg,cp_type,
								 md_env),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
    as$status(action = RET_STATUS);

    status = om$send(msg      = message NDnode.NDdisplay(0,GRbd,md_env),
		     senderid = NULL_OBJID,
		     targetid = my_grid.objid,
		     targetos = my_grid.osnum);
    as$status(action = RET_STATUS);
 /*| ASmodlin is not deleted */
    return (OM_S_SUCCESS);
   }

}


method NDparent_deleted(IGRlong *msg; 
			IGRint count_deleted; struct GRid deleted[];
			struct GRid *new_obj; 
		        struct GRmd_env *md_env)
{
 IGRlong   status; 
 struct GRid my_grid;
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 status = ASmodif_parent_deleted((int *)msg,count_deleted,deleted,my_grid,
			me->typ_mod,me->par_mod,&me->nmodif, md_env);
 return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                locate the support instead of the partial delete            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASmodif_locate_owner(msg,my_grid,cvl,path,pos)
 IGRlong *msg;
 struct GRid my_grid;
 struct GRlc_cvl *cvl;
 struct GRlc_path *path;
 IGRint   *pos;
{
  IGRlong   status,status1;        /* Status returned by om                   */
  int       nb_parent;             /* Number of parents to get                */
  struct    GRid  *buffer;         /* Temopry buffer to get the objects       */
  struct    GRid  gr_grid;         /* Grid of the graphic object of the supp. */
  IGRboolean action; 
  IGRshort mask;
  IGRlong rc;
  IGRdouble save_tol;
  GRclassid obj_class;
  
 /*| Get the first parent of the partial delete and its class */

  status = om$send(msg   = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                      NULL,0,&buffer,0,0,&nb_parent),
		   senderid = NULL_OBJID,
                   targetid = my_grid.objid,
                   targetos = my_grid.osnum);
  as$status(action = RET_STATUS);


  status = om$send( msg = message NDnode.ASreturn_go(&gr_grid,NULL,NULL),
		    senderid = NULL_OBJID,
		    targetid = buffer[0].objid, targetos = buffer[0].osnum);
  as$status(action = RET_STATUS);

 /*| Change it temporary to locatable and displayable */

  mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  action = 1;
  status1 = om$send(msg         = message GRvg.GRchgprops(&rc,&action,&mask),
	  senderid = NULL_OBJID,
          targetid     = gr_grid.objid,
          targetos     = gr_grid.osnum);
  as$status(sts = status1);

 /*| Send it locate message (bypass the proximity criteria) */

  om$get_classid(objid = gr_grid.objid,
		 osnum = gr_grid.osnum,
		 p_classid = &obj_class);

  if(om$is_ancestry_valid(superclassid = OPP_GRowner_class_id,
			  subclassid = obj_class) == OM_S_SUCCESS)
    {
     status = om$send(msg = message GRowner.GRlocate_owner(msg,cvl,path,pos),
	              senderid = NULL_OBJID,
                      targetid     = gr_grid.objid,
                      targetos     = gr_grid.osnum);
    }
  else
    {
     save_tol = cvl->attributes.acc_tolerance;
     cvl->attributes.acc_tolerance = 1.e+12;
     status = om$send(msg = message GRgraphics.GRlocate(cvl,NULL),
	          senderid = NULL_OBJID,
                  targetid     = gr_grid.objid,
                  targetos     = gr_grid.osnum);
     cvl->attributes.acc_tolerance =  save_tol;
    }

 /*| Restore the properties */

  mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  action = 0;
  status1 = om$send(msg         = message GRvg.GRchgprops(&rc,&action,&mask),
	  senderid = NULL_OBJID,
          targetid     = gr_grid.objid,
          targetos     = gr_grid.osnum);
  as$status(sts = status1);

  *msg = MSSUCC;

  return (status);
 }

method GRlocate_owner(IGRlong  *msg; struct GRlc_cvl *cvl;
		      struct GRlc_path *path; IGRint   *pos)
 {
  IGRlong status;
  struct GRid my_grid;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = ASmodif_locate_owner(msg,my_grid,cvl,path,pos);
 
  return (status);
 }
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method become macro                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method ACbecome_macro(IGRlong *msg; IGRint position;
                         struct GRmd_env *md_env)
{
 *msg = ND_DROP_MAC;
 return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method ASgive_modif                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
  Give the instances of the current modifier
*/

method ASgive_modif ( IGRint *nmodif; IGRchar typ_mod[]; IGRchar par_mod[] )
  {
  IGRint i;
  *nmodif = me->nmodif;
  for(i=0 ; i < *nmodif ; i++)
   {
    typ_mod[i] = me->typ_mod[i];
    par_mod[i] = me->par_mod[i];
   }
 return (OM_S_SUCCESS);
}/* end method ASgive_modif */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method GRendpts                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRendpts
  (
  IGRlong        *msg;
  IGRshort       *mat_type;
  IGRmatrix      matrix;
  IGRpoint       startpt;
  IGRpoint       endpt
   )
  {
  IGRpoint prov;
  IGRlong   status;              /* Status returned by om                     */

/*
   a little surprise to find startpoint on nseg-1 and endpoint on 0
   but it seems to work
*/

status = om$send(msg=message GRcurve.GRendpts(msg,mat_type,matrix,startpt,prov),
        	p_chanselect = &AS_to_comp,
        	from = 0,
        	to = 0);
if(status&1)
status = om$send(msg=message GRcurve.GRendpts(msg,mat_type,matrix,prov,endpt),
        p_chanselect = &AS_to_comp,
        from = me->nseg%PARTIAL_SYMBOL - 1,
        to = me->nseg%PARTIAL_SYMBOL - 1);
return(status);
}/* end method GRendpts */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            method NDprint                                    */
/* This object will be printed as several associative object. That needs to   */
/* deceive the graph printer manager wich control that each object is only    */
/* edit one time.   							      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define MAX_PARENTS 20                     /* Number maximum of parents       */
#define MAX_CHAR    80                     /* Number maximum of char for name */


method NDprint(struct GRmd_env *md_env ; FILE *stream)
  {
  IGRint              count;                 /* Number of parents             */
  IGRint              icount;                /* Index for loop                */
  struct GRid *list;                 /* List of the parents objid     */
  IGRlong   status;              /* Status returned by om                     */
  IGRlong             msg;                   /* Returned message from om      */
  char                name[MAX_CHAR];        /* Name of the object to print   */
  char                par_name[MAX_PARENTS]  /* List of the parents names     */
                              [MAX_CHAR];
  IGRint iparent,par_mod,typ_mod,imodif;
  struct ret_struct  supdef;

  /* Get the name of this object */

  as$printer_set_name(prefix="MOD_LIN",
		      name=name);

  if (strcmp(name,"")==0) return(OM_S_SUCCESS);

  /* Give the parents names */
  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
                                                        NULL,0,&list,
                                                        0,OM_K_MAXINT,&count),
                     targetid = my_id);
  if(!(status&1)) count = 0;

  /* suport name */

  as$printer_get_name(objid=list->objid,
		      name=par_name[0]);
  status = om$send
             (msg  = message NDnode.NDgive_structure(&msg,&supdef,md_env),
              targetos = list->osnum,
              targetid = list->objid);
  as$status(action = RET_STATUS);

  list += 1;

  /*| loop on the different modify on the support    */

  iparent = 1;
  for (imodif=0 ; imodif<me->nmodif ; imodif ++)
    {
    typ_mod = me->typ_mod[imodif];
    par_mod = me->par_mod[imodif];
    if(par_mod+1 > MAX_PARENTS) return(OM_W_ABORT);
    if(typ_mod<0) as$printer_set_name(objid=NULL_OBJID,
					  prefix="PARDEL",
					  name=name);
	        else  as$printer_set_name(objid=NULL_OBJID,
					  prefix="PAREXT",
					  name=name);

    /*| give the parent name */

    for (icount=0 ; icount<par_mod ; icount++)
      {
      as$printer_get_name(objid=list->objid, name=par_name[1+icount]);
      list += 1;
     }
	
    /*| Print the parents and symbology */

    for (icount=0; icount<par_mod+1 ; icount++)
      fprintf(stream,"list[%d]=%s;\n",icount,par_name[icount]);
 
    as$printer_print_symb();

    /*| Print NDplace message for delseg */
    if(typ_mod<0)
      {
      fprintf(stream,"send ASdelseg.place(%d,list,0) to %s;\n\n",par_mod+1,name);
      }

    /* Print place message for modlin  need to find the placement point */

    else
      {
      IGRdouble *ptpt;
      if(par_mod == 2)
        {
        struct ret_struct  extdef,tradef;
        IGRdouble scal1;
        IGRvector v1;

        status = om$send
                   (msg  = message NDnode.NDgive_structure(&msg,&extdef,md_env) ,
                    targetos = (list-2)->osnum,
                    targetid = (list-2)->objid );
        as$status(action = RET_STATUS);

        status = om$send
                   (msg = message NDnode.NDgive_structure(&msg,&tradef,md_env) ,
                    targetos = (list-1)->osnum,
                    targetid = (list-1)->objid );
        as$status(action = RET_STATUS);


       v_sub(tradef.var.point_st.pt,extdef.var.point_st.pt,v1);
      scal1 = v_dot(v1,supdef.var.line_st.v0);
      if( scal1 < 0 )  typ_mod = 1-typ_mod ;
     }
     if(typ_mod == 0) ptpt = supdef.var.line_st.p0;
     else ptpt = supdef.var.line_st.p1;

    /*"extend point %d\n",typ_mod*/

     for (icount=0; icount<3 ; icount++)
       fprintf(stream,"ptr[%d]=%lf;\n",icount,*(ptpt+icount));
    fprintf(stream,"send ASextseg.place(%d,list,ptr) to %s;\n\n",par_mod+1,name);
    }

  }/* end loop on modifier */
  return(OM_S_SUCCESS);
}/* end NDprint */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                           method ASmod_erase_mod                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  *msg = MSSUCC;
  ex$message( buff     = info->type,
              msgnumb = AS_I_ParDelOSg);
  return(OM_S_SUCCESS);
}/* end method GRgetobjinfo */


method NDgive_structure(IGRlong *msg; struct ret_struct *str;
			struct GRmd_env *md_env )
{
 IGRint status;
 struct GRid supp;
 IGRint count;

 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,&supp,1,
						     NULL,0,1,&count),
		  targetid = my_id);
 if(count<1) status = OM_W_ABORT;
 as$status(action = RET_STATUS);

 status = om$send(msg = message NDnode.NDgive_structure(msg, str, md_env ),
		  targetid = supp.objid,
		  targetos = supp.osnum);
 as$status();
 return status;
}
end implementation ASmodlin;
