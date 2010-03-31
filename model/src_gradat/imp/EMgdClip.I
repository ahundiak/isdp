/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "EMS.h"
# include <memory.h>        /* memset           */

#include  <stdio.h>         /* stderr           */

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

# ifndef emsmacros_include
# include "emsmacros.h"     /* EM2dbxinc        */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE   */
# endif
# include "emsdattyp.h"
# include "emsdef.h"
# include "emsinterdef.h"

# define U 0                /* Index of u                       */
# define V 1                /* Index of v                       */
# define PTSIZE 2           /* Point size                       */
# define VLA_INCREMENT 40   /* Temp buffer size                 */

from EMSsubbs import EMpartolbasis;
from EMSloop import EMget_objid, EMlppytrimint;

struct EMSpypoint   EMSclipPypointBuffer[EMS_CLIP_BUFF_SIZE];
IGRdouble           EMSclipValueBuffer[EMS_CLIP_BUFF_SIZE];

extern OMuint       OM_Gf_verbose_warning;

method EMclip(IGRlong *EMmsg; struct IGResqbs *rlt;
                 struct EMSpartolbasis *partol_basis; IGRshort *mx_type;
                 IGRmatrix mx; struct IGRbsp_surface *surface)
/*
History

    msm 03 Oct 92       ANSI-C conversion.    
   Jack 07 Apr 92       if me->num_[uv]_rules gets set to something
                        greater than 255, set it to zero and send warning. 
    SS  09 Mar 89       Undid the ill-effects of removing the REMZEROEND
			option from the lppytrimint mask by calling the
			special end-intersection processing function.
    SS  21 Feb 89       Removed the REMZEROEND option from the lppytrimint
			mask. Also an ambiguous case is now construed if
			the number of clip points is odd.
    AIC 04 Jan 89       Maintain the alternate display info at
                        the end of the short_data VLA.
    AIC 28 Apr 88       Changed EMFRT_UPTODATE to EMGD_UPTODATE.
    PP  02/22/88        Added logic to process ambiguous intersections
                        returned from loop trim.
    AIC 15-Jul-1987     Creation Date
*/
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

  IGRint        varying_index;
  IGRint        constant_index;
  IGRint        rules;
  IGRboolean    ambiguous;
  IGRshort      *num_bound;
  IGRdouble     *rule_values;
  IGRdouble     *bdrys,
                *clip_value_buffer,     /* Clip value buffer    */
                *clip_values;           /* Clip value array     */

  void EFallolcRLTdata(), EFsortDouble();
  extern   void EMpypoint_free();
  extern void   EMsfintedpar_free(), EMendint_process();

  /*
   * Initialize
   */
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
                     memset((IGRchar *)EMSclipPypointBuffer,zero,bytes);
  }
  clip_value_buffer = EMSclipValueBuffer;
  sizeof_double = sizeof(IGRdouble);
  to_Ploop.type = OM_e_addr;
  to_Ploop.u_sel.addr = &me^^EMShelper.to_requesters;
  sts = om$send(msg = message EMSloop.EMget_objid(EMmsg, &Ploop),
                p_chanselect = &to_Ploop);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  /*
   * Set and store the size of the VLA's, and the alternate
   * display attributes.
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
  num_bound = (IGRshort *)me->short_data;
  bdrys = me->double_data + total_rules;
  rule_values = rlt->u_rule_values;
  varying_index = V;
  constant_index = U;

  for(l = 0; l < 2; l ++)
  {
    for(i = 0; i < rules; i ++)
    {
      num_clips = 0;

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

      /* 
       * Set up the polyline and range
       */
      rule_line.num_points = 2;
      rule_line.points = my_pts;
      my_pts[varying_index] = 0.0;
      my_pts[varying_index + PTSIZE] = 1.0;
      my_pts[constant_index] =
      my_pts[constant_index + PTSIZE] = rule_values[i];
      OM_BLOCK_MOVE(my_pts, range, 2 * PTSIZE * sizeof_double);
      EM2dbxinc(range, partol_basis->tol)

      /*
       * Find the clip points
       */
# define OPTIONS EMS_INTER_BDRYISAREA | EMS_INTER_CUTTING | \
                 EMS_INTER_STARTPT | EMS_INTER_STOPPT

      clip_pts = clip_pt_buffer;
      EFinitPyPoints(clip_pts, clip_pt_buffer_size);
      sts = om$send(msg = message EMSloop.EMlppytrimint(EMmsg,
                    &rule_line, range, partol_basis, 2, 
                    OPTIONS, &num_clips, NULL, &clip_pts),
                    targetid = Ploop);
      if(! (1 & *EMmsg & sts)) goto wrapup;

      if(num_clips)
      {
        /*
         * The option to remove "zero-ends" was not excercised when computing
         * intersections. This was done to postpone the decision so that the
         * global topology (of the P-loop) w.r.t. to the input-geometry is
         * made use of. Basically: a) if there is more than one intersection
         * at the end-point then no "zero-ends" are removed from that 
         * end-point. The boundary forming is performed treating this case
         * as ambiguous via a function which takes into account the 
         * loop-topology; b) but if there is only one intersection at an
         * end-point and it is a "zero-end", it is removed and the logic
         * proceeds normally. 
         * N.B.: For an explanation of what is a "zero-end", see the include
         *       file - emsinterdef.h
         */

        EMendint_process (EMmsg, &num_clips, &clip_pts);
        ambiguous = *EMmsg == EMS_I_Ambiguous;

        /*
         * Maintain the clip buffers
         */
        if(num_clips > clip_pt_buffer_size)
        {
          clip_pt_buffer_size = /* num_clips */
          clip_value_buffer_size = num_clips;
          if(clip_value_buffer ISNT EMSclipValueBuffer)
            om$dealloc(ptr = clip_value_buffer);
          clip_value_buffer = (IGRdouble *)om$malloc(size=num_clips * sizeof_double);
          if(! clip_value_buffer)
            { *EMmsg = EMS_E_NoDynamicMemory; goto wrapup; }
        }
        clip_values = clip_value_buffer;

        /*
         * Put the clip points in the local array
         */
        this_pt = clip_pts;
        if (!ambiguous)
        {
          for(j = 0; j < num_clips; j ++)
          {
            if (this_pt->props & EMS_PYPT_RELUNKNOWN)
            {
              ambiguous = TRUE;
              break;
            }
            clip_values[j] = this_pt->point[varying_index];
            this_pt = this_pt->next;
          }
        }

        if (ambiguous || num_clips % 2)
        {
          IGRint toginfo = EMS_L_UNKNWN;
          struct EMSdataselect loopdata;
          struct EMSdataselect ingeom;
          struct EMSpypoint *tpyptr;
          struct GRid loopid;
          IGRint noint;
          void EMsortpyptsl (), EMcollect_mpy();

          loopid.objid = Ploop;
          loopid.osnum = OM_Gw_current_OS;
          loopdata.datatype = EMSdata_object;
          loopdata.data.object = &loopid;
          ingeom.datatype = EMSdata_poly2d;
          ingeom.data.poly = &rule_line ;

          EMsortpyptsl (EMmsg,&clip_pts, 2, &toginfo,
                        partol_basis, &loopdata, &ingeom,
                        OPTIONS, &noint);
          if(! (1 & *EMmsg)) goto wrapup;
          num_clips = noint;
          this_pt = clip_pts;
          for(j = 0; j < num_clips; j ++)
          {
            clip_values[j] = this_pt->point[varying_index];
            this_pt = this_pt->next;
          }

          /*
           * Initialise the clip pt buffer again since the linked
           * list might have been broken.
           */

          if(clip_pt_buffer_size > EMS_CLIP_BUFF_SIZE)
          {
            EMcollect_mpy (clip_pts, &tpyptr);
            EMpypoint_free(tpyptr,NULL);
            clip_pt_buffer_size = EMS_CLIP_BUFF_SIZE;
          }

          { 
            IGRint      bytes;
            IGRchar     zero = 0;

            bytes = sizeof(struct EMSpypoint) * EMS_CLIP_BUFF_SIZE;
            clip_pt_buffer = (struct EMSpypoint *)
                      memset((IGRchar *)EMSclipPypointBuffer,zero,bytes);
          }

        } /* if ambiguous */

        /*
         * If the number of clip points is odd, ignore this rule
         * line.
         */
        if(! (num_clips % 2) && num_clips)
        {
          IGRint      add_end, add_begin, end_index;
          IGRdouble   *fromi, *toi;

          /*
           * Set the rule value
           */
          me->double_data[rule_index] = rule_values[i];

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
            num_bound = (IGRshort *)me->short_data;
            bdrys = me->double_data + total_rules;
          }

          /*
           * Put the clip points into the instance data
           */
          fromi = clip_values;
          toi = &bdrys[clip_index];
          end_index = num_clips - 1;
          num_bytes = num_clips * sizeof_double;

          if(add_begin IS 1)
          {
            /*
             * Add zero to the beginning
             */
            toi[0] = 0.0;
            toi ++;
            end_index ++;
          }
          else { fromi ++; num_bytes -= sizeof_double; }

          if(add_end IS 1) toi[end_index] = 1.0;
          else num_bytes -= sizeof_double;

          if(num_bytes) OM_BLOCK_MOVE(fromi, toi, num_bytes);

          num_bound[rule_index] = (IGRshort)
                                  (num_clips + add_begin + add_end) / 2;
          clip_index += (IGRint)
                       (num_bound[rule_index] + num_bound[rule_index ++]);

        } /* if even number of clip points */

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
         fprintf (stderr, "me->num_u_rules overflow  EMSgradata.EMclip\n");
      }
     else  
       me->num_u_rules = rule_index;
    else 
     if((rule_index - me->num_u_rules) > 255)
      {
       me->num_v_rules = 0;
       if(OM_Gf_verbose_warning)
         fprintf (stderr, "me->num_v_rules overflow  EMSgradata.EMclip\n");
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
    IGRdouble   *fromi, *toi;

    if(rule_index != total_rules)
    {
      fromi = me->double_data + total_rules;
      toi = me->double_data + rule_index;
      num_bytes = clip_index * sizeof_double;
      OM_BLOCK_MOVE(fromi, toi, num_bytes);
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
  /*
   * If the clip values array was allocated, free it
   */
  if(clip_value_buffer && (clip_value_buffer != EMSclipValueBuffer))
    om$dealloc(ptr = clip_value_buffer);

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

  EMSmsgReport(sts, "EMSgradata.EMclip", NULL);
  if EMSmsgReport(*EMmsg, "EMSgradata.EMclip", NULL) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSgradata;
