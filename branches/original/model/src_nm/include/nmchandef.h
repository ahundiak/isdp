# ifndef fechandef_include
# define fechandef_include

/*
 * The following constants are the labels that have a one-to-one
 * correspondence with the various channels used within NM. These are
 * "labels" to be used when making a channel via the call to the 
 * function - NMmake_chanselect. When adding a new channel label, be sure
 * to update the NUM_TOTAL_NM_CHANNELS constant and the function -
 * NMinit_chanselect.
 */

#define NMvertex_to_vtx_uses		0
#define NMinters_to_other_int		1
#define NMvertex_use_to_vtx		2
#define NMlistedge_to_edges		3
#define NMlistvtxuse_to_edges		4

#define NUM_TOTAL_NM_CHANNELS		5

#endif
