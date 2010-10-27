/* $Id: VDCmdTablei.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdtable/cmd / VDCmdTablei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdTablei.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *	Initial import to CVS
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
# Revision 1.3  1995/10/31  14:29:52  pinnacle
# Replaced: vdtable/cmd/VDCmdTablei.I for:  by sundar for vds.240
#
# Revision 1.2  1995/09/26  22:04:16  pinnacle
# Replaced: vdtable/cmd/VDCmdTablei.I for:  by sundar for vds.240
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

class implementation VDCmdTable;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include <stdio.h>
#include "ACattrib.h"
#include <sys/types.h>
#include <sys/dirent.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "VDmsg.h"

#if defined(X11)
#include "dirent.h"
#endif



extern GRclassid OPP_ACrg_collect_class_id;
from ACrg_collect import ACcreate,ACadd_attribute_by_type,NDdelete;

/******************************************************************************/
method init(int type; char *string_ptr)
{
int status;

  status =
  om$send(msg = message COm_place.init(type,string_ptr),
	  targetid = my_id,
	  mode = OM_e_wrt_message);

  if(me->form_ptr){
    FIg_delete(me->form_ptr,LOAD_TEMPLATE);
    FIg_delete(me->form_ptr,DEF_SELECTION);
    FIg_delete(me->form_ptr,DEF_OPTIONS);
    FIg_delete(me->form_ptr,TEMP_NAME);
    FIg_delete(me->form_ptr,MAC_NAME);
#if 0 
    /* Remove in 2.0 */
    FIg_delete(me->form_ptr,TEMP_TEXT);
#endif
  }
  return status;
}

/******************************************************************************/
method wakeup(int pos)
{
int status;

 status = om$send(msg = message COm_place.wakeup(pos),
		  targetid = my_id,
		  mode = OM_e_wrt_message);

 if(me->form_ptr){

   FIg_erase(me->form_ptr,CMD_NAME);
   FIg_set_text(me->form_ptr,CMD_NAME,"Place Table Of Parameters"); 
   FIg_display(me->form_ptr,CMD_NAME);
 }

 ex$message( msgnumb = VD_M_CrEdTbPr, field = MESSAGE_FIELD );
 return status;
}

/******************************************************************************/
method prompt_macro()
{
int status;

 strcpy(me->macro_name,"table");

 status =
 om$send(msg = message COm_place.set_action_and_state (STO_MAC,WAIT_TEM),
         targetid = my_id);

 return status;
}


/******************************************************************************/
method get_default_template()
{
  VDcreate_eligible_table(	&me->ModuleInfo,
				me->Temp_Elig+1 );
  if( me->Temp_Elig[1].objid == NULL_OBJID ){
    ex$message( msgnumb = VD_S_NoTblFnd, field = ERROR_FIELD );
  }

  return om$send(msg = message COm_place.get_default_template(),
		 targetid = my_id,
		 mode = OM_e_wrt_message);
}

/******************************************************************************/
method delete(int f_defer_flag)
{
 VDdel_eligible_table(	&me->ModuleInfo );

 return  om$send(msg = message COm_place.delete( f_defer_flag ),
		 targetid = my_id,
		 mode = OM_e_wrt_message);
}

/******************************************************************************/
/******************************************************************************/
/*
    Find all the possible tables and create an rg_collection for eligible
   template 
*/
#define TABLE_NAME ":IGENOD:VDpossible_table"

VDcreate_eligible_table(md_env,table)
		struct GRid	*table;
		struct GRmd_env *md_env;
{
int i, status;
DIR *dir,*opendir();
struct dirent *file,*readdir();
char full_name[DI_PATH_MAX],dir_name[DI_PATH_MAX];
 
  table->osnum = md_env->md_id.osnum;

  /* does not work without :filename: at the beginning ....*/
  status = di$give_pathname(osnum = table->osnum,
			    pathname = dir_name);
  strcat(dir_name,TABLE_NAME);
  status = di$translate ( osnum =  md_env->md_id.osnum,
                          objname = dir_name,
                          p_objid = &table->objid);
  if(status&1) return OM_S_SUCCESS;

  /* Search .t files in current directory */
  dir = opendir(".");

  if(dir != NULL){

    while(1){

      file = readdir(dir);
      if(!file) break;
      VDadd_eligible_table(file,table);
    }
    closedir(dir);
  }

  /* Search now in the config/table directories */

  for(i=0;i<30;i++){

    status = ex$get_path(index = i,
			 path = full_name,
			 len = 180,
			 type = EX_CONFIG_PATH);
    if(!(status&1)) break;
    strcat(full_name,"/config/table/");
    dir = opendir(full_name);

    if(dir != NULL){
      while(1){
        file = readdir(dir);
        if(!file) break;
        VDadd_eligible_table(file,table);
      }
      closedir(dir);
    }
  }
  return OM_S_SUCCESS;
}


/******************************************************************************/
VDadd_eligible_table(file,table)
	struct dirent *file;
	struct GRid *table;
{
long	msg;
int	status;
char	table_name[80];
int	name_len;
char	dir_name[DI_PATH_MAX];

  name_len = strlen(file->d_name);

  if(file->d_name[name_len-1] == 't' &&
     file->d_name[name_len-2] == '.'){

    OM_BLOCK_MOVE(file->d_name,table_name,name_len-2);
    table_name[name_len-2] = '\0';
    if( table->objid == NULL_OBJID ){
	 status = di$give_pathname(osnum = table->osnum,
				   pathname = dir_name);
	 strcat(dir_name,TABLE_NAME);
	 status = om$construct(classid = OPP_ACrg_collect_class_id,
			  p_objid = &table->objid,
			  osnum = table->osnum,
			  msg = message ACrg_collect.ACcreate(&msg,dir_name));
	 as$status(action = RET_STATUS);
    }
				
    status =
    om$send(msg = message ACrg_collect.ACadd_attribute_by_type
				(&msg,AC_ATTRIB_TEXT,table_name,table_name),
            senderid = NULL_OBJID,
            targetid = table->objid,
            targetos = table->osnum );
  } 
  return OM_S_SUCCESS;
}


/******************************************************************************/
VDdel_eligible_table(md_env)
struct GRmd_env *md_env;
{
int status;
OM_S_OBJID table;
char dir_name[DI_PATH_MAX];

  /* does not work without :filename: at the beginning ....*/
  status = di$give_pathname(osnum = md_env->md_id.osnum,
			    pathname = dir_name);
  strcat(dir_name,TABLE_NAME);
  status = di$translate ( objname = dir_name, p_objid = &table);
 
  if(status&1) om$send(msg = message ACrg_collect.NDdelete(md_env),
		       senderid = NULL_OBJID,
		       targetid = table,
		       targetos = md_env->md_id.osnum);
  return OM_S_SUCCESS;
}

/******************************************************************************/
/******************************************************************************/

end implementation VDCmdTable;

