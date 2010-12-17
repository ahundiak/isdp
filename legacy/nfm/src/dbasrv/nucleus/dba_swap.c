/* $Revision: 1.1 $ */

/*  This code borrowed from the RIS group */

union short_1
{
	short s;
	struct
	{
		char b1;
		char b2;
	} byte;
};

union short_2
{
	short s;
	struct
	{
		char b2;
		char b1;
	} byte;
};

union int_1
{
	int i;
	struct
	{
		char b1;
		char b2;
		char b3;
		char b4;
	} byte;
};

union int_2
{
	int i;
	struct
	{
		char b4;
		char b3;
		char b2;
		char b1;
	} byte;
};


/*  F u n c t i o n:	dba_int_swap_copy
    Author:	Tim A. Thompson
    Date:	20-JAN-92
*/

void dba_int_swap_copy(d, s)
int *d, *s;
{
  union int_1 i1;
  union int_2 i2;

/*
  i1.i = *s;
*/
  memcpy (&i1.i, s, 4);
  i2.byte.b1 = i1.byte.b1;
  i2.byte.b2 = i1.byte.b2;
  i2.byte.b3 = i1.byte.b3;
  i2.byte.b4 = i1.byte.b4;
/*
  *d = i2.i;
*/
  memcpy (d, &i2.i, 4);
}


/*  F u n c t i o n:	dba_int_swap_bytes */

void dba_int_swap_bytes(i)
int *i;
{
#ifndef isl              /* Intelsolaris Port */
	union int_1 i1;
	union int_2 i2;

/*
	i1.i = *i;
*/
        memcpy (&i1.i, i, 4);
	i2.byte.b1 = i1.byte.b1;
	i2.byte.b2 = i1.byte.b2;
	i2.byte.b3 = i1.byte.b3;
	i2.byte.b4 = i1.byte.b4;
/*
	*i = i2.i;
*/
        memcpy (i, &i2.i, 4);
#endif
}


/*  F u n c t i o n:	dba_short_swap_copy
    Author:	Tim A. Thompson
    Date:	20-JAN-92
*/

void dba_short_swap_copy (d, s)
short *d, *s;
{
  union short_1 s1;
  union short_2 s2;

/*
  s1.s = *s;
*/
  memcpy (&s1.s, s, 2);
  s2.byte.b1 = s1.byte.b1;
  s2.byte.b2 = s1.byte.b2;
/*
  *d = s2.s;
*/
  memcpy (d, &s2.s, 2);
}


/*  F u n c t i o n:	dba_short_swap_bytes */

void dba_short_swap_bytes(s)
short *s;
{
#ifndef isl              /* Intelsolaris Port */
	union short_1 s1;
	union short_2 s2;

/*
	s1.s = *s;
*/
        memcpy (&s1.s, s, 2);
	s2.byte.b1 = s1.byte.b1;
	s2.byte.b2 = s1.byte.b2;
/*
	*s = s2.s;
*/
        memcpy (s, &s2.s, 2);
#endif
}


/*  F u n c t i o n:    dba_double_swap_bytes */

void dba_double_swap_bytes(d)
double *d;
{
#ifndef isl              /* Intelsolaris Port */
    unsigned char tmp[4];

    memcpy (tmp, (unsigned char *)d, 4);
    ((unsigned char *)d)[0] = ((unsigned char *)d)[7];
    ((unsigned char *)d)[1] = ((unsigned char *)d)[6];
    ((unsigned char *)d)[2] = ((unsigned char *)d)[5];
    ((unsigned char *)d)[3] = ((unsigned char *)d)[4];
    ((unsigned char *)d)[4] = tmp[3];
    ((unsigned char *)d)[5] = tmp[2];
    ((unsigned char *)d)[6] = tmp[1];
    ((unsigned char *)d)[7] = tmp[0];
#endif
}
