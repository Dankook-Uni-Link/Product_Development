DB structure 그대로 사용하면 됨 - survey_structure.sql 파일
mysql command line client에서

    ->CREATE DATABASE survey_db;
  
    ->USE survey_db;

일반 터미널에서

    ->"C:\Program Files\MySQL\MySQL Server 9.1\bin\mysql" -u root -p survey_db < survey_structure.sql
