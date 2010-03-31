/*
NAME:
    EMplace_shell

ABSTRACT:
    This is the function used to create a thin-walled solid given an
    existing one. This can be placed as an associative or non-associative
    entity.

ARGUMENTS:

RETURN VALUES:

ALGORITHM:

    1. If (NOT ASSOCIATIVE)
            if(symmetric)
               in_offset distance    = 'common thickness'/2.0 and
               out_offset distance   = 'common thickness'/2.0.
               direction of offset = 'inward'.
            else if(inward shelling needed)
               in_offset distance    = 'common thickness' and 
               out_offset distance   = 0.0
            else
               in_offset distance    = 0.0 and 
               out_offset distance   = 'common thickness'
               
            Use 'EMshellsolid' method to create shell solid.
    2. If  (ASSOCIATIVE)
            Set-up the parent object information
            Setup the Recompute Information
            Invoke 'EMinit_associative'.  


NOTES:


KEYWORDS:


HISTORY:
    Sanjay  : 04Apr'95   : Initialized "org_ssi" to NULL, so that if the memory
                           is not allocated for it, it will not be freed.
                           Initialized "num_mult_tks" field of "ashell" to zero
                           in case of Non-Associatve placement of thinwall and 
                           was not initialized earlier. This field represents 
                           the VLA size in the recompute info. of thinwall solid
                           and if this field is not initialized, saving the file
                           may result in ABR, as this value is some junk and was
                           the root cause of the TRs : 119423876, 119524930.
    Sudhakar: 05Oct'93   : Added the 'EMS_TRIMMING' option for simple surfaces.
    Sudhakar: 22Sep'93   : Deleted 'two' arguments and added 'one'. This
                           carries the 'dimensioning info'. 
                           Pulled out all the 'edge' parents. Added a
                           'surface' parent for dimensioning common thickness.
                           Modified to handle change in 'recompute' info.
    Sudhakar: 15Sep'93   : Modified such that the 'recompute info' is
                           posted into the 'EMSshslbool' object before
                           the call to 'EMshellsolid' in the
                           'non-associative' case. This fixed a crash problem
                           where, strangely, 'EMgetInGeomIds' is being called
                           before completion of the 'EMshellsolid' method.
    Sampath : 30Jun'93   : Fixed problems with SSI info for symmetric
                           thinwall with open surfaces.
    Sudhakar: 10Jun'93   : Fixed problems with associative thinwall from
                           composite surface.
    Sudhakar: 21May'93   : Added code to deal with thinwall from composite
                           or simple surface. Both work in the Non-assoc
                           mode. In associative mode only thinwall from
                           composite surface has been implemented.
    Sampath : 20thMay'93 : Modified to deal with 'Undo' of the Thinwall.
                           This is done by posting the info. about the
                           nature of offset (inward/outward/symmetric)
                           into the recompute-info, so that it is used
                           later for deactivating during 'undo state'.
    Sudhakar:  03/15/93  : Modification for successful associative placement.
    Sudhakar:  01/07/93  : Modification for Phoenix Thin Wall.
    SS      :  04/01/92  : Creation

*/

class implementation EMSshslbool;

#include "OMmacros.h"
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h"
#include "REshsolid.h"
#include "REgensolid.h"
#include "REgencompsf.h"
#include "msmacros.h"
#include "ECmsg.h"

#define COTHICK_PARM		0

struct dimension_info
{
  GRobjid    surf;
  IGRpoint   uv_point;
  OMuword    view_index;
};


extern GRobjid current_creator;
extern GRclassid OPP_EMSgensolid_class_id;

%safe
IGRlong EMput_in_the_ssi_table(IGRint , GRobjid , GRspacenum ,
					struct GRmd_env *, GRobjid *);
static EMSrc EFssiPerformRemovals_thin(IGRlong *, GRobjid *, 
                                     OMuword, struct EMSboolssi_table *);
static IGRlong EFgroup_composites_and_surfaces( IGRint ,GRobjid *,
					GRspacenum ,
					IGRint *,
					GRobjid **, 
					IGRint  **);
%endsafe

from EMSloopset import EMtoglpactive;

IGRlong EMplace_shell (msg, options, md_env, objname,
                       solid, 
                       is_symmetric, is_inward, is_solid,
                       common_thickness,
                       num_mult_thickness,
                       vals_mult_thickness,
                       num_sfs_per_mult_thickness,
                       mult_thickness_sf_sets,
                       dimensioning_info,
                       num_opensfs, opensfs,
                       shell_solid)
IGRlong *msg;
IGRushort options;
struct GRmd_env *md_env;
IGRchar *objname;
GRobjid solid;
IGRboolean  is_symmetric, is_inward, is_solid;
struct EMSvalue_info *common_thickness;
IGRint num_mult_thickness;
struct EMSvalue_info *vals_mult_thickness; 
IGRint *num_sfs_per_mult_thickness;
GRobjid *mult_thickness_sf_sets;
struct dimension_info  *dimensioning_info;
IGRint num_opensfs;
GRobjid *opensfs;
GRobjid *shell_solid;
{

  IGRchar status_str[GR_MAX_CHAR];
  IGRint i, j, k, solid_inx, num_parents;
  IGRlong stat_OM, msg_loc;
  IGRdouble d_inthick, d_outthick, half_thick;
  GRspacenum os;
  struct GRsymbology symb;
  struct GRvg_construct const_list;
  struct EMSobject_info *parobjs;

  GRobjid base_solid;
  IGRboolean offin_flag, is_composite = TRUE; 
  IGRint sfs_index;
  IGRushort offopts = 0;
  IGRdouble *vals_mult_tk = NULL;

  struct GRobjid_set *spec_tk_sf_sets = NULL;
  IGRint num_sfs, sf_index;
  struct EMSerror_help *errkey_list = NULL;
  GRobjid *tmplist;
  GRclassid objclass;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  os = md_env->md_id.osnum;
  stat_OM = om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
             targetid = solid, targetos = os, senderid = NULL_OBJID);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  EMinitvgcnstr (&msg_loc, md_env, &symb.display_attr, objname, &const_list);
  EMgetvgcnstr (options, EMSgrid, md_env, symb.level, &symb.display_attr,
   NULL, NULL, &const_list);

  strcpy (status_str, "Processing");

/* IF !is_solid then find whether the surface is a composite surface
    or a simple surface - 'is_composite' . 
*/
  if(!is_solid)
   {
     om$get_classid (objid = solid, osnum = os,
      p_classid = &objclass);
     if (om$is_ancestry_valid (subclassid = objclass,
          superclassid = OPP_EMScompsurf_class_id) == OM_S_SUCCESS)
       is_composite = TRUE;
     else
       is_composite = FALSE;
   }

#ifdef DEBUG
if(is_solid)
  printf("The input is a SOLID\n");
else
  if(is_composite)
     printf("The input is COMPOSITE SURFACE\n");
  else
     printf("The input is a SIMPLE SURFACE\n");
#endif

  if(num_mult_thickness)
  {
    vals_mult_tk = (IGRdouble *) om$malloc (size = num_mult_thickness *
                                       sizeof(IGRdouble));
    EMerr_hndlr (!vals_mult_tk, *msg, EMS_E_NoStackMemory, ret_end);

    for(i=0; i<num_mult_thickness; i++)
    {
      stat_OM = EMgetparval_numeric (&msg_loc, &vals_mult_thickness[i],
                                   &vals_mult_tk[i]);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    }
  }

  base_solid = solid;

  if((!is_solid) && (options & EMSasconst_notassociative))
   {
    stat_OM = EMgetparval_numeric (&msg_loc, common_thickness, &d_inthick);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
    d_outthick = 0.0;

    if(is_composite)
     {
      if(num_mult_thickness)
      {
       /* Set data into a 'GRobjid_set' structure */

         spec_tk_sf_sets = (struct GRobjid_set *) om$malloc(size = 
                             num_mult_thickness * sizeof(struct GRobjid_set));

         num_sfs=0;
         for (j=0; j<num_mult_thickness; j++)
          {
           spec_tk_sf_sets[j].num_ids = num_sfs_per_mult_thickness[j];

           tmplist = (GRobjid *) om$malloc(size = 
                                    num_sfs_per_mult_thickness[j] *
                                    sizeof(GRobjid));

           for (k=0, sf_index=num_sfs; k<num_sfs_per_mult_thickness[j];
                                                     k++, sf_index++)
              tmplist[k] = mult_thickness_sf_sets[sf_index];
           num_sfs += num_sfs_per_mult_thickness[j];

           spec_tk_sf_sets[j].objids = tmplist;
          }
       } /* end of if(num_mult_thickness).. */
     } /* if (is_composite)  */
    if(!is_composite && is_symmetric)
     {
    /* Offset the original simple surface outward by half-thickness */
      
      half_thick = d_inthick/2.0;
      offin_flag = FALSE;
      offopts = EMS_opt_offsetS_copy_topology;

      stat_OM = om$send (msg = message EMSsurface.EMoffset (&msg_loc, offopts,
               &md_env->md_env.matrix_type,
               md_env->md_env.matrix,
               &const_list,
               offin_flag, half_thick,
               0, NULL, NULL,
               0, NULL, status_str, &base_solid, errkey_list),
               senderid = NULL_OBJID,
               targetid = solid, 
               targetos = os);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
     } /* end of else of if(is_composite) */

    offin_flag = TRUE;
   }


  if (options & EMSasconst_notassociative)
    {
    struct EMSshell_solid *ashell;  /* TBD - Make additions to this structure*/
    IGRint size;

    /* PLACE NON_ASSOCIATIVE SHELL SOLID */

    size = sizeof(struct EMSshell_solid);
    ashell = (struct EMSshell_solid *)alloca(size);
    ashell->props = 0;
    ashell->is_symmetric = is_symmetric;
    ashell->inward       = is_inward;
    ashell->num_mult_tks = 0;

    offin_flag = FALSE;

    if(is_solid && is_symmetric)
     {
      stat_OM = EMgetparval_numeric (&msg_loc, common_thickness, &d_inthick);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      d_inthick /= 2.0;
      d_outthick = d_inthick;

      /* Set the flag for 'inward' offset */ 
      offin_flag = TRUE;
     }
    else if(is_inward)
       {
        stat_OM = EMgetparval_numeric (&msg_loc, common_thickness, &d_inthick);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

        d_outthick = 0.0;

        /* Set the flag for 'inward' offset */ 
        offin_flag = TRUE;
       }
    else
       {
        stat_OM = EMgetparval_numeric (&msg_loc, common_thickness, &d_outthick);
        EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

        d_inthick = 0.0;

        /* Set the flag for 'outward' offset */ 
        offin_flag = FALSE;
       };

    ex$message(msgnumb = EMS_S_CreatingThinwall);

    if(is_solid)
      {
     /* Construct an object of class 'EMSshslbool' */
       stat_OM = om$construct(classid = OPP_EMSshslbool_class_id,
                              osnum = os,
                              p_objid = shell_solid);
       EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

     /*
       Post the information regarding offset direction etc. into the
       'EMSassoc' vla. This will be used in the methods
          i) EMdeactivate (during 'undo state') [EMshsldeact.I], and
         ii) EMgetInGeomIds [EMshslgeting.I].
      */
       stat_OM = om$send(msg = message EMSassoc.EMput_info(&msg_loc, NULL,
                        NULL, size, (IGRchar *)ashell),
                        senderid = NULL_OBJID,
                        targetos=os,
                        targetid = *shell_solid);
       EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

     /* Create the Thinwall solid */
       stat_OM = om$send(msg = message EMSshslbool.EMshellsolid (&msg_loc,
                   EMSsfbool_opt_display | EMSsfbool_opt_HandleStop,
                   &md_env->md_env.matrix_type, md_env->md_env.matrix,
                   &const_list, base_solid, d_inthick, d_outthick,
                   num_mult_thickness, vals_mult_tk,
                   num_sfs_per_mult_thickness, mult_thickness_sf_sets,
                   num_opensfs, opensfs, status_str, NULL, NULL),
                   senderid = NULL_OBJID,
                   targetid = *shell_solid,
                   targetos = os);
       EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

     /* Push the surfaces into the SSI, if symmetric case */
       EMput_in_the_ssi_table(is_symmetric,solid,os,md_env,shell_solid);

      } /* if(is_solid)..... */
    else
      {
       if(is_composite)
         {     
          /* It is thinwall of a Composite surface */
          offopts = 0;
          stat_OM = om$send(msg = message EMScompsurf.EMshell(&msg_loc,
                                 offopts,
                                 &md_env->md_env.matrix_type,
                                 md_env->md_env.matrix,
                                 &const_list,
                                 offin_flag, 
                                 is_symmetric,
                                 ((d_inthick > 0.0) ? d_inthick : d_outthick),
                                 num_mult_thickness, vals_mult_tk, 
                                 spec_tk_sf_sets, num_opensfs, opensfs,
                                 status_str, shell_solid, errkey_list),
                          mode = OM_e_wrt_message,
                          senderid = NULL_OBJID,
                          targetid = base_solid,
                          targetos = os);

          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
#ifdef DEBUG
 printf("The Offset Composite surface solid id = %d\n", *shell_solid);
#endif
         } /* if(is_composite)..  */
       else
         {
          /* It is thinwall of a Simple surface */
          struct GRlc_info        lc_info;

          OM_BLOCK_MOVE(md_env, &lc_info.module_info, sizeof(struct GRmd_env));
          lc_info.located_obj.objid  = base_solid;
          lc_info.located_obj.osnum  = os;
     

          stat_OM = EMoffset_surface_to_solid ( &lc_info,
                                 ((d_inthick > 0.0) ? d_inthick : d_outthick),
                                                 offin_flag,
                                                 &const_list,
                                                 NULL_OBJID,
                                                 shell_solid );
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

          if(is_symmetric)
          {
           /* Delete the 'half' offset copy surface */
            stat_OM = om$send(msg = message GRgraphics.GRdelete (&msg_loc,
                                        const_list.env_info),
                            senderid = NULL_OBJID,
                            targetid = base_solid,
                            targetos = os);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), 
                                          *msg, EMS_E_Fail, ret_end);
          }

#ifdef DEBUG
 printf("The Offset surface solid id = %d\n", *shell_solid);
#endif
         } /* end of else of if(is_composite)... */      
      } /* end of else of if(is_solid) .. */

    ex$message(msgnumb = EMS_I_00000);
    }
  else
    {

    /* PLACE ASSOCIATIVE SHELL SOLID  */

    IGRint sfs_obj_count; 
    IGRint parent_count, optional_parent_count, size = 0;
    struct GRid   active_grid;
    IGRushort   opts = 0;
    struct EMSshell_solid *ashell = NULL;
    struct mult_tk_surfs_views *s_views = NULL;
    struct EMSoffset_simple_surface *asurf = NULL;

    active_grid.objid = NULL_OBJID;

    if(is_solid)
    {
     /* For solids */
      stat_OM = om$construct (classid = OPP_EMSshslbool_class_id,
                 osnum = os, p_objid = shell_solid);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
    }
    else
    {
     /* For surfaces and Composite Surfaces */
      stat_OM = om$construct (classid = OPP_EMSgensolid_class_id,
                 osnum = os, p_objid = shell_solid);
      EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
    }
    current_creator = *shell_solid;
    
    sfs_obj_count = 0;
    optional_parent_count = 0;

    if(is_solid || is_composite)
    {
      sfs_obj_count = 1;  /* common thickness surface */
      for(i=0; i<num_mult_thickness; i++)
         sfs_obj_count += num_sfs_per_mult_thickness[i];
    }
    else
    {
      /* It is a simple surface. So consider an optional active_id
         parent.
      */
       stat_OM  = om$send(msg = message EMSsurface.EMgetactiveid(&msg_loc,
                     &active_grid, NULL),
                   senderid = NULL_OBJID,
                   targetid = solid,
                   targetos = os);
       EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

       if(active_grid.objid != NULL_OBJID)
              optional_parent_count = 1;
       else
              optional_parent_count = 0;
    }

    num_parents = 2 + num_mult_thickness + 
                      sfs_obj_count +        
                      num_opensfs +
                      optional_parent_count; /* this only for a simple surf.*/

    parobjs = (struct EMSobject_info *) alloca (num_parents * 
               sizeof (struct EMSobject_info));
    EMerr_hndlr (!parobjs, *msg, EMS_E_NoStackMemory, ret_end);

    parent_count =0;

    if(is_solid || is_composite)
     { 
     /* Setup the structures for the thickness values  */

      stat_OM = EMgetparval_object (&msg_loc, os, NULL, common_thickness,
                  &parobjs[parent_count]);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      parent_count++;
   
      if(num_mult_thickness)
       { 
        /* Thickness Objects */
        for (i=0, j=parent_count; i< num_mult_thickness; i++, j++)
          {
          stat_OM = EMgetparval_object (&msg_loc, os, NULL, 
                                        &vals_mult_thickness[i],
                 &parobjs[j]);
          EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
          }
        parent_count += num_mult_thickness;
       }

      /* Surface Objects: Common and Multiple Offset Surfaces.
          The id of the surface to be dimensioned with common thickness
          is stored at the '0'th index of the 'dimension_info' structure. */
     
      parobjs[parent_count].grid.objid = dimensioning_info[0].surf;
      parobjs[parent_count].grid.osnum = os;
      OM_BLOCK_MOVE (md_env, &parobjs[parent_count].env, 
                                  sizeof (struct GRmd_env));
      parent_count++;

      if(num_mult_thickness)
       { 
        sfs_index = 0; 
        for (i=0; i< num_mult_thickness; i++)
         {
          for(j=sfs_index; j<sfs_index+num_sfs_per_mult_thickness[i]; j++)
           {
            parobjs[parent_count+j].grid.objid = mult_thickness_sf_sets[j]; 
            parobjs[parent_count+j].grid.osnum = os;
            OM_BLOCK_MOVE (md_env, &parobjs[parent_count+j].env, 
                                  sizeof (struct GRmd_env));
           }
          sfs_index    += num_sfs_per_mult_thickness[i];
         }
        parent_count += sfs_index; 
       } /* End of -  if(num_mult_thickness) */

     /* The open surface parents */
      if (num_opensfs)
       {
        for (i=0, j=parent_count; i<num_opensfs; i++, j++)
          {
          parobjs[j].grid.objid = opensfs[i];
          parobjs[j].grid.osnum = os;
          OM_BLOCK_MOVE (md_env, &parobjs[j].env, sizeof (struct GRmd_env));
          }
        parent_count += num_opensfs;
       }
     }

  /* The solid/comp. surface itself is the last parent. For a simple
     surface it is the first parent. */

    solid_inx = parent_count;
    parobjs[solid_inx].grid.objid = base_solid; /* The original solid */
    parobjs[solid_inx].grid.osnum = os;
    OM_BLOCK_MOVE (md_env, &parobjs[solid_inx].env, sizeof (struct GRmd_env));
    parent_count++;

    if(!is_solid && !is_composite) 
     {
     /* For a simple surface the offset distance is the second parent */
      stat_OM = EMgetparval_object (&msg_loc, os, NULL, common_thickness,
                  &parobjs[parent_count]);
      EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);
      parent_count++;

      if(active_grid.objid != NULL_OBJID)
       {
        parobjs[parent_count].grid.objid = active_grid.objid;
        parobjs[parent_count].grid.osnum = os;
        OM_BLOCK_MOVE (md_env, &parobjs[parent_count].env,
                                      sizeof (struct GRmd_env));
        parent_count++;
       }
    }  /* end of if(!is_solid....) */

    /*
     *  The Recompute Information is handled below 
     */
    if(is_solid || is_composite)
     {
      /* For solids and composite surfaces : Set the RECOMPUTE */
      size = sizeof(struct EMSshell_solid) +
                 (num_mult_thickness + 1) *
                        sizeof(struct mult_tk_surfs_views) +
                 sizeof(IGRint); /*pad*/

      ashell = (struct EMSshell_solid *)alloca(size);
 
      ashell->props = 0; 
      ashell->is_symmetric = is_symmetric;
      ashell->inward       = is_inward;
      ashell->num_mult_tks = num_mult_thickness;
      s_views = ashell->sfs_views;

     /* Initialise the number for common thickness to '0' and
         for the multiple thicknesses appropriately. */
      for (i=0; i<=num_mult_thickness; i++)
        {
         s_views[i].num_sfs_per_mult_tks 
                            = (i==0 ? 0 : num_sfs_per_mult_thickness[i-1]);
         if(dimensioning_info)
           s_views[i].best_view_index 
                            = dimensioning_info[i].view_index;   /*  ?????? */
         else
           s_views[i].best_view_index 
                          = 1;                                   /*  ?????? */
         s_views[i].uv_point[0] = dimensioning_info[i].uv_point[0];/* u- value*/
         s_views[i].uv_point[1] = dimensioning_info[i].uv_point[1];/* v- vlaue*/

        };
     }
    else
     {
     /* For simple surfaces : the 'inward' boolean flag indicates
        whether the offset is along the natural normal. */
      /* Set the RECOMPUTE info. */
      size = sizeof(struct EMSoffset_simple_surface); 

      asurf = (struct EMSoffset_simple_surface *)alloca(size);
      asurf->props = EMS_TRIMMING;  /* Always trim wrt loopset. */
      if(is_inward) asurf->props |= EMS_NATURAL_NORMAL;
      if(is_symmetric) asurf->props |= EMS_SYMMETRIC_OFFSET;
     }

   /* Initiate the Associative Construction */

     ex$message(msgnumb = EMS_S_CreatingThinwall);
     current_creator = *shell_solid;
     stat_OM = om$send(msg = message EMSassoc.EMinit_associative
                   ( &msg_loc,
                     (is_solid ? NULL : opts & ~EMSasconst_recompute),
                     num_parents,
                     parobjs,
                     (is_solid ? NULL : 
                       (is_composite ? EMS_ASthinwall_from_compsurf :
                                         EMS_ASsolid_by_offsetting_surface)),
                     size,
                     ((is_solid || is_composite) ? (IGRchar *)ashell :
                                                   (IGRchar *)asurf),
                     &const_list),
                    senderid = NULL_OBJID,
                    targetid = *shell_solid,
                    targetos = os);
    EMerr_hndlr (EMSerror (msg_loc & stat_OM), *msg, EMS_E_Fail, ret_end);

    current_creator = NULL_OBJID;
    ex$message(msgnumb = EMS_I_00000);

    }

ret_end:
  if(vals_mult_tk) om$dealloc(ptr = vals_mult_tk);
  if(spec_tk_sf_sets)
     for(i=0; i<num_mult_thickness; i++)
       if(spec_tk_sf_sets[i].objids)
           om$dealloc(ptr = spec_tk_sf_sets[i].objids);
  if(spec_tk_sf_sets) om$dealloc(ptr = spec_tk_sf_sets);
  /* TBD : Add deallocation of 'errkey_list'. */
  if(EMSerror(*msg))
  {  /* Delete the 'thinwall' object in case of error. */
     stat_OM  = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                           const_list.env_info),
                            senderid = NULL_OBJID,
                            targetid = *shell_solid,
                            targetos = os);
  }
  EMWRAPUP (*msg, stat_OM, "EMplace_shell");
  return (stat_OM);
}

IGRlong EMput_in_the_ssi_table(IGRint is_symmetric, GRobjid solid,
		GRspacenum os, struct GRmd_env *md_env, GRobjid *shell_solid)
{
    union EMSssi_table ssi,*org_ssi=NULL,tmp_ssi;
    IGRlong stat_OM = OM_S_SUCCESS,msg_loc;
    enum GRdpmode dpmode;
    IGRlong msg1,*msg=NULL;
    GRobjid *composites=NULL;
    int     num_owners=0;


    msg = &msg1;

    if(is_symmetric)
    {
	IGRint	numsf=0;
	struct  GRid *surfs=NULL;
	GRobjid *surfs1=NULL;
	IGRint	sfcount=0;
	int	loci=0;

	/* Erase the orginal solid */
        dpmode = GRbe;
        om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
     		&md_env->md_env.matrix_type, md_env->md_env.matrix, &dpmode,
     		&md_env->md_id),
		senderid = NULL_OBJID,
                targetid = solid,
		targetos = os);

	/* create additional save state information */

	ssi.bool_info.num_surfaces = 0;
	ssi.bool_info.region_out_ids = NULL;

	/* get the surface ids of the orginal solid */

        stat_OM = om$send( msg = message GRowner.GRget_number_components(
                        &msg_loc, &numsf ),
                        senderid = NULL_OBJID,
                        targetos = os,
                        targetid = solid );
        EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        surfs = (struct GRid *)malloc(numsf * sizeof(struct GRid));
        stat_OM = om$send( msg = message GRowner.GRget_components( &msg_loc,
                        md_env, surfs, numsf, &sfcount,
                        NULL, OM_K_MAXINT ),
                        senderid = NULL_OBJID,
                        targetos = os,
                        targetid = solid);
        EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	surfs1 = (GRobjid *) om$malloc(size = numsf*sizeof(GRobjid));
	for(loci=0;loci<numsf;loci++)
		surfs1[loci] = surfs[loci].objid;
	free(surfs);

	/* get the composites of the orginal solid */
/*
	EMmake_chanselect (GRconnector_to_owners, &chan_to_connector);
	for(loci=0;loci<numsf;loci++)
	{
		int found=FALSE;

		om$get_channel_count (objid = surfs1[loci], osnum = os,
			p_chanselect = &chan_to_connector,
			count = &count);
		if(count)
		{
		owner_comps = (OM_S_OBJECT_LINKAGE *) om$malloc
			(size = count * (sizeof (OM_S_OBJECT_LINKAGE)));
		om$get_channel_objects (objid = surfs1[loci], osnum = os,
			p_chanselect = &chan_to_connector,
			count = &numsf1, size = count,
			list = owner_comps);
		if(num_owners>0)
		{
			int locj;

			for(locj=0;locj<num_owners;locj++)
				if(owner_comps->S_objid==composites[locj])
					found = TRUE;
		}
		if(!found)
		{
		if(num_owners < 1)
			composites = (GRobjid *) om$malloc(size = 
					sizeof(GRobjid));
		else
			composites =  (GRobjid * ) om$realloc(ptr = (char *)
				composites, size = (num_owners+1) *
				sizeof(GRobjid));
		composites[num_owners++] = owner_comps->S_objid;
		}
		om$dealloc(ptr = owner_comps);
		}

	}

	/* get number of surfaces for each compsite 

        ssi.bool_info.num_surfaces_out = (IGRint *) om$malloc( size =
				num_owners*sizeof(GRobjid));
	for(loci=0;loci<num_owners;loci++)
	{
        stat_OM = om$send( msg = message GRowner.GRget_number_components(
                        &msg_loc, &numsfk ),
                        senderid = NULL_OBJID,
                        targetos = os,
                        targetid = composites[loci] );
        EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
	ssi.bool_info.num_surfaces_out[loci] = numsfk;
	}
*/

	EFgroup_composites_and_surfaces(numsf,surfs1,os,&num_owners,
					&composites,
					&ssi.bool_info.num_surfaces_out);
	ssi.bool_info.num_composites = num_owners;
	ssi.bool_info.composite_ids = composites;
	ssi.bool_info.surface_out_ids = surfs1;
	ssi.bool_info.composite_indices =
		(IGRint *) malloc(numsf*sizeof(IGRint ));

	EFssiPerformRemovals_thin (&msg_loc, shell_solid, 
                                          os, &(ssi.bool_info));
	
	/* get orginal save state information */

	stat_OM = om$send(msg = message EMSdpr.EMgetSSI(&msg_loc, &org_ssi),
				senderid = NULL_OBJID,
				targetos = os,
				targetid = *shell_solid);

	/* merge the created save state information with
		orginal save state information */

	if(org_ssi->bool_info.num_composites == 0)
	{
	   org_ssi->bool_info.composite_ids = ssi.bool_info.composite_ids;

           org_ssi->bool_info.num_surfaces_out = ssi.bool_info.num_surfaces_out;

	   org_ssi->bool_info.composite_indices = 
				ssi.bool_info.composite_indices;
	   org_ssi->bool_info.surface_out_ids = ssi.bool_info.surface_out_ids;

	   org_ssi->bool_info.num_composites = ssi.bool_info.num_composites;
	}
	else
	{
	   int ij=0,ij1=0,org_num_surfs=0;

	   tmp_ssi.bool_info.composite_ids = (GRobjid *) om$malloc(
		size = (org_ssi->bool_info.num_composites +
		ssi.bool_info.num_composites)*sizeof(GRobjid));

	   for(ij=0,ij1=0;ij < org_ssi->bool_info.num_composites;ij++,ij1++)
	       tmp_ssi.bool_info.composite_ids[ij] =
			org_ssi->bool_info.composite_ids[ij1];

	   for(ij=org_ssi->bool_info.num_composites,ij1=0;
	       ij < org_ssi->bool_info.num_composites +
		    ssi.bool_info.num_composites;ij++,ij1++)
	       tmp_ssi.bool_info.composite_ids[ij] =
			ssi.bool_info.composite_ids[ij1];

	   for(ij=0;ij < org_ssi->bool_info.num_composites;ij++)
		org_num_surfs += org_ssi->bool_info.num_surfaces_out[ij];

	   tmp_ssi.bool_info.num_surfaces_out = (IGRint *) om$malloc(
		size = (org_ssi->bool_info.num_composites +
		ssi.bool_info.num_composites)*sizeof(IGRint));

	   for(ij=0;ij < org_ssi->bool_info.num_composites;ij++)
               tmp_ssi.bool_info.num_surfaces_out[ij] = 
			org_ssi->bool_info.num_surfaces_out[ij];

	   for(ij=org_ssi->bool_info.num_composites,ij1=0;
	       ij < org_ssi->bool_info.num_composites +
		    ssi.bool_info.num_composites;ij++,ij1++)
               tmp_ssi.bool_info.num_surfaces_out[ij] = 
			ssi.bool_info.num_surfaces_out[ij1];

	   tmp_ssi.bool_info.composite_indices = (IGRint *) om$malloc(
		size = (org_num_surfs + numsf)*sizeof(IGRint));

	   for(ij=0,ij1=0;ij <org_num_surfs + numsf;ij++,ij1++)
	       tmp_ssi.bool_info.composite_indices[ij] = 
				org_ssi->bool_info.composite_indices[ij1];

	   for(ij=org_num_surfs,ij1=0;
		ij <org_num_surfs + numsf;
		ij++,ij1++)
	       tmp_ssi.bool_info.composite_indices[ij] = 
				ssi.bool_info.composite_indices[ij1];

	   tmp_ssi.bool_info.surface_out_ids = (GRobjid *) om$malloc(
		size = (org_num_surfs + numsf)*sizeof(GRobjid));

	   for(ij=0,ij1=0;ij <org_num_surfs; ij++,ij1++)
	       tmp_ssi.bool_info.surface_out_ids[ij] =
			org_ssi->bool_info.surface_out_ids[ij1];

	   for(ij=org_num_surfs,ij1=0;
		ij <org_num_surfs + numsf;
		ij++,ij1++)
	       tmp_ssi.bool_info.surface_out_ids[ij] =
			ssi.bool_info.surface_out_ids[ij1];

	   org_ssi->bool_info.num_composites +=
	   			ssi.bool_info.num_composites;

	   om$dealloc(ptr = ssi.bool_info.composite_ids);

	   om$dealloc(ptr = ssi.bool_info.num_surfaces_out);

	   om$dealloc(ptr = ssi.bool_info.composite_indices);

	   om$dealloc(ptr = ssi.bool_info.surface_out_ids);
	 
	   org_ssi->bool_info.composite_ids =
			tmp_ssi.bool_info.composite_ids;
	   org_ssi->bool_info.num_surfaces_out = 
			tmp_ssi.bool_info.num_surfaces_out;
	   org_ssi->bool_info.composite_indices = 
			tmp_ssi.bool_info.composite_indices;
	   org_ssi->bool_info.surface_out_ids =
			tmp_ssi.bool_info.surface_out_ids;
	}

	/* put back the merged save state information */

	stat_OM = om$send(msg = message EMSdpr.EMputSSI(&msg_loc, org_ssi),
				senderid = NULL_OBJID,
				targetos = os,
				targetid = *shell_solid);
    }

ret_end :

    /* fix for mlk */

    if(org_ssi)
    {
       if(org_ssi->bool_info.composite_ids)
          om$dealloc(ptr = org_ssi->bool_info.composite_ids);
 
       if(org_ssi->bool_info.num_surfaces_out)
          om$dealloc(ptr = org_ssi->bool_info.num_surfaces_out);
 
       if(org_ssi->bool_info.composite_indices)
          om$dealloc(ptr = org_ssi->bool_info.composite_indices);
 
       if(org_ssi->bool_info.surface_out_ids)
          om$dealloc(ptr = org_ssi->bool_info.surface_out_ids);

       om$dealloc(ptr = org_ssi);	
    }

    return stat_OM;
}


# include "EMS.h"       /* for shared libraries */

/*
from EMSsubbs import GRdisconn;
*/

static EMSrc EFssiPerformRemovals_thin( IGRlong *rc, 
                                GRobjid *shell_solid, OMuword osnum,
    				struct EMSboolssi_table *p_ssi)
{
    IGRlong omrc = OM_S_SUCCESS;
    int ii;
    OM_S_OBJID *p_affected=NULL; /* object having something removed */
    IGRint *p_nrout=NULL;        /* number out */
    OM_S_OBJID *p_idout=NULL;    /* id out */
    OMuint *p_ixout=NULL;        /* index of removed object */
    IGRint numComposites=0;
    enum EMSbooltype exact_type;
    IGRboolean reverseOrientation, disjointSurfaces, emptySet;


    *rc = EMS_S_Success;

    omrc = om$send (
       msg = message EMSsfboolean.EMget_operation_type (
        (IGRlong *) rc,
        NULL,
        &exact_type,
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
       senderid = NULL_OBJID,
       targetid = *shell_solid,
       targetos = osnum 
     );

     if (EMSerror (omrc) OR EMSerror (*rc))
     {
       omrc = OM_E_ABORT;
       *rc = EMS_E_Fail;
       goto wrapup;
     }


    if (numComposites = p_ssi->num_composites) /* !assignment! */
    {
        OM_S_CHANSELECT toComponents, toLoopset;
        struct GRid ownerGRid;

        ownerGRid.osnum = osnum;

        p_affected = p_ssi->composite_ids;
        p_nrout = p_ssi->num_surfaces_out;
        p_idout = p_ssi->surface_out_ids;
        p_ixout = (OMuint *) p_ssi->composite_indices;

        omrc = EMmake_chanselect(GRcmpowner_to_components, &toComponents);

        if (EMSokay (omrc))
        {
            omrc = EMmake_chanselect(EMSsubbs_to_loopset, &toLoopset);
        }

        /* iteration over each of the composites */

        for (
            ii = 0;
            ii < numComposites AND EMSokay (omrc) AND EMSokay (*rc);
            ii++, p_affected++, p_nrout++
        )
        {
            int jj;

            ownerGRid.objid = *p_affected;

            /* iteration over each of the surfaces to be removed */

            for (
                jj = 0;
                jj < *p_nrout AND EMSokay (omrc) AND EMSokay (*rc);
                jj++, p_idout++, p_ixout++
            )
            {
                omrc = om$get_index (
                    osnum_c = ownerGRid.osnum,
                    objid_c = ownerGRid.objid,
                    p_chanselect = &toComponents,
                    objid = *p_idout,
                    osnum2 = osnum,
                    indexaddr = p_ixout
                );

                if (EMSokay (omrc))
                {
                    omrc = om$send (
                        msg = message GRconnector.GRdisconn (
/*
                        msg = message EMSsubbs.GRdisconn (
*/
                            (IGRlong *) rc,
                            &ownerGRid
                        ),
                        senderid = NULL_OBJID,
                        targetid = *p_idout,
                        targetos = osnum
                    );

                }

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    extern void EFsetsfstate ();

                    EFsetsfstate (rc, *p_idout, osnum, EMS_O_OFF);

                }
                if ((EMSokay (omrc) AND EMSokay (*rc)) && (!disjointSurfaces))
                {
                    omrc = om$send (
                        msg = message EMSloopset.EMtoglpactive (
                            (IGRlong *) rc
                        ),
                        senderid = *p_idout,
                        targetos = osnum,
                        p_chanselect = &toLoopset
                    );

                }


            } /* done iteration over each of the surfaces to be removed */

        } /* done iteration over each of the composites */

    } /* end if (p_ssi->num_composites) */


    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
        *rc = EMS_S_Success;
    }
    else
    {
        omrc = OM_E_ABORT;
        *rc = EMS_E_Fail;
    }

wrapup:
    return omrc;
}

static IGRlong EFgroup_composites_and_surfaces( IGRint numsf,GRobjid *old_surfs,
					GRspacenum os,
					IGRint	*owner_count,
					GRobjid **composites, 
					IGRint  **num_composites)
{
	struct comp_node 
	{
		GRobjid	composite_id;
		IGRint	num_sfs;
		GRobjid	*surfs;
		struct comp_node *next;
	} *Head=NULL,*p=NULL,*p1=NULL;
	int i,j;
	GRobjid *tmp_composites=NULL;
	IGRint  *tmp_num_composites=NULL;
	OM_S_CHANSELECT chan_to_connector;
	OMuint          count,numsf1;
	OM_S_OBJECT_LINKAGE  *owner_comps=NULL;
	int     num_owners=0;

	EMmake_chanselect (GRconnector_to_owners, &chan_to_connector);
	for(i=0;i<numsf;i++)
	{
		om$get_channel_count (objid = old_surfs[i], osnum = os,
			p_chanselect = &chan_to_connector,
			count = &count);
		if(count)
		{
		owner_comps = (OM_S_OBJECT_LINKAGE *) om$malloc
			(size = count * (sizeof (OM_S_OBJECT_LINKAGE)));
		om$get_channel_objects (objid =  old_surfs[i], osnum = os,
			p_chanselect = &chan_to_connector,
			count = &numsf1, size = count,
			list = owner_comps);
		for(p=Head;p;p=p->next)
			if(p->composite_id == owner_comps->S_objid)
				break;
		if(p==NULL)
		{
			num_owners++;
			p = (struct comp_node *) 
				om$malloc(size = sizeof(struct comp_node));
			p->composite_id = owner_comps->S_objid;
			p->num_sfs = 1;
			p->surfs = (GRobjid *)
					om$malloc(size = sizeof(GRobjid));
			p->surfs[0] = old_surfs[i];

			p->next = NULL;

			if(Head == NULL)
				Head = p;
			else
			{
				for(p1=Head;p1->next;p1=p1->next);
				p1->next = p;
			}
		}
		else
		{
			p->num_sfs++;
			p->surfs = (GRobjid *) 
					om$realloc(ptr = (IGRchar *) p->surfs,
					size = p->num_sfs*(sizeof(GRobjid)));
			p->surfs[p->num_sfs-1] = old_surfs[i];
		}
		om$dealloc(ptr = owner_comps);
		}
	}

	tmp_composites = (GRobjid *)
		om$malloc(size = num_owners*sizeof(GRobjid));
	tmp_num_composites = (IGRint *)
		om$malloc(size = num_owners*sizeof(IGRint));
	numsf = 0;
	p = Head;
	for(i=0;i<num_owners;i++)
	{
		tmp_composites[i] = p->composite_id;
		tmp_num_composites[i] = p->num_sfs;
		for(j=0;j<p->num_sfs;j++)
			old_surfs[numsf++] = p->surfs[j];
		p1 = p;
		p = p->next;
		om$dealloc(ptr = p1->surfs);
		om$dealloc(ptr = p1);
	}
	*owner_count = num_owners;
	*composites = tmp_composites;
	*num_composites = tmp_num_composites;

	return OM_S_SUCCESS;
}

end implementation EMSshslbool;
