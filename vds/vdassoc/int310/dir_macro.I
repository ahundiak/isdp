/* $Id: dir_macro.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int310 / dir_macro.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dir_macro.I,v $
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

/*
 * I/VDS
 *
 * Correction adapted to handle checkin/checkout for invisible modules, which
 * are working during their sleep process with the visible module.
 * 
 * adz:	05/28/94 : integrated as dloadable for in I/VDS.
 */
class implementation Root;
#	include "OMminimum.h"
#	include "OMmacros.h"
#	include "OMlimits.h"
#	include "OMprimindex.h"
#	include "OMprimitives.h"
#	include "OMerrordef.h"
#	include "igrtypedef.h"
#	include "igetypedef.h"
#	include "godef.h"
#	include "codef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "grerr.h"
#	include "gr.h"
#	include "igr.h"
#	include "igrdp.h"
#	include "grdpbdef.h"
#	include "grdpb.h"
#	include "go.h"
#	include "griodef.h"
#	include "grio.h"
#	include "dp.h"
#	include "lcdef.h"
#	include "lc.h"
#	include "griomacros.h"
#include "exmacros.h"

#include <string.h>

#include "parametric.h"
#include "expression.h"
#include "expmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "asbox.h"
#include "AS_status.h"
#include "acdef.h"
#include "acmacros.h"
#define AS_DEBUG

/**
#define	DEBUG	1  
 **/

#ifdef ORIGINAL

%safe
/******   INFORMATION ABOUT WOKING DIRECTORY FOR MACRO  *****/

  
char ACwd[DI_PATH_MAX];          /* name of the file    	      */

struct GRid AC_construct_id = {0,(OM_S_OBJID)-1};        /* grid of the working directory*/

/******   INFORMATION ABOUT PATH DIRECTORY FOR MACRO  *****/

struct GRid *ACpath_grid = NULL;   /* list of grid for path directory       */
int  *ACpath_in_open = NULL;	   /* corresponding index in open list      */
int  ACpath_gr_number = 0;	   /* number of directory in the path 	    */
int  ACpath_gr_total = 0;	   /* allocated size of ACpath_grid         */

/******   INFORMATION ABOUT OPEN LIB FOR MACRO  *****/

int ACopen_number = 0;             /* number of open OS for macro lib       */
int ACopen_size = 0;               /* size of ACopen_struct                 */

struct ACopen_struct
   {
    int osnum;             	   /* open osnum			    */
    int name;       		   /* index of name in name_array	    */
   };

struct ACopen_struct
	   *ACopen_info = NULL;    /* allocated place for info		    */

int ACopen_name_used = 0;          /* size used to store open file name     */
int ACopen_name_size = 0;          /* size allocated to store open file name*/

char *ACopen_name_array = NULL;     /* allocated space for name		    */



/*******   DEFAULT NAME AND SEPARATOR *********/

%endsafe
char *ACdefault_constructs = "constructs";
char *ACdefault_constructs_lib = "constructs_lib";

#endif

struct ACopen_struct
   {
    int osnum;                     /* open osnum                            */
    int name;                      /* index of name in name_array           */
   };

extern struct ACopen_struct
           *ACopen_info;    /* allocated place for info             */

extern char ACwd[DI_PATH_MAX];     /* name of the file                */
extern struct GRid AC_construct_id; /* grid of the working directory*/
extern struct GRid *ACpath_grid;   /* list of grid for path directory       */
extern int  *ACpath_in_open;       /* corresponding index in open list      */
extern int   ACpath_gr_number;     /* number of directory in the path       */
extern int   ACpath_gr_total;      /* allocated size of ACpath_grid         */
extern int   ACopen_number;        /* number of open OS for macro lib       */
extern int   ACopen_size;          /* size of ACopen_struct                 */
extern int   ACopen_name_used;     /* size used to store open file name     */
extern int   ACopen_name_size;     /* size allocated to store open file name*/
extern char *ACopen_name_array;    /* allocated space for name              */
extern char *ACdefault_constructs;
extern char *ACdefault_constructs_lib;



#define SEPAR_PATH ','
#define SEPAR_DIR  ':'

 
#ifdef	ORIGINAL

ACpath_to_file(path_name,file_name)
char *path_name,*file_name;
/*.ACpath_to_file*/
{
char *pwd, *getenv();

/*"entry path_name %s\n",path_name */

/* make the file name 
   - from ci_path if the file exit in ci_path
   - in the current directory if not 
*/

strcpy(file_name,path_name);

if(file_name[0] != '/')
  {
    give_path(file_name);
  }

/*| give_path fail or in working directory */

if(file_name[0] != '/')
  {
   pwd = getenv("PWD");
   strcpy(file_name,pwd);
   strcat(file_name,"/");
   strcat(file_name,path_name);
  }
  
/*" return file_name %s \n",file_name*/
return 1;
}

#endif

/***************************************************************
   Return path_name from osnum
   Does not allow for now several directory in the same osnum 
***************************************************************/
   
ACos_to_path(osnum,path_name)
GRspacenum osnum;
char *path_name;
/*.ACos_to_path */
{
int i;

path_name[0] = '\0';
for(i=0;i<ACopen_number;i++)
  {
   if(osnum == ACopen_info[i].osnum)
     {
      strcpy(path_name,&ACopen_name_array[ACopen_info[i].name]);
      /*"found %s \n",path_name*/
      break;
     }
  }

 if( path_name[0] == '\0' ){
   /*
    * get pathname.
    */
   di$give_pathname(osnum = osnum, pathname = path_name );
   strcpy( path_name, &path_name[1] );
#ifdef	DEBUG
   printf(" ADD invisible : %s \n", path_name );
#endif
 }
   
 return 1;
}

#ifdef	ORIGINAL

/***************************************************************
Return macro library name from osnum

***************************************************************/

AClib_name(osnum,name_size,name,name_len)
short osnum;
int name_size,*name_len;
char *name;
{
int i,len;
int status;

status = OM_W_ABORT;
for(i=0;i<ACopen_number;i++)
  {
   if(osnum == ACopen_info[i].osnum)
     {
      /*|found */
      status = OM_S_SUCCESS;

      len = strlen(&ACopen_name_array[ACopen_info[i].name])+1;

      if(name_len) *name_len = len;

      if(name)
       {
        if(name_size >= len)
	  OM_BLOCK_MOVE(&ACopen_name_array[ACopen_info[i].name],name,len);
        else 
	 {
	  OM_BLOCK_MOVE(&ACopen_name_array[ACopen_info[i].name],name,name_size);
	  name[name_size-1] = '\0';
	 }
       }
      break;
     }
  }

return status;
}


/***************************************************************
Return directory for macro from macro lib name
***************************************************************/

AClib_dir(name,dir)
char *name;
struct GRid *dir;
{
int i,status,sts;

status = OM_W_ABORT;
dir->objid = NULL_OBJID;

for(i=0;i<ACopen_number;i++)
  {
   if(strcmp(name,&ACopen_name_array[ACopen_info[i].name]) == 0)
    {
      /*|found */
      dir->osnum = ACopen_info[i].osnum;
      sts = di$translate(osnum = dir->osnum,
		   objname = ACdefault_constructs,
		   p_objid = &dir->objid);
      if(sts&1) status = OM_S_SUCCESS;
      else dir->objid = NULL_OBJID;
      break;
     }
  }
return status;
}

/***************************************************************
   Reset information about open macro lib
***************************************************************/

ACopen_init()
{
 ACopen_number = 0;
 ACopen_name_used = 0;
 ACwd[0] = '\0';
 ACpath_gr_number = 0;
 return 1;
}

/***************************************************************
   Store information about an open macro lib
***************************************************************/

ACopen_store(osnum,name,open_index)
GRspacenum osnum;
IGRchar *name;
int *open_index;

/*.ACopen_store*/
{
int name_len,i_open;

 name_len = strlen(name);
 for(i_open=0;i_open<ACopen_number;i_open++)
   {
    if(   ACopen_info[i_open].osnum == -1 
       || ACopen_info[i_open].osnum == osnum ) break;
   }
 /*"store in %d\n",i_open */
 *open_index = i_open;

 if(i_open >= ACopen_size)
   {
    ACopen_size = ACopen_size + 10;
    if(ACopen_info == NULL)
      {
	/*| alloc ACopen_info */
	ACopen_info = (struct ACopen_struct *)om$malloc(
			      size = ACopen_size*sizeof(struct ACopen_struct));
       }
    else
      {
	/*| REalloc ACopen_info */
	ACopen_info = (struct ACopen_struct *)om$realloc(
			       ptr = (IGRchar *)ACopen_info,
			       size = ACopen_size*sizeof(struct ACopen_struct));
      }
    
   }

 if(ACopen_name_used + name_len +1 >= ACopen_name_size)
   {
    ACopen_name_size = ACopen_name_used + name_len + 100;
    if(ACopen_name_array == NULL)
      {
	/*| alloc ACopen_name_array */
	ACopen_name_array = (char *) om$malloc( size = ACopen_name_size);
       }
    else
      {
	/*| REalloc ACopen_name_array */

	ACopen_name_array = (char *) om$realloc (ptr = ACopen_name_array,
				      		 size = ACopen_name_size);
      }
   }


 ACopen_info[i_open].osnum = osnum;

 if(   i_open == ACopen_number 
    || strcmp(name,&ACopen_name_array[ACopen_info[i_open].name]) != 0)
  {
   ACopen_info[i_open].name  = ACopen_name_used;
 
   OM_BLOCK_MOVE(name,&ACopen_name_array[ACopen_name_used],name_len+1);
   ACopen_name_used = ACopen_name_used + name_len +1;
  }

 if(i_open == ACopen_number) ACopen_number += 1;
 return 1;
}

#endif

/***************************************************************
     Modify or return the path defined to find macro definiton
***************************************************************/

ACconstruct_path(mode,name,path,path_size,path_len)
int mode;
char *name,*path;
int path_size;
int *path_len;
/*.ACconstruct_path*/
{
 struct GRid construct;
 char *separ;
 int status = OM_S_SUCCESS;
 int len,new_len;
 int index,i;
 int open_index;
 char *open_name;
 int  already;
 int open_mode;
 IGRlong global_return;
 /* checkin/checkout */
 OM_S_OBJID TmpId;
 GRspacenum TmpOs;
 
/* Initialize assoc */
 
 ASsuper_construct();

 status = ex$get_cur_mod( id = &TmpId, osnum = &TmpOs );

/* Initialise return code */
  global_return = OM_S_SUCCESS;

/* Add path to active path */
   if(mode&AC_ADD_PATH)
     {
      /*| AC_ADD_PATH control that the name is not already in the path */
      if(name[0] == '\0') already =1;
      else
        {
	 already = 0;
 	 for(index=0 ; index<ACpath_gr_number;index++)
	   {
	    open_index = ACpath_in_open[index];
	    open_name = &ACopen_name_array[ACopen_info[open_index].name];
	    if(strcmp(open_name,name) == 0) { already = 1; break; }
	   }
	}

      if(!already)
	{
         status = ACactivate(name,&construct,EX_read_only,
			     &open_index,&open_mode,TmpOs );
/*  
    If the macro library is not found then return the abort status to display
    the form but don't display any messages on UNIX window which is done by
    the following as$status statement. -- Mrudula 04/06/93
*/

/*	 as$status(action = RET_STATUS); */
         if (!(status & 1))
            return(status);

         /* Add the directory GRid in the list of directory */

 	 if(ACpath_gr_number >= ACpath_gr_total)
	   {
	    ACpath_gr_total += 10;
	    if(ACpath_grid == NULL)
	      {
	       /*| allocate ACpath_gr */
      	       ACpath_grid = (struct GRid *)om$malloc(
				    size = ACpath_gr_total*sizeof(struct GRid));
      	       ACpath_in_open = (IGRint *)om$malloc(
				    size = ACpath_gr_total*sizeof(IGRint));
		
	      }
	    else
	      {
	       /*| reallocate ACpath_gr */
	       ACpath_grid = (struct GRid *)om$realloc(ptr = (IGRchar *)ACpath_grid,
      	        		    size = ACpath_gr_total*sizeof(struct GRid));
      	       ACpath_in_open = (IGRint *)om$realloc(ptr = (IGRchar *)ACpath_in_open,
				    size = ACpath_gr_total*sizeof(IGRint));
	      }
	   }

	 ACpath_in_open[ACpath_gr_number] = open_index;
	 ACpath_grid[ACpath_gr_number++] = construct;
	}
      }

/* remove directory from path */

   else if(mode&AC_REM_PATH)
     {
 	 for(index=0 ; index<ACpath_gr_number;index++)
	   {
	    open_index = ACpath_in_open[index];
	    open_name = &ACopen_name_array[ACopen_info[open_index].name];
	    if(strcmp(open_name,name) == 0)
	      {
	       /*"found at index %d\n",index */
	       for(i=index ; i<ACpath_gr_number-1 ; i++)
	          {
	           ACpath_grid[i] = ACpath_grid[i+1];
	           ACpath_in_open[i] = ACpath_in_open[i+1];
	          }

	       ACpath_gr_number -= 1 ;
	       break;
	      }
           }
     }

   if(mode&AC_SET)
     {
      /*"ACset of %s\n",name*/
      ACpath_gr_number = 0;
      open_name = name;
      do
	{
	 separ = strchr(open_name,',');
	 if(open_name != separ)
	   {
	    if(separ != NULL) *separ = '\0';
      	    status = ac$construct_path(mode = AC_ADD_PATH,
                                       path = (char *)NULL,
                                       path_len = (int *)NULL,
			      	       name = open_name);
	    if(!(status&1))
	      { global_return = OM_W_ABORT;}
	   }
	  open_name = separ+1;
	  if(separ != NULL) *separ = ',';
	 } while( separ != NULL);
     }

/* Return path */

   if(mode&AC_INQ)
     {
      /* Init if no macro library */
      if(path && path_size>0) path[0] = '\0';

      new_len = 0;

         for(index=0 ; index<ACpath_gr_number;index++)
	   {
            open_index = ACpath_in_open[index];
	    open_name = &ACopen_name_array[ACopen_info[open_index].name];
	    len = strlen(open_name);
	       if(new_len != 0)
		{ 
      		 if(path != NULL && new_len +1 <= path_size) path[new_len] =',';
		 new_len++;
		}
      	       if(path != NULL && new_len+len+1 <= path_size) 
	       			  OM_BLOCK_MOVE(open_name,&path[new_len],len+1);
	       new_len =  new_len+len;
	   }
       if(path_len != NULL) *path_len = new_len;
     }

   return (global_return);
}


/***************************************************************
    Modify or return the working directory 
    (where are created new macro definition)
***************************************************************/
   
ACconstruct_wd(mode,name,const_grid,name_size,name_len)
int mode;
char *name;
struct GRid *const_grid;
int name_size;
int *name_len;
/*.ACconstruct_wd*/
{
 int status = OM_S_SUCCESS;
 int open_index;
 int open_mode;
 int len;
 OM_S_OBJID TmpId;
 GRspacenum TmpOs;
 
/* Initialize assoc */
 
 ASsuper_construct();

/*
   Checkin/Checkout form invisible modules need to have reference from 
   object space. Functions need to use current module environment.
*/
 status = ex$get_cur_mod( id = &TmpId, osnum = &TmpOs );

if(mode & AC_SET)
  {
   /*"set the working directory to %s\n",name */
   if(name[0] != '\0')
    {
     status = ACactivate(name,&AC_construct_id,EX_read_write,
		       &open_index,&open_mode, TmpOs );
     if(!(status&1) || open_mode != EX_read_write) return(OM_W_ABORT);
    }
   else AC_construct_id.objid = NULL_OBJID;
   strcpy(ACwd,name);
  }

/*
   return the working directory 
*/

if(mode & AC_INQ)
  {
   len = strlen(ACwd);
   if(name_size >= len+1) OM_BLOCK_MOVE(ACwd,name,len+1);

   if(name_len != NULL) *name_len = len;
  }


if(const_grid != NULL) *const_grid = AC_construct_id;

#ifdef	DEBUG
  printf("WD: %d,%d\n",AC_construct_id.objid,AC_construct_id.osnum);
#endif

return(status);
}

#ifdef	ORIGINAL

/***************************************************************
 Return the GRid of the directory
 Or construct it if it does not exist
***************************************************************/
 
ACtran_or_make(cur_os,dir_name,dir_grid)
GRspacenum cur_os;
char *dir_name;
struct GRid *dir_grid;
/*.ACtran_or_make */
{
  IGRint rc;

  rc = di$translate(osnum = cur_os,
                    objname = dir_name,
                    p_objid = &dir_grid->objid,
                    p_osnum = &dir_grid->osnum);

  if(rc != DIR_S_SUCCESS)
  {
      /*| constructs_lib does not exist */
      rc = di$mkdir(osnum = cur_os,
                    dirname = dir_name,
                    p_dirid = &dir_grid->objid);
     dir_grid->osnum = cur_os;
  }
  return(rc);
}

#endif

/***************************************************************
   Initialize the macro directories.
   Load corresponding file if exist
***************************************************************/

ACactivate(file_name,construct,req_mode,open_index,open_mode,send_os )
char *file_name;         /* I name of the file                 */
struct GRid *construct;  /* O GRid of the constructs directory */
IGRint req_mode,         /* I request mode to open the file    */
       *open_index,      /* O invisible index of the file      */
       *open_mode;       /* O obtain mode for the file         */
GRspacenum	send_os; /* I sender object space	       */

/*.ACactivate */
{
IGRchar		full_file_name[DI_PATH_MAX],
		full_dir_name[DI_PATH_MAX];
IGRchar		fileName[DI_PATH_MAX];
IGRlong		rc,status;
IGRint		i;
struct GRid	dir,lib;
GRspacenum	mod_osnum,cur_os;
OM_S_OBJID	super_id,mod_id,cur_id;
int		invisible_index;
OM_S_OBJID	tmp;


  full_file_name[0] = '\0';
  status = ex$get_cur_mod( id = &cur_id, osnum = &cur_os);

#ifdef DEBUG
  printf("\tACact:file %s cur_os: %d ref_os: %d mode:%d\n",
			file_name, cur_os , send_os, req_mode );
#endif

/*
 * from ACtmp_defn the file_name can be an empty string.
 * 	empty string create problems with retrieve_module.
 */

if( file_name[0] == '\0' )	strcpy( file_name, "." );

if(( strcmp( file_name, ".") == 0 ) &&
   ( send_os != cur_os )){
  rc = di$give_pathname(osnum = send_os, pathname = fileName );
  strcpy( file_name, &fileName[1] );

#ifdef	DEBUG
  printf("\tACact:Changed filename -> %s\n", file_name );
#endif
}

/*
   construct constructs_lib if it does not already exist
*/

*open_index = -1;
invisible_index = -1;

rc = di$give_pathname(osnum = cur_os, pathname = full_dir_name);

/*
 * the input can be an "." or a "filename"
 */
if( ( cur_os == send_os ) &&
    ( strcmp( file_name, ".") == 0 ||
      strcmp( file_name, &full_dir_name[1] ) == 0 ))
  {
    /*
     * file to mount is current file
     */
     mod_osnum = cur_os;
     strcpy( file_name, ".");
     ACopen_store(mod_osnum,file_name,open_index);
     *open_mode = EX_read_write;
  }
  else{
    /*
     *  file to mount is a reference file
     */

    strcat(full_dir_name,":");
    strcat(full_dir_name,ACdefault_constructs_lib);

    rc = ACtran_or_make(cur_os,full_dir_name,&lib);

    if(rc != DIR_S_SUCCESS){
       printf("mkdir of %s failed\n",full_dir_name);
       return(rc);
    }

    /*
     * Get name from root for the file
     */
    ACpath_to_file(file_name,full_file_name);

#ifdef	DEBUG
    printf("ACact:full_file_name: %s \n", full_file_name);
#endif

    /*
     * to handle relative paths
     * ADZ: Put on comment.
     *
     *	   module_build_path ( full_file_name );
     */

    /*
     *  File will appear in the directory as
     */
    strcat(full_dir_name,":");
    strcat(full_dir_name,file_name);

    status = om$os_name_to_number(osname = full_file_name,
				 p_osnum = &mod_osnum);

#ifdef	DEBUG
    printf(" name:%s osnum: %d status:%d\n",full_file_name,mod_osnum,status); 
#endif

    /*
     * When the path is failing. We need to delete the existing name path for
     * the sub-directory system.
     */

    if(!(status&1)){

	struct GRid thing;

        /* jla/hgb april 93 make sure that a directory with that name does
           not already exist in construct_lib. This should never hapen
           because macro lib are unmounted during save. But it hapens,
           and today nobody knows to reproduce !!!!! Let's try to
           survive the problem
         */

   	rc = di$translate(osnum = mod_osnum,
                          objname = full_dir_name,
                          p_objid = &thing.objid,
                          p_osnum = &thing.osnum);
	if(rc == DIR_S_SUCCESS){

	  int  Index;
	  char DirectoryName [DI_PATH_MAX], BaseName [DI_PATH_MAX];
	   
	  /* Force delete this thing that should not exist .... */
	  di$split ( pathname = full_dir_name,
		     dirname = DirectoryName, 
	 	     name = BaseName );
	  di$unindex(dirname = DirectoryName,
		     name = BaseName,
		     p_index = &Index );
	  di$rm_index(dirname = DirectoryName,
		      index = Index );

	  om$send(msg = message Root.delete ( 1 ),
		  senderid = NULL_OBJID,
		  targetid = thing.objid,
		  targetos = thing.osnum);
	}

        /*
         * If mount for read only verify that the file already exist
         */
        if(req_mode == EX_read_only){
  	  if(access(full_file_name,00) != 0) return (OM_W_ABORT);
        }

        /*
         * Define the obtained mode for mount
         */
        if((access(full_file_name,00) == 0) &&
           (access(full_file_name,02) != 0)) {
          /* file is read only */
          *open_mode = EX_read_only; 
        }
        else{
  	  /* file is read and write */
          *open_mode = EX_read_write;
        }

        status = ex$retrieve_module(filename = full_file_name,
				  flag     = *open_mode,
				  file_no  = &invisible_index,
				  fstat    = EX_default,
				  ftype    = EX_invisible,
				  mount_name = full_dir_name);
        as$status();

        /*
         * After mount, get the index or retrieved module.
         */
        status = ex$get_invis_info_by_index (
				  index = invisible_index,
                                  mod_osnum = &mod_osnum,
				  mod_id = &mod_id);
        as$status(action = RET_STATUS);

        /*
         * construct super object in macro lib
         */
        status =
        ex$get_super(	mod_id		= mod_id,
			mod_osnum	= mod_osnum,
			super_name	= "super_para",
			create		= TRUE,
			super_class	= "super_para",
			super_id	= &super_id);

        /*
         * construct super object in current module
         */
        status = 
        ex$get_super(	mod_id		= cur_id,
			mod_osnum	= cur_os,
			super_name	= "super_para",
			create		= TRUE,
			super_class	= "super_para",
			super_id	= &super_id );

        /*
         * Store the information
         */
        ACopen_store(mod_osnum,file_name,open_index);
    }
    else{

      /*
       *  mount if necessary directory of already mounted file
       */
      rc = di$translate(  osnum = mod_osnum,
                        objname = full_dir_name,
                        p_objid = &tmp);
      if(rc != DIR_S_SUCCESS ){
        /*
         * Don't mount the module, when the module is current object space.!!!
         */
        if( mod_osnum != cur_os ){
          /*
	   * mount it
	   */
	  rc = di$mount( logical = full_dir_name, osnum = mod_osnum);

          /*
	   * construct super object in current module
	   */
	  status = 
	  ex$get_super(	mod_id		= cur_id,
			mod_osnum	= cur_os,
			super_name	= "super_para",
			create		= TRUE,
			super_class	= "super_para",
			super_id	= &super_id);
	  as$status();
        } /* mod_osnum != cur_os */
      }
      /*
       * give error message from previous process.
       */
      if(!(rc&1)) di$report_error(sts = rc);

      /*
       * retrieve its open mode (check on mod_osnum).
       */
      for( i=0; i<ACopen_number; i++ ){

	if(ACopen_info[i].osnum == mod_osnum){
	  /*
	   * found in open list
	   */
	  *open_index = i;
	  if( ex$is_invis(	mod_osnum = mod_osnum,
				index	  = &invisible_index)){

	    status =
	    ex$get_invis_info_by_index(index = invisible_index,
					flag  = open_mode);
	  }
	  else{ *open_mode = EX_read_write; }
					 
	  break;
	}
      }

      if( *open_index == -1 ){
        /*
         * Error macro lib not found in open list
         */
        return(OM_W_ABORT);
      }
    }
  }
      
  /*
   * control that the construct directory exist in it or created if not
   */

  strcat(full_dir_name,":");
  strcat(full_dir_name,ACdefault_constructs);

  ACtran_or_make(mod_osnum,full_dir_name,construct);

#ifdef	DEBUG
  printf(" ACact:%d:%s: %d,%d\n", mod_osnum, full_dir_name,
					construct->objid, construct->osnum );
#endif

  return (OM_S_SUCCESS);
}

#ifdef	ORIGINAL

ACconstruct_save(name)
char *name;
{
IGRlong status = OM_S_SUCCESS;
IGRint invisible_index;

 ASsuper_construct();

/*| retrieve index from file name or take working directory */

if(name == NULL || name[0]=='\0')
  {
   /*| save working dir */
   if(ex$is_invis(mod_osnum = AC_construct_id.osnum,
		  index = &invisible_index))
     {
      status = ex$save_module(index = invisible_index);
      as$status();
     }
   else
     {
      printf("working directory for macro is NOT a macro lib\n");
     }
  }
else
  {
   printf("save path dir not implemented \n");
  }

return(status);
}

#endif

end implementation Root;
