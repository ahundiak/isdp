/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

/*
DESCRIPTION

This method will activate me if I am an inactive state.  This is
done by changing topology and/or geometry I have saved with what
is currently active.

ALGORITHM

Get the SSI table.

Take out out_loops.

Put in in_loops.

Take out out_surfaces.

Set properties of the surfaces OFF.

Set my active bit on

RETURNED VALUES

EMS_S_Success is all is well.

HISTORY

03/03/92    DLB Added EFfix_parent_child_relationship call to fix up
                assoc graph when an associative surface is removed.

18 Apr 1989 jBk Added boolean variable "display" to cut down on
                pointer dereferencing and bitwise operations.

                Removed differentiation between EMjoiningActivate
                and EMdisjointActivate to make EMactivate handle
                both now that SSI tables are returned
                consistently from EMgetSSI, whether or not the
                internal representation of the SSI table is
                consistent in the instance data of the object.

28 Dec 1988 jBk Fixed mistake in conversion from explicit
                assignment of a message to the usage of
                om$make_message.

13 Sep 1988 AIC Replaced explicit assignment of message to
                om$make_message.
07/26/88    DLB Added code to (re)set inactive bit is surface props.
14-Apr-1988 jBk Use EMget_operation_type to determine if an
                orientation reversal is necessary.
                Subdivided into EMactivate, EMjoiningActivate and
                EMdisjointActivate.
04-Dec-1987 jBk Added orientation reversal for EMSbool_hollowDif.
11/03/87    DLB Modified for version 1.1.0.
29-Jul-1987 SM  Added check for EMSbool_saveside.
04/??/87    DLB Take care of reverse orient for difference
                operation and RMT changes.
??-???-1987 SM  Creation date.
*/

#include "EMS.h"
#include "EMSopt.h"
#include "OMmacros.h"
#include "emsdef.h" /* DPR_DISPLAY_BUFF_INCR */

#define BUFF_INCR DPR_DISPLAY_BUFF_INCR

from EMSloop import EMtreemod,EMgivenestinfo,EMactivate_loop;
from EMSsubbs import EMpartolbasis, EMpassloop;
from EMSboundary import EMget_objid, EMcheck_props;
from EMSloopset import EMnesting,EMtreemod,EMtoglpactive;
from EMSloop import EMset_props;

method EMjoiningActivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
    *EMmsg = EMS_E_Fail;

    return OM_E_MSGNOTSUPP;
}

method EMdisjointActivate (
    IGRlong *EMmsg;
    struct GRmd_env *env;
    IGRshort option;
    IGRboolean emptySet, firstOnly, allButFirst, lastOnly
)
{
    *EMmsg = EMS_E_Fail;

    return OM_E_MSGNOTSUPP;
}

method EMactivate (
    IGRlong *EMmsg;
    IGRshort *option;
    struct GRmd_env *env;
    GRobjid **display_ids; 
    IGRint *display_count
)
{
  IGRlong                   sts;
  IGRint                    i,j;
  GRobjid                   *lp_in,*lp_out,lpset,*sf_out;
  union EMSssi_table        *ssi;
  struct EMSboolssi_table   *my_info;
  struct GRid               temp_GRid;
  OM_S_CHANSELECT           to_loopset;
  struct EMSpartolbasis     partolbasis;
  struct EMSnest_info       nesting;
  IGRushort         props, ls_props, lp_props, ed_props;
  IGRboolean                world;
  IGRboolean                display;
  IGRboolean reverseOrientation, disjointSurfaces;
  IGRboolean emptySet;
  OM_S_OBJID nullSymbolId;

  /*Initialize.*/
  *EMmsg = EMS_S_Success;
  ssi = NULL;
  display = *option & EMS_DO_DISPLAY;

  sts = om$send (
    msg = message EMSsfboolean.EMget_operation_type (
        EMmsg,
        NULL,
        NULL,
        NULL,
        &reverseOrientation,
        &emptySet,
        &disjointSurfaces,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    ),
    targetid = my_id
  );

  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

  if (emptySet)
  {
    /* get empty set id */

    nullSymbolId = me^^EMSdpr.ids[0];
    me^^EMSdpr.ids[0] = my_id;

/*
    When all removed-operand booleans their SSI tables
    consistently in their instance data, the following "if"
    clause may be omitted.
*/

    if (NOT me^^EMSsfboolean.num_composites)
    {
        /*
            no composites indicated in ssi table instance data
            means this object has the inconsistent flavor of ssi
            table representation in its instance data; it needs
            to replace the first element of the me^^EMSdpr.ids
            array with its first child's id rather than its own.
        */

        IGRint childCount;

        sts = om$send (
            msg = message GRowner.GRget_number_components (
                EMmsg,
                &childCount
            ),
            targetid = my_id
        );

        EMerr_hndlr (!(1&sts), *EMmsg, EMS_E_Fail, wrapup);

        if (childCount)
        {
            /* at least one component */

            struct GRid zeroIndexChild;

/*
            send wrt message for class EMScomposite because I
            do not want the EMSsfdpr implementation of this
            message; that is, I do not necessarily want
            leaves but actual children 
*/

            sts = om$send (
                mode = OM_e_wrt_message,
                msg = message EMScomposite.GRget_components (
                    EMmsg,
                    env,
                    &zeroIndexChild,
                    1,
                    &childCount,
                    0,
                    OM_K_MAXINT
                ),
                targetid = my_id
            );

            if (childCount IS 1 AND EMSokay (sts) AND EMSokay (*EMmsg))
            {
                 me^^EMSdpr.ids[0] = zeroIndexChild.objid;
            }
            else
            {
                sts = OM_E_ABORT;
                *EMmsg = EMS_E_Fail;
                goto wrapup;
            }
        }
        else /* zero components; perhaps removed */
        {
            me^^EMSdpr.ids[0] = NULL_OBJID;
        }

    } /* fi no composites indicated in ssi table instance data */

  } /* fi get empty set id */

  sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  /*Send a message to myself to get the save state info table. -DLB*/
  sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                targetid = my_id);
  EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

  my_info = &ssi->bool_info;

  /* Take out the 'out_loops' from the corresponding loopsets.*/
  lp_out = my_info->region_out_ids;
  ls_props = NULL | EMLS_NATURAL;
  lp_props = NULL;
  ed_props = NULL;

  for(i=0;i<my_info->num_surfaces;i++)
   {
      /*Erase the surfaces that will be modified by the act -DLB*/
      if (display)
      {
        IGRint       inx;                  /*DECL*/
        IGRboolean got_it = FALSE;

        /*Has this surface already been erased?*/
        for (inx=0; inx<*display_count; inx++)
        {
          if ( (*display_ids)[inx] == my_info->surface_ids[i] )
          {
             got_it = TRUE;
             break;
          }
        }

        if (! got_it)
        {    
          enum GRdpmode display_mode = GRbehe;   /*DECLARE*/
 
          /*Have a surface not yet erased.*/          
          sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                              &env->md_env.matrix_type, 
                              env->md_env.matrix, &display_mode,
                              &env->md_id),
                        targetid = my_info->surface_ids[i]);
          EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
  
          /*Store this surface that was erased (modified) -DLB*/
          EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                              BUFF_INCR, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;
 
          (*display_ids)[*display_count] = my_info->surface_ids[i];
          (*display_count)++;
        }    
      }

      ls_props = NULL | EMLS_NATURAL;
      if(my_info->num_regions_out[i])
       {
         sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                 senderid=my_info->surface_ids[i],p_chanselect=&to_loopset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
      for(j=0;j<my_info->num_regions_out[i];j++)
       {
         sts = om$send(msg=message EMSloop.EMtreemod
                           (EMmsg,&nesting,EXTRACT,NULL),
                                targetid = *lp_out);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);

         {
           IGRshort option = EMS_O_OFF;
        
           props = EMLP_ACTIVE;
           sts = om$send(msg = message EMSloop.EMset_props(EMmsg, props,
                               option),
                         targetid = *lp_out);
           if (! (1 & sts & *EMmsg)) goto wrapup;
         }
         lp_out++;
       }
/* After taking out the loops removed by this state a loopset may become
   natural again. The bit of such loopsets need to be set ON again.
*/
      if(my_info->num_regions_out[i])
       {
         sts = om$send(msg = message EMSboundary.EMcheck_props
                        (EMmsg, &ls_props, &lp_props, &ed_props), 
                                targetid = lpset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
   }


/* Put in the 'in_loops' into the respective loopsets
*/
   lp_in = my_info->region_in_ids;
   ls_props = NULL | EMLS_NATURAL;
   lp_props = NULL;
   ed_props = NULL;

   for(i=0;i<my_info->num_surfaces;i++)
    {
      ls_props = NULL | EMLS_NATURAL;
      if(my_info->num_regions_in[i])
       {
         world = TRUE;
         sts = om$send(msg=message EMSsubbs.EMpartolbasis
                           (EMmsg,&env->md_env.matrix_type,
                            env->md_env.matrix,&world,FALSE,&partolbasis.tol),
                        targetid = my_info->surface_ids[i]);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);
         partolbasis.mattyp = &env->md_env.matrix_type;
         partolbasis.mat = env->md_env.matrix;
         partolbasis.in_world = TRUE;
         partolbasis.is_valid = TRUE;
         sts = om$send(msg=message EMSboundary.EMget_objid(EMmsg,&lpset),
                       senderid=my_info->surface_ids[i],
                       p_chanselect=&to_loopset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }
      for(j=0;j<my_info->num_regions_in[i];j++)
       {
         {
           sts = om$send(msg = message EMSloop.EMactivate_loop(EMmsg),
                         targetid = *lp_in);
           if (! (1 & sts & *EMmsg)) goto wrapup;
         }

         sts = om$send(msg=message EMSloop.EMgivenestinfo(EMmsg,&nesting),
                       targetid= *lp_in);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
         sts = om$send(msg=message EMSloopset.EMnesting
                           (EMmsg,&nesting,&partolbasis),
                       targetid=lpset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
         if(IF_EQ_OBJID(lpset,nesting.parent))
           sts = om$send(msg=message EMSloopset.EMtreemod
                             (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = lpset);
         else
           sts = om$send(msg=message EMSloop.EMtreemod
                             (EMmsg,&nesting,ADD_CHILD,&partolbasis),
                        targetid = nesting.parent);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_NestError,wrapup);
         lp_in++;
       }
/* After all the loops have been put back in, the corresponding loopset
   can become natural again. If so the bit needs to be set ON.
*/
      if(my_info->num_regions_in[i])
       {
         sts = om$send(msg = message EMSboundary.EMcheck_props
                        (EMmsg, &ls_props, &lp_props, &ed_props), 
                                targetid = lpset);
         EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopsetError,wrapup);
       }

    }


/* Take out the 'out_surfaces' and make them non-locatable and
   non-displayable.
*/
  sf_out = my_info->surface_out_ids;
  temp_GRid.osnum = OM_Gw_current_OS;

  for(i=0;i<my_info->num_composites;i++)
   {
     for(j=0;j<my_info->num_surfaces_out[i];j++)
      {
        temp_GRid.objid = my_info->composite_ids[i];        

        /*Erase the surfaces that will be modified by the act -DLB*/
        if (display)
        {
          IGRint       inx;                  /*DECL*/
          IGRboolean got_it = FALSE;

          /*Has this surface already been erased?*/
          for (inx=0; inx<*display_count; inx++)
          {
            if ( (*display_ids)[inx] == *sf_out )
            {
               got_it = TRUE;
               break;
            }
          }

          if (! got_it)
          {    
            enum GRdpmode display_mode = GRbehe;   /*DECLARE*/
 
            /*Have a surface not yet erased.*/          
            sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                                &env->md_env.matrix_type, 
                                env->md_env.matrix, &display_mode,
                                &env->md_id),
                          targetid = *sf_out);
            EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, *EMmsg, wrapup);
  
            /*Don't store surface removed.*/ 
          }    
        }

        sts = om$send(msg = message GRconnector.GRdisconn(EMmsg,&temp_GRid),
                      targetid = *sf_out);
        EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);   

        EFsetsfstate(EMmsg, *sf_out, OM_Gw_current_OS, EMS_O_OFF);
        EMerr_hndlr(!(1&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

        sts = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                              temp_GRid.objid, 
                                              OM_Gw_current_OS, TRUE, NULL);
        if (!(1 & sts & *EMmsg)) goto wrapup;

        if (NOT disjointSurfaces)
        {
            /*
                set all the loops in the removed surface to
                inactive; we do not do this for disjoint surfaces
                because theirs are never toggled to be (in)active
            */

            sts = om$send(
                msg = message EMSsubbs.EMpassloop (
                    EMmsg,
                    message EMSloopset.EMtoglpactive (EMmsg)
                ),
                targetid = *sf_out
            );

            if (! (1 & sts & *EMmsg)) goto wrapup;
        }

        sf_out++;
      }
   }

    if (reverseOrientation AND EMSokay (sts) AND EMSokay (*EMmsg))
    {
        /* must reverse components of index 1 and greater */

        OM_S_CHANSELECT to_comps;

        sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps        );

        if (EMSokay (sts))
        {
            sts = om$send (
                msg = message EMSsurface.EMrevorient (EMmsg),
                p_chanselect = &to_comps,
                from = 1
            );
        }

    } /* fi must reverse components of index 1 and greater */

    if (emptySet AND EMSokay (sts) AND EMSokay (*EMmsg))
    {
        /* connect null symbol; set properties; display */
        
        IGRlong zero = 0;
        struct GRid myGRid;

        myGRid.objid = my_id;
        myGRid.osnum = OM_Gw_current_OS;

        sts = om$send (
            msg = message GRconnector.GRrigidconn (
                EMmsg,
                &myGRid,
                &zero
            ),
            targetid = nullSymbolId
        );

        if (EMSokay (sts) AND EMSokay (*EMmsg))
        {
            /* set properties */

            /* null symbol is a GR3dtext object */

            IGRboolean on_off = TRUE;
            IGRshort props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

            sts = om$send (
                msg = message GRvg.GRchgprops (
                    EMmsg,
                    &on_off,
                    &props
                ),
                targetid = nullSymbolId
            );

        } /* fi set properties */

        if (display AND EMSokay (sts) AND EMSokay (*EMmsg))
        {
            /* display null symbol */

            enum GRdpmode drawNS = GRbd;

            sts = om$send (
                msg = message GRgraphics.GRdisplay (
                    EMmsg,
                    &env->md_env.matrix_type,
                    env->md_env.matrix,
                    &drawNS,
                    &env->md_id
                ),
                targetid = nullSymbolId
            );

        } /* fi display null symbol */

    } /* fi connect null symbol; set properties; display */

  wrapup:
    if(ssi) om$dealloc(ptr = ssi);
    EMWRAPUP(*EMmsg,sts,"In EMSsfboolean.EMactivate")
    return(sts);
}

end implementation EMSsfboolean;
