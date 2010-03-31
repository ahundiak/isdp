/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

/*
Abstract
    This function does a color-coded graph display using rule line tables
    of the radius of curvature of a surface


Arguments
    IGRlong EMcurvature_rlt_color_display(msg, mattyp, matrix, srf_id,
                                          radii, numupars, upars, numvpars,
                                          vpars, button)

    IGRlong    *msg            return code.

    IGRshort   *mattyp         matrix type of the surface.

    IGRmatrix  matrix          environment matrix of the surface.

    struct GRid  srf_id        the surface objid and osnum.

    IGRdouble  radii[]         the radius of curvature values.

    IGRint     numupars        number of parameters in the u direction.

    IGRdouble  upars[]         array of u parameters.

    IGRint     numvpars        number of parameters in the v direction.

    IGRdouble  vpars[]         array of v parameters.

    struct EX_button  *button  the button structure containing the upper
                               left-hand corner point of the legend and
                               the window number, objid, and osnum of the
                               window to display the legend in.


Notes

Files
    EMrltcoldsp.I
    EMgetcolors.I
    EMparminhole.C
    EMlegend.I


History
    dhm    10/28/88    creation date.
    NP     08/27/92    Modified for ANSI compliance.
    SM     10/21/92    Fixed a memory problem. The pointer rlt_bdrys was
                       obtained, but later the memory was being reallocated, 
                       causing the earlier obtained pointer to become
                       invalid. Fixed so that realloc occurs before. See
                       inline comments dated 10/21/92.
*/

from  EMSloopset  import  EMlsparttrim;

IGRlong EMcurvature_rlt_color_display(msg, mattyp, matrix, srf_id,
                                      radii, numupars, upars, numvpars,
                                      vpars, button)
IGRlong    *msg;
IGRshort   *mattyp;
IGRmatrix  matrix;
struct GRid  srf_id;
IGRdouble  radii[];
IGRint     numupars;
IGRdouble  upars[];
IGRint     numvpars;
IGRdouble  vpars[];
struct EX_button  *button;

{
  IGRlong    msg_loc, status;
  IGRlong    numrad;
  IGRint     *inx, *b_inx, *color;
  IGRdouble  *array;
  IGRint     num_lsbdrys, k, j, i, ii, jj, rd_inx, pr_inx, last_inx, col_inx;
  IGRint     prev_color, new_color;
  IGRint     numcvpars, numevpars, do_loop_ctr;
  IGRdouble  *rad, *cvpars, *evpars, *range_scale, lovalue, base_tol;
  IGRboolean const_in_u, sts, one_color;
  IGRint     num_of_colors, num_colors;
  unsigned int    count;
  unsigned short  options;
  IGRdouble  mat_mem[16];
  IGRdouble  incr, range, mean_rad;
  IGRdouble  pnts[4], ret_bdry[2], max_rad, min_rad;
  IGRchar    errmsg[GR_MAX_CHAR];
  struct EMSdataselect    py_datasel;
  struct EMSpypoint       *ls_bdrys;
  struct EMSpartolbasis   partol_basis;
  struct IGRpolyline      poly;
  struct GRid             modGRid;
  OM_S_CHANSELECT         to_loopset;
  struct IGRdisplay       display_attr;
  IGRshort                level;
  IGRlong                 size, bytes_out;
  struct IGResqbs         *rlt;
  struct IGRbsp_surface   *srf;
  IGRdouble               (*bdrys)[2];
  IGRboolean              EMparm_in_hole(), in_hole;
  void                    EFsortDouble();

  /*
   * Initialize
   */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy (errmsg, "EMSsubbs.EMcurvature_rlt_color_display\n");
  rad = NULL;
  cvpars = NULL;
  evpars = NULL;
  rlt = NULL;
  color = NULL;
  srf = NULL;
  range_scale = NULL;
  partol_basis.mattyp = mattyp;
  partol_basis.mat = mat_mem;
  OM_BLOCK_MOVE(matrix, partol_basis.mat, sizeof(IGRmatrix) );
  ex$get_cur_mod(id = &modGRid.objid, osnum = &modGRid.osnum);

  status = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMomerr_hndlr(status, ret_end, errmsg);

  sts = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, base_tol);

  /*
   * Get the number of loopsets to see if I have any.
   */

  status = om$get_channel_count(objid = srf_id.objid,
                                osnum = srf_id.osnum,
                                p_chanselect = &to_loopset,
                                count = &count);
  EMomerr_hndlr(status, ret_end, errmsg);

  /*
   * Get the display attributes and level for displaying the
   * rule line tables surface.
   */

  size = sizeof(struct IGRdisplay);
  gr$get_active_display(msg = &msg_loc, 
                        sizbuf = &size,
                        buffer = &display_attr,
                        nret = &bytes_out);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  size = sizeof(IGRshort);
  gr$get_active_level(msg = &msg_loc,
                      sizbuf = &size,
                      buffer = &level,
                      nret = &bytes_out);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Get the colors.
   */

  status = EMget_colors(&msg_loc, &num_of_colors, &color);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Allocate memory for the rule line tables.
   */

  rlt = (struct IGResqbs *) om$malloc(size = num_of_colors *
                                      sizeof(struct IGResqbs));
  EMerr_hndlr(!rlt, *msg, MSNOMEM, ret_end);

  /*
   * Initalize the rlt's.  Allocate any necessary memory.
   */

  for (i = 0; i < num_of_colors; i++)
  {
    rlt[i].u_rules = numupars;
    rlt[i].v_rules = numvpars;
    rlt[i].is_polydis = FALSE;
    rlt[i].is_surfdis = TRUE;
    rlt[i].is_slowdis = FALSE;
    rlt[i].type = IGRQS;
    rlt[i].rules_specified = TRUE;

    rlt[i].u_rule_values = (IGRdouble *) om$malloc(size = numupars *
                            sizeof(IGRdouble) );
    EMerr_hndlr(!rlt[i].u_rule_values, *msg, MSNOMEM, ret_end);

    rlt[i].v_rule_values = (IGRdouble *) om$malloc(size = numvpars *
                            sizeof(IGRdouble) );
    EMerr_hndlr(!rlt[i].v_rule_values, *msg, MSNOMEM, ret_end);

    rlt[i].u_num_bound = (IGRint *) om$malloc(size = numupars *
                          sizeof(IGRint) );
    EMerr_hndlr(!rlt[i].u_num_bound, *msg, MSNOMEM, ret_end);

    rlt[i].v_num_bound = (IGRint *) om$malloc(size = numvpars *
                          sizeof(IGRint) );
    EMerr_hndlr(!rlt[i].v_num_bound, *msg, MSNOMEM, ret_end);

    for (j = 0; j < numupars; j++)
    {
      rlt[i].u_rule_values[j] = upars[j];
      rlt[i].u_num_bound[j] = 0;
    }

    for (j = 0; j < numvpars; j++)
    {
      rlt[i].v_rule_values[j] = vpars[j];
      rlt[i].v_num_bound[j] = 0;
    }

    rlt[i].u_bdrys = (IGRdouble **) om$malloc(size = numupars *
                      sizeof(IGRdouble *) );
    EMerr_hndlr(!rlt[i].u_bdrys, *msg, MSNOMEM, ret_end);

    for (j = 0; j < numupars; j++)
    {
      rlt[i].u_bdrys[j] = (IGRdouble *) om$malloc(size = 2 * 10 *
                           sizeof(IGRdouble) );
      EMerr_hndlr(!rlt[i].u_bdrys[j], *msg, MSNOMEM, ret_end);
    }

    rlt[i].v_bdrys = (IGRdouble **) om$malloc(size = numvpars *
                      sizeof(IGRdouble *) );
    EMerr_hndlr(!rlt[i].v_bdrys, *msg, MSNOMEM, ret_end);

    for (j = 0; j < numvpars; j++)
    {
      rlt[i].v_bdrys[j] = (IGRdouble *) om$malloc(size = 2 * 10 *
                           sizeof(IGRdouble) );
      EMerr_hndlr(!rlt[i].v_bdrys[j], *msg, MSNOMEM, ret_end);
    }

  } /* end for (i = 0; i < num_of_colors; i++) */

  /*
   * Allocate memory for the radius values.
   */

  numrad = numupars * numvpars;
  rad = (IGRdouble *) om$malloc(size = numrad * sizeof(IGRdouble));
  EMerr_hndlr(!rad, *msg, MSNOMEM, ret_end);

  /*
   * We want to execute the whole code twice.  Once displaying the u-dir
   * colored curves and once displaying the v-dir colored curves.
   */

  do_loop_ctr = 0;
  const_in_u = TRUE;

  do
  {

    /*
     * Set the cvpars and evpars correctly.
     * If it's constant in u-dir, then the parms at which to extract the 
     * u-rules are the upars and the parms to evaluate at are the vpars.
     * If it's constant in v-dir, then the parms at which to extract the
     * v-rules are the vpars and the parms to evaluate at are the upars.
     */

    if (const_in_u)
    {
      numcvpars = numupars;
      cvpars = (IGRdouble *) om$malloc(size = numupars * 
                                              sizeof(IGRdouble));
      EMerr_hndlr(!cvpars, *msg, MSNOMEM, ret_end);

      OM_BLOCK_MOVE(upars, cvpars, numupars * sizeof(IGRdouble) );

      numevpars = numvpars;
      evpars = (IGRdouble *) om$malloc(size = numvpars *
                                              sizeof(IGRdouble));
      EMerr_hndlr(!evpars, *msg, MSNOMEM, ret_end);

      OM_BLOCK_MOVE(vpars, evpars, numvpars * sizeof(IGRdouble) );

      /* Must reverse the radii values to correspond to a v-u direction.
       */

      for (i = 0; i < numupars; i++)
      {
        k = i * numvpars;

        for (j = 0; j < numvpars; j++)
        {
          rad[k + j] = radii[(j * numupars) + i];
        }
      }  /* end for i < numupars */

    }  /* end if const_in_u */
    else
    {
      numcvpars = numvpars;
      cvpars = (IGRdouble *) om$malloc(size = numvpars *
                                              sizeof(IGRdouble));
      EMerr_hndlr(!cvpars, *msg, MSNOMEM, ret_end);

      OM_BLOCK_MOVE(vpars, cvpars, numvpars * sizeof(IGRdouble) );

      numevpars = numupars;
      evpars = (IGRdouble *) om$malloc(size = numupars *
                                       sizeof(IGRdouble));
      EMerr_hndlr(!evpars, *msg, MSNOMEM, ret_end);

      OM_BLOCK_MOVE(upars, evpars, numupars * sizeof(IGRdouble) );

      OM_BLOCK_MOVE(radii, rad, numrad * sizeof(IGRdouble) );

    }

    /*
     * Calculate the range and increment step of the colors.
     */

    one_color = FALSE;
    max_rad = 0.0;
    min_rad = MAXDOUBLE;
    for (i = 0; i < numrad; i++)
    {
      if (rad[i] > max_rad)
        max_rad = rad[i];

      if ( (rad[i] != -1) && (rad[i] < min_rad) )
        min_rad = rad[i];
    }

    if (min_rad == MAXDOUBLE)
    {
      *msg = MSINARG;
      goto ret_end;
    }
    else
    {
      range = max_rad - min_rad;
      incr = range / num_of_colors;
    }

    if (incr <= base_tol)
      one_color = TRUE;

    /*
     * Process each curve assigning color values to the segments.
     */

    for (i = 0; i < numcvpars; i++)
    {

      /*
       * Get the boundaries if there are any.
       */

      if (count)
      {
        num_lsbdrys = 0;
        ls_bdrys = NULL;

        partol_basis.is_valid = FALSE;
        options = EMS_INTER_BDRYISAREA | EMS_INTER_CUTTING;

        poly.num_points = 2;
        poly.points = pnts;
        if (const_in_u)
        {
          poly.points[0] = cvpars[i];
          poly.points[1] = 0;
          poly.points[2] = cvpars[i];
          poly.points[3] = 1;
        }
        else
        {
          poly.points[0] = 0;
          poly.points[1] = cvpars[i];
          poly.points[2] = 1;
          poly.points[3] = cvpars[i];
        }

        py_datasel.datatype = EMSdata_poly2d;
        py_datasel.data.poly = &poly;

        status = om$send(msg = message EMSloopset.EMlsparttrim(&msg_loc,
                               &py_datasel, &partol_basis, options,
                               &num_lsbdrys, &ls_bdrys, NULL),
                         senderid = srf_id.objid,
                         targetos = srf_id.osnum,
                         p_chanselect = &to_loopset);
        EMomerr_hndlr(status, ret_end, errmsg);
        EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

      }  /* end if count */

      /*
       * If there isn't any ls_bdrys, then the whole curve is in a hole.
       */
 
      if (!ls_bdrys)
        continue;

      /*
       * Begin do loop to process rule lines into different colors.
       */

      pr_inx = 0;
      last_inx = numevpars - 1;
      rd_inx = i * numevpars;
      in_hole = FALSE;
      do
      {

        if (count && EMparm_in_hole(evpars[pr_inx], 0, ls_bdrys, ret_bdry))
        {
          in_hole = TRUE;
          pr_inx++;
          rd_inx++;
          continue;
        }
        else if (rad[rd_inx] == -1)
        {
          in_hole = FALSE;
          pr_inx++;
          rd_inx++;
          continue;
        }
        else if ( pr_inx != 0 )
        {
          pr_inx--;
          rd_inx--;
        }

        if (one_color)
          prev_color = 1;
        else
        {
          if ( rad[rd_inx] == -1 )
            mean_rad = rad[rd_inx + 1];
          else
            mean_rad = (rad[rd_inx] + rad[rd_inx + 1]) / 2.0;

          prev_color = (IGRint) ( (mean_rad - min_rad) / incr + 1 );
          if (prev_color > num_of_colors)
             prev_color = num_of_colors;
          else if (prev_color <= base_tol)
             prev_color = 1;
        }

        col_inx = prev_color - 1;

        b_inx = (const_in_u ? rlt[col_inx].u_num_bound :
                              rlt[col_inx].v_num_bound);
        if (b_inx[i] >= 10)
        {
          if (const_in_u)
          {
            rlt[col_inx].u_bdrys[i] = (IGRdouble *) om$realloc(ptr =
                                      (IGRchar *)(rlt[col_inx].u_bdrys[i]),
                                      size = (b_inx[i] + 1) * 2 *
                                              sizeof(IGRdouble) );
          }
          else
          {
            rlt[col_inx].v_bdrys[i] = (IGRdouble *) om$realloc(ptr =
                                      (IGRchar *) (rlt[col_inx].v_bdrys[i]),
                                      size = (b_inx[i] + 1) * 2 *
                                              sizeof(IGRdouble) );
          }

        }  /* end b >= 10 */
        bdrys = (IGRdouble (*)[2])(const_in_u ? rlt[col_inx].u_bdrys[i] :
                              rlt[col_inx].v_bdrys[i]);
        bdrys[b_inx[i]][0] = (in_hole ? ret_bdry[1] : evpars[pr_inx]);

        /*
         * Process the remainder of the rule line.
         */

        while ( pr_inx < (last_inx - 1) )
        {
          pr_inx++;
          rd_inx++;

          if (one_color)
            new_color = 1;
          else
          {
            if ( rad[rd_inx + 1] == -1 )
              mean_rad = rad[rd_inx];
            else
              mean_rad = (rad[rd_inx] + rad[rd_inx + 1]) / 2.0;

            new_color = (IGRint) ( (mean_rad - min_rad) / incr + 1 );
            if (new_color > num_of_colors)
               new_color = num_of_colors;
            else if (new_color <= base_tol)
               new_color = 1;
          }

          col_inx = new_color - 1;

          if (count)
          {
            in_hole = EMparm_in_hole(evpars[pr_inx], 0, ls_bdrys,
                                     ret_bdry);
          }

          /*
           * Process a color change or parm in hole.
           */

          if ( (new_color != prev_color) || in_hole )
          {
            bdrys[b_inx[i]][1] = (in_hole ? ret_bdry[0] : evpars[pr_inx]);
            (b_inx[i])++;

            /*
             * If parm is in a hole, keep processing until you reach a
             * parm that is not in a hole.
             */

            if (in_hole)
            {
               if (ret_bdry[1] == evpars[last_inx])
               {
                 pr_inx = last_inx;
                 continue;
               }

               while ( (ret_bdry[1] >= evpars[pr_inx+1]) &&
                       (pr_inx < last_inx - 1) )
               {
                 pr_inx++;
                 rd_inx++;

                 if (one_color)
                   new_color = 1;
                 else
                 {
                   mean_rad = (rad[rd_inx] + rad[rd_inx + 1]) / 2.0;
                   new_color = (IGRint) ( (mean_rad - min_rad) / incr+1 );
                   if (new_color > num_of_colors)
                      new_color = num_of_colors;
                   else if (new_color <= base_tol)
                      new_color = 1;
                 }

                 col_inx = new_color - 1;
               }
            }  /* end if in_hole */

            /*
             * Set the start boundary on the new color's rlt.
             */

            prev_color = new_color;
            b_inx = (const_in_u ? rlt[col_inx].u_num_bound :
                                  rlt[col_inx].v_num_bound);
            if (b_inx[i] >= 10)
            {
              if (const_in_u)
              {
                rlt[col_inx].u_bdrys[i] = (IGRdouble *) om$realloc(ptr =
                                          (IGRchar *)(rlt[col_inx].u_bdrys[i]),
                                          size = (b_inx[i] + 1) * 2 *
                                                  sizeof(IGRdouble) );
              }
              else
              {
                rlt[col_inx].v_bdrys[i] = (IGRdouble *) om$realloc(ptr =
                                          (IGRchar *) (rlt[col_inx].v_bdrys[i]),
                                          size = (b_inx[i] + 1) * 2 *
                                                  sizeof(IGRdouble) );
              }

            }  /* end b >= 10 */
            bdrys = (IGRdouble (*)[2])(const_in_u ? rlt[col_inx].u_bdrys[i] :
                                  rlt[col_inx].v_bdrys[i]);
            bdrys[b_inx[i]][0] = (in_hole ? ret_bdry[1] : evpars[pr_inx]);

          }  /* end if new_color != prev_color  || in_hole */

          /*
           * If rad is infinite at this interval, then set the end
           * boundary on this color's rlt, process until rad is not
           * infinite, and then set the start boundary on the new color's
           * rlt.
           */

          if (rad[rd_inx+1] == -1)
          {
            pr_inx++;
            rd_inx++;
            bdrys[b_inx[i]][1] = evpars[pr_inx];
            (b_inx[i])++;

            while ( (rad[rd_inx] == -1) && (pr_inx < last_inx) )
            {
              pr_inx++;
              rd_inx++;
            }

            if (count)
            {
              in_hole = EMparm_in_hole(evpars[pr_inx], 0, ls_bdrys,
                                       ret_bdry);
            }

            if (pr_inx < last_inx)
            {
              if (in_hole)
              {
                if (ret_bdry[1] == evpars[last_inx])
                {
                  pr_inx = last_inx;
                  continue;
                }

                while ( (ret_bdry[1] >= evpars[pr_inx+1]) &&
                        (pr_inx < last_inx) )
                {
                  pr_inx++;
                  rd_inx++;
                }

              }  /* end if in_hole */

              if (one_color)
                prev_color = 1;
              else
              {
                mean_rad = (in_hole ? (rad[rd_inx] + rad[rd_inx+1]) / 2.0
                                    : rad[rd_inx]);
                prev_color = (IGRint) ( (mean_rad - min_rad) / incr + 1 );
                if (prev_color > num_of_colors)
                  prev_color = num_of_colors;
                else if (prev_color <= base_tol)
                  prev_color = 1;
              }

              col_inx = prev_color - 1;

              pr_inx--;
              rd_inx--;

              b_inx = (const_in_u ? rlt[col_inx].u_num_bound :
                                    rlt[col_inx].v_num_bound);
              if (b_inx[i] >= 10)
              {
                if (const_in_u)
                {
                  rlt[col_inx].u_bdrys[i] = (IGRdouble *) om$realloc(ptr=
                                            (IGRchar *)(rlt[col_inx].u_bdrys[i]),
                                            size = (b_inx[i] + 1) * 2 *
                                                    sizeof(IGRdouble) );
                }
                else
                {
                  rlt[col_inx].v_bdrys[i] = (IGRdouble *) om$realloc(ptr=
                                            (IGRchar *)(rlt[col_inx].v_bdrys[i]),
                                            size = (b_inx[i] + 1) * 2 *
                                                    sizeof(IGRdouble) );
                }

              }  /* end b >= 10 */
              bdrys = (IGRdouble (*)[2])(const_in_u ? rlt[col_inx].u_bdrys[i] :
                                    rlt[col_inx].v_bdrys[i]);
              bdrys[b_inx[i]][0] = (in_hole ? ret_bdry[1] :
                                              evpars[pr_inx]);

            }  /* end if pr_inx < last_inx */

          }  /* end if rad[rd_inx+1] == -1 */

        }  /* end while ( pr_inx < last_inx-1) */

        /*
         * On the last segment the last boundary needs to be set.
         */

        if ( pr_inx == (last_inx - 1) )
        {
          pr_inx++;
          rd_inx++;

          if (count)
          {
            in_hole = EMparm_in_hole(evpars[pr_inx], 0, ls_bdrys,
                                     ret_bdry);
          }

          bdrys[b_inx[i]][1] = (in_hole ? ret_bdry[0] : evpars[pr_inx]);
          (b_inx[i])++;
        }

      } while ( pr_inx < last_inx );   /* end color eval. do-while loop */
      if(ls_bdrys)
        EMpypoint_free(ls_bdrys,MAXINT);
 
    }  /* end for i < numcvpars loop */


    if (one_color)
      num_colors = 1;
    else
      num_colors = num_of_colors;


/************************* most optimized  patch -ha ha  */
 if(const_in_u )
  {
     for(ii=0; ii<num_of_colors;ii++)
         for(jj=0; jj<numcvpars;jj++)
             if(rlt[ii].u_num_bound[jj] > 0)
                EFsortDouble(rlt[ii].u_bdrys[jj],rlt[ii].u_num_bound[jj]*2);
  }
 else
  {
     for(ii=0; ii<num_of_colors;ii++)
         for(jj=0; jj<numcvpars;jj++)
             if(rlt[ii].v_num_bound[jj] > 0)
                EFsortDouble(rlt[ii].v_bdrys[jj],rlt[ii].v_num_bound[jj]*2);
  }
/*  end patch  ******************** */

    /*
     * Code to post-process the rule line tables from positive
     * boundaries into negative boundaries.
     */

    {
      IGRdouble              *temp_temp_bdrys,*temp_bdrys, *rlt_bdrys;
      IGRlong                num_bytes;
      IGRboolean             add_0, add_1;
      IGRint                 end_inx;

      for (i = 0; i < num_colors; i++)
      {

        for (j = 0; j < numcvpars; j++)
        {
          temp_bdrys = NULL;
          add_0 = add_1 = FALSE;
          b_inx = (const_in_u ? rlt[i].u_num_bound :
                                rlt[i].v_num_bound);
          /********** Add SM 10/21/92 **********/
          /* Reallocate max required memory (for cases when add_0 and add_1, 
             both become TRUE later in this loop). Then obtain the pointer
             rlt_bdrys.
          */
          if(b_inx[j])
           {
            if (const_in_u)
             rlt[i].u_bdrys[j] = (IGRdouble *) om$realloc(ptr =
                                 (char *) rlt[i].u_bdrys[j],
                                 size = (b_inx[j] +2) * 2 *
                                 sizeof(IGRdouble) );
            else
             rlt[i].v_bdrys[j] = (IGRdouble *) om$realloc(ptr =
                                (char *) rlt[i].v_bdrys[j],
                                size = (b_inx[j] + 2) * 2 *
                                sizeof(IGRdouble) );
           }
          /******* End add SM 10/21/92 *************/

          rlt_bdrys = (const_in_u ? rlt[i].u_bdrys[j] : rlt[i].v_bdrys[j]);

          if (b_inx[j] == 0)
          {
            rlt_bdrys[0] = 0.0;
            rlt_bdrys[1] = 1.0;
            (b_inx[j])++;
          }
          else
          {
            end_inx = b_inx[j] * 2 - 1;
            num_bytes = b_inx[j] * 2 * sizeof(IGRdouble);

            temp_bdrys =(IGRdouble *) om$malloc(size = num_bytes +
                                      sizeof(IGRdouble));
            temp_temp_bdrys = temp_bdrys;
        
            EMerr_hndlr(!temp_bdrys, *msg, MSNOMEM, ret_end);

            OM_BLOCK_MOVE(rlt_bdrys, temp_bdrys, num_bytes);

            if (rlt_bdrys[0] != 0.0)
               add_0 = TRUE;
            if (rlt_bdrys[end_inx] != 1.0)
               add_1 = TRUE;

            if (add_0)
            {
              rlt_bdrys[0] = 0.0;
              rlt_bdrys++;
              end_inx++;
            }
            else
            {
              temp_bdrys++;
              num_bytes -= sizeof(IGRdouble);
            }

            if (add_1)
            {
              temp_bdrys[end_inx] = 1.0;
              num_bytes += sizeof(IGRdouble);
            }
            else
              num_bytes -= sizeof(IGRdouble);

            if (add_0 && add_1)
            {
              (b_inx[j])++;
/********************************** SM 10/21/92
              if (const_in_u)
              {
                rlt[i].u_bdrys[j] = (IGRdouble *) om$realloc(ptr =
                                          (IGRchar *)(rlt[i].u_bdrys[j]),
                                          size = b_inx[j] * 2 *
                                                 sizeof(IGRdouble) );
              }
              else
              {
                rlt[i].v_bdrys[j] = (IGRdouble *) om$realloc(ptr =
                                          (IGRchar *)(rlt[i].v_bdrys[j]),
                                          size = b_inx[j] * 2 *
                                                 sizeof(IGRdouble) );
              }
****************** End SM 10/21/92 *************/
            }
            else if (!add_0 && !add_1)
              (b_inx[j])--;

            if (num_bytes) OM_BLOCK_MOVE(temp_bdrys, rlt_bdrys, num_bytes);
            
            if(temp_temp_bdrys)
              om$dealloc(ptr = temp_temp_bdrys);

          }  /* end else b_inx != 0 */

        }  /* end for j < numcvpars loop */

      }  /* end for i < num_colors loop */

    }

    if (cvpars)  om$dealloc(ptr = cvpars);
    cvpars = NULL;
    if (evpars)  om$dealloc(ptr = evpars);
    evpars = NULL;

    do_loop_ctr++;
    const_in_u = FALSE;

  } while (do_loop_ctr < 2);  /* end the main do-while loop */

  /*
   * Set up element header and display the rlt buffers.
   */

  status = om$send(msg = message GRvg.GRgetsize(&msg_loc, mattyp, matrix,
                         &size),
                   senderid = NULL_OBJID,
                   targetid = srf_id.objid,
                   targetos = srf_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  srf = (struct IGRbsp_surface *) om$malloc(size = size);
  EMerr_hndlr(!srf, *msg, MSNOMEM, ret_end);

  status = om$send(msg = message GRvg.GRgetgeom(&msg_loc, mattyp, matrix,
                         (IGRchar *)srf),
                   senderid = NULL_OBJID,
                   targetid = srf_id.objid,
                   targetos = srf_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  if (one_color)
    num_colors = 1;
  else
    num_colors = num_of_colors;

  range_scale = (IGRdouble *) om$malloc(size = 2 * num_colors * 
                                         sizeof(IGRdouble));
  EMerr_hndlr(!range_scale, *msg, MSNOMEM, ret_end);

  lovalue = min_rad;
  for (i = 0; i < num_colors; i++)
  {
    struct DPele_header    ele_header;

    range_scale[i*2] = lovalue;
    range_scale[i*2+1] = lovalue + incr;

    display_attr.color = color[i];

    dp$build_dis_buffer(buffer = &ele_header,
                        type = IGRQS,
                        level = &level,
                        display_att = &display_attr,
                        ele_spec_att = &rlt[i],
                        geometry = srf);

    dp$display(msg = &msg_loc, osnum = modGRid.osnum,
               objid = modGRid.objid, mode = GRbd,
               buffer = &ele_header);
    EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

    lovalue = lovalue + incr;
  }

  EMlegend(&msg_loc, button->window, button->objid, button->osnum,
           &button->x, num_colors, color, range_scale);


ret_end:
  if (rad)  om$dealloc(ptr = rad);
  if (cvpars)  om$dealloc(ptr = cvpars);
  if (evpars)  om$dealloc(ptr = evpars);
  if (srf)   om$dealloc(ptr = srf);
  if (color)   om$dealloc(ptr = color);
  if (range_scale)   om$dealloc(ptr = range_scale);

  if (rlt)
  {
    for (i = 0; i < num_of_colors; i++)
    {
      if (rlt[i].u_rule_values)  om$dealloc(ptr = rlt[i].u_rule_values);
      if (rlt[i].v_rule_values)  om$dealloc(ptr = rlt[i].v_rule_values);
      if (rlt[i].u_num_bound)  om$dealloc(ptr = rlt[i].u_num_bound);
      if (rlt[i].v_num_bound)  om$dealloc(ptr = rlt[i].v_num_bound);
      if (rlt[i].u_bdrys)
      {
        for (j = 0; j < numupars; j++)
          om$dealloc(ptr = rlt[i].u_bdrys[j]);

        om$dealloc(ptr = rlt[i].u_bdrys);
      }

      if (rlt[i].v_bdrys)
      {
        for (j = 0; j < numvpars; j++)
          om$dealloc(ptr = rlt[i].v_bdrys[j]);

        om$dealloc(ptr = rlt[i].v_bdrys);
      }

    }  /* end for i < num_of_colors loop */

    om$dealloc(ptr = rlt);

  }  /* end if rlt */

  return (status);
}

end implementation EMSsubbs;
