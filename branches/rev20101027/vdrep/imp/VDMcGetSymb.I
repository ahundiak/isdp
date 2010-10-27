/* $Id: VDMcGetSymb.I,v 1.1.1.1 2001/01/04 21:09:07 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrep/imp / VDMcGetSymb.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDMcGetSymb.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:07  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*****************************************************************************/
/*
/*	Function to get or store active error symbology in VDS
/*	Implemented as a funcion of ACrg_collect as that's where
/*	the base code is inherited from.
/*
$Log: VDMcGetSymb.I,v $
Revision 1.1.1.1  2001/01/04 21:09:07  cvs
Initial import to CVS

# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
Revision 141.1  91/04/19  18:10:35  phillip
COMMENT : Add print_symb fn support new representation values

Revision 141.0  91/04/18  19:29:28  phillip
COMMENT : Storage now via collections, Remove init and print fns, ret_cod is now long not ptr to long

******************************************************************************/

class implementation ACrg_collect;


#include <stdio.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "OMminimum.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#define  AS_DEBUG 1 
#include "AS_status.h"

#define  NOVDSEXT 1
#include "VDSsymb_def.h"
#include "ACrg_collect.h"

#define  ACTIVE_SYMB ":IGENOD:ACsymb"

/************************************************************************/
/*									*/
/*	VDSsymbology : This function is designed to perform a store or  */
/*			  retreive operation on the current active      */
/*			  active parameters object. It also returns the */
/*			  objid of the object corresponing to the osnum */
/*			  given by the caller.				*/
/*	arg : IN							*/
/*		IGRlong *msg		: return code for call		*/
/*		IGRint	operation	: type of operation		*/
/*						  STORE OR RETRIEVE	*/
/*		struct	GRid *symb_id	 : osnum = working os	*/
/*									*/
/*		struct  VDSsymb * symbology  : pointer to symbology	*/
/*						 : == addr for RETREIVE */
/*						 : == addr for STORE	*/
/*	arg : OUT							*/
/*		objid OUT = id						*/
/*		struct  VDSsymb *symbology				*/
/*			pointer to active parameters structure		*/
/*			when RETRIEVE operation				*/
/*									*/
/************************************************************************/

int VDSsymbology(  msg, operation, symb_id, symbology )
IGRlong		*msg;
IGRint		operation;
struct	GRid	*symb_id;
struct VDSsymb	*symbology;
{
IGRchar			path_name[DI_PATH_MAX];
IGRlong			rc;
struct ACrg_coll	list[6];
IGRlong			status;

  /* Ignoring given osnum */
  status = ex$get_cur_mod( osnum = &symb_id->osnum );
  if ( operation == RETRIEVE ) {

    ACget_def_NVrep(  &symbology->representation, &symbology->VDSerror );
  }
  else if ( operation == STORE && symbology == NULL ) {

    return ( OM_E_INVARG );
  }
  else if ( operation == STORE ) {

    *msg = di$give_pathname( osnum = symb_id->osnum,
			     pathname = path_name );

    if ( *msg != DIR_S_SUCCESS ) {

      di$report_error( sts = *msg,  comment = "error in give pathname" );	
      return ( OM_E_INVARG );
    }

    strcat( path_name, ACTIVE_SYMB );

    *msg = di$translate ( objname = path_name,
			  osnum	  = symb_id->osnum,
			  p_objid = &symb_id->objid );
    if ( *msg != DIR_S_SUCCESS ) {
      if ( *msg == DIR_W_NAME_NOT_FOUND ) {
        /*
         * we create the default collection object
	 */
	ACget_def_NVrep(  &symbology->representation, &symbology->VDSerror );
      }
    else
      return( *msg );
    }

    strcpy(list[0].name,"rgb_value");
    list[0].desc.type= AC_ATTRIB_DOUBLE;
    list[0].desc.value.att_exp = 0.0;

    strcpy(list[1].name,"color");
    list[1].desc.type= AC_ATTRIB_DOUBLE;
    list[1].desc.value.att_exp = symbology->VDSerror.display_attr.color;

    strcpy(list[2].name,"weight");
    list[2].desc.type= AC_ATTRIB_DOUBLE;
    list[2].desc.value.att_exp = symbology->VDSerror.display_attr.weight;

    strcpy(list[3].name,"style");
    list[3].desc.type= AC_ATTRIB_DOUBLE;
    list[3].desc.value.att_exp = symbology->VDSerror.display_attr.style;

    strcpy(list[4].name,"level");
    list[4].desc.type= AC_ATTRIB_DOUBLE;
    list[4].desc.value.att_exp = symbology->VDSerror.level;

    strcpy(list[5].name,"representation");
    list[5].desc.type= AC_ATTRIB_DOUBLE;
    list[5].desc.value.att_exp = symbology->representation;

    status =
    om$send(msg = message ACrg_collect.ACmod_list_attribute(&rc,6,list),
                  senderid = NULL_OBJID,
                  targetid = symb_id->objid,
                  targetos = symb_id->osnum );
   
  }
  else{
    *msg = OM_E_INVARG;
    return ( *msg );
  }

  *msg = OM_S_SUCCESS;
  return( *msg );
}

/**************************************************************************/
/*                                                                        */
/*      fct VDSprint_symb This function initilize active parameter     */
/*      IN - OUT                pointer to structure VDSsymb      */
/**************************************************************************/
VDSprint_symb( symbology )

struct VDSsymb *symbology;
{
  switch( symbology->representation )
  {
    case 0x2: printf("representation = Symbolic \n" ); break;
    case 0x4: printf("representation = Detailed \n" ); break;
    case 0x8: printf("representation = Envelope \n" ); break;
    default : printf("representation = %d\n", symbology->representation );
    break;
  }

  printf( " level %d \n", symbology->VDSerror.level );
  printf( " color %d \n", symbology->VDSerror.display_attr.color );
  printf( " weight %d \n", symbology->VDSerror.display_attr.weight );
  printf( " style %d \n", symbology->VDSerror.display_attr.style );

  return 1;
}

end implementation ACrg_collect;

