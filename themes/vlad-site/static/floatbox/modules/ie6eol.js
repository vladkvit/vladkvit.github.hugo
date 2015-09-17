(function () {
	var eolIntro = 'Internet Explorer 6 - End of Life',
		eolText = 'We notice that you are using Internet Explorer version 6.0. ' +
			'Please be advised that this site and many others will have reduced functionality under this very old browser. ' +
			'There are also security risks involved in continuing to use IE6. ' +
			'To make your browsing experience safer and better, and to help web site developers everywhere, ' +
			'please replace your browser with one of the choices available below.',
		chkText = 'Do not show this again (requires a permanent cookie)',
		language = (navigator.language || navigator.userLanguage || 'en').substring(0, 2),
	// browserchoice.eu page has only the following language versions
		choiceLang = /^(bg|cs|da|de|el|es|et|fi|fr|hr|hu|it|nl|pl|pt|ro|sk|sl|sv)$/.test(language) ? language : 'en',
		choicePath = 'http://www.browserchoice.eu/BrowserChoice/browserchoice_' + choiceLang + '.htm',
		choiceHeight = /bg|de|el/.test(language) ? 456 : 420;

	if (fb.jsGet && fb.jsGet['force'] || (new Date()).getFullYear() < 2014 && self == top && !/fbIE6Shown=.+/.test(document.cookie)) {
	// direct load html and use a javascript object for the options parameter
		fb.start(
		// source
			'<div style="padding:10px 20px 0 20px; color:black;">' +
			'<span style="font-size:20px; font-weight:bold;">' + eolIntro + '</span>' +
			'<span><br/>' + eolText + '</span></div>' +
			'<iframe src="' + choicePath + '" width="816" height="' + choiceHeight +
			'" frameborder="0" scrolling="no" style="border-width:0;margin-bottom:5px;"></iframe>',
		// options
			{ width:816, enableDragResize:false, controlsPos:'tr', backgroundColor:'#DAF3FD',
				caption: '<input type="checkbox" id="fbIE6check"/>' +
				'<span> ' + chkText + '</span>',
			// set session cookie when the box is up
				afterItemStart: function () {
					document.cookie = 'fbIE6Shown=true; path=/';
				},
			// if the checkbox is checked, set permanent cookie on box exit
				beforeItemEnd: function () {
					if (fb.$('fbIE6check').checked) {
						var date = new Date();
						date.setTime(date.getTime() + 6480000000);  // 75 days in msecs
						document.cookie = 'fbIE6Shown=true; expires=' + date.toGMTString() + '; path=/';
					}
				}
			}
		);  // fb.start
	}  // if
})();
