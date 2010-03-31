/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
# include "EMS.h"

# include <stdio.h>
# include "OMminimum.h"         /* GRlc...          */

# include "igrtypedef.h"    /* GRdpmode (and dpstruct.h)        */
# include "dp.h"            /* GRdpmode                         */
# include "igrdp.h"         /* DPele_header and DP_information  */
# include "igetypedef.h"    /* GRlc...                          */
# include "dpstruct.h"      /* DPele_header and DP_information  */
# include "igrdef.h"        /* dp$dispelem IGRQS                */

# include "igr.h"               /* IGR...           */
# include "gr.h"                /* GRlc...          */
# include "madef.h"             /* GRlc...          */
# include "godef.h"             /* GRlc...          */
# include "go.h"                /* GRlc...          */
# include "ex.h"                /* GRlc...          */
# include "EMSlogic.h"          /* logic stuff      */

# define WRITE fprintf(stderr,

void EFdisplayDump(EMmsg, ele_header, display_mode, sp_info)

IGRlong                 *EMmsg;
struct DPele_header     *ele_header;
enum GRdpmode           display_mode;
struct DP_information   *sp_info;

{
  IGRint    i, j, index;

  /*
   * Intro
   */
  WRITE "\n\nDisplay Dump ...\n");

  /*
   * Write out ele_header
   */
  WRITE "Element Header: (at %x)\n", ele_header);
  WRITE "\ttag: %x\n", ele_header->tag);
  switch(ele_header->type)
  {
    case IGRBC:
      WRITE "\ttype: IGRBC\n");
      break;

    case IGRQS:
      WRITE "\ttype: IGRQS\n");
      break;

    default:
      WRITE "\ttype: %x\n",ele_header->type);
      break;
  }
  WRITE "\tflags: %x\n", ele_header->flags);
  WRITE "\trange: (at %x)\n", ele_header->range);
  WRITE "\t\trange: %lf\n", ele_header->range[0]);
  WRITE "\t\trange: %lf\n", ele_header->range[1]);
  WRITE "\t\trange: %lf\n", ele_header->range[2]);
  WRITE "\t\trange: %lf\n", ele_header->range[3]);
  WRITE "\t\trange: %lf\n", ele_header->range[4]);
  WRITE "\t\trange: %lf\n", ele_header->range[5]);
/*  WRITE "\tlevel: (at %x) %d\n", ele_header->level, ele_header->level[0]); */
  WRITE "\tdis_att: (at %x)\n", ele_header->dis_att);
/*
  WRITE "\t\trgb_value: %x\n", ele_header->dis_att->rgb_value);
*/
  WRITE "\t\tcolor: %x\n", ele_header->dis_att->color);
  WRITE "\t\tweight: %x\n", ele_header->dis_att->weight);
  WRITE "\t\tstyle: %x\n", ele_header->dis_att->style);

# define ELE_SPEC ele_header->ele_spec_att

  /*
   * Write the element specific stuff
   */
  switch(ele_header->type)
  {
    case IGRBC:
      WRITE "\tELE_SPEC: (at %x)\n", ELE_SPEC .bspcurve);
      WRITE "\t\tis_polydis: %x)\n", ELE_SPEC .bspcurve->is_polydis);
      WRITE "\t\tis_curvedis: %x)\n", ELE_SPEC .bspcurve->is_curvedis);
      break;

    case IGRBS:
      WRITE "\tELE_SPEC: (at %x)\n", ELE_SPEC .bspsurf);
      WRITE "\t\trules: %d %d\n", ELE_SPEC .bspsurf->u_rules,
                                  ELE_SPEC .bspsurf->v_rules);
      WRITE "\t\tis_polydis: %x\n", ELE_SPEC .bspsurf->is_polydis);
      WRITE "\t\tis_surfdis: %x\n", ELE_SPEC .bspsurf->is_surfdis);
      WRITE "\t\tis_slowdis: %x\n", ELE_SPEC .bspsurf->is_slowdis);
      WRITE "\t\ttype: %x\n", ELE_SPEC .bspsurf->type);
      break;

    case IGRQS:
      WRITE "\tELE_SPEC: (at %x)\n", ELE_SPEC .bsqsurf);
      WRITE "\t\trules: %d %d\n", ELE_SPEC .bsqsurf->u_rules,
                                  ELE_SPEC .bsqsurf->v_rules);
      WRITE "\t\tis_polydis: %x\n", ELE_SPEC .bsqsurf->is_polydis);
      WRITE "\t\tis_surfdis: %x\n", ELE_SPEC .bsqsurf->is_surfdis);
      WRITE "\t\tis_slowdis: %x\n", ELE_SPEC .bsqsurf->is_slowdis);
      WRITE "\t\ttype: %x\n", ELE_SPEC .bsqsurf->type);
      WRITE "\t\trule_specified: %x\n",
            ELE_SPEC .bsqsurf->rules_specified);
      WRITE "\t\trule values in U: (at %x)\n",
            ELE_SPEC .bsqsurf->u_rule_values);
      WRITE "\t\t(u_bdrys at %x)\n", ELE_SPEC .bsqsurf->u_bdrys);
      for(i = 0; i < ELE_SPEC .bsqsurf->u_rules; i ++)
      {
        WRITE "\t\t\t%lf\n", ELE_SPEC .bsqsurf->u_rule_values[i]);
        if(ELE_SPEC .bsqsurf->u_num_bound[i])
        {
          WRITE "\t\t\t\t%d boundaries: (at %x)\n",
                ELE_SPEC .bsqsurf->u_num_bound[i],
                ELE_SPEC .bsqsurf->u_bdrys[i]);
          for(j = index = 0; j < ELE_SPEC .bsqsurf->u_num_bound[i]; j ++)
          {
            WRITE "\t\t\t\t\t%lf\t%lf\n",
                  ELE_SPEC .bsqsurf->u_bdrys[i][index ++],
                  ELE_SPEC .bsqsurf->u_bdrys[i][index ++]);
          }
        }
      }

      WRITE "\t\trule values in V: (at %x)\n",
            ELE_SPEC .bsqsurf->v_rule_values);
      WRITE "\t\t(v_bdrys at %x)\n", ELE_SPEC .bsqsurf->v_bdrys);
      for(i = 0; i < ELE_SPEC .bsqsurf->v_rules; i ++)
      {
        WRITE "\t\t\t%lf\n", ELE_SPEC .bsqsurf->v_rule_values[i]);
        if(ELE_SPEC .bsqsurf->v_num_bound[i])
        {
          WRITE "\t\t\t\t%d boundaries: (at %x)\n",
                ELE_SPEC .bsqsurf->v_num_bound[i],
                ELE_SPEC .bsqsurf->v_bdrys[i]);
          for(j = index = 0; j < ELE_SPEC .bsqsurf->v_num_bound[i]; j ++)
          {
            WRITE "\t\t\t\t\t%lf\t%lf\n",
                  ELE_SPEC .bsqsurf->v_bdrys[i][index ++],
                  ELE_SPEC .bsqsurf->v_bdrys[i][index ++]);
          }
        }
      }
      break;

    default:
      WRITE "Invalid element type, stupid\n");
      break;
  }

  /*
   * Write the geometry
   */
# define GEOM ele_header->geometry

  switch(ele_header->type)
  {
    case IGRBC:
      WRITE "\tGEOM: (at %x)\n", GEOM .bspcurve);
      WRITE "\t\torder: %d\n", GEOM .bspcurve->order);
      WRITE "\t\tperiodic: %d\n", GEOM .bspcurve->periodic);
      WRITE "\t\tnon_uniform: %d\n", GEOM .bspcurve->non_uniform);
      WRITE "\t\tnum_poles: %d\n", GEOM .bspcurve->num_poles);
      WRITE "\t\t%d poles: (at %x)\n", GEOM .bspcurve->num_poles,
                                       GEOM .bspcurve->poles);
      for(i = index = 0; i < GEOM .bspcurve->num_poles; i ++)
        WRITE "\t\t\t%lf\t%lf\t%lf\n", GEOM .bspcurve->poles[index ++],
                                       GEOM .bspcurve->poles[index ++],
                                       GEOM .bspcurve->poles[index ++]);
      WRITE "\t\t%d knots: (at %x)\n", GEOM .bspcurve->num_knots,
                                       GEOM .bspcurve->knots);
      for(i = 0; i < GEOM .bspcurve->num_knots; i ++)
        WRITE "\t\t\t%lf\n", GEOM .bspcurve->knots[i]);
      WRITE "\t\trational: %x\n", GEOM .bspcurve->rational);
      WRITE "\t\tweights: (at %x)\n", GEOM .bspcurve->weights);
      if(GEOM .bspcurve->rational)
      {
        for(i = 0; i < GEOM .bspcurve->num_poles; i ++)
          WRITE "\t\t\t%lf\n", GEOM .bspcurve->num_poles);
      }
      WRITE "\t\tplanar: %x\n", GEOM .bspcurve->planar);
      WRITE "\t\tphy_closed: %x\n", GEOM .bspcurve->phy_closed);
      WRITE "\t\t%d bdrys: (at %x)\n", GEOM .bspcurve->num_boundaries,
                                       GEOM .bspcurve->bdrys);
      for(i = index = 0; i < GEOM .bspcurve->num_boundaries; i ++)
        WRITE "\t\t\t%lf\t%lf\n", GEOM .bspcurve->bdrys[index ++],
                                  GEOM .bspcurve->bdrys[index ++]);
     break;

    case IGRBS: case IGRQS:
      WRITE "\tGEOM: (at %x)\n", GEOM .bspsurf);
      WRITE "\t\torder -- u: %d\tv: %d\n",
            GEOM .bspsurf->u_order,
            GEOM .bspsurf->v_order);
      WRITE "\t\tperiodic -- u: %d\tv: %d\n",
            GEOM .bspsurf->u_periodic,
            GEOM .bspsurf->v_periodic);
      WRITE "\t\tnon_uniform -- u: %d\tv: %d\n",
            GEOM .bspsurf->u_non_uniform,
            GEOM .bspsurf->v_non_uniform);
      WRITE "\t\t %d by %d poles: (at %x)\n",
            GEOM .bspsurf->u_num_poles,
            GEOM .bspsurf->v_num_poles,
            GEOM .bspsurf->poles);
      for(i = index = 0; i < GEOM .bspsurf->v_num_poles; i ++)
      {
        WRITE "\t\t\t---------\n");
        for(j = 0; j < GEOM .bspsurf->u_num_poles; j ++)
        {
          WRITE "\t\t\t\t%lf\t%lf\t%lf\n",
                GEOM .bspsurf->poles[index ++],
                GEOM .bspsurf->poles[index ++],
                GEOM .bspsurf->poles[index ++]);
        }
      }

      WRITE "\t\t%d u_knots: (at %x)\n", GEOM .bspsurf->u_num_knots,
                                         GEOM .bspsurf->u_knots);
      for(i = 0; i < GEOM .bspsurf->u_num_knots; i ++)
        WRITE "\t\t\t%lf\n", GEOM .bspsurf->u_knots[i]);

      WRITE "\t\t%d v_knots: (at %x)\n", GEOM .bspsurf->v_num_knots,
                                         GEOM .bspsurf->v_knots);
      for(i = 0; i < GEOM .bspsurf->v_num_knots; i ++)
        WRITE "\t\t\t%lf\n", GEOM .bspsurf->v_knots[i]);

      WRITE "\t\trational: %x\n", GEOM .bspsurf->rational);
      WRITE "\t\tweights: (at %x)\n", GEOM .bspsurf->weights);
      if(GEOM .bspsurf->rational)
      {
        for(i = index = 0; i < GEOM .bspsurf->u_num_poles; i ++)
        {
          WRITE "\t\t\t---------\n");
          for(j = 0; j < GEOM .bspsurf->v_num_poles; j ++)
          {
            WRITE "\t\t\t\t%lf\n", GEOM .bspsurf->weights[index ++]);
          }
        }
      }

      for(i = 0; i < GEOM .bspsurf->num_boundaries; i ++)
      {
        WRITE "\t\t\t%d points: (at %x)\n",
              GEOM .bspsurf->bdrys[i].num_points,
              GEOM .bspsurf->bdrys[i].points);
        for(j = index = 0; j < GEOM .bspsurf->bdrys[i].num_points; j ++)
        {
          WRITE "\t\t\t\t%lf\t%lf\n",
                GEOM .bspsurf->bdrys[i].points[index ++],
                GEOM .bspsurf->bdrys[i].points[index ++]);
        }
      }
      break;

    default:
      WRITE "Listen up. Invalid element type.\n");
      break;
  }

  /*
   * Wite display mode
   */
  WRITE "\nDisplay mode: %x\n", display_mode);

  /*
   * Write sp_info
   */
  WRITE "\nDP_information: (at %x)\n", sp_info);
  WRITE "\tgragad: (at %x)\n", sp_info->gragad);
  WRITE "\twin_no: %d\n", sp_info->win_no);
  WRITE "\tis_update: %x\n", sp_info->is_update);
  WRITE "\tis_fit: %x\n", sp_info->is_fit);
  WRITE "\tfit_range: (at %x)\n", sp_info->fit_range);
  if((sp_info->is_fit) && (sp_info->fit_range))
  {
    WRITE "\t\t%lf\t%lf\t%lf\n\t\t%lf\t%lf\t%lf\n",
          sp_info->fit_range[0], sp_info->fit_range[1],
          sp_info->fit_range[2], sp_info->fit_range[3],
          sp_info->fit_range[4], sp_info->fit_range[5]);
  }
  WRITE "\tis_hidden_line: %x\n", sp_info->is_hidden_line);
  WRITE "\thline_info: (at %x)\n", sp_info->hline_info);
}
