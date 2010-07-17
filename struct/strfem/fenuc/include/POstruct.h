#ifndef POstruct_included
#define POstruct_included

/*************************************************************************** 

   Doc: POstruct.h

   Abstract: This header file contains data structures for the POST system.

   History:

	Date		Who	Why
	---------	---	------------------------------------------
	 7 Feb 89	msl	Creation
	23 Feb 89	msl	Updates for 1.2
	10 May 89	msl	Moved POloader structs to POload.h
	20 Oct 89	msl	Added POe_info
	14 Nov 89	msl	Included POcrit.h
	 6 Apr 90	msl	Added POstats
	19 Sep 90	msl	Added POplgr_data & POsel_data
					( place graphics data, select data )
	30 Jul 91	kk	Added POsec_info
	06 Dec 91	qxn	Added type to POman_info
	16 Jun 92	qxn	Added POpdd_info
 ****************************************************************************/

#include "POlim.h"
#include "POcrit.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

typedef struct postman_info {
		IGRchar		name[PO_PMAN_NAME_LEN];
		IGRchar		desc[PO_PMAN_DESC_LEN];
		IGRlong		date;
		int		type;	/*TRUE - results set with visible mesh*/
   }POman_info;

typedef struct post_elem_info {
		int		nnodes;
		int		dimension;
   }POe_info;

typedef	struct pdentry_info {
		IGRlong		din;
		IGRint		cat;
		unsigned char	units;		/* See APunitdef.h for #defines	*/
		IGRchar		name[PO_PDNAME_LEN];
   }POpde_info;

typedef	struct pdd_info {
	char				name[PO_PDNAME_LEN];
	long				first_din;
	long				ndins;
	long				first_pde; /* index to first entry of the pde
						      list. Note: this piece of info.
						      is only relevant to the POCselect
						      instance data- pde.	*/
   }POpdd_info;

typedef	struct post_def_dins {	
		IGRint		ndins;
		IGRlong		dins[6];
   }POdefault_dins;

typedef	struct post_stats {	
		double		max;	 /* max of data	*/
		long		uid_max; /* uid where max occurs */
		double		min;	 /* min of data	*/
		long		uid_min; /* uid where min occurs */
		double		mean;	 /* mean of data	*/
		long		cnt;	 /* number nd/el with data */
   }POstats;

typedef struct pl_graphics_data {
		long		nsteps;	/* Num steps, dec places, frames, etc*/
		double		shrink;	/* shrink factor		*/
		double		exagg;	/* Exaggeration factor (abs)	*/
		struct GRid	cvt_grid; /* cvt for color coding	*/
		struct GRsymbology sym;	/* symbology			*/
		long		props;	/* bit booleans ( POpgdef.h )	*/
   }POplgr_data;

typedef struct select_data {
	POpde_info	*pde;		/* ptr to post data entries to select*/
	int		num_pde;	/* number of pde's in list	*/
	long		dins[6];	/* Data ID numbers selected	*/
	int		ndins;		/* Number of dins selectable	*/
	int		cat;		/* Data Category		*/
	int		post_type;	/* Post Operation Type		*/
	double		max;		/* Maximum data this din	*/
	double		min;		/* Minimum data this din	*/
	char		data_name[PO_PDNAME_LEN]; /* pde name of selected */
	char		mxmn_flag;	/* 0 - do not get max min data when
						selection is made on the form
					   1 - get max min, do NOT check mx=mn
					   2 - get max min, if(mx=mn) do not
						release form, make user select
						data with mx!=mn	*/
	char		pdd_name[PO_PDNAME_LEN]; /* pdd name of selected */
	int		pdd_cnt;	/* the # 'selectable' pdd's	*/
	POpdd_info	*pdd;		/* the tensor list		*/
	struct GRid	cmd_grid;	/* cmd object grid (3.0 addition)*/
   }POsel_data;

typedef struct  cutting_section
   {
	char			type;  /* 1 : Planar, 2 : Surface  */
	long			num_sections; /* For planar	   */
	long			planar_type;  /* 1: abcd used.  2: curve_grid used */
	union
	{
		double		*abcd;	/*  plane = ax + by + cz + d = 0 	*/
	   				/*    abcd[num_sections][4]		*/
	   	struct GRid	curve_grid;  /* Bspline curve			*/
	} planar;
   }  POsec_info;

#define MAX_SEC 4
#define MAX_EDGE 6

typedef struct sec_edges
   {
   	long		num_sec;		/* Number of sections		*/
   	long		num_edges[MAX_SEC];	/* Number of in each section	*/
   	long		nodes[MAX_SEC][MAX_EDGE][2];	/* Edge node ids	*/
   } POsec_edges;

typedef struct double_id
   {
	OM_S_OBJID	model_id;	/* model node/element id*/
   	OM_S_OBJID	arch_id;	/* archive node/element id*/
   } POdbl_id;

#endif
