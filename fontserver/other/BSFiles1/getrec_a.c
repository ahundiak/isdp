




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/************************** G E T R E C _ A B S . C **************************
 ********************** R E V I S I O N   H I S T O R Y **********************

 1)  10-Jan-86  jsc   Removed function 'check_outlines'

 *****************************************************************************

    Routines for unpacking compressed outline data (absolute format, no plaid)

 ****************************************************************************/








#include    "../hfiles/stdef.h"



static ufix16 state[2], repeat_active[2], ret_count[2], ret_offset[2];
static ufix16 x_extn_flag[2], y_extn_flag[2], beta_extn_flag[2];
static fix31 x_extn[2], y_extn[2], beta_extn[2];
static fix31 current_x[2], current_y[2];
static fix31 x_org[2], y_org[2];
static ufix16 *pxedges[2], *pyedges[2];
static ufix16 saved_state, saved_repeat_active, saved_ret_count, saved_ret_offset;
static ufix16 saved_x_extn_flag, saved_y_extn_flag, saved_beta_extn_flag;
static fix31    saved_current_x, saved_current_y;
static fix31    saved_x_org, saved_y_org;
static ufix16  *saved_pxedges, *saved_pyedges;
static fix15    char_count;

FUNCTION init_arec_state(n)
ufix16 n;
{
state[n] = 0;
repeat_active[n] = 0;                                      /* Clear call stack */
x_extn_flag[n] = y_extn_flag[n] = beta_extn_flag[n] = 0;
current_x[n] = current_y[n] = 0;
x_org[n] = y_org[n] = 0;
}
         

FUNCTION save_arec_state(n)
ufix16 n;
{
saved_state = state[n];
saved_repeat_active = repeat_active[n];
saved_ret_count = ret_count[n];
saved_ret_offset = ret_offset[n];
saved_x_extn_flag = x_extn_flag[n];
saved_y_extn_flag = y_extn_flag[n];
saved_beta_extn_flag = beta_extn_flag[n];
saved_current_x = current_x[n];
saved_current_y = current_y[n];
saved_x_org = x_org[n];
saved_y_org = y_org[n];
saved_pxedges = pxedges[n];
saved_pyedges = pyedges[n];
}


FUNCTION restore_arec_state(n)
ufix16 n;
{
state[n] = saved_state;
repeat_active[n] = saved_repeat_active;
ret_count[n] = saved_ret_count;
ret_offset[n] = saved_ret_offset;
x_extn_flag[n] = saved_x_extn_flag;
y_extn_flag[n] = saved_y_extn_flag;
beta_extn_flag[n] = saved_beta_extn_flag;
current_x[n] = saved_current_x;
current_y[n] = saved_current_y;
x_org[n] = saved_x_org;
y_org[n] = saved_y_org;
pxedges[n] = saved_pxedges;
pyedges[n] = saved_pyedges;
}


FUNCTION get_arec(n, pprec, pdata_origin, ptype, px, py, pbeta)
ufix16 n, **pprec, *pdata_origin, *ptype;
fix31  *px, *py, *pbeta;
/* get_arec fetches the next logical step from compressed outline data */
/* sets *ptype to indicate type of step read */
/*   -1: erroneous step read  */
/*    0: end of character or call while repeat active */
/*    1: move to (*px, *py) */
/*    2: vector to (*px, *py) */
/*    3: horizontal vector to (*px, *py) */
/*    4: vertical vector to (*px, *py) */
/*    5: arc to (*px, *py) with bulge factor *pbeta */
/*    6: set scale factors to *px, *py (units of 1/65536) */
/*    7: set origin to (*px, *py) */
/*    8: set x min extent (*px) */
/*    9: set x max extent (*px) */
/*   10: set y min extent (*py) */
/*   11: set y max extent (*py) */
/*   12: do char (*px) */
/*   13: hierarchy value (*px) */
/*   14: plaid x zone data (*px, *py, *pbeta) */
/*   15: plaid y zone data (*px, *py, *pbeta) */
{
ufix16 type, first_word, second_word, third_word;
fix31  x, y, beta, x_at_call, y_at_call;

again:
if (state[n])                                           /* Outstanding data to read */
    {
    first_word = state[n];
    if ((first_word & 0xff00) == 0xf000)                /* Extent data */
        {
        if ((first_word & 0x0003) == 0x0003)            /* 32 bit xmin data */
            {
            *px = (((fix31)(*(*pprec + 1))) << 16) + **pprec;
            *ptype = 8;
            *pprec += 2;
            state[n] = first_word - 0x0003;
            return;
            }
        if (first_word & 0x0001)                        /* 16 bit xmin data */
            {
            *px = ((fix31)(**pprec)) << 16 >> 16;
            *ptype = 8;
            (*pprec)++;
            state[n] = first_word - 0x0001;
            return;
            }
        if ((first_word & 0x000c) == 0x000c)            /* 32 bit xmax data */
            {
            *px = (((fix31)(*(*pprec + 1))) << 16) + **pprec;
            *ptype = 9;
            *pprec += 2;
            state[n] = first_word - 0x000c;
            return;
            }
        if (first_word & 0x0004)                        /* 16 bit xmax data */
            {
            *px = ((fix31)(**pprec)) << 16 >> 16;
            *ptype = 9;
            (*pprec)++;
            state[n] = first_word - 0x0004;
            return;
            }
        if ((first_word & 0x0030) == 0x0030)            /* 32 bit ymin data */
            {
            *py = (((fix31)(*(*pprec + 1))) << 16) + **pprec;
            *ptype = 10;
            *pprec += 2;
            state[n] = first_word - 0x0030;
            return;
            }
        if (first_word & 0x0010)                        /* 16 bit ymin data */
            {
            *py = ((fix31)(**pprec)) << 16 >> 16;
            *ptype = 10;
            (*pprec)++;
            state[n] = first_word - 0x0010;
            return;
            }
        if ((first_word & 0x00c0) == 0x00c0)            /* 32 bit ymax data */
            {
            *py = (((fix31)(*(*pprec + 1))) << 16) + **pprec;
            *ptype = 11;
            *pprec += 2;
            state[n] = first_word - 0x00c0;
            return;
            }
        if (first_word & 0x0040)                        /* 16 bit ymax data */
            {
            *py = ((fix31)(**pprec)) << 16 >> 16;
            *ptype = 11;
            (*pprec)++;
            state[n] = first_word - 0x0040;
            return;
            }
        }
    else if ((first_word & 0xff00) == 0xf100)           /* Do char parameters */
        {
        if (first_word & 0x000f)                        /* Origin data */
            {
            if ((first_word & 0x0003) == 0x0003)        /* 32 bit x origin data */
                {
                *px = (((fix31)(*(*pprec + 1))) << 16) + **pprec;
                *pprec += 2;
                first_word = first_word - 0x0003;
                }
            else if (first_word & 0x0001)               /* 16 bit x origin data */   
                {
                *px = ((fix31)(**pprec)) << 16 >> 16;
                (*pprec)++;
                first_word = first_word - 0x0001;
                }
            else
                *px = 0;
            if ((first_word & 0x000c) == 0x000c)        /* 32 bit y origin data */
                {
                *py = (((fix31)(*(*pprec + 1))) << 16) + **pprec;
                *pprec += 2;
                first_word = first_word - 0x000c;
                }
            else if (first_word & 0x0004)               /* 16 bit y origin data */
                {
                *py = ((fix31)(**pprec)) << 16 >> 16;
                (*pprec)++;
                first_word = first_word - 0x0004;
                }
            else
                *py = 0;
            state[n] = first_word;
            *ptype = 7;
            return;
            }
        if (first_word & 0x0030)                        /* Scale data */
            {
            if (first_word & 0x0010)                    /* x scale data */
                {
                *px = ((fix31)(**pprec)) << 4;
                (*pprec)++;
                first_word = first_word - 0x0010;
                }
            else
                *px = 65536;
            if (first_word & 0x0020)                    /* y scale data */
                {
                *py = ((fix31)(**pprec)) << 4;
                (*pprec)++;
                first_word = first_word - 0x0020;
                }
            else
                *py = 65536;
            state[n] = first_word;
            *ptype = 6;
            return;
            }
        }
    else if ((first_word & 0xff00) == 0xf200)           /* Hierarchy values */
        {
        if (first_word & 0x00ff)
            {
            *px = (fix31)(**pprec);
            (*pprec)++;
            state[n] = first_word - 1;
            *ptype = 13;
            return;
            }
        }
    else if ((first_word & 0xff00) == 0xfb00)           /* Plaid zone values */
        {
        if (first_word & 0x00f0)                        /* x zones */
            {
            *px = ((fix31)pxedges[n][((**pprec) & 0xf000) >> 12]) << 16 >> 16;
            *py = ((fix31)pxedges[n][((**pprec) & 0x0f00) >> 8]) << 16 >> 16;
            *pbeta = (fix31)((**pprec) & 0x00ff);
            (*pprec)++;
            state[n] = first_word - 0x10;
            *ptype = 14;
            return;
            }
        if (first_word & 0x000f)                        /* y zones */
            {
            *px = ((fix31)pyedges[n][((**pprec) & 0xf000) >> 12]) << 16 >> 16;
            *py = ((fix31)pyedges[n][((**pprec) & 0x0f00) >> 8]) << 16 >> 16;
            *pbeta = (fix31)((**pprec) & 0x00ff);
            (*pprec)++;
            state[n] = first_word - 1;
            *ptype = 15;
            return;
            }
        }
    state[n] = 0;
    next_astep(pprec, pdata_origin, n, 0);
    }
first_word = **pprec;
if ((first_word & 0xc000) == 0)                         /* Horizontal vector code */
    {
    *ptype = 3;
    if (x_extn_flag[n])
        {
        *px = x_extn[n] | (first_word & 0x3fff);
        x_extn_flag[n] = 0;
        }
    else
        *px = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
    current_x[n] = *px = *px - x_org[n];
    *py = current_y[n];
    *pbeta = 0;
    next_astep(pprec, pdata_origin, n, 1);
    return;
    }
else if ((first_word & 0xc000) == 0x4000)               /* Vertical vector code */
    {
    *ptype = 4;
    *px = current_x[n];
    if (y_extn_flag[n])
        {
        *py = y_extn[n] | (first_word & 0x3fff);
        y_extn_flag[n] = 0;
        }
    else
        *py = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
    current_y[n] = *py = *py - y_org[n];
    *pbeta = 0;
    next_astep(pprec, pdata_origin, n, 1);
    return;
    }
else if ((first_word & 0xc000) == 0x8000)  
    {
    second_word = *(*pprec + 1);
    if ((second_word & 0xc000) == 0)                    /* Move code */
        {
        *ptype = 1;
        if (x_extn_flag[n])
            {
            *px = x_extn[n] | (first_word & 0x3fff);
            x_extn_flag[n] = 0;
            }
        else
            *px = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
        current_x[n] = *px = *px - x_org[n];
        if (y_extn_flag[n])
            {
            *py = y_extn[n] | (second_word & 0x3fff);
            y_extn_flag[n] = 0;
            }
        else
            *py = ((fix31)(second_word & 0x3fff)) << 18 >> 18;
        current_y[n] = *py = *py - y_org[n];
        *pbeta = 0;
        next_astep(pprec, pdata_origin, n, 2);
        return;
        }
    else if ((second_word & 0xc000) == 0x4000)          /* Vector code */
        {
        *ptype = 2;
        if (x_extn_flag[n])
            {
            *px = x_extn[n] | (first_word & 0x3fff);
            x_extn_flag[n] = 0;
            }
        else
            *px = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
        current_x[n] = *px = *px - x_org[n];
        if (y_extn_flag[n])
            {
            *py = y_extn[n] | (second_word & 0x3fff);
            y_extn_flag[n] = 0;
            }
        else
            *py = ((fix31)(second_word & 0x3fff)) << 18 >> 18;
        current_y[n] = *py = *py - y_org[n];
        *pbeta = 0;
        next_astep(pprec, pdata_origin, n, 2);
        return;
        }
    else if ((second_word & 0xc000) == 0x8000)          /* Arc code */
        {
        third_word = *(*pprec + 2);
        *ptype = 5;
        if (x_extn_flag[n])
            {
            *px = x_extn[n] | (first_word & 0x3fff);
            x_extn_flag[n] = 0;
            }
        else
            *px = ((fix31)(first_word & 0x3fff)) << 18 >> 18;
        current_x[n] = *px = *px - x_org[n];
        if (y_extn_flag[n])
            {
            *py = y_extn[n] | (second_word & 0x3fff);
            y_extn_flag[n] = 0;
            }
        else
            *py = ((fix31)(second_word & 0x3fff)) << 18 >> 18;
        current_y[n] = *py = *py - y_org[n];
        if (beta_extn_flag[n])
            {
            *pbeta = (beta_extn[n] | (third_word & 0x3fff)) << 10;
            beta_extn_flag[n] = 0;
            }
        else
            *pbeta = ((fix31)(third_word & 0x3fff)) << 18;
        next_astep(pprec, pdata_origin, n, 3);
        return;
        }
    else
        {
        printf("get_arec: Illegal code: %4x %4x \n", first_word, second_word);
        goto error;
        }
    }
else if ((first_word & 0xf000) == 0xc000)               /* Call code */
    {
    if (repeat_active[n])                               /* Call code during repeat */
        {
        *ptype = 0;
        return;
        }
    else
        {
        ret_count[n] = first_word & 0x00ff;             /* Initialize step count */
        if (ret_count[n] == 0)                          /* Ignore if step count is zero */
            {
            *pprec += 2;
            goto again;
            }
        ret_offset[n] = *pprec + 2 - pdata_origin;      /* Save return address */
        *pprec = pdata_origin + (*(*pprec + 1));        /* Set next address */
        x_at_call = current_x[n];
        y_at_call = current_y[n];
        get_arec(n, pprec, pdata_origin, &type, &x, &y, &beta);
        if (type == 1 || type == 2 || type == 5)
            {
            x_org[n] = x - x_at_call;                   /* Set x offset */
            y_org[n] = y - y_at_call;                   /* Set y offset */
            }
        else if (type == 3)
            {
            x_org[n] = x - x_at_call;                   /* Set x offset */
            get_arec(n, pprec, pdata_origin, &type, &x, &y, &beta);
            if (type == 4)
                {
                y_org[n] = y - y_at_call;               /* Set y offset */
                }
            else
                {
                printf("get_arec: call finds types 3 and %d.\n", type);
                goto error;
                }
            }
        else if (type == 4)
            {
            y_org[n] = y - y_at_call;                   /* Set y offset */
            get_arec(n, pprec, pdata_origin, &type, &x, &y, &beta);
            if (type == 3)
                {
                x_org[n] = x - x_at_call;               /* Set y offset */
                }
            else
                {
                printf("get_arec: call finds types 4 and %d.\n", type);
                goto error;
                }
            }
        else
            {
            printf("get_arec: call finds type %d\n", type);
            goto error;
            }
        repeat_active[n] = 1;
        goto again;
        }
    }
else if ((first_word & 0xf000) == 0xd000)               /* Do char code */
    {
    *ptype = 12;
    *px = first_word & 0x00000fff;
    next_astep(pprec, pdata_origin, n, 1);
    return;
    }
else if ((first_word & 0xff00) == 0xf000)               /* Extent values code */
    {
    state[n] = first_word;
    (*pprec)++;
    goto again;
    }
else if ((first_word & 0xff00) == 0xf100)               /* Do char parameters code */
    {
    state[n] = first_word;
    (*pprec)++;
    goto again;
    }
else if ((first_word & 0xff00) == 0xf200)               /* Hierarchy values code */
    {
    state[n] = first_word;
    (*pprec)++;
    goto again;
    }
else if ((first_word & 0xff00) == 0xf300)               /* Set x extn code */
    {
    x_extn[n] = ((fix31)(first_word & 0x00ff)) << 24 >> 10;
    x_extn_flag[n] = 1;
    *pprec += 1;
    goto again;
    }
else if ((first_word & 0xff00) == 0xf400)               /* Set y extn code */
    {
    y_extn[n] = ((fix31)(first_word & 0x00ff)) << 24 >> 10;
    y_extn_flag[n] = 1;
    *pprec += 1;
    goto again;
    }
else if ((first_word & 0xff00) == 0xf500)               /* Set beta extn code */
    {
    beta_extn[n] = ((fix31)(first_word & 0x00ff)) << 24 >> 10;
    beta_extn_flag[n] = 1;
    *pprec += 1;
    goto again;
    }
else if ((first_word & 0xff00) == 0xfa00)               /* Plaid edge values code */
    {
    pxedges[n] = *pprec += 1;
    pyedges[n] = *pprec += (first_word & 0x00f0) >> 4;
    *pprec += first_word & 0x000f;
    if ((**pprec & 0xff00) != 0xfb00)
        printf("get_arec: Plaid edge values not followed by plaid zone data\n");
    state[n] = **pprec;
    (*pprec)++;
    goto again;
    }
else if (first_word == 0xffff)                          /* End char code  */
    {                                              
    *ptype = 0;
    next_astep(pprec, pdata_origin, n, 1);
    return;                                       
    }
printf("get_arec: Illegal code: %4x \n", first_word);
error: *ptype = -1;
next_astep(pprec, pdata_origin, n, 1);
}




FUNCTION next_astep(pprec, pdata_origin, n, word_count)
ufix16 **pprec, *pdata_origin, n;
fix15 word_count;
/* Updates *pprec to point to next record. */
/* n = number of words in current record */
/* Tracks repeat subroutine and inserts return when appropriate. */
{
if (repeat_active[n])                                   /* repeat sequence active */
    {                                  
    if (--ret_count[n] == 0)                              /* Step count now zero */
        {
        repeat_active[n] = 0;              
        *pprec = ret_offset[n] + pdata_origin;      /* Restore return address */
        x_org[n] = 0;
        y_org[n] = 0;
        return;
        }
    }
*pprec += word_count;
}
