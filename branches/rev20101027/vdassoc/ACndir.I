/* $Id: ACndir.I,v 1.2 2001/01/18 19:08:50 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/ACndir.I
 *
 * Description:
 *		Avoiding error messages during savings process.
 *
 * Dependencies:
 *		GRNUCSRC/assoc/nmacro/ACndir.I
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      05/10/00	Jayadev 	changes for CR179901429
 ***************************************************************************/

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

#if 0
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
/* START VDS MODIFICATION */
  if( !(status &1) ) return status ;
/* END   VDS MODIFICATION */
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
#endif
/* a unique name is allowed */

method GRputname(IGRlong *msg; IGRchar *name)
{
  char old_name[DI_PATH_MAX];
  char mesg[DI_PATH_MAX];
  char current_dir[DI_PATH_MAX];
  char full_name[DI_PATH_MAX];
  int i,ret_type = FALSE;
  DIobjid    objid;
  DIspacenum osnum;
  *msg = MSFAIL;
  objid = NULL_OBJID;

    /*| remove the names from the global table */
  for(i=0;i<100;i++)    /* to not loop forever .... */
   {
        /* check for duplicate naming CR179901429*/
    di$pwd(dirname = current_dir);
    sprintf(full_name,"%s:%s",current_dir,name);
    if(di$translate ( objname = full_name, p_objid = &objid, p_osnum = &osnum )
== DIR_S_SUCCESS)
        {
          ret_type = getNewName(name,current_dir,name);
          if(!ret_type) break; // failed, exit and retain old_name
          sprintf(mesg,"Duplicate %s -> New name %s",full_name,name);
          UI_status(mesg);
          sleep(2);

        }
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

IGRint getNewName(char *name,char *current_dir,char *updated_name)
{
  IGRint i,msg,retFlag = FALSE;
  char    *c,*c1,*strrchr();
  struct  GRid Object_GRid;

  { /* if the name is name_##, find pointer to the suffix */
    c = strrchr(name,'_');

    if(c != NULL) {
      i = strtol(c+1,&c1,10);
      if(*c1 != '\0') c = NULL;
  }

    if(c == NULL) c = name + strlen(name);

    /* find correct suffix */

    for(i=0;i<1000;i++) {

      if(i<100) sprintf(c,"_%02d",i);
      else      sprintf(c,"_%03d",i);
      /*" hdr_name %s\n",me->hdr_name*/
      msg = di$translate(
        objname = name,
        p_objid = &Object_GRid.objid,
        p_osnum = &Object_GRid.osnum
      );
      if( msg != DIR_S_SUCCESS) break;
    }
    strcpy(updated_name,name);
  }
  // Done
  retFlag = TRUE;
wrapup:
  return retFlag;
}
end implementation ACncpx;
