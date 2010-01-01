// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function userAgent() {
	var ua = navigator.userAgent;
	//alert(ua);

	if(ua.match('MSIE')) engine = 'msie';
	else if(ua.match('KHTML')) engine = 'khtml';  
	else if(ua.match('Opera')) engine = 'opera'; 
	else if(ua.match('Gecko')) engine = 'gecko';

	return engine;
}

function language_format(language_name) {
	if (userAgent() != "khtml") {
		if (language_name == "php4") {
			return "php";
		} else if (language_name == "js") {
			return "javascript";
		} else if (language_name == "html") {
			return "html";
		} else {
			return language_name;
		}
	}
}