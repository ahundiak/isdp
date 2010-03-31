/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
History
    DLB 04/23/91    If tag to objid results in NULL_OBJID return EMS_I_NotFound
    DLB 09/04/90    Creation.
*/    

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "OMmacros.h"

#if DEBUG
#include "stdio.h"
#endif

void EFcvrt_to_from_tag(EMmsg, num_to_cvrt, objid, tag, to_tag, osnum)
IGRint     *EMmsg;
IGRint     num_to_cvrt;
GRobjid    *objid;
OMuint     *tag;
IGRboolean to_tag;
OMuword    osnum;
{
  IGRint        ii, OM_stat=OM_S_SUCCESS;
  extern OMuint OM_Gf_verbose_warning;
  IGRboolean    no_tag=FALSE, no_objid=FALSE;
  IGRlong       EFcheck_for_tag();


  *EMmsg = EMS_S_Success;
  
  for(ii=0; ii<num_to_cvrt; ii++)
  {
    if (to_tag)
    {
#     if DEBUG
        if (OM_Gf_verbose_warning)
          fprintf(stderr, "objid is %d      ", objid[ii]);
#     endif

      OM_stat = om$objid_to_tag(objid = objid[ii],
                                p_tag = &tag[ii],
                                osnum = osnum);
      if (OM_stat == OM_W_NOTTAGGED)
      {
        tag[ii] = EMS_NO_TAG;
        no_tag = TRUE;
        OM_stat = OM_S_SUCCESS;
      }

#     if DEBUG
        if (OM_Gf_verbose_warning)
          fprintf(stderr, "tag is %d\n", tag[ii]);
#     endif
    }                                
    else
    {
      OMuint loc_tag;

#     if DEBUG
        if (OM_Gf_verbose_warning)
          fprintf(stderr, "tag is %d        ", tag[ii]);
#     endif

      loc_tag = tag[ii];
      objid[ii] = NULL_OBJID;

      if (EFcheck_for_tag(loc_tag) == EMS_S_Success)
      {
        OM_stat = om$tag_to_objid(tag = loc_tag,
                                  p_objid = &objid[ii],
                                  osnum = osnum);
        if (1 & OM_stat)
        {
#         if DEBUG
            if (OM_Gf_verbose_warning)
              fprintf(stderr, "objid is %d\n", objid[ii]);
#         endif
        }
        else if (OM_Gf_verbose_warning)
        {
          no_objid = TRUE;
#         if DEBUG
            fprintf(stderr, "objid is -1\n");
            fprintf(stderr, "WARNING: TAG (%d) HAS NO OBJID\n", loc_tag); 
#         endif
          OM_stat = OM_S_SUCCESS;
        }
      }
      else if (OM_Gf_verbose_warning)
      {
        no_objid = TRUE;
#       if DEBUG
          fprintf(stderr, "objid is -1\n");
          fprintf(stderr, "WARNING: TAG (%d) IS IN MISMATCH LIST\n", loc_tag);
#       endif
      }
    }
  }                                                                
 
  OM_stat = OM_S_SUCCESS;

  if (no_tag) *EMmsg = EMS_I_InvalidCase;
  if (no_objid) *EMmsg = EMS_I_NotFound;
  EMWRAPUP(*EMmsg, OM_stat, "EFcvrt_to_from_tag")
  return;
}
