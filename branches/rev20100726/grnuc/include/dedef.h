




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

#ifndef dedef_include
#define dedef_include

/*
 *    OMerrordef.h must be included before this file
 */

#define de_ret_setup(f,m,s) (((f)<<16) + 0x8000 + ((m)<<3) + (s))

/* detailing facility code */
#define DE_TAG    0x811
                                                                            
#define DE_LOCATE1             258   /* don't collide in cob action filter */
#define DE_LOCATE_NO_AUTO      259   /* don't collide in cob action filter */
#define DE_LOCATE2             260   /* don't collide in cob action filter */


#define DE_I_EXP_MATCHED_NO_WINDOW    135364619
/* expression did not match a window name */
/* de_ret_setup(DE_TAG,1,INFO) 0x811800b */


#define DE_I_TOO_MANY_WINDOWS        135364627
/* expression matched too many window names */
/*  de_ret_setup(DE_TAG,2,INFO) 0x8118013 */


#define DE_E_INV_CHAN_COUNT        135364634
/* the number of objects on a channel did not make sense  */
/* de_ret_setup(DE_TAG,3,ERRO) 0x811801a */


#define DE_E_NO_SOO_ON_WINDOW    135364642
/* the number of objects on a channel did not make sense */
/* de_ret_setup(DE_TAG,4,ERRO) 0x8118022 */


#endif /* dedef_include */
