/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				dlgxext.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Dynamic Dialog Box extensions

Revision History:

********************************************************************/
#ifndef _WINXEXT_H_
#define _WINXEXT_H_

#ifndef __WINDOWS_H
#include <windows.h>
#endif

   // Macro to define pointer version of a given typedef

#define TYPEDEF_POINTERS(base, type)		\
typedef base *                  P##type;        \
typedef const base *            PC##type;       \
typedef base NEAR *             NP##type;       \
typedef const base NEAR *       NPC##type;      \
typedef base FAR *              LP##type;       \
typedef const base FAR *        LPC##type;

//-------------------------------------------------------------------------
// WIN16 and WIN32 Compatibility definitions 
//-------------------------------------------------------------------------

#ifdef WIN32

  // Portable resource character type
  typedef WCHAR RCHAR;

  // Macro returning the length of a resource string. 
  #define _rcslen(lpcrsz)  wcslen(lpcrsz)
// per Atif  #define _rcslen(lpcrsz)   lstrlenW(lpcrsz)

  // Missing lstrcpyn() from Win32 API

//  #include <tchar.h>
//  #include <wchar.h>

//  #define lstrcpyn _tcsncpy

#else // WIN32

  // Portable basic character unit not included in Win16 header files
  // but is defined here.

  typedef char	TCHAR;

  TYPEDEF_POINTERS(TCHAR, TSTR)
  TYPEDEF_POINTERS(TCHAR, TCH)

  // Macro returning the length of a resource string.
  #define _rcslen(lpcsz)   lstrlen(lpcsz)

  // The following macro is to be used for string and character literals
  // appearing in the code. It is already defined in the Win32 SDK
  // header file.
  #define TEXT(text)		text

  // Portable resource character type 
  typedef char	RCHAR;

#endif	 // WIN32

//-------------------------------------------------------------------------
// Definitions common to WIN16 and WIN32 
//-------------------------------------------------------------------------

// Define string versions of RCHAR (PRSTR, LPRSTR, etc.)
TYPEDEF_POINTERS(RCHAR, RSTR)

   // Miscellaneous type definitions

typedef HWND NEAR *  NPHWND;

   // Other useful macros

#define ARRAY_COUNT(a)	   (sizeof(a) / sizeof((a)[0]))

#endif	// _WINXEXT_H_
