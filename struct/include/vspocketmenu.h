/*
	I/STRUCT
*/
#ifndef vspocketmenu_include
#	define vspocketmenu_include

/*
 * This structure contains information about gadgets to add to default pocket
 * menu.
 */
struct VSaddGadget {
	long	type_cmd ;	/* type of command FI_CMD_KEY or	     */
				/* FI_CMD_STRING.			     */
	char	*cmd ;		/* the command string or ASCII key.	     */
	char	*symbol_file ;	/* name of symbol file. 		     */
	char	symbol_index ;	/* symbol index in symbol file. 	     */
	int	label ; 	/* set by function.			     */
} ;

/*
 * Values returned by functions.
 */
#define VS_K_pk_ST_PK_MN_EXISTS    0x10 /* Structural pocket menu exists.    */
#define VS_K_pk_ST_PK_MN_NOT_HERE  0x20 /* Structural pocket menu doesn't    */
					/* exist.			     */
#define VS_K_pk_PK_MN_NOT_FOUND    0x40 /* Default pocket menu not found.    */
#define VS_K_pk_ERROR		   0x80 /* Error encountered.		     */

#endif
