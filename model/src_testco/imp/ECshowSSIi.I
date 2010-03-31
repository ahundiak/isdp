/* ###################   APOGEE COMPILED   ################## */
class implementation ECshowSSI;

/*

HISTORY

22 May 1989 jBk Comment referring to GRlclocate changed to
                lc$locate.

13 Apr 1989 jBk Reworked to be a show boolean SSI command.

01/08/88 : rlw : Rewritten to conform to ems verison 1.1.

11/19/86 : jBk : Genesis.

*/

#include "EMS.h"
#include "EC_E.h"
#include "EC_S.h"
#include "EC_M.h"
#include "EC_I.h"
#include "EC_P.h"

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include "EMSmsgdef.h"
#define START           0
#define GET_ELEMENT     1
#define SHOWSSI         2

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(1 & sts_stupid & error_number))\
   {\
    *response = TERMINATE;\
    return(OM_E_ABORT);\
   }\
 }

#include "ems_m_inc.h"
#include "EMSlogic.h"
#include "EMScmacros.h"

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsfboolean_class_id, OPP_GRvg_class_id,
               OPP_EMSassoc_class_id;
extern OMuword OPP_GRtext_class_id;

from EMSsfboolean import EMgetSSIsize, EMgetSSI;

method execute(int *response; char *response_data; int pos)
{
 OMuword        r_classes[5], e_classes[5];
 OM_S_CLASSLIST rtree_classes, eligible_classes;
 IGRlong        sts, msg;
 IGRlong        object_was_located, display_flag;
 struct         GRid *id;
 struct         GRlc_locate attributes;
 struct         GRevent event, accept_event;
 IGRchar        locate_prompt[52], acc_prompt[52], relocate_prompt[52];
/*
 * Initialize
 */
 ex$message(msgnumb = EM_M_ShwBolnSSI);
 do
  {
    switch(ME.super_cmd->state)
    {
     case START:
      me->state = GET_ELEMENT;
      break;

     case GET_ELEMENT:
      display_flag = 
       ONE_WINDOW               |       /* Hilite in only one window */
       ELEM_HILIGHT             |       /* Hilite the whole element */
       NO_PROJ_ACCEPT_POINT     |       /* Don't project the accept point */
       ACC_REJ_CYCLE            |       /* Run through accept reject cycle */
       RELOCATE                 |       /* Relocate if none found */
       LC_REGULAR_HIGHLIGHT     |       /* Use regular hilite not 1/2 */
       LC_ERASE_ALL;                    /* Erase hilite on reject */
      attributes.properties = 
       LC_LC_ONLY               |       /* Locate locatable objects */
       LC_DP_ONLY               |       /* Locate displayable objects */
       IGN_MOD_BIT              |       /* Ignore modified and new props */
       LC_PLANAR_NON_PLANAR     |       /* Planar or not */
       LC_RW;                           /* This is a read operation */
      attributes.owner_action = 
       LC_STOP_ON_ASSOC | 
       LC_INTERMIDIATE | 
       LC_BOTTOM_UP |
       LC_ASSOCIATIVE |
       LC_EXTERN_CONSTRAINED |
       LC_RIGID_OWNER |
       LC_RIGID_COMP  |
       LC_FLEX_OWNER  |
       LC_FLEX_COMP   |
       LC_REF_OBJECTS |                 /* Objects in ref. files are O.K. */
       LC_NO_REF_HEADER;                /* No reference file headers */
      strcpy(attributes.classes, "EMSsfboolean");
      rtree_classes.w_count = 2;
      rtree_classes.w_flags = OM_CLST_subclass;
      rtree_classes.p_classes = &r_classes[0];
      r_classes[0] = OPP_EMSsubbs_class_id;
      r_classes[1] = OPP_GRtext_class_id;
      eligible_classes.w_count = 1;
      eligible_classes.w_flags = OM_CLST_subclass;
      eligible_classes.p_classes = &e_classes[0];
      e_classes[0] = OPP_EMSassoc_class_id;

      ex$message(msgnumb = EMS_P_IdntBoolean, buff = locate_prompt);
      ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
      ex$message(msgnumb = EMS_P_BooleanNotFound, buff = relocate_prompt);  
      sts = lc$locate(
        rc =                    &object_was_located,
        event1 =                &event,
        event2 =                &accept_event,
        mask1 =                 GRm_DATA | GRm_BACK_UP,
        mask2 =                 GRm_DATA,
        display_flag =          display_flag,
        unhilight_mode =        (enum GRdpmode ) GRhd,  /* Don't unhilite */
        locate_prompt =         locate_prompt,
        acc_prompt =            acc_prompt,
        relocate_prompt =       relocate_prompt,
        attributes =            &attributes,
        stack =                 &me->locate_stack,
        rtree_classes =         &rtree_classes,
        eligible_classes =      &eligible_classes);

      if (!object_was_located)
       {
        if (event.response == EX_BACK_UP)
         me->state = START;
        else
         return(OM_S_SUCCESS);
       }
      else
       me->state = SHOWSSI;
      break;

     case SHOWSSI:
      ex$message(msgnumb = EMS_P_ClearPromptField);
      ex$message(msgnumb = EMS_S_ClearStatusField); 
      dp$erase_hilite(msg = &msg);
      id = &accept_event.located_object[0].located_obj;

      { /* intentional block */

        union EMSssiSizeData size_data;
        union EMSssi_table *p_ssi = NULL;
        char name [OM_K_MAXCLASS_LEN];

        sts = om$get_classname(osnum = id->osnum,
                               objid = id->objid,
                               classname = name);
        ERROR(sts, EMS_S_Success, "get_classname")

        sts = om$send(msg = message EMSsfboolean.EMgetSSIsize(&msg, 
                            &size_data),
                      targetid = id->objid,
                      targetos = id->osnum);
        ERROR(sts, msg, "get ssi size")

        fprintf(stderr, "\n%d %d %s boolean ssi size\n",                      
                id->osnum, id->objid, name);             

        fprintf(stderr, "%d num_composites\n",
                size_data.bool_info.num_composites);

        fprintf(stderr, "%d num_surfaces_out\n",
                size_data.bool_info.num_surfaces_out);

        fprintf(stderr, "%d num_surfaces\n",
                size_data.bool_info.num_surfaces);

        fprintf(stderr, "%d num_regions_in\n",
                size_data.bool_info.num_regions_in);

        fprintf(stderr, "%d num_regions_out\n",
                size_data.bool_info.num_regions_out);

        sts = om$send(msg = message EMSsfboolean.EMgetSSI(&msg, &p_ssi),
                      targetid = id->objid,
                      targetos = id->osnum);
        ERROR(sts, msg, "get ssi")

        { /*intentional block*/
          char *p_name;
          int ii, jj, kk, ll;
          struct EMSboolssi_table *p_info;

          p_info = &p_ssi->bool_info;

          fprintf(stderr, "\n%d %d %s boolean ssi table\n",
                  id->osnum, id->objid, name);

          fprintf(stderr, "%d num_composites\n",
                  p_info->num_composites);

          for (ii = 0, kk = 0; ii < p_info->num_composites; ii++)
          {
            sts = om$get_classname(osnum = id->osnum,
                                   objid = p_info->composite_ids[ii],
                                   classname = name);
            if (1 & sts)
              p_name = name;
            else
              p_name = "OM_W_NAMENOTFOUND";

            fprintf(stderr, "%d composite_id %s %d num_surfaces_out\n",
                    p_info->composite_ids[ii],
                    p_name,
                    p_info->num_surfaces_out[ii]);

            for (jj = 0; jj < p_info->num_surfaces_out[ii]; jj++)
            {
              sts = om$get_classname(osnum = id->osnum,
                                     objid = p_info->surface_out_ids[kk],
                                     classname = name);
              if (1 & sts)
                p_name = name;
              else
                p_name = "OM_W_NAMENOTFOUND";

              fprintf(stderr, "\t%d surface_out_id %s %d index\n",
                      p_info->surface_out_ids[kk],
                      p_name,
                      p_info->composite_indices[kk]);
              kk++;                    
            }
          }

          fprintf(stderr, "%d num_surfaces\n",
                  p_info->num_surfaces);

          for (ii = 0, kk = 0, ll = 0; ii < p_info->num_surfaces; ii++)
          {
            sts = om$get_classname(osnum = id->osnum,
                                   objid = p_info->surface_ids[ii],
                                   classname = name);
            if (1 & sts)
              p_name = name;
            else
              p_name = "OM_W_NAMENOTFOUND";

            fprintf(stderr, "%d surface_id %s %d in %d out\n",
                    p_info->surface_ids[ii],
                    p_name,
                    p_info->num_regions_in[ii],
                    p_info->num_regions_out[ii]);

            for (jj = 0; jj < p_info->num_regions_in[ii]; jj++)
            {
              sts = om$get_classname(osnum = id->osnum,
                                     objid = p_info->region_in_ids[kk],
                                     classname = name);
              if (1 & sts)
                p_name = name;
              else
                p_name = "OM_W_NAMENOTFOUND";

              fprintf(stderr, "\t%d region_in_id %s\n",
                      p_info->region_in_ids[kk++], p_name);
            }

            for (jj = 0; jj < p_info->num_regions_out[ii]; jj++)
            {
              sts = om$get_classname(osnum = id->osnum,
                                     objid = p_info->region_out_ids[ll],
                                     classname = name);
              if (1 & sts)
                p_name = name;
              else
                p_name = "OM_W_NAMENOTFOUND";

              fprintf(stderr, "\t%d region_out_id %s\n",
                      p_info->region_out_ids[ll++], p_name);
            }
          }
        }

        fprintf (stderr, "\n");

      } /* end intentional block */

      me->state = START;
      break;
/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
    }
  }
 while(TRUE);
}

end implementation ECshowSSI;
