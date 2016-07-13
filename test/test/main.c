//
//  main.c
//  test
//
//  Created by 宛越 on 16/7/7.
//  Copyright © 2016年 yuewan. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>

typedef struct tagMp3
{
    char tag[4];
    char name[31];
    char singer[31];
    char special[31];
    char years[5];
    char remark[29];
    char hasTRK;
    char TRK;
    char style;
} MP3;


void ShowMP3Info(MP3 mp3)
{
    printf("歌曲的详细信息如下：\n");
    printf("标签        ：%s\n", mp3.tag);
    printf("歌曲名      ：%s\n", mp3.name);
    printf("歌手名      ：%s\n", mp3.singer);
    printf("专辑        ：%s\n", mp3.special);
    printf("年份        ：%s\n", mp3.years);
    printf("备注        ：%s\n", mp3.remark);
    if(0 == mp3.hasTRK)
    {
        printf("是否有音轨  ：有\n");
    }
    else
    {
        printf("是否有音轨  ：无\n");
    }
    printf("音轨        ：%d\n", mp3.TRK);
    printf("风格        ：%x\n", mp3.style);
}

int main(int argc, char const *argv[])
{
    /* code */
    printf("%s\n", "-----start-------");
    FILE *fp = fopen("/Users/wanyue/learn/test123/1234.mp3","r");
    if (NULL == fp)
    {
        printf("%s\n", "文件打开失败");
        return -1;
    }
    
    MP3 mp3;
    fseek(fp, -128L, SEEK_END);
    fgets(mp3.tag, 4, fp);
    
    fseek(fp, -125L, SEEK_END);
    fgets(mp3.name, 31, fp);
    
    fseek(fp, -95L, SEEK_END);
    fgets(mp3.singer, 31, fp);
    
    fseek(fp, -65L, SEEK_END);
    fgets(mp3.special, 31, fp);
    
    fseek(fp, -35L, SEEK_END);
    fgets(mp3.years, 5, fp);
    
    fseek(fp, -31L, SEEK_END);
    fgets(mp3.remark, 29, fp);
    
    // 读取是否音轨
    fseek(fp, -3L, SEEK_END);
    fgets(&(mp3.hasTRK), 2, fp);
    
    // 读取音轨
    fseek(fp, -2L, SEEK_END);
    fgets(&(mp3.TRK), 2, fp);
    
    // 读取风格
    fseek(fp, -1L, SEEK_END);
    fgets(&(mp3.style), 2, fp);
    
    fclose(fp); // 关闭mp3文件
    
    ShowMP3Info(mp3);
    
    return 0;
}
