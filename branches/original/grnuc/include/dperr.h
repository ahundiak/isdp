




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

#ifndef dperr_include

#define	     dperr_include

#define DP_ERROR(msg)    ( !( (msg) & 1) )

#define      DPPHGSTD  0x08078014
#define      DPIGRSTD  0x0807801C
#define      DPVORANGE 0x08078024
#define      DPEVVRANG 0x0807802C  
#define      DPDUPLICNM 0x08078034
#define      DPVWCLOS  0x08078044
#define      DPCLPNCOM 0x0807804F
#define      DPCLPCOM  0x08078051
#define      DPVUPPRLVPN 0x0807805C
#define	     DPSTRKNCOM  0x08078067
#define      DPSTRKCOM   0x0807806F
#define	     DPWNGTYP    0x08078074
#define      DPCLPINRNG  0x0807807C
#define      DPCLPININ   0x08078084
#define      DPCLPINOUT  0x0807808C
#define      DPCLPINBUF  0x08078094
#define	     DPCLPINDEX	 0x0807809C
#define	     DPWNNODEF   0x080780A4
#define      DPVWSMNODEF 0x080780A3
#define      DPVWSNODEF  0x080780AB
#define      DPBADELETYP 0x080780BC
#define	     DPBADMODE   0x080780C4		
#define	     DPNOOBJECTS 0x080780C3
#define      DPAMBIGUOUS 0x080780CB
#define	     DPDGNMAXX   0x080780D3
#define      DPDGNEDGE   0x080780DB
#define      DPDGNMAXY   0x080780E3
#define      DPDGNLIMIT  0x080780EB
#define	     DPDGNSLIMIT 0x080780F3
#define	     DPNOFILE    0x080780D4		
#define	     DPINVINP    0x080780DC		
#define	     DPTRUNC     0x080780E4		
#define	     DPVWPTOOSM  0x080780FB   /* viewport too small */
#define	     DPSTOPDRAW	 0x08078103
#define      DPDDOUTDGN  0x0807810B
#define      DPCURPARAL  0x08078104
#define      DPCURPERSP  0x0807810C
#define      DPFRAMEACT	 	0x08078114
#define      DPNOFRAMES	 	0x0807811C
#define      DPINVREQUEST	0x08078124
#define      DPNOFDBCKBUF	0x0807812C
#define      DPNODYNMEM	 	0x08078134
#define      DPFRAMENOTACT	0x0807813C
#define      DPBUFTOOBIG	0x08078144
#define      DPINVFRAMENO	0x0807814C
#define      DPFRAMEMPTY	0x08078154

/*  the next error number is 0x08078158 | error code

    
    please update this number when you add an error code.
    If you have any questions consult the Display Package
    Error Codes handout or ask Rajesh 

    For information messages the last number should be a 3 or a B. 
    For fatal errors the last number should be a 4 or a C.
    For severe errors the last number shoud be a 2 or an A, 
    which will also cause a fail in an error check                 */


#endif
