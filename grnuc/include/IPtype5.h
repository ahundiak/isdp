/*
Name
        IPtype5.h

Description
        This file is "borrowed" from InterPlot.

Dependencies
        IPtypes.h

History
        mrm     02/17/92    added to GRNUC
*/

/* From here on, the file is as received from InterPlot */

/******************************************************************************

    FILE 

	IPtype5.h

    DESCRIPTION

	This file contains a type definition for the InterPlot Type 5
	Transformation/Clipping Element.
	
	Below is a description of how several fields of the structure are
	derived.

	The "scale_to_NDC" factor is:

		1 if master file elements are being described,  or

		the reference file to master file conversion factor is
		     reference file elements are being described.


	If master file elements are being described, the "xform_to_NDC"
	matrix is calculated as follows:

		xform_to_NDC = [TV]*[RV]

		where:

		"TV" is a translation matrix which subtracts the view
		     origin, and

		"RV" is a rotation matrix which aligns the master coordinate
		     space with the view coordinate space.


	If reference file elements are being described, the "xform_to_NDC"
	matrix is calculated as follows:

		xform_to_NDC = [TAR]*[RM]*[SM]*[TAM]*[TV]*[RV]

		where:

		"TAR" is a translation matrix which subtracts the attach
		      point in refence file units, 

		"RM"  is a rotation matrix which aligns the reference file
		      space with the master file space, 

		"SM"  is a scaling matrix which scales the reference file
		      space to the master file space, 

		"TAM" is a translation matrix which adds the attach point
		      in master file units, 

		"TV" is a translation matrix which subtracts the view
		     origin, and

		"RV" is a rotation matrix which aligns the master coordinate
		     space with the view coordinate space.


	The number to the left of each field is the word offset of the
	field.

    INCLUDE FILE DEPENDENCIES

	IPconst.h

    CHANGE HISTORY

	04/20/88 (RKS)	Initial creation.

	05/26/88 (mhw)	Changed 'lines_w_width' to 'extended_dflags'
			and added #defines for the bits in this word.
			Now orientation and mirror are also indicated
			in the 'extended_dflags' word.

	10/14/88 (asb)	Added a new type 5, 'IPPlotT5Lx'.  This type 5
			stores the multi-sided clipping polygon for both
			master and reference files.

	10/24/88 (asb)  Changed 'IPPlotT5Lx' to 'IPPlotT5L16'.

	10/28/88 (mhw)	Added definition for IPAttrLnkBit.

	04/16/89 (mhw)	Changed the types for clip_z_low, clip_z_high, and
			verts from IPuint32 to IPint32 in the typedef for
			IPPlotT5L16.

	05/17/89 (mhw)	Changed the definition of IPPlotT5L16 - removed the
			zlow and zhigh fields and added z_delta.

	08/04/89 (mhw)	Added definition for IPPriorityBit.

        11/27/90 (jjr)  Modified the declaration of 'font_mask' in 'IPPlotT5'.
                        The font mask should be an array of UNSIGNED 
                        characters.

******************************************************************************/


/* bit defintions for the extended_dflags word */

#define	IPLWWBit	0		/* lines with width bit		*/
					/* 1-> lines with width present */

#define	IPOrientBit	1		/* orientation bit		*/
					/* 0-> landscape		*/
					/* 1-> portrait			*/

#define	IPMirrorBit	2		/* mirror bit			*/
					/* 1-> mirror on		*/

#define	IPAttrLnkBit	3		/* attribute linkage present	*/
					/* 1-> a keyword that could 	*/
					/* cause linkage to be added to	*/
					/* an element was encountered	*/
					/* in the pen table.		*/

#define	IPPriorityBit	4		/* priority bit			*/
					/* 1-> the priority keyword was	*/
					/* encountered in the pen table	*/


#define IPT5L4Version   1.0             /* Version number of plotting   */
                                        /* type 5.                      */

typedef struct
{

    /*** Element Header ***/

    IPint16	type_level;		/* type: 5  level: 4		*/
    IPint16	words_to_follow;	/* words to follow: 754 	*/
    IPint32	xlow;
    IPint32	ylow;
    IPint32	zlow;
    IPint32	xhigh;
    IPint32	yhigh;
    IPint32	zhigh;
    IPint16	graphic_group;
    IPint16	attr_linkage;
    IPint16	properties_mask;
    IPint16	display_symb_mask;


    /*** NDC Coordinate Space Clipping Limits ***/

    IPuint32	clip_xlow;		/* Diagonal of a clipping box	*/
    IPuint32	clip_ylow;		/* in plot space		*/
    IPuint32	clip_zlow;
    IPuint32	clip_xhigh;
    IPuint32	clip_yhigh;
    IPuint32	clip_zhigh;

    IPint32	ALIGN;			/* Align the next field on a	*/
					/*   64-bit boundary		*/


    /*** Transformation Data ***/

    IPreal64	scale_DB_to_plot;	/* scale factor which scales	*/
					/* the master file or reference	*/
					/* file data to the plot space	*/

    IPreal64	rotate_DB_to_plot[9];	/* rotation matrix: reference	*/
					/* file or master file to plot	*/

    IPreal64	xform_DB_to_plot[16];	/* homogeneous transformation	*/
					/* matrix: master or reference	*/
					/* file to plot			*/

    IPreal64	xform_plot_to_DB[16];	/* inverse of above		*/


    /*** Display Information ***/

    IPint16	dimension;		/* 2 = 2D  3 = 3D		*/
    IPint16	level_mask[4];
    IPint16	display_flags;
    IPuint16	extended_dflags;	/* bit 0 -> lines with width	*/
					/* bit 1 -> orientation		*/
					/* (0->landscape, 1->portrait)  */
					/* bit 2 -> mirror		*/

    IPuint8	font_mask[16];		/* mask indicating fonts used	*/
					/* in metafile		        */
    IPint16	level_sym_mask;		/* level symbology mask		*/
    IPint16	symbology[63];		/* level symbology table	*/
    IPint16	co_tab_attached;	/* 0 => no color table attached	*/
    IPint16	color_table[384];	/* color table information:	*/
					/* valid only if color table	*/
					/* is attached			*/

    /*** Font Library Information ***/
    char	sending_node[16];	
    char	fontlib[128];

    /*** Arb. Rotation and Disp. Scale ***/
    IPreal64    rotation;
    IPreal64    data_rescale_x;
    IPreal64    data_rescale_y;
    IPreal64    plot_rescale_x;
    IPreal64    plot_rescale_y;

} IPPlotT5;
