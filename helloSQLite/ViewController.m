//
//  ViewController.m
//  helloSQLite
//
//  Created by zhu on 16/4/28.
//  Copyright © 2016年 zhu. All rights reserved.
//

/*---------------------------------------------------------------
= Blog about this article:http://www.jianshu.com/p/d02aae7bb66a =
----------------------------------------------------------------*/

#import "ViewController.h"
#import <sqlite3.h>
@interface ViewController ()
@property     sqlite3 *db;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //1,要学会生成文件并进入数据库
    //2,要学会生成数据库列表
    //3,要学会插入数据
    //4,要学会查数据
//    sqlite3          *db, 数据库句柄，跟文件句柄FILE很类似
//    sqlite3_stmt      *stmt, 这个相当于ODBC的Command对象，用于保存编译好的SQL语句
//    sqlite3_open(),   打开数据库，没有数据库时创建。
//    sqlite3_exec(),   执行非查询的sql语句
//    Sqlite3_step(), 在调用sqlite3_prepare后，使用这个函数在记录集中移动。
//    Sqlite3_close(), 关闭数据库文件
//    还有一系列的函数，用于从记录集字段中获取数据，如
//    sqlite3_column_text(), 取text类型的数据。
//    sqlite3_column_blob（），取blob类型的数据
//    sqlite3_column_int(), 取int类型的数据
   
    
    /*
     1......
     db是数据库的句柄,就是数据库的象征,要求对数据库进行增删改查,就要用这个实例
     */

    //文件目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucumentDirectory = [paths objectAtIndex:0];
    //创建文件
    //A stringByAppendingPathComponent B ....在a目录下生成B
    //A stringByAppendingString B  ...在同级A 目录下生成文件名为 AB 的文件
    NSString *path = [doucumentDirectory stringByAppendingPathComponent:@"student.sqlite"];
    NSFileManager *fileManager =[NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path];
    //
    const char *dbpath = [path UTF8String];
        if (sqlite3_open(dbpath,&_db)==SQLITE_OK) {
            NSLog(@"成功打开数据库");
            /*
             2......
             生成数据列表
             */
            //PRIMARY KEY AUTOINCREMENT z
//            id  你自己起的字段名字。
//            int  数据类型，整型。
//            primary key 定义这个字段为主键。
//            auto_increment 定义这个字段为自动增长，即如果INSERT时不赋值，则自动加1
            const char *sql = "create table if not exists iOS_students (student_id integer PRIMARY KEY AUTOINCREMENT,name text NOT NULL,age integer NOT NULL )";
            char *errmsg = NULL;
            
//            sqlite3_exec(//              参数：
//                        sqlite3*,                                  /* An open database */ 第一个是数据库的句柄，
//                        const char *sql,                           /* SQL to be evaluated */  第二个是sql语句，
//                        int (*callback)(void*,int,char**,char**),  /* Callback function */第三个sql的长度（如果设置为-1，则代表系统会自动计算sql语句的长度），
//                        void *,                                    /* 1st argument to callback */ 第四个参数用来取数据，
//                        char **errmsg                              /* Error msg written here */第五个参数为尾部一般用不上可直接写NULL。
//                         );

            
            int result = sqlite3_exec(_db, sql, NULL,NULL, &errmsg);
            if(result == SQLITE_OK){
                  NSLog(@"create ok.");
            }else{
                NSLog(@"创表失败----%s",errmsg);
            }
    
        }else{
            NSLog(@"打开数据库失败");
        }

[self setValueForDB];
[self toFinlTheDB];
}

//这里写个方法,  到时候你们可以用button来控制
-(void)setValueForDB{
    //排序人名 ,随机岁数                                             );
    for (int i = 0; i<15; i++) {
        NSString *name = [NSString stringWithFormat:@"拾壹---%d",i];
        int age = arc4random_uniform(15)+10;
        NSString *sql = [NSString stringWithFormat:@"insert into iOS_students (name,age)VALUES ('%@',%d);",name,age];
        char *errmsg = NULL;
        sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
        NSLog(@"%@",sql);;
        NSLog(@"%s",sql.UTF8String);;
        if (errmsg) {
            NSLog(@"%s----数据有误",errmsg);
        }
        NSLog(@"成功录入");
    }
    
}
-(void)toFinlTheDB{

     NSString *selectSql = @"SELECT * from iOS_students where age <18 ;";

    //    sqlite3_stmt是一个已经把sql语句解析了的、用sqlite自己标记记录的内部数据结构。其实我也是不怎么懂 哈哈哈.
     sqlite3_stmt *stmt = NULL;
    //    sqlite3_prepare_v2(
    //                        sqlite3 *db,            /* Database handle */数据库的句柄
    //                        const char *zSql,       /* SQL statement, UTF-8 encoded */sql语句格式为UTF-8
    //                        int nByte,              /* Maximum length of zSql in bytes. */sql的长度
    //                        sqlite3_stmt **ppStmt,  /* OUT: Statement handle */取数据
    //                        const char **pzTail     /* OUT: Pointer to unused portion of zSql */尾部一般用不上可直接写NULL
   if (sqlite3_prepare_v2(self.db,selectSql.UTF8String , -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        NSLog(@"搜索语句没有问题");
        
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            //收取数据
            
            //获取学号.在setm 的第几列 值
            int ID =sqlite3_column_int(stmt,0);
            //获取名字.在setm 的第几列 值
            char *name = (char *)sqlite3_column_text(stmt,1);
            //utf-8 转回类型
            NSString *nameStr = [[NSString alloc] initWithUTF8String:name];
            //获取年龄.在setm 的第几列 值
            int age = sqlite3_column_int(stmt,2);
            
            NSLog(@"名字:%@ 学号:%d 年龄:%d",nameStr,ID,age);
           
        }
    }else
//        if(SQLITE_OK != sqlite3_exec(_db, selectSql.UTF8String ,NULL, NULL,&error))
    {
        
            NSAssert1(0,@"Error:%s",sqlite3_errmsg(_db));
         NSLog(@"搜索语句有问题");
   }
     [self setdelete];
}
-(void)setdelete{
    sqlite3_stmt *stmt = nil;
    NSString *sqlStr = [NSString stringWithFormat:@"delete from iOS_students where student_id = 4" ];
    int result = sqlite3_prepare_v2(_db,[sqlStr UTF8String], -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {//觉的应加一个判断, 若有这一行则删除
            if (sqlite3_step(stmt) == SQLITE_DONE) {
                sqlite3_finalize(stmt);
            }
        }
    }
    sqlite3_finalize(stmt);
}


@end
