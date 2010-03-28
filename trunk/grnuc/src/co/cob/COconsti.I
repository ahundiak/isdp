/* #######################    APOGEE COMPILED   ######################## */
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

class implementation COconst;



#include "codebug.h"

#include "igrmacros.h"
#include "grdpbmacros.h"








/*
 *  init method
 */
method init ( int type; char *string_ptr )

{
    IGRlong msg;
    IGRlong NumberOfBytes;
    IGRlong BytesReceived;
    IGRlong status;

#define NIL             0
#define ERR             1
#define INITIAL_STATE   2


    _m_debug_str( "COconst init method." );


    status = om$send(
                mode = OM_e_wrt_message,
                msg = message super_cmd.init( type, string_ptr ),
                targetid = my_id );
    /*
     *  get the default ActiveAngle data from the DPB
     */
    NumberOfBytes = sizeof( ME.COconst->ActiveAngle );
    gr$get_active_angle(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &ME.COconst->ActiveAngle,
            nret = &BytesReceived );
    _m_checkp( msg, "COconst.init - gr$get_active_angle_radians." );
    _m_checkq( msg );


    /*
     *  get the default display symbology data from the DPB
     */
    NumberOfBytes = sizeof( ME.COconst->ActiveDisplay );
    gr$get_active_display(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &ME.COconst->ActiveDisplay,
            nret = &BytesReceived );
    _m_checkp( msg, "COconst.init - gr$get_active_display." );
    _m_checkq( msg );


    /*
     *  get the default level from the DPB
     */
    NumberOfBytes = sizeof( ME.COconst->ActiveLevel );
    gr$get_active_level(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &ME.COconst->ActiveLevel,
            nret = &BytesReceived );
    _m_checkp( msg, "COconst.init - gr$get_active_level." );
    _m_checkq( msg );


    /*
     *  get the data set env stuff from the DPB
     */
    NumberOfBytes = sizeof( ME.COroot->ModuleInfo );
    gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &ME.COroot->ModuleInfo,
                nret = &BytesReceived );
    _m_checkp( msg, "COconst.init - gr$get_module_env." );
    _m_checkq( msg );



    /*
     *  get the default database type from the DPB
     */
    NumberOfBytes = MAX_DB_TYPE_SIZE;
    gr$get_database_type(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = ME.COconst->DatabaseType,
                nret = &BytesReceived );
    _m_checkp( msg, "COconst.init - gr$get_database_type." );
    _m_checkq( msg );


    /*
     *  set the state to be 0.  this should work for MOST command objects
     *  the action is set to 2.  by common consent, NIL and ERR actions
     *  are NIL = 0, and ERR = 1.
     */
    ME.super_cmd->state = NIL;
    ME.COconst->action = INITIAL_STATE;

quit:

    _m_check( msg, return ( OM_E_ERROR ); );

    return ( OM_S_SUCCESS );
}



/*
 *  COconst sleep method
 */
method sleep ( int pos )

{
    _m_debug_str( "COconst sleep method." );


    UI_prompt( "" );
    UI_message( "" );

    return ( OM_S_SUCCESS );
}



/*
 *  COconst wakeup method
 */
method wakeup ( int pos )

{
    IGRlong msg;
    IGRlong NumberOfBytes;
    IGRlong BytesReceived;
    IGRlong status;

    _m_debug_str( "COconst wakeup method." );

    status = om$send(
                mode = OM_e_wrt_message,
                msg = message super_cmd.wakeup( pos ),
                targetid = my_id );

    /*
     *  get the default ActiveAngle data from the DPB
     */
    NumberOfBytes = sizeof( ME.COconst->ActiveAngle );
    gr$get_active_angle(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &ME.COconst->ActiveAngle,
            nret = &BytesReceived );
    _m_checkp( msg, "COconst.wakeup - gr$get_active_angle_radians." );
    _m_checkq( msg );


    /*
     *  get the default display symbology data from the DPB
     */
    NumberOfBytes = sizeof( ME.COconst->ActiveDisplay );
    gr$get_active_display(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &ME.COconst->ActiveDisplay,
            nret = &BytesReceived );
    _m_checkp( msg, "COconst.wakeup - gr$get_active_display." );
    _m_checkq( msg );


    /*
     *  get the default level from the DPB
     */
    NumberOfBytes = sizeof( ME.COconst->ActiveLevel );
    gr$get_active_level(
            msg = &msg,
            sizbuf = &NumberOfBytes,
            buffer = &ME.COconst->ActiveLevel,
            nret = &BytesReceived );
    _m_checkp( msg, "COconst.wakeup - gr$get_active_level." );
    _m_checkq( msg );


    /*
     *  get the data set env stuff from the DPB
     */
    NumberOfBytes = sizeof( ME.COroot->ModuleInfo );
    gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &ME.COroot->ModuleInfo,
                nret = &BytesReceived );
    _m_checkp( msg, "COconst.wakeup - gr$get_module_env." );
    _m_checkq( msg );



    /*
     *  get the default database type from the DPB
     */
    NumberOfBytes = MAX_DB_TYPE_SIZE;
    gr$get_database_type(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = ME.COconst->DatabaseType,
                nret = &BytesReceived );
    _m_checkp( msg, "COconst.wakeup - gr$get_database_type." );
    _m_checkq( msg );

quit:
    return ( OM_S_SUCCESS );
}


end implementation COconst;


