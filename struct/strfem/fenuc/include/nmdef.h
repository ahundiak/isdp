# ifndef nmdef_include
# define nmdef_include


/* Parent indices used by NMinters object.
*/
#define NmOpIdx		0
#define VolOpIdx	1



/* Parent indices used by NMtrim object.
*/
#define SrcIdx		0
#define CompIdx		1


#define MaxNumEdpars	2



/* Maximum partedges arising out of a stitch.
*/
#define MaxNumPe	3


/* Following used in NMnonmanigm.NMputSSI and NMgetSSI.
*/
#define FirstDangling		0x1
#define SecondDangling		0x2


#define InvalidIntobjIndex -1


#define VtxDispWeight	4

#define FlpDispWeightInc        1

#define PtFlpDispWeightInc	4



/* Options for NMinters.NMintersect method.
*/
#define NMintersect_NoStoreInters	0x0001
#define NMintersect_IsRecompute		0x0002



/* Options for NMinters.NMput_inters method.
*/
#define NMputint_StoreOther		0x0001



/* Options for NMinters.NMget_inters method.
*/
#define NMgetint_NoStorageObjs		0x0001




/* Options for NMnonmanigm.NMget_SSI method.
*/
#define NMgetssi_cache			0x0001
#define NMgetssi_NoVtx			0x0002
#define NMgetssi_NoNmEdge		0x0004
#define NMgetssi_NoNmEntities		0x0008




/* Options for NMSSI_action method.
   DeactTopolgy includes - DisconnectFlps, DeactivateVtx, UnsplitEdges
			   UnChangeVtxuse AND ReverseEdges.
*/
#define NMssiact_DeleteTopology  	0x0001
#define NMssiact_EraseFlps	 	0x0002
#define NMssiact_DrawFlps	 	0x0004
#define NMssiact_DisconnectFlps		0x0008
#define NMssiact_EraseVtx		0x0010
#define NMssiact_DrawVtx		0x0020
#define NMssiact_DeactivateVtx		0x0040
#define NMssiact_RedrawAffectedSfs	0x0080
#define NMssiact_UnsplitEdges		0x0100
#define NMssiact_ReverseEdges		0x0200
#define NMssiact_DeactTopology		0x0400
#define NMssiact_DeactivateNmEdge	0x0800
#define NMssiact_UnChangeVtxuse		0x1000
#define NMssiact_UnTransVtxuse		0x2000


/* Options for NMget_node function.
*/
#define NMgetnode_All			0x0001




/* Options for NMreexecute method.
*/
#define NMreex_RecomputeAll		0x0001
#define NMreex_NoUneval			0x0002




/* Options for NMcreate_topology function.
*/
#define NMcreatetp_NmEdgesConnected	0x0001
#define NMcreatetp_CheckNmEdges		0x0002
#define NMcreatetp_OnlyVtx		0x0004
#define NMcreatetp_CreateDegenerateVtx  0x0008
#define NMcreatetp_NonOrientedInput     0x0010




/* Options for various query functions. The
   query options are passed via the argument
   'nmquery_opt' to these functions.
   Data type - unsigned IGRint
   An individual function can honor only a
   subset of these options.
*/
#define NMquery_ConsiderExternalToModel	0x0001
#define NMquery_ConsiderInactive	0x0002
#define NMquery_InTransientState	0x0004 /* for getinfo from
						  NMedge and NMvertex_use*/
#define NMquery_CreateIfNotFound	0x0008





/* Options for the function NMassociative_preprocess.
*/
#define NMassocpre_NMedge		0x0001 /* Want a NMedge */
#define NMassocpre_StartVtx		0x0002 /* Want vertex at begin */
#define NMassocpre_StopVtx		0x0004 /* Guess */
#define NMassocpre_NoTopEdges		0x0008 /* Consider the input
						  edge as being the topmost. */
#define NMassocpre_NoSaveState		0x0010 /* Don't bother saving the ssi
						  about created entities. */
						
						

/* Options for NMnonmanibnd.NMcreate_boundaries method.
*/
#define NMcreatebnd_NoCurveAssoc	0x0001




/* NMprop method options for NMvertex, NMvertex_use, NMnonmanigm
   and NMedge
*/
#define NMprop_Get			0x0001
#define NMprop_SetOn			0x0002
#define NMprop_SetOff			0x0004




/* NMassoc.NMtransmigrate method options
*/
#define NMtrans_SameActidFunc		0x0001
#define NMtrans_SameActidFuncArgs	0x0002




/* NMassoc.NMinit_assocative method options
*/
#define NMinitas_NoDuplicateParents	0x0001




/* NMinit method options for NMvertex, NMvertex_use, NMedge,
   and NMfeaturelp.
*/
#define NMinit_CompatibleVertices	0x0001 /* For NMedge only */
#define NMinit_AddToSSI			0x0002
#define NMinit_ExternalToModel		0x0004



/* NMedge.NMconnect_edges, NMvertex_use.NMconnect_edges and 
   NMvertex.NMconnect_vertex_uses options.
*/
#define NMconnect_CompatibleVertices	0x0001 /* For NMedge only */
#define NMconnect_AddToSSI		0x0002 
#define NMconnect_InTransientState	0x0004
#define NMconnect_ExternalToModel	0x0008
#define NMconnect_NoChecks		0x0010 /* For vtx & vtxuse only */





/* int_props for NMintcurve and NMintpoly.
*/
#define NMintobject_Is2d		0x0001 /* Default 3d */
#define NMintobject_IsPlanar		0x0002



/* Options for the function NMcreate_nmtp.
*/
#define NMcrtnmtp_QueryOnly		0x0001 /* Just return the NMnonmanitp
						  node if it exists. Do not
						  create if does not
						  exist. Default behavior is
						  creation.
					       */

/* Options for NMnonmaist.NMperform_stitch (nm_options argument)
*/
#define NMstch_GlueEdgesOnly		0x0001 /* Avoid any other processing
						  except getting edges of
						  input components and gluing
						  them (via NMedges) if there
						  is a match.
					       */
#define NMstch_TempCreator		0x0002

/******************** Properties ***************************/


/* Vertex properties 
*/
#define NMvtx_Active			0x0001
#define NMvtx_ExternalToModel		0x0002



/* Vertex use properties 
*/
#define NMvtxuse_Active			0x0001
#define NMvtxuse_Deletable		0x0002
#define NMvtxuse_ExternalToModel	0x0004



/* Nonmanigm properties 
*/
#define NMgm_Active			0x0001
#define NMgm_Unevaluated		0x0002
#define NMgm_NullState			0x0004


/* NMedge properties 
*/
#define NMedge_Active			0x0001
#define NMedge_Deletable		0x0002
#define NMedge_ExternalToModel		0x0004



/* NMfeaturelp properties (nmprops) 
*/
#define NMflp_ExternalToModel		0x0001



/* NMpartedge properties (nmprops) 
*/
#define NMparted_ExternalToModel	0x0001



/* NMinters properties 
*/
#define NMinters_IsVolInt		0x0001
#define NMinters_VolOpRevOrnt		0x0002
#define NMinters_PartialVolInt		0x0004



#endif
