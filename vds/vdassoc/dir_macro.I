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


#ifdef  ASSOC_ORIGINAL

%safe
/******   INFORMATION ABOUT WOKING DIRECTORY FOR MACRO  *****/


char ACwd[DI_PATH_MAX];          /* name of the file                  */

struct GRid AC_construct_id = {0,(OM_S_OBJID)-1};        /* grid of the working
directory*/

/******   INFORMATION ABOUT PATH DIRECTORY FOR MACRO  *****/

struct GRid *ACpath_grid = NULL;   /* list of grid for path directory       */
int  *ACpath_in_open = NULL;       /* corresponding index in open list      */
int  ACpath_gr_number = 0;         /* number of directory in the path       */
int  ACpath_gr_total = 0;          /* allocated size of ACpath_grid         */

/******   INFORMATION ABOUT OPEN LIB FOR MACRO  *****/

int ACopen_number = 0;             /* number of open OS for macro lib       */
int ACopen_size = 0;               /* size of ACopen_struct                 */

struct ACopen_struct
   {
    int osnum;                     /* open osnum                            */
    int name;                      /* index of name in name_array           */
   };

struct ACopen_struct
           *ACopen_info = NULL;    /* allocated place for info              */

int ACopen_name_used = 0;          /* size used to store open file name     */
int ACopen_name_size = 0;          /* size allocated to store open file name*/

char *ACopen_name_array = NULL;     /* allocated space for name             */



/*******   DEFAULT NAME AND SEPARATOR *********/

char *ACdefault_constructs = "constructs";
char *ACdefault_constructs_lib = "constructs_lib";

%endsafe

#endif

#define SEPAR_PATH ','
#define SEPAR_DIR  ':'


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
 

/***************************************************************
   Initialize the macro directories.
   Load corresponding file if exist
***************************************************************/

ACactivate(file_name,construct,req_mode,open_index,open_mode)
char *file_name;         /* I name of the file                 */
struct GRid *construct;  /* O GRid of the constructs directory */
IGRint req_mode,         /* I request mode to open the file    */
       *open_index,      /* O invisible index of the file      */
       *open_mode;       /* O obtain mode for the file         */

/*.ACactivate */
{
IGRchar full_file_name[DI_PATH_MAX],full_dir_name[DI_PATH_MAX];
IGRlong rc,status;
IGRint i;
struct GRid lib;
GRspacenum mod_osnum,cur_os;
OM_S_OBJID super_id,mod_id,cur_id;
int invisible_index;

/*"file to activate is %s\n",file_name */

full_file_name[0] = '\0';

/*
   construct constructs_lib if it does not already exist
*/

*open_index = -1;
invisible_index = -1;

status = ex$get_cur_mod( id = &cur_id, osnum = &cur_os);
/*" cur_os is %d\n", cur_os */

rc = di$give_pathname(osnum = cur_os,
                      pathname = full_dir_name);
/*"active file name %s\n",full_dir_name */


if(strcmp(file_name,".") == 0)
  {
   /*| file to mount is current file */
   mod_osnum = cur_os;
   ACopen_store(mod_osnum,file_name,open_index);
   *open_mode = EX_read_write;
  }
else
  {
   /*| file to mount is a reference file */
   strcat(full_dir_name,":");
   strcat(full_dir_name,ACdefault_constructs_lib);

   /*"lib in %s\n",full_dir_name */

   rc = ACtran_or_make(cur_os,full_dir_name,&lib);

   if(rc != DIR_S_SUCCESS)
     {
       printf("mkdir of %s failed\n",full_dir_name);
       return(rc);
      }

   /* Get name from root for the file */

   ACpath_to_file(file_name,full_file_name);

/* START VDS CORRECTION */
   /*
    * We do not like to see the total path's
    *
    * module_build_path ( full_file_name );
    */

   /* File will appear in the directory as */

   strcat(full_dir_name,":");

   /* strcat(full_dir_name,full_file_name); */
   strcat(full_dir_name,file_name);

/* END  VDS CORRECTION */

   /*"is the file %s already mounted\n",full_file_name */

   status = om$os_name_to_number(osname = full_file_name,
                                 p_osnum = &mod_osnum);
   if(!(status&1))
       {
        struct GRid thing;
        /* jla/hgb april 93 make sure that a directory with that name does
           not already exist in construct_lib. This should never hapen
           because macro lib are unmounted during save. But it hapens,
           and today nobody knows to reproduce !!!!! Let's try to
           survive the problem */

        rc = di$translate(osnum = mod_osnum,
                          objname = full_dir_name,
                          p_objid = &thing.objid,
                          p_osnum = &thing.osnum);
        if(rc == DIR_S_SUCCESS)
         {
           int  Index;
           char DirectoryName [DI_PATH_MAX], BaseName [DI_PATH_MAX];

          /* Force delete this thing that should not exist .... */
          di$split ( pathname = full_dir_name, dirname = DirectoryName,
            name = BaseName );
          di$unindex( dirname = DirectoryName,name = BaseName,p_index = &Index);
          di$rm_index ( dirname = DirectoryName, index = Index );
          om$send(msg = message Root.delete ( 1 ),
                  senderid = NULL_OBJID,
                  targetid = thing.objid,
                  targetos = thing.osnum);
         }

        /* If mount for read only verify that the file already exist */
        if(req_mode == EX_read_only)
          {
           if(access(full_file_name,00) != 0) return (OM_W_ABORT);
          }

        /* Define the obtained mode for mount */
        if((access(full_file_name,00) == 0) &&
           (access(full_file_name,02) != 0)    )
            {
              /*| file is read only */
              *open_mode = EX_read_only;
            }

        else
            {
              /*| file is read and write */
              *open_mode = EX_read_write;
            }

        status = ex$retrieve_module(filename = full_file_name,
                                  flag     = *open_mode,
                                  file_no  = &invisible_index,
                                  fstat    = EX_default,
                                  ftype    = EX_invisible,
                                  mount_name = full_dir_name);
        as$status();

        /*| After mount */

        status = ex$get_invis_info_by_index ( index = invisible_index,
                                  mod_osnum = &mod_osnum,
                                  mod_id = &mod_id);
        as$status(action = RET_STATUS);

        /*| construct super object in macro lib */

        ex$get_super(mod_id = mod_id,
                mod_osnum = mod_osnum,
                super_name = "super_para",
                create = TRUE,
                super_class = "super_para",
                super_id = &super_id);

        /*| construct super object in current module */

        ex$get_super(mod_id = cur_id,
                mod_osnum = cur_os,
                super_name = "super_para",
                create = TRUE,
                super_class = "super_para",
                super_id = &super_id);

        /*| Store the information */
        ACopen_store(mod_osnum,file_name,open_index);
       }
      else
       {
        OM_S_OBJID tmp;

         /*| mount if necessary directory of already mounted file */
        rc = di$translate(osnum = mod_osnum,
                          objname = full_dir_name,
                          p_objid = &tmp);
         if(rc != DIR_S_SUCCESS)
          {
            /*
             * Don't mount the module!!!
             */
            if (mod_osnum != cur_os)
            {
              /*| mount it */
              rc = di$mount(logical = full_dir_name,
                         osnum   = mod_osnum);

             /*| construct super object in current module */

             ex$get_super(mod_id = cur_id,
                mod_osnum = cur_os,
                super_name = "super_para",
                create = TRUE,
                super_class = "super_para",
                super_id = &super_id);
            }
          }
         if(!(rc&1)) di$report_error(sts = rc);

        /*| retrieve its open mode */

        for(i=0;i<ACopen_number;i++)
          {
           if(ACopen_info[i].osnum == mod_osnum)
             {
              /*| found in open list */
              *open_index = i;
              if(ex$is_invis(mod_osnum = mod_osnum,
                             index = &invisible_index))
                {
                 ex$get_invis_info_by_index(index = invisible_index,
                                            flag  = open_mode);
                }
               else
                {
                 *open_mode = EX_read_write;
                }

              break;
             }
         }
        if(*open_index == -1)
          {/*| Error macro lib not found in open list */
           return(OM_W_ABORT);
          }

       }
     }

/*" obtained osnum %d\n",mod_osnum */


/*| control that the construct directory exist in it or created if not */

   strcat(full_dir_name,":");
   strcat(full_dir_name,ACdefault_constructs);

   rc = ACtran_or_make(mod_osnum,full_dir_name,construct);

   /*" directory for macro %d %d\n",construct->objid,construct->osnum */

  return (OM_S_SUCCESS);
 }

end implementation Root;
