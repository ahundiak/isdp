
/* $Id: VCRxgrover.I,v 1.2 2001/02/20 01:11:24 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:      vcroot / VCRxgrover.I
 *
 * Description:
 *    VCRoot override of GR methods
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCRxgrover.I,v $
 *      Revision 1.2  2001/02/20 01:11:24  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/09/11  23:14:40  pinnacle
# Replaced: vcroot/VCRxgrover.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.7  1997/08/28  15:11:28  pinnacle
# Replaced: vcroot/VCRxgrover.I for:  by apazhani for cabling
#
# Revision 1.6  1997/07/14  21:58:06  pinnacle
# Replaced: vcroot/VCRxgrover.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/10  14:03:48  pinnacle
# Replaced: vcroot/VCRxgrover.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/19  15:53:48  pinnacle
# Replaced: vcroot/VCRxgrover.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/06  22:34:24  pinnacle
# Replaced: vcroot/VCRxgrover.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  21:56:46  pinnacle
# Replaced: vcroot/VCRxgrover.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:14:14  pinnacle
# Created: vcroot/VCRxgrover.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR      DESCRIPTION
 *      06/10/96    hv          Initial
 *      08/28/97    Alwin       Removed the restriction for the terminal,
 *                              Backshell and Cable movement, when connected
 *                              to a parent.
 *
 *************************************************************************/

class implementation VCRoot;

#include "vc_define.h"
#include "vrdbgmacros.h"

method GRgetobjinfo(IGRlong     *msg;
             struct GRobj_info  *info)

{
  IGRchar      string[100];
  IGRchar      szRep[8];
  IGRchar      szStr[VC_MAX_TAGNO];
  IGRint       status, length=0;

  SetProc( Md GRgetobjinfo ); Begin 

  *msg = MSSUCC;

  /* -- component type (11 characters) -- */
  __DBGpr_com( " Get the Product " );
  status = 
  om$send ( msg = message VCRoot.VCGetProduct ( NULL, string ),
       targetid = my_id);

  strcat(string,"-");

  if ( me->nVCStat & VC_ERROR )
  {
    /*| ERROR COMPONENT */
    strcat(string,"Error: ");
  }

  __DBGpr_com( " Get the components code " );
  status = 
  om$send ( msg = message VCRoot.VCGetCode (szStr),
       targetid = my_id);
  __DBGpr_str( " Components Code ", szStr );

  if( !strlen(szStr) )
      strcat(string," No Code? ");
  else
  {
      strcat(string, szStr);
      strcat(string,"-");
  }

  /* -- add tag number -- */

  szStr[0] = '\0';
  __DBGpr_com( " Get the Tag Number " );
  status = 
  om$send ( msg = message VCRoot.VCGetTagNo (szStr),
       targetid = my_id);
  __DBGpr_str( " Tag Number ", szStr );

  if (strlen(szStr))
  {
    strcat (string, szStr);
    strcat(string,"-");
  }

  /* -- add NVrepresentation (4 characters) -- */

  status =
  om$send (msg = message VCRoot.VCGetRep (NULL, szRep),
      targetid = my_id);

  strcat (string, "(");
  strcat (string, szRep);
  strcat (string, ")");

  length = strlen( string );
  string[length+1] = '\0';

  strcpy ( info->type,string );

  End
  return(OM_S_SUCCESS);

}/* end GRgetobjinfo */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              override     method GRxform                            
/*
/*  DESCRIPTION: A component is allowed to move if is not attached to any 
                 topology. -- by Henk.

                 As per the CR179701612, we need to remove this restriction, 
                 and which allows the Terminal/Backshell/Cable to be move even 
                 if it is connected to a Parent. --Alwin
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method GRxform (IGRlong     *msg;
         struct GRmd_env    *md_env;
                IGRshort    *matrix_type;
                IGRmatrix    matrix;
                GRobjid     *newobjid )
{

  IGRint  status;

  *msg = MSSUCC;

/*  if ((me->nVCTopo == 0) || (me->nVCStat & VC_CLONE))
    The restriction is being removed */

  if ((me->nVCTopo >= 0) || (me->nVCStat & VC_CLONE))
  { /*| No topological attachement to a network */
    /* -- Send xform to the graphics -- */

    status =
    om$send ( msg = message GRgraphics.GRxform
                               ( msg, md_env, matrix_type, matrix, newobjid ),
     p_chanselect = &AS_to_comp);

    status =
    om$send( msg = message NDnode.NDchange_node ( md_env ),
        targetid = my_id);
    as$status(action = RET_STATUS);

    *newobjid = my_id;
  }
  else
  { /*| Normal behaviour */
    status =
    om$send ( msg = message ACncpx.GRxform
                               ( msg, md_env, matrix_type, matrix, newobjid ),
             mode = OM_e_wrt_message,
         targetid = my_id );

  }

  return status;

}/* end GRxform */


end implementation VCRoot;
