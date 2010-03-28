/*
  ACncpxi.I
  robert patience
  1 sept 1989
*/
class implementation ACncpx;

#define AS_DEBUG

extern char *regcmp();
extern char *regex();
extern char *strpbrk();


#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h" 
#include "DIomac.h" /*DIcheck_link DIfree*/
#include "exdef.h"
#include "exmacros.h"
#include "grownerdef.h"
#include "grownmacros.h"

extern GRclassid OPP_ASsource_class_id;

from ACcpx_defn import 	 ACgive_feet_desc;

 method IGRdir.remove ( DIint *status; DIchar *name; DIint index )
 {
  *status = MSSUCC;
  return (OM_S_SUCCESS);
 }


method translate ( DIint *stat; DIchar *name; int index; DIchar *p_name; DIobjid *objid )
{
  int status,suc;
  struct GRid 		feet_obj;
  char *nm;

  nm=(char *)name;
  status = om$send(msg =  message ACncpx.ACgive_foot(&suc,name,&feet_obj),
		   targetid = my_id );
  as$status( action = RET_STATUS );
  if(objid)
  *objid = feet_obj.objid;
  if(suc==0) *stat= DIR_W_NAME_NOT_FOUND;
   else      *stat= DIR_S_SUCCESS ;
  return ( OM_S_SUCCESS );
}

method dump ( DIint *stat; DIchar *reg_exp; OM_p_CLASSLIST classlist;
                DIchar ***lines; DIgrid **grids; DIint *count; 
                DIchar options )
{
  struct myfeet 	*feet;
  int 			feet_num, i, status,suc;
  char 			**mname = NULL;
  struct GRid		*ft = NULL,wk_ft;
  int 			wcount;
  struct GRid mac_def;

/*"option %d OPT_SYS %d\n",options,OPT_SYS */

 if(options & OPT_SYS /* || me->mac_def.osnum == 0 */)
 
  {
    /*| Dump returns nothing because after NDsleep or before AC wakeup */
    *count = 0;
    *stat = DIR_S_SUCCESS;
    return(OM_S_SUCCESS);
  }

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


  status = om$send( msg = message ACcpx_defn.ACgive_feet_desc(&feet_num, &feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
  as$status( action = RET_STATUS );
    
  if(feet_num)
   {
   ft=(struct GRid *)om$malloc (size =feet_num  * sizeof(struct GRid));
   mname=(char **) om$malloc (size =  feet_num  * sizeof(char **));
   }

  wcount=0;
  for(i=0;i<feet_num;i++)
   {
 /*" before %s\n",feet[i].name */
   status = om$send(msg =  message ACncpx.ACgive_foot
		(&suc,feet[i].name,&wk_ft),
		   targetid = my_id );
   as$status( action = RET_STATUS );
 /*" return %d %s\n",suc,feet[i].name */

   if(suc!=0 && suc!=temp_miss_foot)
    {
    GRclassid obj_class;
    mname[wcount] = om$malloc(size = strlen(feet[i].name)+1); 
    strcpy(mname[wcount],feet[i].name);

    /* because HB check probably classes before sending dump message    */
    /* and to have parent ACdiowner understand like a nested collection */

    om$get_classid(objid = wk_ft.objid,
		   osnum = wk_ft.osnum,
		   p_classid = &obj_class);
    if(om$is_ancestry_valid(subclassid = obj_class,
			  superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS)
      {
       status = om$send(msg = message NDnode.ASreturn_go(ft+wcount,NULL,NULL),
                        targetid = wk_ft.objid,
                        targetos = wk_ft.osnum);
       if(!(status&1)) ft[wcount]=wk_ft;
      }
    else ft[wcount]=wk_ft;

    wcount +=1;
    } 
   }
  *count= *count + wcount;
  *grids= (DIgrid *) ft;
  *lines=mname;
  *stat= DIR_S_SUCCESS ;
 return(1);
}

/* utile ????? */

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

/* a unique name is allowed */

method GRputname(IGRlong *msg; IGRchar *name)
{
  char old_name[DI_PATH_MAX];
  int i;

  *msg = MSFAIL;

    /*| remove the names from the global table */

  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = old_name ) != DIR_S_SUCCESS)
      { 
       if(name == NULL || name[0] == '\0')  *msg = MSSUCC;
       else if (DIadd_dir ( OM_Gw_current_OS, my_id, name, 1 ) == DIR_S_SUCCESS)
    					    *msg = MSSUCC;
       break;
      }
    else if(DIunlink_dir ( old_name, 1 ) != DIR_S_SUCCESS) break;
   }

  return OM_S_SUCCESS;
}

method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
 return (om$send(msg = message ACncpx.GRputname(msg,name),
		 targetid = my_id));

}


method delete(int i)
{
  char name [DI_PATH_MAX];
  int i;

    /*| remove the names from the global table */

  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
    if(di$untranslate ( objid = my_id, objname = name ) != DIR_S_SUCCESS) break;
    if(DIunlink_dir ( name, 1 ) != DIR_S_SUCCESS) break;
   }

 return  om$send(msg = message ACcpx.delete(i),
		  mode = OM_e_wrt_message,
		  targetid = my_id);
}


DIadd_dir ( osnum, objid, name, add )
            DIspacenum osnum	/* Object osnum				IN  */;
            DIobjid    objid	/* Object id				IN  */;
            DIchar     *name	/* Name of the link			IN  */;
            DIint      add	/* To add or not to add the name	IN  */;
/* This procedure is used to add a directory tree to the hieararchy. */
{
  DIint      status,msg;
  DIspacenum loc_osnum;

  /* check OS */
  status = di$give_osnum ( pathname = name, p_osnum = &loc_osnum );
  if ((status == DIR_S_SUCCESS) && (osnum == loc_osnum))
  {
      DIchar  path_name [DI_PATH_MAX], 
              base_name [DI_PATH_MAX], 
              dir_name [DI_PATH_MAX];
      DIgrid  target_grid,my_grid;

      DIexpanse ( name, path_name );
      di$split ( pathname = path_name, dirname = dir_name, name = base_name );
      status = DImasterRetrieve ( &msg, dir_name, NULL, (DIchar *)&target_grid, NULL, NULL );
      as$status(action = RET_STATUS);

      /* add it to the directory */
      if (add)
      {
        /* add in dir AND untree */
        status = om$send(msg = message IGRdir.add(&msg, base_name, objid, NULL),
                         senderid = NULL_OBJID,
		  	 targetid = target_grid.objid,
			 targetos = target_grid.osnum );
	as$status(action = RET_STATUS);


      /* must be in the master if it's a directory */

      my_grid.osnum = osnum; my_grid.objid = objid;
      }

  }
  else
    status = DIR_E_ILL_LINK;

  return status;
}


DIunlink_dir ( name, remove )
               DIchar *name     /* Name of the link                     IN  */;
               DIint  remove    /* To remove or not to remove the name  IN  */;
/* This procedure is used to remove a directory tree from the hieararchy.   */
/*.DIunlink_dir*/
{
  DIint      status, msg;
  DIchar     full_name [DI_PATH_MAX], 
             dir_name [DI_PATH_MAX], 
             base_name [DI_PATH_MAX];
  DIobjid    objid, owner_id;
  DIspacenum osnum, owner_os;

  status = di$translate ( objname = name, p_objid = &objid, p_osnum = &osnum );
  if (status != DIR_S_SUCCESS) return status;

  /*| remove the entry point from the untree */
  DIexpanse ( name, full_name );
  di$split ( pathname = full_name, dirname = dir_name, name = base_name );
  /*"dir_name %s \n", dir_name */
  /*| remove it from the directory */
  DIcheck_link ( osnum, objid );
  status = di$translate ( regexp = dir_name, p_objid = &owner_id, p_osnum = &owner_os );
  if (status != DIR_S_SUCCESS)
   { /*| translate fail */ return status; }

  if (remove)
  {
    /*" remove %s from dir AND untree\n",base_name */
    status = om$send (msg = message IGRdir.remove ( &msg, base_name, NULL ),
		      senderid =  NULL_OBJID,
		      targetid = owner_id,
		      targetos = owner_os );
    /*"msg %d\n",msg*/
    as$status(action = RET_STATUS);
  }
  else
   {
    /*| remove from untree */
    DIunall ( osnum, objid, dir_name, base_name, 1, NULL, NULL );
   }

  if (DIancestry_valid ( osnum, objid, DIR_G_DIlink_clid ))
  {
    DIspacenum root_os;
    DIobjid    root_id;

    /* the directory is a link : remove the root of the OS */
    om$get_intercept ( osnum = osnum, objid = objid, p_target_osnum = &root_os, p_target_objid = &root_id );
    DIunall ( root_os, root_id, dir_name, base_name, 1, NULL, NULL );
  }

  return status;
}


method DIgive_output (  char *formula )
{
 strcat(formula,"()");
 return OM_S_SUCCESS;
}

end implementation ACncpx;
