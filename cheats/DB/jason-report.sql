/* Linux */
/* this counts the virtual as subtotal and gives the overall count as total */
select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from Host where Active=1
  and  Domain in ( "ingdirect.com", "main.corp.int")  and OS = "Linux";
       
select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from Host where Active=1
  and  Domain in ( "ingdedev.com", "main.corp.devqa")  and OS = "Linux";

select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from Host where Active=1
  and  Domain in ( "ingqa.com", "main.corp.qaint")  and OS = "Linux";

select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from Host where Active=1
  and  Domain in ( "sharebuilder.com")  and OS = "AIX";

select distinct Domain from Host;  

/*  AIX */
select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from Host where Active=1
  and  Domain in ( "ingdirect.com", "main.corp.int")  and OS = "AIX";
  
select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from Host where Active=1
  and  Domain in ( "ingdedev.com", "main.corp.devqa")  and OS = "AIX";

select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from Host where Active=1
  and  Domain in ( "ingqa.com", "main.corp.qaint")  and OS = "AIX";
    
select OS, count(*) as count from Host where Active = 1
  and Domain IN("ingdirect.com","ingqa.com","ingdedev.com","main.corp.int","main.corp.devqa","main.corp.qaint")
  group by OS;

select count( if(Virtual=1,1,NULL) ) AS vcount, count(*) as total from PROD group by OS;

select OS, count(*) from Prod where Virtual = 1 group by OS;
                                                            
select Domain, OS, Virtual from Host where Active = 1 and OS != "Solaris" order by OS asc;
  
