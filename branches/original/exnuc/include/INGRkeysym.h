/* 
 * Copyright 1990 Intergraph Corporation
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of Intergraph Corporation not be used 
 * in advertising or publicity pertaining to distribution of the software 
 * without specific, written prior permission.  Intergraph Corporation 
 * makes no representations about the suitability of this software for 
 * any purpose.  It is provided "as is" without express or implied warranty.
 *
 * INTERGRAPH CORPORATION DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS 
 * SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND 
 * FITNESS, IN NO EVENT SHALL INTERGRAPH CORPORATION BE LIABLE 
 * FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN 
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Author:	Doyle C. Davidson
 *		Intergraph Corporation
 *		One Madison Industrial Park
 *		Huntsville, Al.  35894-0001
 *
 * Intergraph Keysyms:
 *
 *	These are needed because Intergraph keyboards
 *	have more function keys that are in the standard X protocol
 *	(we have 47, X allows 35)
 *
 *	The bottom row (c1-c16) will map to XK_F1 thru XK_F16.
 *	This way, the standard X function key keysyms will still
 *	work and be somewhat intuitive.
 *
 *	The top two rows (a1-a15, b1-b16) will have their own keysyms.
 *	In addition we also have the following keys that need new keysyms:
 *		Remove
 *		Repeat
 *		2nd Function Left
 *		2nd Function Right (not A16)
 *
 *	Notice that the keysyms are encoded so that the LSByte will be
 *	the function key number and the next byte will be either 
 *	0x41 ('A') or 0x42 ('B') corresponding to the row or
 *	0x40 for one of the other keys.
 *	Ok, ok, you got a better idea!
 *
 */

#define IXK_2ND_FUNC_L	0x10004001
#define IXK_2ND_FUNC_R	0x10004002
#define IXK_REMOVE	0x10004003
#define IXK_REPEAT	0x10004004

#define IXK_A1		0x10004101
#define IXK_A2		0x10004102
#define IXK_A3		0x10004103
#define IXK_A4		0x10004104
#define IXK_A5		0x10004105
#define IXK_A6		0x10004106
#define IXK_A7		0x10004107
#define IXK_A8		0x10004108
#define IXK_A9		0x10004109
#define IXK_A10		0x1000410A
#define IXK_A11		0x1000410B
#define IXK_A12		0x1000410C
#define IXK_A13		0x1000410D
#define IXK_A14		0x1000410E
#define IXK_A15		0x1000410F
#define IXK_B1		0x10004201
#define IXK_B2		0x10004202
#define IXK_B3		0x10004203
#define IXK_B4		0x10004204
#define IXK_B5		0x10004205
#define IXK_B6		0x10004206
#define IXK_B7		0x10004207
#define IXK_B8		0x10004208
#define IXK_B9		0x10004209
#define IXK_B10		0x1000420A
#define IXK_B11		0x1000420B
#define IXK_B12		0x1000420C
#define IXK_B13		0x1000420D
#define IXK_B14		0x1000420E
#define IXK_B15		0x1000420F
#define IXK_B16		0x10004210
