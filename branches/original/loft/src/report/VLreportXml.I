/* $Id: VLreportXml.I,v 1.6 2001/11/09 15:36:29 ahundiak Exp $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        isdp/loft/src/report/VLreportXml.I
 *
 * Description: Function to report lofting objects to XML format.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLreportXml.I,v $
 *      Revision 1.6  2001/11/09 15:36:29  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/08 23:00:15  ramarao
 *      Added buffer argument.
 *
 *      Revision 1.4  2001/09/26 16:29:20  ramarao
 *      XML reporting.
 *
 *      Revision 1.3  2001/09/25 19:54:08  ramarao
 *      XML reporting.
 *
 *      Revision 1.1  2001/09/24 19:30:53  ramarao
 *      XML reporting.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/24/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "EMSmsgdef.h"
#include "cotxmacros.h"
#include "DIprims.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDctx.h"
#include "VDvalConv.h"
#include "vscmd.h"
#include "v_datamacros.h"
#include "vlstructure.h"
#include "VLxmlreport.h"
#include "vlstifbend.h"
#include "vlpinjig.h"
#include "vlglobals.h"
#include "vlmiscmacros.h"
#include "vldbgmacros.h"


from GRtext		import	GRgettxattr;
from ACrg_collect	import	ACget_named_attribute;

static IGRlong	VLgetDomNodeFromXml( IGRchar		*xmlFile,
				     IGRchar		*nodeName,
				     struct GRid	*prsID,
				     struct GRid	*nodeID    )
{
IGRlong			sts;
TVDctxNodeList		nodeList;
struct GRid		xtreeID, prsUnitID;
FILE			*fp=NULL;

    fp = fopen( xmlFile, "r" );

    if( fp == NULL )
    {
       VDctxCreateXdomTree( SMS_PRS, NULL, prsID );
       VDctxCreateNode( prsID, SMS_PRS_UNIT, NULL, &prsUnitID );
       VDctxCreateNode( &prsUnitID, nodeName, NULL, nodeID );
       return 1;
    }
    fclose( fp );

    VDxdomCreateTreeFromXmlFile( xmlFile, &xtreeID );
    if( xtreeID.objid == NULL_OBJID )  return MSFAIL;

    VDctxInitNodeList( &nodeList );

    VDctxGetNodeListByType( &xtreeID, nodeName, &nodeList );
    if( nodeList.cnt != 0 ) 
    {
       *nodeID = nodeList.listIDs[0];

       VDctxFreeNodeList( &nodeList );
       VDctxGetNodeListByType( &xtreeID, SMS_PRS, &nodeList );
       
       *prsID = nodeList.listIDs[0];
    }

    VDctxFreeNodeList( &nodeList );

    VDctxGetNodeListByType( &xtreeID, SMS_PRS_UNIT, &nodeList );
    if( nodeList.cnt != 0 ) 
    {
       prsUnitID = nodeList.listIDs[0];

       VDctxFreeNodeList( &nodeList );
       VDctxGetNodeListByType( &xtreeID, SMS_PRS, &nodeList );

       *prsID = nodeList.listIDs[0];
    }
    else
    {
       VDctxCreateXdomTree( SMS_PRS, NULL, prsID );
       VDctxCreateNode( prsID, SMS_PRS_UNIT, NULL, &prsUnitID );
    }

    VDctxCreateNode( &prsUnitID, nodeName, NULL, nodeID );

wrapup:
    VDctxFreeNodeList( &nodeList );
    return sts;
}

IGRlong VLreportLoftObjectsToXml( IGRlong             *msg,
                                  IGRint              type,
                                  IGRint              macroCnt,
                                  struct GRobj_env    *macroOE,
				  IGRchar	      **buffer,
                                  IGRchar             *fileName )
{
IGRlong			sts;
IGRint			i, objCnt=0;
IGRchar			macName[100];
struct GRobj_env	*objOE=NULL;

   if( !( objOE = _MALLOC( macroCnt, struct GRobj_env )) ) vd_$mem_fail();

   switch( type )
   {
	case ALL_LOFT:

       	case STEEL_BAND:
	    objCnt = 0;
	    for( i=0; i<macroCnt; ++i )
	    {
	       vdobj$Get( objOE = &macroOE[i], macName = macName );
	       if( !strcmp( macName, "steel_band" ) )
	       {
		  objOE[objCnt] = macroOE[i];
		  objCnt++;
	       }
	    }

            if( objCnt )
            {
               VLreportSteelBandsToXml( msg, objCnt, objOE, buffer, fileName );
            }
	    if( type != ALL_LOFT ) break;	

	case BENDING_LINE:
	    objCnt = 0;
            for( i=0; i<macroCnt; ++i )
            {
               vdobj$Get( objOE = &macroOE[i], macName = macName );
               if( !strcmp( macName, "stifBend" ) )
               {
                  objOE[objCnt] = macroOE[i];
                  objCnt++;
               }
            }

            if( objCnt )
            {
               VLreportBendingLinesToXml( msg, objCnt, objOE, buffer, fileName );
            }
	    if( type != ALL_LOFT ) break;

	case BALANCEMENT:
	    objCnt = 0;
            for( i=0; i<macroCnt; ++i )
            {
               vdobj$Get( objOE = &macroOE[i], macName = macName );
               if( !strcmp( macName, "balance" ) )
               {
                  objOE[objCnt] = macroOE[i];
                  objCnt++;
               }
            }

            if( objCnt )
            {
               VLreportBalancementToXml( msg, objCnt, objOE, buffer, fileName );
            }
            if( type != ALL_LOFT ) break;

	case PIN_JIG:
	    objCnt = 0;
            for( i=0; i<macroCnt; ++i )
            {
               vdobj$Get( objOE = &macroOE[i], macName = macName );
               if( !strcmp( macName, "pinjig" ) )
               {
                  objOE[objCnt] = macroOE[i];
                  objCnt++;
               }
            }

            if( objCnt )
            {
               VLreportPinJigsToXml( msg, objCnt, objOE, buffer, fileName );
            }
            if( type != ALL_LOFT )  break;

	case TEMPLATE:
	    objCnt = 0;
            for( i=0; i<macroCnt; ++i )
            {
               vdobj$Get( objOE = &macroOE[i], macName = macName );
               if( !strcmp( macName, "template_mgr" ) )
               {
                  objOE[objCnt] = macroOE[i];
                  objCnt++;
               }
            }

            if( objCnt )
            {
               VLreportTemplatesToXml( msg, objCnt, objOE, buffer, fileName );
            }
            if( type != ALL_LOFT ) break;

	case KEY_LINE:
	    objCnt = 0;
            for( i=0; i<macroCnt; ++i )
            {
               vdobj$Get( objOE = &macroOE[i], macName = macName );
               if( !strcmp( macName, "plate_key" ) )
               {
                  objOE[objCnt] = macroOE[i];
                  objCnt++;
               }
            }

            if( objCnt )
            {
               VLreportKeyLinesToXml( msg, objCnt, objOE, buffer, fileName );
            }
            if( type != ALL_LOFT ) break;
   }

wrapup:
   _FREE( objOE );
   return sts;
}

IGRlong VLgetTextStringFromObj( IGRlong			*msg,
				struct GRid		*macroID,
				IGRchar			*feetName,
				IGRchar			*textStr  )
{
IGRlong			sts;
IGRshort		text_length=0;
IGRchar			*text_string=NULL;
struct GRid		footID;

   *textStr = '\0' ;

   sts = vl$return_foot( msg    = msg,
                         name   = feetName,
                         objId  = macroID,
                         footId = &footID  );
   __CheckRC( sts, *msg, "vl$return_foot", wrapup );

   sts = om$send( msg = message GRtext.GRgettxattr
                       ( msg, NULL, &text_length, (IGRuchar **) &text_string ),
                  senderid = NULL_OBJID,
                  targetid = footID.objid,
                  targetos = footID.osnum );
   __CheckRC( sts, *msg, "GRtext.GRgettxattr", wrapup );

   /* Remove escape sequences */
   co$rm_esc_seqs( msg         = msg,
                   font_num    = (IGRshort)0,
                   font_flags  = (IGRint)0,
                   text_string = text_string,
                   text_length = &text_length );
   __CheckRC( sts, *msg, "co$rm_esc_seqs", wrapup );
   text_string[text_length] = '\0' ;

   strcpy( textStr, text_string );

wrapup:
   _FREE( text_string );
   return sts;
}

IGRlong VLreportSteelBandsToXml(  IGRlong               *msg,
				  IGRint		nbBand,
				  struct GRobj_env	*bandList,
				  IGRchar		**buffer,
				  IGRchar		*fileName )
{
IGRlong			sts;
IGRint			i, j, num_pl;
IGRchar			timeStamp[32];
VLsteelBandInfo		sbInfo;
VLsteelBandData 	*ptData=NULL;
struct GRid		sbGroupID, sbID, sbInfoID, sbDataID, prsID,
			structID, plateDomID;
struct GRobj_env	goOE, neatContOE, plateOE;

   sts = *msg = MSSUCC;

   VLgetDomNodeFromXml( fileName, SMS_STEELBANDS, &prsID, &sbGroupID );

   VDsysGetTimeStamp( timeStamp );

   for( i=0; i<nbBand; ++i )
   {
       VDctxCreateNode( &sbGroupID, SMS_STEELBAND, NULL, &sbID );

       VDctxCreateNode( &sbID, SMS_STRUCT_INFO, NULL, &structID );

       vdobj$GetTemplate( objOE = &bandList[i], nth = 0, 
		          templateOE = &goOE );
       ASget_as_owner( &goOE, &neatContOE );

       vdchn$GetList( objID   = &neatContOE.obj_id,
                      chnName = VDCHN_NAME_PARENT,
		      maxCnt  = 31,
                      cnt     = &num_pl );
       for( j=1; j<num_pl; ++j )
       {
           vdobj$GetTemplate( objID      = &neatContOE.obj_id,
                              nth        = j,
                              templateOE = &plateOE );

	   VDvalConvertPieceToDom( &plateOE, &structID, &plateDomID, NULL, VDVAL_DOM_WANT_MIN );
       }

       _FREE( ptData );
       sts = VLfillSteelBand( &bandList[i], &sbInfo, &ptData, msg );
       __CheckRC( sts, *msg, "VLfillSteelBand", wrapup );

       VDctxAppTxtAtr( &sbID, JOB_NUMBER, sbInfo.jobN );
       VDctxAppTxtAtr( &sbID, JOB_DESC, sbInfo.desc );
       VDctxAppTxtAtr( &sbID, XML_TIME, timeStamp );

       VDctxCreateNode( &sbID, SMS_STEELBAND_INFO, NULL, &sbInfoID );

       VDctxAppTxtAtr( &sbInfoID, BAND_NUMB, sbInfo.band );
       VDctxAppDblAtr( &sbInfoID, START_STOCK, sbInfo.stock );
       VDctxAppDblAtr( &sbInfoID, END_STOCK, sbInfo.endstock );

       for( j=0; j<sbInfo.numP; ++j )
       {
	  VDctxCreateNode( &sbInfoID, SMS_STEELBAND_DATA, NULL, &sbDataID );
	  VDctxAppIntAtr( &sbDataID, XML_INDEX, j+1 );
	  VDctxAppTxtAtr( &sbDataID, XML_NAME, ptData[j].nam  );
	  VDctxAppDblAtr( &sbDataID, XML_DISTANCE, ptData[j].dst );
       }
   }

   if( buffer )
   {
	VDctxSaveTreeToXmlBuf( &prsID, buffer );
   }
   else
   {
        VDctxSaveTreeToXmlFile( &prsID, fileName );
   }

wrapup:
   _FREE( ptData );
   return sts;
}

IGRlong VLreportBendingLinesToXml( IGRlong		*msg,
				   IGRint               nbBend,
                                   struct GRobj_env     *bendList,
				   IGRchar              **buffer,
				   IGRchar		*fileName  )
{
IGRlong			sts;
IGRint			i, j, k, nbCrv, nbHeights;
IGRchar			name[100], word[25], *ptr, *next_ptr, path[DI_PATH_MAX];
IGRdouble		step, *valHeights=NULL;
GRspacenum		cur_os;
struct ACrg_coll	attr;
struct GRid		iblGroupID, iblID, lineID, stepID, loftGlobalID, prsID,
			structID, stifDomID;
struct GRobj_env	stifOE, *crvList=NULL;

   sts = *msg = MSSUCC;

   ex$get_cur_mod ( osnum = &cur_os );
   di$give_pathname( osnum    = cur_os,
                     pathname = path    );
   sprintf ( path, "%s:IGENOD:%s", path, GLOBAL_G_NAME );

   loftGlobalID.objid = NULL_OBJID;
   loftGlobalID.osnum = cur_os;
   sts = di$translate( objname = path,
                       p_objid = &loftGlobalID.objid,
                       p_osnum = &loftGlobalID.osnum  );
   if( sts != DIR_S_SUCCESS )  goto wrapup;

   strcpy( attr.name, NAM_G_BEND_STEP );
   sts = om$send( msg = message ACrg_collect.ACget_named_attribute
                                        ( msg, &attr ),
		  senderid = NULL_OBJID,
                  targetid = loftGlobalID.objid,
                  targetos = loftGlobalID.osnum );
   __CheckRC( sts, *msg, "ACrg_collect.ACget_named_attribute", wrapup );
   step = attr.desc.value.att_exp;

   VLgetDomNodeFromXml( fileName, SMS_BENDLINES, &prsID, &iblGroupID );

   for( i=0; i<nbBend; ++i )
   {
       VDctxCreateNode( &iblGroupID, SMS_BENDLINE, NULL, &iblID );

       VDctxCreateNode( &iblID, SMS_STRUCT_INFO, NULL, &structID );

       vdobj$GetTemplate( objID      = &bendList[i].obj_id,
                          nth        = 1,
                          templateOE = &stifOE );

       VDvalConvertPieceToDom( &stifOE, &structID, &stifDomID, NULL, VDVAL_DOM_WANT_MIN  );

       sts = VLgetTextStringFromObj( msg, &bendList[i].obj_id, 
				     NAM_SBF_NAME, name );
       __CheckRC( sts, *msg, "VLgetTextStringFromObj", wrapup );       

       ptr = name;
       if( VDSGetNextWord( ptr, word, 25, ' ',  &next_ptr ) == 0) continue;
       VDctxAppTxtAtr( &iblID, STIF_NAME, word );

       strcpy( name, next_ptr );
       ptr = name;
       if( VDSGetNextWord( ptr, word, 25, '\t',  &next_ptr ) == 0) continue;
       strcpy( name, word );

       ptr = name;
       if( VDSGetNextWord( ptr, word, 25, ' ',  &next_ptr ) == 0) continue;
       VDctxAppTxtAtr( &iblID, WEB_SIDE, word );

       strcpy( name, next_ptr );
       ptr = name;
       if( VDSGetNextWord( ptr, word, 25, '\t',  &next_ptr ) == 0) continue;
       VDctxAppTxtAtr( &iblID, FIB_RATIO, word );

       sts = VLextractBendedLines( &bendList[i], &nbCrv, &crvList, msg);
       __CheckRC( sts, *msg, "VLextractBendedLines", wrapup );

       for( j=0; j<nbCrv; ++j )
       {
	  nbHeights = 0;
	  _FREE( valHeights );
	  VDctxCreateNode( &iblID, SMS_CRV_INFO, NULL, &lineID );
	  VDctxAppIntAtr( &lineID, XML_INDEX, j+1 );
	  sts = VLcomputeBendLineHeights( &crvList[j], &bendList[i], step,
					  &nbHeights, &valHeights, msg );
	  __CheckRC( sts, *msg, "VLcomputeBendLineHeights", wrapup );

	  for( k=0; k<nbHeights; ++k )
	  {
	     VDctxCreateNode( &lineID, SMS_STEP_INFO, NULL, &stepID );
	     VDctxAppDblAtr( &stepID, STEP_VALUE, valHeights[2*k] );
	     VDctxAppDblAtr( &stepID, BEND_HEIGHT, valHeights[2*k+1] );
	  }
       }
   }

   if( buffer )
   {
        VDctxSaveTreeToXmlBuf( &prsID, buffer );
   }
   else 
   {
        VDctxSaveTreeToXmlFile( &prsID, fileName );
   }

wrapup:
   _FREE( crvList );
   _FREE( valHeights );
   return sts;
}

IGRlong VLreportBalancementToXml( IGRlong              *msg,
                                  IGRint               nbBal,
                                  struct GRobj_env     *balList,
				  IGRchar              **buffer,
                                  IGRchar              *fileName  )
{
IGRlong			sts;
IGRint			i, j, nbTemp;
VLbalBasePts		baseInfo;
struct VLsortTpl	*balInfo=NULL;
struct GRid		balGroupID, balID, cornerID, positionID, prsID,
			structID, plateDomID;
struct GRobj_env	plateOE;

   sts = *msg = MSSUCC;

   sts = VLfillBalanceData( nbBal, balList, &balInfo, msg );
   __CheckRC( sts, *msg, "VLfillBalanceData", wrapup );

   VLgetDomNodeFromXml( fileName, SMS_BALANCEMENTS, &prsID, &balGroupID );

   for( i=0; i<nbBal; ++i )
   {
       	VDctxCreateNode( &balGroupID, SMS_BALANCEMENT, NULL, &balID );
	VDctxAppIntAtr( &balID, XML_INDEX, balInfo[i].idx );
 	VDctxAppTxtAtr( &balID, XML_NAME, balInfo[i].name );
	VDctxAppIntAtr( &balID, NUM_ELEM, balInfo[i].num  );
	VDctxAppDblAtr( &balID, X_ANGLE, balInfo[i].x );
	VDctxAppDblAtr( &balID, Y_ANGLE, balInfo[i].y );
	VDctxAppDblAtr( &balID, Z_ANGLE, balInfo[i].z );

	VDctxCreateNode( &balID, SMS_STRUCT_INFO, NULL, &structID );

        vdchn$GetList( objOE   = &balList[i],
                       chnName = VDCHN_NAME_PARENT,
                       maxCnt  = 100,
                       cnt     = &nbTemp );

        for( j=6; j<nbTemp; ++j )
        {
            vdobj$GetTemplate( objOE	  = &balList[i],
                               nth        = j,
                               templateOE = &plateOE );

            VDvalConvertPieceToDom( &plateOE, &structID, &plateDomID, NULL, VDVAL_DOM_WANT_MIN  );
        }

       	sts = VLbasePoints( msg, &balList[i], &baseInfo );
	__CheckRC( sts, *msg, "VLbasePoints", wrapup );	

	for( j=0; j<4; ++j )
	{
	   VDctxCreateNode( &balID, SMS_CORNER_INFO, NULL, &cornerID );
	   VDctxAppIntAtr( &cornerID, CORNER_INDEX, j+1 ); 

	   VDctxCreateNode( &cornerID, SMS_ON_GROUND, NULL, &positionID );
	   VDctxAppDblAtr( &positionID, ON_GROUND_X, baseInfo.corner[j].balance[0] );
	   VDctxAppDblAtr( &positionID, ON_GROUND_Y, baseInfo.corner[j].balance[1] );
	   VDctxAppDblAtr( &positionID, ON_GROUND_Z, baseInfo.corner[j].balance[2] );

           VDctxCreateNode( &cornerID, SMS_ON_GROUND, NULL, &positionID );
           VDctxAppDblAtr( &positionID, IN_SHIP_X, baseInfo.corner[j].in_ship[0] );
           VDctxAppDblAtr( &positionID, IN_SHIP_Y, baseInfo.corner[j].in_ship[1] );
           VDctxAppDblAtr( &positionID, IN_SHIP_Z, baseInfo.corner[j].in_ship[2] );
	}
   }

   if( buffer )
   {
        VDctxSaveTreeToXmlBuf( &prsID, buffer );
   }
   else 
   {
        VDctxSaveTreeToXmlFile( &prsID, fileName );
   }

wrapup:
   _FREE( balInfo );
   return sts;
}

IGRlong VLreportPinJigsToXml( IGRlong              *msg,
                              IGRint               nbPinJigs,
                              struct GRobj_env     *pinList,
			      IGRchar              **buffer,
                              IGRchar              *fileName  )
{
IGRlong                 sts;
IGRint                  i, j, nbPins, nbCrns, nbPanelCrn, nbTemp;
IGRpoint		H1V1position;
VLpinCorn		*cornerData=NULL, *panelCrnData=NULL;
struct ACrg_coll	*positionArray=NULL;
struct GRid		pinGroupID, coordID, pinJigID, pinID, cornersID, cornerID,
			panelsID, panelID, structID, plateDomID, prsID;
struct GRobj_env	layoutOE, balOE, plateOE;

   sts = *msg = MSSUCC;

   VLgetDomNodeFromXml( fileName, SMS_PINJIGS, &prsID, &pinGroupID );

   for( i=0; i<nbPinJigs; ++i )
   {
	VDctxCreateNode( &pinGroupID, SMS_PINJIG, NULL, &pinJigID );

	VDctxCreateNode( &pinJigID, SMS_STRUCT_INFO, NULL, &structID );

        vdobj$GetTemplate( objOE      = &pinList[i],
                           nth        = 0,
                           templateOE = &layoutOE );

	vdobj$GetTemplate( objOE      = &layoutOE,
                           nth        = 0,
                           templateOE = &balOE );

        vdchn$GetList( objOE   = &balOE,
                       chnName = VDCHN_NAME_PARENT,
                       maxCnt  = 100,
                       cnt     = &nbTemp );

        for( j=6; j<nbTemp; ++j )
        {
            vdobj$GetTemplate( objOE      = &balOE,
                               nth        = j,
                               templateOE = &plateOE );

            VDvalConvertPieceToDom( &plateOE, &structID, &plateDomID, NULL, VDVAL_DOM_WANT_MIN  );
        }

	nbPins = nbCrns = nbPanelCrn = 0 ;
	_FREE( cornerData );  _FREE( panelCrnData ); _FREE( positionArray );
        sts = VLfillPinjig1( &pinList[i], &nbPins, &nbCrns, &cornerData,
			     &nbPanelCrn, &panelCrnData, &positionArray,
			     H1V1position, msg );
	__CheckRC( sts, *msg, "VLfillPinjig1", wrapup );

	VDctxCreateNode( &pinJigID, SMS_PIN_DATA, NULL, &pinID );

	for( j=0; j<nbPins; ++j )
	{
	   sts = VLfillPinjig2( &pinList[i], j, H1V1position, positionArray, msg );
	   __CheckRC( sts, *msg, "VLfillPinjig2", wrapup );

	   VDctxCreateNode( &pinID, PIN_DATA, NULL, &coordID );
	   VDctxAppIntAtr( &coordID, COL_NO, 
			   (IGRint) positionArray[3+IDX_PB_COL].desc.value.att_exp );
	   VDctxAppIntAtr( &coordID, ROW_NO,
			   (IGRint) positionArray[3+IDX_PB_LIN].desc.value.att_exp );
	   VDctxAppDblAtr( &coordID, PIN_X_POS, 
			   positionArray[3+IDX_PB_XPT].desc.value.att_exp );
	   VDctxAppDblAtr( &coordID, PIN_Y_POS, 
                           positionArray[3+IDX_PB_YPT].desc.value.att_exp );
	   VDctxAppDblAtr( &coordID, PIN_Z_POS, 
                           positionArray[3+IDX_PB_ZPT].desc.value.att_exp );
	   VDctxAppDblAtr( &coordID, PIN_HEIGHT,
			   positionArray[3+IDX_PB_HEI].desc.value.att_exp );
           VDctxAppDblAtr( &coordID, PIN_ANGLE,
			   positionArray[3+IDX_PB_ANG].desc.value.att_exp );
	   VDctxAppTxtAtr( &coordID, XML_NAME,
			   positionArray[3+IDX_PB_NAM].desc.value.att_txt );
	}

	VDctxCreateNode( &pinJigID, SMS_CORNER_DATA, NULL, &cornersID );

	for( j=0; j<nbCrns; ++j )
        {
	   VDctxCreateNode( &cornersID, CORNER_DATA, NULL, &cornerID );
	   VDctxAppTxtAtr( &cornerID, XML_NAME, cornerData[j].cp  );
	   VDctxAppDblAtr( &cornerID, PIN_X_POS, cornerData[j].dx );
	   VDctxAppDblAtr( &cornerID, PIN_Y_POS, cornerData[j].dy ); 
	   VDctxAppDblAtr( &cornerID, PIN_Z_POS, cornerData[j].dz );
	   VDctxAppTxtAtr( &cornerID, REF_PIN_NAME, cornerData[j].pn );
	}

	VDctxCreateNode( &pinJigID, SMS_PANEL_CORNER_DATA, NULL, &panelsID );

        for( j=0; j<nbPanelCrn; ++j )
        {
           VDctxCreateNode( &panelsID, CORNER_DATA, NULL, &panelID );
           VDctxAppTxtAtr( &panelID, XML_NAME, panelCrnData[j].cp  );
           VDctxAppDblAtr( &panelID, PIN_X_POS, panelCrnData[j].dx );
           VDctxAppDblAtr( &panelID, PIN_Y_POS, panelCrnData[j].dy );
           VDctxAppDblAtr( &panelID, PIN_Z_POS, panelCrnData[j].dz );
           VDctxAppTxtAtr( &panelID, REF_PIN_NAME, panelCrnData[j].pn );
        }
   }

   if( buffer )
   {
        VDctxSaveTreeToXmlBuf( &prsID, buffer );
   }
   else 
   {
        VDctxSaveTreeToXmlFile( &prsID, fileName );
   }

wrapup:
   _FREE( cornerData );  _FREE( panelCrnData ); _FREE( positionArray );
   return sts;
}

IGRlong VLreportTemplatesToXml( IGRlong              *msg,
                                IGRint               nbTemplates,
                                struct GRobj_env     *tempList,
				IGRchar              **buffer,
                                IGRchar              *fileName  )
{
IGRlong                 sts;
IGRint                  i, j, k, ntpl=0, nbHeights=0, nobj=0;
IGRdouble		step, *valHeights=NULL;
IGRchar			path[DI_PATH_MAX];
GRspacenum		cur_os;
VLpltTpl		*Tpl=NULL, *Reg=NULL, *Spi=NULL;
struct ACrg_coll        attr;
struct GRid		loftGlobalID, tplGroupID, templateID, stepID, tplSetID,
			regTplsID, regTplID, chtID, spineID, plateDomID, structID,
			prsID, tplID;
struct GRobj_env	plateOE;

   sts = *msg = MSSUCC;

   ex$get_cur_mod ( osnum = &cur_os );
   di$give_pathname( osnum    = cur_os,
                     pathname = path    );
   sprintf ( path, "%s:IGENOD:%s", path, GLOBAL_G_NAME );

   loftGlobalID.objid = NULL_OBJID;
   loftGlobalID.osnum = cur_os;
   sts = di$translate( objname = path,
                       p_objid = &loftGlobalID.objid,
                       p_osnum = &loftGlobalID.osnum  );
   if( sts != DIR_S_SUCCESS )  goto wrapup;

   strcpy( attr.name, NAM_G_TEMP_STEP );
   sts = om$send( msg = message ACrg_collect.ACget_named_attribute
                                        ( msg, &attr ),
                  senderid = NULL_OBJID,
                  targetid = loftGlobalID.objid,
                  targetos = loftGlobalID.osnum );
   __CheckRC( sts, *msg, "ACrg_collect.ACget_named_attribute", wrapup );
   step = attr.desc.value.att_exp;

   VLgetDomNodeFromXml( fileName, SMS_TEMPLATES, &prsID, &tplGroupID );

   for( i=0; i<nbTemplates; ++i )
   {
	VDctxCreateNode( &tplGroupID, SMS_TEMPLATE, NULL, &tplID );

        VDctxCreateNode( &tplID, SMS_STRUCT_INFO, NULL, &structID );

        vdobj$GetTemplate( objID      = &tempList[i].obj_id,
                           nth        = 0,
                           templateOE = &plateOE );

        VDvalConvertPieceToDom( &plateOE, &structID, &plateDomID, NULL, VDVAL_DOM_WANT_MIN  );

	VDctxCreateNode( &tplID, SMS_REG_TEMP, NULL, &regTplsID );

	_FREE( Reg );   _FREE( Spi );
	sts = VLfillChtTemplateData( &tempList[i], &nobj, &Reg, &Spi, msg );
	__CheckRC( sts, *msg, "VLfillChtTemplateData", wrapup );

	VDctxAppIntAtr( &regTplsID, NUM_TEMP, nobj );

	for( j=0; j<nobj; ++j )
	{
	    VDctxCreateNode( &regTplsID, REG_INFO, NULL, &regTplID );
            VDctxAppTxtAtr( &regTplID, XML_NAME, Reg[j].nam );
            VDctxAppDblAtr( &regTplID, TEMP_HEIGHT, Reg[j].hei );
            VDctxAppDblAtr( &regTplID, TEMP_ANGLE, Reg[j].ang );
            VDctxAppTxtAtr( &regTplID, TEMP_LEAN_DIR, Reg[j].lea );
	}

	if( Spi )
	{
	   VDctxCreateNode( &tplID, SMS_SPI_TEMP, NULL, &spineID );
	   VDctxAppTxtAtr( &spineID, XML_NAME, Spi[0].nam );

	   for( j=0; j<nobj; ++j )
           {
	      VDctxCreateNode( &spineID, CHT_INFO, NULL, &chtID );
	      VDctxAppTxtAtr( &chtID, FRM_NAME, Spi[j].frm );
	      VDctxAppDblAtr( &chtID, CHT_HEIGHT, Spi[j].cht );
	   }
	}

	ntpl = 0;
	_FREE( Tpl );
	sts = VLfillHeiTemplateData1( &tempList[i], &ntpl, &Tpl, msg );
	__CheckRC( sts, *msg, "VLfillHeiTemplateData1", wrapup );

	VDctxCreateNode( &tplID, SMS_TEMPLATE_SET, NULL, &tplSetID );
	VDctxAppIntAtr( &tplSetID, NUM_TEMP, ntpl );

	for( j=0; j<ntpl; ++j )
	{
	    nbHeights = 0;
	    _FREE( valHeights );
	    sts = VLfillHeiTemplateData2( &tempList[i], step, &Tpl[j],
					  &nbHeights, &valHeights, msg );
	    __CheckRC( sts, *msg, "VLfillHeiTemplateData2", wrapup );

	    VDctxCreateNode( &tplSetID, SMS_TEMPLATE, NULL, &templateID );
	    VDctxAppIntAtr( &templateID, XML_INDEX, j );

            for( k=0; k<nbHeights; ++k )
            {
               VDctxCreateNode( &templateID, SMS_STEP_INFO, NULL, &stepID );
               VDctxAppDblAtr( &stepID, STEP_VALUE, valHeights[2*k] );
               VDctxAppDblAtr( &stepID, TEMP_HEIGHT, valHeights[2*k+1] );
            }
	}
   }

   if( buffer )
   {
        VDctxSaveTreeToXmlBuf( &prsID, buffer );
   }
   else 
   {
        VDctxSaveTreeToXmlFile( &prsID, fileName );
   }

wrapup:
   _FREE( Reg ); _FREE( Spi );
   _FREE( Tpl ); _FREE( valHeights );
   return sts;
}

IGRlong VLreportKeyLinesToXml( IGRlong               *msg,
                               IGRint                nbKey,
                               struct GRobj_env      *keyList,
			       IGRchar               **buffer,
                               IGRchar               *fileName )
{
IGRlong                 sts;
IGRint                  i, j, nbTemp;
IGRchar                 timeStamp[32];
VLkeyLineInfo   	klInfo;
VLkeyLineData   	*Tran=NULL, *Long=NULL, *Diag=NULL;
struct GRid             klGroupID, klID, klInfoID, klDataID, structID, 
			prsID, plateDomID;
struct GRobj_env	plateOE;

   sts = *msg = MSSUCC;

   VLgetDomNodeFromXml( fileName, SMS_KEYLINES, &prsID, &klGroupID );

   VDsysGetTimeStamp( timeStamp );

   for( i=0; i<nbKey; ++i )
   {
	VDctxCreateNode( &klGroupID, SMS_KEYLINE, NULL, &klID );

	VDctxCreateNode( &klID, SMS_STRUCT_INFO, NULL, &structID );

        vdchn$GetList( objOE   = &keyList[i],
                       chnName = VDCHN_NAME_PARENT,
                       maxCnt  = 100,
                       cnt     = &nbTemp );

        for( j=2; j<nbTemp; ++j )
        {
            vdobj$GetTemplate( objOE      = &keyList[i],
                               nth        = j,
                               templateOE = &plateOE );
            VDvalConvertPieceToDom( &plateOE, &structID, &plateDomID, NULL, VDVAL_DOM_WANT_MIN  );
        }

       _FREE( Tran ); _FREE( Long ); _FREE( Diag );
       sts = VLfillKeyLine( &keyList[i], &klInfo, &Tran, &Long, &Diag, msg );
       __CheckRC( sts, *msg, "VLfillKeyLine", wrapup );

       VDctxAppTxtAtr( &klID, JOB_NUMBER, klInfo.jobN );
       VDctxAppTxtAtr( &klID, XML_TIME, timeStamp );

       if( klInfo.numT > 0 )
       {
          VDctxCreateNode( &klID, SMS_TRANS_INFO, NULL, &klInfoID );
	  for( j=0; j<klInfo.numT; ++j )
	  {
	     VDctxCreateNode( &klInfoID, SMS_KEYLINE_DATA, NULL, &klDataID );
	     VDctxAppTxtAtr( &klDataID, MOLD_LINE_NAME, Tran[j].lin );
	     VDctxAppTxtAtr( &klDataID, LOCATION_NAME, Tran[j].nam );
	     VDctxAppDblAtr( &klDataID, XML_DISTANCE, Tran[j].dst );
	  }
       }

       if( klInfo.numL > 0 )
       {
          VDctxCreateNode( &klID, SMS_LONG_INFO, NULL, &klInfoID );
          for( j=0; j<klInfo.numL; ++j )
          {
             VDctxCreateNode( &klInfoID, SMS_KEYLINE_DATA, NULL, &klDataID );
             VDctxAppTxtAtr( &klDataID, MOLD_LINE_NAME, Long[j].lin );
             VDctxAppTxtAtr( &klDataID, LOCATION_NAME, Long[j].nam );
             VDctxAppDblAtr( &klDataID, XML_DISTANCE, Long[j].dst );
          }
       }

       if( klInfo.numD > 0 )
       {
          VDctxCreateNode( &klID, SMS_DIAG_INFO, NULL, &klInfoID );
          for( j=0; j<klInfo.numD; ++j )
          {
             VDctxCreateNode( &klInfoID, SMS_KEYLINE_DATA, NULL, &klDataID );
             VDctxAppTxtAtr( &klDataID, LOCATION_NAME, Diag[j].nam );
             VDctxAppDblAtr( &klDataID, XML_DISTANCE, Diag[j].dst );
          }
       }
   }

   if( buffer )
   {
        VDctxSaveTreeToXmlBuf( &prsID, buffer );
   }
   else 
   {
        VDctxSaveTreeToXmlFile( &prsID, fileName );
   }

wrapup:
   _FREE( Tran ); _FREE( Long ); _FREE( Diag );
   return sts;
}

end implementation VDSroot;
