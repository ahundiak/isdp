




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/************************** G E T R E C _ I N C . C **************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)  12-Dec-85  jsc   Added new record types to getrec to handle 4 types of
                      function items: P item (type 16), F item (type 17),
                      Constant item (type 18) and Operation item (type 19).

                      Also changed definition of beta result for x and y
                      zones (types 14 and 15) to accomodate two bit function
                      flag and larger field for minimum pixel value.

                      check_outlines() updated to handle the new types.

 2)  10-Jan-86  jsc   Removed function 'check_outlines'

 3)   1-May-86  jsc   T item handling added.
                      is_c_t_item() function added.

 4)   6-Sep-86  jsc   Types of second and third arguments of is_c_const_item()
                      changed from ufix32 to fix31.

 5)  11-Oct-86  jsc   Field extraction expressions in get_rec() updated to ensure
                      casting to ufix32 in setting of state variable.
                  
                      static variable min name changed to mini to avoid name clash.

 *****************************************************************************

    Routines for unpacking compressed outline data (with plaid)

 ****************************************************************************/







#include    "../hfiles/stdef.h"


static ufix32  state[2];    /* Determines internal state of get_rec channel n
    Bits 31-24  Bits 23-16   Bits 15-8    Bits 7-0
       00         00            00           00       Nothing to do
       01         00            00        MS 4 bits   Xmax extent data
       02         00            00        MS 4 bits   Ymax extent data
       03         00            00        No values   Outline hierarchy data
       04    No X zones     No Y zones    F size      Plaid zone data (16 bit edge values)
       05    No X zones     No Y zones    F size      Plaid zone data (32 bit edge values) */

static ufix16  repeat_active[2], ret_count[2], ret_offset[2];
static fix31   current_x[2], current_y[2];
static ufix16 *pxedges[2], *pyedges[2];
static ufix32  saved_state;
static ufix16  saved_repeat_active, saved_ret_count, saved_ret_offset;
static fix31   saved_current_x, saved_current_y;
static ufix16 *saved_pxedges, *saved_pyedges;
static fix31   acc_mantissa, acc_exponent;
static fix15   acc_dec_pt_read, acc_sign, acc_term_read;

FUNCTION void init_rec_state(n)
ufix16 n;
/* Initializes get_rec state for channel n */
{
state[n] = 0;
repeat_active[n] = 0;                                   /* Clear call stack */
current_x[n] = current_y[n] = 0;
}

FUNCTION save_rec_state(n)
ufix16 n;
/* Saves get_rec state for channel n */
{
saved_state = state[n];
saved_repeat_active = repeat_active[n];
saved_ret_count = ret_count[n];
saved_ret_offset = ret_offset[n];
saved_current_x = current_x[n];
saved_current_y = current_y[n];
saved_pxedges = pxedges[n];
saved_pyedges = pyedges[n];
}

FUNCTION restore_rec_state(n)
ufix16 n;
/* Restores get_rec state for channel n */
{
state[n] = saved_state;
repeat_active[n] = saved_repeat_active;
ret_count[n] = saved_ret_count;
ret_offset[n] = saved_ret_offset;
current_x[n] = saved_current_x;
current_y[n] = saved_current_y;
pxedges[n] = saved_pxedges;
pyedges[n] = saved_pyedges;
}

FUNCTION get_rec(n, pprec, pdata_origin, ptype, px, py, pbeta)
ufix16 n;                 /* Environment number */
ufix16 **pprec;           /* Current record in character data */ 
ufix16 *pdata_origin;     /* First data record in character data */
fix15  *ptype;            /* Returned record type */
fix31  *px;               /* Returned value x */
fix31  *py;               /* Returned value y */
fix31  *pbeta;            /* Returned value beta */
/* get_rec fetches the next logical step from compressed outline data.     */
/* Sets *ptype to indicate type of step read.                               */
/*   -1: erroneous step read.                                               */
/*    0: end of character or call while repeat active.                      */
/*    1: move to (*px, *py).                                                */
/*    2: vector to (*px, *py).                                              */
/*    3: horizontal vector to (*px, *py).                                   */
/*    4: vertical vector to (*px, *py).                                     */
/*    5: arc to (*px, *py) with bulge factor *pbeta.                        */
/*    6: set scale factors to *px, *py (units of 1/65536).                  */
/*    7: set origin to (*px, *py).                                          */
/*    8: set x min extent (*px).                                            */
/*    9: set x max extent (*px).                                            */
/*   10: set y min extent (*py).                                            */
/*   11: set y max extent (*py).                                            */
/*   12: do char (*px).                                                     */
/*   13: hierarchy value (*px).                                             */
/*   14: plaid x zone data. *px is starting co-ord, *py is ending co-ord,   */
/*       *pbeta is P, L, C, function flags and minimum pixels:              */
/*           Bits 31-16   Not used                                          */
/*           Bit  15      P flag                                            */
/*           Bit  14      L flag                                            */
/*           Bit  13      C flag                                            */
/*           Bits 12-11   Function flag:                                    */
/*                            0: No function items                          */
/*                            1: 1 function item follows                    */
/*                            2: Not used                                   */
/*                            3: 2 or more function items follow terminated */
/*                                   by an op item with termination flag on */
/*           Bits 10-8    Not used                                          */
/*           Bits  7-0    Minumum value                                     */
/*   15: plaid y zone data. *px is starting co-ord, *py is ending co-ord,   */
/*       *pbeta is P, L, C, function flags and minimum pixels:              */
/*           Bits 31-16   Not used                                          */
/*           Bit  15      P flag                                            */
/*           Bit  14      L flag                                            */
/*           Bit  13      C flag                                            */
/*           Bits 12-11   Function flag:                                    */
/*                            0: No function items                          */
/*                            1: 1 function item follows                    */
/*                            2: Not used                                   */
/*                            3: 2 or more function items follow terminated */
/*                                   by an op item with termination flag on */
/*           Bits 10-8    Not used                                          */
/*           Bits  7-0    Minumum value                                     */
/*   16: P item. *px is character number, *py is dim * 256 + zone no        */
/*   17: F item. *px is character number, *py is dim * 256 + zone no        */
/*   18: Const item. *px is value, *py is decimal exponent                  */
/*   19: Op item. *px is op code:                                           */
/*           0: NOP function                                                */
/*           1: ADD function                                                */
/*           2: SUB function                                                */
/*           3: MUL function                                                */
/*           4: DIV function                                                */
/*           5: PRINT function                                              */
/*           6: FIXR function (round to nearest integer)                    */
/*           7: FIX function (round to next lowest integer)                 */
/*           8: CO function                                                 */
/*           9: CF function                                                 */
/*          10: RRFS function                                               */
/*          11: RRHS function                                               */
/*          12: RRFS1 function                                              */
/*          13: RRHS1 function                                              */
/*          14: BZON function                                               */
/*          15: BZON1 function                                              */
/*          16: LZON function                                               */
/*          17: LZON1 function                                              */
/*          18: CFFLB function                                              */
/*          19: CFFRB function                                              */
/*          20: CFSLB function                                              */
/*          21: CFSRB function                                              */
/*          22: XHT_ADJ function                                            */
/*                                                                          */
/*   for all op codes, *pbeta indicates if last item in function:           */
/*           Bits 31-1    Not used                                          */
/*           Bit   0      Termination flag:                                 */
/*                            0: Not last function item                     */
/*                            1: Last function item                         */
/*   20: T item. *px is character number, *py is dim * 256 + zone no        */
{
ufix16  first_word, second_word, third_word, fourth_word;
ufix16  char_no, dim, zone_no, from, to, plc, op_code, fsize, mini, term_flag;
fix31   xinc, yinc;
fix15   is_c_zone();
fix15   is_c_p_item(), is_c_f_item(), is_c_t_item();
fix15   is_c_const_item(), is_c_op_item();

again:
if (state[n])                                   /* Outstanding data to read */
    {
    if ((state[n] & 0xff000000) == 0x01000000)  /* X extent data */
        {
        *ptype = 9;
        *px = (((fix31)state[n]) << 28 >> 12) + **pprec;
        state[n] = 0;
        next_step(pprec, pdata_origin, n, 1);
        return;
        }
    if ((state[n] & 0xff000000) == 0x02000000)  /* Y extent data */
        {
        *ptype = 11;
        *py = (((fix31)state[n]) << 28 >> 12) + **pprec;
        state[n] = 0;
        next_step(pprec, pdata_origin, n, 1);
        return;
        }
    if ((state[n] & 0xff000000) == 0x03000000)  /* Outline hierarchy values */
        {
        *px = (fix31)(**pprec);
        (*pprec)++;
        (state[n])--;
        if ((state[n] & 0x000000ff) == 0)
            state[n] = 0;
        *ptype = 13;
        return;
        }
    if ((state[n] & 0xfc000000) == 0x04000000)   /* Plaid zone data */
        {
        fsize = state[n] & 0x000000ff;
        if (fsize)                               /* Function items */
            {
            term_flag = 0;
            if (is_c_p_item(pprec, &char_no, &dim, &zone_no))
                {
                *px = char_no;
                *py = (dim << 8) + zone_no;
                *ptype = 16;
                }
            else if (is_c_f_item(pprec, &char_no, &dim, &zone_no))
                {
                *px = char_no;
                *py = (dim << 8) + zone_no;
                *ptype = 17;
                }
            else if (is_c_const_item(pprec, px, py))
                {
                *ptype = 18;
                }
            else if (is_c_op_item(pprec, &op_code, &term_flag))
                {
                *px = op_code;
                *pbeta = term_flag;
                *ptype = 19;
                }
            else if (is_c_t_item(pprec, &char_no, &dim, &zone_no))
                {
                *px = char_no;
                *py = (dim << 8) + zone_no;
                *ptype = 20;
                }
            else
                {
                fprintf(stderr,
                    "get_rec: function item %8x not recognised\n", **pprec);
                *ptype = -1;
                }
            if (fsize < 3)
                state[n]--;
            if (term_flag)
                state[n] = state[n] & 0xffffff00;
            if ((state[n] & 0x00ffffff) == 0)
                state[n] = 0;
            return;
            }
        if (state[n] & 0x00ff0000)               /* x zones */
            {
            if (is_c_zone(pprec, &from, &to, &plc, &mini, &fsize))
                {
                if (state[n] & 0x01000000)       /* 32 bit edge values? */
                    {
                    *px = ((fix31)pxedges[n][from << 1]) << 16;
                    *px += pxedges[n][(from << 1) + 1];
                    *py = ((fix31)pxedges[n][to << 1]) << 16;
                    *py += pxedges[n][(to << 1) + 1];
                    }
                else
                    {
                    *px = ((fix31)pxedges[n][from]) << 16 >> 16;
                    *py = ((fix31)pxedges[n][to]) << 16 >> 16;
                    }
                *pbeta = (plc << 13) + (fsize << 11) + mini;
                *ptype = 14;
                }
            else
                {
                fprintf(stderr,
                    "get_rec: plaid zone %8x not recognised\n", **pprec);
                *ptype = -1;
                }
            state[n] = state[n] - 0x00010000 + fsize;
            if ((state[n] & 0x00ffffff) == 0)
                state[n] = 0;
            return;
            }
        if (state[n] & 0x0000ff00)               /* y zones */
            {
            if (is_c_zone(pprec, &from, &to, &plc, &mini, &fsize))
                {
                if (state[n] & 0x01000000)       /* 32 bit edge values? */
                    {
                    *px = ((fix31)pyedges[n][from << 1]) << 16;
                    *px += pyedges[n][(from << 1) + 1];
                    *py = ((fix31)pyedges[n][to << 1]) << 16;
                    *py += pyedges[n][(to << 1) + 1];
                    }
                else
                    {
                    *px = ((fix31)pyedges[n][from]) << 16 >> 16;
                    *py = ((fix31)pyedges[n][to]) << 16 >> 16;
                    }
                *pbeta = (plc << 13) + (fsize << 11) + mini;
                *ptype = 15;
                }
            else
                {
                fprintf(stderr,
                    "get_rec: plaid zone %8x not recognised\n", **pprec);
                *ptype = -1;
                }
            state[n] = state[n] - 0x00000100 + fsize;
            if ((state[n] & 0x00ffffff) == 0)
                state[n] = 0;
            return;
            }
        }
    fprintf(stderr, "get_rec: state %8x not recognised\n", state[n]);
    }
first_word = **pprec;
if ((first_word & 0xc000) == 0)                 /* Horizontal vector code */
    {
    *ptype = 3;
    xinc = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
    current_x[n] += xinc;
    *px = current_x[n];
    *py = current_y[n];
    *pbeta = 0;
    next_step(pprec, pdata_origin, n, 1);
    return;
    }
else if ((first_word & 0xc000) == 0x4000)       /* Vertical vector code */
    {
    *ptype = 4;
    *px = current_x[n];
    yinc = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
    current_y[n] += yinc;
    *py = current_y[n];
    *pbeta = 0;
    next_step(pprec, pdata_origin, n, 1);
    return;
    }
else if ((first_word & 0xc000) == 0x8000)       /* Short vector code */
    {
    *ptype = 2;
    xinc = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
    current_x[n] += xinc;
    *px = current_x[n];
    second_word = *(*pprec + 1);
    yinc = ((fix31)(second_word)) << 16 >> 16;
    current_y[n] += yinc;
    *py = current_y[n];
    *pbeta = 0;
    next_step(pprec, pdata_origin, n, 2);
    return;
    }
else if ((first_word & 0xff00) == 0xe000)       /* Long vector code */
    {
    *ptype = 2;
    second_word = *(*pprec + 1);
    xinc = (((fix31)first_word) >> 4 << 28 >> 12) + second_word;
    current_x[n] += xinc;
    *px = current_x[n];
    third_word = *(*pprec + 2);
    yinc = (((fix31)first_word)  << 28 >> 12) + third_word;
    current_y[n] += yinc;
    *py = current_y[n];
    *pbeta = 0;
    next_step(pprec, pdata_origin, n, 3);
    return;
    }
else if ((first_word & 0xe000) == 0xc000)       /* Short arc code */
    {
    *ptype = 5;
    second_word = *(*pprec + 1);
    xinc = (((fix31)first_word) << 22 >> 22);
    current_x[n] += xinc;
    *px = current_x[n];
    yinc = (((fix31)second_word)  << 22 >> 22);
    current_y[n] += yinc;
    *py = current_y[n];
    *pbeta = ((((fix31)first_word) >> 10 << 16) + second_word) >> 10 << 23;
    next_step(pprec, pdata_origin, n, 2);
    return;
    }
else if ((first_word & 0xff00) == 0xe100)       /* Long arc code */
    {
    *ptype = 5;
    second_word = *(*pprec + 1);
    xinc = (((fix31)first_word) >> 4 << 28 >> 12) + second_word;
    current_x[n] += xinc;
    *px = current_x[n];
    third_word = *(*pprec + 2);
    yinc = (((fix31)first_word)  << 28 >> 12) + third_word;
    current_y[n] += yinc;
    *py = current_y[n];
    fourth_word = *(*pprec + 3);
    *pbeta = ((fix31)fourth_word) << 16;
    next_step(pprec, pdata_origin, n, 4);
    return;
    }
else if ((first_word & 0xff00) == 0xf000)       /* Move code */
    {
    *ptype = 1;
    second_word = *(*pprec + 1);
    current_x[n] = (((fix31)first_word) >> 4 << 28 >> 12) + second_word;
    *px = current_x[n];
    third_word = *(*pprec + 2);
    current_y[n] = (((fix31)first_word)  << 28 >> 12) + third_word;
    *py = current_y[n];
    *pbeta = 0;
    next_step(pprec, pdata_origin, n, 3);
    return;
    }
else if ((first_word & 0xff00) == 0xf100)       /* End outline code */
    {
    *pprec += 1;
    goto again;
    }
else if ((first_word & 0xff00) == 0xe200)       /* Call code */
    {
    if (repeat_active[n])                       /* Call code during repeat */
        {
        *ptype = 0;
        return;
        }
    else
        {
        ret_count[n] = first_word & 0x00ff;     /* Initialize step count */
        if (ret_count[n] == 0)                  /* Ignore if step count = 0 */
            {
            *pprec += 2;
            goto again;
            }
/*TPL*/ ret_offset[n] = (ufix32)(*pprec - pdata_origin) + 2; /* Save return address */
        *pprec = pdata_origin + (*(*pprec + 1)); /* Set next address */
        repeat_active[n] = 1;
        goto again;
        }
    }
else if ((first_word & 0xff00) == 0xe300)       /* End char code  */
    {                                              
    *ptype = 0;
    next_step(pprec, pdata_origin, n, 1);
    return;                                       
    }
else if ((first_word & 0xff00) == 0xf200)       /* Set position code */
    {
    *ptype = 7;
    second_word = *(*pprec + 1);
    *px = (((fix31)first_word) >> 4 << 28 >> 12) + second_word;
    third_word = *(*pprec + 2);
    *py = (((fix31)first_word)  << 28 >> 12) + third_word;
    next_step(pprec, pdata_origin, n, 3);
    return;
    }
else if ((first_word & 0xff00) == 0xf300)       /* Set scale factors code */
    {
    *ptype = 6;
    second_word = *(*pprec + 1);
    *px = (((fix31)second_word) << 16 >> 12);
    third_word = *(*pprec + 2);
    *py = (((fix31)third_word)  << 16 >> 12);
    next_step(pprec, pdata_origin, n, 3);
    return;
    }
else if ((first_word & 0xff00) == 0xf400)       /* Do char code */
    {
    *ptype = 12;
    second_word = *(*pprec + 1);
    *px = second_word;
    next_step(pprec, pdata_origin, n, 2);
    return;
    }
else if ((first_word & 0xff00) == 0xf500)       /* X extents code */
    {
    *ptype = 8;
    second_word = *(*pprec + 1);
    *px = (((fix31)first_word) >> 4 << 28 >> 12) + second_word;
    state[n] = 0x01000000 + (first_word & 0x000f);
    *pprec += 2;
    return;
    }
else if ((first_word & 0xff00) == 0xf600)       /* Y extents code */
    {
    *ptype = 10;
    second_word = *(*pprec + 1);
    *py = (((fix31)first_word) >> 4 << 28 >> 12) + second_word;
    state[n] = 0x02000000 + (first_word & 0x000f);
    *pprec += 2;
    return;
    }
else if ((first_word & 0xff00) == 0xf700)       /* Plaid edge values code */
    {
    pxedges[n] = *pprec += 1;                   /* Set pointer to x edges */
    pyedges[n] = *pprec                         /* Set prec to y edges */
        += (first_word & 0x00f0) >> 4;
    *pprec += first_word & 0x000f;              /* Move to zone data */

    if ((**pprec & 0xff00) == 0xf800)
        {
        state[n] = 0x04000000
            + ((ufix32)(**pprec & 0x00f0) << 12)
            + ((**pprec & 0x000f) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else if (**pprec == 0xfff2)
        {
        (*pprec)++;
        state[n] = 0x04000000
            + ((ufix32)((**pprec & 0xff00) + (**pprec & 0x00ff)) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else
        {
        fprintf(stderr,
            "get_rec: Plaid edge values not followed by plaid zone data\n");
        goto error;
        }
    }
else if ((first_word & 0xff00) == 0xfa00)      /* Long plaid edge vals code */
    {
    pxedges[n] = *pprec += 1;                  /* Set pointer to x edges */
    pyedges[n] = *pprec                        /* Set prec to y edges */
        += (first_word & 0x00f0) >> 3;
    *pprec += (first_word & 0x000f) << 1;      /* Move to zone data */

    if ((**pprec & 0xff00) == 0xf800)
        {
        state[n] = 0x05000000
            + ((ufix32)(**pprec & 0x00f0) << 12)
            + ((**pprec & 0x000f) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else if (**pprec == 0xfff2)
        {
        (*pprec)++;
        state[n] = 0x05000000
            + ((ufix32)((**pprec & 0xff00) + (**pprec & 0x00ff)) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else
        {
        fprintf(stderr,
           "get_rec: Long plaid edge vals not followed by plaid zone data\n");
        goto error;
        }
    }
else if ((first_word & 0xffff) == 0xfff0)       /* Plaid edge values code */
    {
    second_word = *(*pprec + 1);
    pxedges[n] = *pprec += 2;                   /* Set pointer to x edges */
    pyedges[n] = *pprec                         /* Set prec to y edges */
        += (second_word & 0xff00) >> 8;
    *pprec += second_word & 0x00ff;             /* Move to zone data */

    if ((**pprec & 0xff00) == 0xf800)
        {
        state[n] = 0x04000000
            + ((ufix32)(**pprec & 0x00f0) << 12)
            + ((**pprec & 0x000f) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else if (**pprec == 0xfff2)
        {
        (*pprec)++;
        state[n] = 0x04000000
            + ((ufix32)((**pprec & 0xff00) + (**pprec & 0x00ff)) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else
        {
        fprintf(stderr,
 "get_rec: Plaid edge values (more than 15) not followed by plaid zone data\n"
            );
        goto error;
        }
    }
else if ((first_word & 0xffff) == 0xfff1)      /* Long plaid edge vals code */
    {
    second_word = *(*pprec + 1);
    pxedges[n] = *pprec += 2;                  /* Set pointer to x edges */
    pyedges[n] = *pprec                        /* Set prec to y edges */
        += (second_word & 0xff00) >> 8;
    *pprec += second_word & 0x00ff;            /* Move to zone data */

    if ((**pprec & 0xff00) == 0xf800)
        {
        state[n] = 0x05000000
            + ((ufix32)(**pprec & 0x00f0) << 12)
            + ((**pprec & 0x000f) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else if (**pprec == 0xfff2)
        {
        (*pprec)++;
        state[n] = 0x05000000
            + ((ufix32)((**pprec & 0xff00) + (**pprec & 0x00ff)) << 8);
        (*pprec)++;
        if ((state[n] & 0x00ffffff) == 0)
            state[n] = 0;
        goto again;
        }
    else
        {
        fprintf(stderr,
         "get_rec: Long plaid edge values not followed by plaid zone data\n");
        goto error;
        }
    }
else if ((first_word & 0xff00) == 0xf900)       /* Hierarchy values code */
    {
    state[n] = 0x03000000 + (first_word & 0x00ff);
    (*pprec)++;
    if ((state[n] & 0x00ffffff) == 0)
        state[n] = 0;
    goto again;
    }
fprintf(stderr, "get_rec: Illegal code: %4x \n", first_word);
error: *ptype = -1;
next_step(pprec, pdata_origin, n, 1);
}

FUNCTION next_step(pprec, pdata_origin, n, word_count)
ufix16 **pprec, *pdata_origin, n;
fix15 word_count;
/* Updates *pprec to point to next record. */
/* n = number of words in current record */
/* Tracks repeat subroutine and inserts return when appropriate. */
{
if (repeat_active[n])                           /* Repeat sequence active */
    {                                  
    if (--ret_count[n] == 0)                    /* Step count now zero */
        {
        repeat_active[n] = 0;              
        *pprec = ret_offset[n] + pdata_origin;  /* Restore return address */
        return;
        }
    }
*pprec += word_count;
}

FUNCTION fix15 is_c_zone(pprec, pfrom, pto, pplc, pmin, pfsize)
ufix16 **pprec;
ufix16 *pfrom;
ufix16 *pto;
ufix16 *pplc;
ufix16 *pmin;
ufix16 *pfsize;
/* Interprets the record at *pprec as a plaid zone definition              */
/* Unpacks from edge number into *pfrom                                    */
/* Unpacks to edge number into *pto                                        */
/* Unpacks prop, level and cont flags into *pplc                           */
/* Unpacks min into *pmin                                                  */
/* Unpacks function size into *pfsize                                      */
/* Always returns true because any binary value is interpretable as a      */
/* plaid zone definition                                                   */
{
ufix16 word;

word = **pprec;
if ((word & 0xf000) != 0xf000)
    {
    *pfrom = word >> 12;
    *pto = (word >> 8) & 0x000f;
    *pplc = (word >> 5) & 0x0007;
    *pfsize = (word >> 3) & 0x0003;
    *pmin = word & 0x0007;
    (*pprec)++;
    }
else 
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
return(1);
}

FUNCTION fix15 is_c_p_item(pprec, pchar_no, pdim, pzone_no)
ufix16 **pprec;
ufix16 *pchar_no;
ufix16 *pdim;
ufix16 *pzone_no;
/* Tests if the data at *pprec is a plaid P item definition               */
/* If so:                                                                 */
/*   Unpacks the character number into *pchar_no                          */
/*   Unpacks the dimension flag into *pdim                                */
/*   Unpacks the zone number into *pzone_no                               */
/*   Returns true                                                         */
/* If not, returns false                                                  */
{
ufix16 word;

word = **pprec;
if ((word & 0xc000) == 0x0000)
    {
    *pchar_no = (word >> 5) & 0x01ff;
    *pdim = (word >> 4) & 0x0001;
    *pzone_no = word & 0x000f;
    (*pprec)++;
    return(1);
    }
else if ((word & 0xff00) == 0xf000)
    {
    *pzone_no = word & 0x00ff;
    (*pprec)++;
    word = **pprec;
    *pchar_no = word >> 1;
    *pdim = word & 0x0001;
    (*pprec)++;
    return(1);
    }
return(0);
}

FUNCTION fix15 is_c_f_item(pprec, pchar_no, pdim, pzone_no)
ufix16 **pprec;
ufix16 *pchar_no;
ufix16 *pdim;
ufix16 *pzone_no;
/* Tests if the data at *pprec is a plaid F item definition               */
/* If so:                                                                 */
/*   Unpacks the character number into *pchar_no                          */
/*   Unpacks the dimension flag into *pdim                                */
/*   Unpacks the zone number into *pzone_no                               */
/*   Returns true                                                         */
/* If not, returns false                                                  */
{
ufix16 word;

word = **pprec;
if ((word & 0xc000) == 0x4000)
    {
    *pchar_no = (word >> 5) & 0x01ff;
    *pdim = (word >> 4) & 0x0001;
    *pzone_no = word & 0x000f;
    (*pprec)++;
    return(1);
    }
else if ((word & 0xff00) == 0xf100)
    {
    *pzone_no = word & 0x00ff;
    (*pprec)++;
    word = **pprec;
    *pchar_no = word >> 1;
    *pdim = word & 0x0001;
    (*pprec)++;
    return(1);
    }
return(0);
}

FUNCTION fix15 is_c_t_item(pprec, pchar_no, pdim, pzone_no)
ufix16 **pprec;
ufix16 *pchar_no;
ufix16 *pdim;
ufix16 *pzone_no;
/* Tests if the data at *pprec is a plaid T item definition               */
/* If so:                                                                 */
/*   Unpacks the character number into *pchar_no                          */
/*   Unpacks the dimension flag into *pdim                                */
/*   Unpacks the zone number into *pzone_no                               */
/*   Returns true                                                         */
/* If not, returns false                                                  */
{
ufix16 word;

word = **pprec;
if ((word & 0xff00) == 0xf200)
    {
    *pzone_no = word & 0x00ff;
    (*pprec)++;
    word = **pprec;
    *pchar_no = word >> 1;
    *pdim = word & 0x0001;
    (*pprec)++;
    return(1);
    }
return(0);
}

FUNCTION fix15 is_c_const_item(pprec, pmantissa, pexponent)
ufix16 **pprec;
fix31   *pmantissa, *pexponent;
{
/* Tests if the data at *pprec is a plaid constant item definition        */
/* If so, converts the decimal constant to binary and                     */
/*    Assigns the mantissa to *pmantissa                                  */
/*    Assigns the exponent to *pexponent                                  */
/*    Returns true                                                        */
/* If not, returns false                                                  */
ufix16 word;

word = **pprec;
if ((word & 0xc000) == 0x8000)
    {
    init_acc();
    if ((word & 0xf000) == 0x8000)
        {
        acc_digit(word & 0x000f);
        acc_digit((word >> 4) & 0x000f);
        acc_digit((word >> 8) & 0x000f);
        (*pprec)++;
        }
    else if ((word & 0xf000) == 0x9000)
        {
        acc_digit(word & 0x000f);
        acc_digit((word >> 4) & 0x000f);
        acc_digit((word >> 8) & 0x000f);
        (*pprec)++;
        word = **pprec;
        acc_digit(word & 0x000f);
        acc_digit((word >> 4) & 0x000f);
        acc_digit((word >> 8) & 0x000f);
        acc_digit((word >> 12) & 0x000f);
        (*pprec)++;
        }
    else if ((word & 0xf000) == 0xa000)
        {
        acc_digit(word & 0x000f);
        acc_digit((word >> 4) & 0x000f);
        acc_digit((word >> 8) & 0x000f);
        (*pprec)++;
        word = **pprec;
        acc_digit(word & 0x000f);
        acc_digit((word >> 4) & 0x000f);
        acc_digit((word >> 8) & 0x000f);
        acc_digit((word >> 12) & 0x000f);
        (*pprec)++;
        word = **pprec;
        acc_digit(word & 0x000f);
        acc_digit((word >> 4) & 0x000f);
        acc_digit((word >> 8) & 0x000f);
        acc_digit((word >> 12) & 0x000f);
        (*pprec)++;
        }
    else
        {
        fprintf(stderr,
            "is_c_const_item: Unrecognised constant item %4x\n", word);
        }
    *pmantissa = acc_mantissa * acc_sign;
    *pexponent = acc_exponent;
    return(1);
    }
return(0);
}

FUNCTION fix15 is_c_op_item(pprec, pop_code, plast_item)
ufix16 **pprec;
ufix16 *pop_code;
ufix16 *plast_item;
/* Tests if the data at *pprec is a plaid operator item definition        */
/* If so:                                                                 */
/*    Unpacks the operator code into *pop_code                            */
/*    Unpacks the last item flag into *plast_item                         */
/*    Returns true                                                        */
/* If not, returns false                                                  */
{
ufix16 word;

word = **pprec;
if ((word & 0xe000) == 0xc000)
    {
    *plast_item = (word >> 12) & 0x0001;
    *pop_code = word & 0x0fff;
    (*pprec)++;
    return(1);
    }
return(0);
}

FUNCTION init_acc()
/* Initializes the decimal to binary conversion accumulator               */
{
acc_mantissa = 0;
acc_exponent = 0;
acc_dec_pt_read = 0;
acc_sign = 1;
acc_term_read = 0;
}

FUNCTION acc_digit(digit)
ufix16 digit;
/* Accumulates the digit into the decimal to binary conversion accumulator  */
{
if (digit < 0xa)
    {
    acc_mantissa = acc_mantissa * 10 + digit;
    if (acc_dec_pt_read)
        acc_exponent--;
    }
else if (digit == 0xa)
    acc_term_read = 1;
else if (digit == 0xb)
    {
    if (acc_dec_pt_read)
        fprintf(stderr, "acc_digit: two decimal points read\n");
    else
        acc_dec_pt_read = 1;
    }
else if (digit == 0xc)
    {
    acc_sign = -1;
    }
else
    {
    fprintf(stderr, "acc_digit: Illegal digit code %d\n", digit);
    }
}
