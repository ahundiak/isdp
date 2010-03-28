/*
  AC	sym_util.I
  robert patience
  21_jul_86
*/
class implementation ACsym;

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"
#include "acmacros.h"
#include "grownmacros.h"
#include "exmacros.h"

extern IGRint ASgive_size_st();
extern char *strpbrk();

#define AS_DEBUG

from ACpretgo import ACplace;
from ACmacro_defn import ACintpt_foot,	ACintpt_foot_dir, 	
		ACgive_feet_desc,	ACgive_upscan, 		
		ACgive_temp_desc,		
		ACconnect_compute,      ACmap_test,
		ACunmap_hdr, 		ACmap_to_hdr,
		ACgive_inst_defn, 	ACgive_name;
from ACcomplex import ACget_other;

/* ========================================================================= */

method ACmap_to_defn()
{
  int 		status,mapped;
  struct GRid 	*tlist;
  int 		size;
  struct GRid		mygrid;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

  status = om$send( msg = message ACmacro_defn.ACmap_test(mygrid,&mapped),
                      targetid=mac_def.objid,targetos=mac_def.osnum);
  as$status( action = RET_STATUS );
  if(!mapped)
   {
   status =om$get_channel_count( objid = my_id,
				p_chanselect = &AC_template_chns,
				count = (OMuint *)&size );
   as$status( action = RET_STATUS );

   if(size==0)
   {
    printf("ACsym.ACmap_to_defn no parents\n");
    return(0);
   }
   if(size)
   {
    tlist = (struct GRid *) om$malloc (size = (size) * sizeof( struct GRid ));
   }
   ACmagic_read(my_id, &AC_template_chns, tlist, size);

   status = om$send( msg = message ACmacro_defn.ACmap_to_hdr(mygrid,tlist),
                      targetid=mac_def.objid,targetos=mac_def.osnum);
   as$status( action = CONTINUE );

   if(size) om$dealloc(ptr = tlist);
  }
  return(1);
}

method ACunmap_fr_defn()
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
 

 return (status);
}
/* ========================================================================= */

/* ========================================================================= */

method ACplace(int *suc, prop; 	char *macro_name;
	       int num_temp; 	struct GRid *temp_list)
{
  struct GRmd_env	md_env;
  IGRlong 		S1,S2;
  int 			msg,status;

  S1 = sizeof (struct GRmd_env);
  status = gr$get_module_env(	msg    = &msg,
                    		sizbuf = &S1,
                    		buffer = &md_env,
                    		nret   = &S2 );
  as$status(action = RET_STATUS );

  status = om$send(msg = message ACsym.ACmplace(suc,prop,macro_name,num_temp,
							temp_list,&md_env),
	 	   targetid = my_id );
  as$status(action = RET_STATUS );
  return(1);
}

/* ========================================================================= */
#define acfail() \
    status = om$send(msg = message ACsym.NDdelete(&emp_env), \
		       targetid = my_id ); \
    as$status(action = RET_STATUS); \
    return(1);

method ACmplace(int *suc, prop; 	char *macro_name;
	       	int num_temp; 		struct GRid *temp_list;
		struct GRmd_env *md_env)
{
  int			cn_type;
  int 			status,i;
  long 			msg;
  struct GRmd_env	emp_env;


  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;

  if(!(prop&AChdr_noprotect))
  {
    for( i=0;i<num_temp;i++ )
      as$make_source( 	go_grid = temp_list[i],
			as_os   = temp_list[i].osnum,
		        as_grid = &temp_list[i] );
  }

  status = om$send( msg = message NDnode.NDconnect( num_temp, temp_list, 
					      NULL_GRID, ND_NEW),
		    targetid = my_id);
  as$status( );

  status = om$send(msg = message ACsym.ACattach(suc,macro_name),
		   targetid = my_id );
  as$status(action = RET_STATUS);
  if(*suc!=1) {acfail()}

  /* copy vissible data and init internal variable length structures */

  status = om$send(msg = message ACsym.ACrebuild(suc,&emp_env),
		     targetid = my_id );
  as$status(action = RET_STATUS);
  if(*suc!=1) {acfail()}

  if(prop&AChdr_nocompute)return(1);
  {
    /*| NDs_compute */
    cn_type =ND_COMP;
    status = om$send(msg = message ACsym.NDcompute_node(&msg,  cn_type,
							  num_temp ,temp_list, 
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
#define st_list_sz 10
static struct GRid cplist[st_list_sz];

copy_graphics(macro, dest_id, cont1)
struct GRid 		dest_id, macro;
struct GRmd_env 	*cont1;
{
  OM_S_OBJID 		dum;
  struct GRid		*list,active_owner;
  int 			count, i, status, actmsg;
  long 			dmsg;
  IGRlong 		msg,j;
  extern IGRboolean 	ASbroadcast_in_progress;
  IGRboolean 		save_br;
  struct GRmd_env	macro_env;

  macro_env= *cont1;
  macro_env.md_id.osnum=macro.osnum;

  j=OM_K_MAXINT;

  status =om$get_channel_count( objid = macro.objid,osnum=macro.osnum,
			  	p_chanselect = &AC_mto_graf_chns,
			  	count = (OMuint *)&count );
  as$status( action = RET_STATUS);

  if(!count) return OM_S_SUCCESS;
  
  if(count<=st_list_sz)
	list= cplist;
  else
        list= ( struct GRid *)
 		om$malloc ( size = count * sizeof( struct GRid ));
  ACread(macro, &AC_mto_graf_chns,list,count);

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);  
   
  save_br=ASbroadcast_in_progress;
  ASbroadcast_in_progress=TRUE;
  for(i=0;i<count;i++)
  {
    status = om$send(msg =  message GRgraphics.GRcopy ( &dmsg,
                                             &macro_env, cont1, &dum ),
		     senderid = dest_id.objid,
                     targetid = list[i].objid,targetos=list[i].osnum );
    as$status(  action = GOTO_VALUE,        
		value = wrapup );

    /*" connect graphic %d to %d\n", list[i].objid, dest_id.objid */

    status = om$send(msg = message GRconnector.GRrigidconn( &msg,&dest_id,&j),
		     senderid = dest_id.objid,
	             targetid = dum,targetos=dest_id.osnum );
    as$status(  action = GOTO_VALUE,        
		value = wrapup );

   if( msg != MSSUCC ) 
    printf(" GRrigidconn msg  %x \n",msg);
    /* " GRrigidconn msg  %d \n",msg  */
  }

wrapup :
  if(actmsg == MSSUCC) gr$put_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(count > st_list_sz)  om$dealloc( ptr = list )  ;
  ASbroadcast_in_progress =save_br;
  return OM_S_SUCCESS;
}

/* ========================================================================= */

method ACrebuild(int *suc ;struct GRmd_env *md_env )
{
  int 			status;
  struct GRid		mygrid;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

  copy_graphics(mac_def,mygrid,md_env);

  /* initialize saved instance data */
  {
    char 	*p_inst;
    int 	vla_sz;

    status = om$send(msg = message ACmacro_defn.ACgive_inst_defn(
						&(me->inst_sz), &p_inst ),
		     targetid=mac_def.objid,targetos=mac_def.osnum);
    as$status( action = RET_STATUS );

    if(me->inst_sz)
    {
      vla_sz = om$dimension_of(varray=ME.ACsym->inst_save);
      if(me->inst_sz > vla_sz)
      { 
        status = om$vla_set_dimension(varray= ME.ACsym->inst_save,size =me->inst_sz);
        as$status( msg =  "ACsym.ACrebuild vla inst" );
      }
      OM_BLOCK_MOVE( p_inst , me->inst_save ,me->inst_sz);
     }
  }
  *suc=1;

  /* init xform to closed */
  me->xform_chan=-1;
  return(1);
}



/* ========================================================================= */

method  NDcompute_node ( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env)
{
  int 			tot_up,prop,status,int_out_ch;
  struct GRid		mygrid;
  struct GRmd_env	emp_env;
  struct sup *xdup;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);

  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;
  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

   if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	       string =("element %d not updated because degraded\n",my_id));
    return(OM_W_ABORT);}

  status = om$send(msg = message ACmacro_defn.ACgive_upscan(&tot_up,&prop,&xdup),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );
  if(tot_up!=count )
   {
   printf("Macro lost template required %d found %d degrading!!!\n",tot_up,count);
   NDdegraded_dep(mygrid); 
   /* disable broad cast */
   }
   

  /*" list size = %d\n",count */
  /* test return structures are made */
  if(!(me->STATE & sym_rtn_built ))
  {
    status = om$send(msg = message ACsym.ACtbuild_rtn_str( count, list),
		     targetid = my_id );
    as$status( action = RET_STATUS );
  }

   if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	       string =("element %d not updated because degraded\n",my_id));
    return(OM_W_ABORT);}
   
  if(!IF_EQ_OBJID(md_env->md_id.objid,NULL_OBJID))
    status = om$send(msg =  message GRgraphics.GRremwrng(msg,md_env),
			  	p_chanselect = &AC_mto_graf_chns);

  int_out_ch=0;
  status = om$send(msg = message ACmacro_defn.ACconnect_compute(
				msg,cn_type,count,mygrid,list, 
				me->rtstr, &emp_env,
				&int_out_ch,&(me->inst_sz),me->inst_save),
		  targetid=mac_def.objid,targetos=mac_def.osnum);
  as$status(action = RET_STATUS);

  if(!IF_EQ_OBJID(md_env->md_id.objid,NULL_OBJID))
   status = om$send(msg = message GRgraphics.GRaddwrng(msg, md_env),
			  	p_chanselect = &AC_mto_graf_chns);

  status = om$send( msg = message ACcpx.ACload_temp_feet(count, list, md_env),
	     	      targetid = my_id);
  as$status( action = RET_STATUS );

  return ( OM_S_SUCCESS );
}

/* ========================================================================= */
#define path_MAX_CHAR 80

method ACgive_structure(int *suc,*direct_index;char *foot_name;
	struct ret_struct *ptr_rst;struct GRmd_env *md_env )
{
  int 		pos, chan, type ,index, status,i;
  char 		*chpos, chtemp[path_MAX_CHAR],fttemp[path_MAX_CHAR];
  struct 	GRid 	obj;
  struct GRid mac_def;

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);



  *suc=0;
  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	    string =("element %d degraded doesn't return structure of %s\n",
                      my_id,foot_name));
    return(OM_W_ABORT);}

/*^
 {
  char 		*macro_name;
  status = om$send( msg = message ACmacro_defn.ACgive_name( &macro_name ),
                      targetid=mac_def.objid,targetos=mac_def.osnum);
  as$status( action = RET_STATUS );
   printf("ACgive %s -> %s \n",macro_name,foot_name);
 }
*/
  
  if(!(me->STATE & sym_rtn_built ))
   {
   /*"ACsym.ACgive_structure failed at %d \n",pos */
   status = om$send(msg = message ACsym.ACbuild_rtn_str(md_env,ND_COMP ), 
		       targetid = my_id);
   as$status( action = RET_STATUS );
   }

  if(direct_index && *direct_index != -1)
   {
   if(me->rtstr[*direct_index])
    {
    /*" load ext direct_index %d,pointer %d\n",*direct_index,me->rtstr[*direct_index]*/
    OM_BLOCK_MOVE( (char *)(me->rtstr[*direct_index]),  
  		((char *) (ptr_rst)),
		ASgive_size_st(me->rtstr[*direct_index]->type));
    *suc=1;

/* jla 06-june-90 when ACgive_structure is accross reference file */
  if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
							
    return(1);
    }
   }

  if(chpos=strpbrk(foot_name,":"))
   {
   int mapped,msg;
   struct GRid		mygrid;
   mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;
   
    status = om$send( msg = message ACmacro_defn.ACmap_test(mygrid,&mapped),
                      targetid=mac_def.objid,targetos=mac_def.osnum);
     as$status( action = CONTINUE );
     if(mapped!=2)
      {
       struct GRmd_env rd_env;
     /*" executing compute  %d\n",mapped */

     /*
      Modif jla 06-June-1990 : The object must be evaluated in the units of
      the ACcpx file and not using some transformation matrix when the ACcpx
      is in a reference file
     */

      ex$get_modid( mod_osnum = OM_Gw_current_OS,
                    mod_id    = &rd_env.md_id.objid);
      rd_env.md_id.osnum = OM_Gw_current_OS;
      rd_env.md_env.matrix_type = MAIDMX;
      MAidmx(&msg,rd_env.md_env.matrix);

      status = om$send(msg = message ACsym.NDs_compute_node((IGRlong *)&msg, ND_COMP , 
  								&rd_env),
  		   targetid = my_id );
      as$status ( action = RET_STATUS );
      }
    
   if( *(chpos+1)=='_')
    {
      strcpy(chtemp,"dim");
      strcat(chtemp,chpos+1);
    }
    else
      strcpy(chtemp,chpos+1);  

    strcpy(fttemp,foot_name);  
    chpos=strpbrk(fttemp,":");
    *chpos=0; i=-1;

    status = om$send(msg =  message ACcpx.ACgive_foot(suc,fttemp,&obj),
		   targetid = my_id );
    as$status( action = RET_STATUS );
    status = om$send(msg =  message ACcpx.ACgive_structure(suc,&i,chtemp,
							ptr_rst,md_env),
        	   targetid = obj.objid ,targetos=obj.osnum);
    as$status( action = RET_STATUS );
    return(1);
   }

  status = om$send( msg = message ACmacro_defn.ACintpt_foot_dir(suc,
			direct_index, foot_name, &chan,&pos, &type,&index),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );

  if(*suc!=1)
    return(1);

  if(chan == feet_virtual)
  {
    OM_BLOCK_MOVE(  ((char *) (me->rtstr[index])), (char *)ptr_rst,
		ASgive_size_st(me->rtstr[index]->type));
    /*"	loading internal from pos %d type %x \n",pos,ptr_rst->type */
    *suc=1;

/* jla 06-june-90 when ACgive_structure is accross reference file */
    if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
  }
  else if(chan == feet_numeric)
  {
    struct GRid ft_obj;

    status = om$send(msg = message ACsym.ACgive_foot(suc,foot_name,&ft_obj),
		   targetid = my_id );
    as$status( action = RET_STATUS );
    status = ASany_give_struct( ft_obj.objid,ft_obj.osnum,md_env, ptr_rst );
    if(!(status&1)) *suc = 0;
  }
  else if(chan == feet_in_template)
  {
   /*" load ext index %d,pointer %d\n",index,me->rtstr[index]*/
   OM_BLOCK_MOVE( (char *)(me->rtstr[index]),  
  		((char *) (ptr_rst)),
		ASgive_size_st(me->rtstr[index]->type));
   if(md_env->md_env.matrix_type != MAIDMX) AStrans_rst(ptr_rst,
						       md_env->md_env.matrix);
  }
  return(1);
}

/* ========================================================================= */

method ACreturn_foot(IGRlong  *suc;char *foot_name; struct GRid *foot_obj;
                     IGRshort *mat_type;IGRdouble *matrix)

		     
{
  int		pos, chan, type, status,loc_msg; 
  struct GRid 	mac_def;
  char 		*chpos, chtemp[path_MAX_CHAR],fttemp[path_MAX_CHAR];
  struct GRid   obj;

  *suc=0;
  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	       string =("element %d degraded doesn't return foot %s\n",
			my_id,foot_name));
    return(OM_W_ABORT);}

  if(!(me->STATE & sym_rtn_built ))
   {
   /*"ACsym.ACgive_foot not returned structures  %s \n",foot_name */
/* 
   status = om$send(msg = message ACsym.ACbuild_rtn_str(0,ND_COMP ), 
		       targetid = my_id);
   as$status( action = RET_STATUS );
*/
   }

  if(chpos=strpbrk(foot_name,":"))
  {
    if( *(chpos+1)=='_')
    {
      strcpy(chtemp,"dim");
      strcat(chtemp,chpos+1);
    }
    else
      strcpy(chtemp,chpos+1);  

    strcpy(fttemp,foot_name);  
    chpos=strpbrk(fttemp,":");
    *chpos=0; 

    status = om$send(msg =  message ACcpx.ACreturn_foot(suc,fttemp,&obj,
						        mat_type,matrix),
		    targetid = my_id );
    as$status(action = RET_STATUS );

    status = om$send(msg =  message ACcpx.ACreturn_foot(suc,chtemp,
						foot_obj,mat_type,matrix),
        	    targetid = obj.objid ,targetos = obj.osnum);
    as$status(action = RET_STATUS );
    return(1);
  }

  status = om$send(msg = message ACcpx.find_macro(&mac_def),
		   targetid = my_id );
  as$status(action = RET_STATUS );

  status = om$send(msg = message ACmacro_defn.ACintpt_foot((int *)suc,foot_name,
						&chan,&pos, &type),
		   targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status(action = RET_STATUS );

  if(*suc!=1)return(1);
  if(chan == feet_virtual || chan == feet_numeric)
  {
    status = om$send(msg = message ACsym.ACmap_to_defn(),
  		   targetid = my_id); 
    as$status( action =RET_STATUS );


/*
/*  AC_mother channnel removed in 2.0 
/*     status = om$get_objid_at_index( objid 	= mac_def.objid,
/* 				    osnum       = mac_def.osnum,
/*                                  p_chanselect	= &AC_mother_chns,
/*                                  index 	= pos,
/*                                  objidaddr 	= &(foot_obj->objid),
/*				  osnumaddr 	= &(foot_obj->osnum) );
/*    as$status(action = RET_STATUS );
/********/
    {
     int nb_other;
     OM_S_OBJID *other;
     status = om$send(msg = message ACcomplex.ACget_other
					   ((long *)&loc_msg,&nb_other,&other),
		     targetid = mac_def.objid,
		     targetos = mac_def.osnum);
     if(!(status&loc_msg&1) || pos >= nb_other) return OM_W_ABORT;
     foot_obj->objid = other[pos];
     foot_obj->osnum = mac_def.osnum;
    }

    /*"	loading giving from pos %d foot %d \n",pos,foot_obj->objid */
    *suc=temp_assoc_foot;
  }
  else
  {
    status = om$send(msg = message ACcpx.ACfind_exp_temp_obj((int *)suc, pos,
								foot_obj),
		     targetid = my_id );
    as$status(action = RET_STATUS );
  }
  if(mat_type != NULL)  *mat_type = MAIDMX;
  if(matrix != NULL)  MAidmx(&loc_msg,matrix);

  return(1);
}

/* ========================================================================= */

method ACgive_path(int *suc;struct GRid *go_obj;char *footname)
{
  struct GRid 		mac_def,rgo;
  struct GRid		target;
  OM_S_OBJID		*other;
  int 			status,size,i,j,feet_num;
  GRclassid 		target_cl;
  struct myfeet 	*feet;
  char			term,dum[80];
  extern GRclassid 	OPP_AScontents_class_id;
  long loc_msg;

  footname[0]=0;
  *suc=0;

  status = om$send(msg = message ACsym.find_macro(&mac_def),
 		     targetid = my_id );
  as$status(action = RET_STATUS );

  status = om$send(msg = message ACsym.ACmap_to_defn(),
  		   targetid = my_id); 
  as$status( action =RET_STATUS );


/*  status =om$get_channel_count( objid = mac_def.objid,
/*				osnum = mac_def.osnum,
/*				  p_chanselect = &AC_mother_chns,
/*				  count = &size );
/********/

   status = om$send(msg = message ACcomplex.ACget_other
						    (&loc_msg,&size,&other),
		     targetid = mac_def.objid,
		     targetos = mac_def.osnum);
  as$status(action = RET_STATUS);
  for(i=0;i<size;i++)
  {
/*    status = om$get_objid_at_index (	objid 		= mac_def.objid,
/*					osnum 		= mac_def.osnum,
/*                                  	p_chanselect 	= &AC_mother_chns,
/*                                  	index		= i,
/*                                  	objidaddr	= &(target.objid),
/*				  	osnumaddr	= &(target.osnum));
/*    as$status( action = RET_STATUS );
/*****/
    target.objid = other[i];
    target.osnum = mac_def.osnum;
    om$get_classid(objid=target.objid,osnum=target.osnum,
				p_classid = &target_cl);
    if(om$is_ancestry_valid(subclassid =target_cl ,
                           superclassid = OPP_ACcpx_class_id) == OM_S_SUCCESS)
    {
      status = om$send(msg = message ACcpx.ACgive_path(suc,go_obj,footname),
			targetid = target.objid,targetos=target.osnum);
      as$status( action = RET_STATUS );

      if(*suc==1) {term=':';break;}
    }
    else if(om$is_ancestry_valid(subclassid =target_cl ,
                       superclassid = OPP_AScontents_class_id) != OM_S_SUCCESS)
    {
      status=om$send( msg = message  NDnode.ASreturn_go
		    (&rgo,NULL,NULL),
      		    targetid = target.objid,targetos=target.osnum);
      if((status&1) &&
         IF_EQ_OBJID(go_obj->objid,rgo.objid)) {*suc=1;term=0;break;}
    }
  }

  if(*suc==1)
  {
    /* prepare my returned structures */
    status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
		   (&feet_num, &feet),
		     targetid=mac_def.objid,targetos=mac_def.osnum );
    as$status();
    sprintf(dum,"%d",i);
    for(j=0;j<feet_num;j++)
    {
      if(feet[j].pos==i && feet[j].chan==feet_virtual)
      {
        strcpy(dum,feet[j].name);break;
      } 
    }
    /*"ACgive_path dum %s \n",dum */
    dum[strlen(dum)+1]=0;
    dum[strlen(dum)]=term;
    strcat(dum,footname);
    strcpy(footname,dum);
    /*"ACgive_path %s \n",footname */
  }
  return(1);
}

#define recovery() \
  printf("ACsym.ACchange attempting recovery\n"); \
  status = om$send(msg = message ACsym.ACload_macro(old_macro), \
		   targetid = my_id); \
  as$status( action = RET_STATUS ); \
  status = om$send(msg = message ACsym.ACrebuild(suc, md_env), \
		   targetid = my_id); \
  as$status( action = RET_STATUS ); \
  return(1);

/* ========================================================================= */

method  ACchange(int *suc,prop;char *full_name; struct GRmd_env *md_env)
{
  long 			msg;
  int 			status;
  struct GRid 		old_macro;
  struct GRmd_env	emp_env;
  struct GRid		mygrid;

  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;

  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;

  status = om$send(msg = message ACcpx.find_macro(&old_macro),
		   targetid= my_id );
  as$status(action = RET_STATUS );

  status = om$send( msg = message ACmacro_defn.ACunmap_hdr(mygrid),
		      targetid=old_macro.objid,targetos=old_macro.osnum );
  as$status( action = RET_STATUS );



  status = om$send(msg = message NDnode.NDdisplay(0,GRbe, md_env),
		     targetid = my_id );
  as$status( action = RET_STATUS );

  nd$get_graph( p_root = &mygrid, nb_root = 1);
  nd$broadcast_graph( p_msg = message NDnode.NDdisplay(0,GRbe, md_env) );

  if((me->STATE & sym_rtn_built ))
  {
    status = om$send(msg = message ACsym.ACfree_rtn_str(),
		     targetid = my_id );
    as$status( action = RET_STATUS );
  }

  status = om$send (msg = message GRgraphics.GRdelete ( &msg, md_env ), 
		     	p_chanselect = &AC_mto_graf_chns );
  as$status ( action = RET_STATUS );


  status = om$send(msg = message ACsym.ACattach(suc, full_name),
		   targetid = my_id );
  as$status ( action = RET_STATUS );

  if(*suc!=1){  recovery() } ;

  status = om$send(msg = message ACsym.ACrebuild(suc, &emp_env),
		   targetid = my_id );
  as$status ( action = RET_STATUS );

  if(*suc!=1){  recovery() } ;

  if(prop&AChdr_nocompute)return(1);

  status = om$send(msg = message ACsym.NDs_compute_node(&msg, ND_COMP , 
								&emp_env),
		   targetid = my_id );
  as$status ( action = RET_STATUS );

  status = om$send(msg = message GRgraphics.GRaddwrng(&msg, md_env),
			  targetid =my_id);
  as$status();

  if(prop&AChdr_nodisplay)return(1);
  status = om$send(msg = message NDnode.NDdisplay(0,GRbd, md_env),
		   targetid = my_id);
  as$status ( action = RET_STATUS );

  status = om$send(msg = message NDnode.NDchange_node(md_env),
		   targetid = my_id);
  as$status ( action = RET_STATUS );

  return(1);
}
/* ========================================================================= */

method  ACchange_intn(int *suc,prop;char *full_name; struct GRmd_env *md_env;
                      OM_S_OBJID *list;int *count;
                      int *sz_inst_save;char *inst_save)
{
  int 			status, i, obj_cnt,inst_size;
  struct GRid 		macro;
  struct GRmd_env	emp_env;

  emp_env = *md_env;
  emp_env.md_id.objid=NULL_OBJID;


  status = ac$find_macro_defn( action		= ACfind_load,
		      	       macro_name 	= full_name,
		      	       p_macro_defn_id 	= &macro );

  /* add macro info to arrays */

  {
  struct GRid		*xlist,active_owner;
  long 			dmsg;
  int 			status, actmsg;
  extern IGRboolean 	ASbroadcast_in_progress;
  IGRboolean 		save_br;

  status =om$get_channel_count( objid = macro.objid,
				osnum = macro.osnum,
			  	p_chanselect = &AC_mto_graf_chns,
			  	count = (OMuint *)&obj_cnt );
  as$status( action = RET_STATUS);

  if(obj_cnt)
   {
   xlist= ( struct GRid *)
 		om$malloc ( size = obj_cnt * sizeof( struct GRid ));
   ACread(macro, &AC_mto_graf_chns,xlist,obj_cnt);
   save_br=ASbroadcast_in_progress;
   ASbroadcast_in_progress=TRUE;
   gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
   if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);  
   for(i=0;i<obj_cnt;i++)
    {
    status = om$send(msg =  message GRgraphics.GRcopy ( &dmsg,
                                             &emp_env,&emp_env,&list[i+*count]),
		     senderid = my_id,
                     targetid = xlist[i].objid,targetos=xlist[i].osnum );
    as$status(  action = GOTO_VALUE,
		value = wrapup );
    /*" connect graphic %d to %d\n", xlist[i].objid, list[i] */
    }  
wrapup :
   if(actmsg == MSSUCC) gr$put_active_owner ( msg=&actmsg,active_owner=&active_owner);
   om$dealloc( ptr = xlist )  ;
   ASbroadcast_in_progress =save_br;
   }

  *count += obj_cnt;
  }

  {
  char *dpbuf;
  int dpsize;

    status = om$send(msg = message ACmacro_defn.ACgive_inst_defn(
						&(dpsize), &dpbuf),
		     targetid = macro.objid,targetos=macro.osnum );
    as$status( action = RET_STATUS );
    inst_size=0;
    status = om$send(msg = message ACsym.ACcon_s_inst(
	&(inst_size),&(inst_save[*sz_inst_save]),
	dpsize,obj_cnt,dpbuf,full_name),
		     targetid = my_id );
    as$status( action = RET_STATUS );
  *sz_inst_save += inst_size;
  }


  return(1);
}

/* ========================================================================= */

method ACchange_feet(int *suc,numb;char **feet_name,**macro_name;
		      struct GRmd_env *md_env )
{
  int 		i, j,status,feet_num;
  long 		rc;
  struct myfeet 	*feet;
  struct GRid 		mac_def;
  OM_S_OBJID 	*list;
  int 		count,cur_objn,cur_inst,wkft;
  char 		*inst_save;
  struct GRid		mygrid;

  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;
  
  *suc=0;
  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	       string =("element %d degraded doesn't change feet\n",my_id));
    return(OM_W_ABORT);}

  *suc=1;

  status = om$send(msg = message ACcpx.find_macro(&mac_def),
		   targetid = my_id );
  as$status( action = RET_STATUS );

  status = om$send(msg = message ACmacro_defn.ACunmap_hdr(mygrid),
                      targetid=mac_def.objid,targetos=mac_def.osnum);
  as$status( action = RET_STATUS );

  status = om$send (msg = message GRgraphics.GRdelete ( &rc, md_env ), 
		     	p_chanselect = &AC_mto_graf_chns );
  as$status( action = RET_STATUS );

  status = om$send( msg = message ACmacro_defn.ACgive_feet_desc(&feet_num, &feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );


  cur_objn=20;
  cur_inst=800;
  inst_save= om$malloc( size = cur_inst);
  list= (OM_S_OBJID *) om$malloc(size = cur_objn *sizeof(OM_S_OBJID)); 
  count=0;
  me->inst_sz=0;
  wkft=0;
  while(wkft!=numb)
  {
  for(j=0;j<feet_num;j++)
   {
    if(wkft==feet[j].pos)
    {
     for(i=0;i<numb;i++)
     {
      if(!strcmp(feet_name[i],feet[j].name))
      {
      /*"ACprepare_feet %s %s  \n",feet_name[i],macro_name[i] */
      status = om$send(msg = message ACsym.ACchange_intn(suc,AChdr_nocompute,
						macro_name[i], md_env,
                   list,&count,&(me->inst_sz),inst_save),
		       targetid = my_id );
      as$status( action = RET_STATUS );
      if(*suc!=1)
        { printf("ACchange_feet failed \n");break;}
      break;
      }
     }
    break;
    }
   }
  wkft+=1;
  }
  /*" dim_kludge objcnt %d size inst %d\n", count, me->inst_sz */

  status = om$vla_set_dimension(varray= me->inst_save,
                             size = me->inst_sz );
  as$status( action = RET_STATUS );

  /*| fill val */
  OM_BLOCK_MOVE( inst_save , me->inst_save ,me->inst_sz);

  {
    IGRlong 		flag,j;
    struct GRid 	mygrid;
 
    flag=1;
    mygrid.osnum=OM_Gw_current_OS;
    mygrid.objid=my_id;
    j=OM_K_MAXINT;
    for(i=0;i<count;i++)
    {
      /*" connect graphic %d to %d\n", list[i], my_id */
      status = om$send(msg = message Root.connect( AC_mto_graf_chns,0,
					list[i],OM_Gw_current_OS,
					AC_mfrom_graf_chns,OM_K_MAXINT),
	             targetid = my_id);
      as$status( action = RET_STATUS );
    }
  }
  om$dealloc(ptr = list);
  om$dealloc(ptr = inst_save);


  *suc=1;
  /* init xform to closed */
  me->xform_chan=-1;

  return(1);
}




end implementation ACsym;

