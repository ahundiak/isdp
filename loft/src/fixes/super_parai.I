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
#include "msmacros.h"
#include "ASmessages.h"
#include "acdef.h"
#include "acmacros.h"
#include "grmessage.h"

#include "OMversion.h"

#define AS_DEBUG

/*global for fast directory look up */

/*
%safe
struct GRid DMdim_dir_grid ;
struct GRid DMconstructs_dir_grid;
%endsafe
*/

/* to avoid multiple untranslate of super_para and font mgr */
/*
%safe 
struct GRid ASfont_mgr   = {0,(OM_S_OBJID)-1}; 
struct GRid ASsuper_grid = {0,(OM_S_OBJID)-1}; 
%endsafe
*/

extern	struct GRid DMdim_dir_grid ;
extern	struct GRid DMconstructs_dir_grid;
extern	struct GRid ASfont_mgr;
extern	struct GRid ASsuper_grid;


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



method global_class.sleep(IGRint pos)
{
 int status,msg;
//  OM_S_CLASSLIST clist;
 char tmp_path[100];
 char *stamp;
 int tmp_size,tmp_len,stamp_len;
 struct GRmd_env mod_env;
 OM_S_OBJID md_id,undo_id;
 int nb_symb;
 int write_mode;
 GRspacenum master_os;

 extern  OMuint  OM_Gi_number_of_appl_ids;
 extern  struct INGR_sd_product_def *OM_GA_appl_version [];
 int iapp;

/* a little super_dim */

 DMdim_dir_grid.objid =NULL_OBJID;
 DMconstructs_dir_grid.objid =NULL_OBJID;
 ASsuper_grid.objid = NULL_OBJID;
 ASsuper_grid.osnum = 0;
 ASfont_mgr.objid = NULL_OBJID;
 ASfont_mgr.osnum = 0;

/* Retrieve current module OS and ask if the sleeped OS goes to file */

 status = ex$get_cur_mod(osnum = &master_os);

 ex$get_modid( mod_osnum = OM_Gw_current_OS,
	       mod_id    = &md_id);
    
 status = ex$file_status( modid = md_id,
    			  modos = OM_Gw_current_OS,
			  mode = &write_mode);



/*
   To weel beheave for temporary sleep of before 1.4 release,
   what follows is done even if the OS is not written 
*/

/*"write_mode %d pos %d\n",write_mode,pos*/
   
if ((write_mode == 0 || pos != 0) && OM_Gw_current_OS == master_os)
 {
      /* Store also the GRNUC stamp number.				     */
      /* This stamp is also stored in the file of the object space but there */
      /* is no way to access it .... 					     */

  stamp = NULL;
  stamp_len = 0;
  for(iapp=0;iapp< OM_Gi_number_of_appl_ids ; iapp++)
    {
      if(strncmp(OM_GA_appl_version[iapp]->curr_version,"I/GR",4) == 0)
       {
	stamp = OM_GA_appl_version[iapp]->curr_version + 8;
	stamp_len = strlen(stamp);
 
        /*"version of GRNUC is %s\n",stamp */
	break;
       }
    }

   tmp_size = 100;
   ac$construct_path(mode = AC_INQ,
     		    path = tmp_path,
     		    path_size = tmp_size,
     		    path_len = &tmp_len);

    status = om$vla_set_dimension(varray = me->ACpath,
     		      		size = tmp_len+stamp_len+2);
    as$status(action = GOTO_VALUE, value  = wrapup);
     
    if(tmp_len >= tmp_size)
      {
       ac$construct_path(mode = AC_INQ,
     		        path = me->ACpath,
     		        path_size = tmp_len+1,
     		        path_len = &tmp_len);
      }
    else
      {
       OM_BLOCK_MOVE(tmp_path,me->ACpath,tmp_len+1);
      }

    /* Now stamp version */
    if(stamp_len>0) 
	  {
           OM_BLOCK_MOVE(stamp,me->ACpath+tmp_len+1,stamp_len);
	   me->ACpath[tmp_len+stamp_len+1] ='\0';
	  }
    else   printf("NO TIME STAMP !!!\n");

     ac$construct_wd(mode = AC_INQ,
     		    name = me->ACwd,
     		    name_size = ACWD_PATH_MAX);
       /*"store ACpath %s\nACwd %s\n",me->ACpath,me->ACwd */
   }
   

/*
   Sleep is only necessary if the sleeped module goes to file 
*/

if(write_mode == 0) 
  {
   /* construct module env (for NDsleep message) */

    mod_env.md_id.objid = md_id;
    mod_env.md_id.osnum = OM_Gw_current_OS;
    mod_env.md_env.matrix_type = MAIDMX;
    MAidmx(&msg,mod_env.md_env.matrix);

  /* Sleep first the undo object */

    undo_id = NULL_OBJID;
    status = ex$get_super(mod_id = md_id,
	       mod_osnum = OM_Gw_current_OS,
	       super_name = "UNDO_OBJECT",
	       create = FALSE,
	       super_id = &undo_id);
    if(status&1 && !IF_NULL_OBJID(undo_id))
     {
      /*| send sleep message to UNDO_OBJECT */

      status = om$send(msg = message global_class.sleep(pos),
		       targetid = undo_id);
      as$status();
     }
    else
     {
      /*| UNDO_OBJECT does not exist */
     }


   /* exec batch if necessary */
   
    nd$exec_batch();

   /*| initialize list for temporary macro definition */
   /*  These temporary definition are used by macr occurence instead of */
   /*  the real definition in another OS when they are on file          */
   
       ACinit_symbol();
       ACload_symbol(OM_GO_current_OS_objid,OM_Gw_current_OS);
      
   /*| sleep of associative elements */ 

	// FIX BUG LLC 4 Nov : replace pass method by a loop on object space.
	//			because pass can break before end of Obj Space
/*    
       clist.w_count=1;
       clist.w_flags=OM_CLST_subclass;
       clist.p_classes=&OPP_NDnode_class_id;

       status = om$send(msg = message OMObjSpace.pass
      				       (&clist,OM_e_wrt_object,
      				 	message NDnode.NDsleep(&mod_env)),
              	  targetid = OM_GO_current_OS_objid);
       as$status();

*/
// Start FIX
	{
	struct	GRid	OBJ;
	GRclassid	cid;

	OBJ.osnum	= OM_Gw_current_OS;
	for( OBJ.objid = 0; OBJ.objid<OM_GA_OSDs[OBJ.osnum]->CurSpaceMapSize; 
								OBJ.objid ++){

		om$get_classid(		osnum	  = OBJ.osnum, 
					objid	  = OBJ.objid, 
					p_classid = &cid );

		if( om$is_ancestry_valid(
				subclassid	= cid,
				superclassid	= OPP_NDnode_class_id ))

      			om$send( msg	  = message NDnode.NDsleep(&mod_env),
				 targetid = OBJ.objid );
	}
	}// end block
// End Fix

    /* exec_batch again to delete element put in the delete list by NDsleep */

       nd$exec_batch();
      
   /*
         delete not used symbol definition and free correspondance
         table between real definition and symbolic definition
   */
   
       ACclear_symbol(&nb_symb);
       if(nb_symb == 0) me->ACwd[ACWD_PATH_MAX-1] = '$';
       else me->ACwd[ACWD_PATH_MAX-1] = '\0';
      
       ACfree_symbol();

  /*
     Associative graph options are only stored if the saved module is the 
     current module.
     Should be the same for ACpath ..
  */
   
     if(master_os == OM_Gw_current_OS)
   {
     ASsave_option(&mod_env);
   }
   
 }

/*
   If the sleep is for the current module 
    - Unmount the directory for macro_lib.
    - If the sleep is for a real exit (pos=0), close the corresponding files
      and reset the ACpath
 */

 if(master_os == OM_Gw_current_OS)
   {
     ASunmount_macro_lib(OM_Gw_current_OS,pos);
   }

wrapup :
 return(OM_S_SUCCESS);
}
end implementation super_para;
