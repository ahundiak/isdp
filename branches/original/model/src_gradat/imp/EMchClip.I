/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif
#include "EMSopt.h"
/*
History
    
   Jack 07 Apr 92       if me->num_[uv]_rules gets set to something
                        greater than 255, set it to zero and send warning. 
    rlw 04 Apr 89       In wrapup there was a goto wrapup; statement.
    AIC 11 Jan 89       Modified to allow material cross hatch 
                        patterns.
    AIC 04 Jan 89       Maintain the alternate display info at
                        the end of the short_data VLA.
    AIC 28 Apr 88       Changed EMSFRT_UPTODATE to EMSGD_UPTODATE.
    PP  02/22/88        Added logic to process ambiguous intersection from
                        loop trim.
    RC  12/07/87        Modified due to change in the instance data.
                        u-scale and v-scale factors are no more stored.
    AIC 15 Jul 87       Creation Date
*/

# include <memory.h>        /* memset           */

# ifndef OMmacros_include
# include "OMmacros.h"      /* OM_BLOCK_MOVE    */
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport     */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport     */
# endif

# ifndef EMSommacros_include
# include "EMSommacros.h"   /* ems$get_memory   */
# endif

# ifndef emsmacros_include
# include "emsmacros.h"     /* EM2dbxinc        */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE   */
# endif
# include "emsdattyp.h"
# include "emsdef.h"
# include "emsinterdef.h"
# include "emserr.h"

# define U 0                /* Index of u                       */
# define V 1                /* Index of v                       */
# define PTSIZE 2           /* Point size                       */
# define VLA_INCREMENT 40   /* Temp buffer size                 */

# define OPTIONS EMS_INTER_BDRYISAREA | EMS_INTER_CUTTING | \
                 EMS_INTER_STARTPT | EMS_INTER_STOPPT | \
                 EMS_INTER_REMZEROEND

from EMSsubbs import EMpartolbasis;
from EMSloop import EMget_objid, EMlppytrimint;
from EMSloop   import EMmake_natural_loop;
from GRvg import GRgenabsg;
from EMSboundary import EMuv_transform, EMtpcopy;

extern  struct EMSpypoint   EMSclipPypointBuffer[EMS_CLIP_BUFF_SIZE];
extern  IGRdouble           EMSclipValueBuffer[EMS_CLIP_BUFF_SIZE];
extern  IGRchar             EMScrossHatchPlaneBuffer[CROSS_HATCH_PLANE_BUFFER_SIZE];
extern  OMuint              OM_Gf_verbose_warning;


method EMclip(IGRlong *EMmsg; struct IGResqbs *rlt;
                 struct EMSpartolbasis *partol_basis; IGRshort *mx_type;
                 IGRmatrix mx; struct IGRbsp_surface *surface)
{
  IGRshort              alt_display[2]; /* Memory for alternate display */
  IGRlong               sts;            /* OM status                    */
  IGRint                num_clips,      /* Number of clip points        */
                        num_bytes,      /* Number of bytes needed       */
                        sizeof_double,  /* Size of the data type        */
                        i, j, l,        /* loop counters                */
                        rule_index,     /* index in short_data VLA      */
                        clip_index,     /* index in double_data VLA     */
                        total_rules,    /* Total number of rules        */
                        clip_value_buffer_size,
                                        /* Size of clip value buffer    */
                        clip_pt_buffer_size,
                                        /* Size of clip point buffer    */
                        short_VLA_size, /* short_data VLA size          */
                        double_VLA_size;/* double_data VLA size         */
  IGRdouble             range[4],       /* Range of the rule line       */
                        my_pts[4];      /* Polyline points buffer       */
  OM_S_CHANSELECT       to_Ploop;       /* My channel to the Ploop      */
  GRobjid               Ploop;          /* objid of the Ploop           */
  struct EMSpypoint     *clip_pts,      /* Clip points                  */
                        *clip_pt_buffer,/* Clip point buffer            */
                        *this_pt;       /* Clip point pointer           */
  struct IGRpolyline    rule_line;      /* rule line                    */
  struct IGRbsp_surface *plane,         /* World plane geometry         */
                        *xh_plane;      /* Cross hatch plane geometry   */

  IGRboolean      Ploop_constructed = FALSE, ambiguous;

  IGRint        varying_index;
  IGRint        constant_index;
  IGRint        rules;
  IGRshort      *num_bound;
  IGRdouble     *rule_values;
  IGRdouble     *bdrys,
                *clip_value_buffer,     /* Clip value buffer    */
                *clip_values;           /* Clip value array     */
  IGRint        sgrp_index;
  IGRint        num_rls_this_style;
  IGRint        counter;

  IGRdouble     matrix_to_xh_space[4][4],
                matrix_from_xh_space[4][4];

  extern void       EFallolcRLTdata(),
                    EFsortDouble(),
                    EMpypoint_free(),
                    EMsfintedpar_free(),
                    EMsortpypts();
  extern IGRboolean EFsrf1uv_to_srf2uv(),
                    EFget_xh_sf_geom(),
                    EFgetxh_tr_pts();

  /*
   * Initialize
   */

# if DEBUG
# define CLIP_TIMER 0
# define GEOM_TIMER 1
# define TRIM_TIMER 2
# define LPTRIM_TIMER 3
# define BSTRIM_TIMER 4
# define MATRIM_TIMER 5
# define PYTRIM_TIMER 6
  init_timer(CLIP_TIMER);
  init_timer(GEOM_TIMER);
  init_timer(TRIM_TIMER);
  init_timer(LPTRIM_TIMER);
  init_timer(BSTRIM_TIMER);
  init_timer(MATRIM_TIMER);
  init_timer(PYTRIM_TIMER);
  fprintf (stderr, "Start of EMclip, CLIP_TIMER\n");
  start_timer(CLIP_TIMER);
# endif

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  clip_pt_buffer_size = /* EMS_CLIP_BUFF_SIZE */
  clip_value_buffer_size = EMS_CLIP_BUFF_SIZE;
  rule_index = 0;
  clip_pts = NULL;
  clip_values = NULL;

  /*
   * Clear the clip point buffer
   */
  {
    IGRint      bytes;
    IGRchar     zero = 0;

    bytes = sizeof(struct EMSpypoint) * EMS_CLIP_BUFF_SIZE;
    clip_pt_buffer = (struct EMSpypoint *)
                     memset((IGRchar *)EMSclipPypointBuffer, zero, bytes);
  }
  clip_value_buffer = EMSclipValueBuffer;
  sizeof_double = sizeof(IGRdouble);
  to_Ploop.type = OM_e_addr;
  to_Ploop.u_sel.addr = &me^^EMShelper.to_requesters;
  Ploop = NULL_OBJID;

  sts = om$send(msg = message EMSloop.EMget_objid(EMmsg, &Ploop),
                p_chanselect = &to_Ploop, from = 1, to = 1);
  if (sts == OM_E_NOSUCHOBJ) sts = OM_S_SUCCESS;
  if(! (1 & *EMmsg & sts)) goto wrapup;

  if(Ploop IS NULL_OBJID)
  {
    sts = om$construct(classid = OPP_EMSloop_class_id,
                       p_objid = &Ploop, msg = message
                       EMSloop.EMmake_natural_loop(EMmsg, 
                       NULL, NULL, NULL));
    if(! (1 & *EMmsg & sts)) goto wrapup;
    Ploop_constructed = TRUE;
  }
  else
  {
    sts = om$send (msg = message EMSboundary.EMtpcopy (EMmsg, NULL, 
                    OM_Gw_current_OS, OM_Gw_current_OS, NULL, &Ploop),
                   targetid = Ploop);
    if (!(1 & sts & *EMmsg)) goto wrapup;
  }

  /*
   * Get the world coordinate plane and the cross hatch plane
   */

# if DEBUG
  fprintf (stderr, "Start getting Geometry, GEOM_TIMER\n");
  start_timer(GEOM_TIMER);
# endif

  if(! surface)
  {
    OM_S_CHANSELECT to_requesters;

    to_requesters.type = OM_e_addr;
    to_requesters.u_sel.addr = &me^^EMShelper.to_requesters;
    sts = om$send(msg = message GRvg.GRgenabsg(
                    EMmsg,
                    mx_type,
                    mx,
                    (IGRchar **) &surface),
                  p_chanselect = &to_requesters,
                  from = 0, to = 0);
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }
  plane = surface;

  {
    IGRint  total_bytes;

    EMSbs_size(plane->u_order,
               plane->v_order,
               plane->u_num_poles,
               plane->v_num_poles,
               plane->rational,
               0,
               (IGRlong *)NULL,
               total_bytes)

    ems$get_memory(rc =             EMmsg,
                   num_elements =   total_bytes,
                   buffer =         EMScrossHatchPlaneBuffer,
                   buffer_size =    CROSS_HATCH_PLANE_BUFFER_SIZE,
                   ptr =            (IGRchar **) &xh_plane);
    if(! (1 & *EMmsg)) goto wrapup;
    EMSmsgReport(*EMmsg, "Get cross hatch plane memory",
                 *EMmsg IS EMS_I_DynamicMemoryAllocated);

    EMSbs_partition(plane->u_order,
                    plane->v_order,
                    plane->u_num_poles,
                    plane->v_num_poles,
                    plane->rational,
                    0,
                    (IGRlong *)NULL,
                    xh_plane)
  }

  EFget_xh_sf_geom(EMmsg, me->angle, NULL, NULL, plane, xh_plane);

  /*
   * Get the matrices to and from the cross hatch space
   */
  EFsrf1uv_to_srf2uv(plane, xh_plane, matrix_to_xh_space, EMmsg);
  if(! (1 & *EMmsg)) goto wrapup;
  EFsrf1uv_to_srf2uv(xh_plane, plane, matrix_from_xh_space, EMmsg);
  if(! (1 & *EMmsg)) goto wrapup;

      /*
       * If partol_basis is not valid, get it.
       */
      if(! partol_basis->is_valid)
      {
        IGRboolean        world = TRUE;
        OM_S_CHANSELECT   to_requesters;

        to_requesters.type = OM_e_addr;
        to_requesters.u_sel.addr = &me^^EMShelper.to_requesters;
        sts = om$send(msg = message EMSsubbs.EMpartolbasis(EMmsg,
                      partol_basis->mattyp, partol_basis->mat,
                      &world, FALSE, &partol_basis->tol),
                      p_chanselect = &to_requesters, from = 0, to = 0);
        if(! (1 & *EMmsg & sts)) goto wrapup;
      }

  sts = om$send (msg = message EMSboundary.EMuv_transform (EMmsg,
                  (IGRdouble *)matrix_to_xh_space, partol_basis, EMS_TF_TRANSFORM_NE,
                  NULL, NULL),
                 targetid = Ploop);
  if (!(1 &sts & *EMmsg)) goto wrapup;

# if DEBUG
  fprintf (stderr, "Stop of getting geometry, GEOM_TIMER\n");
  stop_timer(GEOM_TIMER, NULL, NULL);
# endif

  /*
   * Set and store the size of the VLA's.
   */
  total_rules = rlt->u_rules + rlt->v_rules;
  clip_index = 0;

  short_VLA_size = total_rules;
  if(me->props & EMGD_ALTDISPLAY)
  {
    alt_display[0] = me->short_data[short_VLA_size ++];
    alt_display[1] = me->short_data[short_VLA_size ++];
  }

  if(short_VLA_size > OM_DIMENSION_OF(me->short_data))
    OM_SET_DIMENSION(me->short_data, short_VLA_size);
  else
    short_VLA_size = OM_DIMENSION_OF(me->short_data);

  double_VLA_size = total_rules + VLA_INCREMENT;
  if(double_VLA_size > OM_DIMENSION_OF(me->double_data))
    OM_SET_DIMENSION(me->double_data, double_VLA_size);
  else
    double_VLA_size = OM_DIMENSION_OF(me->double_data);

  /*
   * Find the clip points
   */
  rules = rlt->u_rules;
  num_bound = (IGRshort *) ( me->short_data );
  bdrys = me->double_data + total_rules;
  rule_values = rlt->u_rule_values;
  varying_index = V;
  constant_index = U;
  sgrp_index = 0;
  num_rls_this_style = me->sgrp_info[0].num_rls_this_style;
  me->sgrp_info[0].num_rls_this_style = 0;
  counter = 0;

  for(l = 0; l < 2; l ++)
  {
    for(i = 0; i < rules; i ++, counter ++)
    {
      num_clips = 0;
      if(counter IS num_rls_this_style)
      {
        num_rls_this_style =
          me->sgrp_info[++ sgrp_index].num_rls_this_style;
        me->sgrp_info[sgrp_index].num_rls_this_style = 0;
        counter = 0;
      }

      /* 
       * Set up the polyline and range
       */
      rule_line.num_points = 2;
      rule_line.points = my_pts;
      my_pts[varying_index] = 0.0;
      my_pts[varying_index + PTSIZE] = 1.0;
      my_pts[constant_index] =
        my_pts[constant_index + PTSIZE] = rule_values[i];
/*
      (void)EFgetxh_tr_pts(EMmsg, 2, my_pts, matrix_from_xh_space);
      if(! (1 & *EMmsg)) goto wrapup;
*/
      if(my_pts[0] < my_pts[2])
      {
        range[0] = my_pts[0];
        range[2] = my_pts[2];
      }
      else
      {
        range[0] = my_pts[2];
        range[2] = my_pts[0];
      }
      if(my_pts[1] < my_pts[3])
      {
        range[1] = my_pts[1];
        range[3] = my_pts[3];
      }
      else
      {
        range[1] = my_pts[3];
        range[3] = my_pts[1];
      }
      EM2dbxinc(range, partol_basis->tol)

      /*
       * Find the clip points
       */
      clip_pts = clip_pt_buffer;
      EFinitPyPoints(clip_pts, clip_pt_buffer_size);

# if DEBUG
  start_timer(TRIM_TIMER);
# endif

      sts = om$send(msg = message EMSloop.EMlppytrimint(
                        EMmsg,
                        &rule_line,
                        range,
                        partol_basis,
                        2,
                        OPTIONS,
                        &num_clips,
                        NULL,
                        &clip_pts),
                    targetid = Ploop); 
      if(! (1 & *EMmsg & sts)) goto wrapup;

# if DEBUG
  stop_timer(TRIM_TIMER, NULL, NULL);
# endif

      if(num_clips)
      {
        IGRint      add_end,
                    add_begin,
                    end_index;
        IGRdouble   *from_ptr,
                    *to_ptr;

        /*
         * Maintain the clip buffers
         */
        if(num_clips > clip_pt_buffer_size)
          clip_pt_buffer_size = num_clips;

        if(num_clips * 2 > clip_value_buffer_size)
        {
          clip_value_buffer_size = num_clips * 2;
          if(clip_value_buffer ISNT EMSclipValueBuffer)
            om$dealloc(ptr = clip_value_buffer);
          clip_value_buffer = (IGRdouble *) om$malloc(
                                        size=clip_value_buffer_size  * 
                                        sizeof_double);
          if(! clip_value_buffer)
            { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
        }
        clip_values = clip_value_buffer;

        /*
         * Put the clip points in the local array
         */
        this_pt = clip_pts;
        to_ptr = clip_values;
        ambiguous = FALSE;

        for(j = 0; j < num_clips; j ++)
        {
          if (this_pt->props & EMS_PYPT_RELUNKNOWN)
          {
            ambiguous = TRUE;
            break;
          }

          *to_ptr ++ = this_pt->point[0];
          *to_ptr ++ = this_pt->point[1];
          this_pt = this_pt->next;
        }

        /*
         * KLUGE KLUGE KLUGE
         */
        if (ambiguous)
        {
          IGRint                toginfo = EMS_L_UNKNWN;
          struct EMSdataselect  loopdata;
          struct EMSdataselect  ingeom;
          struct EMSpypoint     *tpyptr;
          struct GRid           loopid;
          IGRint                noint;
          void                  EMcollect_mpy(),
                                EMsortpyptsl();

          loopid.objid = Ploop;
          loopid.osnum = OM_Gw_current_OS;
          loopdata.datatype = EMSdata_object;
          loopdata.data.object = &loopid;
          ingeom.datatype = EMSdata_poly2d;
          ingeom.data.poly = &rule_line ;
   
          EMsortpyptsl(EMmsg,
                       &clip_pts,
                       2,
                       &toginfo,
                       partol_basis,
                       &loopdata,
                       &ingeom,
                       OPTIONS,
                       &noint);
          if(! (1 & *EMmsg)) goto wrapup;

          num_clips = noint;
          this_pt = clip_pts;
          to_ptr = clip_values;

          for(j = 0; j < num_clips; j ++)
          {
            *to_ptr ++ = this_pt->point[0];
            *to_ptr ++ = this_pt->point[1];
            this_pt = this_pt->next;
          }

          /*
           * Initialise the clip pt buffer again since the linked list
           * might have been broken.
           */
          if(clip_pt_buffer_size > EMS_CLIP_BUFF_SIZE)
          {
            EMcollect_mpy(clip_pts,&tpyptr);
            EMpypoint_free(tpyptr,NULL);
            clip_pt_buffer_size = EMS_CLIP_BUFF_SIZE;
          }

          { 
            IGRint      bytes;
            IGRchar     zero = 0;

            bytes = sizeof(struct EMSpypoint) * EMS_CLIP_BUFF_SIZE;
            clip_pt_buffer = (struct EMSpypoint *)
              memset((IGRchar *)EMSclipPypointBuffer,zero,bytes);
            clip_pt_buffer[EMS_CLIP_BUFF_SIZE - 1].next = NULL;
          }
        }

        if(num_clips && (!(num_clips % 2)))
        {
          /*
           * Transform the clip points to the cross hatch space.
           */
/*
          (void)EFgetxh_tr_pts(EMmsg,
                               num_clips,
                               clip_values,
                               matrix_to_xh_space);
          if(! (1 & *EMmsg)) goto wrapup;

*/
          /*
           * Set the rule value
           */
          me->double_data[rule_index] = rule_values[i];

          /*
           * Increment the num_rls_this_style counter
           */
          me->sgrp_info[sgrp_index].num_rls_this_style ++;

          /*
           * Compress the clip points
           */
          {
            IGRint    i, j;

            for(i = 0, j = varying_index; i < num_clips; i ++, j += 2)
              clip_values[i] = clip_values[j];
          }

          /*
           * Sort the clip points
           */
          EFsortDouble(clip_values, num_clips);

          /*
           * Determine add_begin and add_end
           */
          if(clip_values[0] IS 0.0) add_begin = -1;
          else add_begin = 1;
          if(clip_values[num_clips - 1] IS 1.0) add_end = -1;
          else add_end = 1;

          /*
           * Make shure there is enough room for the clip points
           * in the double_data VLA
           */
          if(double_VLA_size < total_rules + clip_index + num_clips +
                               add_begin + add_end)
          {
            double_VLA_size = total_rules + clip_index + num_clips +
                              add_begin + add_end;
            double_VLA_size += VLA_INCREMENT;
            OM_SET_DIMENSION(me->double_data, double_VLA_size);
            num_bound = (IGRshort *) me->short_data;
            bdrys = me->double_data + total_rules;
          }

          /*
           * Put the clip points into the instance data
           */
          from_ptr = clip_values;
          to_ptr = &bdrys[clip_index];
          end_index = num_clips - 1;
          num_bytes = num_clips * sizeof_double;

          if(add_begin IS 1)
          {
            /*
             * Add zero to the beginning
             */
            to_ptr[0] = 0.0;
            to_ptr ++;
            end_index ++;
          }
          else { from_ptr ++; num_bytes -= sizeof_double; }

          if(add_end IS 1) to_ptr[end_index] = 1.0;
          else num_bytes -= sizeof_double;

          if(num_bytes) OM_BLOCK_MOVE(from_ptr, to_ptr, num_bytes);

          num_bound[rule_index] = (IGRshort)
                                  (num_clips + add_begin + add_end) / 2;
          clip_index +=
            (IGRint)(num_bound[rule_index] + num_bound[rule_index ++]);

        } /* if num_clips (after ambiguous checks) */

      } /* if num_clips */

    } /* end for i */

    /*
     * Set number of u or v rules
     */
    if(l IS U)
     if(rule_index > 255)
      {
       me->num_u_rules = 0;
       if(OM_Gf_verbose_warning)
         fprintf (stderr, "me->num_u_rules overflow  EMSchatch.EMclip\n");
      }
     else  
       me->num_u_rules = rule_index;
    else 
     if((rule_index - me->num_u_rules) > 255)
      {
       me->num_v_rules = 0;
       if(OM_Gf_verbose_warning)
         fprintf (stderr, "me->num_v_rules overflow  EMSchatch.EMclip\n");
      }
     else
       me->num_v_rules = rule_index - me->num_u_rules;

    /*
     * Set up to work on the V data
     */
    rules = rlt->v_rules;
    rule_values = rlt->v_rule_values;
    varying_index = U;
    constant_index = V;
  } /* end for l */

  /*
   * Move the double_data back and reset the VLA sizes
   */
  {
    IGRint      num_bytes;
    IGRdouble   *from_ptr, *to_ptr;

    if(rule_index != total_rules)
    {
      from_ptr = me->double_data + total_rules;
      to_ptr = me->double_data + rule_index;
      num_bytes = clip_index * sizeof_double;
      OM_BLOCK_MOVE(from_ptr, to_ptr, num_bytes);
    }

    double_VLA_size = rule_index + clip_index;
    if(OM_DIMENSION_OF(me->double_data) != double_VLA_size)
      OM_SET_DIMENSION(me->double_data, double_VLA_size);

    short_VLA_size = rule_index;
    if(me->props & EMGD_ALTDISPLAY) short_VLA_size += 2;
    if(OM_DIMENSION_OF(me->short_data) != short_VLA_size)
      OM_SET_DIMENSION(me->short_data, short_VLA_size);

    if(me->props & EMGD_ALTDISPLAY)
    {
      me->short_data[short_VLA_size - 2] = alt_display[0];
      me->short_data[short_VLA_size - 1] = alt_display[1];
    }
  }

  me^^EMShelper.props |= EMGD_UPTODATE;

wrapup:

# if DEBUG
  stop_timer(CLIP_TIMER, NULL, NULL);
  fprintf (stderr, "End of EMclip, CLIP_TIMER\n");
  total_timer(CLIP_TIMER, "Clip timer: ");
  total_timer(GEOM_TIMER, "Geom timer: ");
  total_timer(TRIM_TIMER, "Trim timer: ");
  total_timer(LPTRIM_TIMER, "Lp: Trim timer: ");
  total_timer(BSTRIM_TIMER, "Bs: Trim timer: ");
  total_timer(MATRIM_TIMER, "Ma: Trim timer: ");
  total_timer(PYTRIM_TIMER, "Py: Trim timer: ");
# endif

  /*
   * If the clip values array was allocated, free it
   */
  if(clip_value_buffer && (clip_value_buffer != EMSclipValueBuffer))
    om$dealloc(ptr = clip_value_buffer);

   {
    IGRlong sts;

    sts = om$send(msg = message Root.delete(1), targetid = Ploop);
/*  if(! (1 & sts)) goto wrapup; */
   }

  /*
   * If there are more than the original buffer of clip points,
   * free the allocated points
   */
  if(clip_pt_buffer_size > EMS_CLIP_BUFF_SIZE)
  {
    clip_pt_buffer_size -= EMS_CLIP_BUFF_SIZE;
    EMpypoint_free(clip_pt_buffer[EMS_CLIP_BUFF_SIZE - 1].next,
                   clip_pt_buffer_size);
  }

  EMWRAPUP(*EMmsg, sts, "EMSchatch.EMclip")
  return(sts);
}

end implementation EMSchatch;
