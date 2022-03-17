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



#endif /* ACDConfig_h */
