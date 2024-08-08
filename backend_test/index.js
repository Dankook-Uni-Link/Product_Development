// 기본적인 사용법 연습 코드.

const express = require("express");
const app = express();

app.get("/", function (req, res) {
  res.send("Hello World");
});

app.get("/dog", function (req, res) {
  res.send("강아지");
});

app.get("/cat", function (req, res) {
  res.send("고양이");
});

app.get("/contents", (req, res) => {
  res.json({
    name: "홍길동",
    age: 26,
  });
});

app.get("/user/:id", (req, res) => {
  res.send(`안녕하세요, ${req.params.id}님 !`);
});

app.get("/information/:id", (req, res) => {
  res.send({ 거주지: req.params.id });
});

app.get("/animal/:id", (req, res) => {
  const q = req.query;
  res.send({ 항목1: q, 항목2: q.name, 항목3: q.age });
});

app.listen(3000);
