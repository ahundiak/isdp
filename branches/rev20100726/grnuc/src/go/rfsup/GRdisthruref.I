class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"

from GRcontext import GRgetinstance;
from GRreffile import GRgetlevels;

#define NO_RANGE_KEY 0
%safe
static int ACdisplay_on = 0;
%endsafe
ACset_disthruref ()
{
  return ACdisplay_on = 1;
}


ACreset_disthruref ()
{
  return ACdisplay_on = 0;
}


int ACreturn_disthruref ()
{
  return ACdisplay_on;
}


long GRdisthruref ( msg, display_msg, graphics_object )
long		*msg;
OM_S_MESSAGE	*display_msg;
struct GRid	*graphics_object;
{
  IGRboolean          world, ref_object, reset, outside_window, level_on, displaying_reffile_object;
  short               objects_mx_type, attachments_mx_type, flag, orig_flag, reffile_level,
                      num_opens, num_opens_processed;
  long                OMmsg, msg1;
  int                 i, k, count, displaying_in_reffile, old_levels [32], levels [32],
                      comp_levels [32], *lev_ptr;
  IGRmatrix           objects_context_matrix, attachments_context_matrix;
  OM_S_CHANSELECT     super_chan, context_chan, reffile_chan;
  GRrange             saved_range, old_range, range;
  GRspacenum          osnum1, osnum;
  struct GRsymbology  symb, test_symb;
  struct GRid         Super, previous_context, nested_context, reffile_id;
  OMuword             classid;
  OM_S_OBJECT_LINKAGE objid_list;

  struct display_args_struct
  {
    long    *msg;
    short  *type;
    double  *matrix;
    enum GRdpmode   *mode;
    struct IGRdisplay *alt_symb;
    struct DP_information *dp_info;
    OM_p_KEY_DESC  *key;
  } *display_args;

  OMmsg = OM_S_SUCCESS;
  *msg = MSSUCC;
  reffile_level = 0;

  if (ACdisplay_on)
  {
    /* special case for macro => call display directly */
    display_args = (struct display_args_struct *) display_msg->p_arglist;
    OMmsg = om$send ( msg = message GRgraphics.GRdisyourself
        ( msg,
        display_args->type,
        display_args->matrix,
        display_args->mode,
        (struct IGRaltdisplay *)display_args->alt_symb,
        display_args->dp_info, 
        NO_RANGE_KEY ),
        senderid = graphics_object->objid,
        targetid = graphics_object->objid,
        targetos = graphics_object->osnum);
    return OMmsg;
  }

  reset = FALSE;

  OMmsg = GRgetctxsuper(msg,&Super);

  if ( 1 & OMmsg & *msg)
  {        /* set up channel information  */
    om$make_chanselect(p_chanselect = &super_chan,
        channame = "Super_rfmgr.to_context");
    om$make_chanselect(p_chanselect = &context_chan,
        channame = "GRcontext.to_nested_files");
    om$make_chanselect(p_chanselect = &reffile_chan,
        channame =  "GRcontext.to_reffile");

    display_args = (struct display_args_struct *) display_msg->p_arglist;

    saved_range[0] = display_args->dp_info->gragad->dit_clip_range[0];
    saved_range[1] = display_args->dp_info->gragad->dit_clip_range[1];
    saved_range[2] = display_args->dp_info->gragad->dit_clip_range[2];
    saved_range[3] = display_args->dp_info->gragad->dit_clip_range[3];
    saved_range[4] = display_args->dp_info->gragad->dit_clip_range[4];
    saved_range[5] = display_args->dp_info->gragad->dit_clip_range[5];

    world = TRUE;      /* range flag      */

    num_opens = 0;
    num_opens_processed = 0;

    GRget_num_opens(msg1,graphics_object->osnum,num_opens);

    if (!( 1 & msg1))
    {
      OMmsg = OM_E_ABORT;
      *msg = MSFAIL;
      goto wrapup;
    }

    OMmsg = om$get_channel_count(
        p_chanselect = &super_chan,
        osnum = Super.osnum,
        objid = Super.objid,
        count = (OMuint *)&count);

    if ( 1 & OMmsg)
    {
      reset = FALSE;

      if ( count )
      {
        /* get the object's symbology */
        OMmsg = om$send(msg = message GRvg.GRgetsymb(msg,&symb),
            senderid = graphics_object->objid,
            targetid = graphics_object->objid,
            targetos = graphics_object->osnum);

        if ( ! (1 & OMmsg & *msg))
          goto wrapup;
      }

      om$get_classid(osnum=graphics_object->osnum,
          objid = graphics_object->objid,
          p_classid = &classid);

      OMmsg = om$is_ancestry_valid(superclassname = "GRreffile",
          subclassid=classid);

      ref_object = TRUE;

      if (OMmsg == OM_I_INVANCESTRY)
      {
        OMmsg = om$is_ancestry_valid(superclassname = "GRclippoly",
            subclassid=classid);

        if (OMmsg == OM_I_INVANCESTRY)
        {
          ref_object = FALSE;
        }
      }

      for (i=0; ((i < count) && (num_opens_processed < num_opens)); ++i)
      {
        OMmsg = om$send(mode = OM_e_wrt_object,
            msg = message GRcontext.GRgetinstance
            (msg,&objects_mx_type,objects_context_matrix,
            &osnum1,&orig_flag,&previous_context),
            senderid = Super.objid,
            p_chanselect = &super_chan,
            from = i,
            to = i);

        if ( (1 & OMmsg) && 
            ((orig_flag & GRACTIVATED_CONTEXT) || (orig_flag & GRMASTER_CONTEXT)) )
        {
          /* If the object to be displayed is in this object
           * space, we must determine the clipping window
           * for this object.  To do this the range of all
           * nested attachments is computed and a final
           * minimum clip range stored in the window information
           * structure.
           */

          if (graphics_object->osnum == osnum1)
          {
            ++num_opens_processed;

            if (orig_flag & GRCYCLIC_ATTACHMENT)
            {
              /* if this object is a clipping polygon or reffile do not display it */
              if (ref_object)
                continue;
              k=0;
              GRset_expansion_mode ( &k );
            }

            outside_window = FALSE;
            displaying_reffile_object = FALSE;
            level_on = TRUE;
            displaying_in_reffile = 0;

            OMmsg = om$get_channel_objects(
                osnum = previous_context.osnum,
                objid = previous_context.objid,
                p_chanselect = &reffile_chan,
                list = &objid_list,
                size = 1,
                count = (OMuint *)&displaying_in_reffile);

            if (displaying_in_reffile)
            {
              /* a check must be made to determine if the
               * object to be displayed is the reference file
               * object */
              reffile_id.objid = objid_list.S_objid;
              reffile_id.osnum = objid_list.osnum;

              if ((graphics_object->osnum ==reffile_id.osnum) && 
                  (graphics_object->objid==reffile_id.objid))
                displaying_reffile_object = TRUE;

              om$send ( msg = message GRreffile.GRgetlevels ( msg, levels ),
                  senderid = reffile_id.objid,
                  targetid = reffile_id.objid,
                  targetos = reffile_id.osnum );

              om$send( msg = message GRvg.GRgetsymb ( msg, &test_symb ),
                  senderid = reffile_id.objid,
                  targetid = reffile_id.objid,
                  targetos = reffile_id.osnum);

              reffile_level = test_symb.level;

              if (!(DPlevel_check(symb.level,levels)))
                level_on = FALSE;
            }

            /* check to see if this object is nested. 
             * If it is, loop backwards thru context 
             * objects to:
             * 1) compute the ranges of the 
             *    attachments and compute the minimum 
             *    range 
             * 2) see if the levels of the attachments
             *    are on
             * until all nested objects are processed.
             * If a cyclic attachment is encountered, do
             * not display this object.  No further reference
             * file expansion is allowed for a cyclic 
             * attachment encountered in the nested files.
             * The cyclic attachment flag is not checked
             * for the initial GRgetinstance because it is
             * legal to display the graphics in 1 level deep
             * cyclic attachments.
             */

            flag = orig_flag;

            while ( (! (flag & GRMASTER_CONTEXT)) && (level_on))
            { 
              /* get the context information  */
              OMmsg = om$send ( msg = message GRcontext.GRgetinstance
                  (&msg1,&attachments_mx_type,
                  attachments_context_matrix,
                  &osnum,&flag,&nested_context),
                  senderid = previous_context.objid,
                  p_chanselect = &context_chan,
                  to = 0,
                  from = 0);

              if ((1 & OMmsg & msg1) && 
                  (OMmsg != OM_I_CHAN_EMPTY))
              {
                if (flag & GRCYCLIC_ATTACHMENT)
                {
                  /* no display is to occur for this graphic object. This context is
                   * a nested cyclic attachment. */
                  outside_window = TRUE;
                  break;
                }
                else 
                if (! displaying_reffile_object)
                {
                  /* get range of the reference file object. */
                  OMmsg = om$send ( msg = message GRvg.GRgetrang
                    (&msg1,&attachments_mx_type,
                    attachments_context_matrix,
                    &world,range ),
                    senderid = previous_context.objid,
                    p_chanselect = &reffile_chan,
                    from = 0,
                    to = 0);

                  if (OMmsg == OM_I_CHAN_EMPTY)
                  {
                    /* The ref objects is not there anymore, break but mark this
                       one as unprocessed */
                    num_opens_processed--;
                    outside_window = TRUE;
                    OMmsg = 1;
                    break;
                  }

                  /* see if the reference file header is on a level that is on. */
                  if ( flag & GRMASTER_CONTEXT)
                  {
                    lev_ptr = display_args->dp_info->gragad->levels;
                  }
                  else
                  {
                    om$send(
                        msg = 
                        message GRreffile.GRgetlevels
                        (msg,comp_levels),
                        senderid =nested_context.objid,
                        targetos =nested_context.osnum,
                        p_chanselect = &reffile_chan,
                        from = 0,
                        to = 0);
                  
                    lev_ptr = comp_levels;
                  }
                  if(!(DPlevel_check
                      (reffile_level,lev_ptr)))
                  {
                    level_on = FALSE;
                    break;
                  }
                  
                  if ( 1 & OMmsg)
                  {
                    dp$inter_clip_range
                        (msg = &msg1,
                        old_range = old_range,
                        range = range,
                        dp_info = display_args->dp_info);
                  
                    if ( 1 & msg1)
                    {
                      /* BLOCK START - Added by Ashok 20-Nov-1990 */
                      /* If view is perspective then reset the viewport clipping range */
                      if(display_args->dp_info->gragad->
                          flags & IS_PERSP)
                        dp$reset_clip_range(
                            msg = &msg1,
                            old_range = saved_range,
                            dp_info = display_args->dp_info);
                  
                      else
                        /* BLOCK END */
                        reset = TRUE;
                  
                      previous_context.objid = 
                          nested_context.objid;
                      previous_context.osnum =
                          nested_context.osnum;
                      if (!(flag & GRMASTER_CONTEXT))
                      {
                        om$send(
                            msg=message 
                            GRvg.GRgetsymb(msg,&test_symb),
                            senderid =nested_context.objid,
                            targetos =nested_context.osnum,
                            p_chanselect = &reffile_chan,
                            from = 0,
                            to = 0);
                  
                        reffile_level=test_symb.level;
                      }
                  
                    }
                    else /* outside range of window*/
                    {
                      outside_window = TRUE;
                      break;
                    }
                  }
                }
                else
                {
                  objects_mx_type = attachments_mx_type;
                  for ( k=0; k<16; ++k)
                  {
                    objects_context_matrix[k] = 
                        attachments_context_matrix[k];
                  }
                  displaying_reffile_object = FALSE;
                  previous_context = nested_context;
                  if (!(flag & GRMASTER_CONTEXT))
                  {
                    om$send(
                        msg=message 
                        GRvg.GRgetsymb(msg,&test_symb),
                        senderid =nested_context.objid,
                        targetos =nested_context.osnum,
                        p_chanselect = &reffile_chan,
                        from = 0,
                        to = 0);
                
                    reffile_level=test_symb.level;
                  }
                }
              }
            }
            
            if ( (! outside_window) && (level_on))
            {
              if (displaying_in_reffile)
                /* change the window levels for the reference file display */
                DPset_levels ( old_levels, levels, display_args->dp_info );

              OMmsg = om$send ( msg = message GRgraphics.GRdisyourself
                  (display_args->msg,&objects_mx_type,
                  objects_context_matrix,
                  display_args->mode,
                  (struct IGRaltdisplay *)display_args->alt_symb,
                  display_args->dp_info,NO_RANGE_KEY),
                  senderid = graphics_object->objid,
                  targetid = graphics_object->objid,
                  targetos = graphics_object->osnum);

              if (displaying_in_reffile)
                /* reset the window levels */
                DPreset_levels ( old_levels, display_args->dp_info );
            }
            
            if (orig_flag & GRCYCLIC_ATTACHMENT)
            {
              k=1;
              GRset_expansion_mode(&k);
            }
            
            if (reset)
            {
              dp$reset_clip_range ( msg = &msg1, old_range = saved_range,
                  dp_info = display_args->dp_info );
              reset =  FALSE;
            }
          }
        }
      }
    }
  }

wrapup:

  return OMmsg;
}

end implementation GRvg;
