/* $Id: super_parai.I,v 1.3 2002/06/07 15:10:17 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/super_parai.I
 *
 * Description:
 *		Change the way of saving the libraries after the sleeping
 *		process.
 *
 * Dependencies:
 *		GRNUCSRC/assoc/super_parai.I
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/13/95	adz		Checking with MasterOs is invalid.
 *      04/08/99        ylong           TR179900273
 *	12/07/00	RamaRao		Used GRisThereAnyUnknownObject().
 *					TR# 4222, ETL# 4930.
 ***************************************************************************/

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

/******* ORIGINAL VERSION * ***

%safe
struct GRid DMdim_dir_grid ;
struct GRid DMconstructs_dir_grid;
%endsafe

%safe 
struct GRid ASfont_mgr   = {0,(OM_S_OBJID)-1}; 
struct GRid ASsuper_grid = {0,(OM_S_OBJID)-1}; 
%endsafe

 ****** ENS ORIGINAL VERSION ****/


/*
 * dynamically loaded version.
 */
extern	struct	GRid	DMdim_dir_grid ;
extern	struct	GRid	DMconstructs_dir_grid ;
extern	struct	GRid	ASfont_mgr ;
extern	struct	GRid	ASsuper_grid ;


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

static int	GRisThereAnyUnknownObject( OMuword	OSnum )
{
  int             max_entry;            /* Last object space map entry   */
  OM_p_OSD        p_OSD;                /* Ptr to object space descriptor */
  OM_p_SPAMAPENT  spamapent_p;          /* Ptr to space map entry        */
  OM_S_OBJID      oid;

    p_OSD = OM_GA_OSDs[OSnum];
    max_entry = p_OSD->CurSpaceMapSize-1 ;

    for( oid=0, spamapent_p = p_OSD->Spacemap; 
           (int) oid <= max_entry;  oid++, spamapent_p++ )
    {                                       
        if ( (spamapent_p->flags  != 0) &&   
             (spamapent_p->p_acld != NULL) )
        { 
	   if( spamapent_p->flags & OM_SM_unknown_obj )  return TRUE;
	}
    }
    return FALSE;
}

method global_class.sleep(IGRint pos)
{
 int status,msg;
 OM_S_CLASSLIST clist;
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

 VDclearToDoList();

/*
   To weel beheave for temporary sleep of before 1.4 release,
   what follows is done even if the OS is not written 
*/

/*"write_mode %d pos %d\n",write_mode,pos*/

/*
 * The sleeping process of the macro libraries need to be done after the
 * NDnode objects when to bed.
 */

#ifdef	NEED_AFTER_SLEEP
   
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
   
#endif /* NEED_AFTER_SLEEP */

/*
   Sleep is only necessary if the sleeped module goes to file 
*/

if(write_mode == 0 )
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
      
       clist.w_count=1;
       clist.w_flags=OM_CLST_subclass;
       clist.p_classes=&OPP_NDnode_class_id;
       status = om$send(msg = message OMObjSpace.pass
      				       (&clist,OM_e_wrt_object,
      				 	message NDnode.NDsleep(&mod_env)),
              	  targetid = OM_GO_current_OS_objid);
       as$status();

    /* exec_batch again to delete element put in the delete list by NDsleep */

       nd$exec_batch();
      
   /*
         delete not used symbol definition and free correspondance
         table between real definition and symbolic definition
   */
  
       if( GRisThereAnyUnknownObject( OM_Gw_current_OS ) )
	   me->ACwd[ACWD_PATH_MAX-1] = '\0';
       else
       {
       	   ACclear_symbol(&nb_symb);
           if(nb_symb == 0) me->ACwd[ACWD_PATH_MAX-1] = '$';
           else me->ACwd[ACWD_PATH_MAX-1] = '\0';
       }
      
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

/* START VDS CORRECTION */

/*
 * The library information need to saved after the sleep of the 
 * NDnode object.
 */

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

/* END   VDS MODIFICATION */
   
/*
   Sleep is only necessary if the sleeped module goes to file 
*/

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

// TR179900273 by ylong. modified wake_up()
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
	       char *ctmp,tmp[MS_MAX_MSG_LENGTH+1],*strrchr();
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
		 if(len1+len2+1 >= MS_MAX_MSG_LENGTH-100)
		  {
                   // TR179900273 by ylong
                   int len3 ;
                   if (MS_MAX_MSG_LENGTH-len1-4>100)
                     len3 = 100 ;
                   else 
                     len3 = MS_MAX_MSG_LENGTH-len1-4;
                   error[len3] = '\0';

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
