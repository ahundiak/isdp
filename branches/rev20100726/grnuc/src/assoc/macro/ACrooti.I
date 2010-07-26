/*
  ACroot_util.I
  robert patience
  21_jul_86
*/
class implementation ACroot;

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"
#include "grownmacros.h"
#include "ASmsg.h"
#include "msmacros.h"


extern IGRint ASgive_size_st();
extern char *strpbrk();
extern GRclassid OPP_ACcpx_defn_class_id;

#define AS_DEBUG

from ACmacro_defn import ACintpt_foot_dir,ACintpt_foot,	ACgive_name,	
		ACgive_feet_desc,	ACgive_upscan, 		
		ACgive_temp_desc;

/* ========================================================================= */

method ACplace( int *suc,prop; 	char *macro_name;
		int numb_obj;  	struct  GRid  *grp_objs;
		int feet_num;  	struct ret_struct *fts )
{
  int 			status;
  struct GRmd_env	md_env;

  status = om$send(msg = message ACroot.ACmplace( suc, prop, macro_name,
				numb_obj, grp_objs, feet_num, fts, &md_env),
	           targetid = my_id );
  as$status( action =  RET_STATUS );   
  return(1); 
}

/* ========================================================================= */

method ACmplace( int *suc,prop; 	char *macro_name;
		int numb_obj;  	struct  GRid  *grp_objs;
		int feet_num;  	struct ret_struct *fts;
		struct GRmd_env *md_env)
{
  int 			i, j, status;
  struct GRid 		tmp;
  GRclassid mac_def_class;
  struct GRid mac_def;

  tmp.osnum=OM_Gw_current_OS;tmp.objid=my_id;
  j=OM_K_MAXINT;

/* modif jla 23-aug-89 for copy_to_root */

if(macro_name != NULL)
 {
  status = om$send(msg = message ACroot.ACattach(suc,macro_name),
		   targetid = my_id );
  as$status( action =  RET_STATUS );
 }
else
 {
  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


  status = om$get_classid(objid = mac_def.objid,
			  osnum = mac_def.osnum,
			  p_classid = &mac_def_class);
  if(om$is_ancestry_valid(superclassid = OPP_ACcpx_defn_class_id,
			  subclassid = mac_def_class) == OM_S_SUCCESS) *suc = 1;
  else								       *suc = 0;

 }

  if(*suc!=1)
  {
    status = om$send(msg = message ACroot.NDdelete(md_env),
		     targetid = my_id );
    as$status( action =  RET_STATUS );
    return(1);
  }
 
  for(i=0;i<numb_obj;i++)
  {
    /*" connect graphic %d to %d\n",grp_objs[i].objid , my_id */

    status = om$send(msg = message Root.connect(AC_mto_graf_chns,OM_K_MAXINT,
					grp_objs[i].objid , grp_objs[i].osnum ,
		       			AC_mfrom_graf_chns, OM_K_MAXINT),
	             targetid = my_id );
    as$status( action =  RET_STATUS );   
  }
  status = om$vla_set_dimension(varray= me->fts,
                             size = feet_num );
  as$status( action = RET_STATUS );

  for(i=0;i<feet_num;i++)
  {
/*    me->fts[i]=fts[i];*/
    /*"root_type %#x address %d \n",fts[i].type,&fts[i].type  */
      OM_BLOCK_MOVE((char *)&fts[i], (char *) (&(me->fts[i])), 
		ASgive_size_st(fts[i].type));
  }
  return(1);
}

/* ========================================================================= */

method ACgive_structure(int *suc,*direct_index;char *foot_name;
	struct ret_struct *ptr_rst; struct GRmd_env *md_env )
{
  long status;
  struct myfeet 	*feet;
  int 			feet_num, i;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

    
  status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
  			(&feet_num, &feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

/*
   jla 02-08-89  important because some pretend name have been lost in the
   1.1 --> 1.2 translation 
*/
 
if( direct_index && *direct_index > -1 && *direct_index <feet_num)
 {
  OM_BLOCK_MOVE( (char *) (&(me->fts[*direct_index])), (char *)ptr_rst,
                ASgive_size_st(me->fts[*direct_index].type));
  *suc=1;

/* jla 06-june-90 when ACgive_structure is accross reference file */
  if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
							
  return(1);
 }
else
 {
  for(i=0;i<feet_num;i++)
  {
    if(!strcmp(foot_name,feet[i].name))
    {
      /*"root_type %#x \n",me->fts[i].type */
      /*     *ptr_rst = (me->fts[i]); */
      OM_BLOCK_MOVE( (char *) (&(me->fts[i])), (char *)ptr_rst,
		ASgive_size_st(me->fts[i].type));
      *suc=1;

/* jla 06-june-90 when ACgive_structure is accross reference file */
      if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
      return(1);
     }
  }
  as$status(sts = 0,
	 string =("ACroot %d give_structure failed on %s\n",my_id,foot_name));
  *suc=0;
  return(1);
 }
}
/* ========================================================================= */

method ACreturn_foot(IGRlong *suc;char *foot_name; struct GRid *foot_obj;
		     IGRshort *mat_type;IGRdouble *matrix)
{
  int		msg, junk,status, loc_msg;
  struct GRmd_env	md_env;
  IGRlong 		S1,S2;
  struct ret_struct 	large;
  IGRlong actmsg;
  struct GRid active_owner;
  int		pos, chan, type;
  struct GRid 	macro;
  
  status = om$send(msg = message ACcpx.find_macro(&macro),
		      targetid = my_id );
  as$status( action = RET_STATUS );

  status = om$send(msg= message ACmacro_defn.ACintpt_foot((int *)suc,foot_name,
					&chan,&pos, &type),
		      targetid = macro.objid ,targetos = macro.osnum);
  as$status( action = RET_STATUS );

  if(!(*suc))return(1);
  if(chan == feet_in_graphic )
   {
   *suc=0;
   status = om$get_objid_at_index( objid 	= my_id,
                                  p_chanselect	= &AC_mto_graf_chns,
                                  index 	= pos,
                                  objidaddr 	= &(foot_obj->objid),
				  osnumaddr 	= &(foot_obj->osnum) );
   as$status( action = RET_STATUS );
   *suc = graphic_foot;
   }
  else
   {
   S1 = sizeof (struct GRmd_env);
   status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &md_env,
                    		nret   = &S2 );
   as$status(action = RET_STATUS );
   as$status(sts = 0,
            string = ("ACroot %d give_foot %s kludge\n",my_id,foot_name));
   junk=-1;
   status = om$send(msg = message ACroot.ACgive_structure
			((int *)suc,&junk,foot_name,&large,&md_env),
  		        targetid = my_id );
   as$status( action = RET_STATUS );
   if(! *suc)return(1);  

   gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
   if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);
   status = ASany_create( &md_env,&large,0,foot_obj);
   if(actmsg == MSSUCC) gr$put_active_owner ( msg=&actmsg,active_owner=&active_owner);
   as$status( );
   *suc=status & 1;
   }

   if(mat_type != NULL)  *mat_type = MAIDMX;
   if(matrix != NULL)  MAidmx(&loc_msg,matrix);


  return(1);
}


/* ========================================================================= */

method ACgive_path(int *suc;struct GRid *go_obj;char *footname)
{
  struct GRid 		mac_def;
  struct GRid		target;
  int 			status,j;
  OMuint 		size,i;
  extern GRclassid 	OPP_AScontents_class_id;

  footname[0]=0;
  *suc=0;

  status = om$send(msg = message ACcpx.find_macro(&mac_def),
 		     targetid = my_id );
  as$status(action = RET_STATUS );

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
    if(IF_EQ_OBJID(go_obj->objid,target.objid)) {*suc=1;break;}
  }

  if(*suc==1)
  {
  struct myfeet 	*feet;
  int feet_num;
    /*"ACgive_path index %d \n",i */
    status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
		   (&feet_num, &feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status();
    for(j=0;j<feet_num;j++)
    {
      if(feet[j].pos==i && (feet[j].chan & 3)==feet_in_graphic)
      {
        strcpy(footname,feet[j].name);break;
      } 
    }
    /*"ACgive_path footname %s \n",footname */
  }
  return(1);
}
/* ========================================================================= */

method NDprint(struct GRmd_env *md_env ; FILE *stream)
{
  int 	status;
 
  status = om$send(msg = message NDnode.NDprint_root(md_env,stream),
		   targetid = my_id );
  as$status( action = RET_STATUS );
  return(1);
}

/* ========================================================================= */

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  char 	*macro_name;
  int	status;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);



  if(status&1)
  status = om$send( msg = message ACmacro_defn.ACgive_name( &macro_name ),
                     targetid=mac_def.objid,targetos=mac_def.osnum);
  *msg = 1;
  if(status&1)
   {
    ex$message(buff=info->type, msgnumb=AS_I_RootCpx );
    strcat( info->type, macro_name );
   }
  else
   {
    ex$message(buff=info->type, msgnumb=AS_I_RootCpxN);
   }
  return( OM_S_SUCCESS );
}

/* ========================================================================= */

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid; 
                      struct GRmd_env *md_env )
{
  src_grid->osnum = OM_Gw_current_OS;
  src_grid->objid = my_id;
  return(1);
}

/* ========================================================================= */

method NDcopy_to_root(IGRlong *msg;int cp_type;struct GRmd_env *fr_env, *to_env;
		      struct GRid *newobjid)
{
 IGRlong status;
 struct GRid owner;

 status = om$send( msg = message NDnode.NDcopy(msg, cp_type, fr_env, to_env, 
						&owner),
                   targetid = my_id );
 as$status(action = RET_STATUS);

 status = om$send( msg = message NDnode.NDmove_to_root(msg, newobjid, 
 		   to_env),
                   targetid = owner.objid, targetos = owner.osnum );
 as$status();
 return(status);
}

/* ========================================================================= */

method  ACbuild_rtn_str( struct GRmd_env *md_env; int cn_type)
{
  return(1);
}

/* ========================================================================= */

method GRxform(IGRlong *msg; struct GRmd_env *obj_dsenv; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 int status;

  status = om$send( msg = message GRvg.GRxform
		(msg,obj_dsenv,matrix_type,matrix,newobjid),
		     p_chanselect=&AC_mto_graf_chns );
  as$status( msg = "ACroot.xfrom->GRvg.xfrom");

  status = om$send(msg = message NDnode.NDchange_node(NULL), 
		targetid = my_id);
  as$status();

  *newobjid=my_id;
  return(1);
}
 
end implementation ACroot;

