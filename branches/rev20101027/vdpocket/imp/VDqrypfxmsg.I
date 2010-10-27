/* $Id: VDqrypfxmsg.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpocket/imp / VDqrypfxmsg.I
 *
 * Description:
 *   This file include the method used for manipulate item prefix 
 *
 *               function  VDgetQryObject
 *               method    VDgetPfxInfo
 *               method    VDsetPfxInfo
 *               method    VDdelPfxInfo
 *   Note: Prefix include two field: 
 *         pfxName : can not be all digits like "129", but "129A" is ok 
 *         pfxIndex: internal is double, input famat is an integer 
 * Revision History:
 *	$Log: VDqrypfxmsg.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
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
# Revision 1.7  1995/08/30  15:37:10  pinnacle
# Replaced: vdpocket/imp/VDqrypfxmsg.I for:  by yzhu for vds.240
#
# Revision 1.6  1995/07/20  15:23:52  pinnacle
# Replaced: vdpocket/imp/VDqrypfxmsg.I for:  by tlbriggs for vds.240
#
# Revision 1.5  1995/07/10  01:51:48  pinnacle
# Replaced: vdpocket/imp/VDqrypfxmsg.I for:  by yzhu for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      06/04/95 :      yzhu -          create
 *	07/18/95	tlb		modify VDgetPfxInfo
 * -------------------------------------------------------------------*/
class implementation VDquery ; 

#include "OMminimum.h"
#include "OMerrordef.h"                 /* OM_E_ABORT */
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"

#include "igewindef.h"
#include "igrdef.h"
#include "dp.h"
#include "lcdef.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "exdef.h"
#include "exmacros.h"

#include	"vdqrydef.h"
#include	"VDQYdef.h"
#include	"v_miscmacros.h"
#include	"v_dbgmacros.h"
#include	"VDmem.h"

#include	"AS_status.h"
#define         maxqry   300
/*+mi
-----------------------------------------------------------------------------
  Public  Function
        VDgetQryObject

  Abstract
        This method return the query object from query name

  Arguments
        IGRlong           O      *msg ;
        struct GRid       O      *obj;
        IGRchar           I      *qryName

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_ABORT      if unsuccess;
-----------------------------------------------------------------------------
-mi*/
IGRlong VDgetQryObject( IGRlong                 *msg,
                        struct GRid             *Obj,
                        IGRchar                 *qryName)
{
IGRlong                 status = OM_S_SUCCESS ;
IGRint                  directIndex = 0,
                        index,
                        rc;
GRspacenum              curOs;
GRname                  curDir,
                        pwdDir,
                        gvName,
                        objPwd;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;
struct  GRid            obj;

        SetProc( VDgetQryObject ); Begin 
        *msg = MSSUCC;
        /*
         * find the directory in which the query name match with input
         * query name
         */
        ex$get_cur_mod( osnum   = &curOs );
        obj.objid = NULL_OBJID;
        obj.osnum = curOs ;

        status =
        di$pwd( dirname = pwdDir );
        if( status != DIR_S_SUCCESS ){
                printf(" VDsetPfxInfo: di$pwd failed \n");
                goto wrapup;
        }

        status = di$give_pathname( osnum = curOs, pathname = curDir );
        as$status( action = RET_STATUS );

        status = di$cd( dirname = curDir );
        if( status != DIR_S_SUCCESS ){
                printf(" Can't go to directory: %s \n", curDir );
                goto wrapup;
        }
        strcat( curDir, ":" );
        strcat( curDir, QRY_str_DIR_NAME );

        /*
         * test if directory exists
         */
        status =
        di$translate(   objname = curDir,
                        p_objid = &obj.objid,
                        p_osnum = &obj.osnum );
        if( status != DIR_S_SUCCESS ){
                printf(" VDsetPfxInfo: nor query directory\n");
                goto wrapup;
        }

        /* 
         * find the object which include the input query name,
         * assume max query num = maxqry 
         */
        index = 0;
        while( index < maxqry){
                sprintf( objPwd, "%s:%s_%d", curDir, QRY_str_DIR_NAME, index );
#ifdef  DEBUG
        printf(" objPwd : %s\n", objPwd );
#endif
                obj.objid = NULL_OBJID;
                status =
                di$translate(   objname = objPwd,
                                p_objid = &obj.objid,
                                p_osnum = &obj.osnum );
                if( status == DIR_S_SUCCESS ){
                    /*  get query name.  */
                    strcpy( gvName, VD_qry_nmName );
                    status =
                    om$send(msg = message ACrg_collect.ACgive_structure(
                                                                &rc,
                                                                &directIndex,
                                                                gvName,
                                                                &retStr,
                                                                &mdEnv ),
            			senderid = NULL_OBJID,
                		targetid = obj.objid,
                		targetos = obj.osnum );

                    as$status( action = RET_STATUS );

                    if ( !strcmp(qryName, retStr.var.text_st.text_string)){
                       (*Obj) = obj;
                       break;
                    }
                }
                index++;
                status = OM_E_ABORT;
        }  /* where */
wrapup:
      End
      return status;
} /* VDgetQryObj */
/*+mi
-----------------------------------------------------------------------------
  Private Message
        VDgetPfxInfo

  Abstract
        This method return the item prefix information, based on the requested
        pointers of the arguments. This interface is only usefull for the
        two predefined attributes pfx_index and pfx_nmae.

  Arguments
        IGRlong           O      *msg ;
        IGRchar           O      *PfxIndex ;	if NULL - ignore 
        IGRchar           O      *PfxName ;	if NULL - ignore , 
					user allocated buffer of size ATTR_NAME


  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_ABORT      if unsuccess;
-----------------------------------------------------------------------------
-mi*/
method  VDgetPfxInfo(   IGRlong                 *msg;
                        IGRint                  *PfxIndex;
                        IGRchar                 *PfxName)
{
IGRlong                 status = OM_S_SUCCESS ;
IGRchar                 name[DI_PATH_MAX];
IGRint                  directIndex = 0,
                        rc;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;


 	SetProc( VDgetPfxInfo ); Begin        

        *msg = MSSUCC;

        if( PfxName ){
           	/*
            	 * get the prefix name.
                 */
                strcpy( name, VD_qry_nmPfxName );
                status =
                om$send(msg = message ACrg_collect.ACgive_structure(
                                                                &rc,
                                                                &directIndex,
                                                                name,
                                                                &retStr,
                                                                &mdEnv ),
                	mode     = OM_e_wrt_message,
                	targetid = my_id );
                as$status( action = RET_STATUS );
                if(!(status&1*rc)) {
                   status = OM_E_ABORT;
                   goto wrapup;
                }
                if ( retStr.type == text_type) {
                   strcpy( PfxName, retStr.var.text_st.text_string );      
                }       
                else{
                   status = OM_E_ABORT;
                   goto wrapup;
                }  
        }
        if( PfxIndex ){
                /*
                 * get the prefix index.
                 */
                strcpy( name, VD_qry_nmPfxIndex );
                status =
                om$send(msg = message ACrg_collect.ACgive_structure(
                                                                &rc,
                                                                &directIndex,
                                                                name,
                                                                &retStr,
                                                                &mdEnv),
                        mode     = OM_e_wrt_message,
                        targetid = my_id );
                as$status( action = RET_STATUS );
                if(!(status&1*rc)) {
                   status = OM_E_ABORT;
                   goto wrapup;
                }

                if ( retStr.type == double_type) {
                   *PfxIndex =(int)retStr.var.root_pm_st.value; 
                }
                else{
                   status = OM_E_ABORT;
                }
        }
wrapup:
        End
        return  status ;
}
/*+mi
-----------------------------------------------------------------------------
  Private Message
        VDsetPfxInfo

  Abstract
        This method set the item prefix information into query collector
  Arguments
        IGRlong                 O *msg ;
        IGRint                  I *PfxIndex ;
        IGRchar                 I *PfxName ;

  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_ABORT      if unsuccess;
-----------------------------------------------------------------------------
-mi*/
method  VDsetPfxInfo(   IGRlong                 *msg;
                        IGRint                  *PfxIndex;
                        IGRchar                 *PfxName)
{
IGRlong                 status = OM_S_SUCCESS ;
IGRchar                 name[DI_PATH_MAX];
IGRchar                 PfxIndexChar[DI_PATH_MAX];
IGRint                  directIndex = 0;
IGRint                  rc,len,i;
IGRint                  Nflag = FALSE;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;

        SetProc( VDsetPfxInfo ); Begin
        *msg = MSSUCC;

           if( PfxName ) {
                len = strlen(PfxName);
                for (i = 0; i< len; i++) {
                    if (!isdigit(PfxName[i])) Nflag = TRUE;
                }
                if( !Nflag ) {
                    status = OM_E_ABORT; 
                    goto wrapup;
                }
                strcpy( name, VD_qry_nmPfxName );
                status =
                om$send(msg = message ACrg_collect.ACgive_structure(
                                                              &rc,
                                                              &directIndex,
                                                              name,
                                                              &retStr,
                                                              &mdEnv ),
                        mode     = OM_e_wrt_message,
                        targetid = my_id );
                 if ( status&rc&1 ){
                   /*
                    * modify the "pfx_name" string of the query.
                    * ACmod_attribute maintain previous type: if used
                    * double type, you cna not change it to text type.
                    * So best way is to remove it , then create it.
                    */
                   status =
                   om$send(msg = message VDquery.ACrem_attribute(  msg,
                                                                name),
                   mode     = OM_e_wrt_message,
                   targetid = my_id );
                   as$status( action = RET_STATUS );
                   if(!(status&*msg&1)) {
                        status = OM_E_ABORT;
                        goto wrapup;
                   } 
                         
                   status =
                   om$send(msg = message VDquery.ACadd_attribute(  msg,
                                                                name,
                                                                PfxName ),
                   mode     = OM_e_wrt_message,
                   targetid = my_id );
                   as$status( action = RET_STATUS );
                   if(!(status&*msg&1)) {
                        status = OM_E_ABORT;
                        goto wrapup;
                   }
                 }
                 else {
                   /*
                    * create the "pfx_name" string of the query.
                    */
                   status =
                   om$send(msg = message VDquery.ACadd_attribute(  msg,
                                                                name,
                                                                PfxName ),
                   mode     = OM_e_wrt_message,
                   targetid = my_id );
                   as$status( action = RET_STATUS );
                   if(!(status&*msg&1)) {
                        status = OM_E_ABORT;
                        goto wrapup;
                   }
                 }
           } /* if( PfxName ) */ 
           if( PfxIndex) {
                /* PfxIndex must be integer, so it is checked automatically */ 
                strcpy( name, VD_qry_nmPfxIndex );
                sprintf( PfxIndexChar, "%d", *PfxIndex);
                status =
                om$send(msg = message ACrg_collect.ACgive_structure(
                                                              &rc,
                                                              &directIndex,
                                                              name,
                                                              &retStr,
                                                              &mdEnv ),
                        mode     = OM_e_wrt_message,
                        targetid = my_id );
                 if ( status&rc&1 ){
                   /*
                    * modify the "pfx_Index" string of the query.
                    */
                   status =
                   om$send(msg = message VDquery.ACrem_attribute(  msg,
                                                                name),
                   mode     = OM_e_wrt_message,
                   targetid = my_id );
                   as$status( action = RET_STATUS );

                   status =
                   om$send(msg = message VDquery.ACadd_attribute(  msg,
                                                                   name,
                                                                 PfxIndexChar ),
                   mode     = OM_e_wrt_message,
                   targetid = my_id );
                   as$status( action = RET_STATUS );
                 }
                 else {
                   /*
                    * create the "pfx_index" string of the query.
                    */
                   status =
                   om$send(msg = message VDquery.ACadd_attribute(  msg,
                                                                   name,
                                                                 PfxIndexChar ),
                   mode     = OM_e_wrt_message,
                   targetid = my_id );
                   as$status( action = RET_STATUS );
                 }
           } /* if( PfxIndex) */
wrapup:
        End
        return  status ;
}
/*+mi
-----------------------------------------------------------------------------
  Private Message
        VDdelPfxInfo
  Abstract
        This method delete the item prefix information in query collector
  Arguments
        IGRlong                 O *msg ;

  Status/Return Code
      status == OM_S_SUCCESS    if success;
-----------------------------------------------------------------------------
-MI*/
method  VDdelPfxInfo(   IGRlong                 *msg)
{
IGRlong                 status = OM_S_SUCCESS ;
GRname                  name;

        SetProc( VDdelPfxInfo ); Begin

        *msg = MSSUCC;
                /*
                 * remove "pfx_name" string of the query.
                 */
                strcpy( name, VD_qry_nmPfxName );
                status =
                om$send(msg = message VDquery.ACrem_attribute(  msg,
                                                                name),
                mode     = OM_e_wrt_message,
                targetid = my_id );
                as$status( action = RET_STATUS );

                /*
                 * removey the "pfx_Index" string of the query.
                 */

                strcpy( name, VD_qry_nmPfxIndex );
                status =
                om$send(msg = message VDquery.ACrem_attribute(  msg,
                                                                name),
                mode     = OM_e_wrt_message,
                targetid = my_id );
                as$status( action = RET_STATUS );

        End
        return status ;
} /* VDdelPfxInfo */

end implementation VDquery;

