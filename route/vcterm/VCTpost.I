
/* $Id: VCTpost.I,v 1.2 2001/02/20 01:11:44 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm / VCTpost.I
 *
 * Description:
 *   Database post of connectivity info for Terminal
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTpost.I,v $
 *        Revision 1.2  2001/02/20 01:11:44  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *        Initial import to CVS
 *
# Revision 1.5  1999/06/01  11:17:10  pinnacle
# Replaced: vcterm/VCTpost.I for: TR 179900627 by aharihar for route
#
# Revision 1.4  1999/02/17  17:03:50  pinnacle
# Replaced: vcterm/VCTpost.I for:  by lawaddel for route
#
# Revision 1.3  1999/02/08  19:11:50  pinnacle
# Replaced: vcterm/VCTpost.I for:  by lawaddel for route
#
# Revision 1.2  1999/01/19  17:34:24  pinnacle
# Replaced: vcterm/VCTpost.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/20  04:19:12  pinnacle
# Replaced: vcterm/VCTpost.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.1  1997/10/24  12:07:42  pinnacle
# initial revision
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      10/24/97    Alwin          Initial
 *	01/19/99    Alwin	   Included the VDPostYourSelfToDb method.
 *      02/04/99    law            CR179701619 Added Jumper processing 
 *    June 1 1999   Anand          TR 179900627 Posting to VCSCH_JMPLOC table
 *    				   is incomplete. Only the first jumper gets
 *    				   its positions posted.
 *
 *************************************************************************/

class implementation VCTerm;

#include "string.h"
#include "VDSpdudef.h"
#include "VDScheckin.h"
#include "VDScheckdef.h"
#include "VDSris_def.h"
#include "VDSris_siz.h"
#include "VDDbtbldef.h"
#include "vdbmacros.h"
#include  "VDsa.h"         /* CR179701619 */
#include "VCDBpar.h"
#include "VCdbstructs.h"
#include "VCdbaccess.h"
#include "VCdbpost.h"
#include "VRattr_def.h"    /* CR179701619 */
#include "vdAPIequips.h"
#include "vc_define.h"     /* CR179701619 */
#include "vrdbgmacros.h"
#include "vc_default.h"

/***** Added for CR179701619 ******/
from   ACrg_collect import ACshow_data;
from   ACrg_collect import ACset_list_attribute;
from   VRpost  import   VRSetCompSeqNo; 

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);
extern GRclassid            OPP_ACrg_collect_class_id;

/*
#define MY_DEBUG
*/

/* This method is overridden to post the Terminal Jumper information's in
 * addition to the Terminal data. As of now this Posting is not completed we
 * need to incorporate the "VRpost" object posting for the Jumper Datat posting
 * Alwin */
 
method VDPostYourselfToDb( long *msg;           // (O)
                           char *key;           // (O)
                           int  to_sql;         // (I)
                           char *catalog;       // (I)
                           char *partid;        // (I)
                           char *revision;      // (I)
                           char *designRep;
                           int  *delete;        // (I/O)
                          )

{
    IGRint        status;

    IGRint        nProdNo;
    IGRlong       retmsg;

    IGRchar      Jumper_table[25];
    IGRchar      Jumper_Loc_table[25];

    IGRchar       whout[400];

    IGRchar       jumperid[20]; // It's stored as an index (integer) in object
    IGRchar       compcode[VC_MAX_CCODE];
    IGRchar       equiptag[VC_MAX_TAGNO]; // to be on the safer side
    IGRchar       termtag[VC_MAX_TAGNO];
    IGRchar       compnote[80]; // size of the "remarks" field in Jumper Str.
    IGRchar       cnt_vs_max[2];
    IGRchar       no_mto_flag[2];
    /*** Added for cr179701619 */
    struct GRid tempobj;
    IGRint nbjmpr;
    struct GRid EquipId;
    IGRchar       eq_cat[25];
    IGRchar       eq_nam[25];
    IGRchar       eq_rev[15];

    IGRchar       term_mod[20];
    IGRchar       term_pos[20];
    IGRint        nProd;
    IGRint nJ,jumperidfnd;
    struct GRmd_env mod_env;
    struct ACdb_info        DbInfo;

    SetProc( VDPostYourselfToDb ); Begin

    /* First we need to post the Terminal Object itself by calling the Parent
     * class implementation. Later we have to post the information related to
     * Jumper. */

    status = om$send(msg = message VCRoot.VCGetProduct (&nProd, NULL),
	    targetid = my_id );

    __DBGpr_int( "Calling VDSroot.VDPostYourselfToDb for terminal obj",my_id );
    status = om$send(msg = message VDSroot.VDPostYourselfToDb
	    (msg, key, to_sql, catalog, partid,
	     revision, designRep, delete),
	    mode = OM_e_wrt_message,
	    targetid = my_id );
    __DBGpr_int ("ret-status",status);
    __DBGpr_int ("msg   ",*msg);

    as$status( action = RET_STATUS );

    if (*msg != MSSUCC) return (status);

    if( nProd != VC_PROD_ELEC )
    {
	__DBGpr_com( " Fiber optic Cables doesn't carry Jumper ..so exit" );
	End
	return OM_S_SUCCESS;
    }

    /* In the case of Jumper we need to post information in two Tables, one
     * (vcdyn_jump) contains the Jumper details other table (vcdyn_jmploc) to
     * specify which are the pins Terminals connects to */

    strcpy( Jumper_table, "vcsch_jump");  /* This is the only table available
					     for both PID and 3-D modelled
					     Terminals */
    strcpy( Jumper_Loc_table, "vcsch_jmploc");

    __DBGpr_com("Calling VCGetTagNo for terminal");
    status = om$send ( msg = message VCRoot.VCGetTagNo( termtag ),
	    targetid = my_id );
    as$status(action = RET_STATUS );

    __DBGpr_com("setting matrix to identity");
    ex$get_cur_mod( id    = &mod_env.md_id.objid,
	    osnum = &mod_env.md_id.osnum );

    mod_env.md_env.matrix_type = MAIDMX;
    MAidmx( &retmsg, mod_env.md_env.matrix );

    /*** BELOW MODIFIED FOR CR179701619 ************************/
    EquipId.objid = NULL_OBJID;
    eq_cat[0] = eq_nam[0] = eq_rev[0] = equiptag[0] = '\0';
    status = om$send ( msg = message VCTerm.VCGetEquipId( &retmsg,
		&EquipId ) ,
	    targetid = my_id );
    if(EquipId.objid != NULL_OBJID)
    {
	struct ret_struct    p_rs;

	__DBGpr_com("Getting equip-tag");
	status = om$send ( msg = message VCMac.VCGetEquipTag
		( &retmsg, equiptag, &mod_env ),
		targetid = my_id );
	as$status(action = RET_STATUS );
	__DBGpr_str("eqpt_tag      ",equiptag);

	status = vdsa$GetStruct(objID = &EquipId,
		name = VDSA_KEY_SA_PDM_ASSY_CAT,rs = &p_rs);
	__DBGpr_int("get catalog status",status);

	strncpy(eq_cat, p_rs.var.text_st.text_string,25);
	__DBGpr_str("eqpt_cat      ",eq_cat);
	status = vdsa$GetStruct(objID = &EquipId,
		name = VDSA_KEY_SA_PDM_ASSY_NAM,rs = &p_rs);
	__DBGpr_str("eqpt_nam      ",p_rs.var.text_st.text_string);
	strcpy( eq_nam, p_rs.var.text_st.text_string);
	status = vdsa$GetStruct(objID = &EquipId,
		name = VDSA_KEY_SA_PDM_ASSY_VER,rs = &p_rs);
	__DBGpr_str("eqpt_rev      ", p_rs.var.text_st.text_string);
	strcpy(eq_rev,p_rs.var.text_st.text_string);
    }

    { /*** BELOW ADDED FOR CR179701619 ************************/
	void *v_jmpinfo;
	void *v_JumpConn;
	IGRint nconn,TermPinCnt;
	struct VCJumpData *jmpinfo;
	struct VCJumpConn *JumpConn;
	IGRchar mto_flag[2];
	IGRchar cntvsmax[2];
	struct ret_struct rs_loc;
	IGRint msg, direct_index;
	struct  ACrg_coll  NewListAttr[VR_MAX_ATTR];
	IGRint nbattr,nbattr1;

	status = om$send (msg = message VCTerm.VCGetJumpInstance(&retmsg,&v_jmpinfo,
		    &nbjmpr,&v_JumpConn ),
		targetid = my_id );
	as$status(action = RET_STATUS );

	if(nbjmpr > 0)
	{
	    jmpinfo = (struct VCJumpData *) v_jmpinfo;
	    JumpConn= (struct VCJumpConn *) v_JumpConn;
	}
	__DBGpr_int("comp_seqno     ",my_id);
	__DBGpr_str("equip-tag      ",equiptag);
	__DBGpr_obj("equip-ID       ",EquipId);
	__DBGpr_int("no connections ",nbjmpr);

	/* Below two lines added for TR 179900627 */
	nconn=0;
	TermPinCnt=0;

	for(nJ = 0;nJ<nbjmpr;nJ++)
	{
	    /* Create a temporary transient object for VRpost object */
	    /* tempobj.osnum = OM_Gw_TransOSnum_0;
	     ***** transient in transient OS ***/

	    tempobj.osnum = mod_env.md_id.osnum;
	    status = om$construct(classname = "VRpost",
		    p_objid = &tempobj.objid,
		    osnum   = tempobj.osnum );
	    __DBGpr_obj("Created temp jumper obj",tempobj);
	    {
	/***** Set the comp_seqno instance for posting the VRpost object ***/
		struct GRid thisobject;
		thisobject.osnum = OM_Gw_current_OS;
		thisobject.objid = my_id;
		status= om$send( msg    = message VRpost.VRSetCompSeqNo
			( &retmsg, thisobject),
			targetid = tempobj.objid,
			targetos = tempobj.osnum);
	    }

	    DbInfo.quantity = VD_CKIN_VRPOST_JUMP;

	    status =
	    om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
		    targetid = tempobj.objid,
		    targetos = tempobj.osnum );
	    as$status();

	    mto_flag[0] = jmpinfo[nJ].no_mto_flag;
	    mto_flag[1] = '\0';
	    cntvsmax[0] = jmpinfo[nJ].cnt_vs_max;
	    cntvsmax[1] = '\0';

	    __DBGpr_int("jumper id      ",jmpinfo[nJ].JumperId);
	    __DBGpr_str("jumper compcode",jmpinfo[nJ].jump_code);
	    __DBGpr_str("jumper mto     ",mto_flag);
	    __DBGpr_int("no-term-pins   ",jmpinfo[nJ].NumTermPins);
	    __DBGpr_str("jumper remarks ",jmpinfo[nJ].remarks);

	    nbattr = 0;
	    strcpy( NewListAttr[nbattr].name,VC_N_JJUMPERID_IN);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_DOUBLE;
	    NewListAttr[nbattr].desc.value.att_exp = (double) jmpinfo[nJ].JumperId ;
	    nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_CBCOMPCODE_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt, jmpinfo[nJ].jump_code);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT; nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_GENEQ_TAG_AN);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;
	    strcpy( NewListAttr[nbattr].desc.value.att_txt,equiptag); nbattr++;

	    {
		IGRint tempobjid;
		tempobjid = EquipId.objid;
		/***** Trying to bypass contamination of database-CR179801619 */
		if(EquipId.objid == NULL_OBJID)
		    tempobjid = -1;
		strcpy( NewListAttr[nbattr].name,VC_N_GENEQ_ID_IN);
		NewListAttr[nbattr].desc.type = AC_ATTRIB_DOUBLE;
		NewListAttr[nbattr].desc.value.att_exp = (double) tempobjid ; nbattr++;
	    }

	    strcpy( NewListAttr[nbattr].name,VC_N_GENEQ_CAT_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt,eq_cat);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;  nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_GENEQ_NAM_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt,eq_nam);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT; nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_GENEQ_REV_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt,eq_rev);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT; nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_BKTERMTAG_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt, termtag);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;  nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_JCOMPNOTE_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt,
		    jmpinfo[nJ].remarks);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;  nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_JCNTVSMAX_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt, cntvsmax);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;  nbattr++;

	    strcpy( NewListAttr[nbattr].name,VC_N_JNOMTOFLG_AN);
	    strcpy( NewListAttr[nbattr].desc.value.att_txt, mto_flag);
	    NewListAttr[nbattr].desc.type = AC_ATTRIB_TEXT;  nbattr++;

	    /* setting the attribute values in the ACrg_collector instance */
	    __DBGpr_com( "Setting the attributes values into Collector " );
	    status = om$send( msg = message ACrg_collect.ACset_list_attribute
		    ( &retmsg, nbattr, NewListAttr ),
		    targetid = tempobj.objid,
		    targetos = tempobj.osnum );

	    __DBGpr_obj("transient object",tempobj);

#ifdef vdsDEBUG
	    status = om$send( msg = message ACrg_collect.ACshow_data(&retmsg),
		    targetid = tempobj.objid,
		    targetos = tempobj.osnum );
#endif

	    __DBGpr_com( "Inserting the vcsch_jump information into the DB" );
	    status =
	    om$send(msg = message VDSroot.VDPostYourselfToDb
		    (&retmsg, key, to_sql, catalog, partid,
		     revision, designRep, delete),
		    mode = OM_e_wrt_message,
		    senderid = NULL_OBJID,
		    targetid = tempobj.objid,
		    targetos = tempobj.osnum );
	    as$status( action = RET_STATUS );

	    DbInfo.quantity = VD_CKIN_VRPOST_JMPLOC;
	    status =
	    om$send(msg = message ACdb_info.ACset_db_info  ( &retmsg, &DbInfo),
		    targetid = tempobj.objid,
		    targetos = tempobj.osnum );
	    as$status();

	    TermPinCnt += jmpinfo[nJ].NumTermPins; // Added for TR 0627
	    __DBGpr_int("Num term pins so far",TermPinCnt);

	    /* Below for statement modified for TR 0627 */
	    for( ; nconn<TermPinCnt ; nconn++)
	    { 
		__DBGpr_int("Jumper id in JumpConn",JumpConn[nconn].JumperId);
		__DBGpr_int("Jumper id in jmpinfo",jmpinfo[nJ].JumperId);
		if(JumpConn[nconn].JumperId == jmpinfo[nJ].JumperId)
		{
		    nbattr1 = nbattr;
		    __DBGpr_com("Connector found for JumperId");
		    __DBGpr_int("   Jump-Id  ",JumpConn[nconn].JumperId);
		    __DBGpr_str("   Conn-Mod ",JumpConn[nconn].Mod);
		    __DBGpr_str("   Conn-Pos ",JumpConn[nconn].Pos);
		    __DBGpr_com(" ");
		    jumperidfnd = 1;
		    strcpy( NewListAttr[nbattr1].name,VC_N_JTERMMOD_AN);
		    strcpy( NewListAttr[nbattr1].desc.value.att_txt,
			    JumpConn[nconn].Mod);
		    NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT; nbattr1++;

		    strcpy( NewListAttr[nbattr1].name,VC_N_JTERMPOS_AN);
		    strcpy( NewListAttr[nbattr1].desc.value.att_txt,
			    JumpConn[nconn].Pos);
		    NewListAttr[nbattr1].desc.type = AC_ATTRIB_TEXT; nbattr1++;

	    /* setting the attribute values in the ACrg_collector instance */
		    __DBGpr_com("Setting attributes values into Collector");
		    status =
		    om$send( msg = message ACrg_collect.ACset_list_attribute
					     ( &retmsg, nbattr1, NewListAttr ),
			targetid = tempobj.objid,
			targetos = tempobj.osnum );

#ifdef vdsDEBUG
		    status = om$send( msg = message ACrg_collect.ACshow_data(&retmsg),
			    targetid = tempobj.objid,
			    targetos = tempobj.osnum );
#endif

		    __DBGpr_com( "Inserting the vcsch_jmploc information into the DB" );
		    status =
		    om$send( msg = message VDSroot.VDPostYourselfToDb
					 (&retmsg, key, to_sql, catalog, partid,
					  revision, designRep, delete),
			    mode = OM_e_wrt_message,
			    senderid = NULL_OBJID,
			    targetid = tempobj.objid,
			    targetos = tempobj.osnum );
		    as$status();
		} 
	    }
	    __DBGpr_obj("deleting temp jumper obj",tempobj);
	    status = om$send( msg      = message NDnode.NDdelete( &mod_env),
		    targetid = tempobj.objid,
		    targetos = tempobj.osnum);

	}
    }
    __DBGpr_int("no connections ",nbjmpr);
    __DBGpr_com( "Posted the Terminal Object Successfully" );
    End ;
    return MSSUCC;
}

end implementation VCTerm;

