//
//  udtp.h
//  UDTP-ObjcClient
//
//  Created by Kevin Trinh on 10/3/13.
//  Copyright (c) 2013 Kevin Trinh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import <pthread.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/time.h>
#import <semaphore.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <poll.h>


@interface udtp : NSObject{
    
    
    //Client properties
    bool m_bAlive;
    int m_iPrioritySocket;
    int m_iTransferSocket;
    struct sockaddr_in m_SDestinationAddr;
    NSMutableArray *rgFiles;
    NSMutableArray *rgThreads;
    NSThread *m_ProcessThread;
    NSLock *m_FileAccessLock;
    NSLock *m_ThreadAccessLock;
    
    //Structs
    struct m_SFile{
        FILE *m_File;
        char* m_chFileName;
        bool bComplete;
        
        unsigned int m_uiNumOfChunks;
        unsigned int m_uiFileSize;
        __unsafe_unretained NSMutableArray *m_rgFileProgress;
        
    };
    struct m_SThreadProperties{
        int m_iType;

        unsigned int m_uiID;
        __unsafe_unretained udtp *m_CAccess;
    };
}
-(bool) createNewFileName:(char*)chFileName NumOfChunks:(unsigned int)uiNumOfChunks FileSize:(unsigned int)uiFileSize;


-(bool) writeToFile:(FILE*)file Segment:(int)iSegment  Buffer:(char*)chBuffer;


-(UIImage*) convertToUIImageWithFile:(struct m_SFile*) SFile;


/* connectToServerWith: Port:
 Returns:
 0 - Successful
 1 - Could not start socket or connect
 2 - Could not start main thread
 */
-(int) connectToServerWithAddress:(char*)chAddress Port:(int)iPort;


-(bool) isFileDone:(struct m_SFile*)SFile;
-(double) checkFileProgress:(struct m_SFile*)SFile;
-(bool) close;

@end
