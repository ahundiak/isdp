/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							prog32s.h
**	AUTHORS:						Rick Kramer
**	CREATION DATE:					3/23/94
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
#ifndef PROG32S_H
#define PROG32S_H

#undef PUTC
#undef PUTCHAR
#undef FPUTC
#undef PUTS
#undef FPUTS
#undef PRINTF
#undef FPRINTF
#undef VPRINTF
#undef VFPRINTF

#define GETS		VCgets
#define PUTC		putc
#define PUTCHAR	putchar
#define FPUTC		fputc
#define PUTS		VCputs
#define FPUTS		fputs
#define PRINTF		RIS_printf
#define FPRINTF	fprintf
#define VPRINTF	VCvprintf
#define VFPRINTF	vfprintf


#endif
