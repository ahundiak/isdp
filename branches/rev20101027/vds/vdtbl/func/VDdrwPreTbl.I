/* $Id: VDdrwPreTbl.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vdtbl/func/VDdrwPreTbl.I
 *
 * Description:
 *   VDdrwPreTbl.I includes the functions used for preview table layout
 *   function
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwPreTbl.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:27  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/06/11  15:38:40  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.10  1995/10/25  17:27:26  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by tlbriggs for vds.240
#
# Revision 1.9  1995/10/10  15:57:14  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by yzhu for vds.240
#
# Revision 1.8  1995/10/04  20:07:00  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by yzhu for vds.240
#
# Revision 1.7  1995/09/25  23:44:10  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by sundar for vds.240
#
# Revision 1.6  1995/09/19  22:07:02  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by yzhu for vds.240
#
# Revision 1.5  1995/09/14  14:50:10  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/09/07  14:33:34  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by yzhu for vds.240
#
# Revision 1.3  1995/07/06  14:44:16  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/13  19:49:12  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I for:  by tdumbach for vds.240
#
# Revision 1.8  1995/05/19  16:37:52  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I by yzhu r#
#
# Revision 1.7  1995/05/05  20:40:52  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I by hverstee r#
#
# Revision 1.6  1995/04/26  18:48:12  pinnacle
# Replaced: vdtbl/func/VDdrwPreTbl.I by yzhu r#
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/13/95        yzhu            creation date
 *	10/25/95	tlb		EMS 3.2: changed cs.h to grcoordsys.h
 ************************************************************************/

class implementation Root;

/*
#define vdsDEBUG        1
#define vdserrDEBUG     1
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "igewinmacros.h"

#include "EMSmsgdef.h"
#include "exmacros.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "dpdef.h"
#include "AS_status.h"

#include "igrtypedef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "dp.h"
#include "dpmacros.h"

#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grcoordsys.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDdrwtbl.h"
#include "vdsmacros.h"

#include "VDdrwgrProto.h"
#include "VDdrwgrMacro.h"
#include "VDdrwPrTb_pr.h"
#include "vddlodef.h"
#include "vddlomacros.h"

extern GRclassid        OPP_GRowner_class_id;

from NDmacro            import  ACreturn_foot;
from GRgraphics         import  GRaddwrng, GRdisplay, GRconstruct, GRdelete;

from IGEgragad          import  DPfit, gragad_cons, DProtate; 
from IGEgadget          import  add_gadget, activate ;
from VDdrwlo            import  VDdrwlo_gtab, VDdrwlo_grect, 
			        VDdrwlo_gfix, VDdrwlo_gdata;

/* ---------------------------------------------------------------------------
  Public Function: VDset_cs

  Abstract
     This function is used to create a coordinate system

  Arguments
     struct GRid        *CSobj          O       system coordinates

  Example:

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/
IGRlong VDset_cs( struct GRid *CSobj)
{
IGRlong    	status = OM_S_SUCCESS;  
long            msg; 			/* return codes */
long 		size;     		/* dpb parameter */
short 		ii;
char            csname[DI_PATH_MAX];    /* to hold the name of CS */
char            csdesc[60];             /* description */
struct          IGRlbsys lbs_geom;      /* local bounded system geometry */
struct IGRdisplay ActiveDisplay;        /* active display */
struct GRmd_env ModuleInfo;             /* module information */
struct GRcs_construct cs_args;          /* cs-specific construction args */
struct GRvg_construct cnst_lis;         /* construct argument list */
short           ActiveLevel;            /* active level */
double          origin[3];
%safe
static double   matrix[16] = {-1.0, 0.0, 0.0, 0.0,
                              0.0, -1.0, 0.0, 0.0,
                              0.0, 0.0, 1.0, 0.0,
                              0.0, 0.0, 0.0, 1.0 };
%endsafe
 
   SetProc( VDset_cs ); Begin 

   /* set orginal point:  take big number to avoid the table show up
    * in other window
    */
   origin[0] = -100000.;             
   origin[1] = -100000.;
   origin[2] = 0.;

   __DBGpr_vec( " Oringin point ", origin);

   __DBGpr_mat( " Matrix ", matrix);

  /* hard coding coordinate system name */
     strcpy( csname, "pv" );
     strcpy( csdesc, "" );

  /* set up the local bounded system geometry for the
     coordinate system -- transpose the view rotation matrix, add
     in the origin, and give it a degenerate diagonal 
  */

  ii = 4;

  MAtrnmx( &msg, &ii, matrix, lbs_geom.matrix );

  if( msg != MSSUCC )
   return OM_E_ABORT;


  for( ii = 0; ii < 3; ii=ii+1 )
  {
   lbs_geom.matrix[ 3 + (4*ii) ] = origin[ii];
   lbs_geom.diag_pt1[ii] = 0;
   lbs_geom.diag_pt2[ii] = 0;
  }

  /* set up the other construction parameters */

  size = sizeof( struct IGRdisplay );
  gr$get_active_display( msg = &msg,
                         sizbuf = &size,
                         buffer = &ActiveDisplay,
                         nret = &size );


  size = sizeof( short );
  gr$get_active_level( msg = &msg,
                       sizbuf = &size,
                       buffer = &ActiveLevel,
                       nret = &size);

  size = sizeof( ModuleInfo );
  gr$get_module_env( msg = &msg,
                     sizbuf = &size,
                     buffer = &ModuleInfo,
                     nret = &size );

  cs_args.desc = csdesc;
  cs_args.flag = CS_MAKE_ACTIVE | CS_CONNECT_TO_MGR;
  cs_args.type = RECTANGULAR;

 
  cnst_lis.msg = &msg;
  cnst_lis.newflag = FALSE;
  cnst_lis.name = csname;
  cnst_lis.class_attr = (char *)&cs_args;
  cnst_lis.level = ActiveLevel;
  cnst_lis.display = &ActiveDisplay;
  cnst_lis.env_info = &ModuleInfo;
  cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.geometry = (char *)&lbs_geom;

  CSobj->osnum = ModuleInfo.md_id.osnum;
  status = om$construct (classname = "GRgencs",
                            msg = message GRgraphics.GRconstruct
                                         (&cnst_lis),
                            osnum = CSobj->osnum,
                            p_objid = &CSobj->objid);

  End
  return status ;
}
/* ----------------------------------------------------------------------------
  Public Function: VDcreate_window
 
  Abstract
     This function is used to create a window
 
  Arguments
     GRspacenum  	osnum;   	I 	space number  
     struct GRid 	*window,        O 	window id     
     			*gragad;        O 	gragad id     
     IGRint             win_type;       I       window type BORDER/NO_BORDER 
     IGRint      	screen,         I 	screen number 
                        xor,yor,	I       window low left corner point  
                        width,height;   I       window width and height
  
  Example:
 
  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/
IGRlong VDcreate_window( GRspacenum   osnum,
                         struct GRid  *window,
                 	 IGRint       win_type,
                 	 struct GRid  *gragad,
                 	 IGRint       screen,
                         IGRint       xor,
                         IGRint       yor,
                         IGRint       width,
                         IGRint       height)
{
 long            	status,msg ;
 struct GRmd_env 	lib_env;
 int 			flag_rotate;
%safe
    static double rotation[16] = {-1., 0., 0., -100000.,
                                  0., -1., 0., -100000.,
                                  0., 0., 1., 0.,
                                  0., 0., 0., 1. };
%endsafe

        SetProc( VDcreate_window ); Begin

 	/* build md_env for macro lib ?? */

        lib_env.md_id.osnum = osnum;

        ex$get_modid( mod_osnum = lib_env.md_id.osnum,
        	      mod_id    = &lib_env.md_id.objid ) ;

   	lib_env.md_env.matrix_type = 2 ;

   	MAidmx( &msg, lib_env.md_env.matrix ) ;
       
        __DBGpr_mat( " matrix " , lib_env.md_env.matrix );
 
        /*
         * Create gragad gadget. A gragad gadget contains all software
         * information about the window ( Coordinate system, rotation
         * matrix ... ).
         */

 	status = om$construct( 
                            classname   = "ASgradMac",
                            osnum       = lib_env.md_id.osnum,
                            p_objid     = &gragad->objid,
                            msg         = message IGEgragad.gragad_cons
                            (&msg, "preview table window", 0., 0., 1.0,1.0) ) ;

 	as$status(action = RET_STATUS);

	gragad->osnum = lib_env.md_id.osnum ;

        __DBGpr_obj("Gragad constructed", *gragad);

	/*
 	* Create the graphic window. This window contains all hardware
 	* informations about the window ( environ V informations ).
 	*/
  	{
   	short space = 3;

   	double   min_x, min_y, max_x, max_y;

   	min_x = xor; min_y = yor; max_x = min_x+width; max_y=min_y+height;

        __DBGpr_dbl( " min_x ", min_x);
        __DBGpr_dbl( " min_y ", min_y);
        __DBGpr_dbl( " max_x ", max_x);
        __DBGpr_dbl( " max_y ", max_y);

        status = ige$construct_win( 
                                 msg           = &msg,                 /* O */
                                 win_class     = "GRwindow",           /* I */
                                 win_objid     = &window->objid,       /* O */ 
                                 mod_id        = lib_env.md_id.objid,  /* I */
                                 mod_osnum     = lib_env.md_id.osnum,  /* I */
                                 name          = "preview table",      /* I */
                                 win_type      = win_type,             /* I */
/*				 win_level     = IGE_LOW,               I */
                                 dep_indep     = IGE_DEPENDENT,        /* I */
                                 screen        = screen,               /* I */
                                 min_x         = min_x,                /* I */
                                 min_y         = min_y,                /* I */
                                 max_x         = max_x,                /* I */
                                 max_y         = max_y,                /* I */ 
                                 right_space   = space,                /* I */
                                 left_space    = space,                /* I */
                                 top_space     = space,                /* I */
                                 bottom_space  = space,                /* I */
                                 icon_flags    =  IGE_WIN_TOP_ICON |
                                 		  IGE_WIN_BOTTOM_ICON | 
                                                  IGE_WIN_COLLAPSE_ICON |
                                                  IGE_WIN_MODIFY_ICON) ;
        as$status(action = RET_STATUS);

        window->osnum = lib_env.md_id.osnum ;

        }


        __DBGpr_obj("Window constructed", *window);

        /*
         * Add the gragad gadget to the graphic window.
         */
        status = om$send( msg   = message IGEgadget.add_gadget( &msg,
                                                                &gragad->objid,
                                                                1 ),
                               senderid = NULL_OBJID,
                               targetid = window->objid,
                               targetos = window->osnum ) ;
        as$status(action = RET_STATUS);


        /*
         * Activate the graphic window.
         * Do not update because the we do not print model objects
         */
	DPactivate_update(FALSE);  

        status = om$send( msg   = message IGEgadget.activate( &msg,
                                                   0 ),
                       senderid = NULL_OBJID,
                       targetid = window->objid,
                       targetos = window->osnum ) ;
	DPactivate_update(TRUE);

        /*
         *  The default is an iso window , we need a plan window
         */
        flag_rotate = ORIGIN_CENTER | REPLACE_MTX ;
        status = om$send( msg      = message IGEgragad.DProtate( &msg,
                                                              flag_rotate,
                                                              NULL,
                                                              rotation,
                                                              FALSE ),
                       senderid = NULL_OBJID,
                       targetid = gragad->objid,
                       targetos = gragad->osnum ) ;

        End
        return status ;

} /* VDcreate_window */

/* ----------------------------------------------------------------------------
  Internal Function: VD_drwtb_CrtPreTbl

  Abstract
     This function is used to create a preview table which may only include
     a header, or trailer or entire table.

  Arguments
     struct GRid 	*window         I       window  id
     struct GRid 	tblLayoutId     I       table layout id
     IGRint             dis_type;       I       display type : VDdrwlo.h
     IGRint             *ownerId;       o       onwer id of line and text objs
     struct GRmd_env    *mod_env;       o       onwer id of line and text objs
     struct GRid        **graphId0      O       graphic objects list
     IGRint             *nbgraphId      O       graphic objects list number
 
  Example:

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/
IGRlong VD_drwtb_CrtPreTbl( struct GRid *window,  
                            struct GRid tblLayoutId, 
                            IGRint      dis_type, 
                            struct GRid *ownerId,
                            struct GRmd_env *mod_env,
                            struct GRid *csId,
                            struct GRid **graphId0,
                            IGRint      *nbgraphId) 
{
    IGRint              i,j,imax = 0;
    IGRint              TotalGraph = 0;
    IGRshort 		csLocation;
    struct VDdrwlo_tab  tblRec;
    IGRlong             msg;
    OMuword             os;
    IGRdouble           headerCornerPoint[3]; /* corner point of header */
    struct VDdrwlo_apifix  *fldRecs = NULL; 
/*  struct VDdrwlo_data    *datafldRecs = NULL;  */
    IGRint              size = sizeof( struct GRmd_env);
    IGRdouble           xLow, yLow,
                        xHigh, yHigh;
    IGRlong             status = OM_S_SUCCESS;   
    IGRint              status1;   
    IGRshort            flerecCount[8];
    IGRshort            tblOrient;
    IGRshort            hdrType;
    IGRshort            flegrpType[8];
    IGRdouble           fleheight[8];
    IGRdouble           hdrHeights;
    IGRdouble           totalHeight;
    IGRdouble           cornerPnt[3];
    IGRint              nbLines,
                        nbTexts;
    struct GRid         *lineIds = NULL,
                        *textIds = NULL;
    OM_S_CHANSELECT             compChan;
    struct GRid         ownerId1;
    IGRshort            defColor, attColor;
    VD_drwLoInfo        info;
    struct GRid         tmpwid;
    IGRdouble		fheight;

    SetProc( VD_drwtb_CrtPreTble ); Begin

    __DBGpr_obj( "window id", *window );

    tmpwid = *window;
    (*nbgraphId) = 0;
    /* get current osnum */

    ex$get_cur_mod( osnum = &os );

    __DBGpr_int( "Current osnum", os );

     /* get current module environment*/

     status =
     gr$get_module_env(  msg    = &msg,
                        sizbuf  = &size,
                        buffer  = mod_env );
     CheckRC( status, msg );

     /* 
      * construct the new coordinate system 
     */

     VDset_cs( csId ); 

    /*
     * get table record : table type, table name and table direction 
     * to get orientation
     */

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_gtab (&msg, &tblRec),
        targetid = tblLayoutId.objid,
        targetos = tblLayoutId.osnum,
        senderid = NULL_OBJID);

    __CheckRC( status, msg, "VD_drwlo_gtab", wrapup );

    tblOrient = tblRec.direct;

    /* 
     * set cs location  VD_DRW_CS_LOC_RIGHT or VD_DRW_CS_LOC_RIGHT 
     * here we use right location
     */
    csLocation = VD_DRW_CS_LOC_RIGHT;
 

    /* first set up the header corner point */

    headerCornerPoint[2] = 0.0;       /* z = 0 */

    /* 
     * must get rectangle for header and using it as basic  : 
     */

    hdrType = VD_DRWLO_EN_HEADER;   /* first consider header case */ 

    status1 =
    om$send( msg = message  VDdrwlo.VDdrwlo_grect(  
                        &msg,
                        hdrType, 
                        VD_DRWLO_EN_ALL,                        
                        NULL,
                        0, NULL,
                        &xLow, &yLow,
                        &xHigh, &yHigh ),
            targetid = tblLayoutId.objid,
            targetos = tblLayoutId.osnum,
            senderid = NULL_OBJID);
              
      CheckRC( status1, msg );
     
      hdrHeights = yHigh - yLow;
      fheight = hdrHeights;

      /* 
       * set  x amd y of header corner point according to csLocation 
      */

      if( csLocation == VD_DRW_CS_LOC_RIGHT &&
                                tblOrient == VD_DRWLO_EN_ASCEND )
      {
          /*  X is position of cs 
               -----------------------------  
               |                           |
               ----------------------------X  
          */ 
         	headerCornerPoint[0] = xLow - xHigh;
        	headerCornerPoint[1] = 0;
       }
       else if( csLocation == VD_DRW_CS_LOC_RIGHT &&
                                tblOrient == VD_DRWLO_EN_DESCEND )
       {

          /*   
               ----------------------------X  
               |                           |
               -----------------------------  
          */ 

        	headerCornerPoint[0] = xLow - xHigh;
        	headerCornerPoint[1] = yLow - yHigh;
       }
        else if( csLocation == VD_DRW_CS_LOC_LEFT &&
                               tblOrient == VD_DRWLO_EN_ASCEND )
       {
          /*   
               -----------------------------  
               |                           |
               X----------------------------  
          */ 
           headerCornerPoint[0] = 0;
           headerCornerPoint[1] = 0;
       }

       else if( csLocation == VD_DRW_CS_LOC_LEFT &&
                              tblOrient == VD_DRWLO_EN_DESCEND )
       {
          /*   
               X----------------------------  
               |                           |
               -----------------------------  
          */ 
        
          headerCornerPoint[0] = 0;
          headerCornerPoint[1] = yLow - yHigh;
       }

       __DBGpr_vec( "Header corner point", headerCornerPoint );

      /*
       * now construct the components
       */

      /**  get the number of fixed components ( header or trailer) */

      __DBGpr_int( " type of display ", dis_type);

      if( dis_type == VD_DRWLO_EN_ALL) {
         imax = 8;
         flegrpType[0] = VD_DRWLO_EN_HEADER;
         flegrpType[1] = VD_DRWLO_EN_DATA;
         flegrpType[2] = VD_DRWLO_EN_DATA;
         flegrpType[3] = VD_DRWLO_EN_BRKTRLR;
         flegrpType[4] = VD_DRWLO_EN_BRKHDR;
         flegrpType[5] = VD_DRWLO_EN_DATA;
         flegrpType[6] = VD_DRWLO_EN_DATA;
         flegrpType[7] = VD_DRWLO_EN_TRAILER;
      }
      if( dis_type == VD_DRWLO_EN_HEADER) {
         imax = 1;
         flegrpType[0] = VD_DRWLO_EN_HEADER;
      }
      if( dis_type == VD_DRWLO_EN_DATA) {
         imax = 2;
         flegrpType[0] = VD_DRWLO_EN_HEADER;
         flegrpType[1] = VD_DRWLO_EN_DATA;
      }
      if( dis_type == VD_DRWLO_EN_BRKTRLR) {
         imax = 2;
         flegrpType[0] = VD_DRWLO_EN_HEADER;
         flegrpType[1] = VD_DRWLO_EN_BRKTRLR;
      }
      if( dis_type == VD_DRWLO_EN_BRKHDR) {
         imax = 2;
         flegrpType[0] = VD_DRWLO_EN_HEADER;
         flegrpType[1] = VD_DRWLO_EN_BRKHDR;
      }
      if( dis_type == VD_DRWLO_EN_TRAILER) {
         imax = 2;
         flegrpType[0] = VD_DRWLO_EN_HEADER;
         flegrpType[1] = VD_DRWLO_EN_TRAILER;
      }

      /* loop for getting info of different part of table layout */      
      TotalGraph = 0; 
      totalHeight = 0; 
      (*graphId0) = NULL;

      for( i = 0; i < imax; i++) {
           fleheight[i] = 0;       
           flerecCount[i] = 0;       
           status1 =
           om$send ( msg = message VDdrwlo.VDdrwlo_gfix(  
                        &msg,
                        flegrpType[i],
                        0, 0,
                        0, NULL,
                        &fleheight[i],      
                        &flerecCount[i],
                        NULL ),
                     targetid = tblLayoutId.objid,
                     targetos = tblLayoutId.osnum,
                     senderid = NULL_OBJID);

           if ( !(status1&msg& 1) ) {
              __DBGpr_int(" No type = ", flegrpType[i]); 
              continue; 
           }
           if( !flerecCount[i] ) {
               __DBGpr_int(" No type = ", flegrpType[i]);
               __DBGpr_dbl(" height = ", fleheight[i]);
               continue;
           }

           __DBGpr_int( "i = ",   i );
           __DBGpr_dbl( "row height", fleheight[i] );
           __DBGpr_int( "row type",   flegrpType[i] );
 
           /* 
            * compute the corner point 
            */

           if( i == 0 ) {                           /* for header */
              totalHeight = totalHeight + fleheight[i];
	      fheight = fleheight[i];
              for( j = 0 ; j < 3 ; j++ ) {
                   cornerPnt[j] = headerCornerPoint[j];
              }
           }

           else {  /* other */
              totalHeight = totalHeight + fleheight[i];

    	      if( tblOrient == VD_DRWLO_EN_DESCEND ) {
                cornerPnt[1] = (cornerPnt[1] - fleheight[i]); 
              }
              else {
                cornerPnt[1] = (cornerPnt[1] + fheight);
              } 
            
              /* if i > 3 , table is divided into 2 parts, second parts will
               * move done or move up two units of hdr height
               */ 
              if ( tblOrient == VD_DRWLO_EN_DESCEND && (i == 4)) 
                   cornerPnt[1] = (cornerPnt[1] - 2.0 * fleheight[0] );

              else if ( tblOrient != VD_DRWLO_EN_DESCEND && (i == 4))
                   cornerPnt[1] = (cornerPnt[1] + 2.0*fleheight[0] );

	      fheight = fleheight[i];

           }

           __DBGpr_dbl( "totalHeight", totalHeight );
       	   __DBGpr_vec( "cornerPnt", cornerPnt );

           /* allocate fldRec */
           
           fldRecs = _MALLOC( flerecCount[i], struct VDdrwlo_apifix );

           if( !fldRecs ) {
                 printf(" fldRecs  has no memory \n"); 
                 status = OM_E_ABORT;
                 goto wrapup;
           } 

           /* 
            * get the list of fixed components, it includes header
            * , brkheader, break trailer, tailer and data.
            */

           status1 =
           om$send ( msg = message VDdrwlo.VDdrwlo_gfix(  
                          &msg,
                          flegrpType[i],
                          cornerPnt[0], cornerPnt[1],
                          0, NULL,
                          &fleheight[i],
                          &flerecCount[i],
                          fldRecs ),
               targetid = tblLayoutId.objid,
               targetos = tblLayoutId.osnum,
               senderid = NULL_OBJID);

           if( !(status1&msg&1) ) {
                _FREE( fldRecs);
                fldRecs = NULL;
                continue;
           }



#ifdef vdsDEBUG1
           __DBGpr_int("Group type ", flegrpType[i] );

           for( j = 0 ; j < flerecCount[i] ; j++ ) {

              printf("\n\tRecord # %d : Type = %s\n", j,
                (fldRecs[j].rectyp == VD_DRWLO_EN_LINE ? "line" : "text") );

              if( fldRecs[j].rectyp == VD_DRWLO_EN_LINE )
                 printf("\t\tPt1 = (%g, %g), Pt2 = (%g, %g)\n",
                        fldRecs[j].VD.ln.x1, fldRecs[j].VD.ln.y1,
                        fldRecs[j].VD.ln.x2, fldRecs[j].VD.ln.y2 );
              else
                 printf("\t\ttext <%s> \n", fldRecs[j].VD.tx.Text);

#ifdef YYY
                 printf("\t\ttext <%s>, numchr %d, Pnt (%g,%g), wdth %g, hgt %g, spc %g, just %d, font %s\n",
                        fldRecs[j].VD.tx.Text, fldRecs[j].VD.tx.numchr,
                        fldRecs[j].VD.tx.xcor, fldRecs[j].VD.tx.ycor,
                        fldRecs[j].VD.tx.ch_wdt, fldRecs[j].VD.tx.ch_hgt,
                        fldRecs[j].VD.tx.ch_spc, fldRecs[j].VD.tx.justif,
                        fldRecs[j].VD.tx.font );
#endif
            }
#endif


    	   /* default table color : for texts and lines */
           status = vd$drw_layout_info( msg     = &msg,
                                        type    = VD_K_drwLO_tblColor,
                                        info    = &info );
           CheckRC( status, msg );
           defColor = info.val.sValue;

           /* attribute color */

           status = vd$drw_layout_info( msg     = &msg,
                                        type    = VD_K_drwLO_tblAttColor,
                                        info    = &info );
           CheckRC( status, msg );
           attColor = info.val.sValue;

           /*
            *  set up default font
            */

           for( j = 0 ; j < flerecCount[i] ; j++ ) {

             if( fldRecs[j].rectyp == VD_DRWLO_EN_LINE )
                fldRecs[j].symb.display_attr.color  = defColor; 

             else {
                fldRecs[j].symb.display_attr.color  = defColor;
                fldRecs[j].VD.tx.numchr = strlen( fldRecs[j].VD.tx.Text) + 1;
             }
            }  /* for j */

            nbLines = 0;
            nbTexts = 0;

            if( imax == 2 && i == 0) { 
                _FREE( fldRecs);
                fldRecs = NULL;
                continue; /* hdr is basic for calculation, not display it*/
            }

            /* construct the graphics and connect the components */
            status =
            vd$placeBOMelem(    count   = flerecCount[i],       /* I */
                                array   = fldRecs,              /* I */
                                p_env   = mod_env,             /* I */
                                p_rcs   = csId,                /* I cs */
                                l_opt   = FALSE,                /* I */
                                p_nln   = &nbLines,
                                p_lin   = &lineIds,
                                p_ntx   = &nbTexts,
                                p_txt   = &textIds,
                                p_msg   = &msg );

            __CheckRC( status, msg, "vd$placeBOMelem", wrapup );

/*
            __DBGpr_int( "No of lines", nbLines );
            __DBGpr_int( "No of texts", nbTexts );

            __DBGpr_objlist( "List of line ids", nbLines, lineIds );
            __DBGpr_objlist( "List of text ids", nbTexts, textIds );
*/
            /* allocate and set up graphId0 */
            if( (*graphId0) && nbLines ) {
              TotalGraph = TotalGraph + nbLines;
              (*graphId0) =  
                      _REALLOC((*graphId0), TotalGraph,struct GRid );
              for ( j = 0; j < nbLines; j++) {
                   (*graphId0)[TotalGraph - nbLines + j] = lineIds[j];
              }
            }
            else if ( !(*graphId0) && nbLines ) {
              TotalGraph = TotalGraph + nbLines;

              (*graphId0) = _MALLOC( TotalGraph, struct GRid);

              for ( j = 0; j < nbLines; j++) {
                   (*graphId0)[TotalGraph - nbLines + j] = lineIds[j];
              } 
            }
            if( (*graphId0) && nbTexts ) {
              TotalGraph = TotalGraph + nbTexts;
              (*graphId0) = _REALLOC((*graphId0), TotalGraph, struct GRid );
              for ( j = 0; j < nbTexts; j++) {
                   (*graphId0)[TotalGraph - nbTexts + j] = textIds[j];
              }
            }
            else if ( !(*graphId0) && nbTexts) { 
              TotalGraph = TotalGraph + nbTexts;
              (*graphId0) =  _MALLOC( nbTexts, struct GRid );
              for ( j = 0; j < nbTexts; j++) {
                   (*graphId0)[TotalGraph - nbTexts + j] = textIds[j];
              }
            }

            _FREE( fldRecs );
             fldRecs = NULL;
	    _FREE( lineIds );
	     lineIds = NULL;
            _FREE( textIds );
	     textIds = NULL;
      } /* for i loop */ 


      *nbgraphId = TotalGraph;

      /* select the components channel */

      status =
      ems$make_chanselect( chan_label      = GRcmpowner_to_components,
                         chan_selector   = &compChan );
      __CheckRC( status, 1, "make_chanselect", wrapup );

     /*
      * create the owner object, the owner space must same with objects
      */

     ownerId1.osnum = os;

     status =
     om$construct(   classid = OPP_GRowner_class_id,
                     osnum   = ownerId1.osnum,
                     p_objid = &ownerId1.objid );

     __CheckRC( status, 1, "GRowner construction", wrapup );



       /* add line and text components to owner */
       
       status =
       VD_drwtb_addComponents(&msg, mod_env, (*nbgraphId), 
                                    (*graphId0), (ownerId1) );
       __CheckRC( status, msg, "VD_drwtb_addComponents", wrapup );

       ownerId->osnum  = ownerId1.osnum;
       ownerId->objid  = ownerId1.objid;
        
       __DBGpr_obj("ownerId1 ", ownerId1); 


wrapup:
       _FREE( fldRecs );
       _FREE( lineIds );
       _FREE( textIds );
       End
       return status;
} /* VD_drwtb_CrtPreTbl */

/* ----------------------------------------------------------------------------
 Public Function: VD_drwlo_preview

 Abstract
    When this function is called, a window is created and  a piece of table
    layout is displaied in the window.

 Arguments
    IGRlong             *msg;           O       return status
    struct GRid         *ownerId        O       graphic owner id
    struct GRid         tblLayoutId     I       table layout id
    IGRint              dis_type;       I       portion of table to display
    IGRint              win_type;       I       window boundary BORDER/NO_BORDER
    IGRint              xmin, ymin;     I       window upper left corner point
                                                         corner of window
    IGRint              width,height;   I       width and height of window
    IGRint              screen;         I       screen number window is on

  Example:

  Status
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/
IGRlong VD_drwlo_preview( IGRlong     *msg,
                          struct GRid *window,
                          struct GRid tblLayoutId,
                          IGRint      dis_type,

                          IGRint      win_type,
                          IGRint      xmin,
                          IGRint      ymin,
                          IGRint      width,
                          IGRint      height,
                          IGRint      screen,
                          struct GRid *ownerId)
{
IGRlong         status;
IGRint          status1;
GRspacenum      cur_os;
struct GRid     gragad;
struct GRid     csId;
struct GRmd_env mod_env;
struct GRid     *graphId1;
IGRint          nbgraphId1;

        SetProc(VD_drwlo_preview ); Begin
        *msg = OM_S_SUCCESS;

        /*
         * create window
         */

        ex$get_cur_mod( osnum = &cur_os );

        status =
        VDcreate_window( cur_os, window, win_type, &gragad,
                         screen,xmin,ymin,width,height);

        /*
         * create  preview table
         */
        graphId1 = NULL;
        nbgraphId1 = 0;
        
        status =   
        VD_drwtb_CrtPreTbl( window, tblLayoutId, dis_type, ownerId, &mod_env,
                            &csId, &graphId1, &nbgraphId1);

        /* erase cs */
        status1 =
        om$send (    msg = message GRgraphics.GRdelete(
                                             msg,
                                             &mod_env),
                                senderid = NULL_OBJID,
                                targetos = csId.osnum,
                                targetid = csId.objid);

        csId.osnum = 0;
        csId.objid = 0;
 
        /* Fit window */

        status =
        vd$vw_fit_object (      object    = ownerId,
                                factor    = 1.0 ,
                                md_env    = &mod_env ,
                                ggid      = &gragad,
                                num_ggid  = 1 );
        as$status();

/*        DPactivate_update(TRUE); */

        _FREE( graphId1);

        End
        return status;

} /* VD_drwlo_preview */
end implementation Root;
