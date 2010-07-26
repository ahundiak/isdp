




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

/* COB_args.h -- things needed for the CEO.arg_name_to_value method */
#ifndef COB_argsh
#define COB_argsh

typedef union
{
  char		  c;
  short		  s;
  int		  i;
  long		  l;
  unsigned char	 uc;
  unsigned short us;
  unsigned int	 ui;
  unsigned long	 ul;
  float		  f;
  double	  d;
  char		* p;
  OM_S_OBJID	oid;
}	COB_arg_union;

/*--------  address mode values for CEO.arg_name_to_value () -------*/
#define  _COB_address   (-1)
#define  _COB_regular	  0
#define  _COB_indirect    1
#define  _COB_indirect2   2

/*--------  value types for CEO.arg_name_to_value () -------*/
#define  _COB_UNKNOWN_ARG 0	/* Value was unknown to this cmd object */
#define  _COB_arg_c	  1	/* Value was of type char		*/
#define  _COB_arg_s       2	/* Value was of type short		*/
#define  _COB_arg_i	  3	/* Value was of type int		*/
#define  _COB_arg_l       4	/* Value was of type long		*/
#define  _COB_arg_uc	  5	/* Value was of type unsigned char	*/
#define  _COB_arg_us	  6	/* Value was of type unsigned short	*/
#define  _COB_arg_ui	  7	/* Value was of type unsigned int	*/
#define  _COB_arg_ul	  8	/* Value was of type unsigned long	*/
#define  _COB_arg_f	  9	/* Value was of type float		*/
#define  _COB_arg_d	 10	/* Value was of type double		*/
#define  _COB_arg_p	 11	/* Value was of type pointer to anything*/
#define  _COB_arg_oid	 12	/* Value was of type OM_S_OBJID		*/

#endif
