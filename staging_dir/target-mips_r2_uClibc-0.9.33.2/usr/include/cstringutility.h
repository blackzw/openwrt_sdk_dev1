//==========================================================================
/**
 *  @file    cstringutility.h
 *  @brief  The definition for string utility function.
 *  @version 1.0
 *  @author Tian Yiqing <yiqing.tian@tcl.com>
 *  @date 2013-10-15
 */
//==========================================================================

#ifndef CSTRINGUTILITY_H
#define CSTRINGUTILITY_H

#include<wchar.h>
#include <string>
using namespace std;

typedef unsigned short uint16;
typedef unsigned char uint8;
typedef unsigned short U16;
typedef unsigned long U32;

enum
{
    WMS_GW_ALPHABET_7_BIT_DEFAULT,
    WMS_GW_ALPHABET_8_BIT,
    WMS_GW_ALPHABET_UCS2,
    WMS_GW_ALPHABET_MAX32 = 0x10000000
};

#ifndef NULL
#define NULL 0
#endif

extern int GetEncodeType(const unsigned short *wszText);
extern int unichars2wchars(wchar_t* wstr, const U16 *unistr);
extern int wchars2unichars(U16 *unistr, const wchar_t* wstr);
extern U32 unistrlen(const U16 *ucs2_str);
extern U32 unistrcpy( U16 *dest_str, const U16 *ori_str);
extern U32 unistrncpy( U16 *dest_str, const U16 *ori_str, U32 nMaxLen);

extern int wstr2str(const U16 *wstr, char *str);
extern int str2wstr(const char *str, uint16 *wstr);
extern bool isUnicodeString(const U16 *unistr);
extern bool DivideNumber(const char *szNumber, string &strDial, string &strDTMF);
extern int ParseContactNameConvert(const wchar_t*in_str, int in_len);

extern bool wstrtoutf8(const wstring &wstr, string &utf8str);
extern bool utf8towstr(const string &utf8str, wstring &wstr);

#endif // CSTRINGUTILITY_H
