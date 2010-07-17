#include	<stdio.h>
#include	<string.h>
#include	"igrtypedef.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"

/* ************************************************************************** */
void	VLreadGlobals (		IGRchar		*str,
			struct	ACrg_coll	*attr	)
{
	IGRint		len;
	IGRchar		s[ATTR_NAME], *p, Tok[ATTR_NAME], Typ[ATTR_NAME];

	/* Initialize */
	attr->name[0] = '\0';
	attr->desc.type = AC_ATTRIB_TYPE_NOT_DEF;
	attr->desc.value.att_exp = 0.0;
	attr->desc.value.att_txt[0] = '\0';
	Typ[0] = '\0';

	/* Get input string length */
	len = strlen (str);
	if (!len)	return;
	if (str[len-1] == '\n') {	str[len-1] = '\0';
					len = strlen (str);	}
	

	/* Save input string */
	strcpy ( s, &str[0]);

	/* Define tokens */
	strcpy ( Tok, "\t");

	/* Get attribute name */
	p = strtok ( s, Tok);
	if ( (p != NULL) && (p[0] != '\0') )
		strcpy ( attr->name, p);
	else	return;
	len = strlen (attr->name);

	/* Get attribute value (string) */
	strcpy ( s, &str[len+1]);
	p = strtok ( s, Tok);
	if ( (p != NULL) && (p[0] != '\0') )
		strcpy ( attr->desc.value.att_txt, p);
	else	return;
	len += strlen (attr->desc.value.att_txt);

	/* Get attribute type */
	strcpy ( s, &str[len+1]);
	p = strtok ( s, Tok);
	if ( (p != NULL) && (p[0] != '\0') ) {
		strcpy ( Typ, p);
		sscanf ( Typ, "%d", &attr->desc.type);
	}

	/* Get attribute value */
	if (attr->desc.type == AC_ATTRIB_DOUBLE)
		sscanf ( attr->desc.value.att_txt,
			 "%lf",
			 &attr->desc.value.att_exp );

	return;
}
/* ************************************************************************** */
