class implementation ACdiowner;

#include "AS_status.h"
#include "msdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "expression.h"
#include "expmacros.h"
#include "ASmsg.h"
#include "grmsg.h"
#include "OMmacros.h"
#include "msmacros.h"

#define AS_DEBUG

#define _gr_clear_field(f)           \
ex$message( field = f,               \
            msgnumb = GR_I_Clear )



from expression import create;
from NDnode     import NDgive_structure;

extern GRclassid OPP_Gexp_class_id,
		 OPP_Gtext_exp_class_id,
		 OPP_ACcpx_class_id,
		 OPP_ACrg_collect_class_id;
/*
   Define the structure chanselect for the componant channel  
*/

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

 return 1;
}

/* Generate a default name for the di_owner */
static ACdefault_name(di_name)
char *di_name;
/*.ACdefault_name*/
{
int ib;
int status;
OM_S_OBJID tmp_id;

 strcpy(di_name,"attrib");

 for(ib=0;ib<1000;ib=ib+1)
  {
   sprintf(&di_name[6],"%d",ib);
   status = di$translate(objname = di_name,
                         p_objid = &tmp_id);
   if(!(status&1)) break;
  }
 if(ib==1000) return(OM_W_ABORT);
 else return (OM_S_SUCCESS);
}

method unknown (OM_S_MESSAGE *msg)
{

/*^
 {
  long status;
  char classname1 [OM_K_MAXCLASS_LEN], classname2 [OM_K_MAXCLASS_LEN];
  IGRchar       name [80];
  om$get_classname( classid = msg->select.ReqClassid,
                    classname = classname2 );
  om$get_classname( classid = msg->select.DefClassid,
                    classname = classname1 );
  status = om$get_message_name ( classid = msg->select.ReqClassid,
                                 method_index = msg->select.FuncIndex,
                                 msg_name = name );

  printf ( "Unknown Message from %s to %s,%s\n",classname1, classname2,
                name);
 }
*/

  return(OM_S_SUCCESS);

} /* end method unknown */

/* Return the value of a given attribute */

method ACgive_structure(int *msg,*direct_index;char *name;
			struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{ IGRlong loc_msg,status;
 OM_S_OBJID attribute;
 
/* Isn't it fun to have DItype */

status = om$send(msg = message IGRdir.translate
	 ( (DIint *) &loc_msg, (DIchar *)name, -1, NULL,(DIobjid *)&attribute),
		 targetid = my_id);
as$status();

if (loc_msg&1)
 {
  status = om$send(msg = message  NDnode.NDgive_structure
						      (&loc_msg,ptr_rst,md_env),
		   targetid = attribute);
  *msg = MSSUCC;
 }
else
 {
  *msg = MSFAIL;
 }
return(OM_S_SUCCESS);
}

method  ACreturn_foot(long *suc;char *footname;struct GRid *foot_GRid;
		      IGRshort *mat_type; IGRdouble *matrix)
{
 int status,msg;
 status = om$send(msg = message ACdiowner.translate
 			((DIint *)suc, footname, -1,  NULL, &foot_GRid->objid ),
		  targetid = my_id);
 if(*suc&1)
  {*suc = 1;
   if(mat_type != NULL) *mat_type = MAIDMX;
   if(matrix != NULL) MAidmx(&msg,matrix);
   foot_GRid->osnum = OM_Gw_current_OS;
  }
 else  *suc = 0;

 return (OM_S_SUCCESS);
}


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 char dir_name[DI_PATH_MAX];
 char *sepa;
 long status;
 char *strrchr();

 ex$message (buff=info->type,
 	     msgnumb=AS_I_ElmAtr);

 status = di$untranslate(objid = my_id,
                         objname = dir_name);
 *msg = MSSUCC;
 sepa = strrchr(dir_name,':');
 if(sepa != NULL)
   {
    strcpy(&info->type[18],"  ");
    strcpy(&info->type[20],sepa+1);
   }
 return(OM_S_SUCCESS);
}

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
               struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 IGRlong status;
 status = om$send(msg=message GRowner.GRcopy(msg,obj_dsenv,new_dsenv,newobjid),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 if(status&1) status = om$send(msg = message ACdiowner.ACcreate(msg,NULL),
			       targetid = *newobjid,
			       targetos = new_dsenv->md_id.osnum);
 
 return(status);

}
  



method GRcomponent_disconnecting (IGRlong *msg; struct GRmd_env *mod_env;
                                   struct GRid *comp_id)
{
 int index_attr,i;
 OMuint nb_componants;
 OMuint index_deleted;
 OM_S_CHANSELECT *componant;
 IGRlong status;

/* retrieve componant index */
 
 get_componant_ch(&componant);
 status = om$get_index(p_chanselect = componant,
		       objid_c = my_id,
		       objid = comp_id->objid,
		       indexaddr = &index_deleted);
 as$status(action = RET_STATUS);

 for(i=0;i<me->nb_attr;i++) if(me->attr_def[i].index >= index_deleted) break;
 index_attr = i;

 if(me->attr_def[index_attr].index == index_deleted)
 {
   /*| the disconnected element is an attibute */
  status = om$send(msg = message ACdiowner.ACrem_att_at_index(msg,index_attr),
		   targetid = my_id);
 }
 else
  { 
   /*| the disconnected element is not an attribute */
   for(i=index_attr;i<me->nb_attr;i++) me->attr_def[i].index -= 1;
  }

 


/* Delete the diowner if no components, or no attributes remain connected */
 
 status = om$get_channel_count(p_chanselect = componant,
			       objid = my_id,
			       count = &nb_componants);
 as$status(action = RET_STATUS);
 /*"nb_attr %d nb_comp %d\n",me->nb_attr,nb_componants*/

 if(  me->nb_attr == 0 
    || nb_componants == me->nb_attr+1)
   {
    /*| Delete the DIowner */
    status = om$send(msg = message Root.delete(1),
		     p_chanselect = componant);
    as$status();
    status = om$send(msg = message Root.delete(1),
		     targetid = my_id);

			
   }
 return(OM_S_SUCCESS);
}

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
 *msg = MSSUCC;
 *properties = GR_LC_CMP_READ     | GR_LC_CMP_WRITE     |
               GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
               GR_LC_CMP_PRM_READ | GR_LC_CMP_PRM_WRITE |
               GR_LC_FLEXIBLE;
 return(OM_S_SUCCESS);
}

/* add an attribute to the diowner */
method ACadd_attribute(IGRlong *msg; IGRchar *name; IGRchar *text)
{
IGRlong status;
status = om$send(msg = message ACdiowner.ACadd_attribute_by_type(msg,
					 AC_ATTRIB_TYPE_NOT_DEF, name, text),
		 targetid = my_id);
return(status);
}

method ACadd_attribute_by_type(IGRlong *msg; IGRint type;
			IGRchar *name; IGRchar *text)
{
 OM_S_OBJID attribute;
 int previous_size,name_size;
 IGRlong status,rc;
 IGRshort rcc;
 struct GRid my_grid;
 IGRlong owner_index,graphic_index;
 OMuint index;
 IGRlong flag;
 OM_S_CHANSELECT *componant;
 char dir_name[DI_PATH_MAX], previous_dir[DI_PATH_MAX];

/* verify that the attribute does not already exist */

 *msg = MSFAIL;

 status = om$send(msg = message ACdiowner.translate ((DIint *)&rc, name, -1, NULL,
		   				      &attribute),
		  targetid = my_id);
 if(rc&1)
   {/*| attribute already exist */ return (OM_S_SUCCESS); }

/*" create the attribute name >>%s<< >>%s<<\n",name,text */

 status = di$untranslate(objid = my_id,
			 objname = dir_name);

 if(text != NULL)
  {
   /* Make the attribute syntax relative to the attribute directory */
    di$pwd(dirname = previous_dir);
    di$cd(dirname = dir_name);
   
   /* Try first to create an numerical expression */

   if(type&AC_ATTRIB_DOUBLE)
    {
     status = om$construct(classid = OPP_Gexp_class_id,
			 osnum = OM_Gw_current_OS,
			 p_objid = &attribute);
     as$status(action = RET_STATUS);

     status = om$send(msg = message expression.create ( NULL,text , &rcc ),
                   targetid = attribute);
     /*"status %d rcc %d\n",status,rcc */

     if(!(status&1) || !(rcc&1))
      {
       _gr_clear_field(ERROR_FIELD);
       om$send(msg = message Root.delete(1),
	       targetid = attribute);
       status = OM_W_ABORT;
      }
    }
   else status = OM_W_ABORT;

   if(!(status&1) && (type&AC_ATTRIB_TEXT))
    {
     status = om$construct(classid = OPP_Gtext_exp_class_id,
			 osnum = OM_Gw_current_OS,
			 p_objid = &attribute);
     as$status(action = RET_STATUS);
   
     status = om$send(msg = message expression.create(NULL,text, &rcc),
		    targetid = attribute);
     as$status(action = RET_STATUS);
    }

   /* restore previous dir */
    di$cd(dirname = previous_dir);
  }
 as$status(action = RET_STATUS);


/* connect this attribute with the owner channel */

  owner_index = OM_K_MAXINT;
  graphic_index = OM_K_MAXINT;
  flag = 0;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  status = om$send( msg = message GRconnector.GRflexconn
			( msg,&flag, &my_grid, &owner_index, &graphic_index ),
		    targetid = attribute);
  if(*msg != MSSUCC) status = OM_W_ABORT;
  as$status(action = RET_STATUS);

/* store information about the attribute */

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
  om$get_index(objid_c=my_id,
	       p_chanselect = componant,
	       objid = attribute,
	       indexaddr = &index);
  /*"index %d\n",index*/

  me->attr_def[me->nb_attr].name = previous_size;
  me->attr_def[me->nb_attr].index = index;
  me->nb_attr = me->nb_attr + 1;


  return(OM_S_SUCCESS);

}

/* Modify the value of an attribute */

method ACmod_attribute(IGRlong *msg;
			IGRchar *name; IGRchar *text)
{
IGRlong status,rc;
int index;
OM_S_OBJID attribute;

 *msg = MSFAIL;
/* verify that the attribute does not already exist */
 index = 0;

 status = om$send(msg = message ACdiowner.translate ( (DIint *)&rc, name,
					     index, NULL, &attribute),
		  targetid = my_id);
 if(!(rc&1))
   {/*| attribute does not exist */ return (OM_S_SUCCESS);
   }

 rc  = exp$modify(exp_id = attribute,
	    	  osnum = OM_Gw_current_OS,
	    	  exp_syntax = text);
 if(rc&1) *msg = MSSUCC;
 else	  *msg = MSFAIL;
 
 return(OM_S_SUCCESS);
}

method ACrem_attribute(IGRlong *msg;
			IGRchar *name)
{
 int index_attr;
 int status;
 OM_S_CHANSELECT *componant;
 OM_S_OBJID attribute;
 OMuword os;

  /*"nb_attrib %d\n",me->nb_attr*/

  *msg = MSFAIL;
  for(index_attr=0 ; index_attr<me->nb_attr ; index_attr++)
   {
    if(strcmp(name,&me->attr_name[me->attr_def[index_attr].name]) == 0) break;
   }
  if(index_attr >= me->nb_attr) { return(OM_S_SUCCESS);}

/*"found at index %d channel %d\n",index_attr,me->attr_def[index_attr].index*/

/* delete the attribute */
  
  get_componant_ch(&componant);

  status = om$get_objid_at_index(objid = my_id,
				 p_chanselect = componant,
				 index = me->attr_def[index_attr].index,
				 objidaddr = &attribute,
				 osnumaddr = &os);
  status = om$send(msg = message Root.delete(1),
		   p_chanselect = componant,
		   from = me->attr_def[index_attr].index,
		   to   = me->attr_def[index_attr].index);
  as$status();

/* left shift on attributes name */

  status = om$send(msg = message ACdiowner.ACrem_att_at_index(msg,index_attr),
		   targetid = my_id);

/* delete the di_owner ? */

  if(me->nb_attr == 0)
    { status = om$send(msg = message Root.delete(1),
		       targetid = my_id);
    }

  *msg = MSSUCC;
  return(OM_S_SUCCESS);
}

method ACrem_att_at_index(IGRlong *msg; IGRint index)
{
 int i,name_size,previous_size,name_index;
 IGRlong status;


 *msg = MSFAIL;

/* left shift on attributes name */

  me->nb_attr -= 1;
  name_index = me->attr_def[index].name;
  name_size = strlen(&me->attr_name[name_index])+1;
  previous_size = om$dimension_of(varray = me->attr_name);

  OM_BLOCK_MOVE(
	        &me->attr_name[name_index+name_size],
	        &me->attr_name[name_index],
		previous_size - name_index - name_size);


/* left shift on attribute array */

  for(i=index ; i<me->nb_attr ; i++)
    { me->attr_def[i].index = me->attr_def[i+1].index - 1;
      me->attr_def[i].name  = me->attr_def[i+1].name - name_size; }

/* reduce size of vlas */

  status = om$vla_set_dimension(varray = me->attr_def,
                                size = me->nb_attr);

  status = om$vla_set_dimension(varray = me->attr_name,
                                size = previous_size - name_size);
  *msg = MSSUCC;
 
  return(OM_S_SUCCESS);
}


/* Initialize a DIowner */

method ACcreate(IGRlong *msg; IGRchar *name)
{
 char di_name[DI_PATH_MAX];
 char *my_name;
 struct GRid wd;
 IGRlong status;

 *msg   = MSFAIL;
 status = OM_S_SUCCESS;

/*"add de name %d\n",name */

 if(name != NULL) my_name = name;
 else
  {
    status = ACdefault_name(di_name);
    /*"default name return %s\n",di_name */
    as$status(action = RET_STATUS);
    my_name = di_name;
  }

 di$pwd(p_dirid = &wd.objid, p_osnum = &wd.osnum);
 if( my_name[0] != '\0' && (wd.osnum == OM_Gw_current_OS || my_name[0] == ':'))
  { /*"name is %s\n",my_name */
	status = DIadd_dir(OM_Gw_current_OS,my_id,my_name,1);
	as$status( action = RET_STATUS );
	*msg = MSSUCC;
  }
 else  *msg = MSSUCC;

return	status;
}

method ACadd_component(IGRlong *msg; struct GRid *component)
{
 long flag     =0;        
 long owner_ind=OM_K_MAXINT;
 long graph_ind=OM_K_MAXINT;
 struct GRid my_grid;
 long status;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 
 status = om$send (msg      = message GRconnector.GRflexconn(msg, &flag,
                                      &my_grid,&owner_ind,&graph_ind),
                   targetid = component->objid,
                   targetos = component->osnum);
 as$status(action = RET_STATUS);
 return(OM_S_SUCCESS);
}

method ACadd_component_with_name(IGRlong *msg; struct GRid *component;
				 IGRchar *name)
{
 long flag     =0;        
 long owner_ind=OM_K_MAXINT;
 long graph_ind=OM_K_MAXINT;
 struct GRid my_grid;
 long status;
 int previous_size,name_size;
 OMuint index;
 OM_S_CHANSELECT *componant;

/*"componant %d %d name %s\n",component->objid,component->osnum,name*/

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 
 status = om$send (msg      = message GRconnector.GRflexconn(msg, &flag,
                                      &my_grid,&owner_ind,&graph_ind),
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
  om$get_index(objid_c=my_id,
	       p_chanselect = componant,
	       objid = component->objid,
	       indexaddr = &index);
  /*"index %d\n",index*/

  me->attr_def[me->nb_attr].name = previous_size;
  me->attr_def[me->nb_attr].index = index;
  me->nb_attr = me->nb_attr + 1;

 return(OM_S_SUCCESS);
}

method dump ( DIint *stat; DIchar *reg_exp; OM_p_CLASSLIST classlist;
                DIchar ***lines; DIgrid **grids; DIint *count; 
                DIchar options )
{
  char 			**mname;
  struct GRid		*ft;
  int i,iatt;
  OMuint nb_componants;
  IGRlong status;
  OM_S_CHANSELECT *componant;

 if(options & OPT_SYS)

  {
    /*| Dump returns nothing because after NDsleep or before AC wakeup */
    *count = 0;
    *stat = DIR_S_SUCCESS;
    return(OM_S_SUCCESS);
  }


/* get number of componants */

  get_componant_ch(&componant);
  status = om$get_channel_count(p_chanselect = componant,
			        objid = my_id,
			        count = &nb_componants);
  as$status(action = RET_STATUS);

  *count= *count + nb_componants;

/* get name for each of them */

  ft = NULL;
  mname = NULL;
  if(nb_componants)
   {
    ft=(struct GRid *)om$malloc (size =nb_componants  * sizeof(struct GRid));
    mname=(char **) om$malloc (size =nb_componants  * sizeof(char **));
   }

  for(i=0,iatt=0;i<nb_componants;i++)
   {
    status = om$get_objid_at_index ( p_chanselect = componant,
                               index = i,
                               objid = my_id,
                               objidaddr = &ft[i].objid,
                               osnumaddr = &ft[i].osnum);
    as$status( action = RET_STATUS );

    /* 
     * Adding one more check - (iatt < me->nb_attr)
     * We need to malloc only until the number of attributes.
     * At times, the index may be equal to i even though the
     * attribute list would have been over and in such cases, the
     * strlen may fail due to a null pointer, etc.
     * TR 119526236 - Srikanth.
     */

    if( (iatt < me->nb_attr) && (me->attr_def[iatt].index == i) )
     {
      mname[i] = om$malloc(
		     size = strlen(&me->attr_name[me->attr_def[iatt].name])+1); 
      /*" malloc %d\n",strlen(&me->attr_name[me->attr_def[iatt].name])+1 */
      strcpy(mname[i],&me->attr_name[me->attr_def[iatt].name]);
      iatt += 1;
     }
    else
     {
      mname[i] = om$malloc(size = 1); 
      *mname[i] = '\0';
     }

    /*"attr %d name %s id %d %d\n",i,mname[i],ft[i].objid,ft[i].osnum*/
   }
  *grids= (DIgrid *)ft;  /* grrrrrrrr */
  *lines=mname;
  *stat= DIR_S_SUCCESS ;
  return(1);
}


method translate ( DIint *stat; DIchar *name; int index; DIchar *p_name;
		   DIobjid *objid )
{
 int status;
 int index_attr;
 GRspacenum osnum;
 OM_S_CHANSELECT *componant;
IGRchar	*strchr(), *find_name;

  *stat = DIR_W_NAME_NOT_FOUND;

/*"translate %s\n",name*/

/*| Initialization */
  find_name	= strchr( name, ':' );
  if( find_name) *find_name = '\0';

  for(index_attr=0 ; index_attr<me->nb_attr ; index_attr++)
   {
    /*"%d --> %s\n",index_attr,&me->attr_name[me->attr_def[index_attr].name] */
    if(strcmp( name, &me->attr_name[me->attr_def[index_attr].name]) == 0)
       {/*| found */; break;}
   }
  /*"index_attr %d index on channel %d\n",index_attr,me->attr_def[index_attr].index*/

  if(find_name ) *find_name = ':';

  if(index_attr < me->nb_attr)
    {
        DIobjid loc_objid;
        
        if (objid == NULL) objid = &loc_objid;
        
     get_componant_ch(&componant);
     status = om$get_objid_at_index ( p_chanselect = componant,
                                      index = me->attr_def[index_attr].index,
                                      objid = my_id,
                                      objidaddr = objid,
				      osnumaddr = &osnum);
     as$status( action = RET_STATUS );

     if( find_name ){

		/* recursion for macro */
		status = om$send(	msg	 = message IGRdir.translate(
							stat,
							find_name+1,
							index,
							p_name,
							objid ),
					targetid = *objid,
					targetos = osnum );
		as$status( action = RET_STATUS );
	}

     *stat = DIR_S_SUCCESS;
     /*"objid %d\n",*objid */
    }
  return (OM_S_SUCCESS);
}


method add ( DIint  *status; DIchar *name; DIobjid objid; int *p_index )
{
 *status = DIR_E_ABORT;
 return(OM_S_SUCCESS);
}


method GRgetname(IGRlong *msg; IGRchar *name)
{
  if (di$untranslate ( objid = my_id, objname = name ) == DIR_S_SUCCESS)
    *msg = MSSUCC;
  else
    *msg = MSFAIL;

  return 1;
}

method GRputname(IGRlong *msg; IGRchar *name)
{
  if (DIadd_dir ( OM_Gw_current_OS, my_id, name, 1 ) == DIR_S_SUCCESS)
    *msg = MSSUCC;
  else
    *msg = MSFAIL;

  return 1;
}

method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
  char old_name [DI_PATH_MAX];

  *msg = MSSUCC;

  if (di$untranslate ( objid = my_id, objname = old_name ) == DIR_S_SUCCESS)
    DIunlink_dir ( old_name, 1 );

  if(name != NULL && name[0] != '\0')
   {
   
    if (DIadd_dir ( OM_Gw_current_OS, my_id, name, 1 ) != DIR_S_SUCCESS)
    							         *msg = MSFAIL;
  }

  return OM_S_SUCCESS;
}

method GRdelete_owner(IGRlong *msg; struct GRmd_env *mod_env)
{
  char name [DI_PATH_MAX];
  int i;

    /*| remove the names from the global table */
  
  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = name ) != DIR_S_SUCCESS) break;
    if(DIunlink_dir ( name, 1 ) != DIR_S_SUCCESS) break;
   }

  return (om$send(msg = message GRowner.GRdelete_owner(msg,mod_env),
		  targetid = my_id,
		  mode = OM_e_wrt_message));
}

method delete(int i)
{
  char name [DI_PATH_MAX];
  int status;
  int i;

    /*| remove the names from the global table */
  
  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = name ) != DIR_S_SUCCESS) break;
    if(DIunlink_dir ( name, 1 ) != DIR_S_SUCCESS) break;
   }

  status = om$send(msg = message Root.delete(i),
	  	   targetid = my_id,
		   mode = OM_e_wrt_message);
  return(status);
}

method GRdelete( IGRlong *msg; struct GRmd_env *md_env)
{
  char name [DI_PATH_MAX];
  int status;
  int i;

    /*| remove the names from the global table */
  
  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = name ) != DIR_S_SUCCESS) break;
    if(DIunlink_dir ( name, 1 ) != DIR_S_SUCCESS) break;
   }

  status = om$send(msg = message GRowner.GRdelete(msg,md_env),
	  	   targetid = my_id,
		   mode = OM_e_wrt_message);
  return(status);
}

method GRget_channel_type (IGRlong *msg; IGRint *type; IGRint *conn_type)
{
 *msg = MSSUCC;
 *type = GR_FLEXIBLE;
 *conn_type = GR_NO_OVERRIDE;
 return(OM_S_SUCCESS);
}

/* Return the name of a component */

method ACgive_path(IGRlong *msg; struct GRid *go_obj; char *name)
{
/*
 * The ACrg_collect has to override this message, but until we cannot modify
 * the spec file to declare this override we have to write the code a this
 * level and used a bad get_classid macro to select the real class of the
 * object.
 *
 * Kludge description :
 * An ACrg_collect object has ephemeral componants. The componants decription
 * are done after the regular list of attributs. For this reason we have to
 * move the index limite of the loop.
 */

 OMuint index;
 int index_attr,status;
 OM_S_CHANSELECT *componant;

 /*
  * Variable used for the ACrg_collect Kludge
  */
 GRclassid       cid;
 int             startind, endind;

 /*" give_path for %d\n",go_obj->objid */

 get_componant_ch(&componant);
 status = om$get_index(object_c = me,
		       p_chanselect = componant,
		       objid = go_obj->objid,
		       osnum2 = go_obj->osnum,
		       indexaddr = &index);

 /*" at index %d\n",index */
 *msg = 0;

 /*
  * Kludge for ACrg_collect for 3.0
  * define the good index for the loop
  */
  om$get_classid(       objid     = my_id,
                        p_classid = &cid );
 
  if( om$is_ancestry_valid(subclassid   = cid,
                         superclassid   = OPP_ACrg_collect_class_id )
                                        == OM_S_SUCCESS )
  {
        int nb_comp = 0;
        int total_size = 0;

        om$get_channel_count(objid = my_id,
                            p_chanselect = componant,
                            count = (OMuint *) &nb_comp);
 
        total_size = om$dimension_of(varray = me->attr_def);
        total_size = total_size < nb_comp+me->nb_attr ?
                        total_size : nb_comp+me->nb_attr ;
 
        startind = me->nb_attr;
        endind   = total_size;
  }
  else{
 
        startind = 0;
        endind   = me->nb_attr;
  }

 if(status&1)
  { for(index_attr = startind ; index_attr< endind ; index_attr++)
      { if(me->attr_def[index_attr].index == index)
          {
 	   strcpy(name,&me->attr_name[me->attr_def[index_attr].name]);
	   /*" return name %s\n",name */
	   *msg = 1;break;
	  }
      }
  }
 return (OM_S_SUCCESS);
}

/* given an object returns corresponding diowner */

ACreturn_diowner(in,out)
struct GRid *in,*out;
{
 GRclassid obj_class;
 int index;
 long status;
 OM_S_CHANSELECT owner;

/*| Is the object itself eligible */

 status = om$get_classid (objid     = in->objid,
                          osnum     = in->osnum,
                          p_classid = &obj_class);

 if(om$is_ancestry_valid(subclassid = obj_class,
                         superclassid=OPP_ACdiowner_class_id)==OM_S_SUCCESS
 || om$is_ancestry_valid(subclassid = obj_class,
                         superclassid=OPP_ACcpx_class_id)==OM_S_SUCCESS )
   {
     *out = *in;
     return (OM_S_SUCCESS); 
   }
 

/*| Is there an owner eligible */

  status = om$make_chanselect(channame = "GRconnector.to_owners",
			      p_chanselect = &owner);
  as$status(action = RET_STATUS);


  index = 0;
  while(1)
    {
     status = om$get_objid_at_index(objid = in->objid,
				    osnum = in->osnum,
				    p_chanselect = &owner,
				    index = index++,
				    objidaddr = &out->objid,
				    osnumaddr = &out->osnum);
     if(!(status&1)) break;

     status = om$get_classid (objid     = out->objid,
                              osnum     = out->osnum,
                              p_classid = &obj_class);

     if(om$is_ancestry_valid(subclassid = obj_class,
                             superclassid=OPP_ACdiowner_class_id)==OM_S_SUCCESS
     || om$is_ancestry_valid(subclassid = obj_class,
                             superclassid=OPP_ACcpx_class_id)==OM_S_SUCCESS )
        {/*| found */ return(OM_S_SUCCESS);}

    }


/*| There is no diowner eligible */

  out->objid = NULL_OBJID;
  return(OM_W_ABORT);
 
}


end implementation ACdiowner;
