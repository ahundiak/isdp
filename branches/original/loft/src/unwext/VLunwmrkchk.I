/* $Id: VLunwmrkchk.I,v 1.1 2001/03/16 23:58:58 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loft/src/unwext/VLunwmrkchk.I
 *
 * Description: Function to check if there are some marking lines overlapping
 *		and delete one. Also changes the text to FS/NS.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwmrkchk.I,v $
 *      Revision 1.1  2001/03/16 23:58:58  ramarao
 *      Fixed CR# 4467
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/16/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "VDobj.h"
#include "VDmem.h"
#include "v_geommacros.h"
#include "vlunfold.h"
#include "vlunwext.h"
#include "vlstructure.h"
#include "vldbgmacros.h"

IGRlong	VLunwChkMarkOverlap( IGRlong		*msg,
			     struct GRobj_env	*unwrapOE,
			     struct GRid	*featID,
			     struct GRid	*graphicID,
			     IGRint		*is_ns_fs    )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, j, feature_count=0, numDistCvs1=0, numDistCvs2=0, 
			numOvCvs=0, ovLapCode, optlines[UNWEXT_NB_OPT];
IGRshort                action, props;
struct GRid		chkGeomID, chkFeatID;
struct EdgeMatch        *match_list=NULL;
struct IGRbsp_curve     *crv1Geom=NULL, *crv2Geom=NULL, **DCvs1=NULL,
                        **DCvs2=NULL, **OCvs=NULL;

   SetProc( VLunwChkMarkOverlap ); Begin

   sts = *msg = MSSUCC;

   *is_ns_fs = FALSE;

   for ( i=0; i<UNFOLD_NB_OPTLINE; i=i+1 ) optlines[i] = 0;

   optlines[UNFOLD_ATT_IDX_MARK] = 1;

   __DBGpr_obj( "Input Unwrap", unwrapOE->obj_id );

   sts = VLunwGetFeatureLines( msg, unwrapOE->obj_id, optlines,
			       &feature_count, &match_list  );
   __CheckRC( sts, *msg, "VLunwGetFeaturesParents", wrapup );

   __DBGpr_int( "Marking Feature Count", feature_count );


   sts = vd_$get_geometry( msg = msg, grobjId = graphicID,
			   grobjEnv = &unwrapOE->mod_env, geometry = &crv1Geom );
   __CheckRC( sts, *msg, "vd_$get_geometry", wrapup );

   for( i=0; i<feature_count; ++i )
   {
        __DBGpr_obj( "Checking Feature", match_list[i].EdgeId );

        ASget_as_owner( &match_list[i].EdgeId, &chkGeomID );
        ASget_as_owner( &chkGeomID, &chkFeatID );

        if( featID->objid == chkFeatID.objid &&
    	    featID->osnum == chkFeatID.osnum     ) continue;

        _FREE( crv2Geom );
        sts = vd_$get_geometry( msg = msg, grobjId = &match_list[i].EdgeId,
		   grobjEnv = &unwrapOE->mod_env, geometry = &crv2Geom );
	if( !(sts&1&(*msg)) )  continue;

        if( numDistCvs1 )
        {
           for( j=0; j<numDistCvs1; ++j )      BSfreecv( &rc, DCvs1[j] );
           _FREE( DCvs1 );
           numDistCvs1 = 0;
        }
        if( numDistCvs2 )
        {
           for( j=0; j<numDistCvs2; ++j )      BSfreecv( &rc, DCvs2[j] );
           _FREE( DCvs2 );
           numDistCvs2 = 0;
        }
        if( numOvCvs )
        {
           for( j=0; j<numOvCvs; ++j )      BSfreecv( &rc, OCvs[j] );
           _FREE( OCvs );
           numOvCvs = 0;
        }

        BSchk2cvsov( crv1Geom, crv2Geom, 1.0, 1, &ovLapCode,
                     &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                     &numOvCvs, &OCvs, &rc );

        /*
         * If there is no exact ( complete ) overlap, just continue;
         */
        if( rc != BSSUCC || ovLapCode != 6 ) continue;

	__DBGpr_com( "Features are Exactly Overlapping" );

	*is_ns_fs = TRUE;

	props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	action = 0;
	sts = om$send ( msg = message GRgraphics.GRchgprops(
                                   	  msg, &action, &props ),
			   senderid = NULL_OBJID,
                           targetid = chkFeatID.objid,
                           targetos = chkFeatID.osnum );
	if( !(sts&1&(*msg)) )  continue;

     }

wrapup:
   _FREE( crv1Geom );
   _FREE( crv2Geom );
   _FREE( match_list );
   if( numDistCvs1 )
   {
      for( j=0; j<numDistCvs1; ++j )      BSfreecv( &rc, DCvs1[j] );
      _FREE( DCvs1 );
      numDistCvs1 = 0;
   }
   if( numDistCvs2 )
   {
      for( j=0; j<numDistCvs2; ++j )      BSfreecv( &rc, DCvs2[j] );
      _FREE( DCvs2 );
      numDistCvs2 = 0;
   }
   if( numOvCvs )
   {
      for( j=0; j<numOvCvs; ++j )      BSfreecv( &rc, OCvs[j] );
      _FREE( OCvs );
      numOvCvs = 0;
   }
   End
   return sts;
}

end implementation VDSroot;
