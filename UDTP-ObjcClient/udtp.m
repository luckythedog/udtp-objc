//
//  udtp.m
//  UDTP-ObjcClient
//
//  Created by Kevin Trinh on 10/3/13.
//  Copyright (c) 2013 Kevin Trinh. All rights reserved.
//

#import "udtp.h"

@implementation udtp
-(id) init{
    if(self = [super init]){
        m_iTransferSocket = 0;
        m_iPrioritySocket = 0;
        m_bAlive = false;
    }
    return self;
}


void* processThread(udtp* args){
    udtp *CData = args;
    while(CData->m_bAlive){
        //Handle processes here open threads with factory setup
    }
    return NULL;
}
void* openThread(struct m_SThreadProperties* args){
    struct m_SThreadProperties *SThreadProperties = args;
    
    while(SThreadProperties->m_CAccess->m_bAlive){
        //Set up factories
    }
    return NULL;
    
}
-(bool) createNewFileName:(char*)chFileName NumOfChunks:(unsigned int)uiNumOfChunks FileSize:(unsigned int)uiFileSize{
    struct m_SFile SNewFile;
    
    FILE* new_file = NULL;
    new_file = fopen(chFileName, "w");
    
    SNewFile.m_File = new_file;
    SNewFile.m_chFileName = chFileName;
    SNewFile.m_uiNumOfChunks = uiNumOfChunks;
    SNewFile.m_uiFileSize = uiFileSize;
    SNewFile.bComplete = NO;
    NSMutableArray *rgFileProcess =[[NSMutableArray alloc] init];
         NSNumber* bStatus = [NSNumber numberWithBool:NO];
    for(int i=0;i<uiNumOfChunks;i++){
        [rgFileProcess addObject:bStatus];
    }
    SNewFile.m_rgFileProgress = rgFileProcess;
    
    
    
    NSValue *pNewFile = [NSValue valueWithPointer:&SNewFile];
    [m_FileAccessLock lock];
    [rgFiles addObject:pNewFile];
    [m_FileAccessLock unlock];
    return YES;
    
}
-(double) checkFileProgress:(struct m_SFile*)SFile{
    unsigned int iNumOfChunks = SFile->m_uiNumOfChunks;
    unsigned int iTotalComplete = 0;

    for(int i=0; i<[SFile->m_rgFileProgress count]; i++){
        if([SFile->m_rgFileProgress objectAtIndex:i]){
            iTotalComplete++;
        }
        
    }
    return (iTotalComplete/iNumOfChunks)*100;
    
    
}
-(bool) isFileDone:(struct m_SFile*)SFile{
    bool bComplete = YES;
    for(int i=0; i<[SFile->m_rgFileProgress count]; i++){
        if(![SFile->m_rgFileProgress objectAtIndex:i]){
            bComplete = false;
        }
        
    }
    SFile->bComplete = bComplete;
    return bComplete;
}

-(bool) writeToFile:(FILE*)file Segment:(int)iSegment  Buffer:(char*)chBuffer{
    return YES;
    
    
}
-(UIImage*) convertToUIImageWithFile:(struct m_SFile*) SFile{
    if(SFile->bComplete){
        FILE* ProcessFile = NULL;
        char chBuffer[SFile->m_uiFileSize];
        ProcessFile = fopen(SFile->m_chFileName,"r");
        if(ProcessFile != NULL){
            fgets(chBuffer, SFile->m_uiFileSize, ProcessFile);
        }
        
        NSData *FileData = [NSData dataWithBytes: chBuffer length:SFile->m_uiFileSize];
        UIImage *Image = [UIImage imageWithData:FileData];
        return Image;
    }

        
        
return NULL;

}

-(int) connectToServerWithAddress:(char*) chAddress Port:(int)iPort{
    
    //Create tcp backbone
    m_SDestinationAddr.sin_addr.s_addr = atoi(chAddress);
    m_SDestinationAddr.sin_family = AF_INET;
    m_SDestinationAddr.sin_port = htons(iPort);
    
    //Create TCP socket
    m_iPrioritySocket = socket(AF_INET,SOCK_STREAM,0);
    //Now create UDP Socket
    m_iTransferSocket = socket(AF_INET,SOCK_DGRAM,0);

    if(connect(m_iPrioritySocket, (struct sockaddr*)&m_SDestinationAddr, sizeof(m_SDestinationAddr))<0){
        return 1;
    }
    
    
    //Threading
    m_ProcessThread = [[NSThread alloc] initWithTarget:self selector:@selector(processThread:) object:self];
    [m_ProcessThread start];
    if(![m_ProcessThread isExecuting]){
        return 2;
    }
    rgThreads = [[NSMutableArray alloc] init];
    [rgThreads addObject:m_ProcessThread];
    
    
    
    //Initialize files in progress
    rgFiles = [[NSMutableArray alloc] init];
    
    
    //Initialize locks
    m_FileAccessLock = [[NSLock alloc] init];
    m_ThreadAccessLock = [[NSLock alloc] init];
    return 0;
    
}
-(bool) close{
    if(m_bAlive){
        //Stop all threads first
        [m_ThreadAccessLock lock];
        for(int i=0; i<[rgThreads count]; i++){
            if([[rgThreads objectAtIndex:i] isExecuting]){
            [[rgThreads objectAtIndex:i] stop];
            }
        }
        [m_ThreadAccessLock unlock];
        //Close all sockets
        close(m_iPrioritySocket);
        close(m_iTransferSocket);
    }
    return true;
}
@end
