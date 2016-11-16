


function test()
{
	alert("test");
}

var currentpos,timer;

function start()
{
	timer = setTimeout("scroll()",1000);
}

function stop()
{
	clearTimeout(timer);
}

function scroll()
{
	document.body.scrollTop = document.body.scrollTop + 20;
	//currentpos=document.body.scrollTop;
	//window.scrollTo(0,document.body.scrollTop+10);
	//test();
	timer = setTimeout("scroll()",1000);
	
}