/*********************************************************************

Author	:	B Demars

Creation:	October 23rd, 1990


		This file contains the definition of all
		VRconstants.
		
	
Change History :


		  date	|  name	|	modification's description
		--------+-------+-----------------------------------

*********************************************************************/

#ifndef	vr_dim_def_include
#define vr_dim_def_include

	/* structures' dimensions */

#define FORK			2

	/* -- Number of characters that compose the component AABBCC code -- */

#define VR_CODE_LENGTH		13   /* 10/3 JAM */

	/* -- Number of characters that compose the component AABBCC code -- */

#define VR_SEARCH_LENGTH	50

	/* -- Maximum number dimension parameters for a component -- */

#define	VR_MAX_DIM		30

	/* -- Maximum number of predefined connect points -- */

#define	VR_MAX_CPTS	       12

        /* -- Extended and split to allow more connectpoints   -- */
        /* -- and to more clearly delineate separate functions -- */
        /* -- Jan, 1997 HTV                                    -- */

#define VR_MAX_INST_CPTS        5   /* keep for instance arrays       */
#define VR_NWMAX_CPTBUF        15   /* for temp buffers               */
#define VR_NWMAX_CPTNUM        12   /* actual connectpoints for comps */
                                    /*     (see limits below)         */
#define VR_NWMAX_CPTSEG         2   /* connectpoints on segment       */

#define VR_NWMAX_CMPIDX        17   /* maximum instance index         */
                                    /* (original  5 plus reused       */
                                    /*  origin coordinates array)     */
#define VR_NWMAX_CNSEND        13   /* maximum constraints index      */
                                    /* (original  5 plus reused       */
                                    /*  the non used part of the      */
                                    /*  Orientoplanes array, all      */
                                    /*  but the first entry. Also     */
                                    /*  double packed the shorts      */
#endif
