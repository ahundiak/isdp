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

#include "batch.h"

#include "ACrg_collect.h"
#include "ACattrib.h"

#define AS_DEBUG

/*global for fast directory look up */

extern struct GRid DMdim_dir_grid ;
extern struct GRid DMconstructs_dir_grid;


/* to avoid multiple untranslate of super_para and font mgr  */

extern struct GRid ASfont_mgr; 
extern struct GRid ASsuper_grid;

from NDnode     import NDsleep;
from OMObjSpace import pass;
from ACcpx import ACload_macro;
from GRundo import GRudundo;

from ACdiowner import ACcreate;
from ACrg_collect import ACset_list_attribute, AClist_attribute;
from ACrg_collect import NDdelete;

extern GRclassid OPP_NDnode_class_id,
                 CI_ci_classid,                 /* new guy */
                 CI_COci_classid;               /* new guy */


extern struct GMgraph ND_graph;

extern IGRboolean ASbroadcast_in_progress;


/********************************************************************
  Construct if necessary a super_para object in the current directory
*********************************************************************/
#if 0
ASsuper_construct()
/*.ASsuper_construct*/
{
OM_S_OBJID super_id;
struct GRid mod;

/*"ASbroadcast %d\n",ASbroadcast_in_progress */


ex$get_cur_mod(id = &mod.objid, osnum =  &mod.osnum);

if(mod.osnum != ASsuper_grid.osnum)
 {
  /*| call get super */
  ex$get_super(mod_id = mod.objid,
	       mod_osnum = mod.osnum,
	       super_name = "super_para",
	       create = TRUE,
	       super_class = "super_para",
	       super_id = &super_id);

   ASsuper_grid.objid = super_id;
   ASsuper_grid.osnum = mod.osnum;
 }
else
 { 
  /*| Does not call get super */
 }
 return 1;
}

/********************************************************************
  Unmount the object space directories of the macro library before
  save of the current object space.
  These directories will be remount at wakeup when the correspondance
  table between tmp_defn in the current file and the real definition
  in the reference file is establish. (function ACload_symbol)
*********************************************************************/

ASunmount_macro_lib(osnum,pos)
GRspacenum osnum;
IGRint pos;
/*.ASunmount_macro_lib*/
{
int i;
char dir_name[DI_PATH_MAX];
IGRlong status;
OM_S_OBJID tmp;

int  nb_lines = 0;
char **lines = NULL;
GRspacenum lib_osnum;
int invisible_index;

  status = di$give_pathname ( osnum =  osnum,
			      pathname =  dir_name);

  strcat(dir_name,":constructs_lib");

  status = di$translate ( osnum =  osnum,
                          objname = dir_name,
			  p_objid = &tmp);

  if(status != DIR_S_SUCCESS) return(OM_S_SUCCESS);
  strcat(dir_name,":*");

  /*"ls in %s\n",dir_name */

  status = di$ls( regexp = dir_name ,
                  lines = &lines ,
                  ptr = &nb_lines);
  if(!(status&1))di$report_error(sts = status);
  if(!(status&1)) return(OM_S_SUCCESS);

  if(nb_lines == 0) return(OM_S_SUCCESS); 

  for(i=0;i<nb_lines;i=i+1)
        {
         /*"remove %s\n",lines[i]*/

	 if(pos == 0)
	   { /*" close the file os %d\n",lib_osnum */
	     
	     status = di$give_osnum(pathname = lines[i],
				    p_osnum = &lib_osnum);
             if(!(status&1))di$report_error(sts = status);
	    
	     if(ex$is_invis(mod_osnum = lib_osnum,
			    index = &invisible_index))
		{	
		 /*" invisible %d\n",invisible_index */
	     	 status = ex$close_module(ftype = EX_invisible,
				      	  index = invisible_index,
				      	  flag  = 0);
		 /*| after close_module */
		}
	   }
         else
           { /*| Just unmount the directory */
            status = di$umount(dirname = lines[i]);
            if(!(status&1))di$report_error(sts = status);
	   }
        }

  /*| Reset ACpath and ACwd when the save is with an exit file */
  if(pos == 0 ) ACopen_init();

  if(lines != NULL && nb_lines != 0)
   {
    di$free(lines = lines,
            count = nb_lines);
    if(!(status&1))di$report_error(sts = status);
   }
  return(OM_S_SUCCESS);
}

method super_construct()
{
 IGRlong status;
/* Initialize default working directory and path for macro lib               */

me->ACwd[0]='\0';

status = om$vla_set_dimension(varray = me->ACpath,
  		      		size = 2);
me->ACpath[0]='\0';
return(OM_S_SUCCESS);
}


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
                    /* Rule 2: Length of error cannot exceed 256,
                       This appears to be unpublished restriction
                       TR#119313895 ,Changed the code for error not
                       to exceed 255  -gvk 8/23/94*/

                    if( (MS_MAX_MSG_LENGTH-len1-4)  < 255)
                      error[MS_MAX_MSG_LENGTH-len1-4] = '\0';
                    else
                      error[255] = '\0';

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

 struct GRid rgcol,*defobj;
 struct ACrg_coll *objlist; 
 IGRint listlen,nb_attr,i;
 IGRlong msg1;
 DIchar path[DI_PATH_MAX];

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

/** TR119526798 **/
/** Check if ACrg_collect object exists  **/

 di$give_pathname(osnum = OM_Gw_current_OS,
                  pathname = path);
 strcat(path,":usr:Colldefobj");

 status = di$translate(objname = path,
                       p_objid = &rgcol.objid,
                       p_osnum = &rgcol.osnum);

 if (status == DIR_W_NAME_NOT_FOUND || rgcol.objid == NULL_OBJID) 
 {
   /** no collect object found - do nothing **/
 }
 else
 {
   /** get the number of objects deferred **/
	
   listlen = 1;   
   status = om$send( msg = message ACrg_collect.AClist_attribute(&msg1,listlen,
							NULL, &nb_attr),
		     targetid = rgcol.objid,
		     targetos = rgcol.osnum);

   objlist = (struct ACrg_coll *) malloc(nb_attr * sizeof(struct ACrg_coll));
   if (objlist == NULL)
   {
	fprintf(stderr,"Malloc error.\n");
   }
    
   listlen = nb_attr; 

   if (listlen && objlist != NULL)
   {
       /** get the objids of the deferred objects **/

       status = om$send( msg = message ACrg_collect.AClist_attribute(&msg1,listlen,
                                                        objlist, &nb_attr),
                         targetid = rgcol.objid,
                         targetos = rgcol.osnum);

       defobj = (struct GRid *) malloc(listlen*sizeof(struct GRid));
       if (defobj == NULL)
       {
	  fprintf(stderr,"malloc error.\n");
       }
       else
       {
       	  for (i=0;i<listlen;i++)
          {
	      sscanf(objlist[i].desc.value.att_txt,"%d %hu",&defobj[i].objid,&defobj[i].osnum);
          }
 
	  /* post the deferred objids in wait batch **/

          nd$wait_batch(type = GR_GEOM_POSTED,
		        l_object = defobj,
		        l_obj_info = NULL,
		        nb_obj = nb_attr);
       }

       if (defobj) free(defobj);
       if (objlist) free(objlist);

       /** reset the ACrg_collect object list to NULL **/

       status = om$send (msg = message ACrg_collect.ACset_list_attribute(&msg1,0, NULL),
                             targetid = rgcol.objid,
                             targetos = rgcol.osnum);
    }
  }
 }

 return(OM_S_SUCCESS);
}
#endif

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

 extern struct ext_list NDmodif;
 IGRint ret_mode;
 struct GRid rgcol;

 extern  OMuint  OM_Gi_number_of_appl_ids;
 extern  struct INGR_sd_product_def *OM_GA_appl_version [];
 int iapp;

 int traceFlag = 1;
 
 if (traceFlag) {
   printf(">>> super_pari.sleep\n");
 }
 
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
   
#ifdef SLEEP_NEEDED_FIRST
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

    if (traceFlag) {
      printf("ACpath '%s'\n",me->ACpath);
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
#endif
   

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

       if (traceFlag) printf("Sleeping the undo object\n");
       
      status = om$send(msg = message global_class.sleep(pos),
		       targetid = undo_id);

      if (traceFlag) printf("Slept the undo object\n");

      as$status();
     }
    else
     {
      /*| UNDO_OBJECT does not exist */
     }


   /* exec batch if necessary */
   
    nd$exec_batch();

    if (traceFlag) printf("Just di the exec_batch thingee\n");
    
   /*| initialize list for temporary macro definition */
   /*  These temporary definition are used by macr occurence instead of */
   /*  the real definition in another OS when they are on file          */
   
       ACinit_symbol();
       ACload_symbol(OM_GO_current_OS_objid,OM_Gw_current_OS);
      
   /*| sleep of associative elements */ 
      
       clist.w_count=1;
       clist.w_flags=OM_CLST_subclass;
       clist.p_classes=&OPP_NDnode_class_id;

       if (traceFlag) {
	 printf("About to pass NDsleep to all NDnode objects\n");
       }
       
       status = om$send(msg = message OMObjSpace.pass
      				       (&clist,OM_e_wrt_object,
      				 	message NDnode.NDsleep(&mod_env)),
              	  targetid = OM_GO_current_OS_objid);

       if (traceFlag) {
	 printf("Back from passing NDsleep to all NDnode objects\n");
	 fflush(stdout);
	 
       }
       as$status();

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
/* Inquire about the batch mode - if in delay, check NDmodif if any objects
   have been deferred for recompute. If  found, create a collect object
   and push the deferred objects as a list into the collect object to be
   retrieved later on wake up. - Satish */
 
      nd$mod_batch(request = ND_INQ,
                   req_mode = NULL,
                   p_ret_mode = &ret_mode);

 
      if (ret_mode == ND_DEFER) 
      {
	IGRlong msg1;
	IGRint i;
	DIchar path[DI_PATH_MAX];

	di$give_pathname(osnum = OM_Gw_current_OS,
			    pathname = path);
	strcat(path,":usr:Colldefobj");

	status = di$translate(objname = path,
	                      p_objid = &rgcol.objid,
		              p_osnum = &rgcol.osnum);

  	if (status == DIR_W_NAME_NOT_FOUND && NDmodif.nb_obj)
	{

           status = om$construct ( classname = "ACrg_collect",
	   	                   osnum = OM_Gw_current_OS,
		                   p_objid = &rgcol.objid);
           if (status != OM_S_SUCCESS)
		goto wrapup;

	   rgcol.osnum = OM_Gw_current_OS;

	   /** construct the object in the usr directory for consistent
	       retrieval **/

	   status = om$send(msg = message ACdiowner.ACcreate(&msg1,path),
                            targetid = rgcol.objid,
                            targetos = rgcol.osnum);

	   if (status != OM_S_SUCCESS)
	   {
		fprintf(stderr,"Could not create Collect object.\n");
		fprintf(stderr,"Recomputing to avoid data loss.\n");
		
		/** failed to create. Put batch mode to immediate and
		    recompute. Delete the collect object constructed. **/

	        nd$mod_batch(request = ND_INQ,
           	             req_mode = NULL,
                 	     p_ret_mode = &ret_mode);
 
    		if (ret_mode == ND_DEFER)
    		{
        	   nd$mod_batch(request = ND_SET,
                     	  	req_mode = ND_IMMEDIATE,
                     		p_ret_mode = NULL);
    		}
		nd$exec_batch();
	        status = om$send(msg = message NDnode.NDdelete(&mod_env),
			         targetid = rgcol.objid,
			         targetos = rgcol.osnum);
	   }
	}
	if (NDmodif.nb_obj)
	{
	   struct ACrg_coll *objcoll;
	   IGRchar attrname[10];

	   objcoll = (struct ACrg_coll *)malloc(NDmodif.nb_obj * sizeof(struct ACrg_coll));
	   if (objcoll == NULL)
	   {
	      fprintf(stderr,"Malloc error.\n");
	      status = om$send(msg = message NDnode.NDdelete(&mod_env),
	          	       targetid = rgcol.objid,
			       targetos = rgcol.osnum);
	      goto wrapup;
	   }

	   /** put the objids from NDmodif in the list format of ACrg_collect
	       object **/

	   for (i=0;i<NDmodif.nb_obj;i++)
	   {
	      sprintf(attrname,"obj%d",i+1);
	
	      strcpy(objcoll[i].name, attrname);
	      objcoll[i].desc.type = AC_ATTRIB_TEXT;
	      sprintf(objcoll[i].desc.value.att_txt,"%d %u", NDmodif.list_id[i].objid, NDmodif.list_id[i].osnum);
	   }

	   status = om$send (msg = message ACrg_collect.ACset_list_attribute(&msg1,NDmodif.nb_obj , objcoll),
	 	             targetid = rgcol.objid,
			     targetos = rgcol.osnum);	
	   if (status != OM_S_SUCCESS)
	   {
	      fprintf(stderr,"Set list  failed.\n");
	      status = om$send(msg = message NDnode.NDdelete(&mod_env),
		               targetid = rgcol.objid,
			       targetos = rgcol.osnum);
	      if (objcoll) free(objcoll);
	      goto wrapup;
	   }
	   if (objcoll) free(objcoll);
	 }
	 else
	 {
	    /**  If no deferred objects found and a previously constructed
	         collect object exists , then delete it. **/

	    if (rgcol.objid != NULL_OBJID)
	        status = om$send(msg = message NDnode.NDdelete(&mod_env),
			         targetid = rgcol.objid,
			         targetos = rgcol.osnum);
	 }

       }
/** TR119526798 **/

      ASsave_option(&mod_env);
   }
   
 }

   
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
   if (traceFlag) {
     printf("<<< superpari.sleep\n");
   }
 
 return(OM_S_SUCCESS);
}

#if 0
/*------------------------  Access methods --------------------------------*/

method give_path_size (IGRint *size)
{
  IGRlong status=OM_S_SUCCESS;

  if (size)
    *size = om$dimension_of (varray = ME.super_para->ACpath);
  else
    status = OM_E_ABORT;

  return (status);
}

method give_path (IGRchar *path)
{
  IGRlong status=OM_S_SUCCESS;

  if (path)
    strcpy (path, ME.super_para->ACpath);
  else
    status = OM_E_ABORT;

  return (status);
}

method give_wd (IGRchar *wd)
{
  IGRlong status=OM_S_SUCCESS;

  if (wd)
    strcpy (wd, ME.super_para->ACwd);
  else
    status = OM_E_ABORT;

  return (status);
}

#endif

end implementation super_para;
