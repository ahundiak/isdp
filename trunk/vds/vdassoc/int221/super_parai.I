/* $Id: super_parai.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / super_parai.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: super_parai.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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

class implementation super_para;

#include <version.h>
#include "OMminimum.h"
#include "OMobjectcomm.h"
#include "OMmetaclass.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "igetypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "madef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "acdef.h"
#include "acmacros.h"
#include "grmessage.h"

#include "OMversion.h"

#define AS_DEBUG

/*global for fast directory look up */

%safe
extern struct GRid DMdim_dir_grid ;
extern struct GRid DMconstructs_dir_grid;
%endsafe


/* to avoid multiple untranslate of super_para and font mgr */

%safe 
extern struct GRid ASfont_mgr;
extern struct GRid ASsuper_grid;
%endsafe

from NDnode     import NDsleep;
from OMObjSpace import pass;
from ACcpx import ACload_macro;
from GRundo import GRudundo;

extern GRclassid OPP_NDnode_class_id,
                 CI_ci_classid,                 /* new guy */
                 CI_COci_classid;               /* new guy */
;

extern struct GMgraph ND_graph;

extern IGRboolean ASbroadcast_in_progress;

method wake_up()

{
 IGRlong msg;
 int status;
 IGRlong NumberOfBytes;
 int mode, nret;
 IGRboolean cp_mode; 
 struct GRid cur_mod;

 ASfont_mgr.objid = NULL_OBJID;
 ASfont_mgr.osnum = 0;

/* initialize global for super */

 ASsuper_grid.objid = my_id;
 ASsuper_grid.osnum = OM_Gw_current_OS;

/*************** FIXES A Smithermann 19/Oct/90 to initialize ACpath ********/

  SCIinit();                            /* new block of code */
  om$get_classid(       classname = "ci",
                        p_classid = &CI_ci_classid ) ;
  om$get_classid(       classname = "COci",
                        p_classid = &CI_COci_classid ) ;


/* initialize  different module of associative geometry */

  COpara_init();
  NDinit_graph(&ND_graph,100,100,50);
  ASassoc_init();
  ACinit(my_id);

/*"ASbroadcast %d\n",ASbroadcast_in_progress */

/* initialize path and working directory if this wake_up is
   the wake_up of the current module */

    status = ex$get_cur_mod(id = &cur_mod.objid,osnum = &cur_mod.osnum);

    if(OM_Gw_current_OS == cur_mod.osnum)
    {
     /*| module is visible */

     DMdim_dir_grid.objid = NULL_OBJID;
     di$translate ( objname = "dim",
		    osnum   = OM_Gw_current_OS,
		    p_objid = &DMdim_dir_grid.objid,
		    p_osnum = &DMdim_dir_grid.osnum);

     DMconstructs_dir_grid.objid = NULL_OBJID;
     di$translate ( objname = "constructs",
		    osnum   = OM_Gw_current_OS,
		    p_objid = &DMconstructs_dir_grid.objid,
		    p_osnum = &DMconstructs_dir_grid.osnum);


     /* 
	Remount directory for macro libraries which have been unmounted at
	save time.
	NB : mounting only macro lib from the path could not be enought 
	since some of them could not be listed in the path.
     */

    if(ex$is_temp_wakeup())
    {

struct ACopen_struct
   {
    int osnum;
    int name;
   };
extern int ACopen_number;
extern struct ACopen_struct * ACopen_info;
extern char *ACopen_name_array;
char full_dir_name[DI_PATH_MAX];
int ilib,fdn_len;

     msg = di$give_pathname(osnum = OM_Gw_current_OS,
                           pathname = full_dir_name);
     strcat(full_dir_name,":constructs_lib:");
     fdn_len = strlen(full_dir_name);

     for(ilib=0;ilib<ACopen_number;ilib++)
      {
       if(ACopen_info[ilib].osnum == OM_Gw_current_OS) continue;
       strcpy(full_dir_name+fdn_len,ACopen_name_array + ACopen_info[ilib].name);
       di$mount(logical = full_dir_name,
	        osnum = ACopen_info[ilib].osnum);
      }
    }
    else
    {
     char *stamp;
     stamp = NULL;

     /*
	Mount library corresponding to the working macro lib and the lib in the
	path
     */

     if(me->ACpath == NULL || me->ACpath[0] == '\0') 
       {
        ac$construct_path(mode = AC_SET,
		          name = "\0");
       }
     else
       {
	int path_len,path_mode;
	char *error,*c,*c1,*strchr();

	/* Search for missing libraries : */

	path_len = strlen(me->ACpath);
	path_mode = AC_SET;
	error = om$malloc(size = path_len+1);
	if(error)
	  {
	     c = me->ACpath;
	     error[0] = '\0'; 
	     while(1)
	      { c1 = strchr(c,',');
		if(c1 != NULL) *c1 = '\0';
        	status = ac$construct_path(mode = path_mode,
		          	           name = c);
		path_mode = AC_ADD_PATH;
		if(!(status&1)) 
		  {
		   if(error[0] != '\0')strcat(error," ");
		   strcat(error,c);
	          }
		if(!c1) break;
		c = c1+1;
		*c1 = ',';
	      }
	     if(error[0] != '\0')
	      {
	       char *ctmp,tmp [MS_MAX_MSG_LENGTH+1],*strrchr();
	       int len1,len2;

	       /* jla 16.06.92 : to make sure output message is not longer than
		  MS_MAX_MSG_LENGTH
               */
	       ex$message(msgnumb = AS_F_InvPath,buff = tmp);
	       len1 = strlen(tmp);
	       len2 = strlen(error);
	       if(len1 >= MS_MAX_MSG_LENGTH)
		{
	         ex$message(msgnumb = AS_F_InvPath);
		}
	       else
		{
		 if(len1+len2+1 >= MS_MAX_MSG_LENGTH)
		  {
		   error[MS_MAX_MSG_LENGTH-len1-4] = '\0';
		   ctmp = strrchr(error,' ');
		   if(!ctmp) ctmp = error;
		   strcpy(ctmp,"...");
		  }
	         ex$message(msgnumb = AS_F_InvPath,type = "%s",
		            var = `error`);
		}
	       om$dealloc(ptr = error);
	      }
	    }

        /* Get GRNUC stamp if any */
	path_len = strlen(me->ACpath);
	if(path_len+1 < om$dimension_of(varray = me->ACpath))
	  {
	   stamp = me->ACpath+path_len+1;
	   /*"stamp >%s<\n",stamp */
	   while(*stamp == ' ') stamp++;
          }
       }

     if(me->ACwd == NULL || me->ACwd[0] == '\0') 
       {
        ac$construct_wd(mode = AC_SET,
		        name = "\0");
       }
     else
       {
        status = ac$construct_wd(mode = AC_SET,
		        	 name = me->ACwd);
	if(!(status&1))
	  {
	   ex$message(msgnumb = AS_F_InvWd,type = "%s",
		      var = `me->ACwd`);

           ac$construct_wd(mode = AC_SET,
		           name = "\0");
	  }
       }
     /* Update form with ACpath if on the screen */

     {
      extern char *COm_lib_form_ptr, *COm_lib_review_ptr;
#     define RESET 3
#     define ABORT_REVIEW 104

      if(COm_lib_form_ptr)
	{
	 COm_lib_router(0,RESET,0.,COm_lib_form_ptr);
	 if(COm_lib_review_ptr)
	    COm_lib_router(0,ABORT_REVIEW,0.,COm_lib_form_ptr);
	}
      }
     }

     /* Retrieve assoc option */

    ASretrieve_option(OM_Gw_current_OS);
    AScreate_option(OM_Gw_current_OS);

   } /* end wake up of active module */

/*
   Modif jla 29-June-89 to avoid loop when super-object created in cell lib
   (super object created by ACcpx.NDcopy during copy_batch and put_mod_batch
    call again exec_batch) 
*/

if(OM_Gw_current_OS == cur_mod.osnum)
 {
 /*| module is visible */
 /*| Get the dynamic copy flag and put the batch mode */
 NumberOfBytes = sizeof(IGRboolean);
 gr$get_dynamics_copy_flag(msg = &msg,
			   sizbuf = &NumberOfBytes,
			   buffer = &cp_mode,
			   nret = &nret);

 NDget_mod_batch(&mode);
 /*"Get cp_mode %d, and batch mode %d\n",cp_mode, mode */
 if(cp_mode == TRUE)	       mode = ND_IMMEDIATE;
 else if(mode == ND_IMMEDIATE) mode = ND_TRANSACTION;
 NDput_mod_batch(mode);
 /*"put batch mode %d\n",mode */

 }

 return(OM_S_SUCCESS);
}
end implementation super_para;
