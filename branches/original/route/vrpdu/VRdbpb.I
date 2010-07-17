/* $Id: VRdbpb.I,v 1.2 2002/04/15 20:01:46 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRdbpb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRdbpb.I,v $
 *  Revision 1.2  2002/04/15 20:01:46  anand
 *  Removed version.h and associated dependencies. version.h is
 *  an include file in $EXNUC.
 *
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  17:29:54  pinnacle
# Replaced: vrpdu/VRdbpb.I for:  by r240_int for route240
#
 *
 * History:
 *  01/17/96   tlb  Add prototypes
 *      Change VRget_branch, VRaccess_db_1 to ANSII style
 *
 *************************************************************************/

class implementation Root;

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "AS_status.h"
#include "gr.h"
#include "VRdef.h"
#include "dberror.h"
#include "VRDbStruct.h"
#include  <stdio.h>
#include "VRmsg.h"
#include "ms.h"
#include "msdef.h"
#include "msmacros.h"
#include "nddef.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "VRDbCache.h"
#include "VRPDBdef.h"
#include "vrpdu_pto.h"

/*#define DEBUG 1  */

#define   VERSION   "2.0.0"

/**************************************************************/
/*       NEW GLOBAL DEFINITIONS                               */

extern
struct VRPDB_project   VRGL_PROJ;
extern
IGRint                 VRGL_specunit;

/**************************************************************/

extern     UI_status();

from NDnode  import  NDchg_state;

/*************************************************************************/
/*  VRaccess_db_1()                                                      */
/*            Executes dbs access functions and creates a parameter box  */
/*            object which is then passed back to the caller.            */
/*                                     */
/*************************************************************************/
IGRint VRaccess_db_1 ( 
   IGRlong             *msg,         /* message                      (O)  */
   IGRchar             *spec_name,   /* spec name, hvac class or     (I)  */
                                     /* vendor code                       */
   IGRchar             *comp_name,   /* AABBCC code                  (I)  */
   IGRdouble           size_1,       /* green dia, 0 or width1       (I)  */
   IGRdouble           size_2,       /* red dia, 0 or depth1         (I)  */
   IGRshort            option,       /* option code, shape code or   (I)  */
                                     /* rway_type.                        */
   IGRchar             *fam_name,    /* family or macro name         (O)  */
   IGRshort            *comp_topo,   /* component topology           (O)  */
   IGRshort            *comp_type,   /* component reporting category (O)  */
   struct GRid         *pbid,        /* parameter box (I=osnum)    (I/O)  */  
   IGRchar             *err_ptr     /* error message buffer         (O)  */
   )
    
{
  /************************************************************************/
  /*                                                                      */
  /* This routine extracts parameters from the reference database and     */
  /* constructs a parameter box which is then returned to the caller.     */
  /*                                                                      */
  /* For application VR_PIPING :                                          */
  /*                                                                      */
  /*   This routine extracts family name,component topology, component    */
  /*   reporting category from the spec database and and macro parameters */
  /*   from the PDM/PDU tables.              */
  /*                                                                      */
  /* For application VR_HVAC :                                            */
  /*                                                                      */
  /*   This routine extracts macro name, component topology, component    */
  /*   reporting category and some parameters.                            */
  /*                                                                      */
  /* For application VR_CABLING :                                         */
  /*                                                                      */
  /*   This routine extracts macro name, component topology, component    */
  /*   reporting category and some parameters.                            */
  /*                                                                      */
  /*                                                                      */
  /************************************************************************/

   struct ACrg_coll    mac_pm[MAX_MACRO_PARAMS];  /* struct for params    */
   IGRint             pm_no;        /* Count for the mac_pm struct       */
   char   part_number[MAX_PDM_PARTNO_SIZE];    /* PDM part number      */
   int    comp_numcp;                /* Number of connect points          */
   int    comp_seccp;                /* Red connect point identifier      */
   int    offset_flag;
   int    sts;

  pm_no = 0;     /* Initialize the count for the mac_pm struct */

#ifdef DEBUG
  printf("  VRaccess_db_1 of version : %s\n", VERSION);
#endif

  sts = VRenq_proj_units();
  if( sts == -1)
  {
    *msg = VR_E_DbShortErrMsg;
    return(OM_E_ABORT);
  }

  /* Get data from VDS tables */

  sts =
  access_piping (  spec_name, comp_name, size_1, size_2, option,
                   fam_name, part_number, comp_topo, comp_type,
                   &comp_numcp, &comp_seccp, mac_pm, &pm_no, err_ptr);
  if (sts != 1)
  {
    *msg = VR_E_DbShortErrMsg;
    return(OM_E_ABORT);
  }

  if ( fam_name[0] == 0 || part_number[0] == 0 )
  {
    printf("Family name/Part number undefined for %s\n",comp_name);
    printf("No data from family table\n");
    if(err_ptr != NULL)
    {
      ex$message ( msgnumb  = VR_E_DbLongErrMsg,
      type    = "%s%s%s",
      var     = `"piping_comps","Family_name/Part_no_prfx",comp_name`,
      buff    = err_ptr);
    }
    *msg = VR_E_FamOrPartnoUndef; 
    return (OM_E_ABORT);
  }

  /* Get data from PDM/PDU tables */

#ifdef DEBUG
printf("  Accessing PDM/PDU parameters\n");
#endif

  sts =
  access_db (fam_name, part_number, *comp_type, mac_pm, &pm_no,
              err_ptr, &offset_flag );

  if (sts != 1)
  {
    *msg = VR_E_DbShortErrMsg;
    return(OM_E_ABORT);
  }
     
  if(!offset_flag )
  {

#ifdef  DEBUG
printf("  Setting component offsets\n");
#endif
    sts =
    set_offset ( comp_numcp, mac_pm, &pm_no );
  }
      

  /* Create the parameter box */

  pbid->objid = NULL_OBJID;

  sts = 
  VR$ModifyCollection (
      p_msg       = msg,
      Operation      = VR_MERGE_COLL,
      p_ParamsListToModify   = mac_pm,
      NbParamsToModify   = pm_no,
      p_OutputCollectionId   = pbid );

  sts =
  om$send( msg = message NDnode.NDchg_state(
        ( (IGRchar)  ND_DEL_NO_CH ),
        ( (IGRchar) ~ND_DEL_NO_CH ) ),
    senderid = NULL_OBJID,
    targetid = pbid->objid,
    targetos = pbid->osnum ) ;

     
#ifdef DEBUG
 printf("  Parameter box id: %d\n",pbid->objid);
#endif

  *msg = ACC_S_SUCCESS;
  return sts;
}


/************************************************************************/
/*                                                                      */
/* This routine extracts AABBCC code of the branch from the reference   */
/* database for applications -                                          */
/*                                                                      */
/*                    VR_PIPING                                         */
/*                    VR_HVAC                                           */
/*                    VR_CABLING                                        */ 
/*                                                                      */
/*                                                                      */
/************************************************************************/
IGRint VRget_branch (
   IGRlong             *msg,         /* message                      (O)  */
   IGRshort            application,  /* Piping, HVAC or Cabling      (I)  */
   IGRchar             *spec_name,   /* spec name, hvac class or     (I)  */
                                     /* vendor code                       */
   IGRdouble           size_1,       /* green dia or 0               (I)  */
   IGRdouble           size_2,       /* red dia or 0                 (I)  */
   IGRdouble           angle,        /* branch angle                 (I)  */
   IGRint              comp_type,    /* comp type ( race way only)   (I)  */
   IGRchar             *comp_code,   /* AABBCC code of branch        (O)  */
   IGRchar             *err_ptr     /* Error message buffer         (O)  */
   )
{

   int       sts;
   double    SIZE_1, SIZE_2, ANGLE;
   int       proj_no;

   proj_no = 0;

   sts = VRenq_proj_units();
   if( sts == -1)
   {
      *msg = VR_E_DbShortErrMsg;
      return (OM_E_ABORT);
   }
  
   if (application == VR_PIPING)
   {    
       sts = Get_piping_spec_units( proj_no, spec_name,err_ptr);
       if(sts != 1)
       {
           *msg = VR_E_DbShortErrMsg;
           return (OM_E_ABORT);
       }

       if( VRGL_PROJ.prj_units != VRGL_specunit ) 
       {
          SIZE_1 = get_allowed_npd(VRGL_PROJ.prj_units,VRGL_specunit,size_1,
                                   spec_name,proj_no,err_ptr);
          SIZE_2 = get_allowed_npd(VRGL_PROJ.prj_units,VRGL_specunit,size_2,
                                   spec_name, proj_no, err_ptr);
          ANGLE  = converted_to_vds( "bend_ang",VRGL_PROJ.prj_units,
                                   VRGL_specunit,angle,err_ptr);

       }
       else
       {
          SIZE_1 = size_1;
          SIZE_2 = size_2;
          ANGLE  = angle;
       }

     /* Get AABBCC code of branch from VDS database */
     sts = get_piping_br_comp_code ( spec_name, SIZE_1, SIZE_2,
                                     ANGLE, comp_code,err_ptr);

   }
   else if (application == VR_HVAC)
   {
     /* Get AABBCC code of branch from VDS database */
     sts = get_hvac_br_comp_code ( spec_name, angle, comp_code,err_ptr );
   }
   else if (application == VR_CABLING)
   {

     /* Get AABBCC code of branch from VDS database */
     sts = get_rway_br_comp_code ( spec_name, angle, comp_type, comp_code,
                                   err_ptr );
   }

  if (sts != 1)
  {
    *msg = VR_E_DbShortErrMsg;         
    return OM_E_ABORT;
  }

  return OM_S_SUCCESS;
}

end implementation Root;
