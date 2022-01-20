//
//  ACDConfig.h
//  AgoraChat
//
//  Created by liang on 2022/1/19.
//  Copyright © 2022 easemob. All rights reserved.
//

#ifndef ACDConfig_h
#define ACDConfig_h

#define ACDENV  3

#if ACDENV == 0
//美东
#define Appkey @"41117440#383391"
#define AppServerHost @"https://a41.easemob.com"

#elif ACDENV == 1
//easeim
#define Appkey @"easemob-demo#easeim"
#define AppServerHost @"https://a41.easemob.com"

#elif ACDENV == 2
//ebs
#define Appkey @"81446724#514456" //ebs
#define AppServerHost @"https://a1.easemob.com" //国内部署ebs

#elif ACDENV == 3
//vip6
#define Appkey @"86446724#514630" //vip6
#define AppServerHost @"https://a1-vip6.easemob.com" //国内部署vip6

#endif


//#define EaseIMAppKey @"easemob-demo#easeim"
//#define ChatDemoUIAppKey @"easemob-demo#chatdemoui"
//#define HongKongAppkey @"52366312#441909"
//#define MeidongAppkey @"41117440#383391"
//#define Appkey @"61308276#489779"
//#define Appkey1 @"61117440#460199"
//#define AppkeyIM @"81117440#512733" //国内
//#define AppkeyFanLanKeFu @"71117440#417715" //新法兰克福



#endif /* ACDConfig_h */
