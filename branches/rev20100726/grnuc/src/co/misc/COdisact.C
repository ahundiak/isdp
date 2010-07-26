/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                         < 1986,1987,1989,1990 >

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

^L
 */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     FUNCTION NAME: CO_display_active_parms
       
		This method will return the object id and object space number
     of the symbology object manager and the graphics assocated with 
     the symbology override object.
        

-----
%SC%    

    status = CO_display_active_parms( sts,
                                     &module_grid,
                                      mask,
                                      string );

    
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------
     module_grid  struct GRid    The module environment objid & osnum

     mask         IGRlong        The #defines of the messages to be 
                                 cat on the string.  #define are
                                 located in "comisc.h"

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     sts          IGRint         completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     string       IGRchar[MS_MAX_MSG_LENGTH]
                                 An array of characters in which the
                                 resulting string is passed back
                            

----*/

#include "coimport.h"
#include "codebug.h"
#include "grerr.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grsymdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "comisc.h"
#include "grsym.h"
#include "csmacros.h"
#include "msmacros.h"
#include "igrmacros.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "DImacros.h"
#include "DIprims.h"



IGRint CO_display_active_parms( msg, 
                                module_grid, 
                                mask,
                                final_string )
    IGRint                  *msg; 
    struct GRid             *module_grid; 
    IGRlong                  mask;
    char                    *final_string;
{
    IGRlong                  status,
                             number_of_bytes,
                             bytes_received;
    IGRchar                  string[MS_MAX_MSG_LENGTH],
                             string1[MS_MAX_MSG_LENGTH],
                             tmp_string[MS_MAX_MSG_LENGTH],
                             null_string[2];


    _m_debug_str("CO_display_active_parms");
    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    sprintf( final_string,"%s","" );
    sprintf( string,"%s","" );
    sprintf( null_string,"%s","" );
    sprintf( tmp_string,"%s",", " );


    if((mask & CO_STATUS_FORM) == CO_STATUS_FORM)
    { 
       _m_debug_str("CO_display_active_parms - STATUS FORM AVAILABLE");
       ex$message( msgnumb = GR_I_StFmAvail, 
                   buff    = final_string );
    }

    if((mask & CO_ACTIVE_ANGLE) == CO_ACTIVE_ANGLE)
    {
/*       IGRlong                  number_of_aliases = 1; ..Mohan Sun-port */
       IGRshort                 number_of_aliases = 1;
       IGRshort                 field_size=sizeof(IGRchar) * MS_MAX_MSG_LENGTH;
       IGRdouble                active_angle;
       struct GRIOreadout_spec  readout_spec;

       _m_debug_str("CO_display_active_parms - ACTIVE ANGLE");

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       number_of_bytes = sizeof( active_angle );
       status = gr$get_active_angle( msg    =  msg,
                                     sizbuf = &number_of_bytes,
                                     buffer = &active_angle,
                                     nret   = &bytes_received );
       _m_check2p( status,*msg,"CO_display_act - failed gr$get_active_angle" );

       status = co$update_readout_spec( msg          =  msg,
                                        unit_type    =  GRIO_ANGLE,
                                        osnum        =  module_grid->osnum,
                                        update_flag  =  FALSE,
                                        readout_spec = &readout_spec );

       /* do not display units */
       readout_spec.alias_displayed = FALSE;
       readout_spec.intermeas_spacing = 0;
       readout_spec.intrameas_spacing = 0;

       status = co$cvt_imp_to_alias( msg           =  msg,
                                     unit_type     =  GRIO_ANGLE,
                                     osnum         =  module_grid->osnum,
                                     working_units = &active_angle,
                                     inverse_scale_flag = GRIO_NO_SCALE,
                                     readout_spec  = &readout_spec,
                                     field_size    = &field_size,
                                     num_alias     = &number_of_aliases,
                                     cvt_list      =  string );

       ex$message( msgnumb = GR_I_AAEq, 
                   buff    = string,
                   type    = "%s",
                   var     = `string` );
       strcat( final_string, string );
    }

#ifndef IDRAW
    if((mask & CO_APPARENT) == CO_APPARENT)
    {
       IGRboolean  apparent_flag;
 
       _m_debug_str("CO_display_active_parms - TRUE/APPARENT");

       number_of_bytes = sizeof( apparent_flag );
       status = gr$get_apparent_flag(msg    =  msg,
                                     sizbuf = &number_of_bytes,
                                     buffer = &apparent_flag,
                                     nret   = &bytes_received);

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       if( apparent_flag )
       {
          ex$message( msgnumb = GR_I_Appar, 
                      buff    = string );
          strcat( final_string, string );
       }
       else
       {
          ex$message( msgnumb = GR_I_True, 
                      buff    = string );
          strcat( final_string, string );
       }
 
    }

    if((mask & CO_ABSOLUTE) == CO_ABSOLUTE)
    {
       IGRboolean   absolute_flag;

       _m_debug_str("CO_display_active_parms - LOCAL/ABSOLUTE");

       number_of_bytes = sizeof( absolute_flag );
       status = gr$get_local_abs_flag(msg    =  msg,
                                      sizbuf = &number_of_bytes,
                                      buffer = &absolute_flag,
                                      nret   = &bytes_received);

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       if( absolute_flag )
       {
          ex$message( msgnumb = GR_I_Abs, 
                      buff    = string );
          strcat( final_string, string );
       }
       else
       {
          ex$message( msgnumb = GR_I_Local, 
                      buff    = string );
          strcat( final_string, string );
       }
    }
#endif /* IDRAW */


    if((mask & CO_CLOCKWISE) == CO_CLOCKWISE)
    {
       IGRboolean   clock_flag;

       _m_debug_str("CO_display_active_parms - CW/CCW");

       number_of_bytes = sizeof( clock_flag );
       status = gr$get_arc_direction(msg    =  msg,
                                     sizbuf = &number_of_bytes,
                                     buffer = &clock_flag,
                                     nret   = &bytes_received);

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       if( clock_flag )
       {
          ex$message( msgnumb = GR_I_CCW,
                      buff    = string );
          strcat( final_string, string );
       }
       else
       {
          ex$message( msgnumb = GR_I_CW,
                      buff    = string );
          strcat( final_string, string );
       }
    }

    if((mask & CO_XH_SP_ANG) == CO_XH_SP_ANG)
    {
       IGRlong                  number_of_aliases = 1;
 	
       /* TR# 119423264 : changed field size from MS_MAX_MSG_LENGTH 
	  to 80 . otherwise ex$message is resulting in abort when the text 
	  justification is set to Right or Center */
       
       IGRshort                 field_size=sizeof(IGRchar) * 80;
       IGRdouble                xhatch_spacing,
                                xhatch_angle;
       struct GRIOreadout_spec  readout_spec;

       _m_debug_str("CO_display_active_parms - XH SPACING ANGLE");

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       number_of_bytes  = sizeof( xhatch_spacing );
       status = gr$get_xhatch_spacing(msg    =  msg,
                                      sizbuf = &number_of_bytes,
                                      buffer = &xhatch_spacing,
                                      nret   = &bytes_received);
     
       status = co$update_readout_spec( msg          =  msg,
                                        unit_type    =  GRIO_DISTANCE,
                                        osnum        =  module_grid->osnum,
                                        update_flag  =  FALSE,
                                        readout_spec = &readout_spec );

       /* do not display units */
       readout_spec.alias_displayed = FALSE;
       readout_spec.intermeas_spacing = 0;
       readout_spec.intrameas_spacing = 0;

       status = co$cvt_imp_to_alias( msg           =  msg,
                                     unit_type     =  GRIO_DISTANCE,
                                     osnum         =  module_grid->osnum,
                                     working_units = &xhatch_spacing,
                                     inverse_scale_flag = GRIO_NO_SCALE,
                                     readout_spec  = &readout_spec,
                                     field_size    = &field_size,
                                     num_alias     = &number_of_aliases,
                                     cvt_list      =  string );


       number_of_bytes  = sizeof( xhatch_angle );
       status = gr$get_xhatch_angle(msg    =  msg,
                                    sizbuf = &number_of_bytes,
                                    buffer = &xhatch_angle,
                                    nret   = &bytes_received);
     
       status = co$update_readout_spec( msg          =  msg,
                                        unit_type    =  GRIO_ANGLE,
                                        osnum        =  module_grid->osnum,
                                        update_flag  =  FALSE,
                                        readout_spec = &readout_spec );

       /* do not display units */
       readout_spec.alias_displayed = FALSE;
       readout_spec.intermeas_spacing = 0;
       readout_spec.intrameas_spacing = 0;

       status = co$cvt_imp_to_alias( msg           =  msg,
                                     unit_type     =  GRIO_ANGLE,
                                     osnum         =  module_grid->osnum,
                                     working_units = &xhatch_angle,
                                     inverse_scale_flag = GRIO_NO_SCALE,
                                     readout_spec  = &readout_spec,
                                     field_size    = &field_size,
                                     num_alias     = &number_of_aliases,
                                     cvt_list      =  string1 );

       ex$message( msgnumb = GR_I_SpacAngEq, 
                   buff    = string,
                   type    = "%s %s",
                   var     = `string,string1` );
       strcat( final_string, string );
    }


    if((mask & CO_ACTIVE_CELL) == CO_ACTIVE_CELL)
    {
       struct GRactive_symbol_def   active_cell;

       _m_debug_str("CO_display_active_parms - ACTIVE CELL");
       
       status = gr$symget_active_symbol( msg            =  msg,
                                         act_symbol_def = &active_cell );
       _m_check2p(status,*msg,"CO_display_act - symget_active_symbol failed");

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       ex$message( msgnumb = GR_I_CellEq,
                   buff    = string,
                   type    = "%s",
                   var     = `active_cell.name` );
       strcat( final_string, string );
    }


    if((mask & CO_COORD_NAME) == CO_COORD_NAME)
    {
       _m_debug_str("CO_display_active_parms - ACTIVE COORD NAME");

       number_of_bytes = sizeof( string );
       status = cs$get_active_info (
                    msg           =  msg,
                    osnum         =  module_grid->osnum,
                    module        =  module_grid->objid,
                    namebuf_size  =  number_of_bytes,
                    name          =  string,
                    namebytes_ret = &bytes_received );

       di$split(pathname = string, name = string1);

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       strcat( final_string, string1 );
    }


    if((mask & CO_COORD_TYPE) == CO_COORD_TYPE)
    {
       IGRchar     cs_type[MAX_CS_TYPE];

       _m_debug_str("CO_display_active_parms - ACTIVE COORD TYPE");

       number_of_bytes = sizeof( cs_type );
       status = gr$get_cs_type( msg = msg,
                                sizbuf = &number_of_bytes,
                                buffer =  cs_type,
                                nret   = &bytes_received);

       if( final_string[0] != null_string[0] )
          strcat( final_string, tmp_string );

       strcat( final_string, cs_type );
    }

    return( status );
}
