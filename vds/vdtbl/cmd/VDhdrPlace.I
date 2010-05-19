/* $Id: VDhdrPlace.I,v 1.20 2001/10/02 21:12:32 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDhdrPlace.I
 *
 * Description:
 *	Implementation of the following method for VDCmdPlHdr :
 *		placeTblHdr
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem        Creation
 *      07/21/95        R. Manem        Set table type in VDdrwTbl
 *      09/01/00	Ming		CR179901748
 *	04/19/01	ylong		CR5006 and CR5065
 * -------------------------------------------------------------------*/

class implementation VDCmdPlHdr;

/* 
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exmacros.h"

#include "macro.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grdpbmacros.h"
#include "ACattrib.h"
#include "asmacros.h"
#include "asbox.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"

#include "VDCmdDef.h"
#include "FI.h"
#include "FEI.h"
#include "VDtblCmdDef.h"
#include "vdtr_macros.h"

extern IGRint		getNewName();

extern GRclassid	OPP_VDdrwTbl_class_id,
			OPP_VDdrwTblHdr_class_id;

extern ASmake_source_from_env();
extern IGRlong VDtblCmdGetIndexTableType();
extern IGRlong VDdrw_placeStageTable();

from GRgraphics		import	GRchgname;

from VDdrwTbl		import	VDinitTbl,
				VDaddHeaders,
				VDputTableType,
				VDputAdsTblName,
				VDputTableLayoutName;

from VDdrwTblHdr	import	VDinitTblHdr,
				VDputTableInfo,
				VDputConstructInfo,
				VDputCsLocation,
				VDsetMatrixFromCS,
				VDcreate,
				VDconstructHdrTrl;
from	NDmacro	import		ACreturn_foot;

/*+me
 ---------------------------------------------------------------------------
  Public Message placeTblHdr

  Abstract
        This method generates the table header

  Arguments
        IGRlong         *sts            O       Return code

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS
 ---------------------------------------------------------------------------
-me*/

method  placeTblHdr ( long * sts )
{
    IGRint		partNo = 1;
    IGRshort		prop,
			hdrType = VD_DRWLO_EN_HEADER,
			trlType = VD_DRWLO_EN_TRAILER,
			cnstType = VD_DRW_CNST_HDR;
    IGRlong		status = OM_S_SUCCESS,
			msg;
    IGRchar		*ptr = NULL,
			dirName[DI_PATH_MAX],
			occName[DI_PATH_MAX],
			pwdName[DI_PATH_MAX];
    OMuword		os;
    struct GRid		tblId,
			hdrId,
			root,
			roots[2],
			dirObj,
			modObj;
    struct VDdrwlo_tab	tblRec;
    struct GRmd_env     mod_env,
			modEnv;
    struct ACrg_coll	*Attr;
    IGRint		nbAttr;
    IGRint              displayed = 0;
    IGRchar 		nodeType[128],
			nodePath[128],
			indexType[64],
			adsTblName[80];
    IGRint		size = sizeof( struct GRmd_env );
    IGRint		i, cnt;
    struct VDtblStImInfo tblInfo;

   

    SetProc( VDCmdPlHdr.placeTblHdr ); Begin

    *sts = VD_SUCCESS;
    pwdName[0] ='\0';
    occName[0] ='\0';
    Attr = NULL;

    tblInfo.importFile[0]	= '\0';
    tblInfo.styleSheet[0]	= '\0';
    tblInfo.separator[0]	= '\0';
    tblInfo.itemNoOpt		= 0;
    tblInfo.startItemNo		= 1;
    tblInfo.adsTblName[0]	= '\0';
    tblInfo.mapInfo.rows        = 0;
    tblInfo.mapInfo.type[0]     = '\0'; 

    /* get current osnum */
    ex$get_cur_mod( osnum = &os );

    /* get current directory */
    status = di$pwd( dirname = pwdName );
    if( status != DIR_S_SUCCESS ){
	printf(" Can't get current directory name \n");
	goto wrapup;
    }

    __DBGpr_int( "Current osnum", os );

    /* get table record */

    status = VD_drwlo_gtab( &msg, me->tblLayoutName, &tblRec );
    __CheckRC( status, msg, "VD_drwlo_gtab", wrapup );

    /* construct the table object */

    tblId.osnum = os;
    tblId.objid = NULL_OBJID;
    status =
    om$construct(	classid	= OPP_VDdrwTbl_class_id,
			osnum	= tblId.osnum,
			p_objid	= &tblId.objid,
			msg	= message VDdrwTbl.VDinitTbl( &msg ) );
    __CheckRC( status, 1, "construct VDdrwTbl", wrapup );

    __DBGpr_obj( "Table id", tblId );

    if( tblId.objid == NULL_OBJID )
	goto wrapup;

    /* create directory ":<filename>:usr:drw_tables" if not present */
    status = di$split(	pathname	= me->tblName,
			dirname		= dirName );
    CheckRC( status, 1 );

    __DBGpr_str( "Directory name", dirName );

    status = di$translate(	objname	= dirName,
				osnum	= os,
				p_objid	= &dirObj.objid,
				p_osnum	= &dirObj.osnum );

    if( status != DIR_S_SUCCESS )
    {
	status = di$mkdir(	dirname	= dirName,
				osnum	= os,
				p_dirid	= &dirObj.objid,
				p_osnum	= &dirObj.osnum );
	CheckRC( status, 1 );
    }
 
    status = di$cd( dirname = dirName );
    if( status != DIR_S_SUCCESS ){
	printf(" Can't go to directory: %s \n", dirName );
	goto wrapup;
    }

    /* name it */
    ptr = strrchr( me->tblName , ':' );
    if( ! ptr ){
	ptr = me->tblLayoutName;
    }
    else{
	ptr++ ;
    }
    status = getNewName( ptr , dirName , occName );
    __DBGpr_str( "Table name ", me->tblName );
    __DBGpr_str( "Occc name ", occName );
    sprintf( dirName, "%d:%d", occName );

    status =
    _VD_SEND_OBJ( tblId, GRgraphics.GRchgname( &msg, &me->ModuleInfo, occName ) );
    CheckRC( status, msg );
 
    /* put table layout name */

    status =
    _VD_SEND_OBJ( tblId, VDdrwTbl.VDputTableLayoutName( &msg, 
							me->tblLayoutName ) );
    CheckRC( status, msg );

    /* put table type */

    status =
    _VD_SEND_OBJ( tblId, VDdrwTbl.VDputTableType( &msg, tblRec.Tabtyp ) );
    CheckRC( status, msg );

    /* construct the table header object */
    hdrId.osnum = os;
    hdrId.objid = NULL_OBJID;
 
    status =
    om$construct(	classid	= OPP_VDdrwTblHdr_class_id,
			osnum	= hdrId.osnum,
			p_objid	= &hdrId.objid,
			msg	= message VDdrwTblHdr.VDinitTblHdr( &msg ) );

    __CheckRC( status, 1, "construct VDdrwTbl", wrapup );

    __DBGpr_obj( "Table Header id", hdrId );

    if( hdrId.objid == NULL_OBJID )
	goto wrapup;

    /* put table info */
    status =
    _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDputTableInfo( 	&msg,
							me->tblLayoutName,
							&partNo,
							&tblRec.direct ) );
    __CheckRC( status, msg, "VDdrwTblHdr.VDputTableInfo", wrapup );

    /* put cs location */
    status =
    _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDputCsLocation( 	&msg,
							me->csLocation ) );
    __CheckRC( status, msg, "VDdrwTblHdr.VDputCsLocation", wrapup );

    /* put construct info : header, trailer, toConstruct types */

    status =
    _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDputConstructInfo(&msg,
							&hdrType,
							&trlType,
							&cnstType ) );
    __CheckRC( status, msg, "VDdrwTblHdr.VDputConstructInfo", wrapup );

    /* Modified by Ming for CR179901748 */
    if( me->mytype == VD_CMD_TBL_HDR )
    {

      /* create and initialize templates */
      ASmake_source_from_env(	&me->csId.obj_id,
				&me->csId.mod_env,
				&root, 0 );

      prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;

      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDcreate( &msg,
						 0,
 						 NULL, 
						 "VDdrwTblHdr",
						 prop,
						 1,
						 &root) );
      __CheckRC( status, msg, "VDdrwTblHdr.VDcreate", wrapup );
						
      /* construct the header */
      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDconstructHdrTrl( &msg ) );
      __CheckRC( status, msg, "VDdrwTblHdr.VDconstructHdrTrl", wrapup );

      /* update tMatrix */
      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDsetMatrixFromCS( &msg ) );
      __CheckRC( status, msg, "VDdrwTblHdr.VDsetMatrixFromCS", wrapup );

      /* add the header object to the table */
      status =
      _VD_SEND_OBJ( tblId, VDdrwTbl.VDaddHeaders( &msg,
						  1,
						  &hdrId ) );
      __CheckRC( status, msg, "VDdrwTbl.VDaddHeaders", wrapup );
    }
    else if( me->mytype == VD_CMD_STBL_PL )
    {
      /* get current module environment */

      status = gr$get_module_env( msg     = &msg,
                                  sizbuf  = &size,
                                  buffer  = &mod_env );
      __CheckRC( status, msg, "gr$get_module_env", wrapup );

      /* create and initialize templates */

      ASmake_source_from_env(	&me->csId.obj_id,
				&me->csId.mod_env,
				&(roots[0]), 0 );
     
      status =
      om$send( msg	= message NDmacro.ACreturn_foot( &msg,
                                                "",
                                                &modObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ),
               targetid = me->locObjs[0].obj_id.objid,
               targetos = me->locObjs[0].obj_id.osnum,
               senderid = NULL_OBJID );
      CheckRC( status, msg );

      if( !(status&msg&1) ) {
	modObj = me->locObjs[0].obj_id;
	modEnv = me->locObjs[0].mod_env;
      }
      __DBGpr_obj( "me->locObjs[0]", me->locObjs[0].obj_id );
      __DBGpr_obj( "modObj", modObj );

      status =
      as$make_source( go_grid         = modObj,
                      mod_env         = &modEnv,
                      as_grid         = &roots[1] );
      CheckRC( status, 1 );

      __DBGpr_obj( "Source id ", roots[1] );

      prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;

      /*
      ** set three attributes into table header
      */
      nbAttr = 3;
      Attr = _MALLOC( nbAttr, struct ACrg_coll );

      if( Attr )
      {
        strcpy( Attr[0].name, "node_path" );
        strcpy( Attr[1].name, "node_process" );
        strcpy( Attr[2].name, "node_index" );
        Attr[0].desc.type = AC_ATTRIB_TEXT;
        Attr[1].desc.type = AC_ATTRIB_TEXT;
        Attr[2].desc.type = AC_ATTRIB_TEXT;
	
	vdtr$GetNodePath(nodeID = &(me->locObjs[0].obj_id), path = nodePath);
        strcpy( Attr[0].desc.value.att_txt, nodePath );
        if( me->select_flag == VD_DRW_STBL_PLIST )
        {
          strcpy( Attr[1].desc.value.att_txt, "part_list" );
          strcpy( Attr[2].desc.value.att_txt, "unknown" );
        }
        else if( me->select_flag == VD_DRW_STBL_INDEX )
        {
	  strcpy( Attr[1].desc.value.att_txt, "index" );
	  status = VDtblCmdGetIndexTableType( indexType );
          if( !status ) goto wrapup;

          strcpy( Attr[2].desc.value.att_txt, indexType );
        }
        else if( me->select_flag == VD_DRW_STBL_MODEL )
        {
	  strcpy( Attr[1].desc.value.att_txt, "model_obj" );
          strcpy( Attr[2].desc.value.att_txt, "unknown" );
        }
	else if( me->select_flag == VD_DRW_STBL_ITEM )
	{
	  strcpy( Attr[1].desc.value.att_txt, "item" );
          strcpy( Attr[2].desc.value.att_txt, "unknown" );
	}
	
      }
      else
      {
	_FREE( Attr );
        Attr = NULL;
        nbAttr = 0;
      }

      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDcreate( &msg,
						 nbAttr,
 						 Attr, 
						 "VDdrwTblHdr",
						 prop,
						 2,
						 roots) );

      __CheckRC( status, msg, "VDdrwTblHdr.VDcreate", wrapup );
						
      /* construct the header */

      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDconstructHdrTrl( &msg ) );
      __CheckRC( status, msg, "VDdrwTblHdr.VDconstructHdrTrl", wrapup );

      /* update tMatrix */
      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDsetMatrixFromCS( &msg ) );
      __CheckRC( status, msg, "VDdrwTblHdr.VDsetMatrixFromCS", wrapup );

      /* add the header object to the table */

      status =
      _VD_SEND_OBJ( tblId, VDdrwTbl.VDaddHeaders( &msg,
						  1,
						  &hdrId ) );
      __CheckRC( status, msg, "VDdrwTbl.VDaddHeaders", wrapup );

      /* put ADS table name to table for CR5065, by ylong */

      /* get some info */
      {
      IGRchar	text[80];
      text[0] = '\0';
      FIg_get_text( VD_FP, VD_STBL_ADS_FLD, text );
      strcpy(tblInfo.adsTblName, text);

      FIg_get_state( VD_FP, VD_STBL_ITEM_TGL, &tblInfo.itemNoOpt );

      text[0] = '\0';
      FIg_get_text( VD_FP, VD_STBL_STARTNO_FLD, text );
      tblInfo.startItemNo = atoi(text);
      }

      if( tblInfo.adsTblName[0] != '\0' ) 
      {
         status =
         _VD_SEND_OBJ( tblId, VDdrwTbl.VDputAdsTblName(&msg, tblInfo.adsTblName));
      }

      /* place stage table */

      status = VDdrw_placeStageTable (	&msg,
					&tblId,
					&me->locObjs[0].obj_id,
					&mod_env,
					&tblInfo );
      __CheckRC( status, msg, "VDdrw_placeStageTable", wrapup );
    }
    else if( me->mytype == VD_CMD_ITBL_PL )
    {
      /* get  the mapInfo from the form */
      VDtblSaveMap( VD_FP,&tblInfo );

      /* get current module environment */

      status = gr$get_module_env( msg     = &msg,
                                  sizbuf  = &size,
                                  buffer  = &mod_env );
      __CheckRC( status, msg, "gr$get_module_env", wrapup );

      /* create and initialize templates */

      ASmake_source_from_env(   &me->csId.obj_id,
                                &me->csId.mod_env,
                                &(roots[0]), 0 );

      prop = AChdr_nodisplay | AChdr_noprotect | AChdr_nocompute;

      /*
      ** set attributes into table header
      */
      FIg_get_text( VD_FP, VD_ITBL_IMPORTF_FLD, tblInfo.importFile );
      FIg_get_text( VD_FP, VD_ITBL_SEPARATOR_FLD, tblInfo.separator );
      FIg_get_text( VD_FP, VD_ITBL_STYLE_FLD, tblInfo.styleSheet );
      FIg_is_displayed(VD_FP,VD_ITBL_STYLE_FLD,&displayed);
      
      if(displayed == 0) strcpy(tblInfo.styleSheet,"");
      nbAttr = 1 + ceil(((double)strlen(tblInfo.importFile))/(ATTR_TXT - 1));
      Attr = _MALLOC( nbAttr, struct ACrg_coll );

      if( Attr )
      {
	for( i = 0; i < (nbAttr - 1); i++ ) 
	{
          Attr[i].desc.type = AC_ATTRIB_TEXT;
	  cnt = i*(ATTR_TXT - 1);
	  strncpy (	Attr[i].desc.value.att_txt, 
			&tblInfo.importFile[cnt],  
			(ATTR_TXT - 1) );
	  sprintf(Attr[i].name, "file_name%d", i);
	}

        strcpy( Attr[0].name, "file_name" );
        strcpy( Attr[i].name, "separator" );
        Attr[i].desc.type = AC_ATTRIB_TEXT;
	strcpy( Attr[i].desc.value.att_txt, tblInfo.separator );
      }
      else
      {
        _FREE( Attr );
        Attr = NULL;
        nbAttr = 0;
      }

      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDcreate( &msg,
                                                 nbAttr,
                                                 Attr,
                                                 "VDdrwTblHdr",
                                                 prop,
                                                 1,
                                                 roots) );

      __CheckRC( status, msg, "VDdrwTblHdr.VDcreate", wrapup );

      /* construct the header */

      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDconstructHdrTrl( &msg ) );
      __CheckRC( status, msg, "VDdrwTblHdr.VDconstructHdrTrl", wrapup );

      /* update tMatrix */
      status =
      _VD_SEND_OBJ( hdrId, VDdrwTblHdr.VDsetMatrixFromCS( &msg ) );
      __CheckRC( status, msg, "VDdrwTblHdr.VDsetMatrixFromCS", wrapup );

      /* add the header object to the table */

      status =
      _VD_SEND_OBJ( tblId, VDdrwTbl.VDaddHeaders( &msg,
                                                  1,
                                                  &hdrId ) );
      __CheckRC( status, msg, "VDdrwTbl.VDaddHeaders", wrapup );
      status = VDdrw_placeImportTable (	&msg,
                                        &tblId,
                                        &mod_env,
					&tblInfo );
      __CheckRC( status, msg, "VDdrw_placeStageTable", wrapup );
    }

wrapup :

    _FREE(Attr);

    if( pwdName[0] != '\0' ){
	status = di$cd( dirname = pwdName );
	if( status != DIR_S_SUCCESS ){
		printf(" Can't change working directory to : %s\n", pwdName );
	}
    }
    End
    return OM_S_SUCCESS;
}

end implementation VDCmdPlHdr;
