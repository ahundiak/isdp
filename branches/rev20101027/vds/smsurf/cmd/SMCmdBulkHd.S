/* $Id: SMCmdBulkHd.S,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        smsurf/cmd/SMCmdBulkHd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMCmdBulkHd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/06  21:18:02  pinnacle
# Created: smsurf/cmd/SMCmdBulkHd.S by jwfrosch for vds.241
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *************************************************************************/

class specification SMCmdBulkHd (1:0) of SMCmdSurf;

instance SMCmdBulkHd
{
  struct GRobj_env	point;
  char			dir_axis;
  char			x_axis;
  IGRdouble		hight;
  IGRdouble		len1;
  IGRdouble		len2;
  IGRdouble		rad1;
  IGRdouble		rad2;
  IGRdouble		period;

  struct GRobj_env	old_point;
  char			old_dir_axis;
  char			old_x_axis;
  IGRdouble		old_hight;
  IGRdouble		old_len1;
  IGRdouble		old_len2;
  IGRdouble		old_rad1;
  IGRdouble		old_rad2;
  IGRdouble		old_period;
};

override reset_all;

message store_occ (	long * sts );

override save_all;

message clear_form (	long * sts );

message store_point (	long * sts );

override DispAll;

override SMmodif_mac;

override init_all;

override delete_all;

override form_notification;

end specification SMCmdBulkHd;
