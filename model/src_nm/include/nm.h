# ifndef nm_include
# define nm_include

struct NMgmSSI
{
 struct NMentities *nmentities;
 IGRint num_sfs, num_vtx, num_nmedges;
 GRobjid *vtx, *nmedges;
 IGRint nmbufsize, nmedgesbufsize, vtxbufsize;
};


struct NMentities
{
 struct GRid sfid;

 IGRint num_flps, flpsbufsize;
 GRobjid *flps;

 IGRint num_vtxuses, vtxusebufsize;
 GRobjid *vtxuses;

 IGRint num_edges, edgesbufsize;
 GRobjid *edges;

 IGRint numedgesout, edgesoutbufsize, *numedgesin;
 GRobjid *edgesout;

 IGRint edgesinbufsize;
 GRobjid *edgesin;

 IGRint numedgesrev, edgesrevbufsize;
 GRobjid *edgesrev;

 IGRint	numedcon, edconbufsize;
 GRobjid *edcon, *nmedgescon;

 IGRint	numeddiscon, eddisconbufsize;
 GRobjid *eddiscon, *nmedgesdiscon;

 IGRint numvtxusechg, vtxusechgbufsize;
 GRobjid *vtxusechg, *origedges, *repledges;

 IGRint numvtxusetr, vtxusetrbufsize;
 GRobjid *vtxusetr, *origvtx, *replvtx;
};

enum NMbooltype
{
 NMbool_intersect, 
 NMbool_union, 
 NMbool_split
};

struct NMgetnode_trans_args
{
 OMuword *stopclsid;
 struct GRid *stopid;
};

struct NMgmssi_cache
{
 struct GRid elemid;
 IGRboolean is_valid;
 struct NMgmSSI ssi;
};


/*
Key definitions for NMnonmani nodes.
*/
#define NMkey_Unknown		0
#define NMkey_Surface		1
#define NMkey_NMnode		2
#define NMkey_FeatureLp		3
#define NMkey_CreatedEdge	4
#define NMkey_ReplacementEdge	5
#define NMkey_NMvertex_use	6
#define NMkey_NMedge		7
#define NMkey_NMvertex		8
#define NMkey_Loop		9

#endif
