




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                          < 1986, 1987, 1988 >
  
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

/* COBshfn.h -- definitions needed for read_t_next, and COB */
#ifndef COBshfnh
#define COBshfnh


#define _max_data_union_str		515 /* 512 + 2 for "" + '\0' */


/* ---------- read t tokens ---------- */
#define _invalid_class	2
#define _tok_none	0
#define _tok_attr	1
#define _tok_start	2
#define _tok_stop	3
#define _tok_class	4
#define _tok_more_buttons 5

/* -------------- read_t_next() return codes ----------- */
#define RETURN_OK		 1
#define RETURN_RPAREN		 3
#define RETURN_QUOTE		 5
#define RETURN_DQUOTE		 7
#define RETURN_RPAREN_QUOTE	 9
#define RETURN_RPAREN_DQUOTE	11

#endif
