class implementation GRreffile;

/*
   This file contains the code for writable reference files.
*/

#include <stdio.h>
#include "igetypedef.h"
#include "igr.h"
#include "madef.h"
#include "godef.h"
#include "exdef.h"
#include "gr.h"
#include "grerr.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "ex.h"
#include "OMmacros.h"
#include "msdef.h"
#include "refpriv.h"
#include "grdpbmacros.h"
#include "grgsdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"
#include "refdef.h"

from Super_rfmgr import
    add, force_add, remove_file_name, translate, force_translate;

GRget_file_list ( p_grid, create, osnum )
                  struct GRid *p_grid	/* The GRid of the list		OUT */;
                  int         create	/* Create the list ?		IN  */;
                  OMuword     osnum	/* The os to get the list from	IN  */; 
/*
   This function returns the grid of the list of writable files.  If no
   list exists and create is TRUE, an empty one will be created .
*/
{
  int         status;
  GRobjid     mod_objid;
  struct GRid grid;
  
  if (!p_grid)
    p_grid = &grid;
  p_grid->objid = NULL_OBJID;

  if (!osnum)
    ex$get_cur_mod ( osnum = &osnum );
  ex$get_modid ( mod_osnum = osnum, mod_id = &mod_objid );
  status = ex$get_super ( mod_id = mod_objid,
                          mod_osnum = osnum,
                          super_name = "Ref Mgr",
                          super_class = "Super_rfmgr",
                          create = create,
                          super_id = &p_grid->objid,
                          super_osnum = &p_grid->osnum );
  
  return status;
}

#argsused
GRis_writable ( msg, file_name, check, osnum )
                long    *msg   	   /* The return status 		OUT */;
                char    *file_name /* The file to be checked		IN  */;
                int     check      /* Check the os object		IN  */;
                OMuword osnum	   /* The os to check in		IN  */;
/*
   This procedure returns MSSUCC in msg if file_name is a writable file. 
*/
{
  struct GRid list;
  int         status;
  
  /* get the list */
  *msg = MSFAIL;
  status = GRget_file_list ( &list, 0, osnum );
  if (status == OM_S_SUCCESS)
    /* ask the list */
    status = om$send ( msg = message Super_rfmgr.translate ( msg, file_name ),
                       senderid = NULL_OBJID,
                       targetid = list.objid,
                       targetos = list.osnum );
  
  return status;
}

GRis_nested_writable ( IGRlong * msg, IGRchar * file_name )
/*
   This procedure returns MSSUCC in msg if file_name is a writable in one
   of the nested files.
*/
{
    IGRlong status = OM_S_SUCCESS;
    IGRint  i, refflag;
    OMuword osnum;
    
    *msg = MSFAIL;

    for (i=0; i< EX_MAX_INVIS_MODULES; ++i)
    {
        /*
         * Get the osnum of this entry.
         */
        Get_invisible_osnum (i, &osnum);

        /*
         * If this isn't the end of the list ...
         */
        if (osnum != 0)
        {
            /*
             * If it's a reference file ...
             */
            Get_ref_flag (i, refflag);

            if (refflag)
            {
                /*
                 * See if the reference file has file_name as one of it's
                 * writable files.
                 */
                status = GRis_writable (msg, file_name, 0, osnum);

                /*
                 * If so return success.
                 */
                if (status & *msg & 1)
                {
                    break;
                }
            }
        }
    }

    return status;
}

GRmake_writable ( msg, file_name,osnum )
                  long *msg 	  /* The return status 			OUT */;
                  char *file_name /* The file to be made writable	IN  */;
                  OMuword *osnum  /* The os to use                      IN  */;
/*
   This procedure changes the state of file_name to writable.  It returns 
   an error if the file cannot be opened in write mode.  If the file is 
   not stored in the list yet, it is added.
*/
{
  struct GRid list;
  int         status = OM_S_SUCCESS;
  FILE        *fet;
  OMuword     osnum1; 

  /* make sure that file is writable */
  *msg = MSFAIL;
  if (fet = (FILE *)fopen ( file_name, "r+" ))
  {
    fclose ( fet );
      
    /* get the list */
    if(osnum == NULL)
     {
        ex$get_cur_mod ( osnum = &osnum1 );
     }
    else
     {
        osnum1 = *osnum;
     }

    status = GRget_file_list ( &list, 1, osnum1 );
    if (status == OM_S_SUCCESS)
      /* add to the list */
      status = om$send ( msg = message Super_rfmgr.add ( msg, file_name ),
                         senderid = NULL_OBJID,
                         targetid = list.objid,
                         targetos = list.osnum );
  }

  return status;
}


GRmake_read_only ( msg, file_name ,osnum)
                   long *msg 	   /* The return status 		OUT */;
                   char *file_name /* The file to be made read_only      IN  */;
                   OMuword *osnum  /* The os to use                      IN  */;
/*
   This procedure changes the state of file_name to read only.  Since a file
   not in the list means it is read only, all that prodecure does is remove
   the file from the list.
*/
{
  struct GRid list;
  int         status;
  OMuword     osnum1;
  
  /* get the list */
  *msg = MSFAIL;
  if(osnum == NULL)
   {
     ex$get_cur_mod ( osnum = &osnum1 );
   }
  else
   {
     osnum1 = *osnum;
   }
  status = GRget_file_list ( &list, 0, osnum1 );
  if (status == OM_S_SUCCESS)
    /* add to the list */
    status = om$send ( msg = message Super_rfmgr.remove_file_name ( msg, file_name ),
                       senderid = NULL_OBJID,
                       targetid = list.objid,
                       targetos = list.osnum );

  return status;
}

/*
Name
        GRforce_writable

Description
        This procedure changes the state of file_name to writable, regardless
        of whether the file is actually writable on disk (because of UNIX file
        permissions).  If the file is not stored in the list yet, it is added.

        This function is primarily intended to be used as a kludge by PDU so
        that files which the user has not checked out may still be referenced
        for PDD (which requires write access to the file) in some future
        session if the file is granted write permission by a PDU checkout
        procedure.  It is understood that any changes to the reference files
        will be lost when the master file is saved if they did not have write
        permissions when retrieved.  PDU will take care of checking out the
        files and granting write permission during sessions in which work will
        need to be saved.  (Kurt said so, so don't let him claim otherwise
        later :-).  Actually, PDD will not run when the object space is not
        writable, even if it is included in this list, so the user should stay
        out of too much trouble.

        The filename is stored in the list with a tag appended so that it is
        possible to detemine later whether the file is really writable, or
        whether it has been forced into the list through this function.  This
        will be used in the retrieve code to decide whether to display an
        error box for files which could not be retrieved writable.

History
        mrm     10/29/92    creation (in a hurry)
*/
int GRforce_writable(msg, file_name,osnum)
long *msg 	        /* The return status 		        OUT */;
char *file_name         /* The file to be made writable	        IN  */;
OMuword *osnum          /* The os to use                        IN  */;
{
    struct GRid list;
    int         status = OM_S_SUCCESS;
    OMuword     osnum1; 

    /* get the list */
    *msg = MSFAIL;

    if(osnum == NULL)
     {
       ex$get_cur_mod(osnum = &osnum1);
     }
    else
     {
       osnum1 = *osnum;
     }
    status = GRget_file_list(&list, 1, osnum1);
    if (status == OM_S_SUCCESS)
    {
        /*
            Add the name to the list as one that was forced in.
        */

        status = om$send(msg = message Super_rfmgr.force_add(msg, file_name),
                         senderid = NULL_OBJID,
                         targetid = list.objid,
                         targetos = list.osnum);
    }

    return status;
}

/*
Name
        GRis_force_writable

Description
        This function returns MSSUCC in msg if file_name is a force-writable
        file; ie was made writable through GRforce_writable.
*/
#argsused
GRis_force_writable(msg, file_name, check, osnum)
long    *msg   	   /* The return status 		OUT */;
char    *file_name /* The file to be checked		IN  */;
int     check      /* Check the os object		IN  */;
OMuword osnum	   /* The os to check in		IN  */;
{
    int sts;
    struct GRid list;
  
    /* get the list */
    *msg = MSFAIL;
    sts = GRget_file_list(&list, 0, osnum);
    if (sts == OM_S_SUCCESS)
        /* ask the list */
        sts = om$send(msg = 
                      message Super_rfmgr.force_translate(msg, file_name),
                      senderid = NULL_OBJID,
                      targetid = list.objid,
                      targetos = list.osnum);
  
    return(sts);
}


end implementation GRreffile;
