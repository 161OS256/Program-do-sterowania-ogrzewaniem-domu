var error = "Wpisz prawid³owe dane.";

function sprd(){
var filtr = 0;
var uLogin = panel.username.value;
var uHaslo = panel.password.value;

if(uLogin=="Marek" && uHaslo=="matolek"){ 
document.panel.action="mbdzien.html";
document.panel.submit();
filtr=1; }

if(filtr==0){ 
alert(error); 
}}

function sprn(){
var filtr = 0;
var uLogin = panel.username.value;
var uHaslo = panel.password.value;

if(uLogin=="Marek" && uHaslo=="matolek"){ 
document.panel.action="mbnoc.html";
document.panel.submit();
filtr=1; }

if(filtr==0){ 
alert(error); 
}}