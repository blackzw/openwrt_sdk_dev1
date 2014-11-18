/*===========================================================================

          JRD LED CONTROLLER

DESCRIPTION

  This file implements led control.


                     EDIT HISTORY FOR FILE

when         who    what, where, why
----------   ---    ---------------------------------------------------------
2014-03-26   hzk    Init first version

===========================================================================*/
#ifndef JRD_LED_H
#define JRD_LED_H


#include <dlfcn.h>
#include <unistd.h>

#ifndef TRUE
#define TRUE (1)
#endif
#ifndef FALSE
#define FALSE (0)
#endif

#ifndef NULL
#define NULL ((void *) 0)
#endif

#if defined(__linux__) && defined(__KERNEL__)
#include <linux/types.h>
typedef u_int8_t           BOOLEAN;
typedef int8_t			    int8;
typedef u_int8_t            uInt8;
typedef uInt8				uChar;
typedef int16_t  			int16;
typedef u_int16_t           uInt16;
typedef int32_t             int32;
typedef u_int32_t   		uInt32;
#elif defined(WIN32)
#include <wtypes.h>
typedef char				int8;
typedef unsigned char		uInt8;
typedef uInt8				uChar;
typedef short int			int16;
typedef unsigned short int	uInt16;
typedef long				int32;
typedef unsigned long		uInt32;
#else
#include <stdint.h>
typedef uint8_t           BOOLEAN;
typedef int8_t			    int8;
typedef uint8_t            uInt8;
typedef uint8_t				uChar;
typedef int16_t  			int16;
typedef uint16_t           uInt16;
typedef int32_t             int32;
typedef uint32_t   		uInt32;
#endif


enum{
EXT_ANTENNA = 0,
INT_ANTENNA = 1,
ERR_ANTENNA
};


#ifdef __cplusplus
extern "C"
{
#endif

int network_led_controller(BOOLEAN connected,int mode);
int rssi_led_controller(int rssi);
int sms_led_controller(BOOLEAN new_sms);
int sms_storage_full_led_controller(BOOLEAN sms_storage_full);

int fota_upgrade_led_blink(void);

#ifdef __cplusplus
}
#endif




#endif
