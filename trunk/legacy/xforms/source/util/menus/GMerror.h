#ifndef	GMerror_include
#define	GMerror_include

#define	GM_S_SUCCESS	0

#define	GM_I_INFO	15
#define	GM_I_EOF	15

#define	GM_W_WARNING	30
#define	GM_W_TRUNCATE	30
#define	GM_W_PARSE	31

#define	GM_E_ERROR	45
#define	GM_E_WRITE	45
#define	GM_E_PARSE	46

#define	GM_F_FATAL	60
#define	GM_F_ALLOC	60
#define	GM_F_WRITE	61
#define	GM_F_IFORMS	62
#define	GM_F_MENU	63
#define	GM_F_PARSE	64
#define	GM_F_OUTLINE	65
#define	GM_F_USAGE	66

#define	GM_ERROR( status )	status >= GM_E_ERROR

#endif
