/*
 ------------------------------------------------------------------------------

  Module:  COupdate_current_point_form()

  Abstract:
  
     This function updates all fileds the "Current point" form, if one 
     exists.  Fields in this form reflect the current values of:

        DPB's Last Point, 
        Active Coordinate System Type
        Active Coordinate System.

     Also, the Master units of Distance and Angle effect the display of 
     the coordinate fields.

  Example:  status = CO_update_current_point_form( ReturnMsg,
                                                   Flag );

  Arguments:

     *ReturnMsg      IGRlong         Return message:
                                       MSSUCC - success (always)

      Flag  IGRint
  ******** this argument is obsolete in cbase forms ( GRNUC 1.3.0 + **********
           values ( from griodef.h ):

              UPDATE_ONLY_IF_DISPLAYED  ( default )
              UPDATE_UNCONDITIONALLY
           

      Returns IGRlong
           Always returns MSSUCC


  Notes:

    ******************************* 1.3.0 **********************************
    If the "Current point" form does not exist, nothing happens.
    If the "Current Point" form exists, then 
      1) it is assumed that it is displayed, and
      2) all of its fields will be updated unconditionally
    ************************************************************************ 

  History: 
  
    srh   06/15/87   - created
    srh   11/17/87   - added Flag to the arglist
    srh   05/27/88   - changed format of coordiante system names from
                       alpha (string) to integer for 1.1.2 release of
                       I/Draft.  Also, if an unknown CS type is used, 
                       the XYZ CS names are used as a default;  in 
                       previous versions, no update would occur.
    srh   08/09/88   - added npts = 1 arg to message send GRcoords.
                       GRcvt_to_lcl_coords for 1.2.0 release.
    srh   05/15/89   - converted to c-base forms; no longer uses the
                       Flag argument. ALL updates are unconditional.
    scw   07/14/92   - ansi conversion

 -----------------------------------------------------------------------------
 */

/* EH */
class implementation Root;

#include   <UMS.h>
#include   "grimport.h"
#include   "codebug.h"
#include   "OMminimum.h"
#include   "igrtypedef.h"
#include   "igetypedef.h"
#include   "msdef.h"
#include   "exdef.h"
#include   "godef.h"
#include   "igr.h"
#include   "gr.h"
#include   "ex.h"
#include   "igrdp.h"
#include   "go.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "msmacros.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "exmacros.h"
#include   "FI.h"
#include   "csdef.h"
#include   "grcoordsys.h"
#include   "csmacros.h"
#include   "DItypedef.h"
#include   "DIdef.h"
#include   "DImacros.h"
#include   "igrmacros.h"
#include   "coformpriv.h"

#define  _fi_error_check( sts )   if (sts != 0) {status = MSFAIL; goto quit;}

/* 
 * Until cbase forms support this function, I'll use this cbase macro. srh
 */
#define  _fi_set_symbol( sts, form, label, new_symb )                        \
       sts = FIg_set_symbol_index( form, label, new_symb);                   \
       _fi_error_check( sts );                                               \
									     \
       sts = FIg_erase( form, label );                                       \
       _fi_error_check( sts );                                               \
									     \
       sts = FIg_display( form, label );                                     \
       _fi_error_check( sts )

extern Form p_CurrentPointForm;

extern int 
   FIg_display(),
   FIg_set_symbol_index(),
   FIg_set_text();

from  GRcoords import  
        GRcvt_to_lcl_coords;

from  GRcsmgr  import 
        GRget_query_info;


#argsused
IGRlong COupdate_current_point_form( ReturnMsg, Flag )

   IGRlong     *ReturnMsg;     /*  return information code     */
   IGRint       Flag;          /* not used as of 1.3.0 release - reserved */

{

    IGRlong 
       status = MSSUCC,  /* msg code returned to calling routine  */
       fi_sts = 0;       /* FI routines return 0 on success       */

    IGRshort
       nbr_of_aliases = 3, /* display primary/secondary/tertiary    */
       nbr_of_inputs,      /* used as dummy arg          */
       coord_index,
       field_size;

    IGRint
       ret_size,             /* msg code returned by functions called */
       buffer_size,
       first_coord_sym,      /* index in forms.9 for 1st coord label */
       second_coord_sym,     /* index in forms.9 for 2nd coord label */
       third_coord_sym;      /* index in forms.9 for 3rd coord label */
 
    IGRpoint 
       world_last_point,      /* rectangular in Base CS        */
       local_last_point;      /* in Active CS/Active CS type   */

    IGRchar
      *coord_strings[3],
       cs_name[DI_PATH_MAX],
       first_coord_str  [ UMS_MAX_BUFLEN ],
       second_coord_str [ UMS_MAX_BUFLEN ],
       third_coord_str  [ UMS_MAX_BUFLEN ],
       coord_type       [ UMS_MAX_BUFLEN ];

    struct GRid
       cs_manager,
       module,
       active_cs;

    struct EX_button   
       last_point;

    struct GRcsquery_info 
      *p_coord_info; 

    /* EV -- end local varaibles */


    _m_debug_str( ">  COupdate_current_point_form()" ); 

    /*
     *  ---------------------------------------------------------------------
     *  Step 0: If the "CurrentPt" form does not exists then exit
     *          successfully; else we update the form.
     *  ---------------------------------------------------------------------
     */
    *ReturnMsg = MSSUCC;

    if ( p_CurrentPointForm == NULL )
    {
       _m_debug_str( ">  COupdate_current_point_form:  Form does not exist" ); 
       goto quit; 
    }

    /*
     *  --------------------------------------------------------------------
     *  Step 1:  We now know that the "Current point" form exists and we
     *           make the assumption that this form is displayed 
     *  --------------------------------------------------------------------
     */
    {

       /*
        *  ------------------------------------------------------------------
        *   Step 2:  Get information needed to update the form:  
        *
        *            (a) Last Point from the DPB
        *            (b) Active Coordiante System Name from the Coordinate 
        *                System Manager object
        *            (c) Active Coordinate System Type from the DPB.
        *
        *  ------------------------------------------------------------------
        */

       /*
        *  2.a - get last point info from DPB
        */
       buffer_size = sizeof( last_point );
       gr$get_last_point( msg    =  ReturnMsg,
                          sizbuf = &buffer_size,
                          buffer = &last_point,
                          nret   = &ret_size );

       _m_checkp( *ReturnMsg,
                  "COupdate_current_point_form:  gr$get_last_point failed" );

       /*
        *  2.b - Active Coordinate System Name 
        */

       ex$get_cur_mod( id    = &module.objid,
                       osnum = &module.osnum );

       status = cs$get_active_info (
                    msg           =  ReturnMsg,
                    osnum         =  module.osnum,
                    module        =  module.objid,
                    namebuf_size  =  DI_PATH_MAX,
                    name          =  cs_name,
                    namebytes_ret = &ret_size,
                    objid         = &active_cs.objid );
       
       active_cs.osnum = cs_manager.osnum = module.osnum;

       /* required for "User Mode" output */
       status = di$cvt_name_for_output( s_path = cs_name );
 
       /*
        *  2.c - Active Coordinate System Type from the DPB.
        */
       buffer_size = UMS_MAX_BUFLEN;
       gr$get_cs_type( msg    =  ReturnMsg,
                       sizbuf = &buffer_size,
                       buffer =  coord_type,
                       nret   = &ret_size );

       status = cs$get_mgr( msg    =  ReturnMsg,
                            osnum  =  module.osnum,
                            module =  module.objid,
                            csmgr  = &cs_manager.objid );

       /*
        *  ------------------------------------------------------------------
        *   Step 3:  Get conversion info from ACS needed to get local 
        *            coordinate values and then convert the rectangular
        *            xyz coordinates from Last Point to the Active 
        *            Coordiante Sytem's coordinates.
        *  ------------------------------------------------------------------
        */
       status = om$send( 
                    senderid = NULL_OBJID,

                    msg = message GRcsmgr.GRget_query_info(
                              ReturnMsg,
                              NULL,
                              coord_type,
                             &nbr_of_inputs,
                             &p_coord_info,
                             &active_cs ),

                    targetid = cs_manager.objid,
                    targetos = cs_manager.osnum );

       _m_check2q( status, *ReturnMsg );

       world_last_point[0] = last_point.x;
       world_last_point[1] = last_point.y;
       world_last_point[2] = last_point.z;


       status = cs$cvt_to_lcl( msg    = ReturnMsg,
                               cs_id  = active_cs.objid,
                               cs_os  = active_cs.osnum,
                               cstype = coord_type,
                               npts   = 1,
                               wld    = world_last_point,
                               lcl    = local_last_point );

       _m_check2q( status, *ReturnMsg );

       /*
        *  ------------------------------------------------------------------
        *   Step 4:  Convert each of the coordinates to primary/secondary/
        *            tertiary units ( ascii ) for display in the form
        *  ------------------------------------------------------------------
        */

       coord_strings[0] = first_coord_str ;
       coord_strings[1] = second_coord_str;
       coord_strings[2] = third_coord_str ;

       for ( coord_index = 0; coord_index < 3; coord_index++ )
       {
          field_size = sizeof(IGRchar) * UMS_MAX_BUFLEN;

          status = co$cvt_imp_to_alias(
                       msg                =  ReturnMsg,
                       unit_type          =  p_coord_info->unit_type,
                       inverse_scale_flag =  GRIO_NO_SCALE,
                       osnum              =  module.osnum,
                       working_units      = &local_last_point[coord_index],
                       num_alias          = &nbr_of_aliases,
                       field_size         = &field_size,
                       cvt_list           =  coord_strings[coord_index]);

          _m_check2q( status, *ReturnMsg );

          p_coord_info++;     /* next info structure    */
       }

       /*
        *  ------------------------------------------------------------------
        *   Step 5:  Pre-update:  set correct coordinate labels wrt ACS type
	*            This is really a KLUDGE, since CS types are in English
	*            and do not use the message subsystem.
        *  ------------------------------------------------------------------
        */

       if ( strcmp( coord_type, "rectangular" ) == 0 )
       {
          first_coord_sym  = Xindex;
          second_coord_sym = Yindex;
          third_coord_sym  = Zindex;
       }
       else if (strcmp( coord_type, "cylindrical" ) == 0 )
       {
          first_coord_sym  = RHOindex;
          second_coord_sym = THETAindex;
          third_coord_sym  = Zindex;
       }
       else if (strcmp( coord_type, "spherical" ) == 0 )
       {
          first_coord_sym  = Rindex;
          second_coord_sym = THETAindex;
          third_coord_sym  = PHIindex;
       }
       else
       {
          /*
           *  If we don't know the type of coordiante system, we use XYZ
           *  for coordinate names as a default; this is a KLUDGE, but
           *  unitl the cooridante system information contains font indices
           */
          first_coord_sym  = Xindex;
          second_coord_sym = Yindex;
          third_coord_sym  = Zindex;
       }

       /*
        *  ------------------------------------------------------------------
        *   Step 7:  Update the pertenant fields in the "CurrentPt" form
        *  ------------------------------------------------------------------
        */

       /*************  Coordinate labels ( x/y/z etc. ) *************/
       _fi_set_symbol( fi_sts, 
		       p_CurrentPointForm, 
		       FIRST_COORD_NAME,
		       first_coord_sym );

       _fi_set_symbol( fi_sts, 
		       p_CurrentPointForm, 
		       SECOND_COORD_NAME,
		       second_coord_sym );

       _fi_set_symbol( fi_sts, 
		       p_CurrentPointForm, 
		       THIRD_COORD_NAME,
		       third_coord_sym );

                                      
       /*************** Coordinate value text *************/
       fi_sts = FIg_set_text( p_CurrentPointForm,
                              FIRST_COORD_VALUE,
                              first_coord_str );
       _fi_error_check( fi_sts );

       
       fi_sts =  FIg_set_text( p_CurrentPointForm,
                              SECOND_COORD_VALUE,
                              second_coord_str);
       _fi_error_check( fi_sts );

       
       fi_sts =  FIg_set_text( p_CurrentPointForm,
                              THIRD_COORD_VALUE,
                              third_coord_str );
       _fi_error_check( fi_sts );

       /************* Coordinate system name *************/
       fi_sts =  FIg_set_text( p_CurrentPointForm,
                              COORDINATE_SYSTEM_NAME,
                              cs_name );
       _fi_error_check( fi_sts );

       /************* Coordinate system type *************/
       fi_sts =  FIg_set_text( p_CurrentPointForm,
                              COORDINATE_SYSTEM_TYPE,
                              coord_type );
       _fi_error_check( fi_sts );

    }

quit:

   _m_debug_str( "< COupdate_current_point_form()" ); 

   return( status );

}

end implementation Root;

