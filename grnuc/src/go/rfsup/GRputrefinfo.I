/*

  Name

     GRputrefinfo

  Abstract

     This function is used to change the reference file attachment by
     putting the new reference file parameters.

  Arguments

     IGRlong      *msg          (O) completion code
     struct GRid *ref_grid      (I) GRid of the reference file
     IGRchar *ref_name          (I) attachment name
     struct GRmd_env *mod_env   (I) module environment
     IGRulong ref_properties    (I) reference file properties defined
                                    in refdef.h
     IGRchar *filename          (I) filename
     IGRchar *attachment_name   (I) attachment name
     IGRchar *scale             (I) scale

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
#include "refmacros.h"


IGRint GRputrefinfo(msg,
                    ref_grid,
                    ref_name,
                    mod_env,
                    ref_properties,
                    filename,
                    attachment_name,
                    scale)
IGRlong *msg;
struct GRid *ref_grid;
IGRchar *ref_name;
struct GRmd_env *mod_env;
IGRulong ref_properties;
IGRchar *filename;
IGRchar *attachment_name;
IGRchar *scale;
{
    int		            sts;
    struct GRmd_env         cur_mod;
    IGRshort                action;
    IGRlong                 nbytes_in_buff,nbytes_trans;
    struct GRid             ref_id;
    IGRint                  i;
    IGRulong                old_properties;
    IGRchar                 old_filename[DI_PATH_MAX];
    IGRchar                 new_filename[DI_PATH_MAX];
    IGRchar                 old_name[DI_PATH_MAX];
    IGRchar                 attach_name[DI_PATH_MAX];
    IGRchar                 pathname[DI_PATH_MAX];
    IGRint                  which_error;
    IGRboolean              pass;
    enum GRdpmode           disp_mode;
    struct GRinquire_list   requests[4];

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    old_properties = 0;
    which_error = 0;
    pass = FALSE;
    new_filename[0] = NULL;
    action = 2;
    attach_name[0] = NULL;

    /* validate the input parameters */
    if((filename == NULL) && (attachment_name == NULL) &&
       (scale == NULL) && (ref_properties == 0))
     {
       sts = OM_E_ABORT;
       *msg = MSFAIL;
       goto quit;
     }

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
     requests[i].var = REFERENCE_FILE_NAME;
     requests[i].num_requested = DI_PATH_MAX;
     requests[i].var_ptr = old_filename;

     i = i+1;
     requests[i].var = FILE_PROPERTIES;
     requests[i].num_requested = sizeof(unsigned long);
     requests[i].var_ptr = (char *)&old_properties;

     i = i + 1;
     requests[i].var = REFERENCE_NAME;
     requests[i].num_requested = DI_PATH_MAX;
     requests[i].var_ptr = old_name;

     i = i+1;
     requests[i].var = END_REPORT_REQUEST;
     requests[i].num_requested = 0;
     requests[i].var_ptr = NULL;

     sts = om$send(msg = message GRreffile.GRinquireref(msg,
                                                        &cur_mod,
                                                        requests,
                                                        &which_error,
                                                        &pass,NULL),
                   senderid = NULL_OBJID,
                   targetid = ref_id.objid,
                   targetos = ref_id.osnum);
    if(!(*msg & sts &1))
     {
        goto quit;
     }

    if(filename)
     {
        GRfindrefpath(filename,new_filename);
        if(access(new_filename,0) == -1)
         {
            sts = OM_E_ABORT;
            *msg = MSFAIL;
            goto quit;
         }
     }
    else
     {
        strcpy(new_filename,old_filename);
     }

     if(attachment_name)
      {
        strcpy(attach_name,attachment_name);
      }
     else
      {
        if(!filename)
          strcpy(attach_name,old_name);
      }

     disp_mode = GRbehe;
     sts = om$send( msg = message GRgraphics.GRdisplay(msg,
                                             &cur_mod.md_env.matrix_type,
                                             cur_mod.md_env.matrix,
                                             &disp_mode,
                                             &cur_mod.md_id),
                    senderid = NULL_OBJID,
                    targetid = ref_id.objid,
                    targetos = ref_id.osnum);
     
     if(ref_properties != 0)
      {
        if(ref_properties & GRRF_BACKGROUND)
           old_properties = old_properties | GRRF_BACKGROUND;
        else
           old_properties = old_properties & ~GRRF_BACKGROUND;
        if(ref_properties & GRRF_UNLOADED)
           old_properties = old_properties | GRRF_UNLOADED;
        else
           old_properties = old_properties & ~GRRF_UNLOADED;

        if((old_properties & GRRF_SHRINK_WRAP) &&
           !(ref_properties & GRRF_SHRINK_WRAP))
         {
            /* remove the reference file from the R-tree */
            sts = om$send(msg = message GRvg.GRremwrng(msg, &cur_mod),
                          senderid = NULL_OBJID,
                          targetid = ref_id.objid,
                          targetos = ref_id.osnum);

            old_properties = old_properties & ~GRRF_SHRINK_WRAP;

            sts = om$send(msg = message GRreffile.GRchgrfprops(msg,
                                                  &action,&old_properties),
                          senderid = NULL_OBJID,
                          targetid = ref_id.objid,
                          targetos = ref_id.osnum);

            /* add the reference file to the R-tree */
            sts = om$send(msg = message GRvg.GRaddwrng(msg, &cur_mod),
                          senderid = NULL_OBJID,
                          targetid = ref_id.objid,
                          targetos = ref_id.osnum);
        }
       else
         if(!(old_properties & GRRF_SHRINK_WRAP) &&
             (ref_properties & GRRF_SHRINK_WRAP))
          {
              old_properties = old_properties | GRRF_SHRINK_WRAP;

              sts = om$send(msg = message GRreffile.GRchgrfprops(msg,
                                                   &action,&old_properties),
                            senderid = NULL_OBJID,
                            targetid = ref_id.objid,
                            targetos = ref_id.osnum);

          }
        else
          {
              sts = om$send(msg = message GRreffile.GRchgrfprops(msg,
                                                   &action,&old_properties),
                            senderid = NULL_OBJID,
                            targetid = ref_id.objid,
                            targetos = ref_id.osnum);
          }
     }

    /* change the attachment */
    if(filename || attachment_name)
     {
        sts = om$send(msg = message GRreffile.GRchgfilename(msg,new_filename,
                                                            attach_name),
                      senderid = NULL_OBJID,
                      targetid = ref_id.objid,
                      targetos = ref_id.osnum);
     }

   if(scale)
    {
       sts = om$send(msg = message GRreffile.GRputscale(msg,scale),
                     senderid = NULL_OBJID,
                     targetid = ref_id.objid,
                     targetos = ref_id.osnum);
    }

   /* display the reference file */
   disp_mode = GRbd;

   sts = om$send(msg = message GRgraphics.GRdisplay(msg,
                                                    &cur_mod.md_env.matrix_type,
                                                    cur_mod.md_env.matrix,
                                                    &disp_mode,
                                                    &cur_mod.md_id),
                 senderid = NULL_OBJID,
                 targetid = ref_id.objid,
                 targetos = ref_id.osnum);

quit:
  return sts;

}

end implementation GRreffile;
