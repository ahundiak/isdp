
/* $Id: VRXunits.I,v 1.5 2002/04/10 19:55:59 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:.vrpdu / VRXunits.I
 *
 * Description:
 *      All units accessing functions  
 *       (replaces VRPDUunits.c)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRXunits.I,v $
 *      Revision 1.5  2002/04/10 19:55:59  louis
 *      TR5649-standardize tolerances
 *
 *      Revision 1.4  2001/09/12 21:59:49  anand
 *      Regression of TR 5548
 *
 *      Revision 1.3  2001/09/04 22:33:16  anand
 *      JTS TR MP 5548
 *
 *      Revision 1.2  2001/02/20 01:15:22  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/05/04  13:51:14  pinnacle
# Replaced: vrpdu/VRXunits.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/19  10:40:58  pinnacle
# Replaced: vrpdu/VRXunits.I for:  by apazhani for route
#
# Revision 1.1  1997/08/15  19:43:16  pinnacle
# Created: vrpdu/VRXunits.I by hverstee for route
#
 *
 * History:
 *      01/17/96   tlb      Add prototypes
 *      12/19/97   Alwin    Modified get_allowed_npd
 *
 *      05/04/99    Reddy       Doble value comparision corrected
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

class implementation Root;

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "msdef.h"

#include "VDmem.h"
#include "VDDbDef.h"
#include "vdbmacros.h"
#include "vrdbgmacros.h"

#include "VRDbStruct.h"
#include "VRmsg.h"
#include "VRDbTbl.h"
#include "VRMath.h"
#include "vrpdu_pto.h"

#include "VRPDBdef.h"
#include "VRPDBmac.h"

extern IGRdouble   fabs();

/*
#define MY_DEBUG
*/

/**************************************************************/
/*       NEW GLOBAL DEFINITIONS                               */

#if ISDP_MAKE_SP
extern
#endif
struct VRPDB_project   VRGL_PROJ;

#if ISDP_MAKE_SP
extern
#endif
IGRint                 VRGL_specunit;

/* -----------------------------------*/
/*   and leave this garbage here      */
/*   until VRiso has been rectified   */

#if ISDP_MAKE_SP
extern
#endif
int   prj_units_set;

/**************************************************************/
/*   new static buffers for VDS convert/units                 */
%safe
static
IGRshort   nnCON = 0;
static
IGRshort   nnUNI = 0;

static
struct VDSunits   *pUNIT = NULL;

static
struct VDSconvert *pCONV = NULL;
%endsafe
/**************************************************************/

static
void   VR_LD_unit ()
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;

  Num  = 4;
  DbIO = NULL;

  if (VdsVerifyRisTable (VRDB_VDSUNITS_TBL)!= VDS_DBTABLE_FOUND) return;

  status =
  vdb$RisSelect (select     = "*",
                 table_name = VRDB_VDSUNITS_TBL,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    pUNIT = _MALLOC (NbRow, struct VDSunits);
    if (pUNIT == NULL) return;

    for (i=0; i<NbRow; i++)
    {
      VRDBstr (pUNIT[i].param_name, DbIO[i*Num]);

      pUNIT[i].units_set  = VRDBint (DbIO[i*Num + 1]);
      pUNIT[i].units_code = VRDBint (DbIO[i*Num + 2]);
      pUNIT[i].resolution = VRDBdbl (DbIO[i*Num + 3]);
    }

    nnUNI = NbRow;
  }

  if (DbIO != NULL)
    VdsRisFreeBuffer (DbIO, NbRow);

  return;
}


static
void   VR_LD_conv ()
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRint         i;
  IGRint         Num;

  Num  = 5;
  DbIO = NULL;

  if (VdsVerifyRisTable (VRDB_VDSCONVERT_TBL)!= VDS_DBTABLE_FOUND) return;

  status =
  vdb$RisSelect (select     = "*",
                 table_name = VRDB_VDSCONVERT_TBL,
                 numselect  = Num,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (status & OM_S_SUCCESS)
  {
    pCONV = _MALLOC (NbRow, struct VDSconvert);
    if (pCONV == NULL) return;

    for (i=0; i<NbRow; i++)
    {
      pCONV[i].units_in     = VRDBint (DbIO[i*Num]);
      pCONV[i].units_out    = VRDBint (DbIO[i*Num + 1]);

      pCONV[i].cnvr_fctr    = VRDBdbl (DbIO[i*Num + 2]);
      pCONV[i].cnvr_offset  = VRDBdbl (DbIO[i*Num + 3]);
      pCONV[i].rnd_off_fctr = VRDBdbl (DbIO[i*Num + 4]);

    }

    nnCON = NbRow;
  }

  if (DbIO != NULL)
    VdsRisFreeBuffer (DbIO, NbRow);

  return;
}




/**************************************************************/
/*    clear cache function                                    */

void VR_DbC_Clunt ()
{

  _FREE (pUNIT);
  _FREE (pCONV);

  nnCON = 0;
  nnUNI = 0;

  return;
}
/**************************************************************/


IGRint  VR_units_def (char    *par_name,
                      int      units_set_in,
                      int      units_set_out,
                      int     *units_in,
                      int     *units_out,
                      double  *resolution)
{
  IGRint      i;

  *units_in     = 0;
  *units_out    = 0;
  *resolution   = 0;

  if (nnUNI == 0)   VR_LD_unit ();
  if (nnCON == 0)   VR_LD_conv ();

  if((!strcmp(par_name,"thickness")))
          *units_in = units_set_in;
  else
  {
    for( i = 0; i < nnUNI; i++ )
    {
      if((strcmp(pUNIT[i].param_name, par_name) == 0 ) &&
                (pUNIT[i].units_set == units_set_in ))
      {
         *units_in = pUNIT[i].units_code;
         break;
      }
    }
  }

  for( i = 0; i < nnUNI; i++ )
  {
    if ((strcmp(pUNIT[i].param_name, par_name) == 0 ) &&
               (pUNIT[i].units_set == units_set_out ))
    {
        *units_out  = pUNIT[i].units_code;
        *resolution = pUNIT[i].resolution;
        break;
    }
  }

  return (OM_S_SUCCESS);
}


/**************************************************************/

int     Get_piping_spec_units(int      proj_no,
                              char    *name,          /*  spec name  */
                              char    *err_ptr)
{
  IGRlong   retmsg;
  IGRshort  NN,ii;
  char     *ep;

  struct VRPDB_spec_key  YY;
  struct VRPDB_spec      XX;

  ii      = proj_no;                /*    NOT USED    */
  ep      = err_ptr;                /*    NOT USED    */

  strcpy (YY.spec_name, name);
  YY.spec_no = VRPDB_UNDEF;

  VR$PDB_SPEC (p_msg = &retmsg,
               keyin = &YY,
               p_num = &NN,
               p_rec = &XX);

  if ((NN == 0) || (retmsg != MSSUCC)) return (0);

  VRGL_specunit  = XX.data.units;

  return  1;
}

double  converted_to_vds (char    *par_name,
                          int      units_set_in,
                          int      units_set_out,
                          double   old_value,
                          char    *err_ptr)

{
  int         i;
  int         units_in, units_out;
  double      cnvr_fctr, cnvr_offset, rnd_off_fctr, resolution;
  double      new_value1, new_value;
  char     *ep;

  ep      = err_ptr;                /*    NOT USED    */

  VR_units_def (par_name, units_set_in, units_set_out,
                &units_in, &units_out, &resolution);

  if( units_in == units_out )  return old_value;

  cnvr_fctr    = 1;
  cnvr_offset  = 0;
  rnd_off_fctr = 0;

  for( i=0; i < nnCON; i++ )
  {
    if(( pCONV[i].units_in == units_in ) &&
        (pCONV[i].units_out == units_out ))
    {
      cnvr_fctr    = pCONV[i].cnvr_fctr; 
      cnvr_offset  = pCONV[i].cnvr_offset;
      rnd_off_fctr = pCONV[i].rnd_off_fctr; 
      break;
    }
  }

  new_value1 = old_value * cnvr_fctr + cnvr_offset;

  if( fabs(new_value1) < VRGetTol(VR_DIST_TOL))
    new_value = new_value1;
  else
    correct_wrt_resol( new_value1, resolution, &new_value );

  return  new_value;
}

double  get_allowed_npd (int      prj_units_set,
                         int      pip_spec_units,
                         double   old_value,
                         char    *spec_name,
                         int      proj_no,
                         char    *err_ptr)

{
  IGRlong      retmsg;
  IGRshort     snum;
  IGRshort     NN;
  int          i;
  int          units_in,units_out;
  double       new_value;
  double       resolution;
  char        *ep;

  struct VRPDB_npd   *XX;

  SetProc( Fn get_npd_allowed ); Begin

  i          = proj_no;            /*   NOT USED    */
  ep         = err_ptr;            /*   NOT USED    */
  XX         = NULL;

  new_value  = 0;

  __DBGpr_dbl( " old_value ", old_value );

  VR_units_def ("npd_g", prj_units_set, pip_spec_units,
                &units_in, &units_out, &resolution);

  __DBGpr_int( " Units_in ", units_in );
  __DBGpr_int( " Units_out ", units_out );

  if(units_in == units_out )
  {
     __DBGpr_com( " unit_in=units_out, returning old_value " );
     End
     return (old_value);
  }

  VR$PDB_SNUM (p_nam = spec_name,
               p_num = &snum);

  VR$PDB_NPD  (p_msg = &retmsg,
               spec  = snum,
               p_num = &NN);

  XX = _MALLOC (NN, struct VRPDB_npd);

  __CheckPtr( XX, "Allocation Error", quit );

  VR$PDB_NPD  (p_msg = &retmsg,
               spec  = snum,
               p_num = &NN,
               p_rec = XX);

  if( units_out == 11 )
  {
    for (i=0; i<NN; i++)
    {
      /*BILLA  Double value comparison problem */
      if(fabs(XX[i].npd - old_value) < VRGetTol(VR_DIST_TOL))
      {
        new_value = XX[i].npd_eq;
        break;
      }
    }
  }
  else
  if( units_out == 1 )
  {
    __DBGpr_com( " units_out represent Imperial units " );
    for (i=0; i<NN; i++)
    {
      __DBGpr_dbl( " npd_eq ", XX[i].npd_eq );

      if ( fabs(XX[i].npd_eq-old_value) < VRGetTol(VR_DIST_TOL) )
      {
        new_value = XX[i].npd;
        __DBGpr_dbl( " new value ", new_value );
        break;
      }
    }
  }

  _FREE (XX);

quit:
  End
  return new_value;
}

int correct_wrt_resol (double   new_value1,
                       double   resolution,
                       double  *new_value)

{
  double   coeff;
  int  val1, val2, i=0;
  char  str_val[20], str1[6], str2[2];

  for(i=0; i < 6; i++)
    str1[i] = 0;
  i = 0;

  if( resolution <= 0.00001  || new_value1 < 0.00001)
    *new_value = new_value1;
  else
  {
    coeff = new_value1 / resolution;
    sprintf(str_val,"%f",coeff);
    while(str_val[i] != '.' )
    {
      str1[i] = str_val[i];
      i++;
    }
    i++;
    strncpy(str2,&str_val[i],1);
    val1 = VRDBint(str1);
    val2 = VRDBint(str2);
    if(val2 >= 5)
      coeff = (double)( val1 +1 );
    else
      coeff = (double) val1;  
    *new_value = (double)(coeff * resolution);
  }
  return 0;
}

int  VRenq_proj_units()
{
    IGRint	prj_units;
    extern int	VdsGetProjectUnits(IGRint *);

    /* Replace PDB macro call with generic VDS call. It is quicker and piping
     * stuff is not loaded when working in HVAC/Raceway. TR MP 5548 */
    VdsGetProjectUnits(&prj_units);

    /* Need to do this since the global is accessed all over. (Sic!) */
    VRGL_PROJ.prj_units = prj_units;

    if ((prj_units > 0) && (prj_units < 10))
	return VR_IMPERIAL_UNITS;

    if ((prj_units >= 10) && (prj_units < 20))
	return VR_MIXED_UNITS;

    if ((prj_units >= 20) && (prj_units < 30))
	return VR_METRIC_UNITS;

    return -1;
}

end implementation Root;
