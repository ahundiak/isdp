class implementation Root;

#include <stdio.h>
#include "OMindex.h"
#include "OMmacros.h"
#include "exfi.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "ems_m_inc.h"
#include "go.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "growner.h"
#include "grgsmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "igetypedef.h"

#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"

#define RTR_MAXDOUBLE MAXDOUBLE+10

from OMindex import translate;
from GRmodule import GRmdremove;
from GRgraphics import GRaddwrng;


EFverrtree()
{
  IGRlong           OM_stat, EMmsg;
  IGRint            ii, jj, dup_count, cnt;
  IGRint            array_size;
  IGRint            ret, show_bad, remove, found_bad;
  OM_S_CHANSELECT   primary;
  OM_S_KEY_DESC     rtree_key_test;
  DB_3D_DBL_BOX     rtrange_test;
  GRrange           rem_range;
  struct GRmd_env   md_env;
  OM_S_OBJARRAY     *obj_array;
  OM_S_OBJID        *arr, dup_objid;
  extern OMuword    OPP_GRvg_class_id, OPP_EMScompsurf_class_id, 
                    OPP_EMSboundary_class_id, OPP_EMSdatpln_class_id,
                    OPP_EMSgradata_class_id;
  OMuword           osnum;
  char              cname[OM_K_MAXCLASS_LEN];


  gr$get_display_env(buffer = &md_env);

  EMmake_chanselect(module_primary, &primary);
 
  /*First get the number of ids in the tree*/
  obj_array = (OM_S_OBJARRAY *) malloc (sizeof(OM_S_OBJARRAY));
  if (obj_array == 0) {EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  obj_array->size = sizeof(OM_S_OBJARRAY);
  obj_array->count = 0;
  obj_array->tree_type = KEY_3D_DBL;

  rtrange_test.xmin = -(RTR_MAXDOUBLE);
  rtrange_test.ymin = -(RTR_MAXDOUBLE);
  rtrange_test.zmin = -(RTR_MAXDOUBLE);

  rtrange_test.xmax = (RTR_MAXDOUBLE);
  rtrange_test.ymax = (RTR_MAXDOUBLE);
  rtrange_test.zmax = (RTR_MAXDOUBLE);

  rtree_key_test.type = KEY_3D_DBL;
  rtree_key_test.key.p_3ddbl = &rtrange_test;

  osnum = md_env.md_id.osnum;

  OM_stat = om$send(msg = message OMindex.translate(obj_array,
                          &rtree_key_test, NULL, NULL, &ret),
                    senderid = md_env.md_id.objid,
                    targetos = osnum,
                    p_chanselect = &primary);
  if (!(1 & OM_stat)) {EMmsg = EMS_E_OMerror; goto wrapup;}

  fprintf(stderr,"%d total objids found in rtree\n",obj_array->count);
    
  /*Allocate memory for ids*/
  array_size = (obj_array->count * sizeof(OM_S_OBJID)) + sizeof(OM_S_OBJARRAY);

  free(obj_array); /*free old obj array*/

  obj_array = (OM_S_OBJARRAY *) malloc(array_size);
  if (obj_array == 0) {EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

  obj_array->size = array_size;
  obj_array->count = 0;

  /*Now get objids*/
  OM_stat = om$send(msg = message OMindex.translate(obj_array,
                          &rtree_key_test, NULL, NULL, &ret),
                    senderid = md_env.md_id.objid,
                    targetos = osnum,
                    p_chanselect = &primary);
  if (!(1 & OM_stat)) {EMmsg = EMS_E_OMerror; goto wrapup;}

  arr = obj_array->array;
  cnt = obj_array->count;

  show_bad = 0;

  rem_range[0] = -(RTR_MAXDOUBLE);
  rem_range[1] = -(RTR_MAXDOUBLE);
  rem_range[2] = -(RTR_MAXDOUBLE);
  rem_range[3] = (RTR_MAXDOUBLE);
  rem_range[4] = (RTR_MAXDOUBLE);
  rem_range[5] = (RTR_MAXDOUBLE);

  remove = 0;

  found_bad = 0;

  fprintf(stderr,"invalids ids check...\n");  
  for(ii=0; ii<cnt; ii=ii+1)
  {
    if (om$is_objid_valid(objid = arr[ii], osnum = osnum) != OM_S_SUCCESS)
    {
      if (OM_Gf_verbose_warning)
        fprintf(stderr,"ERROR- %d in rtree but does not exist\n", arr[ii]);
      remove = 1;
      show_bad = 0;
    }      
    else
    {
      if (!EFisAncestryValid(&EMmsg, arr[ii], osnum, OPP_GRvg_class_id, 0))
      {
        show_bad = 1;

        if (EFisAncestryValid(&EMmsg, arr[ii], osnum, 
                              OPP_EMSboundary_class_id, 0))
        {
          if (OM_Gf_verbose_warning)
            fprintf(stderr,"ERROR- %d in rtree but is a EMSboundary class\n",
                    arr[ii]); 
          remove = 1;
        }                      
        else if (EFisAncestryValid(&EMmsg, arr[ii], osnum, 
                                   OPP_EMSdatpln_class_id, 0))
        {
          if (OM_Gf_verbose_warning)
            printf("ERROR- %d in rtree but is a EMSdatpln class\n", arr[ii]);
          remove = 1;
        }                      
        else if (EFisAncestryValid(&EMmsg, arr[ii], osnum, 
                                   OPP_EMSgradata_class_id, 0))
        {
          if (OM_Gf_verbose_warning)
            printf("ERROR- %d in rtree but is a EMSgradata class\n", arr[ii]);
          remove = 1;
        }                      
        else if (OM_Gf_verbose_warning)
          fprintf(stderr,"ERROR- %d in rtree but isn't a GRvg class\n",
                  arr[ii]); 
      }
      else
      {
        if (EFisAncestryValid(&EMmsg, arr[ii], osnum, 
                              OPP_EMScompsurf_class_id, 0))
        {
          if (OM_Gf_verbose_warning)
            fprintf(stderr,"ERROR- %d in rtree but is a EMScompsurf class\n",
                    arr[ii]); 
          show_bad = 1;
          remove = 1;
        }        
      }
    }

    if (show_bad)
    {
      if (OM_Gf_verbose_warning)
      {
        om$get_classname(objid = arr[ii],
                         osnum = osnum,
                         classname = cname);
        fprintf(stderr,"    ** class of bad id is %s **\n", cname);
      }
      show_bad = 0;
      found_bad = 1;
    }

    if (remove)
    {
      if (!OM_Gf_verbose_warning) fprintf(stderr, ".");
      OM_stat = om$send(msg = message GRmodule.GRmdremove(&EMmsg,
                              rem_range, &arr[ii]),
                        senderid = NULL_OBJID,
                        targetid = md_env.md_id.objid,
                        targetos = osnum);
      if (!(1 & OM_stat & EMmsg))
      {
        if (OM_Gf_verbose_warning)
        {
          fprintf(stderr,
                  "       ******ERROR- %d failed remove from rtree****\n", 
                  arr[ii]);
          EFprintcode(0, OM_stat);        
          EFprintcode(0, EMmsg);
        }
      }
      else 
      {
        if (OM_Gf_verbose_warning)
          fprintf(stderr,"       *****%d has been removed from rtree****\n", 
                 arr[ii]);
      }
      arr[ii] = NULL_OBJID;
      remove = 0;
      found_bad = 1;
    }
  }

  if (found_bad)
  {
    fprintf(stderr, "\ninvalid ids have been removed\n");
    found_bad = 0;
  }
  else
    fprintf(stderr, "no invalid ids were found\n");  

  fprintf(stderr,"invalids ids check finished.\n\n");

  fprintf(stderr,"duplicates check...\n");

  for(ii=0; ii<cnt; ii=ii+1)
  {
    if (arr[ii] != NULL_OBJID)
    {
      dup_count = 0;
      for(jj=0; jj<cnt; jj=jj+1)
      {
        if (jj != ii && arr[ii] == arr[jj])
        {
          dup_count = dup_count + 1;
          arr[jj] = NULL_OBJID;
        }
      }
      if (dup_count)
      {
        dup_count = dup_count + 1;

        found_bad = 1;

        if (OM_Gf_verbose_warning)
        {
          om$get_classname(objid = arr[ii],
                           osnum = osnum,
                           classname = cname);
          fprintf(stderr,"%d (class %s) found %d times\n", arr[ii], cname, 
                  dup_count); 
        }
        else fprintf(stderr,".");

        dup_objid = arr[ii];

        /*Remove all occurences of dup_objid*/
        if (OM_Gf_verbose_warning)
          fprintf(stderr,"Removing duplicate entries\n");

        for(jj=0; jj<dup_count; jj=jj+1)
        {
          OM_stat = om$send(msg = message GRmodule.GRmdremove(&EMmsg,
                                  rem_range, &dup_objid),
                            senderid = NULL_OBJID,
                            targetid = md_env.md_id.objid,
                            targetos = osnum);
          if (!(1 & OM_stat & EMmsg))
          {
            if (OM_Gf_verbose_warning)
            {
              fprintf(stderr,
                    "      ******ERROR- (%d) could nor remove duplicate***\n", 
                    dup_objid);
              EFprintcode(0, OM_stat);        
              EFprintcode(0, EMmsg);
            }
          }
        }

        if (!EFisAncestryValid(&EMmsg, dup_objid, osnum,
                               OPP_EMSdatpln_class_id, 0)) 
        {
          /*Add back dub_objid*/
          OM_stat = om$send(msg = message GRgraphics.GRaddwrng(&EMmsg,
                                  &md_env), 
                            senderid = NULL_OBJID,
                            targetid = dup_objid,
                            targetos = osnum);
          if (!(1 & OM_stat & EMmsg))
          {
            if (OM_Gf_verbose_warning)
            {
              fprintf(stderr,
                    "     ******ERROR- (%d) could not be added back***\n", 
                    dup_objid);
              EFprintcode(0, OM_stat);        
              EFprintcode(0, EMmsg);
            }
          }
        }
        dup_count = 0;
      }
    }
  }

  if (found_bad)
    fprintf(stderr, "\nduplicate ids have been removed\n");
  else
    fprintf(stderr, "no duplicate ids were found\n");  

  fprintf(stderr,"duplicates check finished.\n\n");

  free(obj_array);
 
  return(1);

  wrapup:
   fprintf(stderr, "ERROR- cleanup failed\n");
   EFprintcode(0, OM_stat);
   EFprintcode(0, EMmsg);
   return(1);
}
end implementation Root;
