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


#ifndef toolco_include
#define toolco_include

/* 
 *  Assign and compare value types:
 * 
 *  str - string    int - integer   dbl - double
 *  btn - button    mtx - matrix    cin - constant int
 *  evt - event     msg - message key
 * 
 *  NOTE: all arguments should be pointers except cin and msg.
 */
#define CO_str_to_str       0
#define CO_str_to_evt       1   /* Not Supported Yet */
#define CO_dbl_to_dbl       2   
#define CO_dbl_to_int       3
#define CO_dbl_to_evt       4   /* Not Supported Yet */
#define CO_int_to_int       5
#define CO_int_to_dbl       6   
#define CO_int_to_evt       7   /* Not Supported Yet */
#define CO_cin_to_int       8
#define CO_cin_to_dbl       9
#define CO_cin_to_evt       11  /* Not Supported Yet */
#define CO_btn_to_btn       12
#define CO_btn_to_pnt       13
#define CO_btn_to_evt       14  /* Not Supported Yet */
#define CO_btn_to_grid      15
#define CO_btn_to_mtx       16
#define CO_evt_to_evt       17
#define CO_mtx_to_mtx       18

/* Weird but useful assign and compare types */
#define CO_gschan_to_grid   19  /* gr$gsget_simple_object */
#define CO_msg_to_str       20  /* Case Insensitive on Compare*/

/*
 *  Compare relation types:
 *
 *  gt - greater than   ge - greater than or equal to   
 *  eq - equal to       le - less than or equal to
 *  lt - less than      ne - not equal to 
 *
 *  NOTE: Only type 'CO_eq' is valid for button/button, button/point and 
 *        matrix/matrix compares.
 */
#define CO_gt               1
#define CO_ge               3
#define CO_eq               5
#define CO_le               7
#define CO_lt               9
#define CO_ne               11

/*
 * Return Messages
 */
#define CO_no_file           0x00000
#define CO_file_exists       0x00001
#define CO_file_dir          0x00002
#define CO_file_reg          0x00004
#define CO_file_design       0x00008 /* Not Supported */
#define CO_file_cell         0x00010 /* Not Supported */
#define CO_file_read         0x00020
#define CO_file_write        0x00040
#define CO_file_execute      0x00080

#endif
