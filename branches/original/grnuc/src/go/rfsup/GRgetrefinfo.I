/*

  Name

     GRgetrefinfo

  Abstract

     This function is used to get the reference file parameters.

  Arguments

     IGRlong      *msg          (O) completion code
     struct GRid *ref_grid      (I) GRid of the reference file
     IGRchar *ref_name          (I) attachment name
     struct GRmd_env *mod_env   (I) module environment
     IGRulong *ref_properties   (O) reference file properties defined
                                    in refdef.h
     IGRboolean *updatable      (O) updatable flag, if TRUE attachment
                                    will be updatable else read-only
     IGRchar *filename          (O) filename
     IGRchar *scale             (O) scale
     IGRchar *saved_view        (O) saved view name
     GRspacenum *ref_osnum      (O) reference file object space number

  Return Values

    -MSSUCC if successful
    -MSFAIL if failure

  History

     Gang     07/20/93    Creation date.

*/

class implementation GRreffile;

#include "stdio.h"
#include "coimport.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "msmacros.h"
#include "exmacros.h"
#include "grmessage.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grimport.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "refdef.h"
#include "ref.h"
#include "refmacros.h"


IGRint GRgetrefinfo(msg,
                    ref_grid,
                    ref_name,
                    mod_env,
                    ref_properties,
                    updatable,
                    filename,
                    scale,
                    saved_view,
                    ref_osnum)
IGRlong *msg;
struct GRid *ref_grid;
IGRchar *ref_name;
struct GRmd_env *mod_env;
IGRulong *ref_properties;
IGRboolean *updatable;
IGRchar *filename;
IGRchar *scale;
IGRchar *saved_view;
GRspacenum *ref_osnum;
{
    int		            sts;
    struct GRmd_env         cur_mod;
    struct GRid             ref_id;
    IGRint                  which_error,i;
    IGRboolean              pass;
    IGRint                  nbytes_in_buff,nbytes_trans;
    IGRchar                 ref_type[40];
    IGRchar                 pathname[DI_PATH_MAX];
    struct GRinquire_list   requestes[11];
    struct GRref_instance_data ref_instance;

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    pass = FALSE;
    which_error = 0;

    if(mod_env == NULL)
     {
        /* get the current module environment */

        nbytes_in_buff = sizeof(struct GRmd_env);
        sts = gr$get_module_env(msg = msg,
                                sizbuf = &nbytes_in_buff,
                                buffer = &cur_mod,
                                nret = &nbytes_trans);
        if(!(*msg & sts & 1))
         {
           goto quit;
         }
     }
    else
     {
        cur_mod = *mod_env;
     }

    if(ref_grid == NULL)
     {
        if(ref_name == NULL)
         {
           *msg = MSFAIL;
            sts = OM_E_ABORT;
            goto quit;
         }

       di$give_pathname(osnum = cur_mod.md_id.osnum,
                        pathname = pathname);

       strcat(pathname,":ref:refnames:");

       sts = di$translate(objname = ref_name,
                          path = pathname,
                          p_objid = &ref_id.objid,
                          p_osnum = &ref_id.osnum);
       if(sts != DIR_S_SUCCESS)
        {
           *msg = MSFAIL;
           goto quit;
        }
     }
    else
     {
       ref_id.objid = ref_grid->objid;
       ref_id.osnum = ref_grid->osnum;
     }

    i = 0;
    if(ref_properties)
     {
        requestes[i].var = FILE_PROPERTIES;
        requestes[i].num_requested = sizeof(unsigned long);
        requestes[i].var_ptr = (char *)ref_properties;
        i = i +1;
     }

    if(updatable)
     {
        requestes[i].var = REFERENCE_TYPE;
        requestes[i].num_requested = 40;
        requestes[i].var_ptr = ref_type;
        i = i +1;
     }
     
    if(filename)
     {
        requestes[i].var = REFERENCE_FILE_NAME;
        requestes[i].num_requested = DI_PATH_MAX;
        requestes[i].var_ptr = filename;
        i = i +1;
     }

   if(scale)
    {
        requestes[i].var = REFERENCE_INSTANCE_DATA;
        requestes[i].num_requested = sizeof(struct GRref_instance_data);
        requestes[i].var_ptr = (char *)&ref_instance;
        i = i +1;
    }

  if(saved_view)
   {
        requestes[i].var = SAVED_VIEW_NAME;
        requestes[i].num_requested = 40;
        requestes[i].var_ptr = saved_view;
        i = i +1;
   }

   requestes[i].var = END_REPORT_REQUEST;
   requestes[i].num_requested = 0;
   requestes[i].var_ptr = NULL;

   sts = om$send(msg = message GRreffile.GRinquireref(msg,&cur_mod,
                                                      requestes,
                                                      &which_error,
                                                      &pass,NULL),
                 senderid = NULL_OBJID,
                 targetid = ref_id.objid,
                 targetos = ref_id.osnum);
   
  if(!(*msg & sts & 1))
   {
       goto quit;
   }

  if(updatable)
   {
     if(!strcmp(ref_type,"write"))
       *updatable = TRUE;
     else
       *updatable = FALSE;
   }

  if(scale)
   {
      scale = ref_instance.scale;
   }

  if(ref_osnum)
   {
       sts = om$send(msg = message GRreffile.GRgetosnum(msg,ref_osnum),
                     senderid = NULL_OBJID,
                     targetid = ref_id.objid,
                     targetos = ref_id.osnum);
   }


quit:
  return sts;
}

end implementation GRreffile;


