/*---------------------------------------------------------------------------+
|	    								     |
|   Current Revision:							     |
|   $Workfile:   mdldim.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									     |
+---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------+
|									     |
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	     |
|									     |
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	     |
|  Systems, Inc.							     |
|									     |
| Limited permission is hereby granted to reproduce and modify this	     |
| copyrighted material provided that the resulting code is used only in	     |
| conjunction with Bentley Systems products under the terms of the	     |
| license agreement provided therein, and that this notice is retained	     |
| in its entirety in any such reproduction or modification.		     |
|									     |
+---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------+
|									     |
|   mdldim.h -- Include file for MDL applications using dimensions.    	     |
|    	    	Defines structures and constants.    		    	     |
|									     |
+---------------------------------------------------------------------------*/
#if !defined (__mdldimH__)
#define __mdldimH__

/*---------------------------------------------------------------------------+
|									     |
|   Dimension Types 							     |
|									     |
+---------------------------------------------------------------------------*/
#define DIMTYPE_SIZE_ARROW 	   1
#define	DIMTYPE_SIZE_STROKE	   2
#define DIMTYPE_LOCATE_SINGLE	   3
#define DIMTYPE_LOCATE_STACKED	   4
#define DIMTYPE_ANGLE_SIZE	   5
#define DIMTYPE_ARC_SIZE	   6
#define DIMTYPE_ANGLE_LOCATION	   7
#define DIMTYPE_ARC_LOCATION	   8
#define DIMTYPE_ANGLE_LINES	   9
#define DIMTYPE_ANGLE_AXIS	  10
#define DIMTYPE_RADIUS		  11
#define DIMTYPE_DIAMETER	  12
#define DIMTYPE_DIAMETER_PARA	  13
#define DIMTYPE_DIAMETER_PERP	  14
#define DIMTYPE_CUSTOM_LINEAR	  15
#define DIMTYPE_ORDINATE	  16
#define DIMTYPE_RADIUS_EXTENDED	  17
#define DIMTYPE_DIAMETER_EXTENDED 18
#define DIMTYPE_CENTER	          19

#define DIMTYPE_ANGLE_AXIS_X   	  50 
#define DIMTYPE_ANGLE_AXIS_Y   	  51 
#define DIMTYPE_LABEL_LINE        52 
#define DIMTYPE_NOTE	    	  53 

/*----------------------------------------------------------------------+
|									|
| Dimension text justification options 					|
|									|
+----------------------------------------------------------------------*/
#define DIMTEXT_OFFSET	   0
#define DIMTEXT_LEFT	   1
#define DIMTEXT_CENTER	   2
#define DIMTEXT_RIGHT	   3

/*---------------------------------------------------------------------------+
|						       			     |
|   Dimension string configuration flags				     |
|									     |
+---------------------------------------------------------------------------*/
#define DIMSTRING_DUAL	         0x1   /* Dual dimensions	       	    */
#define DIMSTRING_TOLERANCE      0x2   /* Tolerance mode on	       	    */
#define DIMSTRING_LIMIT	         0x4   /* Limit type tolerance	       	    */

#define MAX_DIMSTRING             80   /* Max dimension string length  	    */

#if !defined (resource)

typedef struct
    {
    UShort dual:1;	    	       /* TRUE if dual dimension units	    */
    UShort tolerance:1;		       /* TRUE if tolerances are used	    */
    UShort limit:1;		       /* TRUE for limit tolerance	    */
				       /* FALSE for plus/minus tolerance    */
    } DimStringConfig;

typedef union
    {
    struct		    	       /* Dimension with main string and    */
	{			       /*    plus/minus type tolerances	    */
	char main[MAX_DIMSTRING];
	char plus[MAX_DIMSTRING];
	char minus[MAX_DIMSTRING];
	} pmtol;

    struct		   	       /* Dimension with upper and lower    */
	{			       /*    limits only		    */
	char upper[MAX_DIMSTRING];
	char lower[MAX_DIMSTRING];
	} limit;

    char single[MAX_DIMSTRING];	       /* Dimension without tolerance	    */
    } DimStringUnion;

typedef struct
    {
    DimStringUnion  primary;	       /* Primary dimension strings	    */
    DimStringUnion  secondary;	       /* Secondary dimension strings used  */
				       /*    only with dual dimensions	    */
    } DimStrings;

/*---------------------------------------------------------------------------+
|									     |
|   Dimension Parameters						     |
|									     |
+---------------------------------------------------------------------------*/
#define DIMPARAM_TEXT	    1   /* DimParamText			    	    */
#define DIMPARAM_FORMAT	    2   /* DimParamFormat		    	    */
#define DIMPARAM_GEOMETRY   3   /* DimParamGeometry		    	    */
#define DIMPARAM_FLAGS	    4   /* DimParamFlags		       	    */
#define DIMPARAM_TOLERANCE  5   /* DimParamTolerance		    	    */
#define DIMPARAM_TEMPLATE   6   /* DimParamTemplate		    	    */
#define DIMPARAM_INFO	    7	/* DimParamInfo				    */

/* Accuracy constants for englishAccuracy and metricAccuracy		    */
#define DIMACC_0	 0x00   /* display decimal to nearest integer	    */
#define DIMACC_1	 0x81   /* display decimal to nearest .1	    */
#define DIMACC_2	 0x82   /* display decimal to nearest .01	    */
#define DIMACC_3	 0x84   /* display decimal to nearest .001	    */
#define DIMACC_4	 0x88   /* display decimal to nearest .0001	    */
#define DIMACC_5	 0x90   /* display decimal to nearest .00001	    */
#define DIMACC_6	 0xA0   /* display decimal to nearest .000001	    */
#define DIMACC_7	 0xc0   /* display decimal to nearest .0000001	    */
#define DIMACC_8	 0x80   /* display decimal to nearest .00000001	    */
#define DIMACC_HALF	 0x01   /* display fraction to nearest 1/2	    */
#define DIMACC_4th	 0x02   /* display fraction to nearest 1/4	    */
#define DIMACC_8th	 0x04   /* display fraction to nearest 1/8	    */
#define DIMACC_16th	 0x08   /* display fraction to nearest 1/16	    */
#define DIMACC_32nd	 0x10   /* display fraction to nearest 1/32	    */
#define DIMACC_64th	 0x20  	/* display fraction to nearest 1/64	    */

typedef struct
    {
    double width;	     	/* Character width			    */
    double height;	     	/* Character height			    */
    int	   font;	     	/* Font number				    */
    int	   color;	     	/* Text color				    */
    int	   weight;	     	/* Text weight				    */
    byte   useColor;		/* TRUE  - use color from this structure    */
				/* FALSE - use color from display header    */
    byte   useWeight;		/* TRUE  - use weight from this structure   */
				/* FALSE - use weight from display header   */
    } DimParamText;

typedef struct	    	       
    {
    double scale;		/* Scale applied to dimension value    	    */
    byte   metric;	     	/* Use metric system as primary	   	    */
    byte   dual;	     	/* TRUE for dual dimensions    	  	    */
    byte   englishAccuracy;  	/* English accuracy (see DIMACC_ above)     */
    byte   metricAccuracy;   	/* Metric accuracy (see DIMACC_ above)      */
    byte   leadingZero;      	/* Show leadimg zero (TRUE/FALSE)	    */
    byte   trailingZeros;    	/* Show trailing zeros (TRUE/FALSE);	    */

    byte   angleMeasure;     	/* 0-Length, 1-Degrees 			    */
    byte   angleFormat;      	/* 0-dec degrees, 1-deg min sec     	    */
    byte   angleMode;        	/* 0-conventional, 1-azimuth, 2-bearing	    */

	   	     	     	/* Flags for AEC labels			    */
    byte   showSubunits;     	/*   Show subunits    (x x")     	    */
    byte   showUnits;        	/*   Show unit labels (x' x) 		    */
    byte   showDelimiter;    	/*   Show delimiter   (x-x) 		    */
    } DimParamFormat;

typedef struct
    {
    double    witOffset;     	/* Dist from point to start of witness line */
    double    witExtend;     	/* Witness extension above dimension line   */
    double    textLift;	     	/* Dist from dimension line to base of text */
    double    textMargin;    	/* Space between leader line and text	    */
    double    minLeader;       	/* Minimum length of terminator leader	    */
    double    termWidth;     	/* Terminator tile width		    */
    double    termHeight;    	/* Terminator tile height		    */
    double    stackOffset;   	/* Distance between dimension lines	    */
    double    centerSize;    	/* Centermark size			    */
    } DimParamGeometry;

typedef struct 	 
    {
    byte      joiner;	     	/* Join witnss lines if text outside	    */
    byte      boxText;       	/* Draw box around dimension text   	    */
    byte      capsuleText;   	/* Draw capsule around text	   	    */
    byte      embedded;      	/* TRUE for embeded text mode          	    */
    byte      horizontal;    	/* TRUE for horizontal text mode   	    */
    byte      aec;	     	/* 1 = AEC, 0 = Mechanical       	    */
    byte      arrowhead;     	/* 0 = Open, 1 = Closed,  2 = Filled        */
    } DimParamFlags;

typedef struct
    {
    double    upperTol;	     	/* Upper limit/tolerance value		    */	  
    double    lowerTol;	     	/* Lower limit/tolerance value		    */
    double    tolWidth;	        /* Tolerance character width		    */
    double    tolHeight;        /* Tolerance character height		    */
    byte      tolerance;     	/* Genarate tolerances TRUE/FALSE	    */
    byte      tolmode;       	/* 0-Plus/minus, 1-Limit tolerance	    */
    } DimParamTolerance;

typedef struct
    {	    	    	        /* Standard terminators			    */
    			        /* 0-None,1-Arrow,2-Stroke,3-Circle,4-Dot   */
    byte      firstTerm;     	/* First terminator in linear dimension	    */
    byte      leftTerm;      	/* Left terminator in each segment	    */
    byte      rightTerm;     	/* Right terminator in each segment	    */
    byte      jointTerm;     	/* Terminator at internal witness line	    */

    	    	             	/* Standard symbols	    	    	    */
			     	/* 0-None, 1-Diameter, 2-Radius, 3-Square   */
    byte      prefixSym;     	/* Prefix symbol			    */
    byte      suffixSym;     	/* Suffix symbol			    */

    byte      leftWitness;   	/* Show left witness line (TRUE/FALSE)	    */
    byte      rightWitness;  	/* Show right witness line (TRUE/FALSE)	    */
    byte      centermark;    	/* Show center mark (TRUE/FALSE)	    */
    } DimParamTemplate;

typedef struct			/* General read only information - used by  */
    {			        /*   mdlDim_getParam ()	only.		    */
    int	      nPoints;		/* Number of points in dimension element    */
    int	      dimType;		/* Dimension type			    */
    int       dimView;	    	/* View used for text orientation	    */
    } DimParamInfo;

#endif /* resource */

#endif	/* __mdldimH__ */
