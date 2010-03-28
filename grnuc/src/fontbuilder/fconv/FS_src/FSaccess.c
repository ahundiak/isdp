/*************************** F F _ A C C E S S . C ****************************
 ********************** R E V I S I O N   H I S T O R Y ***********************

  (1):  22-SEPT-87  sew creation.


******************************************************************************
    The structures 'FF_outl_str', 'cft_block_hdr', 'cft_font_hdr',
    cft_kern_pair_rec', 'cft_trk_kern_rec', and 'cft_chardir_rec' are
    defined in the file 'FFstructs.h'
******************************************************************************/

#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <math.h>
#include <tools.h>
#include <itools.h>
#include "FSBmap.h"
#include "FFdef.h"
#include "FFstructs.h"
#include "FFerrdef.h"

typedef unsigned short UShort;
typedef unsigned int   UInt;


/* Determines internal state of get_rec channel n
    Bits 31-24  Bits 23-16   Bits 15-8    Bits 7-0
       00         00            00           00       Nothing to do
       01         00            00        MS 4 bits   Xmax extent data
       02         00            00        MS 4 bits   Ymax extent data
       03         00            00        No values   Outline hierarchy data
*/

	static   unsigned int    state[5];
	static   unsigned short  repeat_active[5];
	static            int    current_x[5];
	static            int    current_y[5];
	static   unsigned short  ret_count[5];
	static   unsigned short  ret_offset[5];
	static   unsigned short *pxedges[5];
	static   unsigned short *pyedges[5];
	static   unsigned int    saved_state;
	static   unsigned short  saved_repeat_active;
	static   unsigned short  saved_ret_count;
	static   unsigned short  saved_ret_offset;
	static            int    saved_current_x;
	static            int    saved_current_y;
	static   unsigned short *saved_pxedges;
	static   unsigned short *saved_pyedges;
	static   int    acc_mantissa    = 0;
	static   int    acc_exponent    = 0;
	static   short  acc_dec_pt_read = 0;
	static   short  acc_sign        = 0;
	static   short  acc_term_read   = 0;



/*****************************************************************************
 *                                                                           *
 *             Routines for unpacking compressed outline data                *
 *                                                                           *
 *****************************************************************************/


/* Initializes get_rec state for channel n */

 void FSinitRecState( chan )

   int chan;

{
   state[chan]         = 0;
   repeat_active[chan] = 0;
   current_x[chan]     = 0;
   current_y[chan]     = 0;

}

/*****************************************************************************
 *                                                                           *
 *                    Saves get_rec state for channel n                      *
 *                                                                           *
 *****************************************************************************/

 FSsaveRecState( chan )

   int  chan;

{
   saved_state         = state[chan];
   saved_repeat_active = repeat_active[chan];
   saved_ret_count     = ret_count[chan];
   saved_ret_offset    = ret_offset[chan];
   saved_current_x     = current_x[chan];
   saved_current_y     = current_y[chan];
   saved_pxedges       = pxedges[chan];
   saved_pyedges       = pyedges[chan];

}




/*****************************************************************************
 *                                                                           *
 *                   Restores get_rec state for channel n                    *
 *                                                                           *
 *****************************************************************************/

 FSrestoreRecState( chan )

   int   chan;

{
   state[chan]         = saved_state;
   repeat_active[chan] = saved_repeat_active;
   ret_count[chan]     = saved_ret_count;
   ret_offset[chan]    = saved_ret_offset;
   current_x[chan]     = saved_current_x;
   current_y[chan]     = saved_current_y;
   pxedges[chan]       = saved_pxedges;
   pyedges[chan]       = saved_pyedges;
}


/******************************************************************************
 * get_rec fetches the next logical step from compressed outline data.        *
 * Sets *ptype to indicate type of step read.                                 *
 *                                                                            *
 * -1: erroneous step read.                                                   *
 *                                                                            *
 *  0: end of character or call while repeat active.                          *
 *       e3 record one word.                                                  *
 *                                                                            *
 *  1: Move to or start outline (*px, *py).                                   *
 *       f0 record three words                                                *
 *                                                                            *
 *  2: Vector to (*px, *py).                                                  *
 *       bits 0 and 1 are 10.  Short vector two word record.                  *
 *       E0 record.  Long vector three words.                                 *
 *                                                                            *
 *  3: Horizontal vector to (*px, *py).                                       *
 *       bits 0 & 1 are 00. One word record.                                  *
 *                                                                            *
 *  4: Vertical vector to (*px, *py).                                         *
 *       bits 0 & 1 are 01. One word record.                                  *
 *                                                                            *
 *  5: Arc to (*px, *py) with bulge factor *pbeta.                            *
 *       bits 0 1 and 2 are 110. Short arc two word record.                   *
 *       e1 long arc three word record.                                       *
 *                                                                            *
 *  6: Set scale factors to *px, *py (units of 1/65536).                      *
 *       f3 record three words.                                               *
 *                                                                            *
 *  7: Set new position or set origin to (*px, *py).                          *
 *       f2 record three words.                                               *
 *                                                                            *
 *  8: Set x min extent (*px).                                                *
 *  9: Set x max extent (*px).                                                *
 *     f5 record is 3 words. Contains the x min and max.                      *
 *                                                                            *
 * 10: Set y min extent (*py).                                                *
 * 11: Set y max extent (*py).                                                *
 *       f6 record is 3 words. Contains the x min and max.                    *
 *                                                                            *
 * 12: Do char (*px).                                                         *
 *       f4 record two words.                                                 *
 *                                                                            *
 * 13: Hierarchy header record (*px).                                         *
 *       f9 record one word header.                                           *
 *                                                                            *
 * 14: End Outline record.                                                    *
 *       f1 record one word.                                                  *
 *                                                                            *
 * 15: Call Repeat Sequence.                                                  *
 *       e2 record two words.                                                 *
 *                                                                            *
 * 16: Hierarchy record. From f9 header record.                               *
 *       from f9 header record, One word record.                              *
 *                                                                            *
 * 17: Plaid zone definitions.                                                *
 *                                                                            *
 * 18: Plaid X Zone Edge. px is starting co_ord, py is ending co_ord,         *
 *        *pbeta is P, L, C, function flags and minumum pixels.               *
 *     f7   record 1 word  - (N words,N= 1 + <# of x-edges> + <# of y-edges>) *
 *     fff0 record 2 words - (N words,N= 2 + <# of x-edges> + <# of y-edges>) *
 *           Bits 31-16   Not used                                            *
 *           Bit  15      P flag                                              *
 *           Bit  14      L flag                                              *
 *           Bit  13      C flag                                              *
 *           Bits 12-11   Function flag:                                      *
 *                            0: No function items                            *
 *                            1: 1 function item follows                      *
 *                            2: Not used                                     *
 *                            3: 2 or more function items follow terminated   *
 *                                   by an op item with termination flag on   *
 *           Bits 10-8    Not used                                            *
 *           Bits  7-0    Minumum value                                       *
 *                                                                            *
 * 19:    Plaid Y Zone Edge. px is starting co-ord, py is ending co-ord,      *
 *        *pbeta is P, L, C function flags and minimum pixels.                *
 *    fa   record 1 word  - (N words,N= 1+2*(<# of x-edges> + <# of y-edges>))*
 *    fff1 record 2 words - (N words,N= 2+2*(<# of x-edges> + <# of y-edges>))*
 *           Bits 31-16   Not used                                            *
 *           Bit  15      P flag                                              *
 *           Bit  14      L flag                                              *
 *           Bit  13      C flag                                              *
 *           Bits 12-11   Function flag:                                      *
 *                            0: No function items                            *
 *                            1: 1 function item follows                      *
 *                            2: Not used                                     *
 *                            3: 2 or more function items follow terminated   *
 *                                   by an op item with termination flag on   *
 *           Bits 10-8    Not used                                            *
 *           Bits  7-0    Minumum value                                       *
 *                                                                            *
 * 20: Plaid zone hierarchy header.                                           *
 *    f8   record 1 word.  Plaid zone definitions follows, 1 word each.       *
 *    fff2 record 2 words. plaid zone                                         *
 *                                                                            *
 * 21: P function item. px = character num., py = dim * 256 + zone number.    *
 *    bits 0 & 1 = 00  record 1 word                                          *
 *    f0  record 2 words                                                      *
 *                                                                            *
 * 22: F function item. px = character num., py = dim * 256 + zone number.    *
 *    bits 0 & 1 = 01 - record 1 word                                         *
 *    f1  record 2 words                                                      *
 *                                                                            *
 * 23: C function item. px = value., py = decimal exponent                    *
 *    8 record C2 C1 and C0 represent up to three decimal digits              *
 *    9 record C6 C5 C4 C3 C2 C1 and C0 represent up to seven decimal digits  *
 *    a record C10 C9 C8 C7 C6 C5 C4 C3 C2 C1 and C0 rep. up to 11 dec. digits*
 *                                                                            *
 * 24: Plaid T Function Item.                                                 *
 *        *px is character number, *py is dim * 256 + zone number.            *
 *    f2 record 2 words.                                                      *
 *                                                                            *
 * 25: Plaid Operation  Item (1 words)   *px is op code:                      *
 *    bits 0 1 and 2 are 110. record is 1 word.                               *
 *           0: NOP function                                                  *
 *           1: ADD function                                                  *
 *           2: SUB function                                                  *
 *           3: MUL function                                                  *
 *           4: DIV function                                                  *
 *           5: PRINT function                                                *
 *           6: FIXR function (round to nearest integer)                      *
 *           7: FIX function (round to next lowest integer)                   *
 *           8: CO function                                                   *
 *           9: CF function                                                   *
 *          10: RRFS function                                                 *
 *          11: RRHS function                                                 *
 *          12: RRFS1 function                                                *
 *          13: RRHS1 function                                                *
 *          14: BZON function                                                 *
 *          15: BZON1 function                                                *
 *          16: LZON function                                                 *
 *          17: LZON1 function                                                *
 *          18: CFFLB function                                                *
 *          19: CFFRB function                                                *
 *          20: CFSLB function                                                *
 *          21: CFSRB function                                                *
 *          22: XHT_ADJ function                                              *
 *                                                                            *
 *   for all op codes, *pbeta indicates if last item in function:             *
 *           Bits 31-1    Not used                                            *
 *           Bit   0      Termination flag:                                   *
 *                            0: Not last function item                       *
 *                            1: Last function item                           *
 *****************************************************************************/

 int FSget_rec(n, pprec, pdata_origin, ptype, px, py, pbeta,
                       num_recs)

            int     n;               /* Environment number                   */
   unsigned short **pprec;           /* Current record in character data     */
   unsigned short  *pdata_origin;    /* First data record in character data  */
            short  *ptype;           /* Returned record type                 */
            int    *px;              /* Returned value x                     */
            int    *py;              /* Returned value y                     */
            int    *pbeta;           /* Returned value beta                  */
            int    *num_recs;        /* the record number being read         */

{

   unsigned short   *prec, first_word, second_word, third_word, fourth_word;
   unsigned short   char_no, dim, zone_no, from, to, plc,
                    op_code, fsize, mini;
            int     xinc, yinc;
   unsigned int     status;
   unsigned short   rec_type;
            int     FFis_c_zone();
            int     FFis_c_p_item(), FFis_c_f_item(), FFis_c_t_item();
            int     FFis_c_const_item(), FFis_c_op_item();
            long   *x_edgeptr, *y_edgeptr;

   static unsigned short term_flag = 0;
   static          short   prev_ptype;


   status = FF_S_SUCCESS;

   if (state[n]) {                               /* Outstanding data to read */
       if ((state[n] & 0xff000000) == EXTENT_X) { /* X extent data         */
           *ptype      = prev_ptype = 9;
            prec       = *pprec;
           *px         = (((int)state[n]) << 28 >> 12) + *prec;
           *py         = 0;
           *pbeta      = 0;
           state[n]    = 0;
           *num_recs  += 1;
           FSnext_step(pprec, pdata_origin, n, 1);
           return ( status );
           }

       if ((state[n] & 0xff000000) == EXTENT_Y) {  /* Y extent data        */
           *ptype      = prev_ptype = 11;
            prec       = *pprec;
           *py         = (((int)state[n]) << 28 >> 12) + *prec;
           *px         = 0;
           *pbeta      = 0;
           state[n]    = 0;
           *num_recs  +=1;
           FSnext_step(pprec, pdata_origin, n, 1);
           return( status );
           }

       if ((state[n] & 0xff000000) == HIER_VALUE){ /*Outline hierarchy values*/
           *ptype      = prev_ptype = 13;
            prec       = *pprec;
           *px         = (int)(*prec);
           *py         = 0;
           *pbeta      = 0;
           (*pprec)++;
           (state[n])--;
           if ((state[n] & 0x000000ff) == 0)
               state[n] = 0;
           *num_recs +=1;
           return( status );
           }

       if ((state[n] & 0xfc000000) == PLAID_ZONE_DATA)  {  /* Plaid zone data     */
           fsize = state[n] & 0x000000ff;
           if (fsize) {                               /* Function items      */
               term_flag = 0;
               if(FSis_c_p_item(pprec, &char_no, &dim, &zone_no, num_recs)) {
                   *px         = char_no;
                   *py         = (dim << 8) + zone_no;
                   *pbeta      = 0;
                   *ptype      = prev_ptype = 21;
                   }
               else if(FSis_c_f_item(pprec, &char_no, &dim, &zone_no, num_recs)) {
                   *px         = char_no;
                   *py         = (dim << 8) + zone_no;
                   *pbeta      = 0;
                   *ptype      = prev_ptype = 22;
                   }
               else if(FSis_c_const_item(pprec, px, py, num_recs)) {
                   *ptype      = prev_ptype = 23;
                   *px         = 0;
                   *py         = 0;
                   *pbeta      = 0;
                   }
               else if(FSis_c_op_item(pprec, &op_code, &term_flag, num_recs)) {
                   *ptype      = prev_ptype = 25;
                   *px         = op_code;
                   *py         = 0;
                   *pbeta      = term_flag;
                   }
               else if(FSis_c_t_item(pprec, &char_no, &dim, &zone_no, num_recs)) {
                   *ptype      = prev_ptype = 24;
                   *px         = char_no;
                   *py         = (dim << 8) + zone_no;
                   *pbeta      = 0;
                   }
               else {
                   *ptype      = prev_ptype = -1;
                   *px         = 0;
                   *py         = 0;
                   *pbeta      = 0;
                   status     = FF_FONT_PLAID_FUNC_ERROR + WARN;
                   FF_report_error( status );
                   fprintf(stderr,"%s%8x/n","get_rec():   state = ", state[n]);
                   fprintf(stderr,"%s%8x/n","get_rec(): address = ", *pprec);
                   }
               if (fsize < 3)
                   state[n]--;
               if (term_flag)
                   state[n] = state[n] & 0xffffff00;
               if ((state[n] & 0x00ffffff) == 0)
                   state[n] = 0;
               return( status );
               }

           if (state[n] & PLAID_X_ZONES) {               /* x zones             */
               if(FSis_c_zone(pprec, &from, &to, &plc, &mini, &fsize, num_recs)) {
                   if(state[n] & 0x01000000) {       /* 32 bit edge values? */
                       *px  = ((int)pxedges[n][from << 1]) << 16;
                       *px += pxedges[n][(from << 1) + 1];
                       *py  = ((int)pxedges[n][to << 1]) << 16;
                       *py += pxedges[n][(to << 1) + 1];
                       }
                   else {
                       *px = ((int)pxedges[n][from]) << 16 >> 16;
                       *py = ((int)pxedges[n][to]) << 16 >> 16;
                       }
                   *pbeta = (plc << 13) + (fsize << 11) + mini;
                   *ptype = prev_ptype = 18;
                   }
               else {
                   *ptype      = prev_ptype = -1;
                   *px         = 0;
                   *py         = 0;
                   *pbeta      = 0;
                    status     = FF_FONT_PLAID_ZONE_ERROR + WARN;
                    FF_report_error( status );
                   fprintf(stderr,"%s%8x/n","get_rec():     state = ", state[n]);
                   fprintf(stderr,"%s%8x/n","get_rec(): X - address = ", *pprec);
                   }
               state[n] = state[n] - 0x00010000 + fsize;
               if ((state[n] & 0x00ffffff) == 0)
                   state[n] = 0;
               return( status );
               }

            if (state[n] & PLAID_Y_ZONES) {              /* y zones             */
               if(FSis_c_zone(pprec, &from, &to, &plc, &mini, &fsize, num_recs)) {
                   if (state[n] & 0x01000000) {       /* 32 bit edge values? */
                       *px  = ((int)pyedges[n][from << 1]) << 16;
                       *px += pyedges[n][(from << 1) + 1];
                       *py  = ((int)pyedges[n][to << 1]) << 16;
                       *py += pyedges[n][(to << 1) + 1];
                       }
                   else {
                       *px = ((int)pyedges[n][from]) << 16 >> 16;
                       *py = ((int)pyedges[n][to]) << 16 >> 16;
                       }
                   *pbeta      = (plc << 13) + (fsize << 11) + mini;
                   *ptype      = prev_ptype = 19;
                   }
               else {
                   *ptype      = prev_ptype = -1;
                   *px         = 0;
                   *py         = 0;
                   *pbeta      = 0;
                    status     = FF_FONT_PLAID_ZONE_ERROR + WARN;
                    FF_report_error( status );
                   fprintf(stderr,"%s%8x/n","get_rec():     state = ", state[n]);
                   fprintf(stderr,"%s%8x/n","get_rec(): Y - address = ", *pprec);
                   }
               state[n] = state[n] - 0x00000100 + fsize;
               if ((state[n] & 0x00ffffff) == 0)
                   state[n] = 0;
               return ( status );
               }
           }
        *ptype      = prev_ptype = -1;
        *px         = 0;
        *py         = 0;
        *pbeta      = 0;
         status     = FF_FONT_OUTL_STATE_ERROR + WARN;
         FF_report_error( status );
         fprintf(stderr,"%s%8x/n","get_rec():   state = ", state[n]);
         fprintf(stderr,"%s%8x/n","get_rec(): address = ", *pprec);
         return( status );
         }
   prec       = *pprec;
   first_word = *prec;
   if (      ((first_word & 0xc000) == HORZ_VECT)
         ||  ((first_word & 0xc000) == VERT_VECT)
         ||  ((first_word & 0xc000) == SHORT_VECT) )
       rec_type = first_word >> 14 << 14;
     else if ((first_word & 0xe000) == SHORT_ARC)
       rec_type = first_word >> 13 << 13;
     else if (  ((first_word & 0xff00) == LONG_VECT)
             || ((first_word & 0xff00) == LONG_ARC)
             || ((first_word & 0xff00) == CALL_CODE)
             || ((first_word & 0xff00) == END_CHAR)
             || ((first_word & 0xff00) == MOVE_TO)
             || ((first_word & 0xff00) == END_OUTL)
             || ((first_word & 0xff00) == NEW_ORIG)
             || ((first_word & 0xff00) == NEW_SCALE)
             || ((first_word & 0xff00) == DO_CHAR)
             || ((first_word & 0xff00) == MIN_MAX_X)
             || ((first_word & 0xff00) == MIN_MAX_Y)
             || ((first_word & 0xff00) == P_15_16BIT_EDGE)
             || ((first_word & 0xff00) == PLAID_15_HIER)
             || ((first_word & 0xff00) == HIER_HEAD) 
             || ((first_word & 0xff00) == P_15_32BIT_EDGE) )
       rec_type = first_word >> 8 << 8;
     else if (  ((first_word & 0xffff) == P_255_16BIT_EDGE)
             || ((first_word & 0xffff) == P_255_32BIT_EDGE)
             || ((first_word & 0xffff) == PLAID_255_HIER) )
       rec_type = first_word;
     else {
       *ptype        = prev_ptype = -1;
       *px           = 0;
       *py           = 0;
       *pbeta        = 0;
       *num_recs     = *num_recs + 1;
       status = FF_FONT_OUTL_REC_ERROR + WARN;
       printf("%s%4x\n","get_rec(): record = ",first_word);
       printf("%s%8x\n","          address = ",*pprec);
       FSnext_step(pprec, pdata_origin, n, 1);
       FF_report_error( status );
       return( status );
       }

     switch ( rec_type ) {     
        case HORZ_VECT :                             /* Horizontal vector code */
           *ptype        = prev_ptype = 3;
           xinc          = ((int)(first_word & 0x3fff)) << 18 >> 18;
           current_x[n] += xinc;
           *px           = current_x[n];
           *py           = current_y[n];
           *pbeta        = 0;
           *num_recs     = *num_recs + 1;
           FSnext_step(pprec, pdata_origin, n, 1);
           break;

        case VERT_VECT :                               /* Vertical vector code */
           *ptype        = prev_ptype = 4;
           *px           = current_x[n];
           yinc          = ((int)(first_word & 0x3fff)) << 18 >> 18;
           current_y[n] += yinc;
           *py           = current_y[n];
           *pbeta        = 0;
           *num_recs     = *num_recs + 1;
           FSnext_step(pprec, pdata_origin, n, 1);
           break;

        case SHORT_VECT :                                  /* Short vector code */
           *ptype        = prev_ptype = 2;
           xinc          = ((int)(first_word & 0x3fff)) << 18 >> 18;
           current_x[n] += xinc;
           *px           = current_x[n];
           prec++;
           second_word   = *prec;
           yinc          = ((int)(second_word)) << 16 >> 16;
           current_y[n] += yinc;
           *py           = current_y[n];
           *pbeta        = 0;
           *num_recs     = *num_recs + 2;
           FSnext_step(pprec, pdata_origin, n, 2);
           break;

        case SHORT_ARC :                                    /* Short arc code */
           *ptype        = prev_ptype = 5;
           prec++;
           second_word   = *prec;
           xinc          = (((int)first_word) << 22 >> 22);
           current_x[n] += xinc;
           *px           = current_x[n];
           yinc          = (((int)second_word)  << 22 >> 22);
           current_y[n] += yinc;
           *py           = current_y[n];
           *pbeta        = ((((int)first_word) >> 10 << 16)
                           + second_word) >> 10 << 23;
           *num_recs     = *num_recs + 2;
           FSnext_step(pprec, pdata_origin, n, 2);
           break;

        case LONG_VECT :                                   /* Long vector code */
           *ptype        = prev_ptype = 2;
           prec++;
           second_word   = *prec;
           xinc          = (((int)first_word) >> 4 << 28 >> 12) + second_word;
           current_x[n] += xinc;
           *px           = current_x[n];
           prec++;
           third_word    = *prec;
           yinc          = (((int)first_word)  << 28 >> 12) + third_word;
           current_y[n] += yinc;
           *py           = current_y[n];
           *pbeta        = 0;
           *num_recs     = *num_recs + 3;
           FSnext_step(pprec, pdata_origin, n, 3);
           break;

        case LONG_ARC :                                       /* Long arc code */
           *ptype        = prev_ptype = 5;
           prec++;
           second_word   = *prec;
           xinc          = (((int)first_word) >> 4 << 28 >> 12) + second_word;
           current_x[n] += xinc;
           *px           = current_x[n];
           prec++;
           third_word    = *prec;
           yinc          = (((int)first_word)  << 28 >> 12) + third_word;
           current_y[n] += yinc;
           *py           = current_y[n];
           prec++;
           fourth_word   = *prec;
           *pbeta        = ((int)fourth_word) << 16;
           *num_recs     = *num_recs + 4;
           FSnext_step(pprec, pdata_origin, n, 4);
           break;

        case CALL_CODE :                                         /* Call code */
           if (repeat_active[n]) {          /* Call code during repeat */
               *ptype     = prev_ptype = 0;
               *px        = 0;
               *py        = 0;
               *pbeta     = 0;
               *num_recs  = *num_recs + 1;
               break;
               }
             else {                                 /* Initialize step count */
               ret_count[n]  = first_word & 0x00ff;
               if (ret_count[n] == 0) {    /* Ignore if step count = 0 */
                   *ptype     = prev_ptype = -1;
                   *pprec    += 2;
                   *num_recs  = *num_recs + 2;
                   *px        = 0;
                   *py        = 0;
                   *pbeta     = 0;
                   break;
                   }
               *ptype           = prev_ptype = 15;
               ret_offset[n]    = *pprec + 2 - pdata_origin;    /*Save ret addr*/
               *px              = (*(*pprec + 1));
               *pprec           = pdata_origin+(*(*pprec + 1)); /*Set nxt addr*/
               repeat_active[n] = 1;
               *num_recs        = *num_recs + 2;
               *py              = 0;
               *pbeta           = 0;
               }
           break;

        case END_CHAR :                                      /* End char code  */
           *ptype     = prev_ptype = 0;
           *px        = 0;
           *py        = 0;
           *pbeta     = 0;
           *num_recs  = *num_recs + 1;
           FSnext_step(pprec, pdata_origin, n, 1);
           break;

        case MOVE_TO :                                          /* Move code */
           *ptype       = prev_ptype = 1;
           prec++;
           second_word  = *prec;
           current_x[n] = (((int)first_word) >> 4 << 28 >> 12) + second_word;
           *px          = current_x[n];
           prec++;
           third_word   = *prec;
           current_y[n] = (((int)first_word)  << 28 >> 12) + third_word;
           *py          = current_y[n];
           *pbeta       = 0;
           *num_recs    = *num_recs + 3;
           FSnext_step(pprec, pdata_origin, n, 3);
           break;

        case END_OUTL :                                     /* End outline code */
           *ptype     = prev_ptype = 14;
           *pprec    += 1;
           *num_recs  = *num_recs + 1;
           *px        = 0;
           *py        = 0;
           *pbeta     = 0;
           break;

        case NEW_ORIG :                                  /* Set position code */
           *ptype      = prev_ptype = 7;
           prec++;
           second_word = *prec;
           *px         = (((int)first_word) >> 4 << 28 >> 12) + second_word;
           prec++;
           third_word  = *prec;
           *py         = (((int)first_word)  << 28 >> 12) + third_word;
           *pbeta      = 0;
           *num_recs   = *num_recs + 3;
           FSnext_step(pprec, pdata_origin, n, 3);
           break;

        case NEW_SCALE :                             /* Set scale factors code */
           *ptype      = prev_ptype = 6;
           prec++;
           second_word = *prec;
           *px         = (((int)second_word) << 16 >> 12);
           prec++;
           third_word  = *prec;
           *py         = (((int)third_word)  << 16 >> 12);
           *pbeta      = 0;
           *num_recs   = *num_recs + 3;
           FSnext_step(pprec, pdata_origin, n, 3);
           break;

        case DO_CHAR :                                        /* Do char code */
           *ptype      = prev_ptype = 12;
           prec++;
           second_word = *prec;
           *px         = second_word;
           *py         = 0;
           *pbeta      = 0;
           *num_recs   = *num_recs + 2;
           FSnext_step(pprec, pdata_origin, n, 2);
           break;

        case MIN_MAX_X :                              /* minimum X extents code */
           *ptype        = prev_ptype = 8;
           prec++;
           second_word   = *prec;
           *px           = (((int)first_word) >> 4 << 28 >> 12) + second_word;
           *py           = 0;
           *pbeta        = 0;
           state[n]      = 0x01000000 + (first_word & 0x000f);
           *pprec       += 2;
           *num_recs     = *num_recs + 3;
           break;

        case MIN_MAX_Y :                             /* minimum Y extents code */
           *ptype        = prev_ptype = 10;
           prec++;
           second_word   = *prec;
           *px           = 0;
           *pbeta        = 0;
           *py           = (((int)first_word) >> 4 << 28 >> 12) + second_word;
           state[n]      = 0x02000000 + (first_word & 0x000f);
           *pprec       += 2;
           *num_recs     = *num_recs + 3;
           break;

        case P_15_16BIT_EDGE : /* (N words, N = 1 + <# of x-edges> + <# of y-edges>)) */
           *ptype        = prev_ptype = 18;      /* Plaid Zone Edge Definitions */
           pxedges[n]    = *pprec += 1;
           pyedges[n]    = *pprec += (first_word & 0x00f0) >> 4;
           *pprec       += first_word & 0x000f;
           *px           = (first_word & 0x00f0) >> 4;
           *py           = (first_word & 0x000f);
           *pbeta        = 0;
           break;

        case PLAID_15_HIER :                     /* Plaid zone hierarchy header */
           if (prev_ptype == 18) {
               state[n] =    0x04000000
                           + ((unsigned int)(**pprec & 0x00f0) << 12)
                           + ((**pprec & 0x000f) << 8);
               *px    = (int)pxedges[n];
               *py    = (int)pyedges[n];
               *pbeta = (int)state[n];
               }
             else if ( prev_ptype == 19 ) {
               state[n] =    0x05000000
                           + ((unsigned int)(**pprec & 0x00f0) << 12)
                           + ((**pprec & 0x000f) << 8);
               *px    = (int)pxedges[n];
               *py    = (int)pyedges[n];
               *pbeta = (int)state[n];
               }
           (*pprec)++;
           if( (state[n] & 0x00ffffff) == 0 )
              state[n] = 0;
           *ptype = prev_ptype = 20;
           break;

        case HIER_HEAD :                               /* Hierarchy values code */
           *ptype        = prev_ptype = 16;
           state[n]      = 0x03000000 + (first_word & 0x00ff);
           (*pprec)++;

           if ((state[n] & 0x00ffffff) == 0)
               state[n] = 0;

           *num_recs    = *num_recs + ((int)(first_word & 0x00ff) + 1);
           *px          = (int)(first_word & 0x00ff);
           *py          = 0;
           *pbeta       = 0;
           break;

        case P_15_32BIT_EDGE : /* (N words,N = 1+2 * (<# of x-edges> + <# of y-edges>)) */
           *ptype        = prev_ptype = 19;      /* Plaid Zone Edge Definitions */
           pxedges[n]    = *pprec += 1;
           pyedges[n]    = *pprec += (first_word & 0x00f0) >> 3;
           *pprec       += (first_word & 0x000f) << 1;
           *px           = (int)pxedges[n];
           *py           = (int)pyedges[n];
           *pbeta        = 0;
           break;

        case P_255_16BIT_EDGE :   /* (N words,N = 2 + <# of x-edges> + <# of y-edges>) */
           *ptype        = prev_ptype = 18;    /* Plaid X Zone Edge Definitions */
           second_word   = *(*pprec + 1);
           pxedges[n]    = *pprec += 2;
           pyedges[n]    = *pprec += (second_word & 0xff00) >> 8;
           *pprec       += (second_word & 0x00ff);
           *px           = (int)pxedges[n];
           *py           = (int)pyedges[n];
           *pbeta        = 0;
           break;

        case P_255_32BIT_EDGE : /* (N words,N= 2+2*( <# of x-edges> + <# of y-edges>)) */
           *ptype        = prev_ptype = 19;    /* Plaid Y Zone Edge Definitions */
           second_word   = *(*pprec + 1);
           pxedges[n]    = *pprec += 2;
           pyedges[n]    = *pprec += (second_word & 0xff00) >> 8;
           *pprec       += second_word & 0x00ff;
           *px           = (int)pxedges[n];
           *py           = (int)pyedges[n];
           *pbeta        = 0;
           break;

        case PLAID_255_HIER: /* plaid zone hierarchy header */
           (*pprec)++;
           if ( prev_ptype == 18) {
               state[n] =  0x04000000
                          +((unsigned int)((**pprec & 0xff00)
                                         + (**pprec & 0x00ff)) << 8);
               *px    = state[n];
               *py    = 0;
               *pbeta = 0;
               }
             else if ( prev_ptype == 19) { 
               state[n] =  0x05000000
                          +((unsigned int)((**pprec & 0xff00)
                                         + (**pprec & 0x00ff)) << 8);
               *px    = 0;
               *py    = state[n];
               *pbeta = 0;
               }

           (*pprec)++;

           if ((state[n] & 0x00ffffff) == 0)
              state[n] = 0;

           *ptype = prev_ptype = 20;
           break;

        default :                             /*   **** !!!! ERROR !!!! **** */
           break;

        }

   return ( status );

data_error :
   *ptype         = -1;
    prev_ptype    = *ptype;
    *px           = 0;
    *py           = 0;
    *pbeta        = 0;
    *num_recs     = *num_recs + 1;
    status = FF_FONT_OUTL_REC_ERROR + WARN;
    FSnext_step(pprec, pdata_origin, n, 1);
    return( status );

}





FSput_rec(n, pprec, pdata_origin, outl_rec, num_recs )

   unsigned short   n;               /* Environment number                   */
   unsigned short **pprec;           /* Current record in character data     */
   unsigned short  *pdata_origin;    /* First data record in character data  */
   FF_outl_recs   **outl_rec;
            int    *num_recs;        /* the record number being read         */

{

   unsigned int     status, count1, count2;
   unsigned short  *prec, *head_rec, num_vals;
   unsigned char   *chr;
   FF_outl_recs    *outlrec, *outl_ptr;

   status  = FF_S_SUCCESS;
   prec    = *pprec;
   outlrec = *outl_rec;
   
     switch ( outlrec->rec_type ) {     
        case HORZ_VECT :                              /* Horizontal vector code */
           *prec   = (((UShort)outlrec->px) << 2 >> 2) & 0x3fff;
           prec++;
           *pprec  = prec;
           *num_recs++;
           *outl_rec = outlrec + 1;
           break;

        case VERT_VECT :                               /* Vertical vector code */
          *prec   = (((UShort)outlrec->py) << 2 >> 2) & 0x3fff;
          *prec   = 0x4000 | *prec;
           prec++;
           *pprec = prec;
           *num_recs++;
           *outl_rec = outlrec + 1;
           break;

        case SHORT_VECT :                                  /* Short vector code */
           *prec      = (((UShort)outlrec->px) << 2 >> 2) & 0x3fff;
           *prec     = 0x8000 | *prec;
           prec++;
           *prec      = (UShort)outlrec->py;
           prec++;
           *pprec     = prec;
           *num_recs += 2;
           *outl_rec = outlrec + 1;
           break;

        case SHORT_ARC :                                      /* Short arc code */
           *prec   = ((UShort)(outlrec->pbeta >> 29 << 10));
           *prec  += (((UShort)outlrec->px) << 6 >> 6) & 0x1fff;
           *prec   = 0xc000 | *prec;
           prec++;
           *prec   = (UShort)((outlrec->pbeta << 3 >> 16));
           *prec  += (((UShort)outlrec->py) << 6 >> 6);
           prec++;
           *pprec     = prec;
           *num_recs += 2;
           *outl_rec  = outlrec + 1;
           break;


        case LONG_VECT :                                    /* Long vector code */
           *prec += (UShort)(0x000000f0 & ((UInt)outlrec->px << 12 >> 24));
           *prec += (UShort)(0x0000000f & ((UInt)outlrec->py << 12 >> 28)) & 0x00ff;
           *prec  = 0xe000 | *prec;
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->px << 16 >> 16));
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->py << 16 >> 16));
           prec++;
           *pprec = prec;
           *num_recs += 3;
           *outl_rec = outlrec + 1;
           break;

        case LONG_ARC :                                       /* Long arc code */
           *prec += (UShort)(0x000000f0 & ((UInt)outlrec->px << 12 >> 24));
           *prec += (UShort)(0x0000000f & ((UInt)outlrec->py << 12 >> 28)) & 0x00ff;
           *prec  = 0xe100 | *prec;
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->px << 16 >> 16));
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->py << 16 >> 16));
           prec++;
           *prec  = (UShort)(outlrec->pbeta >> 16);
           prec++;
           *pprec = prec;
           *num_recs += 3;
           *outl_rec = outlrec + 1;
           break;

        case END_CHAR :                                      /* End char code  */
        case END_OUTL :                                    /* end outline code */
           *prec  = 0xe300;
           prec++;
           *pprec = prec;
           *num_recs++;
           *outl_rec = outlrec + 1;
           break;

        case MOVE_TO  :                                    /* Move code         */
        case NEW_ORIG :                                    /* Set position code */
           *prec  = 0xf000;
           *prec  = (UShort)(0x000000f0 & ((UInt)outlrec->px << 12 >> 24));
           *prec += (UShort)(0x0000000f & ((UInt)outlrec->py << 12 >> 28)) & 0x00ff;
           *prec  = 0xf000 | *prec;
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->px << 16 >> 16));
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->py << 16 >> 16));
           prec++;
           *pprec = prec;
           *num_recs += 3;
           *outl_rec = outlrec + 1;
           break;

        case NEW_SCALE :                              /* Set scale factors code */
           *prec  = 0xf300;
           prec++;
           *prec  = (UShort)outlrec->px;
           prec++;
           *prec  = (UShort)outlrec->py;
           prec++;
           *pprec = prec;
           *num_recs += 3;
           *outl_rec = outlrec + 1;
           break;

        case MIN_MAX_X :                              /* minimum X extents code */
        case MIN_MAX_Y :                              /* minimum Y extents code */
           *prec  = (UShort)(0x000000f0 & ((UInt)outlrec->px << 12 >> 24));
           *prec += (UShort)(0x0000000f & ((UInt)outlrec->py << 12 >> 28)) & 0x00ff;

           if (outlrec->rec_type == MIN_MAX_X)
               *prec = 0xf500 | *prec;
             else
               *prec = 0xf600 | *prec;
               
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->px << 16 >> 16));
           prec++;
           *prec  = (UShort)(0x0000ffff & ((UInt)outlrec->py << 16 >> 16));
           prec++;
           *pprec = prec;
           *num_recs += 3;
           *outl_rec = outlrec + 1;
           break;

        case HIER_HEAD :                             /* Font Hierarchy values */
           *prec    =  0xf900;
           head_rec = prec;
           prec++;
           outl_ptr = outlrec;
           outl_ptr++;
           *num_recs++;
           for(  num_vals = count1 = 0;
                    (count1 < outlrec->px)
                 && (outlrec->rec_type == HIER_HEAD);
                 count1++, outl_ptr++ ) {
              for( count2 = 0;
                      (count2 < outl_ptr->py)
                   && (outl_ptr->rec_type == HIER_TYPE);
                   count2++, prec++, *num_recs++, num_vals++ )
              	 *prec = (UShort) 1;
              }

           *head_rec += num_vals;
           *pprec = prec;
           *outl_rec  = outl_ptr;
           break;
           
        default :
          status = FF_FONT_OUTL_REC_ERROR + WARN;

        }

   return ( status );


}





/***************************************************************************/
/* Interprets the record at *pprec as a plaid zone definition              */
/* Unpacks from edge number into *pfrom                                    */
/* Unpacks to edge number into *pto                                        */
/* Unpacks prop, level and cont flags into *pplc                           */
/* Unpacks min into *pmin                                                  */
/* Unpacks function size into *pfsize                                      */
/* Always returns true because any binary value is interpretable as a      */
/* plaid zone definition                                                   */
/***************************************************************************/

int FSis_c_zone(pprec, pfrom, pto, pplc, pmin, pfsize, num_recs)

	unsigned short **pprec;
	unsigned short *pfrom;
	unsigned short *pto;
	unsigned short *pplc;
	unsigned short *pmin;
	unsigned short *pfsize;
                 int   *num_recs;

{
	unsigned short word;

   word = **pprec;
   if ((word & 0xf000) != 0xf000) {
       *pfrom  = word >> 12;
       *pto    = (word >> 8) & 0x000f;
       *pplc   = (word >> 5) & 0x0007;
       *pfsize = (word >> 3) & 0x0003;
       *pmin   = word & 0x0007;
       (*pprec)++;
       *num_recs = *num_recs + 1;
       }
     else {
       *pplc     = (word >> 9) & 0x0007;
       *pfsize   = (word >> 7) & 0x0003;
       *pmin     = word & 0x007f;
       (*pprec)++;
       word      = **pprec;
       *pfrom    = word >> 8;
       *pto      = word & 0x00ff;
       (*pprec)++;
       *num_recs = *num_recs + 2;
       }

   return(1);

}





/**************************************************************************/
/* Tests if the data at *pprec is a plaid P item definition               */
/* If so:                                                                 */
/*   Unpacks the character number into *pchar_no                          */
/*   Unpacks the dimension flag into *pdim                                */
/*   Unpacks the zone number into *pzone_no                               */
/*   Returns true                                                         */
/* If not, returns false                                                  */
/**************************************************************************/

int FSis_c_p_item(pprec, pchar_no, pdim, pzone_no, num_recs)

	unsigned short **pprec;
	unsigned short *pchar_no;
	unsigned short *pdim;
	unsigned short *pzone_no;
                 int   *num_recs;

{
	unsigned short word;

   word = **pprec;
   if ((word & 0xc000) == 0x0000) {
       *pchar_no = (word >> 5) & 0x01ff;
       *pdim     = (word >> 4) & 0x0001;
       *pzone_no = word & 0x000f;
       (*pprec)++;
       *num_recs = *num_recs + 1;
       return(1);
       }
     else if ((word & 0xff00) == 0xf000) {
       *pzone_no = word & 0x00ff;
       (*pprec)++;
       word      = **pprec;
       *pchar_no = word >> 1;
       *pdim     = word & 0x0001;
       (*pprec)++;
       *num_recs = *num_recs + 2;
       return(1);
       }

   return(0);

}





/**************************************************************************/
/* Tests if the data at *pprec is a plaid F item definition               */
/* If so:                                                                 */
/*   Unpacks the character number into *pchar_no                          */
/*   Unpacks the dimension flag into *pdim                                */
/*   Unpacks the zone number into *pzone_no                               */
/*   Returns true                                                         */
/* If not, returns false                                                  */
/**************************************************************************/

int FSis_c_f_item(pprec, pchar_no, pdim, pzone_no, num_recs)

	unsigned short **pprec;
	unsigned short *pchar_no;
	unsigned short *pdim;
	unsigned short *pzone_no;
                 int   *num_recs;

{
	unsigned short word;

   word = **pprec;
   if ((word & 0xc000) == 0x4000) {
       *pchar_no = (word >> 5) & 0x01ff;
       *pdim     = (word >> 4) & 0x0001;
       *pzone_no = word & 0x000f;
       (*pprec)++;
       *num_recs = *num_recs + 1;
       return(1);
       }
     else if ((word & 0xff00) == 0xf100) {
       *pzone_no = word & 0x00ff;
       (*pprec)++;
       word      = **pprec;
       *pchar_no = word >> 1;
       *pdim     = word & 0x0001;
       (*pprec)++;
       *num_recs = *num_recs + 2;
       return(1);
       }

   return(0);

}





/**************************************************************************/
/* Tests if the data at *pprec is a plaid T item definition               */
/* If so:                                                                 */
/*   Unpacks the character number into *pchar_no                          */
/*   Unpacks the dimension flag into *pdim                                */
/*   Unpacks the zone number into *pzone_no                               */
/*   Returns true                                                         */
/* If not, returns false                                                  */
/**************************************************************************/

int FSis_c_t_item(pprec, pchar_no, pdim, pzone_no, num_recs)
	unsigned short **pprec;
	unsigned short *pchar_no;
	unsigned short *pdim;
	unsigned short *pzone_no;
                 int   *num_recs;

{
	unsigned short word;

   word = **pprec;
   if ((word & 0xff00) == 0xf200) {
       *pzone_no = word & 0x00ff;
       (*pprec)++;
       word      = **pprec;
       *pchar_no = word >> 1;
       *pdim     = word & 0x0001;
       (*pprec)++;
       *num_recs = *num_recs + 2;
       return(1);
       }

   return(0);

}





/**************************************************************************/
/* Tests if the data at *pprec is a plaid constant item definition        */
/* If so, converts the decimal constant to binary and                     */
/*    Assigns the mantissa to *pmantissa                                  */
/*    Assigns the exponent to *pexponent                                  */
/*    Returns true                                                        */
/* If not, returns false                                                  */
/**************************************************************************/

int FSis_c_const_item(pprec, pmantissa, pexponent, num_recs)

	unsigned short **pprec;
	         int    *pmantissa, *pexponent;
                 int    *num_recs;

{
	unsigned short word;

   word = **pprec;
   if ((word & 0xc000) == 0x8000) {
       FSinit_acc();
       if ((word & 0xf000) == 0x8000) {
           FSacc_digit(word & 0x000f);
           FSacc_digit((word >> 4) & 0x000f);
           FSacc_digit((word >> 8) & 0x000f);
           *num_recs = *num_recs + 1;
           (*pprec)++;
           }
         else if ((word & 0xf000) == 0x9000) {
           FSacc_digit(word & 0x000f);
           FSacc_digit((word >> 4) & 0x000f);
           FSacc_digit((word >> 8) & 0x000f);
           (*pprec)++;
           word = **pprec;
           FSacc_digit(word & 0x000f);
           FSacc_digit((word >> 4) & 0x000f);
           FSacc_digit((word >> 8) & 0x000f);
           FSacc_digit((word >> 12) & 0x000f);
           (*pprec)++;
           *num_recs = *num_recs + 2;
           }
         else if ((word & 0xf000) == 0xa000) {
           FSacc_digit(word & 0x000f);
           FSacc_digit((word >> 4) & 0x000f);
           FSacc_digit((word >> 8) & 0x000f);
           (*pprec)++;
           word = **pprec;
           FSacc_digit(word & 0x000f);
           FSacc_digit((word >> 4) & 0x000f);
           FSacc_digit((word >> 8) & 0x000f);
           FSacc_digit((word >> 12) & 0x000f);
           (*pprec)++;
           word = **pprec;
           FSacc_digit(word & 0x000f);
           FSacc_digit((word >> 4) & 0x000f);
           FSacc_digit((word >> 8) & 0x000f);
           FSacc_digit((word >> 12) & 0x000f);
           (*pprec)++;
           *num_recs = *num_recs + 3;
           }
         else {
           printf("FSis_c_const_item: Unrecognised constant item %4x\n", word);
           }
       *pmantissa = acc_mantissa * acc_sign;
       *pexponent = acc_exponent;
       return(1);
       }

   return(0);

}





/**************************************************************************/
/* Tests if the data at *pprec is a plaid operator item definition        */
/* If so:                                                                 */
/*    Unpacks the operator code into *pop_code                            */
/*    Unpacks the last item flag into *plast_item                         */
/*    Returns true                                                        */
/* If not, returns false                                                  */
/**************************************************************************/

int FSis_c_op_item(pprec, pop_code, plast_item, num_recs)
	unsigned short **pprec;
	unsigned short *pop_code;
	unsigned short *plast_item;
                 int   *num_recs;

{
	unsigned short word;

   word = **pprec;
   if ((word & 0xe000) == 0xc000) {
       *plast_item = (word >> 12) & 0x0001;
       *pop_code   = word & 0x0fff;
       *num_recs   = *num_recs + 1;
       (*pprec)++;
       return(1);
       }

   return(0);

}





/**************************************************************************/
/* Initializes the decimal to binary conversion accumulator               */
/**************************************************************************/

FSinit_acc()

{
   acc_mantissa    = 0;
   acc_exponent    = 0;
   acc_dec_pt_read = 0;
   acc_sign        = 1;
   acc_term_read   = 0;

}





/****************************************************************************/
/* Accumulates the digit into the decimal to binary conversion accumulator  */
/****************************************************************************/

FSacc_digit(digit)

	unsigned short digit;

{
   if (digit < 0xa) {
       acc_mantissa = acc_mantissa * 10 + digit;
       if (acc_dec_pt_read)
           acc_exponent--;
       }
     else if (digit == 0xa)
       acc_term_read = 1;
     else if (digit == 0xb) {
       if (acc_dec_pt_read)
           printf("FSacc_digit: two decimal points read\n");
         else
           acc_dec_pt_read = 1;
       }
     else if (digit == 0xc) {
       acc_sign = -1;
       }
     else {
       printf("FSacc_digit: Illegal digit code %d\n", digit);
       }

}






/*****************************************************************************
 * Updates *pprec to point to next record.                                   *
 * n = number of words in current record                                     *
 * Tracks repeat subroutine and inserts return when appropriate.             *
 *****************************************************************************/

FSnext_step(pprec, pdata_origin, n, word_count)

   unsigned short **pprec;
   unsigned short  *pdata_origin;
            int     n;
            short   word_count;

{
   if (repeat_active[n])                     /* Repeat sequence active */
       {                                  
       if (--ret_count[n] == 0)                /* Step count now zero */
           {
           repeat_active[n] = 0;              
           *pprec = ret_offset[n] + pdata_origin; /*Restore return addr*/
           return;
           }
       }
   *pprec += word_count;
}
