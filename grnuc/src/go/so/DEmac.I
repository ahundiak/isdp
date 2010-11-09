class implementation DEso;

#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/param.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exmacros.h"
#include "DEso.h"
#include "griomacros.h"

#if defined ( SUNOS ) || defined ( SUNOS5 )
#define PATH_MAX 1023
#endif
#define DEfind_refname(tmp_name, name) \
{  \
    char *ptr1; \
      for (ptr1 = &tmp_name [strlen ( tmp_name )]; \
           (ptr1 != tmp_name) && (*ptr1 != '/'); ptr1--); \
      if (ptr1 != tmp_name) \
        ptr1++; \
      strcpy ( &name [4], ptr1 ); \
}

#argsused
DEplace_so ( msg, type, symb, u1, u2, go, window, module, inter )
             long              *msg   /* return status             OUT */;
             int               type   /* the type of the entry     IN  */;
             struct IGRdisplay *symb  /* symbology of the override IN  */;
             IGRdouble         u1, u2 /* parms of the override     IN  */;
             struct GRid       *go    /* object for the override   IN  */;
             struct GRid       *window/* window for the override   IN  */;
             struct GRmd_env   *module/* context of the override   IN  */;
             int               inter  /* interference checking ?   IN  */;
/*
   This function places a symbology override on go in window with the
   specified context.
*/
{
  uword mod_osnum;
  
  if ( !DEsos )
  {
     *msg = MSFAIL;
     return( OM_E_ABORT );
  }
  
  ex$get_cur_mod ( osnum = &mod_osnum );
  return om$send ( msg = message DEso.DEadd ( msg, type, go->objid, u1, u2, 
                                              symb, window, NULL_INDEX, module, 
                                              NULL_INDEX ),
                   senderid = NULL_OBJID,
                   targetid = DEsos [go->osnum],
                   targetos = mod_osnum );
}


DEdelete_soo_in_view ( msg, go, window, module )
                       long              *msg    /* return status       OUT */;
                       struct GRid       *go     /* object for override IN  */;
                       struct GRid       *window /* window for override IN  */;
                       struct GRmd_env   *module /* context of override IN  */;
/*
   This function deletes all the overrides of a go in the specified view.
*/
{
  uword mod_osnum;
  
  if ( !DEsos )
  {
     /* no DEso objects => don't fail because tags */
     /* will take care of any problems             */
     *msg = MSSUCC;
     return( OM_S_SUCCESS );
  }

  ex$get_cur_mod ( osnum = &mod_osnum );
  return om$send ( msg = message DEso.DEremove_in_view ( msg, go->objid,
                                                         window, module ),
                   senderid = NULL_OBJID,
                   targetid = DEsos [go->osnum],
                   targetos = mod_osnum );
}


DEdelete_so ( msg, type, symb, u1, u2, go, window, module )
              long              *msg    /* return status              OUT */;
              int               type    /* the type of the entry      IN  */;
              struct IGRdisplay *symb   /* symbology of the override  IN  */;
              IGRdouble         u1, u2  /* parms of the override      IN  */;
              struct GRid       *go     /* object for the override    IN  */;
              struct GRid       *window /* window for the override    IN  */;
              struct GRmd_env   *module /* context of the override    IN  */;
/*
   This function deletes a symbology override on go in window with the
   specified context.
*/
{
  uword mod_osnum;
  
  if ( !DEsos )
  {
     /* no DEso objects => don't fail because tags */
     /* will take care of any problems             */
     *msg = MSSUCC;
     return( OM_S_SUCCESS );
  }

  ex$get_cur_mod ( osnum = &mod_osnum );
  return om$send ( msg = message DEso.DEremove ( msg, type, go->objid, u1, 
                                                 u2, symb, window, module ),
                   senderid = NULL_OBJID,
                   targetid = DEsos [go->osnum],
                   targetos = mod_osnum );
}


DEdelete_by_objid ( msg, osnum, objid )
                    long    *msg   /* return status        OUT */;
                    uword   osnum  /* osnum of the object  IN  */;
                    GRobjid objid  /* objid of the object  IN  */;
/*
   This function deletes all the symbology override on go.
*/
{
  uword mod_osnum;
  
  if ( !DEsos )
  {
     /* no DEso objects => don't fail because tags */
     /* will take care of any problems             */
     *msg = MSSUCC;
     return( OM_S_SUCCESS );
  }

  ex$get_cur_mod ( osnum = &mod_osnum );
  return om$send ( msg = message DEso.DEremove_by_objid ( msg, objid ),
                   senderid = NULL_OBJID,
                   targetid = DEsos [osnum],
                   targetos = mod_osnum );
}


DEcreate_soo ( msg, p_objid, osnum )
               long       *msg     /* return status                 OUT */;
               OM_S_OBJID *p_objid /* the objid of the created soo  OUT */;
               IGRushort  osnum    /* the os the soo is for         IN  */;
{
  int     status;
  IGRushort  mod_osnum;
  GRobjid soo=NULL_OBJID, 
          mod_id;
  char    name[MAXPATHLEN], 
          tmp_name[MAXPATHLEN];
  struct GRIOvar_def input_variable; 

  /* if the soo is for the module, it's easy */
  ex$get_cur_mod ( id = &mod_id, osnum = &mod_osnum );
  strcpy ( name, "soo_" );
  if (osnum == mod_osnum)
  {
    status = OM_S_SUCCESS;
    strcpy ( &name [4], "master" );
  }
  else
  {
    status = om$os_number_to_name ( osnum = osnum, osname = tmp_name );
    if (status & 1)
    { 
      /* om$os_number_to_name may return a full path name for the osname.
         This will put only the osname into name[4].
       */  
     DEfind_refname (tmp_name, name);
    }
  }

  if (!(status & 1))
  {
    *msg = MSFAIL;
    return status;
  }

  ex$get_super ( mod_id = mod_id, 
                 mod_osnum = mod_osnum,
                 super_name = name,
                 super_class = "DEso", 
                 super_id = &soo );
  if (soo == NULL_OBJID)
  {
    *msg = MSFAIL;
    status = ex$get_super ( mod_id = mod_id, 
                            mod_osnum = mod_osnum,
                            super_name = name,
                            create = 1,
                            super_class = "DEso", 
                            super_id = &soo );
    if (!(status & 1))
    {
      printf ( "%s at %d: error in soo construction\n", __FILE__, __LINE__ );
      om$report_error ( sts = status );
    } 
    else
    {
/*  Hash function has changed in 2.2. Need to rehash old soo tables. Add the
    name in GRvar to indicate that rehashing of the table is not necessary for
    this soo which is created in 2.2.  --Mrudula.                           */

      strcat (name, "_5535");     /* Make the name unique. */

      /* Purify fix - send the osnum & initialize input_variable */

      input_variable.type = GRIO_VAR_STRING;
      strcpy(input_variable.contents.string, "");

      status = co$addvar(msg = msg,
                          input_alias = name,
		          osnum = mod_osnum,
                          input_string = &input_variable);
      
      if (!(status & 1))
      {
        printf ( "Error in createing variable\n");
        om$report_error ( sts = status );
      }
      status = om$send ( msg = message DEso.DEinit ( msg, osnum, 0 ),
                         targetid = soo,
                         targetos = mod_osnum,
                         senderid = NULL_OBJID );
      if (!(status & 1))
      {
        printf ( "%s at %d: error in soo init\n", __FILE__, __LINE__ );
        om$report_error ( sts = status );
      }
      else
      {
        if (p_objid)
          *p_objid = soo;
        *msg = MSSUCC;
      }
    }
  }
  else
    *msg = MSSUCC;
  
  if (*msg == MSSUCC && p_objid)
    *p_objid = soo;

  return OM_S_SUCCESS;
}


DEchange_so ( msg, old_type, old_symbology, old_u1, old_u2, 
              old_window, old_md_env, type, symbology, u1, u2, 
              go, window, md_env, interference )
              long              *msg 
                                   /* the return code                   OUT */;
              int               old_type
                                   /* the type of the entry             IN  */;
              struct IGRdisplay *old_symbology
                                   /* the old symbology of the override IN  */;
              IGRdouble          old_u1, old_u2
                                   /* the old u parms                   IN  */;
              struct GRid       *old_window
                                   /* the old view of the override      IN  */;
              struct GRmd_env   *old_md_env
                                   /* the old context of the override   IN  */;
              int type                   /* the type of the entry       IN  */;
              struct IGRdisplay *symbology
                                   /* the new symbology                 IN  */;
              IGRdouble          u1, u2
                                   /* the new u parms                   IN  */;
              struct GRid       *go
                                   /* the object with the override      IN  */;
              struct GRid       *window
                                   /* the new view for the override     IN  */;
              struct GRmd_env   *md_env
                                   /* the new context of the override   IN  */;
              int               interference
                                   /* interference checking ?           IN  */;
/*
   This function changes an existing override.
*/
{
  uword mod_osnum;
  
  if ( !DEsos )
  {
     *msg = MSFAIL;
     return( OM_E_ABORT );
  }
  
  ex$get_cur_mod ( osnum = &mod_osnum );
  return om$send ( msg = message DEso.DEmodify ( msg, old_type, old_symbology, 
                                                  old_u1, old_u2, 
                                                  old_window, old_md_env, type,
                                                  symbology, u1, u2, 
                                                  go->objid, window, md_env, 
                                                  interference ),
                   senderid = NULL_OBJID,
                   targetid = DEsos [go->osnum],
                   targetos = mod_osnum );
}

%safe
static GRobjid DElast_soo = (GRobjid)-1;
static uword   DElast_osnum;
%endsafe

DEretrieve_so ( msg, p_type, symb, p_u1, p_u2, go, u, window, module )
                long              *msg   /* return status             OUT */;
                int               *p_type/* the type of the override  OUT */;
                struct IGRdisplay *symb  /* symbology of the override OUT */;
                IGRdouble         *p_u1,
                                  *p_u2  /* parms of the override     OUT */;
                struct GRid       *go    /* object for the override   IN  */;
                IGRdouble          u      /* u parms                   IN  */;
                struct GRid       *window/* window for the override   IN  */;
                struct GRmd_env   *module/* context of the override   IN  */;
/*
   This function retrieves a symbology override from the soo.
*/
{
  uword mod_osnum;
  
  if ( !DEsos )
  {
     *msg = MSFAIL;
     return( OM_E_ABORT );
  }
  
  ex$get_cur_mod ( osnum = &mod_osnum );
  DElast_soo = DEsos [go->osnum];
  DElast_osnum = mod_osnum;
  return om$send ( msg = message DEso.DEretrieve ( msg, p_type, symb, 
                                                   p_u1, p_u2, go->objid, u, 
                                                   window, module ),
                   senderid = NULL_OBJID,
                   targetid = DEsos [go->osnum],
                   targetos = mod_osnum );
}


DEnext_so ( msg, p_type, symb, p_u1, p_u2 )
            long              *msg   /* return status              OUT */;
            int               *p_type/* the type of the override   OUT */;
            struct IGRdisplay *symb  /* symbology of the override  OUT */;
            IGRdouble         *p_u1,
                              *p_u2  /* parms of the override      OUT */;
/*
   This function retrieves the next override (called after a retrieve).
*/
{
  return om$send ( msg = message DEso.DEnext ( msg, p_type, symb, p_u1, p_u2 ),
                   senderid = NULL_OBJID,
                   targetid = DElast_soo,
                   targetos = DElast_osnum );
}


DEcopy_soo ( msg, from_window, to_window )
             long        *msg         /* return status        OUT */;
             struct GRid *from_window /* window to copy from  IN  */;
             struct GRid *to_window   /* window to copy to    IN  */;
/*
   This function copies the override from one window (from) to another (to).
*/
{
  int   i;
  uword mod_osnum;

  if ( !DEsos )
  {
     *msg = MSFAIL;
     return( OM_E_ABORT );
  }
  
  /* the from and the to MUST be in the module */  
  ex$get_cur_mod ( osnum = &mod_osnum );
  if (from_window->osnum != mod_osnum || to_window->osnum != mod_osnum)
  {
    *msg = MSFAIL;
    return OM_E_ABORT;
  }

  /* copy each so table (for each object space) */
  for (i = 0, *msg = MSSUCC; (i < OM_Gw_maxOS) && (*msg == MSSUCC); i++)
    if (DEsos [i] != NULL_OBJID)
      om$send ( msg = message IGEwinsup.view_saved ( msg, to_window, NULL ),
                senderid = from_window->objid,
                targetid = DEsos [i],
                targetos = i );
  
  return OM_S_SUCCESS;
}


DEobjid_changed ( msg, old_id, new_id )
                  long        *msg        /* The returned status  OUT */;
                  struct GRid *old_id        /* The Old GRid      IN  */;
                  struct GRid *new_id        /* The New GRid      IN  */;
/*
   That function gets called when the objid of an object that has SO's is
   about (i.e. BEFORE) to change.
*/
{
  uword mod_osnum;

  if ( !DEsos )
  {
     /* no DEso objects => don't fail because tags */
     /* will take care of any problems             */
     *msg = MSSUCC;
     return( OM_S_SUCCESS );
  }

  /* the from and the to MUST be in the module */  
  ex$get_cur_mod ( osnum = &mod_osnum );
  
  return om$send ( msg = message DEso.DEobjid_changed ( msg, old_id, new_id ),
                   senderid = NULL_OBJID,
                   targetid = DEsos [old_id->osnum],
                   targetos = mod_osnum );
}
                  

end implementation DEso;
