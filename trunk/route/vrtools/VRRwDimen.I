/* $Id: VRRwDimen.I,v 1.3 2001/02/20 01:18:07 build Exp $  */
/*************************************************************************
 * I/ROUTE
 *
 * File:        vrsketch/VRRwDimen.I
 *
 * Description:
 *    This function updates the raceway forms for the width/depth/tier fields.
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VRRwDimen.I,v $
 * Revision 1.3  2001/02/20 01:18:07  build
 * Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 * Revision 1.2  2001/01/16 20:09:27  anand
 * SP merge
 *
# Revision 1.2  2000/05/10  14:41:08  pinnacle
# Replaced by Anand for Service Pack 13 (TR 179901473)
#
# Revision 1.1  2000/04/27  17:00:44  pinnacle
# Created: route/vrtools/VRRwDimen.I by lawaddel for Service Pack
#
# Revision 1.28  2000/04/04  21:38:14  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by lawaddel for route
#
# Revision 1.27  2000/04/03  20:58:42  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by aharihar for route
#
# Revision 1.26  2000/04/02  23:00:40  pinnacle
# Replaced: vrtools/VRRwDimen.I for: TR 179901276 by aharihar for route
#
# Revision 1.25  2000/03/31  19:34:34  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by aharihar for route
#
# Revision 1.24  2000/01/25  18:57:50  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by lawaddel for route
#
# Revision 1.23  2000/01/04  14:10:50  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by lawaddel for route
#
# Revision 1.22  1999/11/05  19:57:52  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by lawaddel for route
#
# Revision 1.21  1999/10/22  15:52:48  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by lawaddel for route
#
# Revision 1.20  1999/06/01  16:42:42  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by lawaddel for route
#
# Revision 1.18  1999/05/28  04:59:32  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by apazhani for route
#
# Revision 1.17  1999/05/27  11:20:22  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by sbilla for route
#
# Revision 1.16  1999/05/27  09:10:02  pinnacle
# Replaced: vrtools/VRRwDimen.I for:  by sbilla for route
#
 *
 * History:
 *
 *      03/08/99        law     CR179900491 - created for variable tier-spacing
 *                              for each tier for any connectpoint.
 *
 *     Apr 20, 99      Anand    CR179900491 - Corrected a minor flaw in 
 *                              VRDelOldTierAttrs (if collector id is passed
 *                              instead of a component's obj id, then call
 *                              ACrem_attribute for the collector id).
 *     May 01, 99      Alwin    Modified to handle Shape transition components
 *
 *     May 27, 99      Alwin    Modified to header information to incorporate 
 *				the history modifications.
 *     May 27,99       Reddy    Commneted the calls for VRDelOldAttributes
 *				function as it is creating the problems .
 *     May 28,99       Alwin    Made sure the deleted attributes are added to
 *				System Collector.
 *
 *     Sep 20, 99      Anand    Revamped code for proc_mode==1
 *      09/19/99        LAW     TR179900780/781- rway cleanup
 *      10/2/99         law     TR179900780 & tr179900932 - more cleanup
 *      1/4/00          law     TR179801414 -  CONRED sizes incorrect
 *      01/25/00        law     tr179900976 - transition failures
 *     Mar 31, 2k      Anand    Removed a few comments!
 *     Apr 03, 2k      Anand    Checked return codes
 *     Apr 04 00        law     tr179901338 conflict of system with crn-rad
 *     Apr 26 00        law     tr179900992 blank left over tiers
 *     Apr 26 00        law     tr179901470 depth incorrect for transitions
 *
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <stdlib.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "AS_status.h"
#include "igrtypedef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRdef.h"
#include "VRchgattrdef.h"
#include "vrparameters.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRRwDimen.h"
#include "FI.h"
#include "VRstructs.h"
#include "VRattr_def.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vrdbgmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"

extern IGRint	GetDepths4QryFromPPL(); // Implemented in vrpdu/VRRDBi.I

#define VR_SHAPE_R_E 64
#define VR_SHAPE_R_D 48
#define VR_SHAPE_C_D 50
#define VR_SHAPE_C_E 66
#define VR_SHAPE_O_D 49
#define VR_SHAPE_R_C 32
#define VR_SHAPE_R_O 16
#define RW_CMP_NB 33
#define RW_LOCATE 17
/*** local defines for form cleanup-tr179900932 *********/
#define RW_RS_SHAPE             40
#define FRM_DEPTH1_TXT  30
#define FRM_DEPTH2_TXT  35


from ACncpx     import	ACgive_structure;
from VRGeneric	import	VRGetNumberOfCpts;
from    ACrg_collect    import          ACget_named_attribute;

/* added by Alwin for VRDelOldTierAttrs() function */
from    ACrg_collect    import  AClist_attribute;
from    ACrg_collect    import  ACrem_attribute;
from    VRGeneric       import  VRGetParams;
from    VRGeneric       import  VRGetInstance;
from    VRGeneric       import  VRGetSupports;
from    VRComponent     import  VRReplace;
//from    Root     	import  delete;
/* added by Alwin for VRDelOldTierAttrs() function */

IGRint VRRw_dimen_fields(form_ptr, gadget_id, cmpobj, md_env, NbCpts, 
                      active_cpt, proc_mode, shape_code, RWcptdata,
                      AttrColl)
        
IGRchar *form_ptr; /* form pointer */
IGRint gadget_id;  /* active gadget no. */
struct GRid *cmpobj; /*comp object id */
struct          GRmd_env        *md_env;
IGRint NbCpts;  /* no. of connect points on the component */
IGRint *active_cpt; /* 0 = single column mode, otherwise active cpt */
IGRint proc_mode;  /* 0 = init, 1=processing, 2 = storage */
IGRint shape_code; /*  0 = rectangular */
struct GRid *AttrColl; /* Collection object */

struct VRRwCptDetails *RWcptdata;


{
 int row,sel_flag,pos;
 IGRint no_tier_frm;
 IGRdouble no_tier_val;
 IGRlong retcode;
 IGRint status;
 IGRdouble depth;
 IGRint no_tiers;
 IGRint i,j,k,m;
 IGRint Lst_tier_sp_ndx;
 IGRdouble Lst_tier_sp;
 IGRint attrmsk;
 IGRint NbAttr;
 struct ret_struct TmpParam;
 IGRint FootIndex = -1;
 
 IGRint intmsg;                /* return code                  */
 IGRdouble tier_sp_val;
 IGRchar temp_tn[3];
 IGRchar tier_sp_str[20];
 IGRchar active_cpt_index_fld[3];
 struct ACrg_coll NewListAttr[50]; /* Collection update structure */
 struct GRid loc_obj,chkcoll[3];
 IGRint tierndx;
 IGRint good_record;
 struct ACrg_coll Foot; /* Collection update structure */
 struct ACrg_coll      ListAttr[VR_MAX_ATTR];
 IGRint coll; 
 IGRboolean bFoundAttr=FALSE;
 IGRdouble tmp_val;
 IGRchar tiersp_str[20], notier_str[20], depth_str[20], width_str[20];

 SetProc( Fn VRRw_dimen_fields ); Begin 

 __DBGpr_int("proc_mode ",proc_mode);
 if(!cmpobj)
 {
    __DBGpr_com("No input component");
 }
 else
 {
    __DBGpr_obj("component cmpobj ",*cmpobj);
 }
 __DBGpr_int("shape_code ",shape_code);
 if(!AttrColl)
 {
    __DBGpr_com("No paramid input");
 }
 else
 {
    __DBGpr_obj("Paramid ",*AttrColl);
 }
 __DBGpr_int( " Nb. of Connect Points ", NbCpts );
 if(NbCpts < 1 || NbCpts > 10)
 {
   printf("calling VRRw_dimen_fields with NbCpts = %d\n",NbCpts);
   End
   return (OM_S_SUCCESS);
 }
 /*** if mode = 0 *****/
 if(proc_mode == 0)
 {
  /*********** INIT SECTION *****************/
   if(cmpobj)
   {
     loc_obj.objid = cmpobj->objid;
     loc_obj.osnum = cmpobj->osnum;
     status = om$send ( msg = message VRGeneric.VRGetParams(&retcode,
                                &chkcoll[0], &chkcoll[1], &chkcoll[2] ),
               senderid = NULL_OBJID,
               targetid = cmpobj->objid,
               targetos = cmpobj->osnum);
   }
   else
   {
     loc_obj = *AttrColl;
     /* We only have 1 input collector */
     chkcoll[0] = chkcoll[1] = chkcoll[2] = loc_obj;
   } 
  __DBGpr_obj( " Component/Collector Id ", loc_obj );
  __DBGpr_int( " Shape Code ", shape_code );
  /***** If NbCpts is to be displayed, this is a good place****/
  good_record = -1;
  /* For no. cpts */
  for (i=0; i<NbCpts; i++)
  {
   IGRint processtiers;
   processtiers = 0;
   k = i + 1; /* the collection index is from 1-10 */
   sprintf(width_str,"width_%d",k);
   TmpParam.var.root_pm_st.value = -1.;

   status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, width_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );
   /* Assume that if the width for a cpt is not stored, then the cpt does*/
   /* not exist.                                                         */
   if(intmsg != OM_S_SUCCESS || TmpParam.var.root_pm_st.value < BSBASISVAL)
   {
     /* Copy the last good record */
     if(good_record < 0)
     {
       __DBGpr_com("processing error in initializing instance");
       End
       return (OM_S_SUCCESS);
     }
     RWcptdata[i] = RWcptdata[good_record];
   }
   else
   {
     good_record = i;
    // AAAA modified the index "k" -> "i"
    RWcptdata[i].width = TmpParam.var.root_pm_st.value;
    __DBGpr_dbl( " The width value ", RWcptdata[i].width );
    /*** tr179900976 for transition dimension control ***/
    if (shape_code == VR_RECT) processtiers = 1; 
    else if( (shape_code == VR_RECT_CIRC) ||
        (shape_code ==VR_RECT_CORN) || (shape_code == VR_RECT_ELLP) ||
        (shape_code ==VR_RECT_OVAL))
    {
       if(k < 2)
          processtiers = 1;
    }
    if (processtiers)
    {
     IGRchar tieroldnt_str[20],tieroldsp_str[20],tiernewsp_str[20];
     IGRint newsp_found,oldsp_found,oldnt_found;
     depth = 0;
     /* if RWCPT_X_TIERSP_STR is in component collection ***/
     status =  VR_Build_Tier_Str(k,0,tiernewsp_str,NULL);
     __DBGpr_str("tier sp string",tiernewsp_str);
     __DBGpr_com( " Calling the ACget_named_attribute ... " );
     intmsg =  0;
     status = 0;

     sprintf(tieroldnt_str,"no_tiers_%d",k);
     sprintf(tieroldsp_str,"tier_sp_%d",k);
     newsp_found = 0;
     oldsp_found = 0;
     oldnt_found = 0;

     bFoundAttr = FALSE; //initialize this boolean variable. Alwin
     for(coll = 0; coll<3 && (!bFoundAttr); coll++)
     {
        IGRlong retmsg;
        status =
           om$send( msg = message ACrg_collect.AClist_attribute
                                ( &retmsg, VR_MAX_ATTR, ListAttr, &NbAttr ),
                senderid = NULL_OBJID,
                targetid = chkcoll[coll].objid,
                targetos = chkcoll[coll].osnum );
        for(j = 0; j < NbAttr ; j++)
        {
          if(!strcmp(tiernewsp_str,ListAttr[j].name))
          {
             newsp_found = 1;
             __DBGpr_str("attr found",ListAttr[j].name);
             __DBGpr_int("attr found in collector",coll);
	     bFoundAttr = TRUE;
          }
          if(!strcmp(tieroldsp_str,ListAttr[j].name))
          {
             oldsp_found = 1;
	     bFoundAttr = TRUE;
          }
          if(!strcmp(tieroldnt_str,ListAttr[j].name))
          {
             oldnt_found = 1;
	     bFoundAttr = TRUE;
          }
        }
     }
     if(newsp_found)
     {
        __DBGpr_com("********Detected new format**********");
        /* new format Get no_tiers */
        status =  VR_Build_Tier_Str(k,0,NULL,notier_str);
        TmpParam.var.root_pm_st.value = 0.;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, notier_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );

        no_tiers = (IGRint) TmpParam.var.root_pm_st.value; 
        if(no_tiers < 1 || no_tiers > 10 ||
              TmpParam.var.root_pm_st.value < BSBASISVAL)
        {
/**** This error keeps occuring with no apparent reason-- TR179900780 ***
           printf("no_tiers incorrectly stored as %d\n",no_tiers);
************************************************************************/
           no_tiers = 1;
           sprintf(depth_str,"depth_%d",k);
           TmpParam.var.root_pm_st.value = 0.;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );
           RWcptdata[i].tier_sp[0] = TmpParam.var.root_pm_st.value; 
           depth = TmpParam.var.root_pm_st.value;
        }
        else
        {
         __DBGpr_com("Getting new format tier spacing");
         for (j=0; j<no_tiers; j++)
         {
           tierndx = j + 1;
           /* Get the tier_sp */
           __DBGpr_int("cpt index",k);
           __DBGpr_obj("object",loc_obj);
           status = VRGetTierSpValue(md_env,k,tierndx,loc_obj,&tier_sp_val);

           __DBGpr_dbl("tiersp",tier_sp_val);
	   // AAAA modified the index "k" -> "i"
           RWcptdata[i].tier_sp[j] = tier_sp_val; 

           depth += tier_sp_val;
         }
/*if(i > 0 && shape_code != VR_RECT) *** Giving problems with transitions ***/
         /* TR179901470 */
         if(shape_code != VR_RECT)
         {
           sprintf(depth_str,"depth_%d",k);
           TmpParam.var.root_pm_st.value = 0.;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );
           if(TmpParam.var.root_pm_st.value > 0.0)
           {
              depth = TmpParam.var.root_pm_st.value;
           }
         }
        }

     } /* end if new collection format */
     else if(oldnt_found && oldsp_found) /* Old collection format */
     {

        FootIndex = 0;
	__DBGpr_com( " Checking for old tier attributes ... " );
        //bFoundAttr = TRUE; we don't need this at all. Alwin
        no_tiers = 0;
        TmpParam.var.root_pm_st.value = 0.;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tieroldnt_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );

        no_tiers = (IGRint) TmpParam.var.root_pm_st.value;

        TmpParam.var.root_pm_st.value = 0.;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tieroldsp_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );

        tier_sp_val = TmpParam.var.root_pm_st.value;
        if(no_tiers < 1 || no_tiers > 10 ||
              tier_sp_val < BSBASISVAL)
        {
/**** This error keeps occuring with no apparent reason-- TR179900780 ***
           printf("no_tiers incorrectly stored as %d\n",no_tiers);
************************************************************************/
           no_tiers = 1;
           sprintf(depth_str,"depth_%d",k);
           TmpParam.var.root_pm_st.value = 0.;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );
           RWcptdata[i].tier_sp[0] = TmpParam.var.root_pm_st.value;
           depth = TmpParam.var.root_pm_st.value;
        }
        else
        {
           depth = 0;
           for(j=0;j<no_tiers;j++)
           {
              RWcptdata[i].tier_sp[j] = tier_sp_val;
              depth += tier_sp_val;
           }
        }

	   /* Now its time to delete the old attributes from the Active 
	   Parameters or Components Collector. Alwin */
	// status = VRDelOldTierAttrs( loc_obj, md_env ); // Commented -Reddy
     }
     else /* params missing */
     {
           __DBGpr_com("either tier_sp, no_tiers, or both not in collection");
           no_tiers = 1;
           sprintf(depth_str,"depth_%d",k);
           TmpParam.var.root_pm_st.value = 0.;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );
           RWcptdata[i].tier_sp[0] = TmpParam.var.root_pm_st.value;
           depth = TmpParam.var.root_pm_st.value;
     }
     /* Store the no_tiers */
     RWcptdata[i].nb_tier = no_tiers;
     RWcptdata[i].depth = depth;
     __DBGpr_int( " Nb. of tiers ", no_tiers );

   } /* end if rectangular */
   else if (shape_code == VR_CIRC)
   {
      sprintf(width_str,"width_%d",k); /* Get the width instead of depth */
      TmpParam.var.root_pm_st.value = 0.;
      status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, width_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );

      depth = TmpParam.var.root_pm_st.value;
      __DBGpr_dbl( " Depth value ", depth );
   }
   else
   {
      sprintf(depth_str,"depth_%d",k);
      TmpParam.var.root_pm_st.value = 0.;
      status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );

      depth = TmpParam.var.root_pm_st.value;
      __DBGpr_dbl( " Depth value ", depth );
   }

   /* store the width and depth */
   RWcptdata[i].depth = depth;
  } /* skip if cpt does not exist */
 } /* end loop on cpts */

  __DBGpr_com( " Initializing process is over " );
  End
  return (OM_S_SUCCESS);
 }
 /******** End Init Section **********/

 /* case for proc_mode == 1 revamped by Anand (Sep '99) */
 /******** Form control section ********/
 if ( proc_mode == 1 && form_ptr != NULL )
 {
    IGRchar szText[10];
    IGRint loc_gadget;

    loc_gadget = gadget_id;
/**** TR179900780 Trouble with shape_codes *****
    if(shape_code != VR_RECT && shape_code != VR_CIRC &&
       shape_code != VR_OVAL && shape_code != VR_CORNER &&
       shape_code != VR_ELLIPSE)
    {
       FIg_display( form_ptr, FRM_WIDTH_2 );
       FIg_display( form_ptr, RW_CMP_NB );
       FIg_erase( form_ptr, RW_LOCATE );
    }
    else
    {
       FIg_erase( form_ptr, FRM_WIDTH_2 );
       FIg_erase( form_ptr, RW_CMP_NB );
       FIg_display( form_ptr, RW_LOCATE );
    }
************************************/
    /***** TR179900976 ***/
    if(shape_code == VR_OVAL_CIRC ||
       shape_code == VR_CIRC_CORN ||
       shape_code == VR_CIRC_ELLP )
    {
        /*** TRYIN to get depth1 to behave *** tr179900976 ***/
        FIg_display(form_ptr,FRM_DEPTH_1);
        FIg_display(form_ptr,FRM_DEPTH1_TXT);
        FIfld_set_mode( form_ptr, FRM_DEPTH_1, 0, FI_INSERT );
    }
    /*** tr179900976 ***/
    if(shape_code == VR_RECT_OVAL || shape_code == VR_CIRC_CORN ||
       shape_code == VR_RECT_CORN || shape_code == VR_RECT_ELLP ||
       shape_code == VR_CIRC_ELLP )
    {
       FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0, FI_INSERT );
    }


    if(shape_code == VR_CIRC_CORN ||
       shape_code == VR_CIRC      ||
       shape_code == VR_CIRC_ELLP)
    {
        /*** killin the FRM_DEPTH_1 ***/
        FIg_erase(form_ptr,FRM_DEPTH_1);
        FIg_erase(form_ptr,FRM_DEPTH1_TXT);
    }
    else
    {
        FIg_display(form_ptr,FRM_DEPTH_1);
        FIg_display(form_ptr,FRM_DEPTH1_TXT);
    }

    __DBGpr_com(" *******  PROCESSING FORM *******");
	    /* Check for valid active_cpt */
    __DBGpr_com("from display and gadget control of VRRw_dimen_fields");
    if( active_cpt == NULL )
    {
	printf("In VRRw_Dimen_fields proc_mode=1 with active_cpt=NULL\n");
	End
	return (OM_S_SUCCESS);
    }

    if (*active_cpt < 1 || *active_cpt > NbCpts)
    {
	printf("In VRRw_Dimen_fields proc_mode=1 with active_cpt>NbCpts\n");
	End
	return (OM_S_SUCCESS);
    }

      /** TR179900780 Moving cpt control up front ******/
      /******************************/
  if( *active_cpt > 1 )
  {
      FIg_get_text( form_ptr, ACTIVE_CPT_INDEX, szText);
      __DBGpr_str( " Set cpt index ", szText );

      *active_cpt = atoi( szText );
      __DBGpr_int( " Active Cpt ", *active_cpt );

      if(gadget_id == INCREASE_ACTIVE_CPT_INDEX) 
      {
          __DBGpr_com(" INCREASE_ACTIVE_CPT_INDEX");
          if(*active_cpt < NbCpts)
              (*active_cpt) ++;

          FIg_erase(form_ptr,ACTIVE_CPT_INDEX );

          active_cpt_index_fld[0] = '\0';
          sprintf( active_cpt_index_fld, "%d",*active_cpt);
          FIg_set_text(form_ptr,ACTIVE_CPT_INDEX,active_cpt_index_fld);
          FIg_set_state_off( form_ptr, gadget_id);
          FIg_display( form_ptr, ACTIVE_CPT_INDEX );

          if(*active_cpt > 2)
              FIg_enable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
          else
              FIg_disable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );

          if(*active_cpt < NbCpts)
              FIg_enable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
          else
              FIg_disable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
          loc_gadget = 0;
        }
      if(gadget_id == DECREASE_ACTIVE_CPT_INDEX) 
      {
          __DBGpr_com(" DECREASE_ACTIVE_CPT_INDEX ");
          if(*active_cpt > 2)
              (*active_cpt) --;

          FIg_erase(form_ptr, ACTIVE_CPT_INDEX);

          active_cpt_index_fld[0] = '\0';
          sprintf( active_cpt_index_fld, "%d",*active_cpt);
          FIg_set_text(form_ptr,ACTIVE_CPT_INDEX,active_cpt_index_fld);
          FIg_set_state_off( form_ptr, gadget_id);
          FIg_display( form_ptr, ACTIVE_CPT_INDEX );

          if(*active_cpt > 2)
              FIg_enable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
          else
              FIg_disable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );

          if(*active_cpt < NbCpts)
              FIg_enable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
          else
              FIg_disable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
          loc_gadget = 0;
      }
    }
    /******************************/

    sel_flag = 0;
    m = *active_cpt - 1; /* struct VRRwCptDat index variable */
    __DBGpr_int("Active array index",m);
    switch( loc_gadget )
    {
      case FRM_WIDTH_1 :
      {
	  IGRdouble tmp_width;
	  IGRdouble max_width;
	  FIg_get_value( form_ptr,FRM_WIDTH_1, &tmp_width);
	  __DBGpr_dbl(" Width 1 value from form ",tmp_width);

	  TmpParam.var.root_pm_st.value = 0.;
	  status = om$send( msg      = message ACncpx.ACgive_structure
					    ( &intmsg, &FootIndex,
					      VR_N_MAX_DEPTH_DB, &TmpParam,
					      md_env ),
			    senderid = NULL_OBJID,
			    targetid = loc_obj.objid,
			    targetos = loc_obj.osnum );
	  as$status();
	  as$status( sts = intmsg );

	  if( status == OM_S_SUCCESS )
	  {
	      max_width = TmpParam.var.root_pm_st.value;
	      __DBGpr_dbl(" Max. Width from Collector",max_width);
	  }
	  else
	      max_width = tmp_width;

	  if( tmp_width > max_width ) 
	  {
	      FIg_set_value( form_ptr, FRM_WIDTH_1 , max_width );
	      RWcptdata[0].width = max_width;
	  } 
	  else
	      RWcptdata[0].width = tmp_width ;

          /* tr179900976 */
	  if(shape_code == VR_CIRC || shape_code == VR_OVAL_CIRC ||
	     shape_code == VR_CIRC_CORN || shape_code == VR_CIRC_ELLP)
	  {
	      __DBGpr_com("make depth same as width");
	      RWcptdata[0].depth = RWcptdata[0].width;
	      FIg_set_value( form_ptr, FRM_DEPTH_1 ,RWcptdata[0].depth);
	  }
	  break;
      }
	  
      case FRM_WIDTH_2 :
      {
	  IGRdouble tmp_width;
	  IGRdouble max_width;
	  FIg_get_value( form_ptr,FRM_WIDTH_2, &tmp_width);
	  __DBGpr_dbl(" Width 2 value from form ", tmp_width );

	  TmpParam.var.root_pm_st.value = 0.;
	  status = om$send( msg      = message ACncpx.ACgive_structure
					    ( &intmsg, &FootIndex,
					      VR_N_MAX_DEPTH_DB, &TmpParam,
					      md_env ),
			    senderid = NULL_OBJID,
			    targetid = loc_obj.objid,
			    targetos = loc_obj.osnum );
	  as$status( sts = intmsg );
	  as$status();

	  if( status == OM_S_SUCCESS )
	  {
	      max_width = TmpParam.var.root_pm_st.value;
	      __DBGpr_dbl( " Max. Width from Collector ", max_width );
	  }
	  else
	      max_width = tmp_width;

	  if( tmp_width > max_width ) 
	  {
	      FIg_set_value( form_ptr, FRM_WIDTH_2 , max_width );
	      RWcptdata[m].width = max_width;
	  } 
	  else
	      RWcptdata[m].width = tmp_width ;

	  if(shape_code == VR_CIRC || shape_code == VR_RECT_CIRC)
	  {
	      __DBGpr_com("make depth same as width");
	      RWcptdata[m].depth = RWcptdata[m].width;
	      FIg_set_value( form_ptr, FRM_DEPTH_2 ,RWcptdata[m].depth);
	  }

	  break;
      }

      case FRM_DEPTH_1 :
	  __DBGpr_com(" case FRM_DEPTH_1");
	  FIg_get_value( form_ptr, FRM_DEPTH_1, &RWcptdata[0].depth );
	  break;
      
      case FRM_DEPTH_2 :
	  __DBGpr_com(" case FRM_DEPTH_2");
	  FIg_get_value( form_ptr, FRM_DEPTH_2, &RWcptdata[m].depth );
	  break;

      case FRM_NO_TIER_1 :
      {
	  FIg_get_value( form_ptr,FRM_NO_TIER_1, &no_tier_val);
	  no_tier_frm = (IGRint) no_tier_val;
	  __DBGpr_int("no_tier_frm 1",no_tier_frm);

	  if(no_tier_frm < 1)
	  {
	      no_tier_frm = 1;
	      no_tier_val = 1.0;
	      FIg_set_value(form_ptr,FRM_NO_TIER_1,no_tier_val);
	  }

	  if (no_tier_frm > RWcptdata[0].nb_tier)
	  {
      /* Pickup cpt0_tier_sp_n and copy to all new tier_sp values **/
	      Lst_tier_sp_ndx = RWcptdata[0].nb_tier - 1;
	      Lst_tier_sp = RWcptdata[0].tier_sp[Lst_tier_sp_ndx]; 

	      FIfld_set_num_rows(form_ptr, FRM_TIER_SP_1, no_tier_frm);
	      for (j=Lst_tier_sp_ndx + 1; j < no_tier_frm; j++)
	      {
		  RWcptdata[0].tier_sp[j] = Lst_tier_sp;
		  sprintf( temp_tn, "%d", j+1 );
		  FIfld_set_text( form_ptr, FRM_TIER_SP_1, j, 0,
				  temp_tn, sel_flag);
		  sprintf( temp_tn, "%.2lf", Lst_tier_sp );
		  FIfld_set_text( form_ptr, FRM_TIER_SP_1, j, 1,
				  temp_tn, sel_flag);
	      } 
	  }
          /*** TR179900992-Get rid of old tierspacing ***/
          if(no_tier_frm < 2)
          {
                  FIfld_set_text( form_ptr, FRM_TIER_SP_1, 1, 0,
                                  "", sel_flag);
                  FIfld_set_text( form_ptr, FRM_TIER_SP_1, 1, 1,
                                  "", sel_flag);
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_1, 2);
          }
          else
          {
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_1, no_tier_frm);
          }
	  RWcptdata[0].nb_tier = no_tier_frm;

	  /* recompute depth_0_store */
	  RWcptdata[0].depth = 0.0 ;
	  for (j = 0; j<no_tier_frm; j++)
	      RWcptdata[0].depth += RWcptdata[0].tier_sp[j];

	  FIg_set_value(form_ptr, FRM_DEPTH_1, RWcptdata[0].depth);

	  break;
      }

      case FRM_NO_TIER_2 :
      {
	  FIg_get_value( form_ptr,FRM_NO_TIER_2, &no_tier_val);
	  no_tier_frm = (IGRint) no_tier_val;
	  __DBGpr_int("no_tier_frm 2",no_tier_frm);

	  if(no_tier_frm < 1)
	  {
	      no_tier_frm = 1;
	      no_tier_val = 1.0;
	      FIg_set_value(form_ptr,FRM_NO_TIER_2,no_tier_val);
	  }

	  if (no_tier_frm > RWcptdata[m].nb_tier)
	  {
      /* Pickup cptm_tier_sp_n and copy to all new tier_sp values **/
	      Lst_tier_sp_ndx = RWcptdata[m].nb_tier - 1;
	      Lst_tier_sp = RWcptdata[m].tier_sp[Lst_tier_sp_ndx]; 

	      FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, no_tier_frm);
	      for (j=Lst_tier_sp_ndx + 1; j < no_tier_frm; j++)
	      {
		  RWcptdata[m].tier_sp[j] = Lst_tier_sp;
		  sprintf( temp_tn, "%d", j+1 );
		  FIfld_set_text(form_ptr, FRM_TIER_SP_2, j, 0,
				 temp_tn, sel_flag);
		  sprintf( temp_tn, "%.2lf", Lst_tier_sp );
		  FIfld_set_text(form_ptr, FRM_TIER_SP_2, j, 1,
				 temp_tn, sel_flag);
	      } 
	  }
          /*** TR179900992-Get rid of old tierspacing ***/
          if(no_tier_frm < 2)
          {
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 0,
                                  "", sel_flag);
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 1,
                                  "", sel_flag);
                  FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, 2);
          }
          else
          {
                  FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, no_tier_frm);
          }

	  RWcptdata[m].nb_tier = no_tier_frm;

	  /* recompute depth_m_store */
	  RWcptdata[m].depth = 0.0 ;
	  for (j = 0; j<no_tier_frm; j++)
	      RWcptdata[m].depth += RWcptdata[m].tier_sp[j];

	  FIg_set_value(form_ptr, FRM_DEPTH_2, RWcptdata[m].depth);

	  break;
      }
      
      case FRM_TIER_SP_1 :
      {
	  __DBGpr_com(" FRM_TIER_SP_1");

	  /* recompute depth_0_store */
	  RWcptdata[0].depth = 0.0 ;
          /* Nbr of rows not always good value tr179900780 */
/*	  FIfld_get_num_rows(form_ptr, FRM_TIER_SP_1, &no_tier_frm); */
	  FIg_get_value( form_ptr,FRM_NO_TIER_1, &no_tier_val);
          no_tier_frm = (IGRint) no_tier_val;
	  for( row=0 ; row<no_tier_frm ; row++ )
	  {
	      FIfld_get_text(form_ptr, FRM_TIER_SP_1,row,1,128,
		      tier_sp_str,&sel_flag,&pos);
	      tier_sp_val = (IGRdouble) atof(tier_sp_str);

	      RWcptdata[0].tier_sp[row] = tier_sp_val;
	      __DBGpr_dbl("value fetched",tier_sp_val);

	      RWcptdata[0].depth += RWcptdata[0].tier_sp[row];

		    /* Reset the list! */
	      sprintf( temp_tn, "%d", row+1 );
	      FIfld_set_text( form_ptr, FRM_TIER_SP_1, row, 0,
	      		      temp_tn, sel_flag);
	      sprintf( temp_tn, "%.2lf", RWcptdata[0].tier_sp[row] );
	      FIfld_set_text( form_ptr, FRM_TIER_SP_1, row, 1,
	      		      temp_tn, sel_flag);
	  }
          /*** TR179900992-Get rid of old tierspacing ***/
          if(no_tier_frm < 2)
          {
                  FIfld_set_text( form_ptr, FRM_TIER_SP_1, 1, 0,
                                  "", sel_flag);
                  FIfld_set_text( form_ptr, FRM_TIER_SP_1, 1, 1,
                                  "", sel_flag);
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_1, 2);
          }
          else
          {
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_1, no_tier_frm);
          }

	  FIg_set_value(  form_ptr, FRM_DEPTH_1 , RWcptdata[0].depth);
	  __DBGpr_dbl("depth computed",RWcptdata[0].depth);

	  break;
      }

      case FRM_TIER_SP_2 :
      {
	  __DBGpr_com(" FRM_TIER_SP_2");

	  /* recompute depth_m_store */
	  RWcptdata[m].depth = 0.0 ;
          /* tr179900780 Nbr of rows not always good value */
/*	  FIfld_get_num_rows(form_ptr, FRM_TIER_SP_2, &no_tier_frm); */
	  FIg_get_value( form_ptr,FRM_NO_TIER_2, &no_tier_val);
          no_tier_frm = (IGRint) no_tier_val;
	  for( row=0 ; row<no_tier_frm; row++)
	  {
	      FIfld_get_text( form_ptr, FRM_TIER_SP_2, row, 1, 128,
						  tier_sp_str, &sel_flag,&pos);
	      tier_sp_val = (IGRdouble) atof(tier_sp_str);

	      RWcptdata[m].tier_sp[row] = tier_sp_val;
	      RWcptdata[m].depth += RWcptdata[m].tier_sp[row];

		    /* Reset the list! */
	      sprintf( temp_tn, "%d", row+1 );
	      FIfld_set_text( form_ptr, FRM_TIER_SP_2, row, 0,
	      		      temp_tn, sel_flag);
	      sprintf( temp_tn, "%.2lf", RWcptdata[m].tier_sp[row] );
	      FIfld_set_text( form_ptr, FRM_TIER_SP_2, row, 1,
	      		      temp_tn, sel_flag);
	  }
          /*** TR179900992-Get rid of old tierspacing ***/
          if(no_tier_frm < 2)
          {
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 0,
                                  "", sel_flag);
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 1,
                                  "", sel_flag);
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, 2);
          }
          else
          {
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, no_tier_frm);
          }

	  FIg_set_value( form_ptr, FRM_DEPTH_2 , RWcptdata[m].depth );
	  break;
      }
/************** CPT control moved to front for tr179900780 *********/
      default:    /* increase/decrease cpt also will go thru here */
      case 0:     /* If gadget_id sent as NULL or 0, populate form */
      {
	  IGRboolean	bDpth1=1, bDpth2=1;

	  __DBGpr_com(" Populate form");

	  FIg_set_value( form_ptr, FRM_WIDTH_1, RWcptdata[0].width );
	  FIg_set_value( form_ptr, FRM_DEPTH_1, RWcptdata[0].depth );

	  if( *active_cpt > 1 )
	  {
	      FIg_set_value(  form_ptr, FRM_WIDTH_2, RWcptdata[m].width);
	      FIg_set_value(  form_ptr, FRM_DEPTH_2, RWcptdata[m].depth);
	  }
	  if( NbCpts<=2 )
	  {
	      FIg_erase( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
	      FIg_erase( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
	      FIg_erase( form_ptr, ACTIVE_CPT_INDEX);
	      FIg_erase( form_ptr, ACTIVE_CPT_INDEX_TEXT);
	  }
	  else
	  {
	      FIg_display(form_ptr,INCREASE_ACTIVE_CPT_INDEX);
	      FIg_display(form_ptr,DECREASE_ACTIVE_CPT_INDEX);
	      FIg_display(form_ptr,ACTIVE_CPT_INDEX);
	      FIg_display(form_ptr,ACTIVE_CPT_INDEX_TEXT);

	      if(*active_cpt > 2)
		  FIg_enable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
	      else
		  FIg_disable( form_ptr, DECREASE_ACTIVE_CPT_INDEX ); 

	      if(*active_cpt < NbCpts)
		  FIg_enable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
	      else
		  FIg_disable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
	  }

	  status = GetDepths4QryFromPPL( &retcode, shape_code, NULL,
					 &bDpth1, &bDpth2 );

	  FIfld_set_mode( form_ptr, FRM_DEPTH_1, 0,
			  ( bDpth1 ? FI_INSERT : FI_REVIEW ) );

	  FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0,
			  ( bDpth2 ? FI_INSERT : FI_REVIEW ) );
          /*** Not working consistently tr179900780***/
          if(*active_cpt == 2 && shape_code != VR_RECT &&
                                           shape_code != VR_RECT_CIRC)
          {
              FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0,FI_INSERT);
              FIg_display( form_ptr, FRM_DEPTH_2 );
          }
	    /* If the shape code is divisible by 16, it is rectangular at
	     * one or more of its ends!!!			- Anand */
	  if( !(shape_code%16) )
	  {
	      __DBGpr_com(" Component rectangular at one or more end(s).");
	      status = VRRw_chktierfrminit(form_ptr,gadget_id,1,RWcptdata);
	      FIfld_set_mode( form_ptr, FRM_DEPTH_1, 0, FI_REVIEW ); /* Just in
									case! */

	      if( ( *active_cpt > 1 ) && ( shape_code == VR_RECT ) )
	      {
		  status = VRRw_chktierfrminit( form_ptr, gadget_id,
						*active_cpt, RWcptdata);
		  FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0, FI_REVIEW ); // JIC
	      }
	      else
	      {
		  FIg_erase(form_ptr,FRM_TIER_SP_2);
		  FIg_erase(form_ptr,FRM_NO_TIER_2);
                  /* Additional added for tr179900780 */
                  /************************************/
                  if(*active_cpt == 1)
	          {
			FIg_erase(form_ptr,FRM_DEPTH_2);
			if(shape_code == VR_CIRC)
			    FIg_erase(form_ptr,FRM_DEPTH_1);
                        else
                        {
                            /*** tr179900976 ***/
                            FIg_display(form_ptr,FRM_DEPTH_1);
                        }
		  }
		  else if(shape_code != VR_RECT && 
                          shape_code != VR_RECT_CIRC && *active_cpt == 2)
		  {
	                FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0, FI_INSERT );
    		        FIg_display(form_ptr,FRM_DEPTH_2);
		  }
		  else if(shape_code == VR_RECT)
		  {
                        FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0, FI_REVIEW );
          	        FIg_display(form_ptr,FRM_DEPTH_2);
		  }
		  else if(shape_code == VR_RECT_CIRC && *active_cpt == 2)
                        FIg_erase(form_ptr,FRM_DEPTH_2);
                  /*************************/
	      }
	  }
	  else
	  {
	      /* Erase tier related fields at non-rectangular ends */
	      FIg_erase(form_ptr,FRM_TIER_SP_1);
	      FIg_erase(form_ptr,FRM_TIER_SP_2);
	      FIg_erase(form_ptr,FRM_NO_TIER_1);
	      FIg_erase(form_ptr,FRM_NO_TIER_2);
              /*** Added for TR179900780 ****/
              /******************************/
	      FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0, FI_INSERT );
              if(shape_code == VR_CIRC )
              {
                       FIg_erase(form_ptr,FRM_DEPTH_1);
                       FIg_erase(form_ptr,FRM_DEPTH_2);
              }
              else if(shape_code == VR_CIRC_CORN || shape_code == VR_CIRC_ELLP)
              {
                       /*** WAS erasing FRM_DEPTH_1 here - tr179900976 ***/
/***                     FIg_erase(form_ptr,FRM_DEPTH_1); ***/
                       if(*active_cpt >= 2)
                       {
	                  FIfld_set_mode( form_ptr, FRM_DEPTH_2, 0, FI_INSERT );
                          FIg_display(form_ptr,FRM_DEPTH_2);
                       }
              }
              else if (*active_cpt >= 2)
              {
                      FIg_display(form_ptr,FRM_DEPTH_1);
                      FIg_display(form_ptr,FRM_DEPTH_2);
              }
              /**********************************/
	  }
	  break;

      } /* End of case 0 - displayed/erased gadgets & fields and populated
	   fields in form */

    }

#ifdef vdsDEBUG
    printf("****** SUMMARY %d %s ********\n", __LINE__ , __FILE__);
    printf(" Active Cpt %d, shape code %d\n", *active_cpt, shape_code );
    printf(" Width 1 <%lf> Width 2 <%lf>\n Depth 1 <%lf> Depth 2 <%lf>\n",
					RWcptdata[0].width,RWcptdata[m].width,
					RWcptdata[0].depth,RWcptdata[m].depth );
#endif
 }  /* end proc_mode==1 */

if ( proc_mode == 2 )
{
 /********** begin storage section ***********/
 /* Get the NbCpts */
 __DBGpr_com( " Reached the Storage Section " );
 NbAttr = 0;
 /* For all cpts */
 for(m = 0; m<NbCpts; m++)
 {
   IGRchar width_store_str[20];
   IGRchar depth_store_str[20];
   IGRchar temp_store_str[20];

   k = m + 1;

   width_store_str[0] = '\0';
   depth_store_str[0] = '\0';

   /* Build width/depth storage strings */
   sprintf( width_store_str, "width_%d", k );
   sprintf( depth_store_str, "depth_%d", k );

   __DBGpr_str( " Width string ", width_store_str );
   __DBGpr_str( " Depth string ", depth_store_str );

   /* Store width_n values */
         strcpy( NewListAttr[NbAttr].name, width_store_str);
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
         NewListAttr[NbAttr].desc.value.att_exp = RWcptdata[m].width;
         NbAttr++;
   __DBGpr_dbl("width val",RWcptdata[m].width);

   /* Store depth_n values */
         strcpy( NewListAttr[NbAttr].name, depth_store_str);
         NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
         NewListAttr[NbAttr].desc.value.att_exp = RWcptdata[m].depth;
         NbAttr++;
__DBGpr_dbl("depth val",RWcptdata[m].depth);
   /* if shape_code is rectangular */
   if( ( shape_code == VR_RECT ) || ( shape_code == VR_RECT_CIRC ) ||
       ( shape_code == VR_RECT_OVAL ) || ( shape_code == VR_RECT_CORN ) ||
       ( shape_code == VR_RECT_ELLP ) )

   {
      IGRchar temptiersp[300];

      /* This condition would ensure, only the Rectangular ends tier information
      would be stored and not the non-rectangular end. Alwin */
      /*** Condition modified for TR179801414 ***/
      if( ( shape_code == VR_RECT ) || 
          ((shape_code != VR_RECT ) && ( m < 1 ) ))
{
      /* get the no_tiers */
      no_tiers = RWcptdata[m].nb_tier;

      /* build no_tier str */
      temp_store_str[0] = '\0';
      status = VR_Build_Tier_Str(k,0,NULL,temp_store_str);
      __DBGpr_str( " Tier string ", temp_store_str );

      /* store no_tier value */
      strcpy( NewListAttr[NbAttr].name, temp_store_str);
      NewListAttr[NbAttr].desc.type = AC_ATTRIB_DOUBLE;
      NewListAttr[NbAttr].desc.value.att_exp = (IGRdouble) RWcptdata[m].nb_tier;
      NbAttr++;
      __DBGpr_int("no_tiers",RWcptdata[m].nb_tier);
      temp_store_str[0] = '\0';
      temptiersp[0] = '\0';

      /* Pack and store the tier_sp data */
      sprintf(temptiersp,"%.2f",RWcptdata[m].tier_sp[0]);
      status = VR_Build_Tier_Str(k,0,temp_store_str,NULL);
      strcpy(NewListAttr[NbAttr].name, temp_store_str);
      __DBGpr_int( " Nb. of Tiers ", RWcptdata[m].nb_tier );
      __DBGpr_str( " Tier string ", temptiersp );

      if( RWcptdata[m].nb_tier > 1 ) 
      {
	  /* This loop should get executed only if the nb_tiers is more than
	  one ( 1 ). Otherwise, it unnecessarily adds up 0.00 to the end of
	  the string. B'cas it executes at least once, Alwin */

	  IGRint strstrt;
	  if (RWcptdata[m].nb_tier > 10 || RWcptdata[m].nb_tier < 1)
          {
            RWcptdata[m].nb_tier = 1;
            printf("Processing error for cpt= %d has %d tiers\n",m,
                                                       RWcptdata[m].nb_tier);
          } 
	  for( i=1; i<RWcptdata[m].nb_tier; i++ )
	  {
	     /* Build storage string */
	     temp_store_str[0] = '\0';

	     strstrt = (IGRint) strlen(temptiersp);
             __DBGpr_dbl("value to be concatenated",RWcptdata[m].tier_sp[i]);
             /* Build storage string */
             sprintf(&temptiersp[strstrt],"_%.2lf",RWcptdata[m].tier_sp[i]);
             __DBGpr_str("tier_sp store string", temptiersp);
#ifdef vdsDEBUG
             strstrt = (IGRint) strlen(temptiersp);
             __DBGpr_int("length of string",strstrt);
#endif

	  }
      }
      strcpy(NewListAttr[NbAttr].desc.value.att_txt,temptiersp);

      /* store tier_sp values */
      NewListAttr[NbAttr].desc.type = AC_ATTRIB_TEXT;
      NbAttr++;
      __DBGpr_int("NbAttr",NbAttr);
}
   }
 }
 status = VR$ModifyCollection(   p_msg                 = &retcode,
                                        Operation             = VR_MERGE_COLL,
                                        p_ParamsListToModify  = NewListAttr,
                                        NbParamsToModify      = NbAttr,
                                        p_OutputCollectionId  = AttrColl);
 __DBGpr_com("leaving VRRw_dimen_fields");
 as$status();

}
 End
 return (OM_S_SUCCESS);
}

/*********************************************************
VRRw_loc_dimen_fields function takes the parameters of the located cpt and 
loads them as Cpt1 & Cpt2 in the active parameters and calls the 
VRRw_dimen_fields function to store the data in the instance.

******************************************************* */

IGRint VRRw_loc_dimen_fields(md_env, loc_cmp, NbCptsnpt,
                      loc_cpt, target_id, shape_code, RWcptdata,
                      NewAttrColl)
struct GRid loc_cmp; /*comp object id */
IGRint NbCptsnpt;
struct          GRmd_env        *md_env;
IGRint loc_cpt; /* located cpt */
struct GRid *target_id;
IGRint shape_code; /*  0 = rectangular */
struct GRid *NewAttrColl; /* Collection object */
struct VRRwCptDetails *RWcptdata;
{
 struct ret_struct TmpParam;
 IGRint FootIndex = -1;
 IGRint intmsg;                /* return code                  */
 IGRchar depth_str[20],width_str[20];
 IGRint NbAttr;
 IGRint j,k,m,t;
 IGRint status;
 IGRint NbCpts;
 IGRint no_tiers;
 IGRdouble tier_sp_val,depth;
 IGRint  active_cpt;
 struct GRid chkcoll[3];
 IGRchar tieroldnt_str[20],tieroldsp_str[20],tiernewsp_str[20],notier_str[20];
 IGRint newsp_found,oldsp_found,oldnt_found;
 struct ACrg_coll      ListAttr[VR_MAX_ATTR];

 IGRint coll, tierndx;
 IGRboolean bFoundAttr=FALSE;
 struct ACrg_coll Foot; /* Collection update structure */
         IGRlong lngmsg;

 /* If NbCpts is  predefined and no object available */
__DBGpr_int("address of md_env",md_env);
__DBGpr_int("objid of located component",loc_cmp.objid);
__DBGpr_int("NbCpts",NbCptsnpt);
__DBGpr_int("located cpt",loc_cpt);
__DBGpr_int("address of target id",target_id);
__DBGpr_int("shape_code",shape_code);
__DBGpr_int("address of RWcptdata",RWcptdata);
__DBGpr_int("address of collector",NewAttrColl);
 if(NbCptsnpt)
   NbCpts = NbCptsnpt;
 else
 {
     if(target_id != NULL)
     {
       
         status =
         om$send ( msg = message VRGeneric.VRGetNumberOfCpts( &lngmsg, &NbCpts,
                                               md_env ),
                         senderid = NULL_OBJID,
                         targetid = target_id->objid,
                         targetos = target_id->osnum );
         as$status ( action = RET_STATUS );

     }
     else
     {
         NbCpts = 2;
     }
 }
     k = loc_cpt + 1;
     sprintf(depth_str, "depth_%d", k);
     TmpParam.var.root_pm_st.value = 0.;
     status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );
     for(m = 0; m < NbCpts; m++)
     {
       RWcptdata[m].depth = TmpParam.var.root_pm_st.value;
     }
     sprintf(width_str, "width_%d", k);
     TmpParam.var.root_pm_st.value = 0.;
     status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, width_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );
     for(m = 0; m < NbCpts; m++)
     {
        RWcptdata[m].width = TmpParam.var.root_pm_st.value;
     }

   /* if rect shapecode, get tier_data */
   if ( shape_code == VR_RECT )
   {
     depth = 0.0; /* Clix compiler complaining */
     __DBGpr_com("rectangular shape");
     status = om$send ( msg = message VRGeneric.VRGetParams(&lngmsg,
                                &chkcoll[0], &chkcoll[1], &chkcoll[2] ),
               senderid = NULL_OBJID,
               targetid = loc_cmp.objid,
               targetos = loc_cmp.osnum);

     status =  VR_Build_Tier_Str(k,0,tiernewsp_str,NULL);
     __DBGpr_str("tier sp string",tiernewsp_str);
     __DBGpr_com( " Calling the ACget_named_attribute ... " );
     intmsg =  0;
     status = 0;
     sprintf(tieroldnt_str,"no_tiers_%d",k);
     sprintf(tieroldsp_str,"tier_sp_%d",k);
     newsp_found = 0;
     oldsp_found = 0;
     oldnt_found = 0;

     bFoundAttr = FALSE;
     for(coll = 0; coll<3 && !(bFoundAttr); coll++)
     {
        IGRlong retmsg;
        __DBGpr_int("collector index",coll);
        __DBGpr_obj("collector id",chkcoll[coll]);
        status =
           om$send( msg = message ACrg_collect.AClist_attribute
                                ( &retmsg, VR_MAX_ATTR, ListAttr, &NbAttr ),
                senderid = NULL_OBJID,
                targetid = chkcoll[coll].objid,
                targetos = chkcoll[coll].osnum );
        for(j = 0; j < NbAttr ; j++)
        {
          __DBGpr_int("attr",j);
          __DBGpr_str("attr name",ListAttr[j].name);
          if(!strcmp(tiernewsp_str,ListAttr[j].name))
          {
             newsp_found = 1;
	     bFoundAttr = TRUE;
          }
          if(!strcmp(tieroldsp_str,ListAttr[j].name))
          {
             oldsp_found = 1;
	     bFoundAttr = TRUE;
          }
          if(!strcmp(tieroldnt_str,ListAttr[j].name))
          {
             oldnt_found = 1;
	     bFoundAttr = TRUE;
          }
        }
     }
     /*** Modified for tr179900780 ***/
     if(newsp_found && shape_code == VR_RECT)
     {
        __DBGpr_com("********Detected new format**********");
        /* new format Get no_tiers */
        status =  VR_Build_Tier_Str(k,0,NULL,notier_str);
        TmpParam.var.root_pm_st.value = 0.;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, notier_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );

        no_tiers = (IGRint) TmpParam.var.root_pm_st.value;
       if(no_tiers < 1 || no_tiers > 10 ||
              TmpParam.var.root_pm_st.value < BSBASISVAL)
        {
/**** This error keeps occuring with no apparent reason-- TR179900780 ***
           printf("no_tiers incorrectly stored as %d\n",no_tiers);
************************************************************************/
           no_tiers = 1;
           sprintf(depth_str,"depth_%d",k);
           TmpParam.var.root_pm_st.value = 0.;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );
           for(m = 0; m < NbCpts; m++)
           {
              RWcptdata[m].tier_sp[0] = TmpParam.var.root_pm_st.value;
           }
           depth = TmpParam.var.root_pm_st.value;
        }
        else
        {
         __DBGpr_com("Getting new format tier spacing");
         for (j=0; j<no_tiers; j++)
         {
           tierndx = j + 1;
           /* Get the tier_sp */
           __DBGpr_int("cpt index",k);
           __DBGpr_obj("object",loc_cmp);
           status = VRGetTierSpValue(md_env,k,tierndx,loc_cmp,&tier_sp_val);

           __DBGpr_dbl("tiersp",tier_sp_val);
           // AAAA modified the index "k" -> "i"
           for(m = 0; m < NbCpts; m++)
           {
              RWcptdata[m].tier_sp[j] = tier_sp_val;
           }

           depth += tier_sp_val;
         }
        }

     } /* end if new collection format */
     else if(oldnt_found && oldsp_found) /* Old collection format */
     {

        FootIndex = 0;
        __DBGpr_com( " Checking for old tier attributes ... " );
        //not_found = 1; We don't need this at all. Alwin
        no_tiers = 0;
        TmpParam.var.root_pm_st.value = 0.;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tieroldnt_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );
        no_tiers = (IGRint) TmpParam.var.root_pm_st.value;

        TmpParam.var.root_pm_st.value = 0.;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tieroldsp_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );

        tier_sp_val = TmpParam.var.root_pm_st.value;
        if(no_tiers < 1 || no_tiers > 10 ||
              tier_sp_val < BSBASISVAL)
        {
/**** This error keeps occuring with no apparent reason-- TR179900780 ***
           printf("no_tiers incorrectly stored as %d\n",no_tiers);
************************************************************************/
           no_tiers = 1;
           sprintf(depth_str,"depth_%d",k);
           TmpParam.var.root_pm_st.value = 0.;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );
           for(m = 0; m < NbCpts; m++)
           {
              RWcptdata[m].tier_sp[0] = TmpParam.var.root_pm_st.value;
           }
           depth = TmpParam.var.root_pm_st.value;
        }
        else
        {
           depth = 0;
           for(j=0;j<no_tiers;j++)
           {
              for(m = 0; m < NbCpts; m++)
              {
                 RWcptdata[m].tier_sp[j] = tier_sp_val;
              }
              depth += tier_sp_val;
           }
        }

           /* Now its time to delete the old attributes from the Active
           Parameters or Components Collector. Alwin */
        // status = VRDelOldTierAttrs( loc_cmp, md_env ); // Commented - Reddy
     }
     else /* params missing */
     {
           __DBGpr_com("either tier_sp, no_tiers, or both not in collection");
           no_tiers = 1;
           sprintf(depth_str,"depth_%d",k);
           TmpParam.var.root_pm_st.value = 0.;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_cmp.objid,
                      targetos = loc_cmp.osnum );
           for(m = 0; m < NbCpts; m++)
           {
              RWcptdata[m].tier_sp[0] = TmpParam.var.root_pm_st.value;
           }
           depth = TmpParam.var.root_pm_st.value;
     }
     /* Store the no_tiers */
     for(m = 0; m < NbCpts; m++)
     {
        RWcptdata[m].nb_tier = no_tiers;
        RWcptdata[m].depth = depth;
        __DBGpr_int( " Nb. of tiers ", no_tiers );
     }

   } /* end if rectangular */
  
  active_cpt = 0;
__DBGpr_com( " Calling14 VRRw_dimen_fields ");
  status = VRRw_dimen_fields(NULL, NULL, NULL, md_env, NbCpts,
                      &active_cpt, 2, shape_code, RWcptdata,
                      NewAttrColl);

return (OM_S_SUCCESS);
}

/*************************************************************************/
/* This function is to build the collection query/store string for either*/
/* tier spacing, no_tiers, or both                                       */
/* If the tierspstr address is null, then only the notierstr is returned */
/* If the notierstr address is null, and the notiers is 0, then the      */
/* tierspstr contains the string to request the concatenated tier-sp     */
/* string for all tier spacings for the cpt                              */
/* If the tierspstr has an address and the ntier value > 0, the string   */
/* returned is to request the numeric value of the tier spacing for the  */
/* tier defined by ntier and the cpt defined by ncpt.                    */
/*************************************************************************/
int VR_Build_Tier_Str(ncpt,ntier,tierspstr,notierstr)
  IGRint ncpt, ntier;
  IGRchar *tierspstr, *notierstr;
{
if(ncpt < 1 || ncpt > 10 )
{
 if(tierspstr )
   tierspstr[0] = '\0';
 if(notierstr)
   notierstr[0] = '\0';
}
else if(ntier < 1 )
{
  if(notierstr)
    sprintf(notierstr, "no_tiers_%d", ncpt);
  if(tierspstr)
    sprintf(tierspstr, "cpt%d_tiersp", ncpt);
}
else 
{
  if(notierstr)
    sprintf(notierstr, "no_tiers_%d", ncpt);
  if(tierspstr)
    sprintf(tierspstr, "cpt%d_tiersp_%d", ncpt, ntier);
}

return (OM_S_SUCCESS);
}

/* added by Alwin for VRDelOldTierAttrs() function */
IGRint VRDelOldTierAttrs( struct GRid CompId, struct GRmd_env *md_env )
{
  IGRint        i, NbCpts=0, NbAttr;
  IGRlong       status, msg;
  IGRchar       AttrName[20];
  struct GRid   SysParamId, UserParamId, MissParamId;

  SetProc( Fn VRDelOldTierAttrs ); Begin

/* Reddy - Enabled it in order to take the legacy issues into account */
/**
  __DBGpr_com("******* disabled VRDelOldTierAttrs ***********");
  if(1)                        
     return (OM_S_SUCCESS);
**/

  __DBGpr_com( " Calling VRGetNumberofCpts ... " );
  status = om$send ( msg = message VRGeneric.VRGetNumberOfCpts(
                        &msg, &NbCpts, md_env ),
                         senderid = NULL_OBJID,
                         targetid = CompId.objid,
                         targetos = CompId.osnum );
  //as$status ( action = RET_STATUS );

  __DBGpr_int( " Nb. of Connect points ", NbCpts );

  /* The attributes that are to be removed are "no_tier*" and "tier_sp*"
  and for the component whose connect point above 2, we should be deleting
  the "width3/depth3, ... */

  if( msg & status & 1 )
  {
      status = om$send ( msg = message VRGeneric.VRGetParams( &msg,
                              &SysParamId, &UserParamId, &MissParamId ),
                       senderid = NULL_OBJID,
                       targetid = CompId.objid,
                       targetos = CompId.osnum );
      as$status ( action = RET_STATUS );
  }
  else
      /* Below lines added by Anand */
  {
      NbCpts		=	2;
      SysParamId.objid	=	CompId.objid;
      SysParamId.osnum	=	CompId.osnum;
      MissParamId.objid	=	CompId.objid;
      MissParamId.osnum	=	CompId.osnum;
  }
      /* Above lines added by Anand */

  for( i=1; i<3; i++ )
  {
      /* This means I've to remove "tier_sp*" */

      AttrName[0] = '\0';
      sprintf( AttrName, "tier_sp_%d", i );
      __DBGpr_str( " Calling the ACrem_attribute ... ", AttrName );
      status = om$send ( msg = message ACrg_collect.ACrem_attribute
				( &msg, AttrName ),
		       senderid = NULL_OBJID,
		       targetid = SysParamId.objid,
		       targetos = SysParamId.osnum );
      //as$status ( action = RET_STATUS );

      if( msg & 1 )
	 __DBGpr_str( " Successfully deleted the attribute ", AttrName );
  }

  if( NbCpts == 2 )
  {
    End
    return OM_S_SUCCESS;
  }

  /* Handle the attributes which are added to the Missing Collectors, If there
  are no other attributes in the collector other than depth* /width* attributes,
  I might as well go ahead and remove it from the Parent list of the component.
  */

  for( i=3; i<=NbCpts; i++ )
  {
        IGRint Index, NbAttr;
        IGRdouble width, depth;
        struct ret_struct strWidth;
        struct ACrg_coll NewListAttr[10];

        AttrName[0] = '\0';
        sprintf( AttrName, "width_%d", i );
        strcpy( NewListAttr[0].name, AttrName );

        status = om$send ( msg = message ACrg_collect.ACgive_structure
                                ( (IGRint*)&msg, &Index, AttrName,
                                &strWidth, md_env ),
                         senderid = NULL_OBJID,
                         targetid = MissParamId.objid,
                         targetos = MissParamId.osnum );
        width = strWidth.var.root_pm_st.value;

	__DBGpr_str( " Calling remove attribute for ", AttrName );
        status = om$send ( msg = message ACrg_collect.ACrem_attribute
                                  ( &msg, AttrName ),
                         senderid = NULL_OBJID,
                         targetid = MissParamId.objid,
                         targetos = MissParamId.osnum );
        //as$status ( action = RET_STATUS );

        if( status & msg & 1 )
           __DBGpr_str( " Successfully deleted the attribute ", AttrName );

        AttrName[0] = '\0';
        sprintf( AttrName, "depth_%d", i );
        strcpy( NewListAttr[1].name, AttrName );

        status = om$send ( msg = message ACrg_collect.ACgive_structure
                                ( (IGRint*)&msg, &Index, AttrName,
                                &strWidth, md_env ),
                         senderid = NULL_OBJID,
                         targetid = MissParamId.objid,
                         targetos = MissParamId.osnum );
        depth = strWidth.var.root_pm_st.value;

	__DBGpr_str( " Calling remove attribute for ", AttrName );
        status = om$send ( msg = message ACrg_collect.ACrem_attribute
                                  ( &msg, AttrName ),
                         senderid = NULL_OBJID,
                         targetid = MissParamId.objid,
                         targetos = MissParamId.osnum );
        //as$status ( action = RET_STATUS );

        if( status & msg & 1 )
           __DBGpr_str( " Successfully deleted the attribute ", AttrName );

	/* Add these attributes into System Collector, so that the recompute
	doesn't complain about attributes missing. Alwin */
        NbAttr = 0;
        NewListAttr[0].desc.type = AC_ATTRIB_DOUBLE;
        NewListAttr[0].desc.value.att_exp = width;
        NbAttr++;

        NewListAttr[1].desc.type = AC_ATTRIB_DOUBLE;
        NewListAttr[1].desc.value.att_exp = depth;
        NbAttr++;

        status = VR$ModifyCollection(   p_msg                 = &msg,
                                        Operation             = VR_MERGE_COLL,
                                        p_ParamsListToModify  = NewListAttr,
                                        NbParamsToModify      = NbAttr,
                                        p_OutputCollectionId  = &SysParamId );
  }

  /* After deleting all the known attributes, check if there is anything else
  left over before deleting it. If you find one or more attributes still present
  in the Collector leave the collector intact and proceed further. Or else
  Replace the component with Two collector and remaining topological parents,
  this would automatically remove the empty collector, b'cas the collector
  get constructed with ( ND_DEL_NO_CH ); so it's suppose to delete itself
  when it doesn't have any children */

  /* Get the number of attributes present in the collector */
  NbAttr = 0;
  status = om$send ( msg = message ACrg_collect.AClist_attribute( &msg,
                                VR_MAX_ATTR, NULL, &NbAttr ),
                         senderid = NULL_OBJID,
                         targetid = MissParamId.objid,
                         targetos = MissParamId.osnum );
  as$status ( action = RET_STATUS );
//  if( NbAttr == 0 ) disable the delete because of errors
  if (0)
  {
     IGRint             arraysize=10, NbSupports=0;
     struct GRid        SegIds[10], ParentsList[10];
     struct VRGenInfo   CmpInstance;
     struct IGRdisplay  ActiveDisplay; /* Active Display              */
     struct GRvg_construct  CnstList;
     struct GRas        assoc_list;

     /* Delete the missing Parameters collector, this could cause 
     trouble later*/
     status = om$send ( msg = message Root.delete(0),
                         senderid = NULL_OBJID,
                         targetid = MissParamId.objid,
                         targetos = MissParamId.osnum );
     as$status ( action = RET_STATUS );

     status = om$send ( msg = message VRGeneric.VRGetInstance( &msg,
                                        &CmpInstance ),
                       senderid = NULL_OBJID,
                       targetid = CompId.objid,
                       targetos = CompId.osnum );
     as$status ( action = RET_STATUS );

     --CmpInstance.nNbAttr; /* decrement the NbAttr by one to indicate that
                                the missing Collector has been removed */

     /* Get the topological parents Id */
     status = om$send ( msg = message VRGeneric.VRGetSupports( &msg,
                                    arraysize, SegIds, &NbSupports ),
                       senderid = NULL_OBJID,
                       targetid = CompId.objid,
                       targetos = CompId.osnum );
     as$status ( action = RET_STATUS );

     ParentsList[0] = SysParamId;
     ParentsList[1] = UserParamId;

     for(i=0; i<CmpInstance.nNbTopo; i++ )
             ParentsList[i+CmpInstance.nNbAttr] = SegIds[i];

     assoc_list.as_attr        = ( IGRchar * ) &CmpInstance;
     assoc_list.num_parents    = CmpInstance.nNbTopo + CmpInstance.nNbAttr;
     assoc_list.go_objid.objid = NULL_OBJID;
     assoc_list.parents        = ParentsList;

     /*| Initialize graphics placement arguments */
     status = VRGetConstructionList
             ( &msg, md_env, NULL, NULL, &ActiveDisplay, NULL, &CnstList);

     status = om$send( msg      = message VRComponent.VRReplace
                         ( &assoc_list, md_env, ( IGRchar * ) &CnstList ),
                   senderid = NULL_OBJID,
                   targetid = CompId.objid,
                   targetos = CompId.osnum );
     as$status( action = RET_STATUS );

     nd$exec_batch();
  }

  End
  return OM_S_SUCCESS;
}
/* added by Alwin for VRDelOldTierAttrs() function */

/****************************************************************************/
/* function to check tier fields against instance for initializing the form */
/****************************************************************************/

int VRRw_chktierfrminit(form_ptr,gadget_id,cpt,cptdata)
IGRchar *form_ptr;
IGRint gadget_id;
IGRint cpt;
struct VRRwCptDetails *cptdata;

{
IGRint no_tier_field, tier_sp_field;
IGRint j,k,m;
IGRint sel_flag,pos;
IGRdouble tier_sp_val;
IGRchar tier_sp_str[90], temp_tn[3];
IGRint no_tier_frm;
IGRdouble no_tier_val;

SetProc( Fn VRRw_chktierfrminit ); Begin 

__DBGpr_int("cpt",cpt);
     if(cpt > 10)
     {
         __DBGpr_int("Bad cpt",cpt);
         cpt =1;
     }
k = cpt -1;
if(cpt == 1)
{
   no_tier_field = FRM_NO_TIER_1;
   tier_sp_field = FRM_TIER_SP_1;
}
else
{
   no_tier_field = FRM_NO_TIER_2;
   tier_sp_field = FRM_TIER_SP_2;
}
no_tier_frm = 0; /* CLIX compile complaining */
     /* If no_tier_1 gadget input ****/
     if(gadget_id != no_tier_field)
     {
       no_tier_frm = cptdata[k].nb_tier;
       no_tier_val = (IGRdouble) no_tier_frm;
       FIg_set_value(form_ptr,no_tier_field,no_tier_val);
     __DBGpr_dbl( " Nb of tier field ", no_tier_val );
     }
     FIfld_set_num_rows(form_ptr, tier_sp_field, no_tier_frm);

     /* Note that if no_tiers have changed, we dont want to change spacings*/
     if(gadget_id != tier_sp_field  && gadget_id != no_tier_field)
     {
       for (j=0; j<no_tier_frm; j++)
       {
          /* get the spacing from the form */
	 __DBGpr_com( " CHECK 28 " );

         {
            /* put the instance value in the form */
            sprintf(tier_sp_str,"%lf", cptdata[k].tier_sp[j]);
            m = j + 1;
	    __DBGpr_com( " CHECK 28.3 " );
            sprintf(temp_tn,"%d",m);
            sel_flag = 0;

	    __DBGpr_com( " CHECK 28.6 " );
            FIfld_set_text(form_ptr,tier_sp_field,j,0,
                                       temp_tn,sel_flag);

            FIfld_set_text(form_ptr,tier_sp_field,j,1,
                                       tier_sp_str,sel_flag);

	    __DBGpr_str( " tier spacing string ", tier_sp_str );
         }
       }
     }

  End
  return OM_S_SUCCESS;
}

/* Function to get either old or new tierspacing value */
int VRFetchTierdata(md_env,cpt_ndx, cmpobj, obj_is_param, no_tiers, tier_sp)
IGRint cpt_ndx; /* 1:10 */
IGRint *no_tiers; /* 1:10 */
struct GRid cmpobj; /* object id */
IGRint obj_is_param;
IGRchar *tier_sp;
struct          GRmd_env        *md_env;

{
 struct ret_struct TmpParam;
 IGRint FootIndex = -1;
 IGRlong retmsg;
 IGRlong retcode;
 IGRint coll, NbAttr, status, intmsg;
 struct GRid chkcoll[3];
 struct ACrg_coll      ListAttr[VR_MAX_ATTR];
 IGRchar tieroldnt_str[20],tieroldsp_str[20],tiernewsp_str[20];
 IGRint newsp_found,oldsp_found,oldnt_found,width_found;
 IGRchar depth_str[20],width_str[20];
 IGRint k, j;
 IGRdouble tier_sp_val;
 IGRint i, strstrt, not_stop;

     k = cpt_ndx ;
     if(obj_is_param)
     {
       chkcoll[0] = cmpobj;
       chkcoll[1].objid = NULL_OBJID;
       chkcoll[2].objid = NULL_OBJID;
     }
     else
     {
       status = om$send ( msg = message VRGeneric.VRGetParams(&retcode,
                                &chkcoll[0], &chkcoll[1], &chkcoll[2] ),
               senderid = NULL_OBJID,
               targetid = cmpobj.objid,
               targetos = cmpobj.osnum);
     }

     /* if RWCPT_X_TIERSP_STR is in component collection ***/
     status =  VR_Build_Tier_Str(k,0,tiernewsp_str,NULL);
     __DBGpr_str("tier sp string",tiernewsp_str);

     sprintf(tieroldnt_str,"no_tiers_%d",k);
     sprintf(tieroldsp_str,"tier_sp_%d",k);
     sprintf(width_str,"width_%d",k);
     sprintf(depth_str,"depth_%d",k);
     newsp_found = 0;
     oldsp_found = 0;
     oldnt_found = 0;
     width_found = 0;
     for(coll = 0; coll<3 ; coll++)
     {
      /* Check which tier data is present in collection */
      if(chkcoll[coll].objid != NULL_OBJID)
      {
        status =
           om$send( msg = message ACrg_collect.AClist_attribute
                                ( &retmsg, VR_MAX_ATTR, ListAttr, &NbAttr ),
                senderid = NULL_OBJID,
                targetid = chkcoll[coll].objid,
                targetos = chkcoll[coll].osnum );
        not_stop = 1;
        for(j = 0; j < NbAttr && not_stop; j++)
        {
          if(ListAttr[j].name[0] == '\0') not_stop = 0;
          else if(!strcmp(tiernewsp_str,ListAttr[j].name))
          {
             newsp_found = 1;
             __DBGpr_str("attr found",ListAttr[j].name);
             __DBGpr_int("attr found in collector",coll);
          }
          if(!strcmp(tieroldsp_str,ListAttr[j].name))
          {
             oldsp_found = 1;
          }
          if(!strcmp(tieroldnt_str,ListAttr[j].name))
          {
             oldnt_found = 1;
          }
          if(!strcmp(width_str,ListAttr[j].name))
          {
             width_found = 1;
          }
        }
      }
     }
     /* If cpt does not exist */
     if(! width_found )
     {
       __DBGpr_int("1No cpt ndx",cpt_ndx);
       sprintf(tier_sp,"%.2f",0.0 );
       *no_tiers = 0;
       return(OM_S_SUCCESS);
     }
     /* Get the no_tiers */
     if(oldnt_found)
     {
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tieroldnt_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmpobj.objid,
                      targetos = cmpobj.osnum );

        *no_tiers = (IGRint) TmpParam.var.root_pm_st.value;
        if(*no_tiers < 1 || *no_tiers > 10)
        {
           *no_tiers = 1;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmpobj.objid,
                      targetos = cmpobj.osnum );
           sprintf(tier_sp,"%.2f", TmpParam.var.root_pm_st.value);
           return (OM_S_SUCCESS);
        }
     }
     else
     {
        *no_tiers = 1;
        TmpParam.var.root_pm_st.value = 0.0;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmpobj.objid,
                      targetos = cmpobj.osnum );
        sprintf(tier_sp,"%.2f",TmpParam.var.root_pm_st.value );
        return (OM_S_SUCCESS);
     }

     if(newsp_found)
     {
         __DBGpr_com("********Detected new format**********");
         __DBGpr_com("Getting new format tier spacing");
         TmpParam.var.text_st.text_string[0] = '\0';
         status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tiernewsp_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmpobj.objid,
                      targetos = cmpobj.osnum );
         strcpy(tier_sp,TmpParam.var.text_st.text_string);
         __DBGpr_str("tiersp",tier_sp);

     } /* end if new collection format */
     else if(oldsp_found) /* Old collection format */
     {
        FootIndex = 0;
        __DBGpr_com( " Checking for old tier attributes ... " );

        TmpParam.var.root_pm_st.value = 0.;
        status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tieroldsp_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmpobj.objid,
                      targetos = cmpobj.osnum );

        tier_sp_val = TmpParam.var.root_pm_st.value;

      /* Pack and store the tier_sp data */
      sprintf(tier_sp,"%.2f",tier_sp_val);
      if( *no_tiers > 10)
      {
        *no_tiers = 1;
        printf("Processing error for no_tiers\n");
      } 
      if( *no_tiers > 1 ) 
      {
	  for( i=1; i<*no_tiers; i++ )
	  {
             strstrt = (IGRint) strlen(tier_sp);
             __DBGpr_dbl("value to be contenated",tier_sp_val);
             /* Build storage string */
             sprintf(&tier_sp[strstrt],"_%.2lf",tier_sp_val);
             __DBGpr_str("tier_sp store string", tier_sp);
             __DBGpr_int("length of string",strstrt);
          }
      }
     }
     else
     {
           *no_tiers = 1;
           status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, depth_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = cmpobj.objid,
                      targetos = cmpobj.osnum );
           sprintf(tier_sp,"%.2f", TmpParam.var.root_pm_st.value);
     }
     __DBGpr_com("Leaving VRFetchTierdata");
return (OM_S_SUCCESS);
}

/* function is to return a single tier spacing from the concatenated string */
 int VRGetTierSpValue(md_env,cpt_ndx,tierndx,loc_obj,tiers_sp)
IGRint cpt_ndx; /* 1:10 */
IGRint tierndx; /* 1:10 */
struct GRid loc_obj; /* Either object or paramid */
IGRdouble *tiers_sp;
struct          GRmd_env        *md_env;
{
  IGRchar tiersp_str[200],notier_str[200];
  IGRint n,intndx,notierval,firstchr,chr,notfound;
 struct ret_struct TmpParam;
 IGRint FootIndex = -1;
 IGRint intmsg, status;                /* return code                  */

  __DBGpr_int("tier_ndx",tierndx);
  VR_Build_Tier_Str(cpt_ndx,0,tiersp_str,notier_str);
  TmpParam.var.root_pm_st.value = 0.;
  status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, notier_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );
  notierval = (IGRint) TmpParam.var.root_pm_st.value;
  __DBGpr_int("no_tiers from collector",notierval);
  if(tierndx < 1 || tierndx > notierval)
  {
    printf("processing error in VRGetTierSpValue, illegal tierndx\n");
    *tiers_sp = 0.;
    return (OM_S_SUCCESS);
  }
  status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &intmsg, &FootIndex, tiersp_str,
                                &TmpParam, md_env ),
                      senderid = NULL_OBJID,
                      targetid = loc_obj.objid,
                      targetos = loc_obj.osnum );

  intndx = tierndx -1;
  firstchr = 0;
  for (n = 0; n<intndx; n++)
  {
    notfound = 1;
    for(chr=firstchr; chr<200 && notfound ; chr++)
    {
       if(TmpParam.var.text_st.text_string[chr] == '_')
       {
         notfound = 0;
         firstchr = chr + 1;
       }
       else if (TmpParam.var.text_st.text_string[chr] == '\0')
       {
         printf("non-existent tier spacing\n");
         *tiers_sp = 0.;
         return (OM_S_SUCCESS);
       }
    }
    if(notfound)
    {
      printf("tier data not found\n");
      *tiers_sp = 0.;
      return (OM_S_SUCCESS);
    }
 }
    notfound = 1;
    for(chr=firstchr; chr<200 && notfound ; chr++)
    {
       if(TmpParam.var.text_st.text_string[chr] == '_' ||
          TmpParam.var.text_st.text_string[chr] == '\0')
       {
         notfound = 0;
         TmpParam.var.text_st.text_string[chr] = '\0';
       }
    }
    if(notfound)
    {
      printf("tier data confused\n");
      *tiers_sp = 0.;
      return (OM_S_SUCCESS);
    }
    sscanf(&TmpParam.var.text_st.text_string[firstchr],"%lf",tiers_sp);

return (OM_S_SUCCESS);
}

/* This function is not in use. Alwin */
#if 0

/* This function to be used only for Raceways. When the user moves to the
next cpt to feed the data; we need to store the information fed to the form
for the present cpt. If the next cpt information's is already present we need
to display them, this could be TRUE in Replace Component command.

gadget_label - If the input is INCREASE_ACTIVE_CPT_INDEX or
		DECREASE_ACTIVE_CPT_INDEX, then we need to store the information
		in the RwCptData structure and increase/decrease the number
		of connect point index text. 

		If the input happened to FI_ACCEPT/FI_EXECUTE; then we need to 
		store the information alonw for the corresponding and quit the
		functio and we don't need to worry about the connect point
		text.
CmpNbCpts - Number of connect points in a component

*/

IGRlong VRRStoreTierInfo( IGRchar *form_ptr, IGRint gadget_label, IGRint shape,
                          IGRint CmpNbCpts, struct VRRwCptDetails *RwCptData )
{
    IGRint      proc_mode, active_cpt, i, index;
    IGRchar     szText[10];
    IGRint sel_flag,pos;

    SetProc( Fn VRRStoreTierInfo ); Begin

    if( RwCptData == NULL || form_ptr == NULL )
    {
       __DBGpr_com( " Wrong Input " );
       End
       return OM_S_SUCCESS;
    }

    __DBGpr_int( " Shape code ", shape );

    if( shape != VR_RECT )
    {
       IGRdouble dValue;

       /* Store the values keyed in the width 2 area */
       FIg_get_value( form_ptr, FRM_WIDTH_2, &dValue );
       RwCptData[1].width = dValue;

       /* Store the values keyed in the depth 2 area */
       FIg_get_value( form_ptr, FRM_DEPTH_2, &dValue );
       RwCptData[1].depth = dValue;

       End
       return OM_S_SUCCESS;
    }

    FIg_set_state_off( form_ptr, gadget_label);

    FIg_get_text( form_ptr, ACTIVE_CPT_INDEX, szText);
    __DBGpr_str( " active cpt text ", szText );

    active_cpt = atoi( szText );
    __DBGpr_int( " Active Cpt ", active_cpt );

    if( active_cpt <= CmpNbCpts )
    {
       IGRdouble dValue, dDepth;

       index = active_cpt -1 ;

       /* Store the values keyed in the width 2 area */
       FIg_get_value( form_ptr, FRM_WIDTH_2, &dValue );
       RwCptData[index].width = dValue;

       /* Store the values keyed in the tier_spacing area */
       FIg_get_value( form_ptr, FRM_NO_TIER_2, &dValue );
       RwCptData[index].nb_tier = (IGRint)dValue;

       dDepth = 0.0;
       for( i=0; i<(IGRint) dValue; i++ )
       {
         IGRint col = 1, row;

         row = i;
         FIfld_get_value( form_ptr, FRM_TIER_SP_2, row, col,
                                &RwCptData[index].tier_sp[i],
                                FALSE, NULL );
         dDepth += RwCptData[index].tier_sp[i];
       }
       /*** TR179900992-Get rid of old tierspacing ***/
          if(RwCptData[index].nb_tier < 2)
          {
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 0,
                                  "", sel_flag);
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 1,
                                  "", sel_flag);
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, 2);
          }
          else
          {
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2,
                                            RwCptData[index].nb_tier);
          }

       RwCptData[index].depth = dDepth;

       szText[0] = '\0';

       if( gadget_label == INCREASE_ACTIVE_CPT_INDEX )
       {
           ++active_cpt;
           sprintf( szText, "%d", active_cpt );
	   FIg_enable( form_ptr, DECREASE_ACTIVE_CPT_INDEX );
       }
       else if( gadget_label == DECREASE_ACTIVE_CPT_INDEX )
       {
           --active_cpt;
           sprintf( szText, "%d", active_cpt );
	   FIg_enable( form_ptr, INCREASE_ACTIVE_CPT_INDEX );
       }
       else 
       {
	  __DBGpr_com( " Store and quit the function " );
	  End
	  return OM_S_SUCCESS;
       }

       __DBGpr_str( " Active Cpt Text ", szText );

       FIg_set_text( form_ptr, ACTIVE_CPT_INDEX, szText );

       if( ( active_cpt == CmpNbCpts ) ||
           ( active_cpt == 2 ) )
          FIg_disable( form_ptr, gadget_label );
       else
       {
         if( RwCptData[index].nb_tier > 0 )
         {
            FIg_set_value( form_ptr, FRM_NO_TIER_2,
                           RwCptData[index].nb_tier );

            FIfld_set_list_num_rows( form_ptr, FRM_TIER_SP_2,
                       0, RwCptData[index].nb_tier );

            for( i=0; i<RwCptData[index].nb_tier; i++ )
            {
               IGRint col = 1, row;

               row = i;
               FIfld_set_value( form_ptr, FRM_TIER_SP_2,
                                row, 0, i+1, FALSE );

               FIfld_set_value( form_ptr, FRM_TIER_SP_2,
                        row, col,
                  RwCptData[index].tier_sp[i], FALSE );
            }
         }
       }
       /*** TR179900992-Get rid of old tierspacing ***/
          if(RwCptData[index].nb_tier < 2)
          {
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 0,
                                  "", sel_flag);
                  FIfld_set_text( form_ptr, FRM_TIER_SP_2, 1, 1,
                                  "", sel_flag);
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, 2);
          }
          else
          {
	          FIfld_set_num_rows(form_ptr, FRM_TIER_SP_2, 
                                                    RwCptData[index].nb_tier);
          }

       FIg_display( form_ptr, ACTIVE_CPT_INDEX );
       FIg_display( form_ptr, gadget_label );
    }

    End
    return OM_S_SUCCESS;
}
#endif

end implementation Root;

