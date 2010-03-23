




/*****************************************************************************
*                                                                            *
*               Copyright 1987, Bitstream Inc., Cambridge, MA                *
*                            Patent No. 4,785,391                            *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/**************************** G E T R E C 1 6 . C ****************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)  20-Nov-87  jsc   Copied from getrec.c
                      Changed to return 16 bit results
                      Scale factors returned in 1/4096 units
                      Character min and max extents returned together

 2)  28 Dec 87  jsc   Replaced constant decoding function acc_digit()
                      by acc_digits() to accumulate all 3 or 4 digits
                      packed into a word.

 3)  29 Dec 87  jsc   Added function skip_funct() to skip over function
                      items during getrec parsing.

 4)  14 Jun 88  tpl  changed error reporting 'printf' and 'fprintf(stderr'
                      to 'report_error(...' function calls

 *****************************************************************************

    Routines for unpacking compressed outline data (with plaid)

 ****************************************************************************/







#include    "stdef.h"
#include    "errchk.h"
#include    "error.h"

static ufix32  state, saved_state;    /* Determines internal state of get_rec
    Bits 31-24  Bits 23-16   Bits 15-8    Bits 7-0
       00         00            00           00       Nothing to do
       03         00            00        No values   Outline hierarchy data
       04    No X zones     No Y zones    F size      Plaid zone data (16 bit edge values)
       05    No X zones     No Y zones    F size      Plaid zone data (32 bit edge values) */

static boolean repeat_active, saved_repeat_active;
static ufix16  ret_count, saved_ret_count;
static ufix16  ret_offset, saved_ret_offset;
static ufix16 *pxedges, *saved_pxedges;
static ufix16 *pyedges, *saved_pyedges;
static fix15   acc_mantissa, acc_exponent;
static fix15   acc_dec_pt_read;
static boolean acc_negative;

FUNCTION void init_rec_state()

/*  Initializes get_rec state
 */

{
state = 0;
repeat_active = FALSE; 
}

FUNCTION save_rec_state()

/*  Saves get_rec state
 */

{
saved_state = state;
saved_repeat_active = repeat_active;
saved_ret_count = ret_count;
saved_ret_offset = ret_offset;
saved_pxedges = pxedges;
saved_pyedges = pyedges;
}

FUNCTION restore_rec_state()

/*  Restores get_rec state
 */

{
state = saved_state;
repeat_active = saved_repeat_active;
ret_count = saved_ret_count;
ret_offset = saved_ret_offset;
pxedges = saved_pxedges;
pyedges = saved_pyedges;
}

FUNCTION get_rec16(pprec, pdata_origin, ptype, px, py, pbeta)
ufix16 huge **pprec;         /* Current record in character data (input and output) */ 
ufix16 huge *pdata_origin;   /* First data record in outline data */
fix15  *ptype;          /* Record type (output) */
fix15  *px;             /* X component of record (depends on record type -- output) */
fix15  *py;             /* Y component of record (depends on record type -- output) */
fix15  *pbeta;          /* Z component of record (depends on record type -- output) */

/*  get_rec fetches the next logical step from compressed outline data.     
 *  Sets *ptype to indicate type of step read.                              
 *    -1: erroneous step read.                                               
 *     0: end of character or call while repeat active.                      
 *     1: move to (*px, *py).                                                
 *     2: vector to (*px = xinc, *py = yinc).                                
 *     3: horizontal vector to (*px = xinc, *py = 0).                        
 *     4: vertical vector to (*px = 0, *py = yinc).                          
 *     5: arc to (*px = xinc, *py = yinc) with bulge factor *pbeta.          
 *     6: set scale factors to *px, *py (units of 1/4096).                   
 *     7: set origin to (*px, *py).                                          
 *     8: set x extents (*px = xmin, *py = xmax).                            
 *    10: set y extents (*px = ymin, *py = ymax).                            
 *    12: do char (*px).                                                     
 *    13: hierarchy value (*px).                                             
 *    14: plaid x zone data. *px is starting co-ord, *py is ending co-ord,   
 *        *pbeta is P, L, C, function flags and minimum pixels:              
 *            Bits 31-16   Not used                                          
 *            Bit  15      P flag                                            
 *            Bit  14      L flag                                            
 *            Bit  13      C flag                                            
 *            Bits 12-11   Function flag:                                    
 *                             0: No function items                          
 *                             1: 1 function item follows                    
 *                             2: Not used                                   
 *                             3: 2 or more function items follow terminated 
 *                                    by an op item with termination flag on 
 *            Bits 10-8    Not used                                          
 *            Bits  7-0    Minumum value                                     
 *    15: plaid y zone data. *px is starting co-ord, *py is ending co-ord,   
 *        *pbeta is P, L, C, function flags and minimum pixels:              
 *            Bits 31-16   Not used                                          
 *            Bit  15      P flag                                            
 *            Bit  14      L flag                                            
 *            Bit  13      C flag                                            
 *            Bits 12-11   Function flag:                                    
 *                             0: No function items                          
 *                             1: 1 function item follows                    
 *                             2: Not used                                   
 *                             3: 2 or more function items follow terminated 
 *                                    by an op item with termination flag on 
 *            Bits 10-8    Not used                                          
 *            Bits  7-0    Minumum value                                    
 */

{
ufix16  first_word, second_word;
ufix16  from, to, plc, mini, fsize, x;

again:
if (state)                                     /* Outstanding data to read? */
    {
    if ((state & 0xfc000000) == 0x04000000)    /* Plaid zone data (16 or 32 bit) */
        {
        fsize = state & 0x000000ff;
        if (fsize)                             /* Function items */
            {
            skip_funct(pprec, fsize);          /* Skip function items */
            state &= 0xffffff00;
            goto again;
            }

        if (state & 0x00ff0000)                /* X zones */
            {
            get_c_zone(pprec, &from, &to, &plc, &mini, &fsize);
            *ptype = 14;
            if (state & 0x01000000)        /* 32 bit edge values? */
                {
                report_error (ERROR,ER_UNEXPD_32BIT_VALUE_X,TRUE,"");
                }
            else
                {
                *px = pxedges[from];
                *py = pxedges[to];
                }
            *pbeta = (((plc << 2) + fsize) << 11) + mini;
/*****      state += fsize - 0x00010000; This is wrong, mby *****/
            state = state + fsize - 0x00010000;
            return;
            }

        if (state & 0x0000ff00)                /* Y zones */
            {
            get_c_zone(pprec, &from, &to, &plc, &mini, &fsize);
            *ptype = 15;
            if (state & 0x01000000)        /* 32 bit edge values? */
                {
                report_error (ERROR,ER_UNEXPD_32BIT_VALUE_Y,TRUE,"");
                }
            else
                {
                *px = pyedges[from];
                *py = pyedges[to];
                }
            *pbeta = (((plc << 2) + fsize) << 11) + mini;
/*****      state += fsize - 0x00000100; This is wrong  mby 4/16/88*****/
            state = state + fsize - 0x00000100;
            return;
            }

        state = 0;
        goto again;
        }

    if ((state & 0xff000000) == 0x03000000)    /* Outline hierarchy values */
        {
        *ptype = 13;
        *px = **pprec;
        (*pprec)++;
        (state)--;
        if ((state & 0x000000ff) == 0)
            state = 0;
        return;
        }

    report_error (ERROR,ER_SHOULDNT_BE_HERE,TRUE,"");
    }

if (((first_word = **pprec) & 0xe000) == 0xc000) /* Short arc code */
    {
    *ptype = 5;
    *px = (first_word & 0x0200)? first_word | 0xfc00: first_word & 0x1ff;
    second_word = *(*pprec + 1);
    *py = (second_word & 0x0200)? second_word | 0xfc00: second_word & 0x1ff;
    *pbeta = (((first_word << 3) & 0xe000) | (second_word >> 3)) & 0xff80;
    if (repeat_active)
        next_step(pprec, pdata_origin, 2);
    else
        *pprec += 2;
    return;
    }

if ((first_word & 0xc000) == 0x8000)           /* Short vector code */
    {
    *ptype = 2;
    *px = (first_word & 0x2000)? first_word | 0xc000: first_word & 0x1fff;
    *py = (fix15)(*(*pprec + 1));
    if (repeat_active)
        next_step(pprec, pdata_origin, 2);
    else
        *pprec += 2;
    return;
    }

if ((first_word & 0xc000) == 0)                /* Horizontal vector code */
    {
    *ptype = 3;
    *px = (first_word & 0x2000)? first_word | 0xc000: first_word & 0x1fff;
    *py = 0;
    if (repeat_active)
        next_step(pprec, pdata_origin, 1);
    else
        (*pprec)++;
    return;
    }

if ((first_word & 0xc000) == 0x4000)           /* Vertical vector code */
    {
    *ptype = 4;
    *px = 0;
    *py = (first_word & 0x2000)? first_word | 0xc000: first_word & 0x1fff;
    if (repeat_active)
        next_step(pprec, pdata_origin, 1);
    else
        (*pprec)++;
    return;
    }

if ((first_word & 0xff00) == 0xf000)           /* Move code */
    {
    *ptype = 1;
    *px = *(*pprec + 1);
    *py = *(*pprec + 2);
    *pprec += 3;
    return;
    }

if ((first_word & 0xff00) == 0xe300)           /* End char code  */
    {                                              
    *ptype = 0;
    (*pprec)++;
    return;                                       
    }

if ((first_word & 0xff00) == 0xf700)           /* Plaid edges header (0-15 16 bit values) */
    {
    pxedges = (*pprec += 1);                   /* Set pointer to first x edge */
    pyedges = *pprec                           
        += (first_word & 0x00f0) >> 4;         /* Set pointer to first y edge */

    *pprec += first_word & 0x000f;             /* Skip to zone header */
    first_word = **pprec;

    if ((first_word & 0xff00) == 0xf800)       /* Less than 16 X and Y zones? */
        {
        state = 0x04000000
            + ((ufix32)(first_word & 0x00f0) << 12)
            + ((first_word & 0x000f) << 8);
        (*pprec)++;                            /* Skip to first plaid zone */
        goto again;
        }

    if (**pprec == 0xfff2)                     /* Less than 256 X and Y zones? */
        {
        (*pprec)++;
        state = ((ufix32)(**pprec) << 8) + 0x04000000;
        (*pprec)++;
        goto again;
        }

    report_error (ERROR,ER_2MANY_X_AND_Y_ZONES_SHDR,TRUE,"");
    goto error;
    }

if ((first_word & 0xff00) == 0xf500)           /* X extents code */
    {
    *ptype = 8;
    *px = *(*pprec + 1);
    *py = *(*pprec + 2);
    *pprec += 3;
    return;
    }

if ((first_word & 0xff00) == 0xf600)           /* Y extents code */
    {
    *ptype = 10;
    *px = *(*pprec + 1);
    *py = *(*pprec + 2);
    *pprec += 3;
    return;
    }

if ((first_word & 0xff00) == 0xf900)           /* Hierarchy values code */
    {
    if (x = (first_word & 0x00ff))
        state = 0x03000000 + x;
    (*pprec)++;                                /* Skip to first hierarchy value */
    goto again;
    }

if ((first_word & 0xff00) == 0xe100)           /* Long arc code */
    {
    *ptype = 5;
    *px = *(*pprec + 1);
    *py = *(*pprec + 2);
    *pbeta = *(*pprec + 3);
    if (repeat_active)
        next_step(pprec, pdata_origin, 4);
    else
        *pprec +=4;
    return;
    }

if ((first_word & 0xff00) == 0xe000)           /* Long vector code */
    {
    *ptype = 2;
    *px = *(*pprec + 1);
    *py = *(*pprec + 2);
    if (repeat_active)
        next_step(pprec, pdata_origin, 3);
    else
        *pprec += 3;
    return;
    }

if ((first_word & 0xffff) == 0xfff0)           /* Plaid edges header (16-255 16 bit values) */
    {
    second_word = *(*pprec + 1);
    pxedges = *pprec += 2;                     /* Set pointer to first X edge */
    pyedges = *pprec                           
        += (second_word & 0xff00) >> 8;        /* Set pointer to first Y edge */
    *pprec += second_word & 0x00ff;            /* Skip to zone header */

    first_word = **pprec;
    if ((first_word & 0xff00) == 0xf800)       /* Less than 16 X and Y zones? */
        {
        state = 0x04000000
            + ((ufix32)(first_word & 0x00f0) << 12)
            + ((first_word & 0x000f) << 8);
        (*pprec)++;
        goto again;
        }
    if (**pprec == 0xfff2)                     /* Less than 256 X and Y zones? */
        {
        (*pprec)++;
        state = 0x04000000
            + ((ufix32)((**pprec & 0xff00) + (**pprec & 0x00ff)) << 8);
        (*pprec)++;
        goto again;
        }
    report_error (ERROR,ER_2MANY_X_AND_Y_ZONES_LHDR,TRUE,"");
    goto error;
    }

if ((first_word & 0xff00) == 0xe200)           /* Call code */
    {
    if (repeat_active)                         /* Call code during repeat (illegal) */
        {
        *ptype = 0;
        return;
        }
    else
        {
        ret_count = first_word & 0x00ff;       /* Initialize step count */
        if (ret_count == 0)                    /* Ignore if step count = 0 */
            {
            *pprec += 2;
            goto again;
            }
/*TPL*/ ret_offset = (ufix32)(*pprec - pdata_origin) + 2; /* Save return address */
        *pprec = pdata_origin + (*(*pprec + 1)); /* Set next address */
        repeat_active = TRUE;
        goto again;
        }
    }

if ((first_word & 0xff00) == 0xf300)           /* Set scale factors code */
    {
    *ptype = 6;
    *px = *(*pprec + 1);
    *py = *(*pprec + 2);
    *pprec +=3;
    return;
    }

if ((first_word & 0xff00) == 0xf200)           /* Set position code */
    {
    *ptype = 7;
    *px = *(*pprec + 1);
    *py = *(*pprec + 2);
    *pprec +=3;
    return;
    }

if ((first_word & 0xff00) == 0xf400)           /* Do char code */
    {
    *ptype = 12;
    *px = *(*pprec + 1);
    *pprec +=2;
    return;
    }

if ((first_word & 0xff00) == 0xf100)           /* End outline code (no longer used) */
    {
    (*pprec)++;
    goto again;
    }

report_error (ERROR,ER_SHOULDNT_BE_HERE_2,TRUE,"");
error: *ptype = -1;
(*pprec)++;
}

FUNCTION next_step(pprec, pdata_origin, word_count)
ufix16 huge **pprec;    /* Pointer to current record (input and output) */
ufix16 huge *pdata_origin; /* Pointer to first record in outline data */
fix15    word_count;    /* Number of 16 bit words in current record */

/*  Updates *pprec to point to next record. 
 *  n = number of words in current record 
 *  Tracks repeat subroutine and inserts return when appropriate.
 */
 
{
if (repeat_active)                           /* Repeat sequence active */
    {                                  
    if (--ret_count == 0)                    /* Step count now zero */
        {
        repeat_active = FALSE;              
        *pprec = ret_offset + pdata_origin;  /* Restore return address */
        return;
        }
    }
*pprec += word_count;
}

FUNCTION get_c_zone(pprec, pfrom, pto, pplc, pmin, pfsize)
ufix16 huge **pprec;    /* Pointer to current record (input and output) */
ufix16 *pfrom;          /* FROM coordinate in orus (output) */
ufix16 *pto;            /* TO coordinate in orus (output) */
ufix16 *pplc;           /* P, L, and C flags (output) */
ufix16 *pmin;           /* Minimum number of pixels for zone (output) */
ufix16 *pfsize;         /* Function size flag (output) */

/*  Interprets the record at *pprec as a plaid zone definition              
 *  Unpacks from edge number into *pfrom                                    
 *  Unpacks to edge number into *pto                                        
 *  Unpacks prop, level and cont flags into *pplc                           
 *  Unpacks min into *pmin                                                  
 *  Unpacks function size into *pfsize                                      
 */

{
ufix16 word;

if (((word = **pprec) & 0xf000) != 0xf000)  /* One word form? */
    {
    *pfrom = word >> 12;
    *pto = (word >> 8) & 0x000f;
    *pplc = (word >> 5) & 0x0007;
    *pfsize = (word >> 3) & 0x0003;
    *pmin = word & 0x0007;
    (*pprec)++;
    }
else                                        /* Two word form? */
    {
    *pplc = (word >> 9) & 0x0007;
    *pfsize = (word >> 7) & 0x0003;
    *pmin = word & 0x007f;
    (*pprec)++;
    word = **pprec;
    *pfrom = word >> 8;
    *pto = word & 0x00ff;
    (*pprec)++;
    }
return;
}

FUNCTION get_c_item(pprec, ptype, px, py, pz)
ufix16 huge **pprec;    /* Pointer to record (input and output) */
ufix16  *ptype;         /* Type of item record found (output) */
ufix16  *px;            /* X component of record (depends on record type -- output) */
ufix16  *py;            /* Y component of record (depends on record type -- output) */
ufix16  *pz;            /* Z component of record (depends on record type -- output) */

/*  If the data at *pprec is a plaid item definition:                        
 *    Sets *ptype to 1                                                       
 *    Unpacks the character number into *px                                  
 *    Unpacks the dimension flag into *py                                    
 *    Unpacks the zone number into *pz                                       
 *  If the data at *pprec is a plaid F item definition:                      
 *    Sets *ptype to 2                                                       
 *    Unpacks the character number into *px                                  
 *    Unpacks the dimension flag into *py                                    
 *    Unpacks the zone number into *pz                                       
 *  If the data at *pprec is a plaid T item definition:                      
 *    Sets *ptype to 3                                                       
 *    Unpacks the character number into *px                                  
 *    Unpacks the dimension flag into *py                                    
 *    Unpacks the zone number into *pz                                       
 *  If the data at *pprec is a plaid constant item definition:               
 *    Sets *ptype to 4                                                       
 *    converts the decimal constant to binary and                            
 *    Assigns the mantissa to *px                                            
 *    Assigns the negated exponent to *py                                    
 *  If the data at *pprec is a plaid operator item definition                
 *    Sets *ptype to 5                                                       
 *    Unpacks the operator code into *px                                     
 *    Op codes:                                                              
 *            0: NOP function                                                
 *            1: ADD function                                                
 *            2: SUB function                                                
 *            3: MUL function                                                
 *            4: DIV function                                                
 *            5: PRINT function                                              
 *            6: FIXR function (round to nearest integer)                    
 *            7: FIX function (round to next lowest integer)                 
 *            8: CO function                                                 
 *            9: CF function                                                 
 *           10: RRFS function                                               
 *           11: RRHS function                                               
 *           12: RRFS1 function                                              
 *           13: RRHS1 function                                              
 *           14: BZON function                                               
 *           15: BZON1 function                                              
 *           16: LZON function                                               
 *           17: LZON1 function                                              
 *           18: CFFLB function                                              
 *           19: CFFRB function                                              
 *           20: CFSLB function                                              
 *           21: CFSRB function                                              
 *           22: XHT_ADJ function                                            
 *                                                                           
 *    Unpacks the last item flag into *py                                    
 *  If no match is found, *ptype is set to 0                                 
 */
{
ufix16 word;

word = **pprec;
if ((word & 0xc000) == 0x0000)          /* P item; one word form? */
    {
    *ptype = 1;
    *px = (word >> 5) & 0x01ff;
    *py = (word >> 4) & 0x0001;
    *pz = word & 0x000f;
    (*pprec)++;
    return;
    }

if ((word & 0xc000) == 0x4000)          /* F item; one word form? */
    {
    *ptype = 2;
    *px = (word >> 5) & 0x01ff;
    *py = (word >> 4) & 0x0001;
    *pz = word & 0x000f;
    (*pprec)++;
    return;
    }

if ((word & 0xe000) == 0xc000)          /* Operator item? */
    {
    *ptype = 5;
    *py = (word >> 12) & 0x0001;
    *px = word & 0x0fff;
    (*pprec)++;
    return;
    }

if ((word & 0xf000) == 0x8000)          /* Const item; one word form? */
    {
    *ptype = 4;
    init_acc();
    acc_digits(word, (fix15)3);
    (*pprec)++;
    *px = acc_negative? -acc_mantissa: acc_mantissa;
    *py = acc_exponent;
    return;
    }

if ((word & 0xff00) == 0xf200)          /* T item? */
    {
    *ptype = 3;
    *pz = word & 0x00ff;
    (*pprec)++;
    word = **pprec;
    *px = word >> 1;
    *py = word & 0x0001;
    (*pprec)++;
    return;
    }

if ((word & 0xf000) == 0x9000)          /* Const item; two word form? */
    {
    *ptype = 4;
    init_acc();
    acc_digits(word, (fix15)3);
    (*pprec)++;
    acc_digits(**pprec, (fix15)4);
    (*pprec)++;
    *px = acc_negative? -acc_mantissa: acc_mantissa;
    *py = acc_exponent;
    return;
    }

if ((word & 0xff00) == 0xf000)          /* P item; two word form? */
    {
    *ptype = 1;
    *pz = word & 0x00ff;
    (*pprec)++;
    word = **pprec;
    *px = word >> 1;
    *py = word & 0x0001;
    (*pprec)++;
    return;
    }

if ((word & 0xff00) == 0xf100)          /* F item; two word form? */
    {
    *ptype = 2;
    *pz = word & 0x00ff;
    (*pprec)++;
    word = **pprec;
    *px = word >> 1;
    *py = word & 0x0001;
    (*pprec)++;
    return;
    }

if ((word & 0xf000) == 0xa000)          /* Const item; three word form? */
    {
    *ptype = 4;
    init_acc();
    acc_digits(word, (fix15)3);
    (*pprec)++;
    acc_digits(**pprec, (fix15)4);
    (*pprec)++;
    acc_digits(**pprec, (fix15)4);
    (*pprec)++;
    *px = acc_negative? -acc_mantissa: acc_mantissa;
    *py = acc_exponent;
    return;
    }

report_error (ERROR,ER_SHOULDNT_BE_HERE_3,TRUE,"");
*ptype = 0;                          

}

FUNCTION skip_funct(pprec, fn_flag)
ufix16 huge **pprec;    /* Pointer to record (input and output) */
ufix16   fn_flag;       /* Function size flag */

/* Updates **pprec to point to record following constraint function.
 * The function size flag indicates the size of the function:
 *   0: No function items
 *   1: Single function item
 *   2: Not used
 *   3: Last item is operator with termination flag set
 */

{
while (fn_flag)
    {
    if (fn_flag == 1)
        fn_flag = 0;
    switch (**pprec >> 12)
        {
    case  0:
    case  1:
    case  2:
    case  3:        /* P item -- 1 word */
        (*pprec)++;
        continue;

    case  4:
    case  5:
    case  6:
    case  7:        /* F item -- 1 word */
        (*pprec)++;
        continue;

    case  8:        /* Const item -- 1 word */
        (*pprec)++;
        continue;

    case  9:        /* Const item -- 2 words */
        *pprec +=2;
        continue;

    case 10:        /* Const item -- 3 words */
        *pprec +=3;
        continue;

    case 12:        /* Op item (non-terminating) -- 1 word */
        (*pprec)++;
        continue;

    case 13:        /* Op item (terminating) -- 1 word */
        (*pprec)++;
        return;

    case 15:        /* T, P or F item -- 2 words */
        *pprec +=2;
        continue;

    default:
        report_error (ERROR,ER_CANT_SKIP_UNDEF_FUNC,TRUE,"");
        }
    }
}

FUNCTION init_acc()

/*  Initializes the decimal to binary conversion accumulator              
 */

{
acc_mantissa = acc_exponent = 0;
acc_dec_pt_read = 0;
acc_negative = FALSE;
}

FUNCTION acc_digits(word, n)
ufix16 word;            /* Word containing one or more digits */
fix15  n;               /* Number of digits to be extracted (right to left) */

/* Extracts digits repeatedly from word starting from the rightmost 4 bit field
 * Repeats for n other 4 bit fields from right to left in the word
 */

{
ufix16 digit;

for (; n > 0; n--, word = word >> 4)
    {
    if ((digit = word & 0x000f) < 10)
        {
        acc_mantissa = acc_mantissa * 10 + digit;
        acc_exponent +=acc_dec_pt_read;  /* Increment if dec point read */
        continue;
        }
    else if (digit == 10)   /* Filler code */
        {
        return;
        }
    else if (digit == 11)   /* Decimal point */
        {
        acc_dec_pt_read = 1;
        continue;
        }
    else if (digit == 12)   /* Minus sign */
        {
        acc_negative = TRUE;
        continue;
        }
    else                    /* Illegal digit code */
        {
        report_error (ERROR,ER_ILLEGAL_DIGIT,TRUE,"");
        return;
        }
    }
}




