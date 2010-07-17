
/* $Id: VCDBjumperi.I,v 1.2 2001/02/20 01:10:35 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vcdbattr / VCDBjumperi.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCDBjumper class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBjumperi.I,v $
 *        Revision 1.2  2001/02/20 01:10:35  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1999/01/19  09:30:02  pinnacle
# Created: vcdbattr/VCDBjumperi.I  by aharihar for route
#
 *
 * History:
 *        10/01/98        Alwin         Initial
 *
 *************************************************************************/

class implementation VCDBjumper;

#include "VCDBpar.h"
#include "VCCmdPJ.h"
#include "VCdbaccess.h"
#include "vrdbgmacros.h"

method VCGetAttr (IGRlong         *msg;
           struct VCpos           *Posdef;
                  IGRchar         *szAttNam;
           struct ret_struct      *res)

{
  IGRint      status;
  IGRshort    nIndex, nAtt;
  IGRshort    nMAP;

  SetProc( Md VCGetAttr ); Begin 

  __DBGpr_str( " Attribute Name ", szAttNam );
  nAtt = VCDB_AttrNamToNum (szAttNam);

  __DBGpr_int( " Attribute Number ", nAtt );

  if (nAtt >= 0)
  {
    status =
    om$send (msg = message VCDB.VCGpAnum
                      (msg, nIndex, nMAP, nAtt, res),
        targetid = my_id);
  }
  else
  {
    status = OM_S_SUCCESS;
    *msg   = MSFAIL;

    status =
    om$send (msg = message VCDBgen.VCGpAnum (msg, nIndex, nMAP, nAtt, res),
            mode = OM_e_wrt_message,
        targetid = my_id);
  }

  End
  return (status);
}

method  VCGpAnum  (IGRlong         *msg;
                   IGRshort         nIndex;
                   IGRshort         nMAP;
                   IGRint           nAttnum;
            struct ret_struct      *res)
{
  IGRint        status;
  IGRshort      nEnt;

  SetProc( Md VCGpAnum ); Begin 

  *msg = MSFAIL;
  /***
  nEnt = om$dimension_of (varray = me->Jumper);
  ***/

  if ( nAttnum == VC_X_JUMP_MAX_POSITION )
  {
    *msg = MSSUCC;

    __DBGpr_int( " Maximum Position for Jumper ", me->Jumper.max_position );
    res->type = double_type;
    res->var.root_pm_st.value = me->Jumper.max_position;
  }
  else
  {
    *msg = MSSUCC;

     __DBGpr_com( " Call the superclass implementation " );
     status = om$send ( msg = message VCDBgen.VCGpAnum
			 ( msg, nIndex, nMAP, nAttnum, res ),
		mode = OM_e_wrt_message,
		targetid = my_id );
  }

  End
  return (OM_S_SUCCESS);
}

method VCDB_init (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  SetProc( Md VCDB_init ); Begin 

  status =
  om$send ( msg = message VCDBgen.VCDB_init ( msg, Tabrec ),
          mode = OM_e_wrt_message,
      targetid = my_id );

  /* Initializing the extension variables
  me->Jumper.Extend1 = NULL;
  me->Jumper.Extend2 = NULL;
     Initializing the extension variables */

  End
  return (OM_S_SUCCESS);
}

method VCDB_ghdr (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  SetProc( Md VCDB_ghdr ); Begin 

  status =
  om$send (msg = message VCDBgen.VCDB_ghdr (msg, Tabrec),
          mode = OM_e_wrt_message,
      targetid = my_id);

  //strcpy (Tabrec->Macro_name, me->DBMain.Macro_name);

  End
  return (OM_S_SUCCESS);
}

method  VCDB_fill (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow=0;
  IGRchar        szWhere[60];
  IGRint         iRow;
  IGRint         iDsp;

  SetProc( Md VCDB_fill ); Begin 

  *msg = MSFAIL;
  DbIO = NULL;

  /*   construct key (where clause)    */

  strcpy (szWhere, VC_DBK_CODE);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->DBMain.Compcode);
  strcat (szWhere, "\'");

#ifdef MY_DEBUG
  printf ("Load elterm %s\n", szWhere);
#endif

  /*   load cable record    */

  status=
  vdb$RisSelect (select     = VC_DBS_JUMPER,
                 table_name = VC_DBT_JUMPER,
                 where      = szWhere,
                 numselect  = VC_DBN_ELTERM,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_ELTERM, szWhere);
    goto L_ABORT;
  }

  VCDBstr (me->DBMain.OwnerId,     DbIO[0]);
  VCDBstr (me->DBMain.Timest,      DbIO[1]);
  VCDBstr (me->DBMain.Short_desc,  DbIO[2]);
  VCDBstr (me->DBMain.Standard,    DbIO[3]);
  VCDBstr (me->DBMain.Environment, DbIO[4]);
  VCDBstr (me->DBMain.Fire_resist, DbIO[5]);
  VCDBstr (me->DBMain.Security,    DbIO[6]);
  VCDBstr (me->DBMain.Desc,        DbIO[7]);
  VCDBstr (me->DBMain.Vendor,      DbIO[8]);
  VCDBstr (me->DBMain.Catalog,     DbIO[9]);
  VCDBstr (me->DBMain.Stockno,     DbIO[10]);

  /* Jumper max_position values needs to be stored in Jumper Structure */
  __DBGpr_str( " max_position for the Jumper ", DbIO[11] );
  __DBGpr_int( " max_position for the Jumper ", VCDBint( DbIO[11] )) ;

  me->Jumper.max_position = VCDBint( DbIO[11] ); 

  __DBGpr_int( " max_position for the Jumper ", me->Jumper.max_position );

  me->DBMain.Weight    = VCDBdbl (DbIO[12]);
  me->DBMain.Unit_Cost = VCDBdbl (DbIO[13]);
  me->DBMain.Gn_data_1 = VCDBdbl (DbIO[14]);
  me->DBMain.Gn_data_2 = VCDBdbl (DbIO[15]);
  me->DBMain.LcUnit    = VCDBint (DbIO[16]);

  me->DBMain.Local     = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  /**
  status =
  om$vla_set_dimension (varray = me->Jumper,
                        size   = NbRow);
  **/

  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

  L_ABORT:
  End
  return (status);
}

end implementation VCDBjumper;
