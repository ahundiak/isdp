/* $Id: SMCmdSurf.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        smsurf/cmd/SMCmdSurf.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMCmdSurf.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/06  21:16:50  pinnacle
# Created: smsurf/cmd/SMCmdSurf.S by jwfrosch for vds.241
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

class specification SMCmdSurf (1:0) of VDS_LOCATE;

#include <stdio.h>
#include <string.h> 
#include "stdlib.h" 
#include "math.h"
#include "macro.h"

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "griodef.h" 
#include "griomacros.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "msdef.h"
#include "msmacros.h"

#include "SMmsg.h"

#include "FI.h"
#include "SMSurf.h"
#include "vdsmacros.h"


instance SMCmdSurf
{
  struct GRid 		frm_sys;
  struct GRid 		coord;
  struct GRid 		go_cs;
  struct GRmd_env	cs_env;
  IGRint		extension;
  IGRdouble		ext_x1;
  IGRdouble		ext_x2;
  IGRdouble		ext_y1;
  IGRdouble		ext_y2;
  IGRdouble		ext_z1;
  IGRdouble		ext_z2;
  char			def_name[MAX_CHAR];
  IGRint		reverse;

  struct GRid 		old_coord;
  struct GRid 		old_go_cs;
  IGRint		old_extension;
  IGRdouble		old_ext_x1;
  IGRdouble		old_ext_x2;
  IGRdouble		old_ext_y1;
  IGRdouble		old_ext_y2;
  IGRdouble		old_ext_z1;
  IGRdouble		old_ext_z2;
  char			old_def_name[MAX_CHAR];
  IGRint		old_reverse;

  struct GRid		macro_id;
  struct GRid		old_macro_id;
};

override init_all;

override delete_all;

message store_cs (	long		 *sts );

message DispAll (	enum GRdpmode	  mode);

message pos_cursor (	long		 *sts );

message verif_frame (	long		 *sts;
			struct GRobj_env *frame);

message verify_obj (	long		 *sts );

override GadgOn;

override GadgOf;

message stop_insert_mode (	long	  *sts );

message GetInfoFrmForm (	long	  *sts;
				IGRdouble *ext_x1;
				IGRdouble *ext_x2;
				IGRdouble *ext_y1;
				IGRdouble *ext_y2);

message SMMdCsAtt (	struct GRid	 *old_cs;
			struct GRid	 *old_rg;
			int		  nb_att; 
			struct ACrg_coll *ACrg;
			int		  nb_new;
			struct GRid	 *new;
			IGRboolean	 *put_batch);

message SMmodif_mac (	int		  nb_att;
			struct ACrg_coll *ACrg;
			int		  nb_new;
			struct GRid	 *new);

override verify_input_row;

override form_notification;

end specification SMCmdSurf;
