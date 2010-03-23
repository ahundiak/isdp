/* 
 * File:   expshell.h
 * Author: impd
 *
 * Created on March 19, 2010, 3:22 PM
 */

#ifndef _EXPSHELL_H
#define	_EXPSHELL_H

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef __STDC__
extern int expand_shell(char *, int *, int);
#else
extern int expand_shell();
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* _EXPSHELL_H */

