

--首先创建临时分区表,只要结构,不要数据
 create table temp_tt partition by range(time)
         (partition p1 values less
                than(to_date('2016/3/1', 'yyyy/mm/dd')), partition p2 values less
                than(to_date('2016/6/1', 'yyyy/mm/dd')), partition p3 values less
                than(to_date('2016/9/1', 'yyyy/mm/dd')), partition p4 values less
                than(to_date('2016/12/1', 'yyyy/mm/dd'))) as
          select * from tt where 1 = 2;
          
          
--1 首先检测是否可以重定义 TT 为原始表
   EXEC dbms_redefinition.can_redef_table('YU','TT',options_flag => dbms_redefinition.cons_use_rowid);
   
   
--2 开始重定义
    exec dbms_redefinition.start_redef_table('YU','TT','TEMP_TT',options_flag => dbms_redefinition.cons_use_rowid);
    
    
--3 把原始表的权限、约束、索引、物化视图log在临时表上创建一份  存储过程输入参数不指定,即使用默认的,但是输出参数必须指定,NUM_ERRORS 就是一个输出参数
  VAR V_ERR NUMBER;
 exec dbms_redefinition.copy_table_dependents(uname => 'YU', orig_table => 'TT',int_table => 'TEMP_TT',NUM_ERRORS => :V_ERR);
 
 
--4 同步数据 这一步不是必要的 ,因为做最后一步的时候,Oracle会自动同步数据，不过这样会加长表不可用的时间，所以还是我们单独做
   EXEC DBMS_REDEFINITION.SYNC_INTERIM_TABLE('YU', 'TT', 'TEMP_TT');
   
   
--5 完成在线重定义，在这一步中，要对原始表TT 以独占的方式锁定
    EXEC DBMS_REDEFINITION.finish_redef_table('YU', 'TT', 'TEMP_TT');
    

