#define LOG_4CC(x)	 NSLog(@"%s = %@", # x, FourCharCode2NSString(x))
#define LOG_FUNCTION()	NSLog(@"%s", __FUNCTION__)
#define LOG_ID(o)	 NSLog(@"%s = %@", # o, o)
#define LOG_INT(i)	 NSLog(@"%s = %d", # i, i)
#define LOG_INT64(ll) NSLog(@"%s = %lld", # ll, ll)
#define LOG_FLOAT(f)	NSLog(@"%s = %f", # f, f)
#define LOG_LONG_FLOAT(f) NSLog(@"%s = %Lf", # f, f)
#define LOG_OBJECT(o)	LOG_ID(o)
#define LOG_POINT(p)	NSLog(@"%s = %@", # p, NSStringFromPoint(p))
#define LOG_RECT(r)	 NSLog(@"%s = %@", # r, NSStringFromRect(r))
#define LOG_SIZE(s)	 NSLog(@"%s = %@", # s, NSStringFromSize(s))
#define LOG_NL	 NSLog(@" ")
#define LOG_TEST	 NSLog(@"I am here.")
#define LOG_BOOL(b)	 NSLog(@"%s = %@", # b, b ? @"YES" : @"NO")

#define kShowInMenuBarAsText 0
#define kShowInMenuBarAsIcon 1

#define kWarnAlertPercent 0
#define kWarnAlertMB 1
#define kWarnAlertGB 2

#define kSuffixMB 2
#define kSuffixGB 3

#define kWarnWhenTextField 1
#define kalertWhenTextField 2
#define kCheckDiskUseTextField 3