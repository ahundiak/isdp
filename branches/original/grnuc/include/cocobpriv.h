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


#ifndef cocoord_include
#define cocoord_include

   /*
    *  Values are set such that they obey OM error msg 
    *  convetions:  Odd numbered codes indicate succecc; 
    *  Even numbered codes indicate failure or an error
    *  condition; values in the *  low order 3 bits have 
    *  the following interpretation:
    *
    *     Value       Meaning
    *  binary  hex
    *  ----------- -----------------------
    *   000    0,8    warning
    *   001    1,9    success
    *   010    2,A    error
    *   011    3,B    information/success
    *   100    4,C    severe error
    */

#  define   CO_I_INDEX_MAX         0xA00080EB
#  define   CO_I_INDEX_ZERO        0xA00080FB

#  define   ABSOLUTE               0   /* mytype for XY  */
#  define   DELTA                  1   /* mytype for DL  */

#  define   NAME_TYPE_SEPERATOR    ';'
#  define   DIR_CHAR               ':' /* KLUDGE - should be DIR_G_car_dir */

#  define   isdirchar( ch )        ( ch == DIR_CHAR || ch == '*' )         

#endif /* cocoord_include */

