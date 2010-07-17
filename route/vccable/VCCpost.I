
/* $Id: VCCpost.I,v 1.4 2002/05/17 19:23:35 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable / VCCpost.I
 *
 * Description:
 *   Database post of connectivity info
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCpost.I,v $
 *        Revision 1.4  2002/05/17 19:23:35  anand
 *        Misc. bug fixes. Covers change rejects CR 5846 and 6040.
 *        Ensures that new sub-cables carry over signals of parent
 *        cables.
 *
 *        Revision 1.3  2002/05/08 15:48:22  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:09:06  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.6  1999/02/25  22:40:32  pinnacle
# Replaced: vccable/VCCpost.I for:  by apazhani for route
#
# Revision 1.5  1999/02/12  22:53:20  pinnacle
# Replaced: vccable/VCCpost.I for:  by lawaddel for route
#
# Revision 1.2  1998/10/08  16:38:44  pinnacle
# Replaced: vccable/VCCpost.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/20  04:04:48  pinnacle
# Replaced: vccable/VCCpost.I for:  by kddinov for route
#
# Revision 1.2  1998/04/01  20:31:34  pinnacle
# Replaced: vccable/VCCpost.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/10/24  12:24:04  pinnacle
# Replaced: vccable/VCCpost.I for:  by apazhani for cabling
#
# Revision 1.2  1997/07/14  22:32:26  pinnacle
# Replaced: vccable/VCCpost.I for:  by hverstee for cabling
#
# Revision 1.1  1996/11/01  21:20:52  pinnacle
# Created: vccable/VCCpost.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *      10/24/97    Alwin       Modified the VDPostYourselfToDb method to 
 *                              delete the vcdyn_elead & vcdyn_elead tables
 *                              properly. And added some attributes like 
 *                              "comp_seqno, assembly_cat, assembly_nam, 
 *                               assembly_rev, fromcino and tocino".
 *
 *	4-98	   KDD		single point default selector  
 *	 			VCGetDefaultProdInfo
 *      10/08/98   Alwin        Reverted back to old way of obtaining the
 *                              dynacmic table. TR179801987
 *      12/31/98   law          CR179802489-add new values for posting
 *      02/12/99   law          TR179802033-errors in posting splices
 *      02/25/99   Alwin        Changed the type of the variable from int->long
 *
 *************************************************************************/

class implementation VCCable;

#include <stdlib.h>
#include <string.h>
#include "ACrg_collect.h"
#include "VDSpdudef.h"
#include "VDScheckin.h"
#include "VDScheckdef.h"
#include "VDSris_def.h"
#include "VDSris_siz.h"
#include "VDDbtbldef.h"
#include "VDsa.h"
#include "vdbmacros.h"

#include "vc_dbpar.h"
#include "vc_param.h"
#include "VCDBpar.h"
#include "VCdbstructs.h"
#include "VCdbaccess.h"
#include "VCdbpost.h"
#include "vc_define.h"
#include "parametric.h"
#include "vrdbgmacros.h"
#include "vc_default.h"
#include "vc_structs.h"
#include "VRutilmacros.h"
#include "VRattr_def.h"
#include "ACdb_info.h"
#include "VCLead.h"

from   VCMac   import   VCGetEquipTag;
from   VCTerm  import   VCGetEquipId;
from   VRpost  import   VRSetCompSeqNo;
from   VCFoCable import   VCFo_GetConn;
from   ACrg_collect import ACset_list_attribute;

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);
extern GRclassid            OPP_ACrg_collect_class_id;

method VDPostYourselfToDb( long *msg;		/* O */
			   char *key;		/* I */
			   int  to_sql;		/* I */
			   char *catalog;	/* I */
			   char *partid;	/* I */
			   char *revision;	/* I */
                           char *designRep;
			   int  *delete;	/* I/O */
			  )
{
  IGRlong       retmsg, sts;
  IGRint        status;

  IGRint        nProd, whichEnd;
  IGRint        i;
  IGRint        FootIndex;
  IGRint        NumFib;
  IGRchar      *tablename;

  IGRchar       whout[500];
  IGRchar       logfile[50];

  /*    fields to post        */

  IGRchar       tagnumber[VC_MAX_TAGNO];
  IGRchar       signalname[VC_MAX_SIG_ID];
  IGRchar       fib_seq[VC_MAX_LEAD_ID];
  IGRchar       compcode[VC_MAX_CCODE];

  IGRshort      flagset;              /* No longer posted-CR179802489 */
  struct GRid   Nbrs[2];
  struct GRid   EqId[2];
  struct GRid   parCable;

  IGRchar       f_eqp[VC_MAX_EQ_ID];
  IGRchar       f_cino[VC_MAX_EQ_ID]; /* No longer posted-CR179802489 */
  IGRchar       f_tag[VC_MAX_TAGNO];

  IGRchar       f_mod[VC_MAX_MOD_ID];
  IGRchar       f_pos[VC_MAX_POS_ID];

  IGRchar       t_eqp[VC_MAX_EQ_ID];
  IGRchar       t_cino[VC_MAX_EQ_ID]; /* No longer posted-CR179802489 */
  IGRchar       t_tag[VC_MAX_TAGNO];
  IGRchar       t_mod[VC_MAX_MOD_ID];
  IGRchar       t_pos[VC_MAX_POS_ID];
  IGRchar       f_spl[VC_MAX_CCODE];
  IGRchar       t_spl[VC_MAX_CCODE];
  IGRchar	f_tgcat[25];
  IGRchar       f_tgnam[25];
  IGRchar       f_tgrev[15];
  IGRchar	t_tgcat[25];
  IGRchar       t_tgnam[25];
  IGRchar       t_tgrev[15];
  IGRchar	f_eqcat[25];
  IGRchar       f_eqnam[25];
  IGRchar       f_eqrev[15];
  IGRchar	t_eqcat[25];
  IGRchar       t_eqnam[25];
  IGRchar       t_eqrev[15];

  IGRlong       t_tgid;
  IGRlong       t_eqid;
  IGRlong       f_tgid;
  IGRlong       f_eqid;

  IGRint              nbattr,nbattr1,tablesize;
  struct GRid         tempobj, thisobject;
  struct GRmd_env     mod_env;
  struct  ACrg_coll   NewListAttr[VR_MAX_ATTR];
  struct ACdb_info    DbInfo;
  struct ret_struct   rs_loc;
  IGRint              direct_index;
  struct VCLdInfo     ldInfo;

  /*C do the default part first    */

  SetProc( VCCable_VDPostYourselfToDb ); Begin;

  __DBGpr_com( "Cable Implementation of the VDPostYourselfToDb  method" ); 

  /* 
   * Subcables will not be posted to the DataBase 
   * We do the posting only for trunk cables.
   * Return OM_S_SUCCESS if sub-cable 
   */
  parCable.objid = NULL_OBJID;
  status = om$send(msg = message VCCable.VCAmISubCab( msg, &whichEnd,
                                                    &parCable, NULL, NULL),
		 targetid = my_id);

  if(
     (status&*msg&1) && 
     ((whichEnd==VCC_SPLIT_BEGIN) || (whichEnd==VCC_SPLIT_END)) &&
     (parCable.objid != NULL_OBJID)
    )
  {
     *msg = MSSUCC;
     End;
     return OM_S_SUCCESS;
  }

  status =
  om$send(msg = message VDSroot.VDPostYourselfToDb
                             (msg, key, to_sql, catalog, partid,
                                       revision, designRep, delete),
         mode = OM_e_wrt_message,
     targetid = my_id );
  as$status(action = RET_STATUS );

  if (*msg != MSSUCC) return (status);

  /* Rest of the code below to support posting to either vcsch_elead
   * or vcsch_flead tables */

  *msg = MSSUCC;
  ex$get_cur_mod( id    = &mod_env.md_id.objid,
                  osnum = &mod_env.md_id.osnum );

  mod_env.md_env.matrix_type = MAIDMX; /* Used for ACgive_structure */
  MAidmx( &retmsg, mod_env.md_env.matrix );

  status =
  om$send(msg = message VCRoot.VCGetProduct (&nProd, NULL),
     targetid = my_id );

  if (nProd == VC_PROD_FO)
  {
    DbInfo.quantity = VD_CKIN_VRPOST_FLEAD;
    tablename = VC_DYN_FO_FTO;
    tablesize = VC_DYN_FTO_NUM + 2;
  }
  else
  {
    DbInfo.quantity = VD_CKIN_VRPOST_ELEAD;
    tablename = VC_DYN_EL_FTO;
    tablesize = VC_DYN_FTO_NUM;
  }
  __DBGpr_int("tablesize",tablesize);
  __DBGpr_str( "Tablename of Posting ", tablename );

  /* Initialization */

  FootIndex    = -1;

  f_eqp[0]     = f_tag[0] = t_eqp[0] = t_tag[0] = '\0';
  tagnumber[0] = compcode[0] =  whout[0] = '\0';
  f_tgid       = f_eqid = t_tgid = t_eqid = 0; 
  f_spl[0]     = t_spl[0] = f_tgcat[0] = f_tgnam[0] = '\0';
  f_tgrev[0]   = t_tgcat[0] = t_tgnam[0] = t_tgrev[0] = '\0';
  f_eqcat[0]   = f_eqnam[0] = f_eqnam[0] = f_eqrev[0] = '\0';
  t_eqcat[0]   = t_eqnam[0] = t_eqrev[0] = '\0';

  /*A fill the tag num info */
  status =
  om$send (msg = message VCRoot.VCGetTagNo (tagnumber),
      targetid = my_id);

  /* fill in the "comp_code" info */
  status =  
  om$send (msg = message VCRoot.VCGetCode (compcode),
      targetid = my_id);

  __DBGpr_str( "Compcode of Cable ", compcode );
  __DBGpr_str( "Tagnumber of Cable ", tagnumber );

  /* Create a temporary transient object */
  tempobj.osnum = mod_env.md_id.osnum;
  status = om$construct(  classname = "VRpost",
                          p_objid = &tempobj.objid,
                          osnum   = tempobj.osnum );
  status =
  om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
     targetid = tempobj.objid,
     targetos = tempobj.osnum );
  as$status();
  {
     thisobject.osnum = OM_Gw_current_OS;
     thisobject.objid = my_id;
     status= om$send( msg    = message VRpost.VRSetCompSeqNo
                                    ( &retmsg, thisobject),
                                 targetid = tempobj.objid,
                                 targetos = tempobj.osnum);
  }
  NumFib = om$dimension_of (varray = me->Connect_Data);
  __DBGpr_int( "No of Fibres in the Cable ", NumFib );

  /*
   * Post the lead specific information below
   */
  for (i=0; i<NumFib; i++)
  {

      sts = VC$GetNetworkForLead( 
				 msg            = &retmsg,
				 szLeadName     = me->Connect_Data[i].LeadNam,
				 p_gridCabId    = &thisobject,
				 p_LeadInfo     = &ldInfo	
				);
      if(!(sts&retmsg&1))
      {
	  __DBGpr_str(" Lead Name ", me->Connect_Data[i].LeadNam);
	  __DBGpr_obj(" VC$GetNetworkForLead failed for", thisobject);
	  return MSFAIL ;
      }

      __DBGpr_str(" Lead Name ",              ldInfo.LeadNam);
      __DBGpr_str(" Signal Name ",            ldInfo.SigNam);
      __DBGpr_str(" Marker Name ",            ldInfo.Marker);
      __DBGpr_obj(" Begin Terminal ",         ldInfo.TermId[0]); 
      __DBGpr_obj(" End Terminal ",           ldInfo.TermId[1]); 
      __DBGpr_str(" Begin Pin Module ",       ldInfo.FibEnds[0].szModId);
      __DBGpr_str(" Begin Pin Position ",     ldInfo.FibEnds[0].szPosId);
      __DBGpr_str(" End Pin Module ",         ldInfo.FibEnds[1].szModId);
      __DBGpr_str(" End Pin Position ",       ldInfo.FibEnds[1].szPosId);
      __DBGpr_obj(" Trunk Cable ",            ldInfo.TrunkCabId); 
      __DBGpr_int(" No. of Cables    ",       ldInfo.NbCab);
      __DBGpr_objlist(" CableList for lead ", ldInfo.NbCab, ldInfo.CabId);

      Nbrs[0] = ldInfo.TermId[0];
      Nbrs[1] = ldInfo.TermId[1];

      {
	  /* variable for posting VC_N_CBFRTERMID_IN */
	  f_tgid = 0;
	  if(Nbrs[0].objid != NULL_OBJID) f_tgid = Nbrs[0].objid;

	  /* variable for posting VC_N_CBTOTERMID_IN */
	  t_tgid = 0;
	  if(Nbrs[1].objid != NULL_OBJID) t_tgid = Nbrs[1].objid;

	  rs_loc.type = text_type;
	  sts = VCTermGiveStructure( &Nbrs[0], VC_N_CBFRTERMCAT_AN, 
				   &rs_loc, 1);
	  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
	  strcpy( f_tgcat, rs_loc.var.text_st.text_string );

	  rs_loc.type = text_type;
	  sts = VCTermGiveStructure( &Nbrs[1], VC_N_CBTOTERMCAT_AN , 
				   &rs_loc, 1);
	  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
	  strcpy( t_tgcat, rs_loc.var.text_st.text_string );

	  rs_loc.type = text_type;
	  sts = VCTermGiveStructure( &Nbrs[0], VC_N_CBFRTERMNAM_AN , 
				   &rs_loc, 1);
	  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
	  strcpy( f_tgnam, rs_loc.var.text_st.text_string );

	  rs_loc.type = text_type;
	  sts = VCTermGiveStructure( &Nbrs[1], VC_N_CBTOTERMNAM_AN , 
				   &rs_loc, 1);
	  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
	  strcpy( t_tgnam, rs_loc.var.text_st.text_string );

	  rs_loc.type = text_type;
	  sts = VCTermGiveStructure( &Nbrs[0], VC_N_CBFRTERMREV_AN , 
				   &rs_loc, 1);
	  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
	  strcpy( f_tgrev, rs_loc.var.text_st.text_string );

	  direct_index=-1;
	  rs_loc.type = text_type;
	  rs_loc.var.text_st.text_string[0] = '\0';
	  sts = VCTermGiveStructure( &Nbrs[1], VC_N_CBTOTERMREV_AN , 
				   &rs_loc, 1);
	  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
	  strcpy( t_tgrev, rs_loc.var.text_st.text_string );
      }
      EqId[0].objid = EqId[1].objid = NULL_OBJID;

      if (Nbrs[0].objid != NULL_OBJID)
      {
	  status =
	      om$send (msg = message VCRoot.VCGetTagNo (f_tag),
		       targetid = Nbrs[0].objid,
		       targetos = Nbrs[0].osnum);

	  status =
	      om$send (msg = message VCMac.VCGetEquipTag (&retmsg, f_eqp, &mod_env),
		       targetid = Nbrs[0].objid,
		       targetos = Nbrs[0].osnum);

	  status =
	      om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EqId[0] ),
			targetid = Nbrs[0].objid,
			targetos = Nbrs[0].osnum );

	  __DBGpr_obj( "End Parent/Equipment Id ", EqId[0] );

	  if( EqId[0].objid != NULL_OBJID )
	  {
	      IGRint msg, direct_index=-1;
	      struct ret_struct FromCino;

	      f_eqid = EqId[0].objid;    /**** CR179802489 ****/
	      FromCino.type = text_type;
	      /* CR179802489 */
	      {
		  struct ret_struct rs_loc;
		  IGRint msg, direct_index;

		  rs_loc.type = text_type;
		  sts = VCTermGiveStructure( &Nbrs[0], VC_N_CBFREQPCAT_AN , 
					   &rs_loc, 2);
		  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
		  strcpy( f_eqcat, rs_loc.var.text_st.text_string );

		  rs_loc.type = text_type;
		  sts = VCTermGiveStructure( &Nbrs[0], VC_N_CBFREQPNAM_AN , 
					   &rs_loc, 2);
		  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
		  strcpy( f_eqnam, rs_loc.var.text_st.text_string );

		  rs_loc.type = text_type;
		  sts = VCTermGiveStructure( &Nbrs[0], VC_N_CBFREQPREV_AN , 
					   &rs_loc, 2);
		  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
		  strcpy( f_eqrev, rs_loc.var.text_st.text_string );
	      }
	  }
	  __DBGpr_str( "Lead Origin : Terminal Tag ", f_tag );
	  __DBGpr_str( "Lead Origin : Equipment Tag ", f_eqp );
      }

      if (Nbrs[1].objid != NULL_OBJID)
      {
	  status =
	      om$send (msg = message VCRoot.VCGetTagNo (t_tag),
		       targetid = Nbrs[1].objid,
		       targetos = Nbrs[1].osnum);

	  status =
	      om$send (msg = message VCMac.VCGetEquipTag (&retmsg, t_eqp, &mod_env),
		       targetid = Nbrs[1].objid,
		       targetos = Nbrs[1].osnum);

	  status =
	      om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EqId[1] ),
			targetid = Nbrs[1].objid,
			targetos = Nbrs[1].osnum );

	  t_eqid = EqId[1].objid;    /**** CR179802489 ****/

	  __DBGpr_obj( "End Parent/Equipment Id ", EqId[1] );

	  if( EqId[1].objid != NULL_OBJID )
	  {
	      IGRint msg, direct_index=-1;
	      struct ret_struct ToCino;

	      ToCino.type = text_type;
	      {
		  struct ret_struct rs_loc;
		  IGRint msg, direct_index;

		  rs_loc.type = text_type;
		  sts = VCTermGiveStructure( &Nbrs[1], VC_N_CBTOEQPCAT_AN , 
					   &rs_loc, 2);
		  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
		  strcpy( t_eqcat, rs_loc.var.text_st.text_string );

		  rs_loc.type = text_type;
		  sts = VCTermGiveStructure( &Nbrs[1], VC_N_CBTOEQPNAM_AN , 
					   &rs_loc, 2);
		  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
		  strcpy( t_eqnam, rs_loc.var.text_st.text_string );

		  rs_loc.type = text_type;
		  sts = VCTermGiveStructure( &Nbrs[1], VC_N_CBTOEQPREV_AN , 
					   &rs_loc, 2);
		  if(!( sts & 1 )) rs_loc.var.text_st.text_string[0] = '\0';
		  strcpy( t_eqrev, rs_loc.var.text_st.text_string );

	      }
	  }

	  __DBGpr_str( "Lead End : Terminal Tag ", t_tag );
	  __DBGpr_str( "Lead End : Equipment Tag ", t_eqp );
      }
      nbattr = 0;

      strcpy( NewListAttr[nbattr].name,VC_N_TAG_NUMBER_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,tagnumber); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBCOMPCODE_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,compcode); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFREQPTG_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_eqp); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFREQPID_IN);
      NewListAttr[nbattr].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[nbattr].desc.value.att_exp = (double) f_eqid ; nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFREQPCAT_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_eqcat); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFREQPNAM_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_eqnam); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFREQPREV_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_eqrev); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFRTERMTG_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_tag); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFRTERMID_IN);
      NewListAttr[nbattr].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[nbattr].desc.value.att_exp = (double) f_tgid ; nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFRTERMCAT_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_tgcat); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFRTERMNAM_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_tgnam); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBFRTERMREV_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,f_tgrev); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOEQPTG_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_eqp); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOEQPID_IN);
      NewListAttr[nbattr].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[nbattr].desc.value.att_exp = (double) t_eqid ; nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOEQPCAT_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_eqcat); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOEQPNAM_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_eqnam); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOEQPREV_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_eqrev); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOTERMTG_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_tag); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOTERMID_IN);
      NewListAttr[nbattr].desc.type          = AC_ATTRIB_DOUBLE;
      NewListAttr[nbattr].desc.value.att_exp = (double) t_tgid ; nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOTERMCAT_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_tgcat); nbattr++;

      strcpy( NewListAttr[nbattr].name,VC_N_CBTOTERMNAM_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_tgnam); nbattr++;
      __DBGpr_str("to_term_nam stored is",t_tgnam);
      strcpy( NewListAttr[nbattr].name,VC_N_CBTOTERMREV_AN);
      NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
      strcpy( NewListAttr[nbattr].desc.value.att_txt,t_tgrev); nbattr++;

      {
	  __DBGpr_int( "Inserting the Details of the Lead ", i );

	  f_mod[0] = f_pos[0] = t_mod[0] = t_pos[0] = '\0';
	  strcpy (signalname, me->Connect_Data[i].SigNam);
	  strcpy (fib_seq   , ldInfo.LeadNam);
	  strcpy (f_mod, ldInfo.FibEnds[0].szModId);
	  strcpy (f_pos, ldInfo.FibEnds[0].szPosId);

	  strcpy (t_mod, ldInfo.FibEnds[1].szModId);
	  strcpy (t_pos, ldInfo.FibEnds[1].szPosId);

	  nbattr1 = nbattr;
	  strcpy( NewListAttr[nbattr1].name,VC_N_CB_CONNAME_AN);
	  NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	  strcpy( NewListAttr[nbattr1].desc.value.att_txt,fib_seq); nbattr1++;

	  strcpy( NewListAttr[nbattr1].name,VC_N_CB_SIGNAL_AN);
	  NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	  strcpy( NewListAttr[nbattr1].desc.value.att_txt,signalname); nbattr1++;

	  strcpy( NewListAttr[nbattr1].name,VC_N_CB_TOTERMMOD_AN);
	  NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	  strcpy( NewListAttr[nbattr1].desc.value.att_txt,t_mod); nbattr1++;

	  strcpy( NewListAttr[nbattr1].name,VC_N_CB_TOTERMPOS_AN);
	  NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	  strcpy( NewListAttr[nbattr1].desc.value.att_txt,t_pos);  nbattr1++;

	  strcpy( NewListAttr[nbattr1].name,VC_N_CB_FRTERMMOD_AN);
	  NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	  strcpy( NewListAttr[nbattr1].desc.value.att_txt,f_mod); nbattr1++;

	  strcpy( NewListAttr[nbattr1].name,VC_N_CB_FRTERMPOS_AN);
	  NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	  strcpy( NewListAttr[nbattr1].desc.value.att_txt,f_pos); nbattr1++;

	  if (nProd == VC_PROD_FO)
	  {
	      IGRshort nCpt;
	      struct GRid Cableobj;
	      IGRshort leadno;

	      Cableobj.objid = my_id;
	      Cableobj.osnum = OM_Gw_current_OS;

	      leadno = i;
	      /*
	       * We need to get the splice/connector information for the 
	       * extreme cables for the lead that are connected to the
	       * terminal pins
	       */
	      Cableobj = ldInfo.CabId[0];

	      if((ldInfo.CabId[0].objid == my_id) &&
		 (ldInfo.CabId[0].osnum == OM_Gw_current_OS)) nCpt = 0;
	      else
		  nCpt = 1;

	      status = VCget_splice_id( Cableobj, leadno, nCpt, fib_seq,f_spl );
	      Cableobj = ldInfo.CabId[ldInfo.NbCab - 1];
	      nCpt = 1;
	      status = VCget_splice_id( Cableobj, leadno, nCpt, fib_seq,t_spl );

	      strcpy( NewListAttr[nbattr1].name,VC_N_CB_FRCONSPL_AN);
	      NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	      strcpy( NewListAttr[nbattr1].desc.value.att_txt,f_spl); nbattr1++;

	      strcpy( NewListAttr[nbattr1].name,VC_N_CB_TOCONSPL_AN);
	      NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	      strcpy( NewListAttr[nbattr1].desc.value.att_txt,t_spl); nbattr1++;
	  }
	  /* Marker is a new entry to the database table */
	  strcpy( NewListAttr[nbattr1].name,VC_N_CB_MARKER_AN);
	  NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT;
	  strcpy( NewListAttr[nbattr1].desc.value.att_txt,ldInfo.Marker); nbattr1++;

	  /* setting the attribute values in the ACrg_collector instance */
	  __DBGpr_com( "Setting the attributes values into Collector " );
	  status = om$send( msg = message ACrg_collect.ACset_list_attribute
			    ( msg, nbattr1, NewListAttr ),
			    targetid = tempobj.objid,
			    targetos = tempobj.osnum );
	  UI_status( "Processing ..." );
	  __DBGpr_obj("transient object",tempobj);
	  status =
	      om$send(msg = message VDSroot.VDPostYourselfToDb
		      (msg, key, to_sql, catalog, partid,
		       revision, designRep, delete),
		      mode = OM_e_wrt_message,
		      senderid = NULL_OBJID,
		      targetid = tempobj.objid,
		      targetos = tempobj.osnum );
	  as$status( action = RET_STATUS );
      }
  }

  status = om$send( msg      = message NDnode.NDdelete( &mod_env),
                                 targetid = tempobj.objid,
                                 targetos = tempobj.osnum);
  UI_status( "" );
End;
  return MSSUCC;
}

/* Added for TR179802033 for returning splice IDs */
int VCget_splice_id( Cableobj, index, nCpt, szLeadName,ConnSplice )
struct GRid Cableobj;
IGRshort index; 
IGRshort nCpt;
IGRchar *szLeadName;
IGRchar *ConnSplice;
{
    IGRshort	CType;
    struct VCpos	IdStr;
    int status;
    IGRlong retmsg; /* changed type of the variable from int -> long */

    IdStr.Conn.Cable.nCpt = nCpt;
    strcpy( IdStr.Conn.Cable.szLeadId, szLeadName );
    status = om$send( msg = message VCFoCable.VCFo_GetConn( &retmsg, nCpt,
			   index, &IdStr, ConnSplice, &CType ),
                           senderid = NULL_OBJID,
			   targetid = Cableobj.objid,
			   targetos = Cableobj.osnum);
    __DBGpr_str( " Connector Splice Id ", ConnSplice );

return (status);
}

IGRint VCTermGiveStructure(TerminalId, footname, p_rs, type )
struct GRid         *TerminalId;
char                *footname;
struct ret_struct   *p_rs;
IGRint              type;
{

    IGRint      retFlag = 0;
    IGRchar     parentName[128];
    IGRint      status=OM_S_SUCCESS;
    IGRlong     retmsg;
    struct GRid EquipId;

    if(TerminalId->objid == NULL_OBJID) goto wrapup;
    if((!footname) || (!p_rs))        goto wrapup;
    /*
     * type = 1 ----> Terminal
     * type = 2 ----> Equipment
     */
    if(type == 1)
    {
	parentName[0] = '\0';
	if (!strcmp(footname,VC_N_CBFRTERMCAT_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
	else if (!strcmp(footname,VC_N_CBFRTERMNAM_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
	else if (!strcmp(footname,VC_N_CBFRTERMREV_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
	else if (!strcmp(footname,VC_N_CBTOTERMCAT_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
	else if (!strcmp(footname,VC_N_CBTOTERMNAM_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
	else if (!strcmp(footname,VC_N_CBTOTERMREV_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
	if (parentName[0] == '\0') goto wrapup;

	status = vdsa$GetStruct(objID = TerminalId,name = parentName,rs = p_rs);
	if ( ! (status & 1) ) 
	{
	    __DBGpr_obj("TerminalId ", *TerminalId);
	    __DBGpr_str("parentName ", parentName);
	    goto wrapup;
	}
	else
	{
	    retFlag = 1; 
	    goto wrapup;
	}
    }
    if(type == 2)
    {
	EquipId.objid = NULL_OBJID;
	status =
	    om$send ( msg = message VCTerm.VCGetEquipId( &retmsg, &EquipId ),
		      senderid = NULL_OBJID,
		      targetid = TerminalId->objid,
		      targetos = TerminalId->osnum );
	if ( ! (status & 1)  || (EquipId.objid == NULL_OBJID)) 
	{
	    __DBGpr_obj("TerminalId ", *TerminalId);
	    __DBGpr_str("parentName ", parentName);
	    goto wrapup;
	}
	parentName[0] = '\0';
	if (!strcmp(footname,VC_N_CBFREQPCAT_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
	else if (!strcmp(footname,VC_N_CBFREQPNAM_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
	else if (!strcmp(footname,VC_N_CBFREQPREV_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);
	else if (!strcmp(footname,VC_N_CBTOEQPCAT_AN))
             strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_CAT);
	else if (!strcmp(footname,VC_N_CBTOEQPNAM_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_NAM);
	else if (!strcmp(footname,VC_N_CBTOEQPREV_AN))
	    strcpy(parentName,VDSA_KEY_SA_PDM_ASSY_VER);

	if (parentName[0] == '\0') goto wrapup;
	p_rs->type = text_type;
	/*
	 * Call routine for value.
	 */
	status =
	    vdsa$GetStruct(objID = &EquipId, name = parentName, rs = p_rs);
	if ( ! (status & 1) ) 
	{
	    __DBGpr_obj("EquipId ", EquipId);
	    __DBGpr_str("parentName ", parentName);
	    goto wrapup;
	}
	else
	{
	    retFlag = 1; 
	    goto wrapup;
	}
    }

    //Done
    retFlag = 1;
wrapup:
    return retFlag;
}
end implementation VCCable;
