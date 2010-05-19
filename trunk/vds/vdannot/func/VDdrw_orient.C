/* $Id: VDdrw_orient.C,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        /vds/vdannot/func/VDdrw_orient.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrw_orient.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1999/02/18  22:39:08  pinnacle
 * tr179801788
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/18/99        ylong           place orientation for tr179801788
 * -------------------------------------------------------------------*/


#include <string.h>
#include <stdlib.h>

#include <OMerrordef.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <msdef.h>
#include <exms.h>
#include <msmacros.h>
#include "grmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"

#include "grio.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grmsg.h"
#include "bstypes.h"
#include "msdef.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "vdmiscmacros.h"
#include "v_dbgmacros.h"

/*----------------------------------------------------------------------------*/
int VD_PlaceCell( msg, lib_name, cell_name, pos, angle, scale, md_env, cell_id )

long		        *msg ;		/* OUT: Completion code		  */
char			*lib_name ;	/* IN : libary name               */
char			*cell_name ;	/* IN : cell name                 */
IGRpoint		pos ;		/* IN : place position            */
IGRdouble		angle ;		/* IN : place angle               */
IGRdouble		scale[3] ;	/* IN : place scale               */
struct	GRmd_env	*md_env ;	/* IN : module information        */
struct	GRid		*cell_id ;	/* OUT: cell id                   */

{
	long			sts ;		/* Return status	*/
	int			i ;		/* Loop-on-geoms index	*/
	IGRmatrix		txMx ;		/* Matrix for text	*/

        IGRchar                 symbol_name[MAX_SYMBOL_DEF_NAME],
                                s[MAX_SYMBOL_DEF_NAME];
        IGRchar                 *original_sy = NULL,
                                *originl_lib = NULL;
        IGRlong                 size,
                                om_msg,
                                ret_msg;
        IGRint			length;
        struct  GRactive_symbol_def     active_symbol;
        struct  GRid            sdh_id,
                                symbol_id;
        struct  GRmd_env        sl_env;
        struct  GRsymbol_lib_file       file;
        struct  GRsymbol_lib_file       ori_file;

	#ifdef vdsDEBUG
	printf( "VD_drwCstSymbol enter\n" ) ;
	#endif

	*msg = MSSUCC;
	
 /* place the cell */

        /*
         * Get the active symbol and store the original name.
         */

	active_symbol.name[0]  = '\0';
        sts = gr$symget_active_symbol (msg            = &ret_msg,
                                       act_symbol_def = &active_symbol);
        if( ret_msg == MSSUCC && active_symbol.name[0] != '\0'){
                 length = strlen( active_symbol.name ) + 1;
                 original_sy = _MALLOC( length, IGRchar );
                 strcpy(original_sy, active_symbol.name);
           }
        /*
         * Get the information about the active cell library and save the
         * active library name.
         */

	ori_file.file_name[0] = '\0';
        sts = gr$symget_asl_info (msg  = msg,
                                  file = &ori_file);
        if (!( *msg & 1 )) {goto wrapup; }

        if( ori_file.file_name[0] != '\0' )
        {
          length = strlen( ori_file.file_name ) + 1;
          originl_lib = _MALLOC( length, IGRchar );
          strcpy(originl_lib,ori_file.file_name);
        }

        /*
         * Retreive the cell library with the given file name.
         */

	length = strlen(lib_name) ;
        strncpy(file.file_name, lib_name, length );
        file.file_name[length] = '\0';

        sts = gr$symretrieve_cell_library (
                                    filename    = file.file_name,
                                    file_no     = &file.file_no,
                                    flag        = EX_read_write | EX_read_only,
                                    file_access = &file.file_access,
                                    fstat       = EX_old_module);

        if (sts == GR_E_NO_FILE) {
                UI_status("File Does Not Exist");
                goto wrapup;
        }
        else if (sts == GR_E_NOT_CELL_LIB) {
                UI_status("File Not A Cell Library");
                goto wrapup;
        }
        else if (sts == GR_E_NO_PREMISSION) {
                UI_status("No Permission for Operation");
                goto wrapup;
        }
        else if( !(sts & 1)){ goto wrapup;}

        /*
         * Define the given lib as active lib.
         */
        om_msg = gr$symput_asl ( msg  = msg,
                                 file = &file);
        if(!(om_msg & *msg & 1)) goto wrapup;

        length = strlen( cell_name ) ;
        strncpy(symbol_name, cell_name, length );
        symbol_name[length] = '\0';

        om_msg = gr$symsd_locate_in_all_sl( msg     = msg,
                                            sd_name = symbol_name,
                                            sl_env  = &sl_env, 
                                            sd_id   = &symbol_id);
        if( *msg == MSFAIL) {
                 sprintf(s,"Symbol \"%s\" Not Defined", symbol_name);
                 UI_status(s); goto wrapup;
          }

        /*
         * Make the required cell as active.
         */

        om_msg = gr$symput_active_symbol ( msg         = msg,
                                           symbol_name = symbol_name,
                                           symbol_id   = &symbol_id,
                                           asl_env     = &sl_env);
        if(!( *msg & 1)){goto wrapup;}

        /*
         * Get the active symbol.
         */

        sts = gr$symget_active_symbol (msg            = msg,
                                       act_symbol_def = &active_symbol);
        if( *msg == MSFAIL) {goto wrapup;}

        sdh_id.objid = active_symbol.objid;
        sdh_id.osnum = active_symbol.symbol_env.md_id.osnum;

        /* set indentical matrix txMx */
        for(i = 0; i < 16; i = i + 1) {
		txMx[i] = 0.;
	}
        txMx[0] = 1.;
        txMx[5] = 1.;
        txMx[10] = 1.;
        txMx[15] = 1.;

        /*  Place the cell */
        sts = gr$sym_cl_place (
                        msg        = msg,
                        num_cells  = 1,
                        origin     = (IGRpoint*)pos,
                        angle      = &angle,
                        scale      = scale,
                        rot_matrix = txMx,
                      /*  display    = &dis, */
                        properties = GRIS_NEW | GRIS_DISPLAYABLE |
                                     GRIS_LOCATABLE,
                      /*  level      = (IGRshort*)1,  cnst.level, */
                        symbol_env = &sl_env,
                        target_env = md_env,
                        classname  = "GRclhdr",
                        sdh_id     = &sdh_id,
                        cl_id      = cell_id);

	if( sts&1&*msg )
        {
          __DBGpr_obj( "Cell", symbol_id ) ;
          __DBGpr_obj( "myCell", *cell_id ) ;

        } 
        else
        {
       	  UI_status( "Cell Placement Failed" );
          vd_$bulk_delete( grids   = &symbol_id,
                           theEnv  = md_env ) ;
	  goto wrapup ;
	}

        /*
         * Display the cell.
         */

        sts = gr$display_object(object_id = &symbol_id,
                                md_env    = md_env,
                                mode      = GRbd);
        /*
         * Make the original lib and cell active.
         */
        if(originl_lib) {
          sts = gr$symretrieve_cell_library (
                 filename    = ori_file.file_name,
                 file_no     = &ori_file.file_no,
                 flag        = EX_read_write | EX_read_only,
                 file_access = &ori_file.file_access,
                 fstat       = EX_old_module);
          om_msg = gr$symput_asl ( msg = msg, file = &ori_file);
        }

        if(original_sy){
            om_msg = gr$symsd_locate_in_all_sl ( msg     = msg,
                                                 sd_name = original_sy,
                                                 sl_env  = &sl_env,
                                                 sd_id   = &symbol_id);

            om_msg = gr$symput_active_symbol ( msg         = msg,
                                               symbol_name = original_sy, 
                                               symbol_id   = &symbol_id,
                                               asl_env     = &sl_env);
        }

	wrapup :
                _FREE( original_sy );
                _FREE( originl_lib );
		return *msg & 1 ;

}
