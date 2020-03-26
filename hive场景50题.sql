=============================================
1.表scores的数据如下
| id | score |
| 1 | 3.50 |
| 2 | 3.65 |
| 3 | 4.00 |
| 4 | 3.85 |
| 5 | 4.00 |
| 6 | 3.65 |
下面是一个排名查询，根据如下排名结果，写出查询语句（按分数从高到低排列）：
| score | rank |
| 4.00 | 1 |
| 4.00 | 1 |
| 3.85 | 2 |
| 3.65 | 3 |
| 3.65 | 3 |
| 3.50 | 4 |

select
score,
dense_rank() over(cluster by score) rn
from score;
=====================================================

2. 给定一个表tree,id是树节点的编号,p_id 是它父节点的id。
| id | p_id |
| 1  | null |
| 2  | 1 |
| 3  | 1 |
| 4  | 2 |
| 5  | 2 |
create table tree(
id int,
p_id int
)
row format delimited
fields terminated by ','
;


树中每个节点属于以下三种类型之一：
叶子：如果这个节点没有任何孩子节点。
根：如果这个节点是整棵树的根，即没有父节点。
内部节点：如果这个节点既不是叶子节点也不是根节点。
写一个查询语句，输出所有节点的编号和节点的类型，并将结果按照节点编号排序。上面样例的结果为：
| id | Type |
| 1 | Root |
| 2 | Inner|
| 3 | Leaf |
| 4 | Leaf |
| 5 | Leaf |

解析：
select A.*,B.* from tree  A left join tree B on A.id = B.p_id; 
A.id    A.p_id  B.id  B.p_id
1       NULL    2       1
1       NULL    3       1
2       1       4       2
2       1       5       2
3       1       NULL    NULL
4       2       NULL    NULL
5       2       NULL    NULL

答案1：
select distinct A.id,
case when A.p_id is null then 'Root' 
when A.id=B.p_id then 'inner' 
else 'leaf' end type 
from tree A left join tree B 
on A.id= B.p_id;

答案2：
select distinct A.id,case 
when A.p_id is null then 'Root' 
when B.p_id is null then 'leaf' 
else 'inner' end type 
from tree A left join tree B 
on A.id= B.p_id;



解释
节点 '1' 是根节点，因为它的父节点是 NULL ，同时它有孩子节点 '2' 和 '3' 。
节点 '2' 是内部节点，因为它有父节点 '1' ，也有孩子节点 '4' 和 '5' 。
节点 '3', '4' 和 '5' 都是叶子节点，因为它们都有父节点同时没有孩子节点。
样例中树的形态如下：
   1
  / \
  2  3
 / \
 4 5
 ==================================================
6、有如下数据:表名:hero_pk
id    names
1       aa,bb,cc,dd,ee
2       aa,bb,ff,ww,qq
3       aa,cc,rr,yy
4       aa,bb,dd,oo,pp
求英雄的出场排名top3的出场次数及出场率

select C.name,C.num,concat(C.num/D.total*100,"%")
from(
select B.name,B.num,dense_rank() over(order by B.num desc) rk
from(
select A.name,count(A.name) num
from(
select id,name from hero_pk lateral view explode(names) mytable as name
) A group by A.name
)B
) C 
join (select count(*) total from hero_pk) D where C.rk<4 ;

=================================================================
3. 在 facebook 中，表follow会有2个字段followee, follower分别表示被关注者和关注者。
请写一个sql查询语句，对每一个关注者，查询他的关注者数目。
比方说：
| followee | follower |
| A | B |
| B | C |
| B | D |
| D | E |
应该输出：
| follower | num |
| B | 2 |
| D | 1 |
解释：
B 和 D 都在在 follower字段中出现，作为被关注者，B被C和D关注，D被E关注。A不在follower字段内，所以A不在输出列表中。
注意：被关注者永远不会被他 / 她自己关注。将结果按照字典顺序返回。

create table facebook(
followee string,
follower string
)
row format delimited
fields terminated by ','
;
load data local inpath './data/follow.txt' into table facebook;

答案1：
select A.followee,count(*) from facebook A join facebook B on A.followee = B.follower group by A.followee;
答案2：
select A.followee,count(*) from facebook A left semi join facebook B on A.followee = B.follower group by A.followee;
答案3：
select A.followee,count(*) from facebook A where exists (select 1 from facebook B where A.followee = B.follower) group by A.followee;










=====================================
25.每个用户连续登陆的最大天数
create table 25t(
uid int,
`date` string
)
row format delimited fields terminated by ','; 

load data inpath '/opt/apps/testdata/25t.txt' into table 25t;

数据: 
login表 
uid,date 
1,2019-08-01
1,2019-08-02
1,2019-08-03
2,2019-08-01
2,2019-08-02
3,2019-08-01
3,2019-08-03
4,2019-07-28
4,2019-07-29
4,2019-08-01
4,2019-08-02
4,2019-08-03

结果如下： 
uid cnt_days 
1 3
2 2
3 1
4 3

==================================================================
 empno:员工编号  ename:员工姓名  job:工种  mgp:领导编号  hiredate:入职时间
		 sal:工资  comm:奖金  deptno :部门号
deptno:部门编号  dname:部门名称  loc:部门地址

6.查询工资高于本部门平均工资的员工的信息及其部门的平均工资。【3分】
select
deptno,
avg(sal) avg
from emp
group by deptno; t1

select
a.*,
t1.avg
from emp a join (select
deptno,
avg(sal) avg
from emp
group by deptno)t1
on a.deptno = t1.deptno
where a.sal > t1.avg



7.查询各个部门的人数及平均工资。【3分】
select
deptno,
count(ename),
avg(sal)
from emp
group by deptno



8.查询各个部门的详细信息以及部门人数、部门平均工资。【3分】
select
deptno,
count(ename) count,
round(avg(sal),2) avgsal
from emp
group by deptno; t1

select
a.*,
t1.count,
t1.avgsal
from dept a join (select
deptno,
count(ename) count,
round(avg(sal),2) avgsal
from emp
group by deptno)t1
on a.deptno = t1.deptno





5.统计每个部门中各工种的人数与平均工资【3分】
select
empno,
job,
count(ename)
from emp
group by empno, job



4.查询所有员工工资都大于1000的部门的信息及其员工信息。【3分】
select
distinct deptno
from emp
where sal < 1000; t1

select





3.查询每个员工的领导所在部门的信息。【3分】
select
a.*,
b.deptno,
c.*
from emp a join emp b
on a.mgp = b.empno
join dept c
on b.deptno = c.deptno


1.查询入职日期早于其直接上级领导的所有员工信息。【3分】

    spark.sql(
      """
        |select
        |a.*
        |from emp a join emp b
        |on a.mgp = b.empno
        |where a.hiredate > b.hiredate
      """.stripMargin).rdd.repartition(1).saveAsTextFile("output1")*/

2.查询平均工资低于2000的部门及其员工信息【3分】
	spark.sql(
      """
        |select * from emp join
        |(select
        |deptno
        |from emp
        |group by deptno
        |having avg(sal) < 3000) t1
        |on emp.deptno = t1.deptno
      """.stripMargin).rdd.repartition(1).saveAsTextFile("output2")*/

=================================================================
10,财务部,北京
20,研发部,上海
30,销售部,广州
40,行政部,深圳

7369,刘一,职员,7902,1980-12-17,800,0,20
7499,陈二,推销员,7698,1981-02-20,1600,300,30
7521,张三,推销员,7698,1981-02-22,1250,500,30
7566,李四,经理,7839,1981-04-02,2975,0,20
7654,王五,推销员,7698,1981-09-28,1250,1400,30
7698,赵六,经理,7839,1981-05-01,2850,0,30
7782,孙七,经理,7839,1981-06-09,2450,0,10
7788,周八,分析师,7566,1987-06-13,3000,0,20
7839,吴九,总裁,null,1981-11-17,5000,0,10
7844,郑十,推销员,7698,1981-09-08,1500,0,30
7876,郭十一,职员,7788,1987-06-13,1100,0,20
7900,钱多多,职员,7698,1981-12-03,950,0,30
7902,大锦鲤,分析师,7566,1981-12-03,3000,0,20
7934,木有钱,职员,7782,1983-01-23,1300,0,10

create table dept(
deptno string,
dname string,
loc string
)
row format delimited fields terminated by ','
;
load data local inpath '/opt/apps/data/dept.txt' into table dept;

create table emp(
empno string, 
ename string, 
job string, 
mgr string, 
hiredate string, 
sal string, 
comm string, 
deptno string
)
row format delimited fields terminated by ','
;
load data local inpath '/opt/apps/data/emp.txt' into table emp;


列出至少有一个员工的所有部门。
select
distinct a.deptno,
b.dname 
from emp a join dept b
on a.deptno == b.deptno
;

列出薪金比"刘一"多的所有员工。
select
sal
from emp 
where ename = "刘一"; t1

select
emp.ename,
emp.sal
from emp join (select
sal
from emp 
where ename = "刘一")t1
on(true)
where emp.sal - t1.sal > 0;

列出所有员工的姓名及其直接上级的姓名。
select
a.ename,
b.empno,
b.ename
from emp a join emp b
on a.mgr = b.empno;

列出受雇日期早于其直接上级的所有员工。
select
a.ename,
a.hiredate,
b.ename,
b.hiredate
from emp a join emp b
on a.mgr = b.empno
where a.hiredate > b.hiredate;

列出部门名称和这些部门的员工信息，同时列出那些没有员工的部门。
select
a.dname,
b.ename
from dept a left join emp b
on a.deptno = b.deptno;

列出所有job为“职员”的姓名及其部门名称。
select
a.ename,
b.dname
from emp a join dept b
on a.deptno = b.deptno
where a.job = '职员';

列出最低薪金大于1500的各种工作。
select
distinct job
from emp 
where sal > 1500;

列出在部门 "销售部" 工作的员工的姓名，假定不知道销售部的部门编号。
select
a.ename,
b.dname,
b.deptno
from emp a left join dept b
on a.deptno = b.deptno
where b.dname = "销售部";


列出薪金高于公司平均薪金的所有员工。
select
avg(sal) avgsal
from emp; t1

select
ename,
sal
from emp join (select
avg(sal) avgsal
from emp)t1
where emp.sal > t1.avgsal;

列出在每个部门工作的员工数量、平均工资。
select
count(empno),
avg(sal)
from emp
group by deptno;


列出所有员工的姓名、部门名称和工资。
select
a.dname,
b.ename,
b.sal
from dept a join emp b
on a.deptno = b.deptno;


查出emp表中所有部门的最高薪水和最低薪水，部门编号为10的部门不显示。
select
deptno,
max(sal),
min(sal)
from emp
where deptno != 10
group by deptno;

删除10号部门薪水最高的员工。
select
max(sal) maxsal
from emp
where deptno = 10; t1

select
ename
from emp join (select
max(sal) maxsal
from emp
where deptno = 10)t1
on emp.sal = t1.maxsal;

===========================================================
userId	visitDate	visitCount
u01	2017/1/21	5
u02	2017/1/23	6
u03	2017/1/22	8
u04	2017/1/20	3
u01	2017/1/23	6
u01	2017/2/21	8
u02	2017/1/23	6
u01	2017/2/22	4

要求使用SQL统计出每个用户的累积访问次数，如下表所示：
用户id	月份	小计	累积
u01	2017-01	11	11
u01	2017-02	12	23
u02	2017-01	12	12
u03	2017-01	8	8
u04	2017-01	3	3

create table visit(
userId string,
visitDate string,
visitCount int
)
row format delimited fields terminated by '\t';
load data local inpath '/root/testdata/visit.txt' into table visit;

select 
regexp_replace(visitDate, '/', '-')
from visit;

2017-1-21
2017-1-23

select
userId,
date_format(regexp_replace(visitDate, '/', '-'), 'yyyy-MM') formatTime,
visitCount
from visit; t1

u01     2017-01 5
u02     2017-01 6

select
userId,
formatTime,
sum(visitCount) sumCount
from (select
userId,
date_format(regexp_replace(visitDate, '/', '-'), 'yyyy-MM') formatTime,
visitCount
from visit)t1
group by userId, formatTime; t2

u01     2017-01 11
u01     2017-02 12

select 
userId,
formatTime,
sumCount,
sum(sumCount) over(distribute by userId sort by formatTime) 
from (select
userId,
formatTime,
sum(visitCount) sumCount
from (select
userId,
date_format(regexp_replace(visitDate, '/', '-'), 'yyyy-MM') formatTime,
visitCount
from visit)t1
group by userId, formatTime)t2;
====================================================
jingdong.user_id        jingdong.shop
u1      a
u2      b
u1      b
u1      a
u3      c
u4      b
u1      a
u2      c
u5      b
u4      b
u6      c
u2      c
u1      b
u2      a
u2      a
u3      a
u5      a
u5      a
u5      a

create table jingdong(
user_id string,
shop string
)
row format delimited fields terminated by '\t';

load data local inpath '/root/testdata/jingdong.txt' into table jingdong;


每个店铺的UV（访客数）
1.去重
select
shop,
user_id
from
jingdong
group by shop, user_id; t1

select
shop,
count(user_id) count
from (select
shop,
user_id
from
jingdong
group by shop, user_id)t1
group by shop;

2）每个店铺访问次数top3的访客信息。输出店铺名称、访客id、访问次数
select
shop,
user_id,
count(*) cnt
from jingdong
group by shop, user_id; t1

shop    user_id cnt
a       u1      3
a       u2      2
a       u3      1
a       u5      3
b       u1      2
b       u2      1
b       u4      2
b       u5      1
c       u2      2
c       u3      1
c       u6      1

select
shop,
user_id,
cnt,
row_number() over(distribute by shop sort by cnt desc) rank
from (select
shop,
user_id,
count(*) cnt
from jingdong
group by shop, user_id)t1; t2


select
shop,
user_id,
cnt
from (select
shop,
user_id,
cnt,
row_number() over(distribute by shop sort by cnt desc) rank
from (select
shop,
user_id,
count(*) cnt
from jingdong
group by shop, user_id)t1)t2
where rank < 4;

================================================
1、用户表操作如下：
log_action:
uid	time	action
1	2019-09-07 12:22:23	read
1	2019-09-07 12:23:23	write
1	2019-09-07 12:26:23	like
1	2019-09-07 12:20:23	share
3	2019-09-07 12:28:23	like
3	2019-09-07 12:29:00	read
3	2019-09-07 12:32:33	comment
4	2019-09-07 12:22:23	read
4	2019-09-07 12:16:18	like
使用hql语句，找到每一个用户在表中的最后一次行为?

select
uid,
time,
action,
row_number() over(distribute by uid sort by time desc) rank
from log_action; t1

select
uid,
action
from (select
uid,
time,
action,
row_number() over(distribute by uid sort by time desc) rank
from log_action)t1
where rank = 1;

========================================================
2、words表：
uid	contents
i love china china china china is good and i i like love

使用hql语句实现词频的top3统计
word	cnt
china 	4
i		3
love	2

create table words(
data array<string>
)
row format delimited 
fields terminated by '\t'
collection items terminated by ' '
;

load data local inpath '/root/testdata/words.txt' into table words;

select
explode(data) 
from words; t1

select
exWord,
count(*) cnt
from words lateral view explode(data) t1 as exWord
group by exWord
order by cnt desc
limit 3
;
=============================================
编写sql实现每个用户截止到每月为止的最大单月访问次数和累计到该月的总访问次数
userid,month,visits 
A,2015-01,5
A,2015-01,15
B,2015-01,5
A,2015-01,8
B,2015-01,25
A,2015-01,5
A,2015-02,4
A,2015-02,6
B,2015-02,10
B,2015-02,5
A,2015-03,16
A,2015-03,22
B,2015-03,23
B,2015-03,10
B,2015-03,1

load data local inpath '/root/testdata/visitmaxcount.txt' into table visitmaxcount;

select
userid,
month,
max(visits) maxvisit,
sum(visits) sumvisit
from visitmaxcount
group by userid, month;

select
userid,
month,
maxvisit,
sumvisit,
sum(sumvisit) over(distribute by userid sort by month) totalvisit
from (select
userid,
month,
max(visits) maxvisit,
sum(visits) sumvisit
from visitmaxcount
group by userid, month)t1;
============================================================================
原表
A P1
B P1
A P2
B P3
使用hql将原表变成如下
用户 P1 P2 P3 
A   1   1  0 
B   1   0  1
create table shop(
user_id string,
product string
)
row format delimited fields terminated by ' ';

load data local inpath '/root/testdata/39.txt' into table shop;

select
user_id,
sum(if(product='P1', 1, 0)) P1,
sum(if(product='P2', 1, 0)) P2,
sum(if(product='P3', 1, 0)) P3
from shop
group by user_id;

=========================================================
load data local inpath '/root/testdata/video.txt' into table video;
求出每个栏目的被观看次数及累计观看时长？
uid channl time 
1 1 23
2 1 12
3 1 12
4 1 32
5 1 342
6 2 13
7 2 34
8 2 13
9 2 134

create table video(
uid int,
channl int,
time int
)
row format delimited fields terminated by ' ';

select
channl,
count(uid) cnt,
sum(time) time
from video
group by channl;

======================================================================
4.编写连续7天登录的总人数

create table 04t(
uid int,
time string,
status int
)
row format delimited fields terminated by ' ';

load data local inpath '/opt/apps/testdata/04t.txt' into table 04t.txt;

uid dt    status(1登录成功,0异常) 
1 2019-07-11 1
1 2019-07-12 1
1 2019-07-13 1
1 2019-07-14 1
1 2019-07-15 1
1 2019-07-16 1
1 2019-07-17 1
1 2019-07-18 1
2 2019-07-11 1
2 2019-07-12 1
2 2019-07-13 0
2 2019-07-14 1
2 2019-07-15 1
2 2019-07-16 0
2 2019-07-17 1
2 2019-07-18 0
3 2019-07-11 1
3 2019-07-12 1
3 2019-07-13 1
3 2019-07-14 1
3 2019-07-15 1
3 2019-07-16 1
3 2019-07-17 1
3 2019-07-18 1

select
uid,
status,
datediff(time, lag(time,6) over(distribute by uid sort by time asc)) dt
from 04t
where status = 1; t1

select
count(distinct uid)
from (select
uid,
status,
datediff(time, lag(time,6) over(distribute by uid sort by time asc)) dt
from 04t
where status = 1)t1
where dt = 6;


----1
select 
uid,
status,
datediff(time,lag(time,6) over(distribute by uid sort by time asc)) dt
from login
where status=1; t1

select 
count(distinct t1.uid)
from (select 
uid,
status,
datediff(time,lag(time,6) over(distribute by uid sort by time asc)) dt
from login
where status=1)t1
where t1.dt = 6;

----2
select
uid,
time,
row_number() over(distribute by uid sort by time) daterank
from login
where status=1; t1

select
uid,
date_sub(time, daterank) newdt
from (select
uid,
time,
row_number() over(distribute by uid sort by time) daterank
from login
where status=1)t1; t2

select
uid
from (select
uid,
date_sub(time, daterank) newdt
from (select
uid,
time,
row_number() over(distribute by uid sort by time) daterank
from login
where status=1)t1)t2
group by uid
having count(newdt) >= 7; t3

select
count(t3.uid)
from (select
uid
from (select
uid,
date_sub(time, daterank) newdt
from (select
uid,
time,
row_number() over(distribute by uid sort by time) daterank
from login
where status=1)t1)t2
group by uid
having count(newdt) >= 7)t3;
=======================================================
6.实现每班前三名，分数一样并列，同时求出前三名 按名次排序计算与其前一名的分差
Stu_no class score 
1 1901 90
2 1901 90
3 1901 83
4 1901 60
5 1902 66
6 1902 23
7 1902 99
8 1902 67
9 1902 87

create table 6t(
stu_no int,
class string,
score int
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/testdata/6.txt' into table 6t;

select
class,
stu_no,
score,
row_number() over(distribute by class sort by score desc) rn,
rank() over(distribute by class sort by score desc) rn1
from 6t; t1

select
class,
stu_no,
score,
rn,
rn1,
score - nvl(lag(score) over(distribute by class sort by rn), 0) rn_diff
from (select
class,
stu_no,
score,
row_number() over(distribute by class sort by score desc) rn,
rank() over(distribute by class sort by score desc) rn1
from 6t)t1
where rn < 4;
===========================================================
8.
create table 8t(
id int,
userid string,
subject string,
score double
)
row format delimited fields terminated by ' ';

load data local inpath '/opt/apps/testdata/8t.txt' into table 8t;

1 001 语文 90
2 001 数学 92
3 001 英语 80
4 002 语文 88
5 002 数学 90
6 002 英语 75.5
7 003 语文 70
8 003 数学 85
9 003 英语 90
10 003 政治 82

--1
select
userid,
sum(if(subject='语文', score, 0)) chinese,
sum(if(subject='数学', score, 0)) math,
sum(if(subject='英语', score, 0)) english,
sum(if(subject='政治', score, 0)) zhengzhi,
sum(score) total
from 8t
group by userid

union

select
'total'
,sum(chinese)
,sum(math)
,sum(english)
,sum(zhengzhi)
,sum(total)
from (select
userid,
sum(if(subject='语文', score, 0)) chinese,
sum(if(subject='数学', score, 0)) math,
sum(if(subject='英语', score, 0)) english,
sum(if(subject='政治', score, 0)) zhengzhi,
sum(score) total
from 8t
group by userid)t1;
==================================================
9.uid tags 
1 1,2,3
2 2,3
3 1,2

转换为
uid tag 
1 1 
1 2 
1 3 
2 2 
2 3 
3 1 
3 2

create table 9t(
uid int,
tags array<int>
)
row format delimited fields terminated by ' '
collection items terminated by ',';
load data local inpath '/opt/apps/testdata/9t.txt' into table 9t;

select
uid,
tag
from 9t lateral view explode(tags) t1 as tag;

如果lags是string类型
select
uid,
tag
from 9t 
lateral view explode(split(tags, ',')) t1 as tag;
========================================================
10.行转列
数据： 
T1表: 
Tags 
1,2,3 
1,2 
2,3 

T2表: 
Id lab 
1 A 
2 B 
3 C

create table 10t1(
tags string
)
row format delimited fields terminated by '\t';

create table 10t2(
id int,
lab string
)
row format delimited fields terminated by ' ';

load data local inpath '/opt/apps/testdata/10t1.txt' into table 10t1;

select
tags,
tag
from 10t1
lateral view explode(split(tags, ',')) t1 as tag; t2

select
tags,
tag,
10t2.lab lab
from
(select
tags,
tag
from 10t1
lateral view explode(split(tags, ',')) t1 as tag)t2 join 10t2
on t2.tag = 10t2.id; t3

select
tags,
concat_ws(',',collect_set(lab)) lab
from (select
tags,
tag,
10t2.lab lab
from
(select
tags,
tag
from 10t1
lateral view explode(split(tags, ',')) t1 as tag)t2 join 10t2
on t2.tag = 10t2.id)t3
group by tags;
=====================================================
11.行转列
id tag flag
a b 2
a b 1
a b 3
c d 6
c d 8
c d 8

id tag flag 
a b 1|2|3 
c d 6|8

create table 11t(
id string,
tag string,
flag string
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/testdata/11t.txt' into table 11t;

select
id,
tag,
concat_ws('|', collect_set(flag)) flag
from 11t
group by id,tag;
=======================================
12.
uid name tags
1 goudan chihuo,huaci
2 mazi sleep
3 laotie paly

编写sql实现如下结果： 
uid name tag 
1 goudan chihuo 
1 goudan huaci 
2 mazi sleep 
3 laotie paly

create table 12t(
uid string,
name string,
tags string
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/testdata/12t.txt' into table 12t;

select
uid,
name,
tag
from 12t
lateral view explode(split(tags, ",")) t1 as tag;
======================================================
13.行转列
uid contents
1 i|love|china
2 china|is|good|i|i|like

content cnt 
i 3
china 2 
good 1 
like 1 
love 1 
is 1

create table 13t(
uid int,
contents string
)
row format delimited fields terminated by ' ';

load data local inpath '/opt/apps/testdata/13t.txt' into table 13t;

select
uid,
content
from 13t
lateral view explode(split(contents, "\\|") t1 as content; t1

=========================================================
14.列转行
id course 
1,a
1,b
1,c
1,e
2,a
2,c
2,d
2,f
3,a
3,b
3,c
3,e

id a b c d e f 
1 1 1 1 0 1 0 
2 1 0 1 1 0 1 
3 1 1 1 0 1 0

create table 14t(
id int,
course string
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/testdata/14t.txt' into table 14t;

select
id,
sum(if(course='a', 1, 0)) a,
sum(if(course='b', 1, 0)) b,
sum(if(course='c', 1, 0)) c,
sum(if(course='d', 1, 0)) d,
sum(if(course='e', 1, 0)) e,
sum(if(course='f', 1, 0)) f
from 14t
group by id;

========================================
15.
获取"2019-07-31 11:57:25"对应的时间戳:
select unix_timestamp("2019-07-31 11:57:25", 'yyyy-MM-dd HH:mm:ss');

获取"2019-07-31 11:57"对应的时间戳：
select unix_timestamp("2019-07-31 11:57", 'yyyy-MM-dd HH:mm');

获取时间戳:1564545445所对应的日期和时分秒：   2019-07-31 11:57
select from_unixtime(1564545445, 'yyyy-MM-dd HH:mm');

获取时间戳:1564545446所对应的日期和小时(yyyy/MM/dd HH):
select from_unixtime(1564545445, 'yyyy/MM/dd HH');

=================================================
16.时间格式转换
数据: t1表 
20190730 
20190731 
编写sql实现如下的结果：
2019-07-30 
2019-07-31

select
from_unixtime(unix_timestamp('20190730', 'yyyyMMdd'), 'yyyy-MM-dd');
==============================================================
17.编写Hive的HQL语句求出每个店铺的当月销售额和累计到当月的总销售额?
a,01,150
a,01,200
b,01,1000
b,01,800
c,01,250
c,01,220
b,01,6000
a,02,2000
a,02,3000
b,02,1000
b,02,1500
c,02,350
c,02,280
a,03,350
a,03,250

create table 17t(
shop string,
month string,
money string
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/testdata/17t.txt' into table 17t;

select
shop,
month,
sum(money) summoney
from 17t
group by shop, month; t1

select
shop,
month,
summoney,
sum(summoney) over(distribute by shop sort by month) totalmoney
from (select
shop,
month,
sum(money) summoney
from 17t
group by shop, month)t1;
=====================================
20.求每个用户的最大连续登陆天数
log_time uid
2018-10-01 12:34:11	123
2018-10-02 13:21:08	456
2018-10-02 14:08:09	123
2018-10-04 05:10:22	456
2018-10-04 21:38:38	123
2018-10-05 09:57:32	123
2018-10-06 13:22:56	123

create table 20t(
log_time string,
uid string
)
row format delimited fields terminated by '\t';
load data local inpath '/opt/apps/testdata/20t.txt' into table 20t;

1.先将日期截止天提取出来，便于比较
2.利用row_number将日期进行排序 rn
3.利用date_sub(dt, rn) 相减，正好连续的天减完后日期一致
4.利用count（*）统计相同个数
5.利用max（cnt）取出最大的数

select 
uid, 
substring(log_time, 1, 10) login_time 
from 20t
group by uid, log_time; t1

select
uid,
date_sub(login_time, row_number() over(distribute by uid sort by login_time)) dt
from (select 
uid, 
substring(log_time, 1, 10) login_time 
from 20t
group by uid, log_time)t1; t2

select
uid,
count(*) cnt
from (select
uid,
date_sub(login_time, row_number() over(distribute by uid sort by login_time)) dt
from (select 
uid, 
substring(log_time, 1, 10) login_time 
from 20t
group by uid, log_time)t1)t2
group by uid, dt; t3

select
uid,
max(cnt) max
from (select
uid,
count(*) cnt
from (select
uid,
date_sub(login_time, row_number() over(distribute by uid sort by login_time)) dt
from (select 
uid, 
substring(log_time, 1, 10) login_time 
from 20t
group by uid, log_time)t1)t2
group by uid, dt)t3
group by uid;
=============================================================、
22.求出两个数据集的差集
t1表
id name 
1 zs
2 ls

t2表： 
id name 
1 zs
3 ww

结果如下： 
id name 
2 ls 
3 ww

create table 22t1(
id int,
name string
)
row format delimited fields terminated by ' ';

create table 22t2(
id int,
name string
)
row format delimited fields terminated by ' ';

load data local inpath '/opt/apps/testdata/22t1.txt' into table 22t1;
load data local inpath '/opt/apps/testdata/22t2.txt' into table 22t2;

select
id,
name
from 22t1
union all
select
id,
name
from 22t2; t1

select
id,
name
from (select
id,
name
from 22t1
union all
select
id,
name
from 22t2)t1
group by id,name
having count(name) =1;

=====================================
23.统计今天和昨天都购买过商品3的用户及昨日消费
orderId,userId,productId,price,stamp,dt
123,"dasfdasas",3,200,1535945356,"2018-08-08"
124,"dasfdass",1,200,1535945356,"2018-08-08"
125,"dadassfas",3,200,1535945356,"2018-08-09"
126,"dadassfas",2,200,1535945356,"2018-08-09"
123,"dasfdasas",5,200,1535945356,"2018-08-09"
create table 23t(
orderId int,
userId string,
productId int,
price int,
stamp bigint,
dt string
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/testdata/23t.txt' into table 23t;

===============================
使用hql语句，找到每一个用户在表中的最后一次行为?

1	2019-09-07 12:22:23	read
1	2019-09-07 12:23:23	write
1	2019-09-07 12:26:23	like
1	2019-09-07 12:20:23	share
3	2019-09-07 12:28:23	like
3	2019-09-07 12:29:00	read
3	2019-09-07 12:32:33	comment
4	2019-09-07 12:22:23	read
4	2019-09-07 12:16:18	like
uid	time	action

create table hive1(
uid int,
time string,
action string
)
row format delimited fields terminated by '\t';
load data local inpath '/opt/apps/testdata/hive1.txt' into table hive1;

select
uid,
max(unix_timestamp(time)) maxtime,
max(action) action
from hive1
group by uid; t1

select
uid,
action
from (select
uid,
max(unix_timestamp(time)) maxtime,
max(action) action
from hive1
group by uid)t1;

==========================================================
create table favor(
id int,
name string,
age int,
favor string
)
row format delimited fields terminated by '\t';

load data local inpath '/opt/apps/data/favor.txt' into table favor;

Id	Name	Age	Favor
1	Huangbo	33	A,B,C,D,E
2	Xuzheng	44	B,C
3	Wangbaoqiang	55	C,D,E
4	Fanbingbing	32	A,B,D

求出每种爱好中年龄最大的人，如果有相同的年龄，请并列显示

select
id,
name,
age,
fav
from favor lateral view explode(split(favor, ',')) t1 as fav; t2

select
max(name),
max(age),
fav
from (select
id,
name,
age,
fav
from favor lateral view explode(split(favor, ',')) t1 as fav)t2 
group by fav; 

====================================================
create table hero(
id int,
names string
)
row format delimited fields terminated by '\t';

load data local inpath '/opt/apps/data/hero.txt' into table hero;

id		names
1	aa,bb,cc,dd,ee
2	aa,bb,ff,ww,qq
3	aa,cc,rr,yy
4	aa,bb,dd,oo,pp
求英雄的出场排名top3的出场次数及出场率

select
id,
name
from hero lateral view explode(split(names, ',')) t1 as name; t2

select
name,
count(name) count
from (select
id,
name
from hero lateral view explode(split(names, ',')) t1 as name)t2 
group by name; t3

select
max(name),
max(count),
sum(count)/count(1) chuchang
from (select
name,
count(name) count
from (select
id,
name
from hero lateral view explode(split(names, ',')) t1 as name)t2 
group by name)t3;

==========================================================
create table business(
name string, 
orderdate string,
cost int
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';

load data local inpath "/opt/apps/data/business.txt" into table business;

jack,2017-01-01,10
tony,2017-01-02,15
jack,2017-02-03,23
tony,2017-01-04,29
jack,2017-01-05,46
jack,2017-04-06,42
tony,2017-01-07,50
jack,2017-01-08,55
mart,2017-04-08,62
mart,2017-04-09,68
neil,2017-05-10,12
mart,2017-04-11,75
neil,2017-06-12,80
mart,2017-04-13,94

name
orderdate
cost

3．需求
（1）查询在2017年4月份购买过的顾客及总人数
select
name,
count(1) over()
from(select
name,
date_format(orderdate, 'yyyy-MM') dt
from business)t1
where dt='2019-04'
group by name;

（2）查询顾客的购买明细及月购买总额



（3）上述的场景,要将cost按照日期进行累加
（4）查询顾客上次的购买时间
（5）查询前20%时间的订单信息
=====================================================================
======================================
网页hive场景题   
https://blog.csdn.net/PIPJIN961111/article/details/102598747

create table w1(
uid int,
dt string,
login_status int
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/testdata/w1.txt' into table w1;

数据: t1表 

1 2019-07-11 1 
1 2019-07-12 1 
1 2019-07-13 1 
1 2019-07-14 1 
1 2019-07-15 1 
1 2019-07-16 1 
1 2019-07-17 1 
1 2019-07-18 1 
2 2019-07-11 1 
2 2019-07-12 1 
2 2019-07-13 0 
2 2019-07-14 1 
2 2019-07-15 1 
2 2019-07-16 0 
2 2019-07-17 1 
2 2019-07-18 0 
3 2019-07-11 1 
3 2019-07-12 1 
3 2019-07-13 1 
3 2019-07-14 1 
3 2019-07-15 1 
3 2019-07-16 1 
3 2019-07-17 1 
3 2019-07-18 1
Uid dt login_status(1登录成功,0异常) 

编写连续7天登录的总人数

思路： 先取出成功登陆的（状态为1的）
	  按照uid分区，dt排序，
	  之后用每个日期减去它第前六个日期
	  取出值为6的值就是七天都登陆的（中间没有间隔）
	  求出不同的id，求总人数

select
uid,
dt,
datediff(dt, nvl(lag(dt, 6) over(distribute by uid sort by dt), 0)) num
from w1 where login_status='1'; t1

select
count(distinct uid)
from (select
uid,
dt,
datediff(dt, nvl(lag(dt, 6) over(distribute by uid sort by dt), 0)) num
from w1 where login_status='1')t1
where num=6;

===========================================================
1.1.6 编写 sql 句实现每班前三名，分数一样并列，同时求出前三名

数据： stu表

uid class score 

1 1901 90
2 1901 90
3 1901 83
4 1901 60
5 1902 66
6 1902 23
7 1902 99
8 1902 67
9 1902 87

create table w2(
uid int,
class string,
score int
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/data/w2.txt' into table w2;


select
class,
uid,
score,
row_number() over(distribute by class sort by score desc) rn,
dense_rank() over(distribute by class sort by score desc) rn1,
score-nvl(lag(score, 1) over(distribute by class sort by score desc), 0) rn_diff
from w2; t1

select
class,
uid,
score,
rn,
rn1,
rn_diff
from (select
class,
uid,
score,
row_number() over(distribute by class sort by score desc) rn,
dense_rank() over(distribute by class sort by score desc) rn1,
score-nvl(lag(score, 1) over(distribute by class sort by score desc), 0) rn_diff
from w2)t1
where rn < 4
;

结果数据：
按名次排序的一次的分差：

班级 stu_no score rn rn1 rn_diff 

1901 1 90 1 1 90 
1901 2 90 2 1 0 
1901 3 83 3 2 -7 
1902 7 99 1 1 99 
1902 9 87 2 2 -12 
1902 8 67 3 3 -20
========================================================================
create table w3(
shopid int,
month string,
money int
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/data/w3.txt' into table w3;

数据：

店铺,月份,金额 
a,01,150
a,01,200
b,01,1000
b,01,800
c,01,250
c,01,220
b,01,6000
a,02,2000
a,02,3000
b,02,1000
b,02,1500
c,02,350
c,02,280
a,03,350
a,03,250
shopid  month  money
编写Hive的HQL语句求出每个店铺的当月销售额和累计到当月的总销售额?

select
shopid,
month,
sum(money) monthmoney
from w3
group by shopid,month 
; t1

select
shopid,
month,
monthmoney,
sum(monthmoney) over(cluster by shopid, month) totalmoney
from (select
shopid,
month,
sum(money) monthmoney
from w3
group by shopid,month )t1;

======================================================================
create table w4(
order_id int,
order_type string,
order_time string
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/data/w4.txt' into table w4;

订单及订单类型行列互换
t1表: 
order_id order_type order_time 
111 N 10:00
111 A 10:05
111 B 10:10

是用hql获取结果如下： 
order_id order_type_1 order_type_2 order_time_1 order_time_2 
111 N A 10:00 10:05 
111 A B 10:05 10:10

select * from
(
select
order_id,
order_type order_type_1,
lead(order_type) over(sort by order_time) order_type_2,
order_time order_time_1,
lead(order_time) over(sort by order_time) order_time_2
from w4
)t1
where order_type_2 is not null;
==============================================================
某APP每天访问数据存放在表access_log里面
包含日期字段ds,用户类型字段user_type，用户账号user_id,用户访问时间log_time,
请使用hive的hql语句实现如下需求：

(1)、每天整体的访问UV、PV?
(2)、每天每个类型的访问UV、PV? 
(3)、每天每个类型中最早访问时间和最晚访问时间? 
(4)、每天每个类型中访问次数最高的10个用户?
===================================================================
create table w5(
uid int,
dt string
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/data/w5.txt' into table w5;

数据: 
w5表 
uid,dt
1,2019-08-01
1,2019-08-02
1,2019-08-03
2,2019-08-01
2,2019-08-02
3,2019-08-01
3,2019-08-03
4,2019-07-28
4,2019-07-29
4,2019-08-01
4,2019-08-02
4,2019-08-03

每个用户连续登陆的最大天数？


select
uid,
dt,
date_sub(dt, row_number() over(distribute by uid sort by dt)) newdt
from w5; t1

select
uid,
count(newdt) num
from (select
uid,
dt,
date_sub(dt, row_number() over(distribute by uid sort by dt)) newdt
from w5)t1
group by uid, newdt
; t2

select
uid,
max(num)
from (select
uid,
count(newdt) num
from (select
uid,
dt,
date_sub(dt, row_number() over(distribute by uid sort by dt)) newdt
from w5)t1
group by uid, newdt)t2
group by uid;

思路：
1.先给出排名
2.日期减去排名（注：1,2为一步，排名函数可以放在date_sub()中）
3.求出相同日期个数（按照uid和newdt分组）
4.取出最大的个数值（按照uid分组）

=========================================================================
create table w6(
id int,
sex int,
chinese int,
math int
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/data/w6.txt' into table w6;

id sex chinese math
0 0 70 50
1 0 90 70
2 1 80 90
1、男女各自语文第一名（0:男，1:女)
select
sex,
max(chinese)
from w6
group by sex;

2、男生成绩语文大于80，女生数学成绩大于70
select id,sex,chinese from w6 where sex=0 and chinese > 80
union
select id,sex,math from w6 where sex=1 and chinese > 70;
===============================================================
create table w7(
log_time string,
uid int
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/data/w7.txt' into table w7;

使用hive的hql实现最大连续访问
log_time uid 
2018-10-01 18:00:00,123
2018-10-02 18:00:00,123
2018-10-02 19:00:00,456
2018-10-04 18:00:00,123
2018-10-04 18:00:00,456
2018-10-05 18:00:00,123
2018-10-06 18:00:00,123
求每个用户本月最大连续登录天数

select
date_format(log_time, 'MM_dd') data,
uid
from w7;


create table w7(
log_time string,
uid int
)
row format delimited fields terminated by ',';

select
uid,
date_sub(log_time, row_number() over(distribute by uid sort by log_time)) newdt
from w7; t1

select
uid,
count(newdt) num
from (select
uid,
date_sub(log_time, row_number() over(distribute by uid sort by log_time)) newdt
from w7)t1
group by uid, newdt; t2

select
uid,
max(num)
from (select
uid,
count(newdt) num
from (select
uid,
date_sub(log_time, row_number() over(distribute by uid sort by log_time)) newdt
from w7)t1
group by uid, newdt)t2
group by uid;

注：
	select date_sub('2018-10-06 18:00:00', 1);  ->  2018-10-05
==================================================================================
数据： 
t1表 
uid tags 
1 1,2,3
2 2,3
3 1,2
编写sql实现如下结果： 
uid tag 
1 1
1 2
1 3
2 2
2 3
3 1
3 2

select
uid,
tag
from w8 lateral view explode(tags) t1 as tag;
==========================================================
create table w9_1(
tags string
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/data/w9_1.txt' into table w9_1;

create table w9_2(
id int,
lab string
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/data/w9_2.txt' into table w9_2;

用户标签连接查询
数据： 
T1表: 
Tags 
1,2,3
1,2
2,3 
T2表: 
Id lab 
1 A
2 B
3 C

select
tags,
tag
from w9_1 lateral view explode(split(tags,',')) t1 as tag; t2

select
tags,
tag,
lab
from (select
tags,
tag
from w9_1 lateral view explode(split(tags,',')) t1 as tag)t2 
join w9_2  on t2.tag = w9_2.id; t3

select
tags,
collect_ws(',',collec_set(lab))
from (select
tags,
tag,
w9_2.lab lab
from (select
tags,
tag
from w9_1 lateral view explode(split(tags,',')) t1 as tag)t2 
join w9_2  on t2.tag = w9_2.id)t3
group by tags;

select
tags,
concat_ws(',',collect_set(lab)) lab
from (select
tags,
tag,
10t2.lab lab
from
(select
tags,
tag
from 10t1
lateral view explode(split(tags, ',')) t1 as tag)t2 join 10t2
on t2.tag = 10t2.id)t3
group by tags;

根据T1和T2表的数据，编写sql实现如下结果： 
id tags
1,2,3 A,B,C
1,2 A,B
2,3 B,C

思路：	
1.先炸开Tags为tag，同时要跟上原来的tags，
2.和第二张表join，形成 tags， tag， word
3.统计join

===============================================================

create table w10(
id int,
tag string,
flag int
)
row format delimited fields terminated by ' ';
load data local inpath '/opt/apps/data/w10.txt' into table w10;

数据： 
t1表： 
id tag flag 
a b 2
a b 1
a b 3
c d 6
c d 8
c d 8
编写sql实现如下结果：
id tag flag
a b 1|2|3
c d 6|8

select
id,
tag,
concat_ws('|', collect_set(flag)) flag
from w10
group by id,tag;

select 
id,
tag,
concat_ws("|",collect_set(flag)) flag
from w10
group by id,tag
;

================================================
create table fct_score(
month int,
student_id int,
score int
)
row format delimited fields terminated by '\t';
load data local inpath '/opt/apps/data/fct_score.txt' into table fct_score;


| month | student_id | score |
1	00012	50
1	00013	71
2	00012	46
3	00012	30
3	00013	80
4	00015	55

题目要求：

请使用hql找出所有学生中成绩从来没有低于50分的学生的第一次成绩？
思路：
1.先找出成绩低于50分的学生ID
2.原表和新表 注：【leftjoin】，条件是学号相同，新表中学号少，会出现缺失字段，id处为空
3.找到id为null的就是都大于50的
4.给出排序序号
5.取rn为1的

注：只能找小于的然后排除，取大于50的无法排除只有部分成绩小于50的

select 
* 
from fct_score 
where score < 50; t1

select 
a.*
from fct_score a
left join (select 
* 
from fct_score 
where score < 50)t1
on a.student_id = t1.student_id 
where t1.student_id is null; t2

select
student_id,
score,
row_number() over(distribute by student_id sort by month) rn
from (select 
a.*
from fct_score a
left join (select 
* 
from fct_score 
where score < 50)t1
on a.student_id = t1.student_id 
where t1.student_id is null)t2; t3

select
student_id,
score
from (select
student_id,
score,
row_number() over(distribute by student_id sort by month) rn
from (select 
a.*
from fct_score a
left join (select 
* 
from fct_score 
where score < 50)t1
on a.student_id = t1.student_id 
where t1.student_id is null)t2)t3
where rn = 1;

=========================================================================================
create table click(
clickinfo array<string>
)
row format delimited fields terminated by '\t'
collection items terminated by ' '
;
load data local inpath '/opt/apps/data/click.log' into table click;

create table imp(
impinfo array<string>
)
row format delimited fields terminated by '\t'
collection items terminated by ' ';
load data local inpath '/opt/apps/data/imp.log' into table imp;

假设点击日志文件（click.log）中每行记录格式如下： 
INFO 2016-07-25 00:29:53 requestURI:/click?app=0&p=1&did=18005472&industry=469&adId=31
INFO 2016-07-25 00:29:53 requestURI:/click?app=0&p=2&did=18005472&industry=469&adId=31
INFO 2016-07-25 00:29:53 requestURI:/click?app=0&p=1&did=18005472&industry=469&adId=32
INFO 2016-07-25 00:29:53 requestURI:/click?app=0&p=1&did=18005472&industry=469&adId=33


假设另有曝光日志(imp.log)格式如下：
INFO 2016-07-25 00:29:53 requestURI:/imp?app=0&p=1&did=18005472&industry=469&adId=31
INFO 2016-07-25 00:29:53 requestURI:/imp?app=0&p=2&did=18005472&industry=469&adId=31
INFO 2016-07-25 00:29:53 requestURI:/imp?app=0&p=1&did=18005472&industry=469&adId=32

hive实现统计每个adId的曝光数与点击数，结果同步到mysql(使用sqoop)，表结构为 （adId，曝光数，点击数)

select
clickinfo[3],
clicks
from click lateral view explode(split(clickinfo[3], '&')) t1 as clicks; t1


select
collect_set(clicks)[4] adid
from (select
clickinfo[3] info,
clicks
from click lateral view explode(split(clickinfo[3], '&')) t1 as clicks)t1
group by info; t2

//click端
select
adid,
count(adid) adidclick
from (select
collect_set(clicks)[4] adid
from (select
clickinfo[3] info,
clicks
from click lateral view explode(split(clickinfo[3], '&')) t1 as clicks)t1
group by info)t2
group by adid;

adid    adidclick
adId=31 2
adId=32 1
adId=33 1

adid    adidimp
adId=31 2
adId=32 1


//imp端
select
adid,
count(adid) adidimp
from (select
collect_set(imps)[4] adid
from (select
impinfo[3] info,
imps
from imp lateral view explode(split(impinfo[3], '&')) t1 as imps)t1
group by info)t2
group by adid;


select
t3.adid adid,
t3.adidclick adidclick,
nvl(t4.adidimp,0) adidimp
from (select
adid,
count(adid) adidclick
from (select
collect_set(clicks)[4] adid
from (select
clickinfo[3] info,
clicks
from click lateral view explode(split(clickinfo[3], '&')) t1 as clicks)t1
group by info)t2
group by adid)t3 left join (select
adid,
count(adid) adidimp
from (select
collect_set(imps)[4] adid
from (select
impinfo[3] info,
imps
from imp lateral view explode(split(impinfo[3], '&')) t1 as imps)t1
group by info)t2
group by adid)t4
on t3.adid=t4.adid;
======================================================================================
create table log(
user_id int,
log_id int,
session_id string,
visit_time bigint
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/data/log.txt' into table log;

数据log表：
user_id,log_id,session_id,visit_time
001,1010,11123267866,1569859216
001,1011,11123267867,1569859222
003,1012,11123267868,1569945760
002,1013,11123267869,1569945912
001,1014,11123267870,1570032100
006,1015,11123267871,1570032333
004,1016,11123267872,1570032668
005,1017,11123267873,1570118860
002,1018,11123267874,1570204902
001,1019,11123267875,1570292206
001,1020,11123267876,1570378668

使用hql实现近1月的人平均登录次数？

思路：
	

select
user_id,
log_id,
session_id,
from_unixtime(visit_time, 'yyyy-MM-dd') dt,
from_unixtime(unix_timestamp(), 'yyyy-MM-dd') nowdt
from log; t1

select
user_id,
log_id,
session_id,
month(dt)-month(nowdt) diffmonth
from (select
user_id,
log_id,
session_id,
from_unixtime(visit_time, 'yyyy-MM-dd') dt,
from_unixtime(unix_timestamp(), 'yyyy-MM-dd') nowdt
from log)t1; t2

select
count(1)/count(distinct user_id) cishu
from (select
user_id,
log_id,
session_id,
month(dt)-month(nowdt) diffmonth
from (select
user_id,
log_id,
session_id,
from_unixtime(visit_time, 'yyyy-MM-dd') dt,
from_unixtime(unix_timestamp(), 'yyyy-MM-dd') nowdt
from log)t1)t2
where diffmonth = -1;
=========================================================================
1、users.dat 数据格式为： 2::M::56::16::70072，

共有6040条数据

UserID BigInt, Gender String, Age Int, Occupation String, Zipcode String
用户id，        性别，         年龄，      职业，           邮政编码

2、movies.dat	

数据格式为： 2::Jumanji (1995)::Adventure|Childrens|Fantasy，

共有3883条数据

MovieID BigInt, Title String, Genres String
电影ID，         电影名字，    电影类型

3、ratings.dat	数据格式为： 1::1193::5::978300760，

共有1000209条数据

UserID BigInt, MovieID BigInt, Rating Double, Timestamped String
用户ID，        电影ID，         评分，         评分时间戳

数据要求：
	1.写shell脚本清洗数据。（hive不支持解析多字节的分隔符，
	也就是说hive只能解析':', 不支持解析'::'，
	所以用普通方式建表来使用是行不通的，要求对数据做一次简单清洗）
	2.使用hive能解析的方式进行
==========================
1.正确建表，导入数据（三张表，三份数据），并验证是否正确
	
需要创建一个数据库movie，在movie数据库中创建3张表，t_user，t_movie，t_rating


原始数据是以::进行切分的，所以需要使用能解析多字节分隔符的Serde即可

使用RegexSerde

需要两个参数：
input.regex = "(.*)::(.*)::(.*)" //有几个参数就写几个
output.format.string = "%1$s %2$s %3$s"

create database movie;
use movie;

//创建t_user表
create table t_user(
userid bigint,
sex string,
age int,
occupation string,
zipcode string) 
row format serde 'org.apache.hadoop.hive.serde2.RegexSerDe' 
with serdeproperties('input.regex'='(.*)::(.*)::(.*)::(.*)::(.*)','output.format.string'='%1$s %2$s %3$s %4$s %5$s')
stored as textfile;

//创建t_movie表

use movie;
create table t_movie(
movieid bigint,
moviename string,
movietype string
) 
row format serde 'org.apache.hadoop.hive.serde2.RegexSerDe' 
with serdeproperties('input.regex'='(.*)::(.*)::(.*)','output.format.string'='%1$s %2$s %3$s')
stored as textfile;

//创建t_rating表

use movie;
create table t_rating(
userid bigint,
movieid bigint,
rate double,
times string) 
row format serde 'org.apache.hadoop.hive.serde2.RegexSerDe' 
with serdeproperties('input.regex'='(.*)::(.*)::(.*)::(.*)','output.format.string'='%1$s %2$s %3$s %4$s')
stored as textfile;

//导入数据
load data local inpath "/opt/apps/data/movie/users.dat" into table t_user;
load data local inpath "/opt/apps/data/movie/movies.dat" into table t_movie;
load data local inpath "/opt/apps/data/movie/ratings.dat" into table t_rating;

//查询数据
select * from t_user limit 3;
select * from t_movie limit 3;
select * from t_rating limit 3;

//查询记录数
select count(*) from t_user;
select count(*) from t_movie;
select count(*) from t_rating;



========
2、求被评分次数最多的10部电影，并给出评分次数（电影名，评分次数）
==第一种方法
select
movieid,
count(movieid) count
from rate
group by movieid
order by count desc
limit 10; t1

select
a.moviename,
t1.count count
from movie a join (select
movieid,
count(movieid) count
from rate
group by movieid
order by count desc
limit 10)t1
on a.movieid = t1.movieid
order by count desc

==第二种方法
select
a.moviename,
count(a.moviename) as total
from t_movie a join t_rating b
on a.movieid = b.movieid
group by a.moviename
order by total desc
limit 10;



===============
3、分别求男性，女性当中评分最高的10部电影（性别，电影名，影评分）
	评论次数大于等于50次
//男M 最喜欢的10部
select
max(b.sex),
max(c.moviename),
avg(rate),2 avgRate   
from rate a join user b on a.userid = b.userid
join movie c on a.movieid = c.movieid
where b.sex = "M"
group by a.movieid
having count(a.movieid) >= 50
order by avgRate desc
limit 10
注：评分不要限制位数，可能导致链两个值本来不同，四舍五入后相同，导致排序错误


//女F 最喜欢的10部
select
'F' as sex,
c.moviename moviename,
round(avg(b.rate), 3) rate,
count(b.movieid) total
from t_user a join t_rating b on a.userid = b.userid 
join t_movie c  on b.movieid = c.movieid
where a.sex='F'
group by c.moviename
having  total >= 50
order by rate desc
limit 10
; 


=======
4.求movieid = 2116这部电影各年龄段（因为年龄就只有7个，就按这个7个分就好了）
	的平均影评（年龄段，影评分）

select
a.age,
avg(b.rate) avgRate
from user a join rate b
on a.userid = b.userid
where b.movieid = 2116
group by a.age
order by a.age

=======
5、求最喜欢看电影（影评次数最多）的那位女性评
	最高分的10部电影的平均影评分（观影者，电影名，影评分)
//先求出这个女士是谁
select
a.userid,
count(a.userid) cnt
from rate a join user b on a.userid = b.userid
where b.sex = "F"
group by a.userid
order by cnt desc
limit 1; t1

//求出这10部电影的ID
select
t1.userid,
a.movieid
from rate a join (select
a.userid userid,
count(a.userid) cnt
from rate a join user b on a.userid = b.userid
where b.sex = "F"
group by a.userid
order by cnt desc
limit 1)t1 on a.userid = t1.userid
order by a.rate desc
limit 10; t2

//求出结果
select
t2.userid,
c.moviename,
avg(a.rate) avgRate
from rate a join (select
t1.userid,
a.movieid
from rate a join (select
a.userid,
count(a.userid) cnt
from rate a join user b on a.userid = b.userid
where b.sex = "F"
group by a.userid
order by cnt desc
limit 1)t1 on a.userid = t1.userid
order by a.rate desc
limit 10)t2 on a.movieid = t2.movieid
join movie c on a.movieid = c.movieid
group by a.movieid,t1.userid,c.moviename
order by avgRate desc

t_user:userid bigint,sex string,age int,occupation string,zipcode string
t_movie:movieid bigint,moviename string,movietype string
t_rating:userid bigint,movieid bigint,rate double,times string
===========
6、求好片（评分>=4.0）最多的那个年份的最好看的10部电影

//先把时间换成年
select
movieid,
rate,
year(from_unixtime(times, 'yyyy-MM-dd')) year
from rate
where rate >= 4.0; t1


//求出哪年(时间戳)？
select
year,
count(rate) cnt
from (select
movieid,
rate,
year(from_unixtime(times, 'yyyy-MM-dd')) year
from rate
where rate >= 4.0)t1
group by year
order by cnt desc
limit 1; t2







7、求1997年上映的电影中，评分最高的10部Comedy类电影



8、该影评库中各种类型电影中评价最高的5部电影（类型，电影名，平均影评分）
9、各年评分最高的电影类型（年份，类型，影评分）
10、每个地区最高评分的电影名，把结果存入HDFS（地区，电影名，影评分）

































































==================================================================================
create table log(
user_id int,
log_id int,
session_id string,
visit_time bigint
)
row format delimited fields terminated by ',';
load data local inpath '/opt/apps/data/log.txt' into table log;


//    1. 统计每个用户充值总金额并降序排序（10分）
select
phoneNum,
sum(money) sum
from test
where status = 1
group by phoneNum
order by sum desc

2. 统计所有系统类型登录总次数并降序排序（10分）

select
terminal,
count(terminal) count
from test
group by terminal
order by count desc


|amount|city|                date|district|      lat|       log|money|              openid|   phoneNum|province|status|terminal|
+------+----+--------------------+--------+---------+----------+-----+--------------------+-----------+--------+------+--------+
|  null| 成都市|2018-09-13T02:15:...|     房山区|39.688011|116.066689|   30|opEu45VAwuzCsDr6i...|18334832972|     四川省|     1|     ios|
|  null| 大同市|2018-09-13T02:15:...|     房山区|39.688011|116.066689|   50|opEu45VAwuzCsDr6i...|15101592939|     山西省|     0| Android|
|  null| 大同市|2018-09-13T02:15:...|     房山区|39.688011|116.066689|   30|opEu45VAwuzCsDr6i...|15101599139|     山西省|     1| windows|
|  null| 北京市|2018-09-14T02:15:...|     房山区|39.688011|116.066689|  100|opEu45VAwuzCsDr6i...|16601047774|     北京市|     0|     ios|
|  null|石家庄市|2018-09-13T02:15:...|     房山区|39.688011|116.066689|   30|opEu45VAwuzCsDr6i...|18334832972|     河北省|     1| Android|
|  null| 朝阳区|2018-09-13T02:15:...|     房山区|39.688011|116.066689|   10|opEu45VAwuzCsDr6i...|15101599269|     北京市|     0| windows|
|  null| 北京市|2018-09-13T02:15:...|     房山区|39.688011|116.066689|   30|opEu45VAwuzCsDr6i...|15101599379|     北京市|     1|     ios|
|  null| 邯郸市|2018-09-14T02:15:...|     房山区|39.688011|116.066689|    5|opEu45VAwuzCsDr6i...|18210393998|     河北省|     0|     ios|
|  null|石家庄市|2018-09-13T02:15:...|     房山区|39.688011|116.066689|   20|opEu45VAwuzCsDr6i...|15001390996|     河北省|     1| Android|
|    20|石家庄市|2018-09-13T02:15:...|     房山区|39.688011|116.066689| null|opEu45VAwuzCsDr6i...|18513459993|     河北省|     1| Android|
+------+----+--------------------+--------+---------+----------+-----+--------------------+-----------+--------+------+--------+


3. 统计各省登录的次数的Top3用户

select
province,
phoneNum,
count(phoneNum) count
from test
group by province, phoneNum; t1

select
province,
phoneNum,
count,
row_number() over(distribute by province sort by count desc) rn
from (select
province,
phoneNum,
count(phoneNum) count
from test
group by province, phoneNum)t1; t2

select
province,
phoneNum,
count,
rn
from (select
province,
phoneNum,
count,
row_number() over(distribute by province sort by count desc) rn
from (select
province,
phoneNum,
count(phoneNum) count
from test
group by province, phoneNum)t1)t2
where rn < 4


====================================================================================
场景： 用户行为日志（ods_user_logs）中有关浏览商品的数据如下,数据schema如下

```
user_id
view_params
exts
ct
```



数据如下

```
order_condition 排序条件 01默认排序 02价格排序 03成交量排序 
order_type 1升序 0降序
key 查询热词 如苹果手机、华为、三只松鼠、图书等等(假设我们这里只针对产品信息搜索，即target_type=04)

target_type 查询类型
target_category 查询商品分类如100表示手机类别
target_ids 查询结果显示的商品ID记录

ct 浏览事件发送时间
```



```
{
    "user_id":"u0001",
    "view_params":"order_condition=03&order_type=1&key=华为手机",
    "exts":{
        "target_type":"04",
        "target_category":"100",
        "target_ids":"[
            "1",
            "2",
            "3"
        ]"
    }
    "ct":"1567429965000"
}
```



1. 首先解析上表字段并把结果放到dw_user_logs



2. 请统计每天每小时的用户浏览统计

| 时间       | 产品分类 | UV浏览人次 | PV浏览次数 |
| ---------- | -------- | ---------- | ---------- |
| 2019091809 | 100      | 10000      | 12000      |



3. 请统计产品分类的热门产品TopN（以浏览次数作为比较条件）

| 产品分类 | 产品     |
| -------- | -------- |
| 100      | 1,2,3    |
| 101      | 6,7,8    |
| 102      | 10,11,12 |



4. 统计查询热词

| 热词    | 查询用户数量 | 查询数量 |
| ------- | ------------ | -------- |
| Mate30  | 100000       | 250000   |
| apple11 | 99999        | 199999   |

1.首先解析上表字段并把结果放到dw_user_logs

insert into table dw_user_logs
select
get_json_object(logs, '$.user_id') user_id,
get_json_object(logs, '$.view_params') view_params,
get_json_object(logs, '$.exts') exts,
get_json_object(logs, '$.ct') ct
from table;

2.请统计每天每小时的用户浏览统计
select
ct,
target_category,
count(distinct user_id) uv,
count(user_id) pv
from (
select
user_id,
get_json_object(exts, '$.target_category') target_category,
from_unixtime(ct, 'yyyyMMddHH')) ct,
from dw_user_logs
)t1
group by ct, target_category;

3.请统计产品分类的热门产品TopN（以浏览次数作为比较条件）
select
get_json_object(exts, '$.target_category') target_category,
target_id,
from dw_user_logs
lateral view explode(split(regexp_replace(get_json_object(exts, '$.target_ids'), '[\\[\\]"]', ''), ',')) t1 as target_id
; t1

select
target_category,
target_id,
count(*) count
from ()t1
group by target_category, target_id
order by count desc; t2

select
target_category,
target_id,
row_number() over(distribute by target_category,target_id sort by count desc) rn
from t2; t3

select
target_category,
target_id
from t3
where rn < 4; t4

select
target_category,
concat_ws(',', collect_set(target_id)) 
from t4
group by target_category;

4.统计查询热词
select
user_id,
view_param
from dw_user_logs
lateral view explode(split(view_params, '&')) t1 as view_param; t1


select
user_id,
collect_list(view_param) view_paramList
from t1; t1

select
view_paramList(2) paramKey,
count(user_id) uv
count(*) pv
from t2; t3

select
regexp_replace(paramKey , '[key=]', '') paramKey,
uv,
pv
from t3;

========================================================================



