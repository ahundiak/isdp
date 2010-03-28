 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\
	COattrdef.h
\*/

#ifndef COattrdef.h
#define COattrdef.h

/* Attribute Index */
#define COLOR           1
#define WEIGHT          2
#define STYLE           3
#define LEVEL           4
#define ANGLE           5
#define ANG2PTS         6
#define ANG3PTS         7
#define SCALE           8
#define SCALE3PTS       9
#define XSCALE          10
#define YSCALE          11
#define ZSCALE          12
#define ANGUNIT         13
#define DISUNIT         14
#define AREAUNIT	15
#define EPDELTA         16
#define APDELTA         17

/* Text Index */
#define TXFONT          31        
#define TXFRAC          32
#define TXSYMB          33
#define TXASCII         34
#define TXJUST          35
#define TXSIZE          36
#define TXWIDTH         37
#define TXHEIGHT        38  
#define CHARSPACE       39
#define LINESPACE       40
#define TXDIR           41

/* Error Codes */
#define COATTR_INVINP  1001
#define COATTR_INVASC  1003

/* Misc Definitions */
#define TRUE             1
#define FALSE            0
#define MAX_EVENTS       3
#define JUST_FORM_LABEL  1

#define LO_COLOR         1
#define HI_COLOR         511
#define LO_WEIGHT        0
#define HI_WEIGHT        31
#define LO_STYLE         0
#define HI_STYLE         7
#define LO_LAYER         0
#define HI_LAYER         1023
#define LO_JUST          0
#define HI_JUST          14
#define LO_SCALE         0
#define LO_SIZE          0

#endif
