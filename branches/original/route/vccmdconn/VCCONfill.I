
/* $Id: VCCONfill.I,v 1.3 2002/05/08 15:48:24 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONfill.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONfill.I,v $
 *     Revision 1.3  2002/05/08 15:48:24  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.2  2001/02/20 01:10:11  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:29  cvs
 *     Initial import to CVS
 *
# Revision 1.2  1999/02/18  17:59:50  pinnacle
# Replaced: vccmdconn/VCCONfill.I for: CR 179701619 by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:08:36  pinnacle
# Replaced: vccmdconn/VCCONfill.I for:  by r250_int for route
#
# Revision 1.6  1997/11/17  23:19:12  pinnacle
# Replaced: vccmdconn/VCCONfill.I for:  by kddinov for cabling
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.4  1997/01/24  00:10:42  pinnacle
# Replaced: vccmdconn/VCCONfill.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/18  18:55:40  pinnacle
# Replaced: vccmdconn/VCCONfill.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:55:48  pinnacle
# Replaced: vccmdconn/VCCONfill.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:32:12  pinnacle
# Created: vccmdconn/VCCONfill.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *
 *    Feb 18, 1999	Anand		Conditionally display 'View jumper'
 *    					button, an asterisk ('*') against every
 *    					terminal pin that is connected to a
 *    					jumper whose 'cnt_vs_max' attribute is
 *    					set to 'y'. Fill all the jumper details
 *    					in the Review Terminal Connections form.
 *
 * -------------------------------------------------------------------*/

class implementation VCCmdCON;

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define MY_DEBUG 1
#define vdsDEBUG 1
*/
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "vc_structs.h"
#include "VCstructs2.h"
#include "VCCmdCON.h"
#include "VCCmdPJ.h"

from VCTerm	import	VCGetJumpInstance, VCGetNumJumpCabOnTermPin;


/*=======================================================================*/

method VCCONFillForm ()
{
  IGRint              status;
  IGRint              i;
  IGRchar            *fptr, Old_szModId[VC_MAX_MOD_ID];

  IGRint              nNbJumper;
  IGRlong             retmsg;


  SetProc(VCCONFillForm); Begin;

  __DBGpr_int("Dimension of form pointer",om$dimension_of(varray=me->forms) );

  fptr               = me->forms[0].form_ptr;

  status =
  om$send (msg = message VCCmdCON.VCCONactv (fptr, -1, -1, -1),
      targetid = my_id);

  FIg_set_text (fptr, VC_CONGDG_TERMTAG, me->szTag);
  FIg_set_text (fptr, VC_CONGDG_EQTAG, me->szEqT);

  /*A fill the conn positions field */
  FIfld_set_max_num_rows (fptr,VC_CONGDG_STAB, me->nMaxCon);
  FIfld_set_max_num_rows (fptr,VC_CONGDG_MTAB, me->nMaxCon);
  FIfld_set_max_num_rows (fptr,VC_CONGDG_CNDLIST,me->nMaxCnd);

	/* Decide whether to display 'View Jumper' Gadget */
  status = om$send ( msg = message VCTerm.VCGetJumpInstance( &retmsg, NULL,
                                                             &nNbJumper, NULL ),
                targetid = me->RefId.objid ,
                targetos = me->RefId.osnum );
  as$status();

  if( nNbJumper )
      FIg_display( fptr, VC_CONGDG_VIEWJUMP );
  else
      FIg_erase( fptr, VC_CONGDG_VIEWJUMP );

  __DBGpr_int(" Jumpers in this terminal?", nNbJumper);

  if (me->bICB)
  {
    for (i=0; i<me->nNumConTab; i++)
    { /*A   fill flattened thruconnect fields   */
      /*  after reset, redisplay table ..... */

      FIg_display (fptr, VC_CONGRP_MULT);

      /*A set the text in the two columns     */
      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_SIG1,
                        me->ConSig1[i].sig , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MARK1,
                        me->ConSig1[i].marker , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_CAB1,
                        me->ConTab1[i].Ctag , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_LEAD1,
                        me->ConTab1[i].ps.Conn.Cable.szLeadId , FALSE);

	 /* Decide whether to display asterisk against terminal pin */
      if( nNbJumper )
      {
	  struct VCPinConnect	TermPin;
	  IGRchar		szPosId[VC_MAX_POS_ID];

	  strcpy(TermPin.PinId.szModId,me->PosTab[i].pDef.Conn.Term.szModId);
	  strcpy(TermPin.PinId.szPosId,me->PosTab[i].pDef.Conn.Term.szPosId);
	  strcpy(szPosId,me->PosTab[i].pDef.Conn.Term.szPosId);

	  __DBGpr_com(" Checkin if this pin is connected to a jumper.");
	  __DBGpr_str(" Term mod",TermPin.PinId.szModId);
	  __DBGpr_str(" Term Pos",TermPin.PinId.szPosId);

	  status = om$send ( msg = message VCTerm.VCGetNumJumpCabOnTermPin
						     ( &retmsg, &TermPin ),
			targetid = me->RefId.objid,
			targetos = me->RefId.osnum );
	  as$status();

	  __DBGpr_int(" Num Cable leads on pin",TermPin.NumConnect);
	  __DBGpr_int(" Num Jumpers on pin",TermPin.NumJumpers);
	  __DBGpr_int(" DB max limit of pin",TermPin.DBlimit);

	  if(TermPin.NumJumpers)
	      strcat(szPosId,"*");

	  __DBGpr_str(" Pos to be displayed",szPosId);
	  FIfld_set_text( fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MPOS1,
			  szPosId, FALSE);
      }
      else
      {
	  FIfld_set_text( fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MPOS1,
			  me->PosTab[i].pDef.Conn.Term.szPosId, FALSE);
      }



	/*---- KDD 11-97 Make it user friendly for szModId ----*/

      if ( strcmp(me->PosTab[i].pDef.Conn.Term.szModId, Old_szModId) )
      {
           FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MMOD,
                        me->PosTab[i].pDef.Conn.Term.szModId , FALSE);

	   strcpy( Old_szModId , me->PosTab[i].pDef.Conn.Term.szModId );
      }
      else
      {
	   FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MMOD,"",FALSE);
      }


	 /* Decide whether to display asterisk against terminal pin */
      if( nNbJumper )
      {
	  struct VCPinConnect	TermPin;
	  IGRchar		szPosId[VC_MAX_POS_ID];

	  strcpy(TermPin.PinId.szModId,me->PosTab[i].pAlt.Conn.Term.szModId);
	  strcpy(TermPin.PinId.szPosId,me->PosTab[i].pAlt.Conn.Term.szPosId);
	  strcpy(szPosId,me->PosTab[i].pAlt.Conn.Term.szPosId);

	  __DBGpr_com(" Checkin if this pin is connected to a jumper.");
	  __DBGpr_str(" Term mod",TermPin.PinId.szModId);
	  __DBGpr_str(" Term Pos",TermPin.PinId.szPosId);

	  status = om$send ( msg = message VCTerm.VCGetNumJumpCabOnTermPin
						     ( &retmsg, &TermPin ),
			targetid = me->RefId.objid,
			targetos = me->RefId.osnum );
	  as$status();

	  __DBGpr_int(" Num Cable leads on pin",TermPin.NumConnect);
	  __DBGpr_int(" Num Jumpers on pin",TermPin.NumJumpers);
	  __DBGpr_int(" DB max limit of pin",TermPin.DBlimit);

	  if(TermPin.NumJumpers)
	      strcat(szPosId,"*");

	  __DBGpr_str(" Pos to be displayed",szPosId);
	  FIfld_set_text( fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MPOS2,
			  szPosId, FALSE);
      }
      else
      {
	  FIfld_set_text(fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MPOS2,
			 me->PosTab[i].pAlt.Conn.Term.szPosId , FALSE);
      }


      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_LEAD2,
                        me->ConTab2[i].ps.Conn.Cable.szLeadId , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_CAB2,
                        me->ConTab2[i].Ctag , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_SIG2,
                        me->ConSig2[i].sig , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_MTAB, i, VC_CONCOL_MARK2,
                        me->ConSig2[i].marker , FALSE);
    }
  }
  else
  {
    for (i=0; i<me->nNumConTab; i++)
    { /*A  fill reular columnar fields   */

      /*  after reset, redisplay table ..... */

      FIg_display (fptr, VC_CONGRP_SING);

      FIfld_set_text (fptr, VC_CONGDG_STAB, i, VC_CONCOL_SMOD,
                        me->PosTab[i].pDef.Conn.Term.szModId , FALSE);

	 /* Decide whether to display asterisk against terminal pin */
      if( nNbJumper )
      {
	  struct VCPinConnect	TermPin;
	  IGRchar		szPosId[VC_MAX_POS_ID];

	  strcpy(TermPin.PinId.szModId,me->PosTab[i].pDef.Conn.Term.szModId);
	  strcpy(TermPin.PinId.szPosId,me->PosTab[i].pDef.Conn.Term.szPosId);
	  strcpy(szPosId,me->PosTab[i].pDef.Conn.Term.szPosId);

	  __DBGpr_com(" Checkin if this pin is connected to a jumper.");
	  __DBGpr_str(" Term mod",TermPin.PinId.szModId);
	  __DBGpr_str(" Term Pos",TermPin.PinId.szPosId);

	  status = om$send ( msg = message VCTerm.VCGetNumJumpCabOnTermPin
						     ( &retmsg, &TermPin ),
			targetid = me->RefId.objid,
			targetos = me->RefId.osnum );
	  as$status();

	  __DBGpr_int(" Num Cable leads on pin",TermPin.NumConnect);
	  __DBGpr_int(" Num Jumpers on pin",TermPin.NumJumpers);
	  __DBGpr_int(" DB max limit of pin",TermPin.DBlimit);

	  if(TermPin.NumJumpers)
	      strcat(szPosId,"*");

	  __DBGpr_str(" Pos to be displayed",szPosId);
	  FIfld_set_text( fptr, VC_CONGDG_STAB, i, VC_CONCOL_SPOS,
			  szPosId, FALSE);
      }
      else
      {
	  FIfld_set_text(fptr, VC_CONGDG_STAB, i, VC_CONCOL_SPOS,
			 me->PosTab[i].pDef.Conn.Term.szPosId , FALSE);
      }


      FIfld_set_text (fptr, VC_CONGDG_STAB, i, VC_CONCOL_LEAD,
                        me->ConTab1[i].ps.Conn.Cable.szLeadId , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_STAB, i, VC_CONCOL_CAB,
                        me->ConTab1[i].Ctag , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_STAB, i, VC_CONCOL_SIG,
                        me->ConSig1[i].sig , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_STAB, i, VC_CONCOL_MARK,
                        me->ConSig1[i].marker , FALSE);
    }
  } /* end fill list */

     /*A fill the free connect candidates field */

  for (i=0; i<me->nCndNum; i++)
  { /*A set the text in the two columns     */

      FIfld_set_text (fptr, VC_CONGDG_CNDLIST, i, VC_CNDCOL_LEAD,
                        me->CndTab[i].ps.Conn.Cable.szLeadId , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_CNDLIST, i, VC_CNDCOL_CAB,
                        me->CndTab[i].Ctag , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_CNDLIST, i, VC_CNDCOL_SIG,
                        me->CndSig[i].sig , FALSE);
      FIfld_set_text (fptr, VC_CONGDG_CNDLIST, i, VC_CNDCOL_MARK,
                        me->CndSig[i].marker , FALSE);
  }

  if (me->Product == VC_PROD_FO)
  {
    FIg_display (fptr, VC_CONGDG_CONTXT);
    FIg_display (fptr, VC_CONGDG_CONFLD);
  }

  me->bRedisplay = FALSE;


      /*****************************************************************/
      /******** ALSO SET THE 'REVIEW TERMINAL CONNECTIONS' FORM ********/
      /*****************************************************************/

  fptr = me->forms[1].form_ptr;

  if( nNbJumper )
  {
      void	*TempData, *TempConn;

      status = om$send( msg = message VCTerm.VCGetJumpInstance( &retmsg,
								&TempData,
								&nNbJumper,
								&TempConn ),
		   targetid = me->RefId.objid ,
		   targetos = me->RefId.osnum );
      as$status();

      /***************************************************************/
      /* The following lines of code assumes the offset type to be 1 */
      /***************************************************************/
      {
	  struct VCJumpData	*JumpData;
	  struct VCJumpConn	*JumpConn;
	  IGRint		NumPinsTerm=0;

	  JumpData = (struct VCJumpData *) TempData;
	  JumpConn = (struct VCJumpConn *) TempConn;

	  for( i=0 ; i<nNbJumper ; i++ )
	  {
	      __DBGpr_int(" Jumper ID",(JumpData+i)->JumperId );
	      __DBGpr_str(" Jumper code", (JumpData+i)->jump_code);
#ifdef vdsDEBUG
	      printf("Material Take off: %c, Count against MAX: %c\n",
						(JumpData+i)->no_mto_flag,
						(JumpData+i)->cnt_vs_max );
#endif
	      __DBGpr_str(" Remarks: ",(JumpData+i)->remarks);
	      __DBGpr_int(" No. of terminal pins",(JumpData+i)->NumTermPins);

	      NumPinsTerm += (JumpData+i)->NumTermPins;
	  }

	  __DBGpr_int(" Total number of rows in MC field",NumPinsTerm);
	  FIfld_set_num_rows( fptr, VCVJ_JUMPFLD, NumPinsTerm);

	  for( i=0 ; i<NumPinsTerm ; ++i )
	  {
	      __DBGpr_int(" Jumper ID",(JumpConn+i)->JumperId );

	      if( ( i==0 ) || ( i>0 &&
		  (JumpConn+i)->JumperId != (JumpConn+i-1)->JumperId ) )
	      {
		  IGRint	jmp_i;

		      /* Query for jumper id to get jumper code */
		  for( jmp_i=0 ; jmp_i<nNbJumper ; jmp_i++ )
		      if( (JumpConn+i)->JumperId
					   == (JumpData+jmp_i)->JumperId )
			  break;

		  __DBGpr_str(" Jumper code for this jumper ID",
					 (JumpData+jmp_i)->jump_code);
		  FIfld_set_text( fptr, VCVJ_JUMPFLD, i, 0,
				  (JumpData+jmp_i)->jump_code, FALSE);
	      }
	      else
		  FIfld_set_text( fptr, VCVJ_JUMPFLD, i, 0, "", FALSE);

	      __DBGpr_str(" Terminal Module", (JumpConn+i)->Mod );
	      FIfld_set_text( fptr, VCVJ_JUMPFLD, i, 1,
						   (JumpConn+i)->Mod, FALSE);

	      __DBGpr_str(" Terminal Position", (JumpConn+i)->Pos );
	      FIfld_set_text( fptr, VCVJ_JUMPFLD, i, 2,
						   (JumpConn+i)->Pos, FALSE);
	  }
      }
      /***********************************************************/
      /* The above lines of code assumes the offset type to be 1 */
      /***********************************************************/

      _FREE( TempData );
      _FREE( TempConn );
  }

  End
  return OM_S_SUCCESS;

}

end implementation VCCmdCON;
