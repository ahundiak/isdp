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
	COrlocksdef.h
\*/

/* Raster Index */
#define RGTRANSON       1  /* rg_prop */
#define RGTRANSOFF      2  /* rg_prop */
#define RGFASTDISP      3  /* rg_prop */
#define RGREGDISP       4  /* rg_prop */
#define RGBORDDISPON    5  /* rg_prop */
#define RGBORDDISPOFF   6  /* rg_prop */
#define RGGRIDLINEON	7  /* rg_prop */
#define RGGRIDLINEOFF   8  /* rg_prop */
#define RGAUTODEFON     9  /* rg_prop */
#define RGAUTODEFOFF    10 /* rg_prop */
#define RGFILLON        11
#define RGFILLOFF       12

/* Raster Graphics properties masks */
#define GRIS_TRANSPARENT 0x1
#define GRIS_FASTDIS 0x2
#define GRIS_FILED   0x4
#define GRIS_HIDDEN  0x8
#define GRIS_BORDDIS 0x10
#define GRIS_PARTDIS 0x20
#define GRIS_COMPOSITE	0x40

