/*

Name
  GRrfinit

Abstract
  This method retrieves a reference files object space.  

Synopsis
  GRrfinit(msg,construct_flag,logical,osnum,modid,context)

       long        *msg             return message
       IGRboolean  *construct_flag  flag to indicate object is being
                                    constructed
       char        *logical         name for mounting directory
       GRspacenum  *osnum           object space number of reference file
       GRobjid     *mod_id          object id of module object
       struct GRid *context         context object for this attachment

Description
  This method retrieves a reference files object space.  
  
  The method is used for initial attachment of a reference 
  file and for subsequent retrieval of a file with
  reference files attached.
 
   If this is a subsequent retrieval of a file and a saved 
  view attachment was used, the saved view is checked to 
  see if it  has been changed. If the saved view has changed, 
  the attachment will be marked as changed.  The transformation
  information stored in the instance data will be used.  The 
  user will have the option of altering the informtion at
  a later date.

  If the saved view has been deleted, the transformation
  information from the previous invocation of the file will 
  be used.

Return Value
  MSSUCC - successful completion
        GRFILENOTFOUND - requested file  not found
        GRVIEWNOTFOUND - requested saved view not found
        GR_E_INV_REQUEST - file is already open with specific privileges
                           and the requested opening privilege differs from these
                           privilege. 
        OM_E_NO_OS_AVAIL - the reference file limit has been exceeded,
                           no more object spaces can be opened.
        MSFAIL - error occured

Notes

Index

Keywords
  construct,reference-file,wireframe

History
  02/03/93 : Henry G. Bequet: support of name starting with a '.'
  04/02/93 : Jay H. Wallingford: fixed a problem with mount names: TR119303817
  08/04/93 : jhw: Added support for loaded/unloaded reffiles.
  08/04/93 : jhw: Added support for PDM selective reffile display on init.
  11/11/93 : jhw: Fixed error return problem when max reffiles is exceeded.
  08/25/94 : dkk: Fixed nested ref file problem for TR119418970
 */

class implementation GRreffile;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "dpdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "exdef.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "OMmacros.h"
#include "grerr.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "DImacros.h"

from GRcontext import GRputosnum, GRchgflag, GRgetinstance;

%safe
int  GRnb_ro_files = 0;
char **GRro_files;
static IGRulong GRref_depth = 0;
%endsafe

method GRrfinit ( long *msg; IGRboolean *construct_flag; char *logical; 
                  GRspacenum *osnum; GRobjid *mod_id; struct GRid *context )
{
  IGRboolean      new_context;
  IGRboolean      constr_flag=TRUE;
  char            filename [OM_K_MAXOSNAME_LEN], osname [OM_K_MAXOSNAME_LEN],
                  path [DI_PATH_MAX], *basename;
  short           action, ctx_type, context_flag = 0;
  long            OMmsg, msg1;
  int             index, my_flag, file_opened, dimension, dimension2;
  struct GRid     saved_context_id, Super_id, Super, oid, module;
  IGRmatrix       ctx_matrix;
  struct GRmd_env env;
  GRspacenum      osnum1;
  OM_S_CHANSELECT chan;
  IGRboolean      displayed, loaded;
  struct GRid     my_grid;
  
  
  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /* get the dimension of the filename */
  dimension = om$dimension_of ( varray = me->filename );
  new_context = TRUE;

  /* do we have a filename yet */
  if (dimension)
  {
    /* save the filename */
    if (om$dimension_of ( varray = me->osname ))
    {
      char *RefPath, *getenv ();
      
      /*
       * Find the guy. If REFPATH is defined then it defines a search
       * path for the reference files else we define it as '.' (relative
       * search path).If nothing works then we forget it.
       * Note that REFPATH follows the usual UNIX search path syntax (like
       * PATH, CDPATH, ...): <path1>:<path2>:...:<pathn>.
       * Also, we ALWAYS look in the current directory (even if path name
       * doesn't contain it).
       */
      if ((RefPath = getenv ( "REFPATH" )) == NULL)
        RefPath = ".";
      if(me->filename[0] == '/')
       {
	  basename = strrchr(me->filename,'/');
	  basename++;
       }
      else
       {
	  basename = me->filename;
       }
      if(!access(me->filename,0))
       strcpy(filename,me->filename);
      else
       {
        char *pString1, *pString2, PathName [DI_PATH_MAX];
        int  Stop, Found;
        
        for (pString1 = pString2 = RefPath, Found = Stop = 0; !Stop;)
        {
          /*
           * Look for the next ':' or end of string
           */
          for (; *pString2 && *pString2 != ':'; pString2++);
          
          /*
           * Replace the ':' by a '\0' for string operations
           */
          if (*pString2 == ':')
            *pString2 = '\0';
          else
            Stop = 1;
          
          if (!*PathName)
            strcpy ( PathName, "." );

          strcat ( strcat ( strcpy ( PathName, pString1 ), "/" ), basename );
          if (!Stop)
          {
            *pString2 = ':';
            pString1 = ++pString2;
          }
          
          /*
           * We must stop if we've found the file
           */
          if (Found = !access ( PathName, 0 ))
            Stop = 1;
        }
        
        strcpy ( filename, Found ? PathName : me->filename );
       }
    }
    else
      strcpy ( filename, me->filename );

    /* Is the file already opened? */
    file_opened = ex$is_file_open ( name = filename );
    oid.objid = my_id;
    oid.osnum = OM_Gw_current_OS;

    /* get the context super's information  */
    OMmsg = GRgetctxsuper ( &msg1, &Super_id );

    if (1 & OMmsg)
      /* find this object space's context object, if none exists,
         construct an empty context object and connect the channels. */
      OMmsg = GRcheckcontext ( msg, me->ref_to_master_matrix, &Super_id, &oid,
          construct_flag, context, &new_context);

    /* Push new context id on the context stack before initing the new space.
       Current context id is returned in saved_context_id. */
    if (1 & OMmsg)
    {
      GRputcontextid ( &msg1, &context->objid, &saved_context_id.objid );
      if (file_opened)
        my_flag = EX_read_write;
      else
      {
        GRis_writable ( &msg1, me->filename, 0, OM_Gw_current_OS );
        my_flag = msg1 == MSSUCC ? EX_read_write : EX_read_only;
      }

      /* 
       * Mount all reference file object spaces under the current module's 
       * ref directory. The base name of the file will be used as the logical
       * name. We also make sure that the name will be seen by the user (no '.'
       * to start the name).
       */
      {
        char *pString;
        IGRlong DIRmsg, i;
        GRobjid objid;
        GRspacenum osnum;
        IGRchar buffer[DI_PATH_MAX];

	buffer[0] = NULL;
        for (pString = &logical [strlen ( logical )] - 1; pString != logical; pString--)
          if (*pString == '/')
          {
            pString++;
            break;
          }
        
        for (; *pString == '.'; pString++);

        ex$get_cur_mod ( id = &module.objid, osnum = &module.osnum );
        DIstmocpy ( path, "ref", pString, 0, module.osnum );

        /*
         * Make sure that the new mount name will be unique.
         *
         * NOTE: This is a fix for a problem with Change Reference
         *       Attachment. TR119303817
         */
        strcpy (buffer, path);

        for (i=0; strlen(buffer) < DI_PATH_MAX-2; i++)
        {
            /*
             * See if the name is being used.
             */
            DIRmsg = di$translate ( objname = buffer,
                                    p_objid = &objid,
                                    p_osnum = &osnum );

            /*
             * If this name isn't found ...
             */
            if (!(DIRmsg&1))
            {
                /*
                 * Use it.
                 */
                strcpy (path, buffer);
                break;
            }

            /*
             * Otherwise tack a uniquifier to the end of 
             * the name and try again ...
             */
            sprintf (buffer, "%s%d", path, i);
        }
      }

      /*
       * Check with PDM's nested display handler for new display 
       * and unloaded flags.
       */
      displayed = (me->properties & GRIS_DISPLAYABLE) ? TRUE : FALSE;
      loaded = (me->ref_properties & GRRF_UNLOADED) ? FALSE : TRUE;
  
      if (PDMset_reffile_display (*construct_flag,
                                  path,
                                  &my_grid, 
                                  context,
                                  GRref_depth,
                                  &displayed, 
                                  &loaded))
      {
          if (loaded)
            me->ref_properties &= ~GRRF_UNLOADED;
          else
            me->ref_properties |= GRRF_UNLOADED;
      
          if (displayed)    
            me->properties |= GRIS_DISPLAYABLE;
          else
            me->properties &= ~GRIS_DISPLAYABLE;
      }

      /*
          Check for background attachment - they are only retrieved when
          attached directly to the master file. Also check for loaded
          or unloaded flag.
      */
      
      /*
       * Increment the depth during a file retrieval.
       */
      GRref_depth++;

      /* Revise assembly check (DEget_localplot()) is included to fix the
         background attachments problem in Revise assembly. */
 
     /* don't retrieve the reference files when assembly file is opened for
        reading partdata */

      if(ASMget_reading_partdata() == TRUE)
       {
          OMmsg = 0;
          msg1 = -1;
          my_flag = EX_read_only;
       }
      else
       if (((me->ref_properties & GRRF_BACKGROUND) &&
            (module.osnum != OM_Gw_current_OS)     &&
            !Invis_check_override() &&
            (DEget_localplot() == FALSE))          ||
           ((me->ref_properties & GRRF_UNLOADED)   &&
            (DEget_localplot() == FALSE)))
       {
          /* 
              This is a background attachment, so don't retrieve it.  Monkey
              with some variables to make it appear that the file couldn't be
              found.
          */
          OMmsg = 0;
          msg1 = -1;
          my_flag = EX_read_only;
       }
      else
       {
          /* retrieve the object space */
          OMmsg = ex$retrieve_module(filename = filename,
                                     ftype = EX_invisible,
                                     mount_name = path,
                                     flag = my_flag,
                                     file_no = &index,
                                     mod_type = 2,
                                     fstat = EX_old_module,
                                     type = EX_ref,
                                     msg = (int *)&msg1);
       }

      /* we try with a read-only flag */
      if (!(1 & OMmsg) && (my_flag == EX_read_write))
      {
        OMmsg = ex$retrieve_module ( filename = filename,
            ftype = EX_invisible,
            mount_name = path,
            flag = EX_read_only,
            file_no = &index,
            mod_type = 2,
            fstat = EX_old_module,
            type = EX_ref,
            msg = (int *) &msg1 );
        
        if ((1 & OMmsg) &&
            (!file_opened) &&
            (1 & GRis_force_writable(&msg1, filename, 0, OM_Gw_current_OS)) &
            (msg1 != MSSUCC))
        {
          int i;

          for (i = 0; i < GRnb_ro_files; i++)
            if (!strcmp ( GRro_files [i], filename ))
              break;

          if (i == GRnb_ro_files)
          {
            if (!(GRnb_ro_files % 124))
            {
              if (GRro_files)
                GRro_files = (char **)realloc ( GRro_files,
                    (GRnb_ro_files + 124) * sizeof ( char * ) );
              else
                GRro_files = (char **)malloc ( 124 * sizeof ( char * ) );
            }
  
            if (!GRro_files)
            {
              *msg = MSFAIL;
              return OM_E_NODYNMEM;
            }
  
            GRro_files [GRnb_ro_files] = (char *)malloc ( DI_PATH_MAX + 1 );
            strcpy ( GRro_files [GRnb_ro_files], filename );
            GRnb_ro_files++;
          }
        }
      }

      /*
       * Decrement the depth after a retrieval.
       */
      GRref_depth--;
      
      if (1 & OMmsg)
      {
        /* get module id from invisible table */
        Get_invisible_objid ( index, mod_id );

        /* get module space number */
        Get_invisible_osnum (index, osnum );

        /* store the object space name */
        om$os_number_to_name ( osnum = *osnum, osname = osname );

        dimension = om$dimension_of ( varray = me->osname );
        dimension2 = strlen ( osname ) + 1;
        if (dimension != dimension2)
          om$vla_set_dimension ( size = dimension2, varray = me->osname );

        strcpy ( me->osname, osname );
        om$send ( msg = message GRcontext.GRputosnum ( msg, osnum ),
            targetid = context->objid,
            targetos = context->osnum );

        if (file_opened)
        {
          /* check to see if this is a cyclic attachment before initing the 
             reference file. */
          if (new_context)
          {
            om$make_chanselect ( channame = "GRcontext.to_nested_files",
                p_chanselect = &chan );
            GRcyclic_check ( msg, &chan, context,osnum, &context_flag );
          }
          else
            /* see if this is a cyclic attachment */
            om$send ( msg = message GRcontext.GRgetinstance ( &msg1, &ctx_type,
                ctx_matrix, &osnum1,
                &context_flag,
                context ),
                targetid = context->objid,
                targetos = context->osnum);

          if (!(context_flag & GRCYCLIC_ATTACHMENT))
          {
            /* get the reference file super in the reference file os */
            OMmsg = ex$get_super ( mod_id = *mod_id,
                mod_osnum = *osnum,
                super_name = "Ref Mgr",
                create = 0,
                super_class = "GRreffile",
                super_id = &Super.objid,
                super_osnum = &Super.osnum );
            if ((1 & OMmsg) && (!IF_NULL_OBJID ( Super.objid )))
            {
              om$make_chanselect ( channame = "Super_rfmgr.mgr",
                  p_chanselect = &chan );
              OMmsg = om$send ( msg = message GRreffile.GRrfpostinit ( msg, &Super_id
                  ),
                  senderid = Super.objid,
                  targetos = Super.osnum,
                  p_chanselect = &chan);
            }
          }
        }

/* FIX for 119418970, recompute sent to source objects connected to objects
   in nested ref files everytime the master file is saved/retrieved. 
   The fix is: GRupdcontext() is sent to the contexts of the ref files within
   the master(active) os only. The nested contexts are to be updated 
   from the master os contexts only and not directly.
   -- Moved this fix to GRupdcontext.I TR# 119526088
*/
        if ((1 & OMmsg) && (!*construct_flag)) 
        {
          /* If the space did not have a context object, a new one was 
             constructed.  Since the send is not due to a construct operation,
             the context must now be updated. */
          env.md_env.matrix_type = MAIDMX;
          MAidmx ( &msg1, env.md_env.matrix );
          env.md_id.objid = NULL_OBJID;
          env.md_id.osnum = OM_Gw_current_OS;
          OMmsg = GRupdcontext ( msg, &env, me->ref_to_master_matrix,
              &constr_flag, &my_id, context );
        }

        action = 1;
        context_flag = GRACTIVATED_CONTEXT;
        om$send ( msg = message GRcontext.GRchgflag ( &msg1, &action,
            &context_flag ),
            targetid = context->objid,
            targetos = context->osnum);
      }
      else 
      {
        /* retrieve OS failed */
        if (msg1 == EX_flag)
          *msg = GR_E_INV_REQUEST;
        else 
          if (msg1 == OM_E_NO_OS_AVAIL)
            *msg = msg1;
          else
          {
              int invis_index;
              OMuword mod_osnum;
                
              /* 
               * Check to see if we exceeded the maximum number of 
               * reference files. Previously ex$retrieve_module would 
               * return OM_E_NO_OS_AVAIL but this is not longer the case.
               */
              for (invis_index=0; invis_index<EX_MAX_INVIS_MODULES; ++invis_index)
              {
                  Get_invisible_osnum (invis_index, &mod_osnum);
                  
                  if (mod_osnum == 0) /* This is the last one. */
                  {
                      break;
                  }   
              }
                
              if (invis_index >= EX_MAX_INVIS_MODULES)
              {
                  *msg = OM_E_NO_OS_AVAIL;
              }
              else
              {
                  *msg = GRFILENOTFOUND;
              }
          }
        
        *osnum = (uword) ~0;
        *mod_id = NULL_OBJID;

        /*
         * put the filename as osname so that converted files (from IGDS) 
         * don't crash.
         */
        om$vla_set_dimension ( size = strlen ( me->filename ) + 1, varray = me->osname );
        strcpy ( me->osname, me->filename );

        om$send ( msg = message GRcontext.GRputosnum ( &msg1, osnum ),
            targetid = context->objid,
            targetos = context->osnum );

        /* reset OMmsg to continue channel send */
        OMmsg = OM_W_ABORT;
      }

      GRputcontextid ( &msg1, &saved_context_id.objid, &context->objid );
    }
  }



  if (1 & OMmsg)
    /* Notify the directory system that a reference file is mounted. 
       This connects the directory object to the context object. */
    di$mount_ref ( logical = path, osnum = *osnum, context = *context );

  return OMmsg;
}


end implementation GRreffile;
