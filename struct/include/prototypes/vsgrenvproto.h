/*
	I/STRUCT
*/

#ifndef vsgrenvproto_include
#	define vsgrenvproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vsgraphicenv_include
#	include "vsgraphicenv.h"
#endif

extern int
VS_flipblock		__((	VSgrEnvWindow	*wno,
				int		x,
				int		y,
				int		X,
				int		Y )) ;

extern int
VS_Clear_scrap		__((	void )) ;

extern int
VS_Put_scrap		__((	char		*type,
				char		*buf,
				int		size )) ;

extern int
VS_Get_scrap		__((	char		*type,
				char		*data,
				int		*size,
				int		*index )) ;

extern int
VS_Wait_timer		__((	int		time )) ;

extern int
VS_Mouseposition	__((	VSgrEnvWindow	*wno,
				int		*x,
				int		*y,
				int		*work_status )) ;

extern int
VS_InqEvents		__((	VSgrEnvEvent	*events )) ;
extern int

VS_isKeyBoardEvent	__((	VSgrEnvEvent	*events )) ;

extern int
VS_isBtnOrWnEvent	__((	VSgrEnvEvent	*events )) ;

extern int
VS_isWnEvent		__((	VSgrEnvEvent	*events )) ;

extern int
VS_DPhandle_event	__((	VSgrEnvEvent	*events )) ;

extern int
VS_FI_process_event	__((	VSgrEnvEvent	*events )) ;

extern int
VS_FIf_get_window	__((	char		*form,
				VSgrEnvWindow	*p_wno )) ;

extern int
VS_FImouseposition	__((	char		*form,
				int		*x,
				int		*y,
				int		*work_status )) ;

extern int
VS_FIweight		__((	char		*form,
				int		weight )) ;

extern int
VS_FIfgcolor		__((	char		*form,
				int		color )) ;


extern int
VS_FIhidecursor		__((	char		*form )) ;

extern int
VS_FIshowcursor		__((	char		*form )) ;

#endif /* vsgrenvproto_include */
