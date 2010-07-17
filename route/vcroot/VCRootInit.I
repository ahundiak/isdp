/* $Id: VCRootInit.I,v 1.3 2002/05/08 15:48:25 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vcroot / VCRootInit.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *    $Log: VCRootInit.I,v $
 *    Revision 1.3  2002/05/08 15:48:25  anand
 *    Files added/modified for sub-cable functionality.
 *
 *    Revision 1.2  2001/02/20 01:11:17  build
 *    Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *    Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *    Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/03/15  23:52:18  pinnacle
# Replaced: vcroot/VCRootInit.I for:  by kddinov for route
#
# Revision 1.4  1998/03/14  19:42:18  pinnacle
# Replaced: vcroot/VCRootInit.I for:  by kddinov for route
#
# Revision 1.3  1998/03/11  17:14:52  pinnacle
# Replaced: vcroot/VCRootInit.I for:  by kddinov for route
#
# Revision 1.2  1998/02/21  19:11:04  pinnacle
# Replaced: vcroot/VCRootInit.I for:  by kddinov for route
#
# Revision 1.1  1998/02/18  19:45:44  pinnacle
# Created: vcroot/VCRootInit.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	Feb/98		KDD	VCInitInstance, VDputAttrDrivenSymb
 *
 *************************************************************************/

class implementation VCRoot;

/*
#define	vdsDEBUG	1
*/


#include "go.h"
#include "vddgndef.h"
#include "vddgnmacros.h"
#include "AS_status.h"
#include "vdattmacros.h"
#include "v_drw.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

extern 	long 	VD_dgnSt_cvrtToString();

/*------------------------------------------------------------------------------
*
* Initialization of var char variables. 
*
------------------------------------------------------------------------------*/
method VCInitInstance (IGRlong *msg)
{
  IGRlong	status;

SetProc(VCInitInstance); Begin;

        *msg = MSSUCC;


__DBGpr_int("Address of me->Data", me->Data); 

  status = om$vla_set_dimension( varray = me->Data,
                                 size   = 0 );

__DBGpr_int("return status of vla_set_dimension 0 for me->Data", status);

__DBGpr_int("Address of me->DataType", me->DataType); 

  me->DataType = 0; /* unknown data type */



End
return (OM_S_SUCCESS);
}

/*------------------------------------------------------------------------------
*
* method: VDputAttrDrivenSymb
*
* Copy of VDSroot.VDputAttrDrivenSymb. 
*
* Changes:
* 1. The return status is OS_S_SUCCESS always.
* 2. Default file name is cableattr.symb.
*------------------------------------------
*
* NOTE: VDsetAttDrSymb communicates with the "design setup parameters" form.
*
*------------------------------------------
* PARAMETERS
*
* char		*fileName     - name of the symbology file. Can be NULL.
*				This on is OVERRIDE by the filename on the
*				form "VDDgnStpPrm" if the later exists.
*				Use command "Design Setup Parameters" to 
*				change the symbology filename.
------------------------------------------------------------------------------*/
method VDputAttrDrivenSymb( long *msg; struct GRmd_env *md_env; char *fileName)
{
struct  GRsymbology     symbology;
IGRlong                 sts;
struct GRid             collId, objId;
VD_drwOutputData        *output = NULL;
 
        SetProc( VDputAttrDrivenSymb ); Begin
        *msg = MSSUCC;

        objId.objid = my_id;
        objId.osnum = OM_Gw_current_OS;
 
        collId.objid = NULL_OBJID ;
        sts =
        VDgetVdCollId( msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
        if( (sts&*msg&1) ) {
            /* use user defined file to drive the symbology */

__DBGpr_obj("Symbology collection object", collId);

            sts = VDsetAttDrSymb(msg, objId, md_env, output );

            VD_drwFreeOutputData( &output ) ;
            if ( (sts&*msg&1) ) goto wrapup;
        }

/*----------------------
# KDD 3-98 Load from symbology file in case of errors.
*---------------------*/
	{
	    char	MyFile[64];

	    if (fileName && (fileName[0] != '\0')) strncpy(MyFile, fileName,64);
            else			   strcpy(MyFile, "cableattr.symb");

__DBGpr_str("Load symbology file", MyFile); 

            sts = om$send( msg = message VDSroot.VDgetAttrDrivenSymb(
                                        msg,
                                        MyFile,
                                        md_env,
                                        &symbology),
                   targetid = my_id );
 
            if ( (sts&*msg&1) ) {
__DBGpr_int("put symbology in object [%d]\n", (int) my_id); 

                sts = om$send( msg = message GRvg.GRputsymb(
                                        msg,
                                        &symbology),
                        targetid = my_id );
	     }
        }
 
/* KDD 3-98 symbology failure shouldn't break placement, compute, etc. */
        as$status( sts = sts, msg = "VCRoot.VDputAttrDrivenSymb failure");
 
wrapup:
        End
        *msg = MSSUCC;
        return OM_S_SUCCESS;
}

method VCDataTypeSize( IGRint *PcktSize )
{
    //This method should be overridden.
    *PcktSize = 0;

    return OM_S_SUCCESS;
}

method VCSetDataVLA( void	*InstanceAttr;
		     IGRint	NbInstAttr;
		     IGRshort	DataType )
{
    /* Do yourself a favor and override it. This one simply initializes it. */
    IGRint status;
    IGRlong msg;

    status = om$send( msg = message VCRoot.VCInitInstance( &msg ),
		      targetid = my_id,
		      mode = OM_e_wrt_message );

    return status;
}

method VCGetDataVLA( void	*InstAttr;
		     IGRint	*nNbAttr;
		     IGRshort	*DataType )
{
    IGRint status,size,i, PacketSize;

    SetProc( VCRoot_VCCGetDataVLA ); Begin;
 
    __DBGpr_me();
 
    size = om$dimension_of( varray = me->Data );
    __DBGpr_int(" Dimension of me->Data", size);

    *DataType = me->DataType;

    status = om$send( msg = message VCRoot.VCDataTypeSize( &PacketSize ),
		      targetid = my_id );
    if( PacketSize )
	*nNbAttr = size / PacketSize;
    else
	*nNbAttr = 0;

    __DBGpr_int(" Number of attributes", *nNbAttr);
 
    if( *nNbAttr == 0 )
    {
	__DBGpr_com(" This object does not any root-level attributes.");
	goto quit;
    }
 
    __CheckPtr( InstAttr, "User interested only in Nb Attributes", quit);

    switch( me->DataType )
    {
	case 0:  // In Cable level, this would be VC_LEGACY_JUN02
	    /* Should never get here (ideally). If DataType is zero, so would
	     * the size of the vla. */
	    _FREE( InstAttr );
	    /* Rationale for free: Caller sends allocated pointer to
	     * VCGetDataVLA. So _FREE frees it and sets it to NULL. If this
	     * produces a core dump - GOOD! Should give an opportunity to
	     * understand why me->DataType is zero despite vla's dimension not
	     * being zero. */
	    End;
	    return OM_E_ABORT;
	case 1 :  // In Cable level, this would be VC_ACRG_COLLECT
	    memcpy(InstAttr, me->Data, size);
	    break;
//      case 2:
	       /* Alternative structure when needed after 2.5 */

	default:
	    return OM_E_ABORT;
    }


quit:
 
    End;
    return(OM_S_SUCCESS);
}


end implementation VCRoot;

