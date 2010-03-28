/*
  ACm_dn_util.I
  robert patience
  21_jul_86
*/
class implementation ACmacro_defn;


#include "ASmacroi.h"
#include "macro.h"
#include "exdef.h"
#include "exmacros.h"
#include "grerr.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "ASmsg.h"

#define AS_DEBUG

from ACcpx 	import ACdrop,ACload_macro;
from ACpretdef 	import ACsconnect;
from ACtmp_defn import ACset_mac_name;

/* ========================================================================= */

method ACgive_upscan( int *tot_up,*prop;struct sup **xdup)
{
  *tot_up = me->tot_up;
  *prop   = me->prop;
  *xdup   = &me->xdup[0];
  return( OM_S_SUCCESS );
}

/* ========================================================================= */

method ACtake_template(int tot_up;struct sup *dup;
                	int tot_temp;struct stemp *dtemp)
{
  int 	i,status;

  me->tot_up=tot_up;
  me->tot_temp=tot_temp;

  status = om$vla_set_dimension(varray= me->xdup,
                             size = tot_up );
  as$status( action =RET_STATUS );

  status = om$vla_set_dimension(varray= me->xdtemp,
                             size = tot_temp );
  as$status( action =RET_STATUS );

  for(i=0;i<tot_up;i++)
    me->xdup[i]=dup[i];

  for(i=0;i<tot_temp;i++)
  {
    me->xdtemp[i]=dtemp[i];
    me->xdtemp[i].direct_index=-1;
  }

  {
  int cntt;cntt=0;
  status = om$send ( 	
		msg = message ACpretdef.ACsconnect(me->xdtemp, &cntt), 
		p_chanselect = &AC_template_chns );
/* 
   Above message is sent to all the object connected to super_para object
   on NDfather.father channel. Previously only ACpretdef objects were 
   connected on this channel. But now there are other objects connected which
   do not understand this message. Set the status to success if status is
   unknown message sent. -- Mrudula TR#119303652  04/05/93            
*/
  if (status & OM_W_UNKNOWN_MSG){
    status = OM_S_SUCCESS;
  }
  as$status ( );
  }
  return( OM_S_SUCCESS );
}

method ACtake_feet(int nb_feet; struct myfeet *feet_desc)
{
 long status;
 int i;

 status = om$vla_set_dimension(varray= me->myfeet,
                               size = nb_feet);
 as$status( action =RET_STATUS );

 for(i=0;i<nb_feet;i++)
  {
   me->myfeet[i] = feet_desc[i];
  }
 me->feet_num = nb_feet;
 return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              PRINT  method                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDprint_root( struct GRmd_env *md_env; FILE *stream )
{
  OMuword		osn;
  OM_S_OBJID  		foot_obj = 0,*other;
  struct GRid 		*list, my_grid;
  int         		index, count, i, mapped;
  long			status,loc_msg;
  char        		name[macro_MAX_CHAR];
  int                   nb_other;


  my_grid.objid = my_id; my_grid.osnum = OM_Gw_current_OS;

  /* if nobody is gone someone is here but who ? */
  status = om$send( msg = message ACmacro_defn.ACmap_test( NULL_GRID,
				&mapped	),
		    targetid = my_id);
  as$status();

  if(mapped) return(1);
  status =om$get_channel_count( objid 		= my_id,
				p_chanselect 	= &AC_template_chns,
				count 		= (OMuint *)&count);
  as$status( action = RET_STATUS );

  list = (struct GRid *)
 	  om$malloc (size = count * sizeof( struct GRid ));

  ACmagic_read(my_id, &AC_template_chns, list, count);
  /*" count %d after ACmagic_read\n", count */

  status = om$send( msg = message Root.wild_disconnect( AC_template_chns ),
 	   	    targetid 	= my_id );
  as$status( );

  status = om$send( msg = message ACcomplex.ACget_other
						   (&loc_msg,&nb_other,&other),
		    targetid = my_id);
 
  asprinter_exec_print(count,list);

  for(i=0; i<count; i++)
  {
    status = om$send( msg=message Root.connect(AC_template_chns, OM_K_MAXINT,
                my_id,OM_Gw_current_OS , ND_children, OM_K_MAXINT ),
                    targetid = list[i].objid,targetos = list[i].osnum );
    as$status( action = RET_STATUS );
  }

  fprintf(stream,"\n\n// upscan definition");
  for (i=0; i< me->tot_up;i++)
  {
    fprintf(stream,"\n up[%d]=\"%s\";us[%d]=\"%s\";",
		i,me->xdup[i].prompt,
		i,me->xdup[i].up_scan);
  }
  fprintf(stream, "\n\n// template definition");

  for (index=0 ; index<count; index++)
  {
     as$printer_get_name( objid =list[index].objid,
  			 name = name ); 

    fprintf(stream,"\n TEMP[%d]=%s;",index,name);
    fprintf(stream," tstr[%d]=\"%s\";ds[%d]=\"%s\";map[%d]=%d;",
		index,me->xdtemp[index].name,
		index,me->xdtemp[index].down_scan,
		index,me->xdtemp[index].back);
  }
  fprintf(stream,"\n//  feet definition ");

  for (i=0 ; i<me->feet_num; i++)
  {
    if(me->myfeet[i].chan == feet_in_template)
      foot_obj=list[me->myfeet[i].pos].objid;
    else
    if(!(me->myfeet[i].chan == feet_in_template))
    {
     foot_obj = other[me->myfeet[i].pos];
     osn      = OM_Gw_current_OS;
    }
    as$printer_get_name( objid = foot_obj,
			 name = name);

    /* Print the feet in the file */
    fprintf(stream,"\n FEET[%d]=%s;",i,name);
    fprintf(stream," fstr[%d]=\"%s\";",
		i,me->myfeet[i].name);
  }
  fprintf(stream, 
    "\nsend ACcreate.ACplace(&suc,0,\"%s\",%d,TEMP,tstr,%d,FEET,fstr) to MACHDR;"
     ,me->macro_name,me->tot_temp,
      me->feet_num);
  fprintf(stream, 
    "\nsend ACcreate.ACedit_template(&suc,%d,%d,up,us,tstr,ds,map) to MACHDR;"
    ,me->tot_up, me->tot_temp);
  fprintf(stream, 
    "\nsend ACcomplex.ACremove_all(1) to MACHDR;");

  if( list ) om$dealloc( ptr= list );
  return(1);

}/* end ACprint_macro method */

/* ========================================================================= */

method NDgive_structure(long *msg; struct ret_struct *str;
                        struct GRmd_env *md_env )
{
  *msg = MSSUCC;
  str->type = other_generic;
  return( OM_S_SUCCESS );
}

/* ========================================================================= */

/*
 - Changes macro name in the instances,
 - Does not allow changing dir of the macro
 - Changes name of default template if it exists
*/ 

method GRchgname(long *msg; struct GRmd_env *env; char *name)
{
 int status;

 char loc_name[DI_PATH_MAX],
      def_name[DI_PATH_MAX],
      *short_name,
      *c,*strrchr();

 struct GRid my_grid,def_temp,def_occ,tmp_obj;
 OM_S_OBJID save_id;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 /* Get my old name */

 loc_name[0] = '\0';
 status = om$send(msg = message GRvg.GRgetname(msg,loc_name),
		  targetid = my_id);


 /* Retrieve default template if it exists */

 def_temp.objid = NULL_OBJID;
 if(status&1)
  {
    strcpy(def_name,loc_name);
    c = strrchr(def_name,'$');
    if(c == NULL) c = def_name + strlen(def_name);

    strcpy(c,"$def");

    /*"def_name %s\n",def_name */

    status = di$translate(objname = def_name,
                        p_objid = &def_temp.objid,
                        p_osnum = &def_temp.osnum);
    if(!(status&1)){ def_temp.objid = NULL_OBJID;}
    else
     {
      /*|search default occurence*/
      strcat(def_name,":~~occurence");
      status = di$translate(objname = def_name,
                        p_objid = &def_occ.objid,
                        p_osnum = &def_occ.osnum);
      if(status&1)
       {
        /* make sure it points to the correct macro definition */
	 status = om$send(msg = message ACcpx.ACload_macro(my_grid),
			  targetid = def_occ.objid,
			  targetos = def_occ.osnum);
       }
     }
   }

 if(name && name[0] != '\0' )
  {
   /*| Make the name relative to my old directory */

   short_name = strrchr(loc_name,':')+1;
   if(short_name == NULL) short_name = loc_name;

   c = strrchr(name,':');
   if(c == NULL) c = name;

   strncpy(short_name,c,macro_MAX_CHAR-1);
   short_name[macro_MAX_CHAR-1] = '\0';

  /* Make sure that another macro or macro default */
  /* does not exist with this name                 */

  status = di$translate(objname = loc_name,
	       p_objid = &tmp_obj.objid,
	       p_osnum = &tmp_obj.osnum);

  if(status&1) 
   {
    ex$message(msgnumb = AS_S_ConsExist);
    *msg = MSFAIL;
    return OM_S_SUCCESS;
   }
  

   /* Change my name in directory and in my instances */
   /* Change name of default template or delete it    */


   status = om$send(msg = message ACcpx.GRchgname(msg,env,loc_name),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
   if(status&1)
    {
     strcpy(me->macro_name,short_name);
     if(def_temp.objid != NULL_OBJID)
      {
       c = strrchr(loc_name,'$');
       if(c == NULL) c = loc_name + strlen(loc_name);
       strcpy(c,"$def");

       status = om$send(msg = message GRvg.GRchgname(msg, env, loc_name),
		        targetid = def_temp.objid,
		        targetos = def_temp.osnum);
       as$status();
      }
    }
  }

 else
  {
   /*| Remove name and delete default template */
   status = om$send(msg = message ACcpx.GRchgname(msg,env,name),
		    targetid = my_id,
		    mode = OM_e_wrt_message);
   me->macro_name[0] = '\0';

   if(def_temp.objid != NULL_OBJID)
    {
     save_id = env->md_id.objid;
     env->md_id.objid = NULL_OBJID;
     status = om$send(msg = message GRgraphics.GRdelete(msg,env),
		      targetid =  def_temp.objid,
		      targetos =  def_temp.objid);
     as$status();
    }
  }


 return(status);
}


/* Allow a unique name for macro definition */

method GRputname(long *msg; char *name)
{
 int status;
 struct GRmd_env md_env;

 md_env.md_id.objid = NULL_OBJID;
 md_env.md_id.osnum = OM_Gw_current_OS;
 MAidmx(msg,md_env.md_env.matrix);
 md_env.md_env.matrix_type = MAIDMX;

 status = om$send(msg = message GRvg.GRchgname(msg,&md_env,name),
                  targetid = my_id);
 return(status);
}

/* Return correct string when located */

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
 *msg = MSSUCC;
 ex$message(buff=info->type,msgnumb=AS_I_MacDefN);
 strcat ( info->type, me->macro_name );
 return OM_S_SUCCESS;

}

method GRgetsymb(long *msg; struct GRsymbology *symb)
{
 *msg = GR_I_NO_LAYER;
 return OM_S_SUCCESS;
}

/*
  replace the real definition by a temporary that will be deleted at save
  time if nobody uses it
*/

method delete(int toto)
{
 int status;
 char macro_name[macro_MAX_CHAR],
      full_file_name[DI_PATH_MAX],
      *file_name,
      *strrchr();
 OM_S_OBJID objid;
 struct GRid mod;

 objid = my_id;

/* get file name and macro name */

 strcpy(macro_name,me->macro_name);

 ex$get_cur_mod(id    = &mod.objid,
		osnum = &mod.osnum);
 
 if(mod.osnum == OM_Gw_current_OS)
   {
    strcpy(full_file_name,"."); 
    file_name = full_file_name;
   }
 else
   {
    di$give_pathname(osnum = OM_Gw_current_OS,
                     pathname = full_file_name);
    file_name = strrchr(full_file_name,':');
    if(file_name == NULL) return (OM_W_ABORT);
    file_name += 1;

   }

/* change the class of the macro def and remove its name from directory */

 status = om$change_class(objid = my_id, classname = "ACtmp_defn",
                          sd_override = OM_K_change_class_sd_override );

 di$rm_objid( objid = my_id,
              osnum = OM_Gw_current_OS);


/* initialize the temporary object */

 status = om$send(msg = message ACtmp_defn.ACset_mac_name(file_name,macro_name),
		  targetid = objid);

 return(status);
}


end implementation ACmacro_defn;
