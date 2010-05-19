
/* $Id: VDdrwlo_int.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/VDdrwlo_int.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_int.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/06/07  21:15:16  pinnacle
 * Created: vdinclude/VDdrwlo_int.h by tdumbach for vds.240
 *
 * Revision 1.2  1995/05/10  21:57:46  pinnacle
 * Replaced: vdinclude/VDdrwlo_int.h by hverstee r#
 *
 * Revision 1.1  1995/04/18  21:25:28  pinnacle
 * Created: vdinclude/VDdrwlo_int.h by tdumbach r#
 * rno
 *
 * Revision 1.3  1995/03/25  15:31:40  pinnacle
 * Replaced: vdinclude/VDdrwlo_int.h by hverstee r#
 *
 * Revision 1.1  1995/03/03  21:08:30  pinnacle
 * Created: vdinclude/VDdrwlo_int.h by hverstee r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            include file to define DRWlo private
 *                                       (internal) structs and constants
 *
 * -------------------------------------------------------------------*/

#ifndef  VDdrwlo_int_h

#define  VDdrwlo_int_h

/* ----------------------------------------------------------------------- */

/*   PRIVATE:    DB and instance structures             */

struct   VDdrwlo_ins_col {          /*  INSTANCE column data   */
  IGRdouble                 col_x1;
  IGRdouble                 col_x2;
  IGRshort                  col_lns;

  struct  VDdrwlo_db_col    col_db;
                         };

struct   VDdrwlo_ins_htf {           /*  INSTANCE   htf data   */
  IGRdouble                 htf_x1;
  IGRdouble                 htf_y1;
  IGRdouble                 htf_x2;
  IGRdouble                 htf_y2;
  IGRshort                  htf_lns;

  struct  VDdrwlo_db_htf    htf_db;
                         };

/*      PRIVATE  function prototypes      */

/*   functions to place textstrings inside a field declaration     */
/*   Calculate/adjust x and y offsets                              */

/*   returns three x coordinates for a field (left/center/right justified)  */

extern IGRint  VD_drwlo_getx (IGRshort         nGrptyp,
                       struct VDdrwlo_ins_col *pCol,
                       struct VDdrwlo_ins_htf *pHtf,
                              IGRdouble       *dX);

/*   returns nlin y coordinates for a field (vertical column arrangement)*/

extern IGRint  VD_drwlo_gety (IGRshort         nGrptyp,
                       struct VDdrwlo_ins_col *pCol,
                       struct VDdrwlo_ins_htf *pHtf,
                              IGRshort         nLin,
                              IGRdouble       *dY);

extern IGRint  VD_drwlo_gtty (IGRdouble        dHGT,
                              IGRdouble        dSPC,
                              IGRshort         nLIN,
                              IGRdouble        dFHGT,
                              IGRdouble       *dY);

extern void    VD_drwlo_malg (struct VDdrwlo_db_alg  *Aout,
                              struct VDdrwlo_db_alg  *Ain);

extern void    VD_drwlo_mcol (struct VDdrwlo_db_col  *Cout,
                              struct VDdrwlo_db_col  *Cin);

extern void    VD_drwlo_mfld (struct VDdrwlo_db_fld  *Fout,
                              struct VDdrwlo_db_fld  *Fin);

extern void    VD_drwlo_mhtf (struct VDdrwlo_db_htf  *Hout,
                              struct VDdrwlo_db_htf  *Hin);

extern IGRboolean  VD_drwlo_calg (IGRshort         nGrptyp,
                                  IGRshort         nAlign,
                           struct VDdrwlo_db_alg  *Alg);

extern IGRboolean  VD_drwlo_ccol (IGRshort         nColno,
                           struct VDdrwlo_db_col  *Cin);

extern IGRboolean  VD_drwlo_chtf (IGRshort         nGrptyp,
                                  IGRchar         *pFieldid,
                           struct VDdrwlo_db_htf  *Hin);

extern IGRboolean  VD_drwlo_cfld (IGRshort         nGrptyp,
                                  IGRshort         nColno,
                                  IGRchar         *pFieldid,
                                  IGRshort         nLinseq,
                           struct VDdrwlo_db_fld  *Fin);

#endif
