
#ifndef fielddef_include

#define fielddef_include

#define h_TYPE    'h'
#define V_TYPE    'v'
#define X_TYPE    'x'
#define Y_TYPE    'y'
#define w_TYPE    'w'
#define F_TYPE    'F'
#define f_TYPE    'f'
#define s_TYPE    's'
#define E_TYPE    'E'
#define M_TYPE    'M'
#define m_TYPE    'm'


#define horizon_move(a,b,c) \
( \
	*a++ = ESC, \
	*a++ = h_TYPE, \
	memcpy(a,&(b),8), \
	a += 8, \
	c+=10 \
)

#define vertical_move(a,b,c) \
( \
	*a++ = ESC, \
	*a++ = V_TYPE, \
	memcpy(a,&(b),8), \
	a += 8, \
	c +=10 \
)

#define change_size(a,b,c) \
( \
	*a++ = ESC, \
	*a++ = s_TYPE, \
	memcpy(a,&(b),8), \
	a += 8, \
	c +=10 \
)

#define X_scale(a,b,c) \
( \
	*a++ = ESC, \
	*a++ = X_TYPE, \
	memcpy(a,&(b),8), \
	a += 8, \
	c +=10 \
)

#define Y_scale(a,b,c) \
( \
	*a++ = ESC, \
	*a++ = Y_TYPE, \
	memcpy(a,&(b),8), \
	a += 8, \
	c +=10 \
)

#define change_font(a,b,c) \
( \
	*a++ = ESC, \
	*a++ = f_TYPE, \
	memcpy(a,&(b),2), \
	a += 2, \
	c += 4 \
)

#define change_weight(a,b,c) \
( \
	*a++ = ESC, \
	*a++ = w_TYPE, \
	*a++ = (b), \
	 c  += 3 \
)

#define start_field(a,b,c,d) \
( \
	*a++ = ESC, \
	*a++ = F_TYPE, \
	*a++ = (b), \
	*a++ = (c), \
	 d += 4 \
)

#define end_field(a,b) \
( \
	*a++ = ESC, \
	*a++ = E_TYPE, \
	 b += 2 \
)
					   
#define justify_field(a,b,c,d) \
( \
	*a++ = ESC, \
	*a++ = m_TYPE, \
	*a++ = (b), \
	memcpy(a,&(c),8), \
	a += 8, \
	memcpy(a,&(c),8), \
	a += 8, \
	d +=19 \
)

#define move_to_field(a,b,c,d,e,f) \
( \
	*a++ = ESC, \
	*a++ = M_TYPE, \
	*a++ = (b), \
	*a++ = (c), \
	memcpy(a,&(d),8), \
	a += 8, \
	memcpy(a,&(e),8), \
	a += 8, \
	f +=20 \
)

#endif


