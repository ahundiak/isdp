/* $Id: SMfrm_systi.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/imp / SMfrm_systi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMfrm_systi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:35  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  14:46:10  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation SMfrm_syst;

#include "string.h"
#include "math.h"
#include "AS_status.h"
#include "msdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIomac.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "expression.h"
#include "expmacros.h"
#include "csmacros.h"
#include "nddef.h"
#include "growner.h"
#include "bserr.h"
#include "SMdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "SMframe.h"
#include "bstypes.h"
#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "VDmem.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "OMmacros.h"

#define AS_DEBUG
/* #define DEBUG 1  */

from NDnode       import NDget_objects,NDdisplay,ASreturn_go;
from DImaster     import retrieve_info,store_info;
from SMframe      import SMgive_rel_position,SMfind_frame_num;
from ACrg_collect import AClist_attribute,ACget_named_attribute;

extern GRclassid OPP_Gexp_class_id,
		 OPP_Gtext_exp_class_id,
                 OPP_GRgencs_class_id,OPP_EMSplane,
		 OPP_SMframe_class_id;
/*
   Define the structure chanselect for the componant channel  
*/

/* This procedure is used to add a directory tree to the hierarchy. */
/* Correct some bug in jla function (some return code not tested!) */
static my_DIadd_dir ( osnum, objid, name, add )
            DIspacenum osnum	/* Object osnum				IN  */;
            DIobjid    objid	/* Object id				IN  */;
            DIchar     *name	/* Name of the link			IN  */;
            DIint      add	/* To add or not to add the name	IN  */;
{
  DIint      status,msg;
  DIspacenum loc_osnum;

  /* check OS */
  status = di$give_osnum ( pathname = name, p_osnum = &loc_osnum );
  if ((status == DIR_S_SUCCESS) && (osnum == loc_osnum))
  {
      DIchar  path_name[DI_PATH_MAX], base_name [DI_PATH_MAX],
              dir_name[DI_PATH_MAX];
      DIgrid  target_grid;

      DIexpanse ( name, path_name );
      di$split ( pathname = path_name, dirname = dir_name, name = base_name );

      status = DImasterRetrieve ( &msg, dir_name, NULL, (DIchar *)&target_grid,
				 NULL, NULL );
      as$status(action = RET_STATUS);
      if(!(msg & DIR_S_SUCCESS)) return  DIR_E_ILL_LINK;
      
      /* add it to the directory */
      if (add)
       {
	 /* add in dir AND untree */
	 status = om$send(msg = message IGRdir.add(&msg, base_name, objid, NULL),
			  senderid = NULL_OBJID,
			  targetid = target_grid.objid,
			  targetos = target_grid.osnum );
	 as$status(action = RET_STATUS);
	 if(!(msg & DIR_S_SUCCESS))
	   return  DIR_E_ILL_LINK;
       }
    }
  else
    status = DIR_E_ILL_LINK;
      
  return status;
}

static get_componant_ch(componant) 
OM_S_CHANSELECT **componant;
{
 static int componant_def = 0;
 static OM_S_CHANSELECT componant_desc;
 IGRlong status;

 if(componant_def == 0)
   {
    status = om$get_channel_number( channame ="GRcmpowner.to_components",
                                   p_channum = &componant_desc.u_sel.number);
    as$status(action = RET_STATUS);
    componant_desc.type  = OM_e_num;

    componant_def = 1;
   }
 *componant = &componant_desc;
 return OM_S_SUCCESS;
}


/* Fonction to allocate memory for names and object */
#define INCREMENT 100

static int my_add_grid_line(lines,grids,name,obj,count)
DIchar ***lines;            /* [I/O] */
DIgrid **grids;	       	    /* [I/O] */
DIchar *name;               /* [I]  */
DIgrid obj;		   /* [I] */
DIint  count;		   /* [I]*/
{
  if (count)
  {
    if (!((count + 1) % INCREMENT))
     {
       if(grids)
	 *grids=_REALLOC(*grids, (count+INCREMENT), DIgrid );
       if(lines)
	 *lines=_REALLOC(*lines, (count+INCREMENT), DIchar *);
     }
  }
  else
   {
     if(grids)
       *grids=_MALLOC (INCREMENT,DIgrid );
     if(lines)
       *lines=_MALLOC (INCREMENT,DIchar *);
   } 
  
  if( lines ){

#ifdef	DEBUG
    if( name) printf(" name: %s \n", name );
#endif

    if (name)
    { 
       (*lines) [count]=_MALLOC(strlen(name)+1,DIchar );
       strcpy ( (*lines) [count], name ); 
    }
    else
      (*lines) [count] = name;
  }
  
  if(grids){
#ifdef	DEBUG
	printf(" obj: %d,%d\n", obj.objid, obj.osnum );
#endif
    (*grids)[count] = obj;
  }

  return DIR_S_SUCCESS;
}

static int my_check_class(class_list, osnum, objid )
OM_p_CLASSLIST class_list		/* IN  */;
DIspacenum     osnum		/* IN  */;
DIobjid        objid		/* IN  */;
/*
   This function checks if the object given by (osnum, objid) is in the
   class_list.
*/
{
  DIchar ok;

  if (class_list)
  {
    DIchar  neg;
    DIint   i;
    OMuword classid;

    neg = class_list->w_flags & OM_CLST_negation;
    if (class_list->w_count)
    {
      om$get_classid ( osnum = osnum, objid = objid, p_classid = &classid );
      for (i = 0, ok = 0; (i < class_list->w_count) && (!ok); i++)
        if (class_list->w_flags & OM_CLST_subclass)
          ok = om$is_ancestry_valid ( subclassid = classid,
                     superclassid = class_list->p_classes [i] ) == OM_S_SUCCESS;
        else
          ok = classid == class_list->p_classes [i];
      if (neg) ok = !ok;
    }
    else
      ok = neg;
  }
  else
    ok = 1;
  return ( ok );
}


method unknown (OM_S_MESSAGE *msg)
{
/*^
  char      classname1 [OM_K_MAXCLASS_LEN], classname2 [OM_K_MAXCLASS_LEN];
  int       status;
  IGRchar   name [80];

  om$get_classname( classid = msg->select.ReqClassid,
                    classname = classname2 );
  om$get_classname( classid = msg->select.DefClassid,
                    classname = classname1 );
  status = om$get_message_name ( classid = msg->select.ReqClassid,
                                 method_index = msg->select.FuncIndex,
                                 msg_name = name );

  printf ( "Unknown Message from %s to %s,%s\n",classname1, classname2,
                name);
*/

  return(OM_S_SUCCESS);

} /* end method unknown */

/* Initialize a DIowner */

method ACcreate(IGRlong *msg; IGRchar *name)
{
 IGRlong status;

 *msg   = MSFAIL;
 status = OM_S_SUCCESS;

 /*"add de name %d\n",name */

 if(name == NULL || name[0] == '\0' )
   return OM_S_SUCCESS; /* Need a name */

 if( name[0] != '\0')
  {
    status = my_DIadd_dir(OM_Gw_current_OS,my_id,name,1);
    if(status != OM_S_SUCCESS) return OM_S_SUCCESS; /* msg say it fail */
  }

 /* Put the state as new */ 
 status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
		  senderid = NULL_OBJID,
		  targetid = my_id);
 
 if(status != OM_S_SUCCESS) return OM_S_SUCCESS; /* msg say it fail */
    
 *msg = MSSUCC;
 return	status;
}

method  translate ( DIint *stat; DIchar *name; int index; DIchar *p_name;
		   DIobjid *objid )
{
  int              status;
  int              index_attr;
  GRspacenum       osnum;
  OM_S_CHANSELECT  *componant;
  IGRchar	  *find_name;
  IGRboolean	   recur_fg;
  
  *stat = DIR_W_NAME_NOT_FOUND;
  
#ifdef	DEBUG
  printf("translate %s\n",name );
#endif
  
  /*| Initialization */
  find_name	= NULL;
  find_name	= strchr( name, ':' );
  recur_fg	= TRUE;
  if( find_name == NULL )	recur_fg	= FALSE;
  else	*find_name = '\0';
  
  for(index_attr=0 ; index_attr<me->nb_attr ; index_attr++)
   {
#ifdef	DEBUG
     printf(" %d --> %s\n",
		index_attr,&me->attr_name[me->attr_def[index_attr].name] );
#endif
     if(strcmp( name, &me->attr_name[me->attr_def[index_attr].name]) == 0)
      {/*| found */; break;}
   }

#ifdef	DEBUG
  printf("index_attr %d channel %d\n",
	index_attr,me->attr_def[index_attr].index );
#endif
  
  if( recur_fg == TRUE ) *find_name = ':';
  
  if(index_attr < me->nb_attr)
   {
     get_componant_ch(&componant);
     status = om$get_objid_at_index ( p_chanselect = componant,
				     index = me->attr_def[index_attr].index,
				     objid = my_id,
				     objidaddr = objid,
				     osnumaddr = &osnum);
     as$status( action = RET_STATUS );
     
     if( recur_fg )
      {
	/* recursion for macro */
       status = om$send(msg	 = message IGRdir.translate
			(stat, find_name+1, index, p_name, objid ),
			targetid = *objid,
			targetos = osnum );
       as$status( action = RET_STATUS );
     }
     
     *stat = DIR_S_SUCCESS;
#ifdef	DEBUG
     printf("objid %d\n",*objid );
#endif
   }
  return (OM_S_SUCCESS);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 strcpy(info->type,"Plane System ");

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}


method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
  char old_name[DI_PATH_MAX];
  char current_dir[DI_PATH_MAX],prec_dir[DI_PATH_MAX];

  *msg = MSSUCC;
  
  if(name == NULL || name[0] == '\0')
   {
     *msg = MSFAIL;
     return OM_S_SUCCESS;
   }

  di$pwd(dirname = current_dir);
  
  if (di$untranslate ( objid = my_id, objname = old_name ) == DIR_S_SUCCESS)
   {
     /* Verify if i'am not in my self directory */
     if(strncmp(current_dir,old_name,strlen(old_name)) == 0)
      {
	di$split(pathname = old_name,dirname = prec_dir);
	di$cd(dirname = prec_dir);
      }
     DIunlink_dir ( old_name, 1 );
   }

  if (DIadd_dir ( OM_Gw_current_OS, my_id, name, 1 ) != DIR_S_SUCCESS)
    *msg = MSFAIL;
  
  return OM_S_SUCCESS;
}

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
  *msg = OM_S_SUCCESS;
  return(OM_S_SUCCESS);

}


method dump ( DIint *stat; DIchar *reg_exp; OM_p_CLASSLIST classlist;
                DIchar ***lines; DIgrid **grids; DIint *count; 
                DIchar options )
{
  int              iatt;
  OMuint           i,nb_componants;
  IGRlong          status;
  OM_S_CHANSELECT  *componant;
  struct GRid      tmp_obj;
  IGRboolean       is_star = FALSE;
  DIchar           **reg_buffer = NULL;
  DIint            reg_count = 0;
  DIchar           reg[DI_PATH_MAX];
  DIchar           *find_name = NULL;
  IGRboolean       recur_fg;

 
  if (!count) { *stat = DIR_E_INVARG; return OM_W_ABORT; }
  else *count = 0;

 if(options & OPT_SYS)
  {
    /*| Dump returns nothing because after NDsleep or before AC wakeup */
    *stat = DIR_S_SUCCESS;
    return(OM_S_SUCCESS);
  }
/* get number of componants */

  get_componant_ch(&componant);
  status = om$get_channel_count(p_chanselect = componant,
			        objid = my_id,
			        count = &nb_componants);
  as$status(action = RET_STATUS);

  /* Find the regular expression */
  (strncpy ( reg,
	    (reg_exp) ? ((*reg_exp) ? reg_exp : "*") : "*",
	    DI_PATH_MAX )) [DI_PATH_MAX - 1] = '\0'; 

  find_name = strchr(reg, ':' );
  if( find_name == NULL )
    recur_fg = FALSE;
  else
    { recur_fg = TRUE; *find_name = '\0'; }

  /* Compile the regular expression */
  if (strcmp ( "*", reg ))
    DImulti_parse ( reg, &reg_buffer, &reg_count );
  else
    is_star = 1;

#ifdef	DEBUG
  printf(" nb_componants : %d \n", nb_componants );
#endif

  for(i=0,iatt=0;i<nb_componants;i++)
   {
    status = om$get_objid_at_index (p_chanselect = componant,
				    index = (OMuint)i,
				    objid = my_id,
				    objidaddr = &tmp_obj.objid,
				    osnumaddr = &tmp_obj.osnum);
    as$status( action = RET_STATUS );

    if(me->attr_def[iatt].index == i)
     {
       if((is_star ? 1 : DImulti_step(&me->attr_name[me->attr_def[iatt].name],
				      reg_buffer, reg_count)) &&
	  (my_check_class(classlist,tmp_obj.osnum,tmp_obj.objid)))
	{
	  if(recur_fg)
	   {
	     DIchar **lines1 = NULL;
	     DIgrid *grids1 = NULL;
	     DIgrid  obj1;
	     DIint  count1 = 0;
	     char tmp_str[DI_PATH_MAX];
	     int j;
	    
	     /* recursion for macro */
	     /* KLUDGE because macros doesn't respond
		correctly to dump (doesn't take account of reg_exp :
		always return all the directory) */
	     if(di$is_regexp(regexp = find_name+1))
	      {
		/* Sorry it won't be completly correct in this case */
		status = om$send(msg = message IGRdir.dump
				 (stat,
				  find_name+1,
				  classlist,
				  &lines1,
				  &grids1,
				  &count1,
				  options), 
				 targetid = tmp_obj.objid,
				 targetos = tmp_obj.osnum );

#ifdef	DEBUG
		printf("1:obj: %d,%d\n", tmp_obj.objid, tmp_obj.osnum );
#endif
		as$status( action = RET_STATUS );
		if(*stat & 1)
		 {
		   for(j=0;j<count1;j++)
		    {
		      tmp_str[0] = '\0';
		      DIstmcpy(tmp_str,&me->attr_name[me->attr_def[iatt].name],
			       lines1[j],NULL);
		      status = my_add_grid_line(lines,grids,
						tmp_str,grids1[j],*count);
		      as$status(action = RET_STATUS);
		      (*count)++;
		    }
		 }
		if(lines1) di$free(lines = lines1,count = count1);
		if(grids1) free(grids1);
	      }
	     else
	      {
		/* Try translate : it wouldn't be necessary to do this if
		 dump works correctly for macro*/
		status = om$send(msg = message IGRdir.translate
				 (stat,find_name+1,0,NULL,&obj1.objid),
				 targetid = tmp_obj.objid,
				 targetos = tmp_obj.osnum);
#ifdef	DEBUG
		printf("2:obj: %d,%d\n", tmp_obj.objid, tmp_obj.osnum );
#endif
		as$status( action = RET_STATUS);
		if(*stat & 1)
		 {
		   obj1.osnum = OM_Gw_current_OS;
		   tmp_str[0] = '\0';
		   DIstmcpy(tmp_str,&me->attr_name[me->attr_def[iatt].name],
			    find_name+1,NULL);
		   status = my_add_grid_line(lines,grids,
					     tmp_str,obj1,*count);
		   as$status( action = RET_STATUS ); 
		   (*count)++;
		 }
	      }
	   } 
	  else  /* No recursion */
	   {
	     DIgrid di_obj;

	     di_obj.objid = tmp_obj.objid; di_obj.osnum = tmp_obj.osnum;

#ifdef	DEBUG
	     printf("3:obj: %d,%d\n", tmp_obj.objid, tmp_obj.osnum );
#endif
	     status = my_add_grid_line(lines,grids,
				       &me->attr_name[me->attr_def[iatt].name],
				       di_obj,*count);
	     as$status(action = RET_STATUS);
	     (*count)++;
	   }
	}
       iatt += 1;
     }
  }

 /* free buffer space */
  if (!is_star && reg_buffer)
  {
    for (i = 0; i < reg_count; i++) DIfree ( reg_buffer [i] );
    DIfree ( reg_buffer );
  }

 if (*count) *stat = DIR_S_SUCCESS;
 else *stat = is_star ?  DIR_I_DIR_EMPTY : DIR_W_NAME_NOT_FOUND;
 
 return OM_S_SUCCESS;
}

method SMremove_component(IGRlong *msg; struct GRid *go_obj)
{
 OMuint          index_deleted,index_attr,i;
 OM_S_CHANSELECT *componant;
 IGRlong         status;
 struct GRid     my_GRid;

 /* retrieve componant index */
 
 get_componant_ch(&componant);
 status = om$get_index(p_chanselect = componant,
		       objid_c      = my_id,
		       objid        = go_obj->objid,
		       indexaddr    = &index_deleted);
 as$status(action = RET_STATUS);

 for(i=0;i<me->nb_attr;i++) if(me->attr_def[i].index >= index_deleted) break;
 index_attr = i;

 if(me->attr_def[index_attr].index == index_deleted)
 {
   /*| the disconnected element is an attibute */
   status = om$send(msg = message ACdiowner.ACrem_att_at_index(msg,index_attr),
		    targetid = my_id);
   if(!(status & *msg & 1)) {*msg = MSFAIL; return OM_S_SUCCESS;}
 }
 else
  {
    *msg = MSFAIL;
#ifdef DEBUG
    printf("Error, element is not an attribute\n");
#endif
    return OM_S_SUCCESS;
  }
 
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 status = om$send (msg = message GRconnector.GRdisconn (msg,&my_GRid),
		   targetid = go_obj->objid,
		   targetos = go_obj->osnum);
 as$status();
 if(!(status & *msg & 1)) {*msg = MSFAIL; return status;} 
  
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}


method SMchange_component_name(IGRlong *msg; struct GRid *go_obj;
			       IGRchar *new_name)
{
  IGRint           status;
  OMuint           index,index_attr;
  OM_S_CHANSELECT  *componant;
  int              i,name_size,new_name_size,previous_size,name_index;
  
  get_componant_ch(&componant);
  status = om$get_index(object_c     = me,
			p_chanselect = componant,
			objid        = go_obj->objid,
			osnum2       = go_obj->osnum,
			indexaddr    = &index);
  if(status&1)
   {
     for(index_attr = 0 ; index_attr< me->nb_attr ; index_attr++)
      {
	if(me->attr_def[index_attr].index == index)
	 {
	   name_index    = me->attr_def[index_attr].name;
	   name_size     = strlen(&me->attr_name[name_index]) + 1;
	   new_name_size = strlen(new_name) + 1;
	   previous_size = om$dimension_of(varray = me->attr_name);

       	   if(name_size < new_name_size)  /* enlarge the array */
	    {
	      status = om$vla_set_dimension
		(varray = me->attr_name,
		 size = previous_size - name_size + new_name_size);
	      if(status != OM_S_SUCCESS)
	       {
		 printf("Memory problem\n");
		 *msg   = MSFAIL;
		 return OM_S_SUCCESS;
	       }
	    }
            
	   if((name_size != new_name_size) &&
	      (previous_size - name_index - name_size) > 0)
	    {
	      OM_BLOCK_MOVE(&me->attr_name[name_index + name_size],
			    &me->attr_name[name_index + new_name_size],
			    previous_size - name_index - name_size);
		 
	      /* Readjust index of name attribute array */
	      for(i=index+1 ; i<me->nb_attr ; i++)
		me->attr_def[i].name  =
		  me->attr_def[i].name - name_size + new_name_size;
	    }

	   if(name_size > new_name_size) /* Recover memory */
	    {
	      status = om$vla_set_dimension
		(varray = me->attr_name,
		 size = previous_size - name_size + new_name_size);
	      if(status != OM_S_SUCCESS)
	       {
		 printf("Memory problem\n");
		 *msg   = MSFAIL;
		 return OM_S_SUCCESS;
	       }
	    } 

	   strcpy(&me->attr_name[name_index],new_name);
#ifdef DEBUG
	   for(i=0 ; i<me->nb_attr ; i++)
	     printf("Name %s\n",&me->attr_name[me->attr_def[i].name]);
	   printf("\n");
#endif

	   *msg = MSSUCC;
	   return OM_S_SUCCESS;
	 }
      }
   }
  *msg   = MSFAIL;
  return OM_S_SUCCESS;
}

/* Given the frame number of a frame system , give the frame objid */

method SMfind_frame_objid(IGRlong *msg;IGRint fr_number;struct GRid *frame)
{
  OM_S_CHANSELECT *componant;
  IGRlong         status; 
  OMuint          i,nb_componants;
  struct GRid     tmpfr;
  IGRint          fr_num;
  GRclassid       obj_class;
  

  frame->objid = NULL_OBJID;
  *msg = MSFAIL;  

  get_componant_ch(&componant);
  status = om$get_channel_count(p_chanselect = componant,
			        objid = my_id,
			        count = &nb_componants);
  if(!(status & 1))
   {
     om$report_error( sts = status );
     return OM_S_SUCCESS;
   }
  
  if(nb_componants == 0) return OM_S_SUCCESS;

  for(i=0;i<nb_componants;i++)
   {
     status = om$get_objid_at_index (p_chanselect = componant,
				     index        = i,
				     objid        = my_id,
				     objidaddr    = &tmpfr.objid,
				     osnumaddr    = &tmpfr.osnum);
     if(!(status&1)) return OM_S_SUCCESS;

     om$get_classid (objid     = tmpfr.objid,
                     osnum     = tmpfr.osnum,
		     p_classid = &obj_class);

     if(om$is_ancestry_valid(subclassid = obj_class,
                             superclassid = OPP_SMframe_class_id)==OM_S_SUCCESS)
     {  
       status = om$send(msg = message SMframe.SMfind_frame_num(msg,&fr_num),
			targetid = tmpfr.objid,
			targetos = tmpfr.osnum);
       if(!(status & *msg & 1)) return OM_S_SUCCESS;
      
       if(fr_num == fr_number)
	{
	  frame->objid = tmpfr.objid, 
	  frame->osnum = tmpfr.osnum;
	  *msg = MSSUCC;
	  return OM_S_SUCCESS;
	}
     }
   }
  return OM_S_SUCCESS;
}

method SMdisplay_all_frame(IGRlong *msg;enum GRdpmode mode;
			   struct GRmd_env *md_env)
{
  OM_S_CHANSELECT *componant;
  IGRlong         status;

  get_componant_ch(&componant);

  status = om$send(msg = message NDnode.NDdisplay(1,mode,md_env),
		   p_chanselect = componant);
  as$status();
  if(!(status & 1)) *msg = MSFAIL; else *msg = MSSUCC;

  return OM_S_SUCCESS;
}

/* Given two frame numbers, give all the objid of the frame between
  *lowest and *highest */
method  SMfind_inter_frame(IGRlong *msg;IGRint *lowest;IGRint *highest;
	                   struct GRid *frame;IGRint *nb_elem)
{
  OM_S_CHANSELECT *componant;
  IGRlong         status; 
  OMuint          i,nb_componants;
  IGRint          pos,to_find;
  struct          GRid tmpfr;
  IGRint          fr_number;
  GRclassid       obj_class;
  IGRint          low_req,high_req;       
  IGRint          low_find = 9999,high_find = -9999;

  if(*highest < *lowest) /* swap lowest and highest */
   {
     IGRint tmp;
     tmp = *lowest;
     *lowest = *highest;
     *highest = tmp;
   } 
     
  low_req = *lowest;
  high_req = *highest;

  to_find = high_req - low_req + 1;  /* Number of frame to retrieve */

  if(to_find <= 0)   /* Not permit */
    goto wrapup;
  
  get_componant_ch(&componant);
  status = om$get_channel_count(p_chanselect = componant,
			        objid = my_id,
			        count = &nb_componants);
  if(!(status & 1))
   {
     om$report_error( sts = status );
     goto wrapup;
   }
  
  if(nb_componants == 0) goto wrapup;

  /* Loop on each object on the channel ,search frame number of this object */
  /* if frame number is between  low and high */
  /* put it in the frame array at the right place */

  for(i=0;i<nb_componants;i++)
   {
     status = om$get_objid_at_index (p_chanselect = componant,
				     index = i,
				     objid = my_id,
				     objidaddr = &tmpfr.objid,
				     osnumaddr = &tmpfr.osnum);
     if(!(status&1)) return OM_S_SUCCESS;

     om$get_classid (objid     = tmpfr.objid,
                     osnum     = tmpfr.osnum,
		     p_classid = &obj_class);

     if(om$is_ancestry_valid(subclassid = obj_class,
                             superclassid = OPP_SMframe_class_id)==OM_S_SUCCESS)
     { 
       status = om$send(msg = message SMframe.SMfind_frame_num(msg,&fr_number),
			targetid = tmpfr.objid,
			targetos = tmpfr.osnum);
       if(!(status & *msg & 1)) return OM_S_SUCCESS;
       
       if(fr_number >= low_req && fr_number <= high_req)
	{
	  pos = fr_number - low_req;
	  frame[pos].objid = tmpfr.objid;
	  frame[pos].osnum = tmpfr.osnum;
          to_find--;
	  if(fr_number <= low_find)
	    low_find = fr_number;
	  if(fr_number >= high_find)
	    high_find = fr_number;
	}

       if(to_find == 0)  /* Search finish ! */
	{
	  *nb_elem = high_find - low_find +1;
	  *msg = MSSUCC;
	  return OM_S_SUCCESS;
	} 
     }
   }
  
  if(low_find > low_req && low_find != 9999)  /* Translate all elem */
   {
     IGRint translate;
     translate = low_find - low_req;

     for(i=0;i< high_req - low_req +1; i++)
      {
	frame[i].objid = frame[i + translate].objid;
	frame[i].osnum = frame[i + translate].osnum;
      }
     *lowest  = low_find;
   }
  
  if(high_find < high_req && high_find != -9999)
    *highest = high_find;
    
  if(low_find != 9999 && high_find != -9999)
    *nb_elem = high_find - low_find +1;
  else
    *nb_elem = 0;

  *msg =  MSSUCC;
  return OM_S_SUCCESS ;
  
 wrapup:
  *nb_elem = 0;
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}

/* Find all frame in the frame system */
method  SMfind_all_frame(IGRlong *msg;struct GRid **frame;IGRint **fr_number;
			 IGRint *nb_elem;IGRint *lowest;IGRint *highest)
{
  OM_S_CHANSELECT *componant;
  IGRlong         status; 
  OMuint          i,nb_componants;
  IGRint          pos,fr_num;
  struct GRid     tmpfr;
  GRclassid       obj_class;
  IGRint          low_find = 9999,high_find = -9999;
  struct GRid     *frm = NULL;
  IGRint          *num = NULL;

  get_componant_ch(&componant);
  status = om$get_channel_count(p_chanselect = componant,
			        objid = my_id,
			        count = &nb_componants);
  if(!(status & 1))
   {
     om$report_error( sts = status );
     goto wrapup;
   }
  
  if(nb_componants == 0) goto wrapup;

  /* First search the lowest and highest frame number */
  for(i=0;i<nb_componants;i++)
   {
     status = om$get_objid_at_index (p_chanselect = componant,
				     index = i,
				     objid = my_id,
				     objidaddr = &tmpfr.objid,
				     osnumaddr = &tmpfr.osnum);
     if(!(status&1)) goto wrapup;

     om$get_classid (objid     = tmpfr.objid,
                     osnum     = tmpfr.osnum,
		     p_classid = &obj_class);

     if(om$is_ancestry_valid(subclassid = obj_class,
                             superclassid = OPP_SMframe_class_id)==OM_S_SUCCESS)
     { 
       status = om$send(msg = message SMframe.SMfind_frame_num(msg,&fr_num),
			targetid = tmpfr.objid,
			targetos = tmpfr.osnum);
       if(!(status & *msg & 1)) goto wrapup;

       if(fr_num < low_find) low_find = fr_num;
       if(fr_num > high_find) high_find = fr_num;
     }
     else
       goto wrapup;
   }
  if(nb_elem) *nb_elem = nb_componants;
  if(lowest)  *lowest  = low_find;
  if(highest) *highest = high_find;

  /* If the array are not asked return immediatly */ 
  if(frame == NULL && fr_number == NULL)
   {
     *msg = MSSUCC;
     return OM_S_SUCCESS;
   }

  if(frame != NULL) 
   {
     frm  =_MALLOC (nb_componants,struct GRid);
     if(frm == NULL)
      { printf("Not enough memory\n"); }
   }
  if(fr_number != NULL)
   {
     num =_MALLOC (nb_componants,IGRint);
     if(num == NULL)
      { printf("Not enough memory\n"); }
   }

  for(i=0;i<nb_componants;i++)
   {
     status = om$get_objid_at_index (p_chanselect = componant,
				     index = i,
				     objid = my_id,
				     objidaddr = &tmpfr.objid,
				     osnumaddr = &tmpfr.osnum);
     if(!(status&1)) goto wrapup;
      
     status = om$send(msg = message SMframe.SMfind_frame_num(msg,&fr_num),
			targetid = tmpfr.objid,
			targetos = tmpfr.osnum);
     if(!(status & *msg & 1)) goto wrapup;

     pos = fr_num - low_find;
     if(frm != NULL)
      {
	frm[pos].objid = tmpfr.objid;
	frm[pos].osnum = tmpfr.osnum;
      }
     if(num != NULL)
       num[pos] = fr_num;
   }

  if(frame != NULL) *frame     = frm;
  if(fr_number != NULL) *fr_number = num;
 
  *msg = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  *msg = MSFAIL;
  *nb_elem = 0;
  if(frm != NULL) _FREE(frm);
  if(num != NULL) _FREE(num);
  return OM_S_SUCCESS; 
}

method SMfind_frame_near_pt(IGRlong *msg;IGRdouble *point;
			    IGRint *low_near_num;IGRint *high_near_num;
			    IGRdouble *low_delta; IGRdouble *high_delta;
			    IGRshort *matrix_type;IGRmatrix matrix)

{
  IGRlong          status,loc_msg;
  struct GRid      *frame = NULL,frame0,cs;
  IGRdouble        local_coord[3],pt_pos,frame_pos;
  IGRchar          axis[80];
  IGRint      	   nb_frame,count,ind_low,ind_high,i,npts;
  IGRboolean 	   pt_on_frame;
  IGRmatrix        cs_mat,cs_env_mat,frm_wld_mat,wld_frm_mat;
  IGRshort	   cs_pl,cs_mat_type,mxtype;
  IGRuchar         props;
  BSrc             bsts;
  double           tol;
  long             nput, nret;

  /* Jean 10/25/93 : Get the bas tolerance for equality betweem point */
  nput = sizeof(tol);
  gr$get_basis_tolerance (msg = &loc_msg, sizbuf = &nput,
			  buffer = &tol, nret = &nret);
  
  /* Find frame 0 */
  status = om$send(msg = message SMfrm_syst.SMfind_frame_objid
		   (&loc_msg,0,&frame0),
		   targetid = my_id);
  as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);

  

  /* Find the coordinate system of the frame system */
  status =  om$send(msg = message NDnode.NDget_objects
		    (ND_ROOT,&cs,1,NULL,0,0,&count),
		    targetid = frame0.objid,
		    targetos = frame0.osnum);
  as$status(action = GOTO_VALUE,value = wrapup);
 
  status = om$send( msg = message NDnode.ASreturn_go
		   (&cs,&cs_mat_type,cs_mat),
		   targetid = cs.objid,
		   targetos = cs.osnum );
  as$status(action = RET_STATUS);

  status = om$send(msg = message SMfrm_syst.SMGetAttTxt
		   (&loc_msg,"axis",axis,NULL),
		   targetid = my_id);
  if(!(loc_msg & 1))
   {printf("Error retreiving axis\n");goto wrapup;}

  /* Convert point to coordinate relative to cs of frame system */

  BSmult_mats(4,4,matrix,0,4,4,cs_mat,0,cs_env_mat,&bsts);
  if(bsts != BSSUCC) return OM_S_SUCCESS; 

  if(bsts = MAtypemx(&loc_msg,cs_env_mat,&cs_mat_type))
    if(!VDget_mat(&cs, cs_mat_type,cs_env_mat,frm_wld_mat, &props, &cs_pl))
     {printf("Error VDget_mat for objid %d\n",cs.objid);return OM_S_SUCCESS;}

  i = 4;
  if(!MAinvmx (&loc_msg, &i,frm_wld_mat ,wld_frm_mat))
   {printf("Error file SMfrm_syti.I: inverting matrices\n"); goto wrapup;}

  npts = 1;
  if(bsts = MAtypemx(&loc_msg,wld_frm_mat,&mxtype))
    bsts = MAoptsxform(&loc_msg,&npts,&mxtype,wld_frm_mat,point,local_coord);

#ifdef JJ_DEBUG
  printf("World coordinate %g %g %g\n",point[0],point[1],point[2]);
  printf("Local coordinate %g %g %g\n",
	 local_coord[0],local_coord[1],local_coord[2]);
#endif

  switch(axis[0])
   {
   case 'x': pt_pos = local_coord[0]; break;
   case 'y': pt_pos = local_coord[1]; break;
   case 'z': pt_pos = local_coord[2]; break;
   default: printf("Incorrect value for frame axis\n"); goto wrapup;
   }
  
  om$send(msg = message SMfrm_syst.SMfind_all_frame
	  (&loc_msg,&frame,NULL,&nb_frame,NULL,NULL),
	  targetid = my_id);
  if(!(loc_msg & 1) || nb_frame == 0) goto wrapup;

  ind_low  = 0;
  ind_high = nb_frame - 1;
 
  for(i = 0; i < nb_frame; i++)
   {
     status = om$send(msg = message SMframe.SMgive_rel_position
		      (&loc_msg,&frame_pos),
		      targetid = frame[i].objid,
		      targetos = frame[i].osnum);
     as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);

     
     /* Jean 10/25/93 : Test with bas tol instead of EPSILON */
     pt_on_frame = (fabs(frame_pos - pt_pos) < tol);
    
     if(i == 0 && (pt_pos < frame_pos || pt_on_frame))
      {
	ind_low  = i;
	ind_high = i;
	break;
      }
	
     if(i == nb_frame - 1 && (pt_pos > frame_pos || pt_on_frame))
      {
	ind_low  = i;
	ind_high = i;
	break;
      } 

     if(frame_pos > pt_pos)
      {
	ind_high = i; 
	if(pt_on_frame) ind_low = i;
	break;
      }
     else  /*Jean 10/25/93 : test if pt_on_frame just in case of cs like navy */
      {
	ind_low = i;
	if(pt_on_frame) { ind_high = i; break; }
      }
   }

  if(low_near_num)
   {
     status = om$send(msg = message SMframe.SMfind_frame_num
		      (&loc_msg,low_near_num),
		      targetid = frame[ind_low].objid,
		      targetos = frame[ind_low].osnum);
     as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);
   }

  if(low_delta)
   {
     status = om$send(msg = message SMframe.SMgive_rel_position
		      (&loc_msg,&frame_pos),
		      targetid = frame[ind_low].objid,
		      targetos = frame[ind_low].osnum);
     as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);
     *low_delta = pt_pos - frame_pos; 
   }
  
  if(high_near_num)
   {
     status = om$send(msg = message SMframe.SMfind_frame_num
		      (&loc_msg,high_near_num),
		      targetid = frame[ind_high].objid,
		      targetos = frame[ind_high].osnum);
     as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);
   }

  if(high_delta)
   {
     status = om$send(msg = message SMframe.SMgive_rel_position
		      (&loc_msg,&frame_pos),
		      targetid = frame[ind_high].objid,
		      targetos = frame[ind_high].osnum);
     as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);
     *high_delta = frame_pos - pt_pos; 
   }

  if(frame) _FREE(frame);
  *msg = MSSUCC;
  return OM_S_SUCCESS;
     
 wrapup:
  if(frame) _FREE(frame);
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}  

method SMfind_near_frame(IGRlong *msg;IGRdouble dist_in;
			 IGRint *fr_num;IGRdouble *delta)
{
 OM_S_CHANSELECT *componant;
 IGRlong         status; 
 OMuint          i,nb_componants;
 IGRdouble       neardist = 1e20,dist,frame_pos;
 struct GRid     nearframe,tmpfr;

  nearframe.objid = NULL_OBJID;

  get_componant_ch(&componant);
  status = om$get_channel_count(p_chanselect = componant,
			        objid = my_id,
			        count = &nb_componants);
  if(!(status & 1))
   {
     om$report_error( sts = status );
     goto wrapup;
   }
  
  if(nb_componants == 0) goto wrapup;

  /* First search the lowest and highest frame number */
  for(i=0;i<nb_componants;i++)
   {
     status = om$get_objid_at_index (p_chanselect = componant,
				     index = i,
				     objid = my_id,
				     objidaddr = &tmpfr.objid,
				     osnumaddr = &tmpfr.osnum);
     if(!(status&1)){ printf("Problem retreiving one frame\n");goto wrapup;}

     status = om$send(msg = message SMframe.SMgive_rel_position
		      (msg,&frame_pos),
		      targetid = tmpfr.objid,
		      targetos = tmpfr.osnum);
     if(!(status & *msg & 1))
      { printf("Problem with one frame macro");goto wrapup;} 

     dist = dist_in - frame_pos;
    
     if(dist >= 0.0 && dist < neardist)
      {
	neardist = dist;
	nearframe.objid = tmpfr.objid; 
	nearframe.osnum = tmpfr.osnum;
      }
   }

  if(nearframe.objid != NULL_OBJID) 
   {
     status = om$send(msg = message SMframe.SMfind_frame_num(msg,fr_num),
		      targetid = nearframe.objid,
		      targetos = nearframe.osnum);
     if(!(status & *msg & 1)) goto wrapup;
     
     *delta = neardist;
   }
  else goto wrapup; 
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;
     
 wrapup:
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}     

/* Override from SMmgr : return attributes representing global frame system */
method SMGetAttType(IGRlong *msg; IGRshort type; 
		     IGRint *nb_att; struct ACrg_coll **att)
{
  IGRlong         status;
  IGRint          count;
  struct GRid     glob_acrg,tmpfr;
  OM_S_CHANSELECT *componant;

  *att = NULL;
  /*  if(!(type & SM_DYN_CRT_ATT)) goto wrapup;   CH ....  */

  /* find one frame (index 0 on the channel) */
  get_componant_ch(&componant);
  status = om$get_objid_at_index (p_chanselect = componant,
				  index = 0,
				  objid = my_id,
				  objidaddr = &tmpfr.objid,
				  osnumaddr = &tmpfr.osnum);
  if(!(status&1)) goto wrapup;

  /* find the ACrg containing glob info of this frame */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,&glob_acrg,1,NULL,2,2,&count),
		   targetid = tmpfr.objid,
		   targetos = tmpfr.osnum);
  if(status != OM_S_SUCCESS) goto wrapup;

  /* Count the number of attributes */
  status = om$send(msg = message  ACrg_collect.AClist_attribute
		   (msg,0,NULL,nb_att),
		   targetid = glob_acrg.objid,
		   targetos = glob_acrg.osnum);
  if(!(status & *msg & 1) || (*nb_att <= 0))
    goto wrapup;
  
  if(att == NULL)  /* Don't want the list of attributes */
   { *msg = MSSUCC; return OM_S_SUCCESS; }  

  *att =_MALLOC(*nb_att,struct ACrg_coll);

  if(*att == NULL)
   {printf("Not enough memory\n");} 

  status = om$send(msg = message ACrg_collect.AClist_attribute
		   (msg,*nb_att,*att,nb_att),
		   targetid = glob_acrg.objid,
		   targetos = glob_acrg.osnum);
  if(!(status & *msg & 1) || (*nb_att <= 0))
    goto wrapup;
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  *msg = MSFAIL;
  *nb_att = 0;
  if(*att != NULL) _FREE(*att);
  return OM_S_SUCCESS;
}

method SMGetAtt(IGRlong *msg; IGRint nb_att; struct ACrg_coll *att; 
 		 IGRshort *type) 
{
  IGRlong         status;
  IGRint          count,i;
  struct GRid     glob_acrg,tmpfr;
  OM_S_CHANSELECT *componant;


  if(att == NULL) goto wrapup;

  /* find one frame (index 0 on the channel) */
  get_componant_ch(&componant);
  status = om$get_objid_at_index (p_chanselect = componant,
				  index = 0,
				  objid = my_id,
				  objidaddr = &tmpfr.objid,
				  osnumaddr = &tmpfr.osnum);
  if(!(status&1)) goto wrapup;
  
  /* find the ACrg containning glob info of this frame */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,&glob_acrg,1,NULL,2,2,&count),
		   targetid = tmpfr.objid,
		   targetos = tmpfr.osnum); 
  if(status != OM_S_SUCCESS) goto wrapup;

  for(i=0; i<nb_att; i++)
   {
     status = om$send(msg = message ACrg_collect.ACget_named_attribute
		      (msg,&att[i]),
		      targetid = glob_acrg.objid,
		      targetos = glob_acrg.osnum);
     if(!(status & *msg & 1)) goto wrapup;
     if(type != NULL) type[i] =  SM_SYST_ATT | SM_DYNAMIC_ATT;
   }		      
  
 *msg = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}


method SMcvt_frm_to_wld(IGRlong *msg;IGRdouble pos;IGRpoint pt;
			IGRshort *matrix_type;IGRmatrix matrix)
{
  IGRlong          status,loc_msg;
  IGRchar          axis[5];
  struct GRid      cs,tmpfr;
  IGRpoint         pt_in;
  IGRmatrix        cs_mat,cs_env_mat,frm_wld_mat;
  IGRshort         cs_mat_type,mxtype;
  IGRuchar         props;
  short	           cs_pl;
  IGRint           npts,count;
  IGRshort         type;
  OM_S_CHANSELECT  *componant;
  BSrc             bsts;
  
  *msg = MSFAIL;

 /* find one frame (index 0 on the channel) */
  get_componant_ch(&componant);
  status = om$get_objid_at_index (p_chanselect = componant,
				  index = 0,
				  objid = my_id,
				  objidaddr = &tmpfr.objid,
				  osnumaddr = &tmpfr.osnum);
  as$status(action = RET_STATUS);

  /* Find the coordinate system of the frame system */
  status =  om$send(msg = message NDnode.NDget_objects
		    (ND_ROOT,&cs,1,NULL,0,0,&count),
		    targetid = tmpfr.objid,
		    targetos = tmpfr.osnum);
  as$status(action = RET_STATUS);
  
  status = om$send(msg = message SMfrm_syst.SMGetAttTxt
		   (&loc_msg,"axis",axis,&type),
		   targetid = my_id);
  if(!(loc_msg & 1))
   {printf("Error retreiving axis\n");return status;}
    
  switch(axis[0])
   {
   case 'x': pt_in[0] = pos; pt_in[1] = 0.0; pt_in[2] = 0.0; break;
   case 'y': pt_in[0] = 0.0; pt_in[1] = pos; pt_in[2] = 0.0; break;
   case 'z': pt_in[0] = 0.0; pt_in[1] = 0.0; pt_in[2] = pos; break;
   }

  status = om$send( msg = message NDnode.ASreturn_go
		   (&cs,&cs_mat_type,cs_mat),
		   targetid = cs.objid,
		   targetos = cs.osnum );
  as$status(action = RET_STATUS);

  BSmult_mats(4,4,matrix,0,4,4,cs_mat,0,cs_env_mat,&bsts);
  if(bsts != BSSUCC) return OM_S_SUCCESS;

  if(bsts = MAtypemx(&loc_msg,cs_env_mat,&cs_mat_type))
    if(!VDget_mat(&cs, cs_mat_type,cs_env_mat,frm_wld_mat, &props, &cs_pl))
     {printf("Error VDget_mat for objid %d\n",cs.objid);return OM_S_SUCCESS;}
         
  npts = 1;
  if(bsts = MAtypemx(&loc_msg,frm_wld_mat,&mxtype))
    bsts = MAoptsxform(&loc_msg,&npts,&mxtype,frm_wld_mat,pt_in,pt);
   
  if(!bsts)
   {printf("Error can't convert to world coordinate\n");return OM_S_SUCCESS;}
        
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}


/* Give type of the frame system */
method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
  *type = SM_FRM;
  *sub_type = 0xFFFF;
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

method ACadd_component_with_name(IGRlong *msg; struct GRid *component;
				 IGRchar *name)
{
 long            owner_ind=OM_K_MAXINT;
 struct GRid     my_grid;
 long            status;
 int             previous_size,name_size;
 OMuint          index;
 OM_S_CHANSELECT *componant;

/*"componant %d %d name %s\n",component->objid,component->osnum,name*/

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 
 status = om$send (msg      = message GRconnector.GRrigidconn(msg,
                                      &my_grid,&owner_ind),
                   targetid = component->objid,
                   targetos = component->osnum);
 if(!(*msg&1)) status = OM_W_ABORT;
 as$status(action = RET_STATUS);

/* store its name */

  name_size = strlen(name)+1;

  /*"name_size %d\n",name_size*/

  previous_size = om$dimension_of(varray = me->attr_name);
  /*"previous_size %d\n",previous_size*/
  status = om$vla_set_dimension(varray = me->attr_name,
                                size = previous_size+name_size);
  OM_BLOCK_MOVE(name,&me->attr_name[previous_size],name_size);
  
  status = om$vla_set_dimension(varray = me->attr_def,
                                size = me->nb_attr+1);

 get_componant_ch(&componant);
  om$get_index(objid_c      = my_id,
	       p_chanselect = componant,
	       objid        = component->objid,
	       indexaddr    = &index);
  /*"index %d\n",index*/

  me->attr_def[me->nb_attr].name = previous_size;
  me->attr_def[me->nb_attr].index = index;
  me->nb_attr = me->nb_attr + 1;

 return(OM_S_SUCCESS);
}

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
 *msg = MSSUCC;
 *properties = GR_LC_CMP_READ | GR_LC_CMP_WRITE  |
               GR_LC_CMP_PRM_READ | GR_LC_CMP_PRM_WRITE | GR_LC_RIGID;
 return(OM_S_SUCCESS);
}


/* ******************* MSG  SMFillSfFile() ************************	*/
method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
  IGRlong           status, loc_msg;
  IGRchar           name[DI_PATH_MAX];
  struct sect_info  sect_info[NB_MAX_SECTION];
  IGRdouble         offset,nb_sect;
  IGRchar           att_name[40],axis[5],orient[5];
  IGRdouble         value;
  int               i,k;
  IGRshort          type;

  *msg = MSFAIL;

  if(tag == TRUE)
  {
    printf("Use a tagged method, not yet implemented\n");
    return OM_W_ABORT;
  }

  status = om$send(msg = message SMmgr.SMGetShortName(&loc_msg,name),
		   targetid = my_id); 
  if(!(status & loc_msg & 1)) return status;
   
  status = om$send(msg = message SMfrm_syst.SMGetAttTxt
		   (&loc_msg,"axis",axis,&type),
		   targetid = my_id);
  if(!(loc_msg & 1))
   {printf("Error retreiving axis\n");return status;}
  
  status = om$send(msg = message SMfrm_syst.SMGetAttTxt
		   (&loc_msg,"orient",orient,&type),
		   targetid = my_id);
  if(!(loc_msg & 1))
   {printf("Error retreiving orientation\n");return status;}

  if(orient[0] == 'N')
   {axis[1] = axis[0]; axis[0] = '-';  axis[2] = '\0';}
  
  status = om$send(msg = message SMfrm_syst.SMGetAttDbl
		   (&loc_msg,"offset",&offset,&type),
		   targetid = my_id);
  if(!(status & loc_msg & 1))
   {printf("Error retreiving offset distance\n");return status;} 
  SMConvDistIntUnit(offset,out_units,&offset,OM_Gw_current_OS);

  status = om$send(msg = message SMfrm_syst.SMGetAttDbl
		   (&loc_msg,"nb_sect",&nb_sect,&type),
		   targetid = my_id);
  if(!(status & loc_msg & 1))
   {printf("Error retreiving nb_sect \n");return status;}


  strcpy(att_name,"S");
  for(i=0;i<(int)nb_sect;i++)
   {
     sprintf(&att_name[1],"%d",i);
     k = strlen(att_name);
     strcpy(&att_name[k],"from");
     status = om$send(msg = message SMfrm_syst.SMGetAttDbl
		      (&loc_msg,att_name,&value,&type),
		      targetid = my_id);
     if(!(status & loc_msg & 1))
      {printf("Error retreiving  attributes %s\n");return status;}
     sect_info[i].fr = (int)value;

     strcpy(&att_name[k], "to");
     status = om$send(msg = message SMfrm_syst.SMGetAttDbl
		      (&loc_msg,att_name,&value,&type),
		      targetid = my_id);
     if(!(status & loc_msg & 1))
      {printf("Error retreiving attributes %s\n");return status;} 
     sect_info[i].to = (int)value;

     strcpy(&att_name[k], "spacing");
     status = om$send(msg = message SMfrm_syst.SMGetAttDbl
		      (&loc_msg,att_name,&sect_info[i].spacing,&type),
		      targetid = my_id);
     SMConvDistIntUnit(sect_info[i].spacing,out_units,&sect_info[i].spacing,
		      OM_Gw_current_OS);
     
     if(!(status & loc_msg & 1))
      {printf("Error retreiving attributes %s\n");return status;}
   }

  if(options & SM_ASCII_FILE)
  {
   /* Use an ascii file */
   fprintf(p_file, "FRA \"%s\" \"%s\" %d\n",name,axis,offset);
   for(i=0; i<(int)nb_sect; i++)
     fprintf(p_file,"%g %d ",sect_info[i].spacing,sect_info[i].fr);
   fprintf(p_file,"%g %d %g\n",sect_info[(int)nb_sect -1].spacing,
	   sect_info[(int)nb_sect -1].to,sect_info[(int)nb_sect -1].spacing);
   fprintf(p_file, "\n");
  }
 else
  {
   /* It is a binary file */
   printf("Binary file not yet implemented\n");
   return OM_W_ABORT;
  }
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}


/* ******************* MSG  SMFillRpFile() ************************	*/

method SMFillRpFile(IGRlong *msg; IGRchar *DescFile; FILE *p_file;
                    IGRshort options; IGRboolean tag; IGRshort out_units;
                    struct GRmdenv_info *obj_env, *trans_env)
{
  IGRlong      status;
  struct GRid *frame;
  IGRint       nb_frame,nb_elem_col,lowest,highest;
  IGRdouble    *fr_pos = NULL,cv_fr_pos,cur_spacing,prec_spacing;
  char         spacing_str[80];
  int          i,col,row,fr_num,fr_ind;
  char         tmp_str[256];

#define NB_REP_COL 3
#define NB_CHAR_COL 27

  status = om$send(msg = message SMfrm_syst.SMfind_all_frame
		   (msg,&frame,NULL,&nb_frame,&lowest,&highest),
		   targetid = my_id);
  as$status(sts = (status & *msg),action = RET_STATUS);

  if(nb_frame) 
   {
     nb_elem_col = nb_frame / NB_REP_COL;
     if(nb_elem_col * NB_REP_COL < nb_frame) nb_elem_col++;
   }
  else goto wrapup;

  /* One line of '*' */
  for(i = 0; i < NB_CHAR_COL * NB_REP_COL + 8; i++) tmp_str[i] = '*';
  strcpy(&tmp_str[i],"\n* "); 
  fprintf(p_file,tmp_str);

  /* Header line */
  for(col = 0; col < NB_REP_COL; col++)
   {
     fprintf(p_file,"%8s%10s%9s","NUM","DIST.","SPACING");
     if(col != (NB_REP_COL - 1)) fprintf(p_file," :");
     else                        fprintf(p_file," *\n");
   }

  /* One line of '-' separate by ':' */
  fputc('*',p_file);
  for(col = 0; col < NB_REP_COL; col++)
   {
     for(i = 0; i < (col == 0 ? NB_CHAR_COL + 2 : NB_CHAR_COL + 1) ; i++)
       tmp_str[i] = '-';
     if(col != (NB_REP_COL - 1))  tmp_str[i++] = ':';
     else                         tmp_str[i++] = '*';
  
     tmp_str[i] = '\0';
     fprintf(p_file,tmp_str);
   } 

  /* Retreive position of each frame */ 
  fr_pos= _CALLOC(nb_frame,IGRdouble);
  /* if(!fr_pos) goto wrapup; */
  
  for(i = 0; i < nb_frame; i++)
   {
     status = om$send(msg = message SMframe.SMgive_rel_position
		      (msg,&fr_pos[i]),
		      targetid = frame[i].objid,
		      targetos = frame[i].osnum);
     as$status(sts = (status & *msg),action = GOTO_VALUE,value = wrapup);
   }
  
  /* Display all frame on column */
  for( row = 0; row < nb_elem_col; row++)
   {
     fprintf(p_file,"\n* ");
     for(col = 0; col < NB_REP_COL; col++)
      {
	fr_ind = row + col * nb_elem_col;
	fr_num = fr_ind + lowest;
	
	if(fr_num <= highest)   /* Last column can contain blank line */
	 {
	   SMConvDistIntUnit(fr_pos[fr_ind],out_units,
			     &cv_fr_pos,OM_Gw_current_OS); 

	   if(fr_num  <= highest - 1)
	     cur_spacing = fr_pos[fr_ind + 1] - fr_pos[fr_ind];
	   else if(fr_ind > 0)  /* It is last frame */
	     cur_spacing = fr_pos[fr_ind] - fr_pos[fr_ind - 1];
	   else
	     cur_spacing = 0.0;

	   if(fr_num > lowest)
	     prec_spacing = fr_pos[fr_ind] - fr_pos[fr_ind - 1];
	   else
	     prec_spacing = cur_spacing;

	   /* Display spacing for the first row and when change */
	   /* with preceding spacing                            */

	   if((row == 0 && fr_num <= highest - 1) ||
	      fabs(cur_spacing - prec_spacing) > 0.00001) 
	    {
	      SMConvDistIntUnit(cur_spacing,out_units,
				&cur_spacing,OM_Gw_current_OS);

	      if(out_units & SM_UNIT_MMTR)
		sprintf(spacing_str,"%8.1f",cur_spacing);
	      else
		sprintf(spacing_str,"%8.3f",cur_spacing);
	    }
	   else
	     spacing_str[0] = '\0';

	   /* If millimeter keep only 1 decimal digit else keep 3 */
	   if(out_units & SM_UNIT_MMTR)
	     fprintf(p_file," %8d %8.1f %8s",fr_num,cv_fr_pos,spacing_str);
	   else
	     fprintf(p_file," %8d %8.3f %8s",fr_num,cv_fr_pos,spacing_str);
	 }
	else
	  for(i = 0; i < NB_CHAR_COL  ; i++) fputc(' ',p_file);

	/* Separate columm */
	if(col != (NB_REP_COL - 1)) fprintf(p_file," :");
	else
	  fprintf(p_file," *");
      }
   }
  
  if(fr_pos)        _FREE(fr_pos);
  if(frame != NULL) _FREE(frame);
  *msg = MSFAIL;
  return OM_S_SUCCESS;

 wrapup:
  if(fr_pos)        _FREE(fr_pos);
  if(frame != NULL) _FREE(frame);
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
method DIgive_output( char *output ) {

	long		sts,
			msg ;
	VDobjDef	objDef ;
	extern char 	*VDmsgkey2string __(( long msgkey )) ;

	/*
	 * Pretty-print yourself in "Display Directory Command" form.
	 */
	sts = om$send(	msg 	= message SMfrm_syst.SMgetObjDef(&msg,&objDef),
			targetid= my_id ) ;
	if( sts & 1 & msg ) {
		strcat( output, "[" ) ;
		strcat( output, VDmsgkey2string( objDef.info ) ) ;
		strcat( output, "]" );
	} else {
		/*
		 * Just in case the messages failed ...
		 */
		strcat( output, "()" ) ;
	}

	return OM_S_SUCCESS ;

} /* method DIgive_output */

/*----------------------------------------------------------------------------*/
method SMgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjFrameSys ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method SMgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMfrm_syst;

