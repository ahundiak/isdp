class implementation Root;

#include "msmacros.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dp.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#define ALLCLEAR	0
#define ALLSET		1
#define CLASSCLEAR      2
#define CLASSSET        3

LClocate_eligible(classname,setbit)
IGRchar *classname;
IGRboolean setbit;
{
  struct var_list vlist[2];
  IGRint i, count,row;
  struct GRelclass_f *claslist = NULL;
  IGRlong sts;
  IGRchar buf[128];
  IGRint depth;
  IGRboolean string_match;

    string_match = TRUE;
    vlist[0].var = DPB_NUMBER_CLASSES;
    vlist[0].var_ptr = (IGRchar *)&count;
    vlist[1].var = END_PARAM;

    gr$set_inq (msg = &sts, var_list = vlist);

    /* Allocate Memory for the data */

    claslist = (struct GRelclass_f *)malloc(count * sizeof(struct GRelclass_f));
    vlist[0].var = DPB_GET_CLASSES;
    vlist[0].var_ptr = (IGRchar *)claslist;
    vlist[1].var = END_PARAM;
    gr$set_inq (msg = &sts, var_list = vlist);
    switch(setbit)
    {
      case CLASSCLEAR:
      {
         string_match = FALSE;
         for(i = 0; i < count; i++)
         {
           buf[0] = NULL;
           sts = ex$message (msgname = claslist[i].ascii_key, buff = buf);
           if(strcmp(buf,classname) == 0)
           {
            claslist[i].properties &= ~DPB_LOCATABLE;
            string_match = TRUE;
            break;
           }
         }
        /* toggle any sub-categories to match the lead category */
        row = i;
        depth = claslist[i].depth;
        row++;
        while ((row < count) && (claslist[row].depth > depth))
        {
            claslist[row].properties &= ~DPB_LOCATABLE;
            row++;
        }
         break;
      }
      case CLASSSET:
      {
        string_match = FALSE;
        for(i = 0; i < count; i++)
        {
           buf[0] = NULL;
           sts = ex$message (msgname = claslist[i].ascii_key, buff = buf);
           if(strcmp(buf,classname) == 0)
           {
             claslist[i].properties |= DPB_LOCATABLE;
             string_match = TRUE;
             break;
           }
        }
        row = i;
        depth = claslist[i].depth;
        if (depth) 
        {
            row--;
            while (row >= 0 && (claslist[row]).depth >= 0)
            {
                if (claslist[row].depth < depth)
                {
                    claslist[row].properties |= DPB_LOCATABLE;
                    depth--;
                }
                row--;
            }
        }
        /* toggle any sub-categories to match the lead category */
        row = i;
        depth = claslist[i].depth;
        row++;
        while ((row < count) && (claslist[row].depth > depth))
        {
            claslist[row].properties |= DPB_LOCATABLE;
            row++;
        }
         break;
      }
 
      case ALLCLEAR:
      {
         for(i = 0; i < count; i++)
         {
            claslist[i].properties &= ~DPB_LOCATABLE;
         }
         break;
      }
      case ALLSET:
      {
         for(i = 0; i < count; i++)
         {
            claslist[i].properties |= DPB_LOCATABLE;
         }
         break;
      }
      default:
        break;
    }

    vlist[0].var = DPB_SET_PROPERTIES;
    vlist[0].var_ptr = (IGRchar *)claslist;
    vlist[1].var = END_PARAM;
    gr$set_inq (msg = &sts, var_list = vlist, set_inq = DPB_SET);
    if(string_match)
      return OM_S_SUCCESS;
    else
      return FALSE;
}
end implementation Root;
