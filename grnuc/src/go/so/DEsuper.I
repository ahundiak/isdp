class implementation DEso;

#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <tools.h>
#include <sys/types.h>
#include <sys/param.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "exmacros.h"
#include "gr.h"
#include "godef.h"
#include "DEso.h"
#include "grio.h"
#include "griodef.h"
#include "griomacros.h"
#include "DEglob.h"
#include "refdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

from GRcontext  import GRgetinstance;

/* Function to convert the channel from an relative ordered */
/* to an absolute ordered channel                           */


int som_convert_chan_rel_to_abs ( os, oid, p_chansel )
OMuword           os;
OM_S_OBJID        oid;
OM_p_CHANSELECT   p_chansel;
{
   int                sts;
   OM_p_CHANNEL_HDR  *pp_chan;
   OM_p_CHANNEL_DEFN  p_chandef;

   sts = om$get_channel ( osnum        = os,
                          objid        = oid,
                          p_chanselect = p_chansel,
                          pp_channel   = &pp_chan,
                          pp_chandef   = &p_chandef );
   if (!(1&sts)) return (sts);

   /*==============================*/
   /*  make sure channel has data  */
   /*==============================*/

   if (*pp_chan) {
      (*pp_chan)->flags &= (~OM_CH_relordered);
      (*pp_chan)->flags |= OM_CH_absordered;
   }

   return (OM_S_SUCCESS);
}


method wake_up ()
{
  DEsoe   *ptr, *last;
  short   action = 1, property = DEHAS_OVERRIDE;
  OMuword mod_os, ctx_os;
  int     status, size, i;
  unsigned int  chan_count;
  short   flag;
  long    msg;
  struct GRIOvar_def var;
  char    name[MAXPATHLEN],
          tmp_name[MAXPATHLEN];
  IGRshort mx_type;
  IGRmatrix matrix;
  struct GRid ctx_id;
  char   objname[DI_PATH_MAX], new_name[DI_PATH_MAX], *new_objname;
  int    sts;

/* needed for conversion code */
  union
  {
    char	c[2];
    short	s;
  } x, y;

  

  /* if this space is not the module: NOOP */
  ex$get_cur_mod ( osnum = &mod_os );
  if (mod_os != OM_Gw_current_OS)
    return OM_S_SUCCESS;
  
  _DEinit ();

  strcpy ( name, "soo_" );

  if (me->used == 0)
    /* I am empty (creation) -> return */
    return OM_S_SUCCESS;

  if (me->to_contexts)
  {
    struct GRmd_env md_env;

    /* I am the soo of a reference file */

    /* Change the channel to a absolutly ordered channel */
    /* KING OF ALL KLUDGES  SS */
    som_convert_chan_rel_to_abs ( mod_os, my_id, &DEso_to_contexts_chanselect );

    om$get_channel_count( osnum = mod_os,
                          objid = my_id,
                          p_chanselect = &DEso_to_contexts_chanselect,
                          count = &chan_count );

    me->osnum = 65535;
    for ( i = 0; i < chan_count; i++)
    {
       om$send ( msg = message GRcontext.GRgetinstance ( &msg, &mx_type, 
                                                         matrix, &ctx_os, 
                                                         &flag, &ctx_id ),
                 p_chanselect = &DEso_to_contexts_chanselect,
                 from = i,
                 to = i );
       if( flag & GRACTIVATED_CONTEXT )
       { 
          me->osnum = ctx_os;
          break;
       }
    }
          

    /*  8/17/95----  Mike Lanier
     *     I added the call to Root.delete for TR 119524667.   For some reason, this
     *  object would not initialize properly (I believe this because me->osnum is still
     *  65535.)  The original code simply left the object lying around, but this prevented
     *  PDD from attaching overrides to objects in that object space.  I figure, since 
     *  we not able to use the information in this object anyway, why not just delete it
     *  from the object space and let a clean on get created when needed.
     */

    if (me->osnum == 65535)
      /* the space is not active -> bye, bye */
      return om$send ( msg = message Root.delete ( 0 ), targetid = my_id );
      /*return OM_S_SUCCESS;*/

    status = om$os_number_to_name ( osnum = me->osnum, osname = tmp_name );
    if (status & 1)
    {
      /* om$os_number_to_name may return a full path name for the osname.
         This will put only the osname into name[4].
       */
      DEfind_refname (tmp_name, name);

      /* If the soo name and the ref file name are different then fix it */

      di$untranslate( objname = objname, osnum = mod_os, objid = my_id );
      new_objname = strrchr( objname,':');
      if ( strcmp( name, new_objname + 1 ))
      {
         strcpy( new_name, objname );
         new_objname = strrchr( new_name,':');
         strcpy( new_objname + 1, name );
         sts = di$rename( oldname = objname,
                    newname = new_name );
      }
    }
  }
  else {
    /* I am relative to the module */
    me->osnum = OM_Gw_current_OS;
    strcpy ( &name [4], "master" );
  }
  DEsos[me->osnum] = my_id;

  strcat (name, "_5535");
  status = co$cvtvar(msg = &msg,
                    alias = name,
                    var = &var);
  if (msg == MSFAIL) {
    var.type = GRIO_VAR_STRING;
    strcpy (var.contents.string, "");
    status = co$addvar(msg = &msg,
                       input_alias = name,
                       input_string = &var);
    if (!(status & 1))
      {
        printf ( "Error in adding variable\n");
        om$report_error ( sts = status );
      }
   size = om$dimension_of ( varray = me->soo );
   status = om$send ( msg = message DEso.DEchange_size
                           ( &msg, size),
                       targetid = my_id );
    if (!(status & 1)) return status;
  }
    
  /* make sure that the properties of each g.o. has DEHAS_OVERRIDE */
  last = &me->soo [om$dimension_of ( varray = me->soo )];
  ptr = &me->soo [0];
  for (status = OM_S_SUCCESS; ptr != last; ptr++)
    if (ptr->type != DE_DELETED && ptr->type != DE_EMPTY)
    {
      /* make sure the object is still here */
      if (me->to_contexts)
      {
        /* we convert the tag */
        status = om$tag_to_objid ( osnum = me->osnum,
                                   tag = ptr->objid,
                                   p_objid = &ptr->objid );
        if (status != OM_S_SUCCESS)
        {
          /* we must delete this entry */
          ptr->type = DE_DELETED;
          me->used--;
        }
      }
      
      if (status == OM_S_SUCCESS)
        status = om$send ( msg = message GRgraphics.GRchgprops ( &msg, &action,
                                                                 &property ),
                           senderid = my_id,
                           targetid = ptr->objid,
                           targetos = me->osnum );

      /* Need to check the soo color field to make sure the color is in range */
      /* of 0-255.  This is a safeguard for files that may have been created  */
      /* on a Sun workstation prior to release 2.2 of EMS.  If color is out   */
      /* of range, switch the chars of the color field.                       */

      if (status == OM_S_SUCCESS)
      {
         if (ptr->osymb.color > 255)
         {
            if (ptr->osymb.color != 65534)
            {
            /* flip the characters of the short to take care of endieness */
            x.s = ptr->osymb.color;
            y.c[0] = x.c[1];
            y.c[1] = x.c[0];
            ptr->osymb.color = y.s;
            }
         }
      }
    }

  /* make sure we have enough room (25% of holes) */
  size = om$dimension_of ( varray = me->soo );
  if ((size < me->used * 1.25) || me->to_contexts)
  {
    int new_size = me->used * 1.25;

    if (new_size < DE_MINIMUM)
      new_size = DE_MINIMUM;
    status = om$send ( msg = message DEso.DEchange_size ( &msg, new_size ),
                       targetid = my_id );
    if (!(status & 1)) return status;
    if (msg != MSSUCC) return OM_S_SUCCESS;

    /* go through the table and set every entry's dirty bit to 1.
       this was put in specifically for files converted from 1.4 
     */
    for (i = 0; i < new_size; i++)
      me->soo [i].dirty = 1;
  }

  
  return OM_S_SUCCESS;
}


method super_construct ()
{
  OMuword mod_os;

  /* if this space is not the module: NOOP */
  ex$get_cur_mod ( osnum = &mod_os );
  if (mod_os != OM_Gw_current_OS)
  {
    printf ( "BUGCHECK: DEso constructed outside the module\n" );
    return OM_S_SUCCESS;
  }

  return OM_S_SUCCESS;
}


method global_class.sleep ( int type_sleep )
{
  long    status2, msg;
  int     status1, size, status;
  short   num_alias;
  OMuword mod_os;
  char    name[MAXPATHLEN],
          tmp_name[MAXPATHLEN];


  /* if this space is not the module: NOOP */
  ex$get_cur_mod ( osnum = &mod_os );
  if (mod_os != OM_Gw_current_OS)
    return OM_S_SUCCESS;

  /* If I am empty, I want to go away */
  if (me->used == 0){
    strcpy ( name, "soo_" );
    if (me->osnum == OM_Gw_current_OS) {
       strcpy ( &name [4], "master" );
    }
    else {
      status = om$os_number_to_name ( osnum = me->osnum, osname = tmp_name );
      if (status & 1)
      {
        /* om$os_number_to_name may return a full path name for the osname.
           This will put only the osname into name[4].
        */
        DEfind_refname(tmp_name, name);
      }
    }
    strcat (name, "_5535");
    num_alias = (short)1;
    /* DElete the variable fron GRvar object. */
    status = co$delvar(msg = &msg,
                       num_alias = &num_alias,
                       input_alias = name);
    return om$send ( msg = message Root.delete ( 0 ), targetid = my_id );
  }

  /* we may need to shrink the table */
  size = om$dimension_of ( varray = me->soo );
  if ((me->used < size * 0.6) && (size != DE_MINIMUM))
  {
    int new_size = me->used * 1.25 + 1;

    status1 = om$send ( msg = message DEso.DEchange_size ( &status2, new_size ),
                        targetid = my_id );
    if (!(status1 & 1)) return status1;
    if (status2 != MSSUCC) return OM_S_SUCCESS;
  }

  /* if I am relative to a reference file, I need to convert objids into tags */
  if (OM_Gw_current_OS != me->osnum)
  {
    DEsoe *ptr, *last;

    /* if the space was not active: bye, bye */
    if (me->osnum == 65535)
      return OM_S_SUCCESS;

    last = &me->soo [om$dimension_of ( varray = me->soo )];
    ptr = &me->soo [0];
    for (; ptr != last; ptr++)
      if (ptr->type != DE_DELETED && ptr->type != DE_EMPTY)
        om$objid_to_tag ( osnum = me->osnum,
                          objid = ptr->objid,
                          p_tag = (OMuint *)&ptr->objid );
  }
  
  /* I am history */
  DEsos [me->osnum] = NULL_OBJID;
  
  return OM_S_SUCCESS;
}

end implementation DEso;
