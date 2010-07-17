/*****************************************************************************/
/*                        						     */
/*									     */
/*	Author : B Demars                                                    */
/*	Date   : 08 Nov 1991						     */
/*                                                                           */
/*  This file contains macros that should be shifted into higher products    */
/*  I/VDS or .... I/EXNUC.						     */
/*                                                                           */
/*  The function implementation are situated in the VRGlobFun.I file         */
/*                                                                           */
/*****************************************************************************/

#ifndef vrglobmac_include

#define vrglobmac_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern	int VRGetPath __((	IGRlong			*msg,
				IGRchar			*product_name,
				IGRchar			*file_path,
				IGRchar 		*product_path,
				IGRint  		product_path_len ));
#if defined(__cplusplus)
}
#endif
/************************************************************************/
/*									*/
/* Abstract :	VR$GetUnixPath ( see also ex$get_path)  returns the unix*/
/* 		path to a product or a file or a file in a product	*/
/* 		depending on the specified arguments.			*/
/* Arguments :								*/
/*									*/
/* O IGRlong *msg    		Completion code,returns MSSUCC or MSFAIL*/
/* I IGRchar *product_name	If specified, will only get this product*/
/*				path.					*/
/* I IGRchar *file_path		If specified, the path to the product	*/
/*				will only be returned if this file	*/
/*				exists in this path.			*/
/* I IGRint  product_path_len	Size of the specified product_path	*/
/*				buffer.					*/
/* O 	Returns the product path.					*/
/*									*/
/* E.g. : 								*/
/*	VR$GetUnixPath ( msg = &msg, product_name="Route", 		*/
/*			 product_path = string, 			*/
/*			 product_path_len = 30 ); 			*/
/*									*/
/*	will return "/usrX/ip32/route" in product_path			*/
/*									*/
/*	VR$GetUnixPath ( msg = &msg, product_name="Isogen", 		*/
/*			 file_path = "config/iso/isogen.sh",		*/
/*			 product_path = string, 			*/
/*			 product_path_len = 30 ); 			*/
/*									*/
/*	will return "/usrX/ip32/isogen" in product_path	if the		*/
/*	file isogen.sh exists in /usrX/ip32/isogen/config/iso		*/
/*									*/
/*	VR$GetUnixPath ( msg = &msg,					*/
/*			 file_path = "config/iso/triflex.sh",		*/
/*			 product_path = string, 			*/
/*			 product_path_len = 30 ); 			*/
/*									*/
/*	will return in product_path the path of one of the RUNNING	*/
/*	products in which the file config/iso/triflex.sh exists 	*/
/************************************************************************/

#omdef VR$GetUnixPath ( 	msg,
				product_name=NULL,
				file_path=NULL,
				product_path,
				product_path_len )

VRGetPath( (msg), (product_name), (file_path), (product_path), (product_path_len))

#endomdef


#endif
